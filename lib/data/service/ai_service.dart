import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:leit/data/model/item_model.dart';

class AIService {
  // الگوی سینگلتون برای دسترسی راحت‌تر
  static final AIService instance = AIService._();
  AIService._();

  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'europe-west1', // باید دقیقاً با ریجن Cloud Function یکی باشد
  );

  Future<ItemModel?> magicFill(String word) async {
    try {
      debugPrint("✨ MagicFill: Requesting data for '$word'...");

      final result = await _functions.httpsCallable('magicFillWord').call({
        "word": word,
      });

      final response = result.data as Map<Object?, Object?>;
      final data = Map<String, dynamic>.from(response['data'] as Map);

      debugPrint("✨ MagicFill Success: $data");

      // تبدیل JSON دریافتی به ItemModel
      return ItemModel.fromAIJson(data);
    } on FirebaseFunctionsException catch (e) {
      debugPrint("❌ Cloud Function Error: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("❌ General Error: $e");
      return null;
    }
  }
}
