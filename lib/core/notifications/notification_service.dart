import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../api/auth_interceptor.dart';
import 'background_handler.dart';
import 'notification_helpers.dart';
import 'rich_notification.dart';
import 'rich_notification_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();
  static final _messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin? _plugin;
  bool _initialized = false;
  final _tapController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onTap => _tapController.stream;
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      _plugin = FlutterLocalNotificationsPlugin();
      await _plugin!.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: _onTap,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );
      if (Platform.isAndroid) {
        await _createChannel();
      }
      await _setupListeners();
      _initialized = true;
    } catch (e) {
      debugPrint('Init error: $e');
      rethrow;
    }
  }

  Future<void> _createChannel() async {
    final channel = NotificationHelpers.createChannel();
    await _plugin!
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> _setupListeners() async {
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _handleMessage(initial);
    FirebaseMessaging.onMessage.listen(_showForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  Future<void> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      final token = await _messaging.getToken();
      log('FCM Token: $token');
    }
  }

  //! default
  // Future<void> _showForeground(RemoteMessage message) async {
  //   // Log notification data when received
  //   log('=== Notification Received (Foreground) ===');
  //   log('Title: ${message.notification?.title}');
  //   log('Body: ${message.notification?.body}');
  //   log('Data: ${message.data}');
  //   log('MessageId: ${message.messageId}');
  //   log('==========================================');

  //   final context = NavigationService.navigatorKey.currentContext;
  //   if (context != null) {
  //     final title = NotificationHelpers.getTitle(message);
  //     final body = NotificationHelpers.getBody(message);

  //     ToastService.showNotification(
  //       context: context,
  //       title: title,
  //       message: body,
  //       duration: const Duration(seconds: 5),
  //       onTap: () {
  //         log('=== Notification Tapped (Foreground) ===');
  //         log('Data: ${message.data}');
  //         log('=========================================');
  //         if (message.data.isNotEmpty) {
  //           _tapController.add(message.data);
  //         }
  //       },
  //     );
  //   }
  // }
  //! For Glassmorphism Notification
  // Future<void> _showForeground(RemoteMessage message) async {
  //   log('=== Notification Received (Foreground) ===');
  //   log('Title: ${message.notification?.title}');
  //   log('Body: ${message.notification?.body}');
  //   log('Data: ${message.data}');

  //   final context = NavigationService.navigatorKey.currentContext;
  //   if (context != null) {
  //     final title = NotificationHelpers.getTitle(message);
  //     final body = NotificationHelpers.getBody(message);

  //     // حدد النوع من الـ data
  //     NotificationType type = NotificationType.chatMessage;
  //     String? senderName;

  //     if (message.data.containsKey('type')) {
  //       switch (message.data['type']) {
  //         case 'new_lesson':
  //           type = NotificationType.newLesson;
  //           break;
  //         case 'exam':
  //           type = NotificationType.exam;
  //           break;
  //         case 'lesson_reminder':
  //           type = NotificationType.lessonReminder;
  //           break;
  //         case 'chat_message':
  //           type = NotificationType.chatMessage;
  //           senderName = message.data['sender_name'];
  //           break;
  //         case 'community_post':
  //           type = NotificationType.communityPost;
  //           senderName = message.data['user_name'];
  //           break;
  //         case 'competition':
  //           type = NotificationType.competition;
  //           break;
  //         case 'achievement':
  //           type = NotificationType.achievement;
  //           break;
  //         case 'live_stream':
  //           type = NotificationType.liveStream;
  //           break;
  //         case 'homework':
  //           type = NotificationType.homework;
  //           break;
  //         case 'grade':
  //           type = NotificationType.grade;
  //           break;
  //         default:
  //           type = NotificationType.announcement;
  //       }
  //     }

  //     NotificationOverlayService.show(
  //       context: context,
  //       title: title,
  //       message: body,
  //       type: type,
  //       senderName: senderName,
  //       duration: const Duration(seconds: 5),
  //       onTap: () {
  //         log('=== Notification Tapped ===');
  //         if (message.data.isNotEmpty) {
  //           _tapController.add(message.data);
  //         }
  //       },
  //     );
  //   }
  // }
  //! for Rich Notification
  Future<void> _showForeground(RemoteMessage message) async {
    log('=== Notification Received (Foreground) ===');
    log('Title: ${message.notification?.title}');
    log('Body: ${message.notification?.body}');
    log('Data: ${message.data}');

    final context = NavigationService.navigatorKey.currentContext;
    if (context != null) {
      final title = NotificationHelpers.getTitle(message);
      final body = NotificationHelpers.getBody(message);

      // حدد النوع من الـ data
      NotificationType type = NotificationType.liveStream;
      String? senderName = message.data['sender_name'];
      String? avatarUrl = message.data['avatar_url'];
      String? badge = message.data['badge'];
      String? timeAgo = message.data['time_ago'];
      String? path = message.data['path'];

      if (message.data.containsKey('type')) {
        switch (message.data['type']) {
          case 'new_lesson':
            type = NotificationType.newLesson;
            break;
          case 'exam':
            type = NotificationType.exam;
            break;
          case 'lesson_reminder':
            type = NotificationType.lessonReminder;
            break;
          case 'chat_message':
            type = NotificationType.chatMessage;
            break;
          case 'community_post':
            type = NotificationType.communityPost;
            break;
          case 'competition':
            type = NotificationType.competition;
            break;
          case 'achievement':
            type = NotificationType.achievement;
            break;
          case 'live_stream':
            type = NotificationType.liveStream;
            break;
          case 'homework':
            type = NotificationType.homework;
            break;
          case 'grade':
            type = NotificationType.grade;
            break;
          default:
            type = NotificationType.announcement;
        }
      }

      RichNotificationService.show(
        context: context,
        title: title,
        message: body,
        type: type,
        senderName: senderName,
        avatarUrl: avatarUrl,
        badge: badge,
        timeAgo: timeAgo,
        onTap: () {
          log('=== Notification Tapped ===');
          if (message.data.isNotEmpty) {
            _tapController.add(message.data);
          }
          _navigateToPath(path, message.data);
        },
        onAction: () {
          log('=== Action Button Pressed ===');
          if (message.data.isNotEmpty) {
            _tapController.add(message.data);
          }
          _navigateToPath(path, message.data);
        },
      );
    }
  }

  void _handleMessage(RemoteMessage message) {
    log('=== Notification Opened (Background/Terminated) ===');
    log('Title: ${message.notification?.title}');
    log('Body: ${message.notification?.body}');
    log('Data: ${message.data}');
    log('MessageId: ${message.messageId}');
    log('===================================================');
    if (message.data.isNotEmpty) {
      _tapController.add(message.data);
    }
    final path = message.data['path'] as String?;
    _navigateToPath(path, message.data);
  }

  void _navigateToPath(String? path, Map<String, dynamic> data) {
    if (path == null || path.isEmpty) return;

    final context = NavigationService.navigatorKey.currentContext;
    if (context == null) return;

    log('=== Navigating to path: $path ===');

    // تحقق إذا كان الـ path يحتاج arguments
    final arguments = data['arguments'];

    if (arguments != null) {
      Navigator.of(context).pushNamed(path, arguments: arguments);
    } else {
      Navigator.of(context).pushNamed(path);
    }
  }

  void _onTap(NotificationResponse response) {
    log('=== Local Notification Tapped ===');
    log('Payload: ${response.payload}');
    log('=================================');
    if (response.payload != null && response.payload!.isNotEmpty) {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      log('Parsed Data: $data');
      _tapController.add(data);
    }
  }

  static Future<String?> getToken() => _messaging.getToken();
  static Future<void> subscribeToTopic(String topic) =>
      _messaging.subscribeToTopic(topic);
  static Future<void> unsubscribeFromTopic(String topic) =>
      _messaging.unsubscribeFromTopic(topic);
  void dispose() {
    _tapController.close();
  }
}
