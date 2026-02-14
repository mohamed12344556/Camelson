// to get release version
// flutter build apk --release --flavor development -t lib/main_development.dart
import 'dart:developer';

import 'package:camelson/core/api/google_sign_in_service.dart';
import 'package:camelson/core/notifications/background_handler.dart';
import 'package:camelson/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'core/cache/onboarding_manager.dart';
import 'core/constants/key_strings.dart';
import 'core/core.dart';
import 'core/notifications/notification_service.dart';
import 'core/services/deep_linking_service.dart';
import 'core/utils/bloc_setup.dart';
import 'camelson_app.dart';
import 'features/community/data/models/community_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupGetIt();

  // Initialize BLoC system
  await initBloc();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hydrated Bloc
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  await DeepLinkingService().initialize();
  log('✅ Deep Linking Service initialized');

  // Initialize AppState first
  await AppState.initialize();

  // Initialize Community current user from token (if logged in)
  await CommunityConstants.initializeCurrentUser();
  log(
    'Main - Current community user initialized: ${CommunityConstants.currentUser.name}',
  );

  await GoogleSignInService.debugStorageState();
  // Initialize Notifications
  // FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
  // FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
  await NotificationService().initialize();
  await NotificationService().requestPermission();

  // Check states after initialization with auto-refresh support
  final apiService = sl<ApiService>();
  final bool hasValidSession = await AppState.hasValidSession(
    apiService: apiService,
  );
  final bool hasSeenOnboarding = await OnboardingManager.hasSeenOnboarding();

  await ScreenUtil.ensureScreenSize();

  // Debug logging
  log('Main - AppState.isLoggedIn: ${AppState.isLoggedIn}');
  log('Main - AppState.isLoggedInAsGoogle: ${AppState.isLoggedInAsGoogle}');
  log('Main - hasSeenOnboarding: $hasSeenOnboarding');
  log('Main - hasValidSession: $hasValidSession');

  runApp(
    CamelsonApp(
      appRouter: Routers(),
      hasValidSession: hasValidSession,
      hasSeenOnboarding: hasSeenOnboarding,
    ),
  );
}


//Example of how to run in release mode
// flutter build apk --release --flavor development -t lib/main_development.dart

//Example of how to execute notification
// https://medium.com/@ali.mohamed.hgr/firebase-push-notifications-in-flutter-the-complete-2024-guide-c1cb0684bf8a?postPublishedType=repub
// State 1: Foreground (App Open)
// FirebaseMessaging.onMessage.listen((message) {
//   NotificationHelpers.showNotification(message, plugin);
// });
// System doesn’t show notification → You show it manually

// State 2: Background (App Minimized)
// FirebaseMessaging.onMessageOpenedApp.listen((message) {
//   _handleMessage(message);
// });
// System shows notification → You handle tap

// State 3: Terminated (App Closed)
// @pragma('vm:entry-point')
// Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   await showNotification(message);
// }
// Runs in separate isolate → Shows notification → Waits for tap


// Token Best Practices
// 1. Store Tokens Securely

// // Store in secure storage
// await secureStorage.write(key: 'fcm_token', value: token);
// 2. Delete Token on Logout

// Future<void> onUserLogout() async {
//   final token = await NotificationService.getToken();
  
//   // Remove from backend
//   await http.post(
//     Uri.parse('https://your-api.com/remove-token'),
//     body: jsonEncode({'fcm_token': token}),
//   );
  
//   // Delete locally
//   await FirebaseMessaging.instance.deleteToken();
// }
// 3. Handle Null Tokens

// final token = await NotificationService.getToken();
// if (token == null) {
//   print('Token not available. Possible reasons:');
//   print('1. No internet connection');
//   print('2. Firebase not initialized');
//   print('3. Permissions not granted');
//   return;
// }
// Future<void> _getAndPrintToken() async {
//   final token = await NotificationService.getToken();
//   print('═══════════════════════════════════');
//   print('FCM TOKEN:');
//   print(token);
//   print('═══════════════════════════════════');
// }
// Handle Token Refresh
// FCM tokens can change. Listen for updates:

// class NotificationService {
//   // ... existing code ...
//   Future<void> setupTokenRefresh(Function(String) onTokenReceived) async {
//     FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
//       debugPrint('Token refreshed: $newToken');
//       onTokenReceived(newToken);
//     });
//   }
// }
// Use it:

// await NotificationService().setupTokenRefresh((newToken) async {
//   await http.post(
//     Uri.parse('https://your-api.com/update-token'),
//     body: jsonEncode({'fcm_token': newToken}),
//   );
// });
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'core/notifications/background_handler.dart';
// import 'core/notifications/notification_service.dart';
// import 'firebase_options.dart';
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
//   await NotificationService().initialize();
//   runApp(const MyApp());
// }
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'FCM Demo',
//       home: const HomeScreen(),
//     );
//   }
// }
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
// class _HomeScreenState extends State<HomeScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _setup();
//   }
//   Future<void> _setup() async {
//     await NotificationService().requestPermission();
//     NotificationService().onTap.listen((data) {
//       debugPrint('Notification tapped: $data');
      
//       if (data['type'] == 'order') {
//         Navigator.pushNamed(context, '/orders');
//       }
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Home')),
//       body: const Center(child: Text('App Ready')),
//     );
//   }
// }