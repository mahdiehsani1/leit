import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:leit/data/model/item_model.dart';

class AIServiceException implements Exception {
  final String message;
  final String code;
  AIServiceException(this.message, this.code);
}

class AIService {
  static final AIService instance = AIService._();
  AIService._();

  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'europe-west1',
  );

  // متغیری برای پیگیری درخواست فعال (اصل ۶ در سمت کلاینت)
  bool _isRequestActive = false;

  Future<ItemModel?> magicFill(String word) async {
    // جلوگیری از درخواست همزمان (اصل ۶)
    if (_isRequestActive) {
      debugPrint("⚠️ Duplicate request blocked.");
      return null;
    }

    _isRequestActive = true;

    try {
      debugPrint("✨ MagicFill: Requesting data for '$word'...");

      final callable = _functions.httpsCallable('magicFillWord');

      // تنظیم تایم‌اوت سمت کلاینت (اصل ۵ و ۹)
      final result = await callable
          .call({"word": word})
          .timeout(
            const Duration(seconds: 45),
            onTimeout: () {
              throw FirebaseFunctionsException(
                message: "Request timed out",
                code: "deadline-exceeded",
              );
            },
          );

      final response = result.data as Map<Object?, Object?>;
      final data = Map<String, dynamic>.from(response['data'] as Map);

      debugPrint("✨ MagicFill Success: $data");
      return ItemModel.fromAIJson(data);
    } on FirebaseFunctionsException catch (e) {
      debugPrint("❌ Cloud Function Error: ${e.code} - ${e.message}");

      // اصل ۹: ترجمه خطاها به زبان قابل فهم
      String userMessage = "An error occurred.";
      if (e.code == 'permission-denied') {
        userMessage = "Premium subscription required.";
      } else if (e.code == 'resource-exhausted') {
        userMessage = "Daily limit reached or too many requests.";
      } else if (e.code == 'invalid-argument') {
        userMessage = "Invalid word entered.";
      }

      throw AIServiceException(userMessage, e.code);
    } catch (e) {
      debugPrint("❌ General Error: $e");
      throw AIServiceException("Connection failed. Check internet.", "unknown");
    } finally {
      // آزاد کردن قفل درخواست (اصل ۶)
      _isRequestActive = false;
    }
  }
}
