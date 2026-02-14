import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/auth/data/repo/auth_repository.dart';
import '../../features/profile/data/repo/plans_repository.dart';
import '../../features/profile/ui/logic/plans/plans_cubit.dart';
import '../api/api_file_service.dart';
import '../../features/auth/ui/logic/auth_cubit.dart';
import '../../features/community/data/repos/chat_repo.dart';
import '../../features/community/data/services/question_service.dart';
import '../../features/community/ui/logic/chat_bloc/chat_bloc.dart';
import '../../features/community/ui/logic/community_bloc/community_bloc.dart';
import '../../features/home/logic/home_cubit.dart';
import '../../features/profile/ui/logic/profle/profile_cubit.dart';
import '../../features/notes/data/models/note_model.dart';
import '../../features/notes/data/repos/notes_repo.dart';
import '../../features/notes/ui/logic/notes_cubit.dart';
import '../../features/notification/ui/logic/notification_cubit.dart';
import '../../features/community/data/models/pending_message.dart';
import '../../features/community/data/services/message_queue_manager.dart';
import '../core.dart';

final sl = GetIt.instance;

Future<void> setupGetIt() async {
  // Initialize Hive FIRST - before any other initialization
  await Hive.initFlutter();

  //for ios
  if (Platform.isIOS) {
    final dir = await getApplicationDocumentsDirectory();
    final hiveDir = Directory(dir.path);
    if (await hiveDir.exists()) {
      try {
        await Process.run('xattr', [
          '-w',
          'com.apple.MobileBackup',
          '1',
          hiveDir.path,
        ]);
      } catch (e) {}
    }
  }

  // Core
  Dio dio = DioFactory.getDio();
  sl.registerLazySingleton<ApiService>(() => ApiService(dio));
  sl.registerLazySingleton<ApiFileService>(() => ApiFileService(dio));

  // Auth
  _initAuth();

  // Home
  _initHome();

  // Profile
  _initProfile();

  // Notification
  _initNotification();

  // Notes
  await _initNotes();

  // Chat - Initialize last due to dependencies
  await _initChat();

  // Community - Initialize after chat
  _initCommunity();

  // Subscription
  _initSubscription();
}

Future<void> _initChat() async {
  // Register Hive adapters
  Hive.registerAdapter(PendingMessageAdapter());

  // First register the async Hive boxes
  sl.registerLazySingletonAsync<Box<Map>>(
    () async => await Hive.openBox<Map>('chat_messages'),
    instanceName: 'chat_messages_box',
  );

  sl.registerLazySingletonAsync<Box<Map>>(
    () async => await Hive.openBox<Map>('chat_rooms'),
    instanceName: 'chat_rooms_box',
  );

  // Register pending messages queue box
  sl.registerLazySingletonAsync<Box<PendingMessage>>(
    () async => await Hive.openBox<PendingMessage>('pending_messages_queue'),
    instanceName: 'pending_messages_queue_box',
  );

  // Wait for the boxes to be ready before registering the repository
  await sl.isReady<Box<Map>>(instanceName: 'chat_messages_box');
  await sl.isReady<Box<Map>>(instanceName: 'chat_rooms_box');
  await sl.isReady<Box<PendingMessage>>(
    instanceName: 'pending_messages_queue_box',
  );

  // ✅ Register Repository as LazySingleton (shared instance)
  sl.registerLazySingleton<ChatRepository>(() => ChatRepository());

  // Initialize the repository after registration
  await sl<ChatRepository>().init();

  // ✅ Register MessageQueueManager as LazySingleton
  sl.registerLazySingleton<MessageQueueManager>(
    () => MessageQueueManager(
      queueBox: sl.get<Box<PendingMessage>>(
        instanceName: 'pending_messages_queue_box',
      ),
      chatRepository: sl<ChatRepository>(),
    ),
  );

  // Initialize MessageQueueManager
  await sl<MessageQueueManager>().init();

  // ✅ Register BLoC as Factory (new instance for each chat room)
  sl.registerFactory<ChatBloc>(
    () => ChatBloc(
      repository: sl<ChatRepository>(),
      queueManager: sl<MessageQueueManager>(),
    ),
  );
}

void _initCommunity() {
  // ✅ Register QuestionService as LazySingleton (shared across the app)
  sl.registerLazySingleton<QuestionService>(() => QuestionService());

  // ✅ Register Community BLoC as LazySingleton (shared, keeps state)
  sl.registerLazySingleton<CommunityBloc>(
    () => CommunityBloc(
      repository: sl<ChatRepository>(),
      questionService: sl<QuestionService>(),
    ),
  );
}

Future<void> _initNotes() async {
  // Register adapter (Hive already initialized)
  Hive.registerAdapter(NoteAdapter());

  // Register Repository as Singleton
  sl.registerLazySingleton<NotesRepository>(() => NotesRepository());

  // Initialize Repository
  await sl<NotesRepository>().init();

  // Register Cubit
  sl.registerFactory<NotesCubit>(() => NotesCubit(sl<NotesRepository>()));
}

void _initAuth() {
  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepository(sl()));

  // Auth Cubit
  sl.registerLazySingleton<AuthCubit>(
    () => AuthCubit(sl<ApiService>(), sl<AuthRepository>()),
  );
}

void _initHome() {
  // Home Cubit
  sl.registerLazySingleton<HomeCubit>(
    () => HomeCubit(sl<ApiService>(), sl<AuthRepository>()),
  );
}

void _initProfile() {
  // Profile Cubit
  sl.registerFactory<ProfileCubit>(() => ProfileCubit(sl<ApiService>()));
}

void _initNotification() {
  // Notification Cubit
  sl.registerLazySingleton<NotificationCubit>(() => NotificationCubit());
}

void _initSubscription() {
  // Repository
  sl.registerLazySingleton(() => PlansRepository(sl()));

  // Cubit
  sl.registerFactory(() => PlansCubit(sl()));
}

///! 1. `registerSingleton`
/// - Creates the object immediately during registration (Eager Initialization).
/// - Only one instance is created and shared across the entire application.
/// - Use Case: When you need the object to be available as soon as the app starts.
/// - Example: AppConfig, SessionManager.

///! 2. `registerLazySingleton`
/// - Creates the object only when it is first requested (Lazy Initialization).
/// - Only one instance is created and shared across the entire application.
/// - Use Case: To optimize performance by delaying object creation until needed.
/// - Example: DatabaseService, ApiClient.

///! 3. `registerFactory`
/// - Creates a new object instance every time it is requested.
/// - Use Case: When you need a new instance for every operation or request.
/// - Example: FormValidator, HttpRequest, BLoCs that manage temporary state.

/// Comparison Table:
/// | Property            | `registerSingleton`   | `registerLazySingleton` | `registerFactory`       |
/// |---------------------|-----------------------|-------------------------|-------------------------|
/// | Creation Time       | Immediately           | On first request        | On every request        |
/// | Number of Instances | One                   | One                     | New instance every time |
/// | State Sharing       | Supported             | Supported               | Not supported           |
/// | Common Use Cases    | Settings, Sessions    | Heavy Services          | Temporary Objects       |
