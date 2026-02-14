import 'package:simplify/features/profile/ui/views/notification_settings_view.dart';
import 'package:simplify/features/profile/ui/views/terms_&_conditions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../../../core/languages/language_cubit.dart';
import '../logic/plans/plans_cubit.dart';
import '../views/dark_mode_settings_view.dart';
import '../views/edit_profile_view.dart';
import '../views/help_center_view.dart';
import '../views/invite_friends_view.dart';
import '../views/language_settings_view.dart';
import '../views/payment_view.dart';
import '../views/plans_view.dart';
import '../views/security_settings_view.dart';

List<Map<String, dynamic>> getProfileOptions(BuildContext context) {
  final languageCubit = BlocProvider.of<LanguageCubit>(context);
  final currentLanguageCode = languageCubit.getCurrentLanguageCode();

  return [
    const {
      "icon": Icons.person,
      "title": "Edit Profile",
      "page": EditProfileView(),
    },
    const {
      "icon": Icons.payment,
      "title": "Payment Option",
      "page": PaymentView(),
    },
    // ✅ Add Subscription Plans here
    {
      "icon": Icons.workspace_premium,
      "title": "Subscription Plans",
      "page": BlocProvider(
        create: (context) => sl<PlansCubit>()..loadStudentPlans(),
        child: const PlansView(),
      ),
    },
    const {
      "icon": Icons.security,
      "title": "Security",
      "page": SecuritySettingsView(),
    },
    {
      "icon": Icons.language_outlined,
      "title": "Language",
      "page": const LanguageSettingsView(),
      // pass the current language - will update when language changes
      "trailing": _languages.firstWhere(
        (element) => element['code'] == currentLanguageCode,
      )['name'],
    },
    const {
      "icon": Icons.dark_mode,
      "title": "Dark Mode",
      "page": DarkModeSettingsView(),
    },
    const {
      "icon": Icons.description,
      "title": "Terms & Conditions",
      "page": TermsAndConditionsView(),
    },
    const {
      "icon": Icons.help,
      "title": "Help Center",
      "page": HelpCenterView(),
    },
    const {
      "icon": Icons.group,
      "title": "Invite Friends",
      "page": InviteFriendsView(),
    },
    {
      "icon": Icons.logout,
      "title": "Logout",
      "page": null, // Special handling for logout
      "isLogout": true,
    },
  ];
}

// Keep the old function for backward compatibility if needed elsewhere
Object getCurrentLanguageCode() {
  final languageCubit = LanguageCubit();
  return languageCubit.getCurrentLanguageCode();
}

final List<String> _languageCodes = [
  'en',
  'ar',
  'fr',
  'es',
  'pt',
  'ru',
  'zh',
  'ja',
  'de',
  'it',
  'ko',
  'vi',
  'tr',
  'pl',
  'id',
];

List<Map<String, dynamic>> get _languages => _languageCodes
    .map(
      (code) => {
        'name': Languages.getLanguageName(code),
        'nativeName': Languages.getLanguageNativeName(code),
        'flag': Languages.getLanguageFlag(code),
        'code': code,
      },
    )
    .toList();
