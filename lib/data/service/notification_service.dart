// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  // 1. الگوی Singleton برای دسترسی آسان
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // متغیر برای بررسی اینیشیالایز شدن
  bool _isInitialized = false;

  /// تابع راه‌اندازی اولیه (Init)
  Future<void> init() async {
    if (_isInitialized) return;

    // 1. تنظیمات Timezone (برای زمان‌بندی دقیق ضروری است)
    await _configureLocalTimeZone();

    // 2. تنظیمات اندروید
    // نکته: فایل 'ic_launcher' یا 'app_icon' باید در پوشه android/app/src/main/res/drawable موجود باشد
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. تنظیمات iOS و macOS (کلاس جدید Darwin جایگزین IOSInitializationSettings شده است)
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: false, // مجوزها را بعداً دستی می‌گیریم
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    // 4. تجمیع تنظیمات
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsDarwin,
        );

    // 5. نهایی‌سازی پلاگین
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // اینجا کدی بنویسید که وقتی کاربر روی نوتیفیکیشن کلیک کرد اجرا شود
        if (response.payload != null) {
          print('Notification payload: ${response.payload}');
          // مثلاً نویگیت کردن به صفحه خاص
        }
      },
    );

    _isInitialized = true;
  }

  /// تنظیم تایم‌زون محلی گوشی
  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // در صورت خطا، تایم‌زون پیش‌فرض را تنظیم کنید
      tz.setLocalLocation(tz.getLocation('Europe/Berlin'));
    }
  }

  /// درخواست مجوزها (با پشتیبانی کامل اندروید 13 و 14)
  Future<bool> requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final bool? result = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      // 1. درخواست مجوز نوتیفیکیشن (Android 13+)
      final bool? grantedNotification = await androidImplementation
          ?.requestNotificationsPermission();

      // 2. بررسی و درخواست مجوز آلارم دقیق (Android 12+)
      // این بخش برای اندروید 14 حیاتی است
      bool? grantedExactAlarm = await androidImplementation
          ?.canScheduleExactNotifications();

      if (grantedExactAlarm == false) {
        // اگر مجوز نداشت، درخواست می‌دهیم (ممکن است کاربر را به تنظیمات ببرد)
        grantedExactAlarm = await androidImplementation
            ?.requestExactAlarmsPermission();
      }

      return (grantedNotification ?? false) && (grantedExactAlarm ?? false);
    }
    return false;
  }

  /// زمان‌بندی اعلان روزانه
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    // ایجاد کانال نوتیفیکیشن برای اندروید (لازم برای نسخه‌های جدید)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'daily_reminder_channel',
      'Daily Reminders',
      description: 'Daily reminder notifications',
      importance: Importance.max,
    );
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await androidPlugin?.createNotificationChannel(channel);

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder_channel',
            'Daily Reminders',
            channelDescription: 'Daily reminder notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

        matchDateTimeComponents: DateTimeComponents.time,
      );
      print("Notification Scheduled for $hour:$minute");
    } catch (e) {
      print("Error scheduling notification: $e");
      // اگر خطای امنیتی داد، یعنی مجوز آلارم دقیق نداریم
    }
  }

  /// نمایش اعلان فوری
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'your_channel_id', // شناسه کانال (باید ثابت و یکتا باشد)
          'General Notifications', // نام کانال
          channelDescription: 'Notifications for general updates',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(), // تنظیمات پیش‌فرض iOS
    );
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// محاسبه زمان بعدی اجرا
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now) || scheduledDate.isAtSameMomentAs(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// لغو تمام اعلان‌ها
  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
