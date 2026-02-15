import 'package:boraq/core/themes/cubit/theme_cubit.dart';
import 'package:boraq/core/widgets/custom_app_bar.dart';
// Navigation extensions moved to core/utils/extensions.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/core.dart';

class DarkModeSettingsView extends StatefulWidget {
  const DarkModeSettingsView({super.key});

  @override
  State<DarkModeSettingsView> createState() => _DarkModeSettingsViewState();
}

class _DarkModeSettingsViewState extends State<DarkModeSettingsView> {
  final List<Map<String, dynamic>> _themeOptions = [
    {
      'name': 'Light',
      'description': 'Clean and bright interface',
      'icon': Icons.light_mode,
      'preview': Colors.white,
      'mode': ThemeMode.light,
    },
    {
      'name': 'Dark',
      'description': 'Easy on the eyes in low light',
      'icon': Icons.dark_mode,
      'preview': const Color(0xFF1A1A1A),
      'mode': ThemeMode.dark,
    },
    {
      'name': 'System',
      'description': 'Automatically switch based on system settings',
      'icon': Icons.auto_mode,
      'preview': Colors.grey[400],
      'mode': ThemeMode.system,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Hide navigation bar when entering this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.setNavBarVisible(false);
    });
  }

  String _getThemeString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, currentThemeMode) {
        final selectedTheme = _getThemeString(currentThemeMode);

        return Scaffold(
          backgroundColor: const Color(0xFFF5F9FF),
          appBar: CustomAppBar(
            title: 'Dark Mode Settings',
            onBackPressed: () {
              context.setNavBarVisible(true);
              Navigator.pop(context);
            },
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 18.h),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(25.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),

                      // Theme Preview Section
                      Text(
                        'Theme Preview',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: 15.h),

                      // Preview Card
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.23,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: _getPreviewBackgroundColor(selectedTheme),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'App Preview',
                                  style: TextStyle(
                                    color: _getPreviewTextColor(selectedTheme),
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Icon(
                                  Icons.more_vert,
                                  color: _getPreviewTextColor(selectedTheme),
                                  size: 20.sp,
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h),
                            Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * 0.08,
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: _getPreviewCardColor(selectedTheme),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20.r,
                                    backgroundColor: const Color(0xFF0961F5),
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 20.sp,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Sample Course',
                                          style: TextStyle(
                                            color: _getPreviewTextColor(
                                              selectedTheme,
                                            ),
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Course description',
                                          style: TextStyle(
                                            color: _getPreviewTextColor(
                                              selectedTheme,
                                            ).withOpacity(0.7),
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 15.h),
                            Container(
                              width: 150.w,
                              height: 35.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0961F5),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Center(
                                child: Text(
                                  'Start Learning',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 30.h),

                      // Theme Options Section
                      Text(
                        'Choose Theme',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: 15.h),

                      // Theme Options List
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _themeOptions.length,
                        itemBuilder: (context, index) {
                          return _buildThemeOption(
                            _themeOptions[index],
                            selectedTheme,
                          );
                        },
                      ),

                      SizedBox(height: 30.h),

                      // Additional Settings
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F8FF),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: const Color(0xFF0961F5).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: const Color(0xFF0961F5),
                              size: 20.sp,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                'Dark mode helps reduce eye strain in low-light environments and can help save battery life on OLED displays.',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF0961F5),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 40.h),

                      // Apply Button (Optional - themes change immediately)
                      SizedBox(
                        width: double.infinity,
                        height: 55.h,
                        child: ElevatedButton(
                          onPressed: () {
                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Theme applied successfully!'),
                                backgroundColor: const Color(0xFF0961F5),
                                duration: const Duration(seconds: 2),
                              ),
                            );

                            // Navigate back
                            context.setNavBarVisible(true);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0961F5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                          ),
                          child: Text(
                            'Done',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(Map<String, dynamic> theme, String selectedTheme) {
    final isSelected = selectedTheme == theme['name'];

    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? const Color(0xFF0961F5) : Colors.grey[300]!,
          width: isSelected ? 2.w : 1.w,
        ),
        borderRadius: BorderRadius.circular(16.r),
        color: isSelected ? const Color(0xFFF0F8FF) : Colors.grey[50],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        leading: Container(
          width: 50.w,
          height: 50.h,
          decoration: BoxDecoration(
            color: theme['preview'],
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Icon(
            theme['icon'],
            color: theme['name'] == 'Dark' ? Colors.white : Colors.black,
            size: 24.sp,
          ),
        ),
        title: Text(
          theme['name'],
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          theme['description'],
          style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
        ),
        trailing: Radio<String>(
          value: theme['name'],
          groupValue: selectedTheme,
          onChanged: (String? value) {
            if (value != null) {
              _changeTheme(value);
            }
          },
          activeColor: const Color(0xFF0961F5),
        ),
        onTap: () {
          _changeTheme(theme['name']);
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Theme applied successfully!'),
              backgroundColor: const Color(0xFF0961F5),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _changeTheme(String themeName) {
    final themeCubit = context.read<ThemeCubit>();

    switch (themeName) {
      case 'Light':
        themeCubit.changeTheme(ThemeMode.light);
        break;
      case 'Dark':
        themeCubit.changeTheme(ThemeMode.dark);
        break;
      case 'System':
        themeCubit.changeTheme(ThemeMode.system);
        break;
    }
  }

  Color _getPreviewBackgroundColor(String selectedTheme) {
    switch (selectedTheme) {
      case 'Dark':
        return const Color(0xFF1A1A1A);
      case 'System':
        // For system mode, check current brightness
        final brightness = MediaQuery.of(context).platformBrightness;
        return brightness == Brightness.dark
            ? const Color(0xFF1A1A1A)
            : Colors.white;
      default:
        return Colors.white;
    }
  }

  Color _getPreviewTextColor(String selectedTheme) {
    switch (selectedTheme) {
      case 'Dark':
        return Colors.white;
      case 'System':
        // For system mode, check current brightness
        final brightness = MediaQuery.of(context).platformBrightness;
        return brightness == Brightness.dark ? Colors.white : Colors.black;
      default:
        return Colors.black;
    }
  }

  Color _getPreviewCardColor(String selectedTheme) {
    switch (selectedTheme) {
      case 'Dark':
        return const Color(0xFF2A2A2A);
      case 'System':
        // For system mode, check current brightness
        final brightness = MediaQuery.of(context).platformBrightness;
        return brightness == Brightness.dark
            ? const Color(0xFF2A2A2A)
            : Colors.grey[100]!;
      default:
        return Colors.grey[100]!;
    }
  }
}
