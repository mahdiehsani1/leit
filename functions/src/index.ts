import {onCall, HttpsError} from "firebase-functions/v2/https";
import {setGlobalOptions} from "firebase-functions/v2";
import * as admin from "firebase-admin";
import {GoogleGenerativeAI} from "@google/generative-ai";

setGlobalOptions({maxInstances: 10});

if (admin.apps.length === 0) {
  admin.initializeApp();
}
const db = admin.firestore();

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || "");
const model = genAI.getGenerativeModel({
  model: "gemini-1.5-flash",
  generationConfig: {
    responseMimeType: "application/json",
  },
});

export const magicFillWord = onCall(
  {region: "europe-west1"},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be logged in.");
    }

    const rawWord = request.data.word;
    if (!rawWord || typeof rawWord !== "string") {
      throw new HttpsError("invalid-argument", "Word is required.");
    }

    const queryWord = rawWord.trim().toLowerCase();

    const cacheRef = db.collection("vocabulary_cache").doc(queryWord);
    const cacheDoc = await cacheRef.get();

    if (cacheDoc.exists) {
      return {source: "cache", data: cacheDoc.data()};
    }

    const prompt = `
    Analyze the German term: "${rawWord}".
    You are a backend API for a Leitner box app. Return ONLY a JSON object.
    
    Strict Output Schema Rules:
    1. "type": Must be EXACTLY one of these strings: 
       ["word", "verb", "adjective", "adverb", "nounPhrase", "sentence", 
       "idiom", "verbNounPhrase"]
       - Use "word" for generic nouns.
    
    2. "german": The corrected German term (Capitalized if noun).
    
    3. Translations (Arrays):
       - "en": List of English translations.
       - "fa": List of Persian translations.
    
    4. Examples (Arrays must have equal length):
       - "examples": List of German example sentences (A1-B2 level).
       - "examplesEn": Corresponding English translations.
       - "examplesFa": Corresponding Persian translations.
    
    5. Type Specific Fields (Return null if not applicable):
       - If type is "word":
         "article": "der", "die", or "das".
         "plural": The plural form.
       
       - If type is "verb":
         "prateritum": e.g., "spielte".
         "perfekt": e.g., "hat gespielt".
         "partizip": e.g., "gespielt" (Partizip II).
       
       - If type is "adjective":
         "synonyms": List of German synonyms.
         "antonyms": List of German antonyms.
       
       - If type is "adverb", "idiom", "sentence", "nounPhrase", 
         "verbNounPhrase":
         "explanation": A usage note or grammar explanation in Persian.
    
    6. General:
       - "level": CEFR level ("A1", "A2", "B1", "B2", "C1").
       - "tags": A string of comma-separated tags.
       - "notes": Any additional short note (optional, or null).

    Json:
  `;

    try {
      const result = await model.generateContent(prompt);
      const responseText = result.response.text();
      const aiData = JSON.parse(responseText);

      const finalData = {
        ...aiData,
        createdAt: Date.now(),
        fetchedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      await cacheRef.set(finalData);

      return {source: "api", data: finalData};
    } catch (error) {
      console.error("Gemini Error:", error);
      throw new HttpsError("internal", "AI processing failed.");
    }
  }
);
