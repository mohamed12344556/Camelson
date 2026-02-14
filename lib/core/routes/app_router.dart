import 'package:simplify/features/community/ui/logic/chat_bloc/chat_bloc.dart';
import 'package:simplify/features/community/ui/logic/community_bloc/community_bloc.dart';
import 'package:simplify/features/courses/ui/views/subject_roadmap_view.dart'
    hide AppRoutes;
import 'package:simplify/features/profile/ui/views/edit_profile_view.dart';
import 'package:simplify/features/profile/ui/views/invite_friends_view.dart';
import 'package:simplify/features/profile/ui/views/payment_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/ui/logic/auth_cubit.dart';
import '../../features/bot/ai_chat_view.dart';
import '../../features/auth/ui/views/forget_password_view.dart';
import '../../features/auth/ui/views/login_view.dart';
import '../../features/auth/ui/views/otp_authenticate_view.dart';
import '../../features/auth/ui/views/reset_password_view.dart';
import '../../features/auth/ui/views/sign_up_view.dart';
import '../../features/auth/ui/views/signup_signin_view.dart';
import '../../features/community/data/models/room.dart';
import '../../features/community/ui/views/chat_room_view.dart';
import '../../features/community/ui/views/community_view.dart';
import '../../features/courses/ui/views/course_contents_view.dart';
import '../../features/courses/ui/views/course_details_view.dart';
import '../../features/courses/ui/views/courses_view.dart';
import '../../features/courses/ui/views/libraries_view.dart';
import '../../features/courses/ui/views/teacher_course_content.dart';
import '../../features/courses/ui/views/teacher_profile_view.dart';
import '../../features/home/logic/home_cubit.dart';
import '../../features/home/ui/views/categories_view.dart';
import '../../features/home/ui/views/home_view.dart';
import '../../features/home/ui/views/host_view.dart';
import '../../features/home/ui/views/streaming_now_view.dart';
import '../../features/home/ui/views/top_mentors_view.dart';
import '../../features/notes/ui/logic/notes_cubit.dart';
import '../../features/notes/ui/views/add_note_view.dart';
import '../../features/notes/ui/views/empty_notes_view.dart';
import '../../features/notes/ui/views/notes_wrapper_view.dart';
import '../../features/notification/ui/logic/notification_cubit.dart';
import '../../features/notification/ui/views/notifications_view.dart';
import '../../features/onboarding/ui/views/onboarding_view.dart';
import '../../features/profile/ui/logic/profle/profile_cubit.dart';
import '../../features/profile/ui/views/dark_mode_settings_view.dart';
import '../../features/profile/ui/views/help_center_view.dart';
import '../../features/profile/ui/views/language_settings_view.dart';
import '../../features/profile/ui/views/profile_settings_view.dart';
import '../../features/profile/ui/views/security_settings_view.dart';
import '../../features/profile/ui/widgets/payment_webview_screen.dart';
import '../../features/rank/ui/views/rank_view.dart';
import '../core.dart';

class Routers {
  Route? generateRoute(RouteSettings settings) {
    final arguments = settings.arguments;

    switch (settings.name) {
      case AppRoutes.onboardingView:
        return MaterialPageRoute(builder: (_) => const OnboardingView());

      // case AppRoutes.sigUpSigninView:
      //   return MaterialPageRoute(builder: (_) => const SigUpSigninView());

      case AppRoutes.loginView:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: sl<AuthCubit>(),
            child: const LogInView(),
          ),
        );

