import { onCall, HttpsError } from "firebase-functions/v2/https";
import { setGlobalOptions } from "firebase-functions/v2";
import * as admin from "firebase-admin";
import { GoogleGenerativeAI } from "@google/generative-ai";

setGlobalOptions({
  region: "europe-west1",
  maxInstances: 10,
  timeoutSeconds: 60, // سرور ۶۰ ثانیه وقت دارد
});

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// Constants
const MAX_DAILY_REQUESTS = 50; 
const MIN_REQUEST_INTERVAL_MS = 3000;
const MAX_INPUT_LENGTH = 100;
const CACHE_TTL_DAYS = 30; // کش بعد از ۳۰ روز منقضی می‌شود

// ----------------------- Helpers -----------------------

function validateInput(text: any): string {
  if (!text || typeof text !== "string") {
    throw new HttpsError("invalid-argument", "Input invalid.");
  }
  const cleanText = text.trim();
  if (cleanText.length > MAX_INPUT_LENGTH) throw new HttpsError("invalid-argument", "Text too long.");
  if (cleanText.length < 2) throw new HttpsError("invalid-argument", "Text too short.");
  // جلوگیری از XSS ولی اجازه دادن به کاراکترهای آلمانی
  if (/(<script|javascript:)/i.test(cleanText)) {
    throw new HttpsError("invalid-argument", "Invalid content detected.");
  }
  return cleanText; 
}

// اعتبارسنجی ساختار خروجی هوش مصنوعی (جلوگیری از توهم ساختاری)
function validateAIResponse(data: any): any {
  if (!data || typeof data !== 'object') throw new Error("Response is not an object.");
  
  // اگر نامعتبر تشخیص داده شد
  if (data.isValid === false) return data;

  // چک کردن فیلدهای ضروری
  const requiredFields = ['german', 'en', 'fa', 'type', 'level'];
  for (const field of requiredFields) {
    if (!(field in data)) throw new Error(`Missing required field: ${field}`);
  }

  // چک کردن تایپ آرایه‌ها
  if (!Array.isArray(data.en) || !Array.isArray(data.fa)) {
     throw new Error("Translation fields must be arrays.");
  }

  return data;
}

async function checkPremium(uid: string) {
  const userDoc = await db.collection("users").doc(uid).get();
  const userData = userDoc.data();
  if (!userData || !userData.isPremium) {
    throw new HttpsError("permission-denied", "Premium subscription required.");
  }
}

async function checkAndIncrementRateLimit(uid: string) {
  const usageRef = db.collection("user_usage").doc(uid);
  await db.runTransaction(async (transaction) => {
    const doc = await transaction.get(usageRef);
    const now = Date.now();
    const today = new Date().toDateString();
    let data = doc.data() || { dailyCount: 0, lastRequestTime: 0, date: today };

    if (data.date !== today) data = { dailyCount: 0, lastRequestTime: 0, date: today };

    if (now - data.lastRequestTime < MIN_REQUEST_INTERVAL_MS) {
      throw new HttpsError("resource-exhausted", "Please wait a moment.");
    }
    if (data.dailyCount >= MAX_DAILY_REQUESTS) {
      throw new HttpsError("resource-exhausted", "Daily limit reached.");
    }

    transaction.set(usageRef, {
      dailyCount: data.dailyCount + 1,
      lastRequestTime: now,
      date: today
    }, { merge: true });
  });
}

