import 'package:camelson/features/bot/ai_chat_view.dart';
import 'package:camelson/features/community/ui/logic/chat_bloc/chat_bloc.dart';
import 'package:camelson/features/courses/ui/views/subject_roadmap_view.dart'
    hide AppRoutes;
import 'package:camelson/features/courses/ui/views/teacher_profile_view.dart';
import 'package:camelson/features/home/ui/views/streaming_now_view.dart';
import 'package:camelson/features/home/ui/views/top_mentors_view.dart';
import 'package:camelson/features/profile/ui/views/dark_mode_settings_view.dart';
import 'package:camelson/features/profile/ui/views/invite_friends_view.dart';
import 'package:camelson/features/profile/ui/views/language_settings_view.dart';
import 'package:camelson/features/profile/ui/views/payment_view.dart';
import 'package:camelson/features/profile/ui/views/terms_&_conditions.dart';
import 'package:camelson/features/schedule/ui/logic/main_plan_cubit.dart';
import 'package:camelson/features/schedule/ui/views/study_preferences_setup_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../community/ui/logic/community_bloc/community_bloc.dart';
import '../../community/ui/views/chat_room_view.dart';
import '../../community/ui/views/community_view.dart';
import '../../courses/ui/views/course_contents_view.dart';
import '../../courses/ui/views/course_details_view.dart';
import '../../courses/ui/views/courses_view.dart';
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
import '../../schedule/ui/logic/lessons_cubit.dart';
import '../../schedule/ui/logic/plan_cubit.dart';
import '../../schedule/ui/logic/study_preferences_cubit.dart';
import '../../schedule/ui/views/lessons_view.dart';
import '../../schedule/ui/views/my_plan_view.dart';
import '../../schedule/ui/views/plan_screen.dart';
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

      // Plan Tab - مع تحسينات في إدارة الـ Cubits
      TabConfig(
        iconPath: 'assets/icons/plan_icons.svg',
        label: 'Plan',
        view: MultiBlocProvider(
          providers: [
            BlocProvider<MainPlanCubit>(
              create: (context) => sl<MainPlanCubit>(),
            ),
            BlocProvider<PlanCubit>(create: (context) => sl<PlanCubit>()),
            BlocProvider<LessonsCubit>(create: (context) => sl<LessonsCubit>()),
            BlocProvider<StudyPreferencesCubit>(
              create: (context) =>
                  sl<StudyPreferencesCubit>()..checkSetupStatus(),
            ),
          ],
          child: const PlanScreen(),
        ),
        routes: {
          AppRoutes.myPlanView: () => BlocProvider(
            create: (context) => sl<PlanCubit>()..loadEvents(),
            child: const MyPlanView(),
          ),
          AppRoutes.lessonsView: () => BlocProvider(
            create: (context) => sl<LessonsCubit>()..loadEvents(),
            child: const LessonsView(),
          ),
          // Remove the duplicate StudyPreferencesCubit creation in routes
          // The cubit will be created by the StudyPreferencesSetupScreen itself
          AppRoutes.studyPreferencesSetup: () =>
              const StudyPreferencesSetupScreen(),
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
