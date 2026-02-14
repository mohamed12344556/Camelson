import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'simplify_app.dart';
import 'core/api/google_sign_in_service.dart';
import 'core/cache/onboarding_manager.dart';
import 'core/constants/key_strings.dart';
import 'core/core.dart';
import 'core/notifications/background_handler.dart';
import 'core/notifications/notification_service.dart';
import 'core/utils/bloc_setup.dart';
import 'features/community/data/models/community_constants.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await setupGetIt();

  // Initialize BLoC system
  await initBloc();

  // Initialize Hydrated Bloc
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  // Initialize AppState first
  await AppState.initialize();

  // Initialize Community current user from token (if logged in)
  await CommunityConstants.initializeCurrentUser();
  log(
    'Main - Current community user initialized: ${CommunityConstants.currentUser.name}',
  );

  await GoogleSignInService.debugStorageState();

  // Check states after initialization with auto-refresh support
  final apiService = sl<ApiService>();
  final bool hasValidSession = await AppState.hasValidSession(
    apiService: apiService,
  );
  final bool hasSeenOnboarding = await OnboardingManager.hasSeenOnboarding();

  // Initialize Notifications - بعد Firebase
  // FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
  await NotificationService().initialize();
  await NotificationService().requestPermission();

  await ScreenUtil.ensureScreenSize();

  // Debug logging
  log('Main - AppState.isLoggedIn: ${AppState.isLoggedIn}');
  log('Main - AppState.isLoggedInAsGoogle: ${AppState.isLoggedInAsGoogle}');
  log('Main - hasSeenOnboarding: $hasSeenOnboarding');
  log('Main - hasValidSession: $hasValidSession');

  runApp(
    SimplifyApp(
      appRouter: Routers(),
      hasValidSession: hasValidSession,
      hasSeenOnboarding: hasSeenOnboarding,
    ),
  );
}
