// ignore_for_file: curly_braces_in_flow_control_structures

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

  bool _isRequestActive = false;

  Future<ItemModel?> magicFill(String word, String? userSelectedType) async {
    // جلوگیری از درخواست همزمان (Concurrency Control)
    if (_isRequestActive) return null;
    _isRequestActive = true;

    try {
      debugPrint(
        "✨ MagicFill: Requesting '$word' [Type: $userSelectedType]...",
      );

      final callable = _functions.httpsCallable('magicFillWord');

      // افزایش تایم‌اوت به ۸۰ ثانیه (۲۰ ثانیه بیشتر از سرور)
      final result = await callable
          .call({"word": word, "userType": userSelectedType})
          .timeout(
            const Duration(seconds: 80),
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
      String userMessage = "An error occurred.";
      if (e.code == 'permission-denied')
        userMessage = "Premium subscription required.";
      else if (e.code == 'resource-exhausted')
        userMessage = "Daily limit reached.";
      else if (e.code == 'invalid-argument')
        userMessage = e.message ?? "Invalid input.";
      else if (e.code == 'deadline-exceeded')
        userMessage = "Server took too long. Try again.";

      throw AIServiceException(userMessage, e.code);
    } catch (e) {
      debugPrint("❌ General Error: $e");
      throw AIServiceException("Connection failed. Check internet.", "unknown");
    } finally {
      _isRequestActive = false;
    }
  }
}
