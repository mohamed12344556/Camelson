import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../logic/profle/profile_cubit.dart';
import '../logic/profle/profile_state.dart';
import '../widgets/bottom_circle_avatar.dart';
import '../widgets/gmail_text.dart';
import '../widgets/profile_circle_avatar.dart';
import '../widgets/profile_list.dart';
import '../widgets/profile_list_tile.dart';

class ProfileSettingsView extends StatefulWidget {
  const ProfileSettingsView({super.key});

  @override
  State<ProfileSettingsView> createState() => _ProfileSettingsViewState();
}

class _ProfileSettingsViewState extends State<ProfileSettingsView> {
  late List<Map<String, dynamic>> currentProfileOptions;

  @override
  void initState() {
    super.initState();
    currentProfileOptions = getProfileOptions(context);
  }

  void refreshProfileOptions() {
    setState(() {
      currentProfileOptions = getProfileOptions(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF5F9FF),
      appBar: CustomAppBar(title: 'Profile Settings'),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final isLoading =
              state.status == ProfileStatus.loading && state.userData == null;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 18.h),
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                  borderRadius: BorderRadius.circular(40.r),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    ProfileCircleAvatar(
                      imageUrl: state.userData?.profileImageUrl,
                      isLoading: isLoading,
                    ),
                    SizedBox(height: 10.h),
                    BottomCircleAvatar(
                      name: state.userData?.name,
                      isLoading: isLoading,
                    ),
                    SizedBox(height: 5.h),
                    GmailText(
                      email: state.userData?.email,
                      isLoading: isLoading,
                    ),
                    SizedBox(height: 15.h),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: currentProfileOptions.length,
                      itemBuilder: (context, index) {
                        final option = currentProfileOptions[index];
                        return ProfileListTile(
                          icon: option['icon'],
                          title: option['title'],
                          page: option['page'],
                          trailing: option['trailing'],
                          isLogout: option['isLogout'] ?? false,
                          onLanguageChanged: option['title'] == 'Language'
                              ? refreshProfileOptions
                              : null,
                        );
                      },
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
