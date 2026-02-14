import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_constants.dart';

class NotificationHelpers {
  NotificationHelpers._();
  static int generateId(RemoteMessage message) {
    if (message.messageId != null) {
      return message.messageId.hashCode.abs();
    }
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  static String? encodePayload(Map<String, dynamic> data) {
    if (data.isEmpty) return null;
    try {
      return jsonEncode(data);
    } catch (e) {
      return null;
    }
  }

  static NotificationDetails buildDetails() {
    const android = AndroidNotificationDetails(
      NotificationConstants.channelId,
      NotificationConstants.channelName,
      channelDescription: NotificationConstants.channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(
        NotificationConstants.androidSound,
      ),
      enableVibration: true,
      icon: NotificationConstants.androidIcon,
    );
    const iOS = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: NotificationConstants.iosSound,
    );
    return const NotificationDetails(android: android, iOS: iOS);
  }

  static String getTitle(RemoteMessage message) {
    final title = message.notification?.title ?? message.data['title'];
    return (title == null || title.isEmpty)
        ? NotificationConstants.defaultTitle
        : title.trim();
  }

  static String getBody(RemoteMessage message) {
    final body = message.notification?.body ?? message.data['body'];
    return (body == null || body.isEmpty)
        ? NotificationConstants.defaultBody
        : body.trim();
  }

  static Future<void> showNotification(
    RemoteMessage message,
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    await plugin.show(
      id: generateId(message),
      title: getTitle(message),
      body: getBody(message),
      notificationDetails: buildDetails(),
      payload: encodePayload(message.data),
    );
  }

  static AndroidNotificationChannel createChannel() {
    return const AndroidNotificationChannel(
      NotificationConstants.channelId,
      NotificationConstants.channelName,
      description: NotificationConstants.channelDescription,
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(
        NotificationConstants.androidSound,
      ),
    );
  }
}
