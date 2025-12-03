import {onCall, HttpsError} from "firebase-functions/v2/https";
import {setGlobalOptions} from "firebase-functions/v2";
import * as admin from "firebase-admin";
import {GoogleGenerativeAI} from "@google/generative-ai";

setGlobalOptions({maxInstances: 10});

if (admin.apps.length === 0) {
  admin.initializeApp();
}
const db = admin.firestore();

if (!process.env.GEMINI_API_KEY) {
  throw new Error("❌ Missing GEMINI_API_KEY in environment variables");
}

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

const model = genAI.getGenerativeModel({
  model: "gemini-1.5-flash-latest",
  generationConfig: {
    responseMimeType: "application/json",
  },
});

export const magicFillWord = onCall(
  {region: "europe-west1"},
  async (request) => {
    // --- Authentication ---
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be logged in.");
    }

    // --- Input validation ---
    const rawWord = request.data.word;
    if (!rawWord || typeof rawWord !== "string") {
      throw new HttpsError("invalid-argument", "Word is required.");
    }

    const queryWord = rawWord.trim().toLowerCase();

    // --- Cache Check ---
    const cacheRef = db.collection("vocabulary_cache").doc(queryWord);
    const cacheDoc = await cacheRef.get();

    if (cacheDoc.exists) {
      return {source: "cache", data: cacheDoc.data()};
    }

    // --- Prompt ---
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

    // --- AI request & JSON cleanup ---
    try {
      const result = await model.generateContent(prompt);
      let responseText = result.response.text();

      // ░░░░░░░░░ Clean Markdown + Unicode garbage ░░░░░░░░░
      responseText = responseText
        .replace(/```json/g, "")
        .replace(/```/g, "")
        .replace(/\u2028|\u2029|\u200f|\u200e/g, "") // Remove RTL/LTR characters
        .trim();

      // ░░░░░░░░░ Log for debugging ░░░░░░░░░
      console.log("=== RAW GEMINI OUTPUT START ===");
      console.log(responseText);
      console.log("=== RAW GEMINI OUTPUT END ===");

      // ░░░░░░░░░ Extract JSON blocks ░░░░░░░░░
      // Attempt to find JSON structure by matching braces
      const jsonBlocks = responseText.match(/\{[\s\S]*?\}/g);

      // If no blocks found, try parsing the whole cleaned text directly as a fallback
      if (!jsonBlocks || jsonBlocks.length === 0) {
         try {
            const directParse = JSON.parse(responseText);
            // If successful, proceed with saving
            const finalData = {
              ...directParse,
              createdAt: Date.now(),
              fetchedAt: admin.firestore.FieldValue.serverTimestamp(),
            };
            await cacheRef.set(finalData);
            return {source: "api", data: finalData};
         } catch(e) {
            throw new HttpsError("internal", "No JSON object found in AI output.");
         }
      }

      let parsed = null;

      // Try all blocks until a valid JSON is found
      for (const block of jsonBlocks) {
        try {
          // remove trailing comma before closing brace/bracket if present
          const cleaned = block.replace(/,(\s*[}\]])/g, "$1");

          parsed = JSON.parse(cleaned);
          // If parse succeeds, we assume this is our JSON
          break;
        } catch (e) {
          continue;
        }
      }

      if (!parsed) {
        throw new HttpsError("internal", "AI returned invalid JSON.");
      }

      // --- Final object ---
      const finalData = {
        ...parsed,
        createdAt: Date.now(),
        fetchedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      // Save to cache
      await cacheRef.set(finalData);

      return {source: "api", data: finalData};

    } catch (error) {
      console.error("Gemini Error:", error);
      throw new HttpsError("internal", "AI processing failed.");
    }
  }
);