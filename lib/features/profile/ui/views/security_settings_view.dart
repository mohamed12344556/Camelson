// Navigation extensions moved to core/utils/extensions.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class SecuritySettingsView extends StatefulWidget {
  const SecuritySettingsView({super.key});

  @override
  State<SecuritySettingsView> createState() => _SecuritySettingsViewState();
}

class _SecuritySettingsViewState extends State<SecuritySettingsView> {
  bool _biometricLogin = true;
  bool _twoFactorAuth = false;
  bool _autoLogout = true;
  bool _loginAlerts = true;

  @override
  void initState() {
    super.initState();
    // Hide navigation bar when entering this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.setNavBarVisible(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: CustomAppBar(
        title: 'Security Settings',
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

                  // Password & Authentication Section
                  _buildSectionHeader('Password & Authentication'),
                  SizedBox(height: 15.h),

                  _buildSecurityOption(
                    'Change Password',
                    'Update your account password',
                    Icons.lock_outline,
                    onTap: () => _showChangePasswordDialog(),
                  ),

                  _buildSecurityToggle(
                    'Biometric Login',
                    'Use fingerprint or face recognition',
                    Icons.fingerprint,
                    _biometricLogin,
                    (value) => setState(() => _biometricLogin = value),
                  ),

                  _buildSecurityToggle(
                    'Two-Factor Authentication',
                    'Add an extra layer of security',
                    Icons.security,
                    _twoFactorAuth,
                    (value) => setState(() => _twoFactorAuth = value),
                  ),

                  SizedBox(height: 30.h),

                  // Privacy Settings Section
                  _buildSectionHeader('Privacy Settings'),
                  SizedBox(height: 15.h),

                  _buildSecurityToggle(
                    'Auto Logout',
                    'Automatically logout after 30 minutes',
                    Icons.timer_outlined,
                    _autoLogout,
                    (value) => setState(() => _autoLogout = value),
                  ),

                  _buildSecurityToggle(
                    'Login Alerts',
                    'Get notified of new login attempts',
                    Icons.notification_important_outlined,
                    _loginAlerts,
                    (value) => setState(() => _loginAlerts = value),
                  ),

                  _buildSecurityOption(
                    'Privacy Policy',
                    'View our privacy policy',
                    Icons.privacy_tip_outlined,
                    onTap: () => _showPrivacyPolicy(),
                  ),

                  SizedBox(height: 30.h),

                  // Account Management Section
                  _buildSectionHeader('Account Management'),
                  SizedBox(height: 15.h),

                  _buildSecurityOption(
                    'Download My Data',
                    'Download all your account data',
                    Icons.download_outlined,
                    onTap: () => _downloadData(),
                  ),

                  _buildSecurityOption(
                    'Active Sessions',
                    'Manage your active login sessions',
                    Icons.devices_outlined,
                    onTap: () => _showActiveSessions(),
                  ),

                  _buildSecurityOption(
                    'Delete Account',
                    'Permanently delete your account',
                    Icons.delete_outline,
                    isDestructive: true,
                    onTap: () => _showDeleteAccountDialog(),
                  ),

                  SizedBox(height: 40.h),

                  // Last Password Change Info
                  Container(
                    width: double.infinity,
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
                            'Last password change: January 15, 2025',
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

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.black,
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildSecurityOption(
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: Colors.grey[300]!),
        ),
        tileColor: Colors.grey[50],
        leading: Container(
          width: 45.w,
          height: 45.h,
          decoration: BoxDecoration(
            color: isDestructive ? Colors.red[400] : const Color(0xFF0961F5),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: Colors.white, size: 20.sp),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red[600] : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.sp,
          color: Colors.grey[600],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSecurityToggle(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 45.w,
            height: 45.h,
            decoration: BoxDecoration(
              color: value ? const Color(0xFF0961F5) : Colors.grey[400],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: Colors.white, size: 20.sp),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF0961F5),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Change Password'),
            content: const Text(
              'You will be redirected to change your password.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continue'),
              ),
            ],
          ),
    );
  }

  void _showPrivacyPolicy() {
    // Navigate to privacy policy
  }

  void _downloadData() {
    // Download user data
  }

  void _showActiveSessions() {
    // Show active sessions
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Account'),
            content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
