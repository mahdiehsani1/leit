import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;

Future<bool> requestNotificationPermission(
  FlutterLocalNotificationsPlugin plugin,
) async {
  if (Platform.isAndroid) {
    final androidImpl = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final granted = await androidImpl?.requestNotificationsPermission();
    return granted ?? false;
  }

  if (Platform.isIOS) {
    final iosImpl = plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final res = await iosImpl?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    return res ?? false;
  }

  return false;
}
