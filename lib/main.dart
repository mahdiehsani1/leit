import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:leit/data/service/notification_service.dart';
import 'package:leit/l10n/app_localizations.dart';
import 'package:leit/screens/onboarding/onboarding.dart';
import 'package:leit/tabs.dart';
import 'package:leit/theme/theme.dart';
import 'package:leit/theme/theme_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // فعال‌سازی کرش‌لیتیکس برای گزارش خطاهای برنامه
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // راه‌اندازی سرویس نوتیفیکیشن با مدیریت خطا
  try {
    await NotificationService().init();
  } catch (e) {
    debugPrint("Notification Init Error: $e");
  }

  final prefs = await SharedPreferences.getInstance();
  final bool showIntro = prefs.getBool('showIntro') ?? true;

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: Leit(showIntro: showIntro),
    ),
  );
}

class Leit extends StatelessWidget {
  final bool showIntro;
  const Leit({super.key, required this.showIntro});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);

    // تنظیمات فونت:
    // 1. فونت اصلی: Poppins (برای متون انگلیسی و آلمانی و اعداد)
    // 2. فونت پشتیبان: IRANSans (برای نمایش صحیح متون فارسی که کاربر وارد می‌کند)
    const String primaryFont = 'Poppins';
    const List<String> fontFallback = ['IRANSans'];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Leit',
      themeMode: themeController.themeMode,

      // --- تنظیمات تم روشن ---
      theme: AppTheme.light.copyWith(
        textTheme: AppTheme.light.textTheme.apply(
          fontFamily: primaryFont,
          fontFamilyFallback: fontFallback,
        ),
      ),

      // --- تنظیمات تم تاریک ---
      darkTheme: AppTheme.dark.copyWith(
        textTheme: AppTheme.dark.textTheme.apply(
          fontFamily: primaryFont,
          fontFamilyFallback: fontFallback,
        ),
      ),

      // --- تنظیمات زبان ---
      // از کنترلر زبان می‌گیرد (که الان فقط en یا de خواهد بود)
      locale: themeController.locale,

      supportedLocales: const [
        Locale('en'), // انگلیسی
        Locale('de'), // آلمانی
        // Locale('fa') // حذف شد: زبان فارسی دیگر به عنوان زبان محیط برنامه استفاده نمی‌شود
      ],

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: showIntro ? const IntroScreen() : TabsScreen(),
    );
  }
}
