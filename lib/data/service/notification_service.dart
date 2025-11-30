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

    // 1. تنظیمات Timezone
    await _configureLocalTimeZone();

    // 2. تنظیمات اندروید
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. تنظیمات iOS و macOS
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: false,
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
        if (response.payload != null) {
          print('Notification payload: ${response.payload}');
          // اینجا می‌توانید نویگیشن را هندل کنید
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
      tz.setLocalLocation(tz.getLocation('Europe/Berlin'));
    }
  }

  /// درخواست مجوزها
  /// (اصلاح شده برای گوگل پلی: درخواست Exact Alarm حذف شد)
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

      // فقط درخواست مجوز نوتیفیکیشن برای اندروید 13+ (این مجاز است)
      final bool? grantedNotification = await androidImplementation
          ?.requestNotificationsPermission();
      return grantedNotification ?? false;
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
    // ایجاد کانال نوتیفیکیشن
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
        // ------------------------------------------------------------------
        // تغییر حیاتی برای گوگل پلی:
        // استفاده از حالت غیردقیق. این حالت نیاز به مجوز SCHEDULE_EXACT_ALARM ندارد
        // و باعث می‌شود اپلیکیشن شما تایید شود.
        // ------------------------------------------------------------------
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,

        matchDateTimeComponents: DateTimeComponents.time,
      );
      print("Notification Scheduled (Inexact) for $hour:$minute");
    } catch (e) {
      print("Error scheduling notification: $e");
    }
  }

  /// نمایش اعلان فوری
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // ایجاد کانال برای اعلان فوری (اضافه شده برای سازگاری)
    const AndroidNotificationChannel generalChannel =
        AndroidNotificationChannel(
          'general_channel_id',
          'General Notifications',
          description: 'Notifications for general updates',
          importance: Importance.max,
        );
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await androidPlugin?.createNotificationChannel(generalChannel);

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'general_channel_id',
          'General Notifications',
          channelDescription: 'Notifications for general updates',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(),
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
