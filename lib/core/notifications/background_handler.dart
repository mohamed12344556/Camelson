import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../firebase_options.dart';
import 'notification_helpers.dart';

/// Handler للرسائل اللي جاية والتطبيق مقفول (background)
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    await NotificationHelpers.showNotification(message, plugin);
  } catch (e) {
    debugPrint('Background error: $e');
  }
}

/// Handler للضغط على notification والتطبيق مقفول
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint(
    'Notification tapped in background: ${notificationResponse.payload}',
  );
  // هنا ممكن تضيف logic للتعامل مع الضغط
}
