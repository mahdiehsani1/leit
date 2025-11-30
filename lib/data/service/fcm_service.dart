import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:leit/data/service/notification_service.dart';

// هندلر پس‌زمینه (حتماً باید خارج از کلاس و Top-Level باشد)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

class FCMService {
  // ساخت سینگلتون برای دسترسی راحت‌تر (اختیاری)
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final _firebaseMessaging = FirebaseMessaging.instance;
  final _notificationService = NotificationService();

  Future<void> init() async {
    // 1. درخواست مجوز
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // 2. چاپ توکن برای تست
    final fcmToken = await _firebaseMessaging.getToken();
    debugPrint("========================================");
    debugPrint("🔥 FCM TOKEN: $fcmToken");
    debugPrint("========================================");

    // 3. تنظیم هندلر پس‌زمینه
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 4. دریافت پیام وقتی برنامه باز است (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // نمایش نوتیفیکیشن محلی (چون وقتی اپ باز است، فایربیس خودکار نشان نمی‌دهد)
      if (notification != null && android != null) {
        _notificationService.showNotification(
          id: notification.hashCode,
          title: notification.title ?? '',
          body: notification.body ?? '',
          payload: 'navigate_to_add_item', // پی‌لود ثابت برای تست
        );
      }
    });

    // سابسکرایب به تاپیک عمومی (برای ارسال پیام به همه)
    await _firebaseMessaging.subscribeToTopic('all_users');
  }

  // --- بخش مدیریت کلیک و نویگیشن ---
  Future<void> setupInteractions(GlobalKey<NavigatorState> navigatorKey) async {
    // سناریو ۱: برنامه کاملاً بسته است و با نوتیفیکیشن باز می‌شود
    RemoteMessage? initialMessage = await _firebaseMessaging
        .getInitialMessage();
    if (initialMessage != null) {
      _handleNavigation(initialMessage, navigatorKey);
    }

    // سناریو ۲: برنامه در پس‌زمینه (Background) است و کاربر روی نوتیفیکیشن کلیک می‌کند
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNavigation(message, navigatorKey);
    });
  }

  // منطق هدایت کاربر
  void _handleNavigation(
    RemoteMessage message,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    // اگر در دیتای پیام، کلید screen برابر با add_item بود
    // یا اگر پی‌لود خاصی داشت
    if (message.data['screen'] == 'add_item' ||
        message.data['route'] == '/add_item') {
      debugPrint("Navigating to Add Item Screen...");
      // هدایت به صفحه افزودن لغت
      navigatorKey.currentState?.pushNamed('/add_item');
    }
  }
}
