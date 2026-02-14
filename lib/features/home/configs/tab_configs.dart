import 'package:simplify/features/bot/ai_chat_view.dart';
import 'package:simplify/features/community/ui/logic/chat_bloc/chat_bloc.dart';
import 'package:simplify/features/courses/ui/views/subject_roadmap_view.dart'
    hide AppRoutes;
import 'package:simplify/features/courses/ui/views/teacher_profile_view.dart';
import 'package:simplify/features/home/ui/views/streaming_now_view.dart';
import 'package:simplify/features/home/ui/views/top_mentors_view.dart';
import 'package:simplify/features/profile/ui/views/dark_mode_settings_view.dart';
import 'package:simplify/features/profile/ui/views/invite_friends_view.dart';
import 'package:simplify/features/profile/ui/views/language_settings_view.dart';
import 'package:simplify/features/profile/ui/views/payment_view.dart';
import 'package:simplify/features/profile/ui/views/terms_&_conditions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../community/ui/logic/community_bloc/community_bloc.dart';
import '../../community/ui/views/chat_room_view.dart';
import '../../community/ui/views/community_view.dart';
import '../../courses/ui/views/course_contents_view.dart';
import '../../courses/ui/views/course_details_view.dart';
import '../../courses/ui/views/courses_view.dart';
import '../../courses/ui/views/libraries_view.dart';
import '../../courses/ui/views/teacher_course_content.dart';
import '../../home/logic/home_cubit.dart';
import '../../notes/ui/logic/notes_cubit.dart';
import '../../notes/ui/views/add_note_view.dart';
import '../../notes/ui/views/empty_notes_view.dart';
import '../../notes/ui/views/notes_wrapper_view.dart';
import '../../notification/ui/logic/notification_cubit.dart';
import '../../notification/ui/views/notifications_view.dart';
import '../../profile/ui/logic/plans/plans_cubit.dart';
import '../../profile/ui/logic/profle/profile_cubit.dart';
import '../../profile/ui/views/edit_profile_view.dart';
import '../../profile/ui/views/help_center_view.dart';
import '../../profile/ui/views/notification_settings_view.dart';
import '../../profile/ui/views/plans_view.dart';
import '../../profile/ui/views/profile_settings_view.dart';
import '../../profile/ui/views/security_settings_view.dart';
import '../../rank/ui/views/rank_view.dart';
import '../data/models/tab_config.dart';
import '../ui/views/categories_view.dart';
import '../ui/views/home_view.dart';

/// Tab configurations for the bottom navigation bar
class TabConfigs {
  static List<TabConfig> getTabConfigs() {
    return [
      // Home Tab
      TabConfig(
        iconPath: 'assets/icons/home_icons.svg',
        label: 'Home',
        view: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: sl<HomeCubit>()),
            BlocProvider.value(value: sl<ProfileCubit>()..loadProfile()),
          ],
          child: const HomeView(),
        ),
        routes: {
          AppRoutes.categoriesView: () => const CategoriesView(),
          AppRoutes.coursesView: () => const CoursesView(),
          AppRoutes.librariesView: () => const LibrariesView(),
          AppRoutes.courseDetailsView: () => const CourseDetailsView(),
          AppRoutes.courseContentsView: () => const CourseContentsView(),
          AppRoutes.subjectRoadmapView: () => const SubjectRoadmapView(),

          // Notifications مع Cubit منفصل
          AppRoutes.notificationsView: () => BlocProvider(
            create: (context) => sl<NotificationCubit>()..loadNotifications(),
            child: const NotificationsView(),
          ),

          // Notes مع Cubit منفصل لكل صفحة
          AppRoutes.editNote: () => BlocProvider(
            create: (context) => sl<NotesCubit>(),
            child: const AddNoteView(isEditing: true),
          ),

          AppRoutes.emptyNotes: () => BlocProvider(
            create: (context) => sl<NotesCubit>(),
            child: const EmptyNotesView(),
          ),

          AppRoutes.addNote: () => BlocProvider(
            create: (context) => sl<NotesCubit>(),
            child: const AddNoteView(),
          ),

          AppRoutes.allNotes: () => BlocProvider(
            create: (context) => sl<NotesCubit>()..loadNotes(),
            child: const NotesWrapperView(),
          ),

          AppRoutes.teacherProfile: () => const TeacherProfileView(),
          AppRoutes.teacherCourseContent: () =>
              const TeacherCourseContentView(),

          AppRoutes.streamingNowView: () => const StreamingNowView(),
          AppRoutes.topMentorsView: () => const TopMentorsView(),
          AppRoutes.aiChatView: () => const AIChatView(),
        },
      ),

      // Rank Tab
      TabConfig(
        iconPath: 'assets/icons/rank_icons.svg',
        label: 'Rank',
        view: const RankView(),
        routes: {
          // Add rank-specific routes here if needed
        },
      ),

      // Community Tab - مع تحسين إدارة Chat Bloc
      TabConfig(
        iconPath: 'assets/icons/community_icons.svg',
        label: 'Community',
        view: BlocProvider(
          create: (context) => sl<CommunityBloc>(),
          child: const CommunityView(),
        ),
        routes: {
          AppRoutes.chatRoomView: () => BlocProvider(
            create: (context) => sl<ChatBloc>(),
            child: const ChatRoomView(),
          ),
        },
      ),

      // Profile Tab
      TabConfig(
        iconPath: 'assets/icons/profile_icons.svg',
        label: 'Profile',
        view: BlocProvider(
          create: (context) => sl<ProfileCubit>()..loadProfile(),
          child: const ProfileSettingsView(),
        ),
        isProfile: true,
        routes: {
          AppRoutes.editProfileView: () => const EditProfileView(),
          AppRoutes.darkModeSettingsView: () => const DarkModeSettingsView(),
          AppRoutes.languageSettingsView: () => const LanguageSettingsView(),
          AppRoutes.notificationSettingsView: () =>
              const NotificationSettingsView(),
          AppRoutes.helpSettingsView: () => const HelpCenterView(),
          AppRoutes.inviteSettingsView: () => const InviteFriendsView(),
          AppRoutes.paymentView: () => const PaymentView(),
          AppRoutes.securitySettingsView: () => const SecuritySettingsView(),
          AppRoutes.termsSettingsView: () => const TermsAndConditionsView(),
          AppRoutes.plansSettingsView: () => BlocProvider(
            create: (context) => sl<PlansCubit>()..loadStudentPlans(),
            child: const PlansView(),
          ),
        },
      ),
    ];
  }

  /// Get specific tab config by index
  static TabConfig getTabConfig(int index) {
    final configs = getTabConfigs();
    if (index >= 0 && index < configs.length) {
      return configs[index];
    }
    throw ArgumentError('Invalid tab index: $index');
  }

  /// Get the number of tabs
  static int get tabCount => getTabConfigs().length;
}