// ----------------------- Cloud Function -----------------------
export const magicFillWord = onCall(
  {
    region: "europe-west1",
    memory: "256MiB",
    enforceAppCheck: false,
  },
  async (request) => {
    if (!request.auth) throw new HttpsError("unauthenticated", "User must be logged in.");
    const uid = request.auth.uid;

    const rawWord = validateInput(request.data.word);
    const userType = request.data.userType;
    const cacheKey = `${rawWord.toLowerCase()}_${userType || 'auto'}`;

    try {
      await Promise.all([
        checkPremium(uid),
        checkAndIncrementRateLimit(uid)
      ]);
    } catch (e) {
      throw e;
    }

    // --- Cache Check with TTL ---
    const cacheRef = db.collection("vocabulary_cache").doc(cacheKey);
    const cacheDoc = await cacheRef.get();

    if (cacheDoc.exists) {
      const cachedData = cacheDoc.data();
      const now = Date.now();
      // اگر کش منقضی نشده باشد، برگردان
      if (cachedData && cachedData.expiresAt && now < cachedData.expiresAt) {
          if (cachedData.isValid === false) {
             throw new HttpsError("invalid-argument", "Input is not a valid German term.");
          }
          console.log(`✅ Cache hit: ${cacheKey}`);
          return { source: "cache", data: cachedData };
      }
      console.log(`⚠️ Cache expired or missing for: ${cacheKey}`);
    }

    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) throw new HttpsError("internal", "Server config error.");

    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({
      model: "gemini-2.5-flash",
      generationConfig: { responseMimeType: "application/json" },
    });

    let typeInstruction = "";
    if (userType) {
        typeInstruction = `User explicitly selected type: "${userType}". Optimize output for this type.`;
        if(userType === 'verbNounPhrase') typeInstruction += " Treat as Nomen-Verb-Verbindung.";
    }

    // --- Prompt Injection Protection & Homonyms Handling ---
    const prompt = `
      Act as an expert German language tutor. Analyze the input enclosed in <input_term> tags.
      
      <input_term>${rawWord}</input_term>

      ${typeInstruction}

      **CRITICAL RULES:**
      1. **SPELLING CORRECTION:** If input is misspelled (e.g. "abeiten"), CORRECT IT (to "arbeiten").
      2. **LANGUAGE CHECK:** If input is clearly English sentence ("This is a book"), return { "isValid": false }. Loanwords (Laptop, Gift) are VALID.
      3. **FALSE FRIENDS:** "Gift" = Poison. "Art" = Kind. Always prefer German meaning.
      4. **HOMONYMS (Ambiguity):** If the word has multiple distinct meanings (e.g. "Bank" -> Bench OR Financial Bank), choose the **most common/A1-B1 level** meaning unless the 'type' suggests otherwise. Mention the other meaning briefly in 'notes'.
      5. **NORMALIZATION:** Plural->Singular. Conjugated->Infinitive.
      6. **GRAMMAR:** Capitalize Nouns. Add Aux to Perfekt.

      **JSON SCHEMA:**
      {
        "isValid": true,
        "type": "word|verb|adjective|adverb|nounPhrase|sentence|idiom|verbNounPhrase",
        "german": "Corrected Term",
        "en": ["English Translation"],
        "fa": ["ترجمه فارسی"],
        "examples": ["German sentence"],
        "examplesEn": ["English"],
        "examplesFa": ["Persian"],
        "level": "A1-C2",
        "article": "der|die|das|null",
        "plural": "string|null",
        "prateritum": "string|null",
        "perfekt": "string|null",
        "partizip": "string|null",
        "synonyms": ["string"]|null,
        "antonyms": ["string"]|null,
        "explanation": "string|null",
        "tags": "string|null",
        "notes": "string|null"
      }
    `;

    try {
      const result = await model.generateContent(prompt);
      const responseText = result.response.text();
      const cleanedJson = responseText.replace(/```json|```/g, "").trim();
      const finalData = JSON.parse(cleanedJson);

      // Validate Structure (Prevent Hallucinations)
      const validatedData = validateAIResponse(finalData);

      if (validatedData.isValid === false) {
         throw new HttpsError("invalid-argument", "Input does not appear to be a valid German term.");
      }

      // Save with TTL
      const dataToSave = {
        ...validatedData,
        originalQuery: rawWord,
        userType: userType || null,
        createdAt: Date.now(),
        expiresAt: Date.now() + (CACHE_TTL_DAYS * 24 * 60 * 60 * 1000), // تاریخ انقضا
        fetchedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      await cacheRef.set(dataToSave);

      return { source: "api", data: dataToSave };

    } catch (err: any) {
      console.error("❌ Processing Failed:", err);
      if (err instanceof HttpsError) throw err;
      throw new HttpsError("internal", "AI processing failed. Please try again.");
    }
  }
);