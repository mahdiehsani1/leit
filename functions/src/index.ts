import { onCall, HttpsError } from "firebase-functions/v2/https";
import { setGlobalOptions } from "firebase-functions/v2";
import * as admin from "firebase-admin";
import { GoogleGenerativeAI } from "@google/generative-ai"; // اصلاح شد: SchemaType حذف شد

// ----------------------- Global Config -----------------------
setGlobalOptions({
  region: "europe-west1",
  maxInstances: 10, // کنترل هزینهA
  timeoutSeconds: 60, // جلوگیری از پردازش طولانی (اصل ۵)
});

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// ----------------------- Constants -----------------------
const MAX_DAILY_REQUESTS = 50; // محدودیت روزانه (اصل ۲)
const MIN_REQUEST_INTERVAL_MS = 3000; // جلوگیری از درخواست رگباری (اصل ۶)
const MAX_INPUT_LENGTH = 100; // محدودیت طول ورودی (اصل ۳)

// ----------------------- Helpers -----------------------

// اعتبارسنجی متن ورودی (اصل ۳)
function validateInput(text: any): string {
  if (!text || typeof text !== "string") {
    throw new HttpsError("invalid-argument", "Input invalid.");
  }
  const cleanText = text.trim();
  if (cleanText.length > MAX_INPUT_LENGTH) {
    throw new HttpsError("invalid-argument", "Text too long (max 100 chars).");
  }
  if (cleanText.length < 2) {
    throw new HttpsError("invalid-argument", "Text too short.");
  }
  // جلوگیری از لینک و کاراکترهای مخرب
  if (/(http|www|\.com|javascript:|script>)/i.test(cleanText)) {
    throw new HttpsError("invalid-argument", "Invalid content detected.");
  }
  return cleanText.toLowerCase();
}

// بررسی وضعیت پریمیوم (اصل ۱)
async function checkPremium(uid: string) {
  const userDoc = await db.collection("users").doc(uid).get();
  const userData = userDoc.data();
  // فرض: فیلدی به نام isPremium یا subscriptionStatus وجود دارد
  if (!userData || !userData.isPremium) {
    throw new HttpsError("permission-denied", "This feature is for Premium users only.");
  }
}

// مدیریت Rate Limit و Concurrency (اصل ۲ و ۶ و ۷)
async function checkAndIncrementRateLimit(uid: string) {
  const usageRef = db.collection("user_usage").doc(uid);
  
  await db.runTransaction(async (transaction) => {
    const doc = await transaction.get(usageRef);
    const now = Date.now();
    const today = new Date().toDateString();

    let data = doc.data() || { dailyCount: 0, lastRequestTime: 0, date: today };

    // ریست کردن شمارنده اگر روز عوض شده باشد
    if (data.date !== today) {
      data = { dailyCount: 0, lastRequestTime: 0, date: today };
    }

    // ۱. جلوگیری از درخواست رگباری (همزمانی)
    if (now - data.lastRequestTime < MIN_REQUEST_INTERVAL_MS) {
      throw new HttpsError("resource-exhausted", "Please wait a moment before trying again.");
    }

    // ۲. بررسی سقف روزانه
    if (data.dailyCount >= MAX_DAILY_REQUESTS) {
      // ثبت لاگ مشکوک (اصل ۷)
      console.warn(`🚨 User ${uid} exceeded daily limit.`);
      throw new HttpsError("resource-exhausted", "Daily limit reached.");
    }

    // آپدیت شمارنده
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
    memory: "512MiB",
    enforceAppCheck: false, // امنیت بالاتر (پیشنهاد می‌شود فعال کنید)
  },
  async (request) => {
    // ------------------------------------------------------------
    // 1. Auth & Context Check (اصل ۱)
    // ------------------------------------------------------------
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be logged in.");
    }
    const uid = request.auth.uid;

    // ------------------------------------------------------------
    // 2. Input Validation (اصل ۳)
    // ------------------------------------------------------------
    const queryWord = validateInput(request.data.word);

    // ------------------------------------------------------------
    // 3. Security Checks (Premium & Rate Limit) (اصل ۱, ۲, ۶, ۷)
    // ------------------------------------------------------------
    try {
      await Promise.all([
        checkPremium(uid),
        checkAndIncrementRateLimit(uid)
      ]);
    } catch (e) {
      // اگر خطای Firestore بود، همان ارور را برگردان
      throw e;
    }

    // ------------------------------------------------------------
    // 4. Cache Check (اصل ۴)
    // ------------------------------------------------------------
    const cacheRef = db.collection("vocabulary_cache").doc(queryWord);
    const cacheDoc = await cacheRef.get();

    if (cacheDoc.exists) {
      console.log(`✅ Cache hit: ${queryWord}`);
      return { source: "cache", data: cacheDoc.data() };
    }

    // ------------------------------------------------------------
    // 5. External API Call (Gemini)
    // ------------------------------------------------------------
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) throw new HttpsError("internal", "Server config error.");

    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({
      model: "gemini-2.5-flash",
      generationConfig: {
        responseMimeType: "application/json", // (اصل ۸)
      },
    });

    // پرامپت دقیق و استاندارد (اصل ۸)
    const prompt = `
      Analyze the German term: "${queryWord}".
      Output strict JSON only. No markdown. No comments.
      Fields not applicable must be null.
      
      Schema:
      {
        "type": "word|verb|adjective|adverb|nounPhrase|sentence|idiom|verbNounPhrase",
        "german": "string",
        "en": ["string"],
        "fa": ["string"],
        "examples": ["string"],
        "examplesEn": ["string"],
        "examplesFa": ["string"],
        "level": "A1|A2|B1|B2|C1|C2",
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
      // اصل ۵: AbortSignal در onCall مستقیماً پشتیبانی نمی‌شود، اما Timeout گلوبال فانکشن عمل می‌کند.
      const result = await model.generateContent(prompt);
      const responseText = result.response.text();
      
      // پاک‌سازی احتمالی JSON (برای اطمینان)
      const cleanedJson = responseText.replace(/```json|```/g, "").trim();
      const finalData = JSON.parse(cleanedJson);

      // ذخیره در کش
      const dataToSave = {
        ...finalData,
        createdAt: Date.now(),
        fetchedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      await cacheRef.set(dataToSave);

      return { source: "api", data: dataToSave };

    } catch (err: any) {
      console.error("❌ Processing Failed:", err);
      // اصل ۹: مدیریت خطای مناسب
      throw new HttpsError("internal", "AI processing failed. Please try again.");
    }
  }
);