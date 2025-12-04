import { onCall, HttpsError } from "firebase-functions/v2/https";
import { setGlobalOptions } from "firebase-functions/v2";
import * as admin from "firebase-admin";
import { GoogleGenerativeAI } from "@google/generative-ai";

// ----------------------- Global Config -----------------------
setGlobalOptions({
  region: "europe-west1",
  maxInstances: 10,
});

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// ----------------------- Cloud Function -----------------------
export const magicFillWord = onCall(
  {
    region: "europe-west1",
    memory: "256MiB",
    enforceAppCheck: false, // در پروداکشن true کنید
  },

  async (request) => {
    // ------------------------------------------------------------
    // 1. Auth Check
    // ------------------------------------------------------------
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be logged in.");
    }

    // ------------------------------------------------------------
    // 2. Read API Key
    // ------------------------------------------------------------
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      console.error("❌ GEMINI_API_KEY not found in .env");
      throw new HttpsError("internal", "Server configuration error.");
    }

    // ------------------------------------------------------------
    // 3. Validate Input
    // ------------------------------------------------------------
    const rawWord = request.data.word;
    if (!rawWord || typeof rawWord !== "string") {
      throw new HttpsError("invalid-argument", "Word is required.");
    }

    const queryWord = rawWord.trim().toLowerCase();

    // ------------------------------------------------------------
    // 4. Check Cache
    // ------------------------------------------------------------
    const cacheRef = db.collection("vocabulary_cache").doc(queryWord);
    const cacheDoc = await cacheRef.get();

    if (cacheDoc.exists) {
      console.log(`✅ Cache hit: ${queryWord}`);
      return {
        source: "cache",
        data: cacheDoc.data(),
      };
    }

    console.log(`🤖 Processing via Gemini: ${queryWord}`);

    // ------------------------------------------------------------
    // 5. Setup Gemini with JSON Config
    // ------------------------------------------------------------
    const genAI = new GoogleGenerativeAI(apiKey);

    const model = genAI.getGenerativeModel({
      model: "gemini-2.5-flash", 
      generationConfig: {
        responseMimeType: "application/json",
      },
    });

    // ------------------------------------------------------------
    // Prompt
    // ------------------------------------------------------------
    const prompt = `
Analyze the German term: "${rawWord}". 
You are a backend API for a Leitner app.

CRITICAL RULES:
1. Output MUST be valid JSON.
2. "type" field MUST be one of: 
   ["word", "verb", "adjective", "adverb", "nounPhrase", "sentence", "idiom", "verbNounPhrase"] 
   - Use "word" for general nouns.
3. If a field is not applicable, return null (do not omit it).

JSON Structure:
{
  "type": "string",
  "german": "Corrected German term (Capitalized if noun)",
  "en": ["English translation 1", "English translation 2"],
  "fa": ["ترجمه فارسی ۱", "ترجمه فارسی ۲"],
  "examples": ["German example sentence"],
  "examplesEn": ["English translation of example"],
  "examplesFa": ["ترجمه فارسی مثال"],
  "level": "A1|A2|B1|B2|C1|C2",
  "article": "der|die|das|null",
  "plural": "Plural form or null",
  "prateritum": "Präteritum form or null",
  "perfekt": "Perfekt form or null",
  "partizip": "Partizip II form or null",
  "synonyms": ["synonym1"] or null,
  "antonyms": ["antonym1"] or null,
  "explanation": "Explanation in Persian (for idioms/grammar) or null",
  "tags": "tag1, tag2",
  "notes": "string or null"
}
`;

    // ------------------------------------------------------------
    // 6. Generate & Save
    // ------------------------------------------------------------
    try {
      const result = await model.generateContent(prompt);

      let rawResponse = result.response.text().trim();

      // Clean up just in case (though responseMimeType usually ensures clean JSON)
      rawResponse = rawResponse
        .replace(/```json/g, "")
        .replace(/```/g, "")
        .trim();

      const finalJSON = JSON.parse(rawResponse);

      const dataToSave = {
        ...finalJSON,
        originalQuery: queryWord,
        createdAt: Date.now(),
        fetchedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      await cacheRef.set(dataToSave);

      return {
        source: "api",
        data: dataToSave,
      };
    } catch (err: any) {
      console.error("❌ Gemini Error:", err);
      throw new HttpsError(
        "internal",
        `AI processing failed: ${err?.message || "Unknown error"}`
      );
    }
  }
);
