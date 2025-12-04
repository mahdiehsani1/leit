import 'dart:ui'; // برای PlatformDispatcher

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:leit/data/service/fcm_service.dart'; // <--- ایمپورت جدید
import 'package:leit/data/service/notification_service.dart';
import 'package:leit/l10n/app_localizations.dart';
import 'package:leit/screens/add_item/add_item.dart'; // <--- ایمپورت صفحه افزودن
import 'package:leit/screens/onboarding/onboarding.dart';
import 'package:leit/tabs.dart';
import 'package:leit/theme/theme.dart';
import 'package:leit/theme/theme_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

// تعریف کلید نویگیشن به صورت گلوبال
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ثبت خطاها
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // راه‌اندازی FCM
  try {
    final fcmService = FCMService();
    await fcmService.init();
    // فعال‌سازی لیسنرهای کلیک روی نوتیفیکیشن
    fcmService.setupInteractions(navigatorKey);
  } catch (e) {
    debugPrint("FCM Init Error: $e");
  }

  // راه‌اندازی نوتیفیکیشن محلی
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
    const String primaryFont = 'Poppins';
    const List<String> fontFallback = ['IRANSans'];

    return MaterialApp(
      // --- تنظیم کلید نویگیشن (خیلی مهم برای هدایت خودکار) ---
      navigatorKey: navigatorKey,

      debugShowCheckedModeBanner: false,
      title: 'Leit',
      themeMode: themeController.themeMode,

      theme: AppTheme.light.copyWith(
        textTheme: AppTheme.light.textTheme.apply(
          fontFamily: primaryFont,
          fontFamilyFallback: fontFallback,
        ),
      ),
      darkTheme: AppTheme.dark.copyWith(
        textTheme: AppTheme.dark.textTheme.apply(
          fontFamily: primaryFont,
          fontFamilyFallback: fontFallback,
        ),
      ),

      locale: themeController.locale,
      supportedLocales: const [Locale('en'), Locale('de')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // --- تعریف مسیرها (Routes) ---
      // این بخش برای اینکه pushNamed('/add_item') کار کند ضروری است
      routes: {
        '/add_item': (context) => const AddItemScreen(),
        // می‌توانید مسیرهای دیگر را هم اینجا اضافه کنید
      },

      home: showIntro ? const IntroScreen() : TabsScreen(),
    );
  }
}
