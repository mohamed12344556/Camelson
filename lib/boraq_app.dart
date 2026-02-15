import 'dart:developer';

import 'package:boraq/core/languages/language_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toastification/toastification.dart';

import 'core/api/auth_interceptor.dart';
import 'core/core.dart';
import 'core/notifications/notification_service.dart';
import 'core/services/deep_linking_service.dart';
import 'core/themes/cubit/theme_cubit.dart';
import 'features/profile/ui/logic/plans/plans_cubit.dart';
import 'generated/l10n.dart';

class boraqApp extends StatefulWidget {
  final Routers appRouter;
  final bool hasValidSession;
  final bool hasSeenOnboarding;

  const boraqApp({
    super.key,
    required this.appRouter,
    required this.hasValidSession,
    required this.hasSeenOnboarding,
  });

  @override
  State<boraqApp> createState() => _boraqAppState();
}

class _boraqAppState extends State<boraqApp> {
  @override
  void initState() {
    super.initState();
    _setupNotificationListener();
    _setupDeepLinkListener();
  }

  void _setupDeepLinkListener() {
    DeepLinkingService().registerPaymentCallback((status, invoiceId) {
      _handlePaymentCallback(status, invoiceId);
    });
  }

  void _handlePaymentCallback(String status, String? invoiceId) {
    final context = NavigationService.navigatorKey.currentContext;
    if (context == null) return;

    final isArabic = context.isArabic;
    final isSuccess = status.contains('success');

    if (isSuccess && invoiceId != null) {
      context.read<PlansCubit>().checkUpgradeStatus(invoiceId);
      context.showSuccessSnackBar(
        isArabic ? 'تم الدفع بنجاح!' : 'Payment successful!',
      );
    }
  }

  void _setupNotificationListener() {
    NotificationService().onTap.listen((data) {
      log('=== Notification Navigation ===');
      log('Data received: $data');
      log('===============================');

      _handleNotificationNavigation(data);
    });
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final context = NavigationService.navigatorKey.currentContext;
    if (context == null) return;

    final type = data['type'] as String?;
    final id = data['id'] as String?;

    log('Navigation type: $type, id: $id');

    switch (type) {
      case 'course':
        Navigator.pushNamed(
          context,
          AppRoutes.courseDetailsView,
          arguments: id,
        );
        break;
      case 'notification':
        Navigator.pushNamed(context, AppRoutes.notificationsView);
        break;
      case 'community':
      case 'chat':
        Navigator.pushNamed(context, AppRoutes.communityView);
        break;
      case 'profile':
        Navigator.pushNamed(context, AppRoutes.profileSettingsView);
        break;
      default:
        log('Unknown notification type: $type');
        // Default: open notifications view
        Navigator.pushNamed(context, AppRoutes.notificationsView);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider(create: (context) => LanguageCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeState) {
          return BlocBuilder<LanguageCubit, Locale>(
            builder: (context, languageState) {
              return ToastificationWrapper(
                config: ToastificationConfig(
                  alignment: Alignment.topCenter,
                  itemWidth: 400,
                  marginBuilder: (context, alignment) {
                    return const EdgeInsets.only(top: 50, left: 16, right: 16);
                  },
                ),
                child: ScreenUtilInit(
                  designSize: const Size(430, 953),
                  minTextAdapt: true,
                  splitScreenMode: true,
                  child: MaterialApp(
                    navigatorKey: NavigationService.navigatorKey,
                    themeMode: themeState,
                    theme: AppTheme.light,
                    darkTheme: AppTheme.dark,
                    debugShowCheckedModeBanner: false,
                    locale: languageState,
                    localizationsDelegates: const [
                      S.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: Languages.all,
                    initialRoute: _getInitialRoute(),
                    onGenerateRoute: widget.appRouter.generateRoute,
                    builder: (context, child) {
                      final mediaQuery = MediaQuery.of(context);
                      final scale = mediaQuery.textScaler
                          .scale(1)
                          .clamp(1, 1.2)
                          .toDouble();
                      return MediaQuery(
                        data: mediaQuery.copyWith(
                          textScaler: TextScaler.linear(scale),
                        ),
                        child: child!,
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getInitialRoute() {
    log('Determining initial route...');
    log('hasSeenOnboarding: ${widget.hasSeenOnboarding}');
    log('hasValidSession: ${widget.hasValidSession}');

    if (!widget.hasSeenOnboarding) {
      log('Showing onboarding');
      return AppRoutes.onboardingView;
    }

    if (widget.hasValidSession) {
      log('Showing host view');
      return AppRoutes.hostView;
    }

    log('Showing login view');
    return AppRoutes.loginView;
  }
}
