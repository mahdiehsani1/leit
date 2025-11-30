// ignore_for_file: avoid_print

import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  final FlutterTts _flutterTts = FlutterTts();

  Future<void> init() async {
    await _flutterTts
        .setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        ]);
    await _flutterTts.awaitSpeakCompletion(true);
  }

  static Future<void> speak(String text, String langCode) async {
    await _instance._speakInternal(text, langCode);
  }

  // متد _speakInternal را به این شکل ایمن کنید:

  Future<void> _speakInternal(String text, String langCode) async {
    if (text.trim().isEmpty) return;

    try {
      await _flutterTts.stop();

      // تنظیمات پایه (قبل از زبان)
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5);

      final isAvailable = await _flutterTts.isLanguageAvailable(langCode);

      if (isAvailable) {
        await _flutterTts.setLanguage(langCode);
        await _flutterTts.speak(text);
      } else {
        // اگر زبان درخواستی (مثلا آلمانی) نبود، تلاش با انگلیسی
        print("Language $langCode not available, trying US English");
        final enAvailable = await _flutterTts.isLanguageAvailable("en-US");
        if (enAvailable) {
          await _flutterTts.setLanguage("en-US");
          await _flutterTts.speak(text);
        }
      }
    } catch (e) {
      print("TTS Critical Error: $e");
    }
  }

  static Future<void> stop() async {
    await _instance._flutterTts.stop();
  }
}