      case AppRoutes.registerView:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: sl<AuthCubit>(),
            child: const SignUpView(),
          ),
        );

      case AppRoutes.otpAuthenticateView:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: sl<AuthCubit>(),
            child: OTPAuthenticateView(
              arguments: arguments! as Map<String, dynamic>,
            ),
          ),
        );

      case AppRoutes.forgetPasswordView:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: sl<AuthCubit>(),
            child: const ForgotPasswordView(),
          ),
        );

      case AppRoutes.resetPasswordView:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: sl<AuthCubit>(),
            child: const ResetPasswordView(),
          ),
        );

      case AppRoutes.hostView:
        return MaterialPageRoute(builder: (_) => const HostView());

      case AppRoutes.homeView:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: sl<HomeCubit>()),
              BlocProvider.value(value: sl<ProfileCubit>()),
            ],
            child: HomeView(),
          ),
        );

      case AppRoutes.notificationsView:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: sl<NotificationCubit>(),
            child: const NotificationsView(),
          ),
        );

      case AppRoutes.categoriesView:
        return MaterialPageRoute(builder: (_) => CategoriesView());

      case AppRoutes.aiChatView:
        return MaterialPageRoute(builder: (_) => const AIChatView());

      case AppRoutes.streamingNowView:
        return MaterialPageRoute(builder: (_) => const StreamingNowView());

      case AppRoutes.topMentorsView:
        return MaterialPageRoute(builder: (_) => const TopMentorsView());

      case AppRoutes.coursesView:
        return MaterialPageRoute(builder: (_) => const CoursesView());

      case AppRoutes.librariesView:
        return MaterialPageRoute(builder: (_) => const LibrariesView());

      case AppRoutes.courseDetailsView:
        return MaterialPageRoute(builder: (_) => CourseDetailsView());

      case AppRoutes.courseContentsView:
        return MaterialPageRoute(builder: (_) => CourseContentsView());

      case AppRoutes.subjectRoadmapView:
        return MaterialPageRoute(builder: (_) => const SubjectRoadmapView());

      case AppRoutes.teacherProfile:
        return MaterialPageRoute(builder: (_) => const TeacherProfileView());

      case AppRoutes.teacherCourseContent:
        return MaterialPageRoute(
          builder: (_) => const TeacherCourseContentView(),
        );

      case AppRoutes.rankView:
        return MaterialPageRoute(builder: (_) => const RankView());

      case AppRoutes.communityView:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: sl<CommunityBloc>(),
            child: const CommunityView(),
          ),
        );

      case AppRoutes.chatRoomView:
        final room = arguments as Room?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<ChatBloc>(),
            child: ChatRoomView(room: room),
          ),
        );

      case AppRoutes.profileSettingsView:
        return MaterialPageRoute(builder: (_) => const ProfileSettingsView());

      case AppRoutes.editProfileView:
        return MaterialPageRoute(builder: (_) => const EditProfileView());

      case AppRoutes.darkModeSettingsView:
        return MaterialPageRoute(builder: (_) => const DarkModeSettingsView());

      case AppRoutes.languageSettingsView:
        return MaterialPageRoute(builder: (_) => const LanguageSettingsView());

      case AppRoutes.helpSettingsView:
        return MaterialPageRoute(builder: (_) => const HelpCenterView());

      case AppRoutes.inviteSettingsView:
        return MaterialPageRoute(builder: (_) => const InviteFriendsView());

      case AppRoutes.paymentView:
        return MaterialPageRoute(builder: (_) => const PaymentView());

      case AppRoutes.paymentWebView:
        final args = arguments as Map<String, dynamic>?;
        final paymentUrl = args?['paymentUrl'] as String?;
        final upgradeRequestId = args?['upgradeRequestId'] as String?;

        if (paymentUrl == null || upgradeRequestId == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Invalid payment data')),
            ),
          );
        }

        return MaterialPageRoute(
          builder: (_) => PaymentWebViewScreen(
            paymentUrl: paymentUrl,
            upgradeRequestId: upgradeRequestId,
          ),
        );

      case AppRoutes.securitySettingsView:
        return MaterialPageRoute(builder: (_) => const SecuritySettingsView());

      case AppRoutes.termsSettingsView:
        return MaterialPageRoute(
          builder: (_) => const SecuritySettingsView(),
        ); // You might want to create a TermsAndConditionsView

      case AppRoutes.emptyNotes:
        return MaterialPageRoute(builder: (_) => const EmptyNotesView());

      case AppRoutes.allNotes:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<NotesCubit>()..loadNotes(),
            child: const NotesWrapperView(),
          ),
        );

      case AppRoutes.addNote:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<NotesCubit>(),
            child: const AddNoteView(),
          ),
        );

      case AppRoutes.editNote:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<NotesCubit>(),
            child: AddNoteView(
              noteId: args?['noteId'] as String?,
              isEditing: true,
            ),
          ),
        );

      default:
        return null;
    }
  }
}
