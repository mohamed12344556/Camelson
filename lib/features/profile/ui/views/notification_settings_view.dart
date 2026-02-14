// Navigation extensions moved to core/utils/extensions.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class NotificationSettingsView extends StatefulWidget {
  const NotificationSettingsView({super.key});

  @override
  State<NotificationSettingsView> createState() =>
      _NotificationSettingsViewState();
}

class _NotificationSettingsViewState extends State<NotificationSettingsView> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = true;
  bool _courseUpdates = true;
  bool _assignments = true;
  bool _messages = false;
  bool _reminders = true;
  bool _promotions = false;

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
        title: 'Notifications Settings',
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

                  // Notification Methods Section
                  _buildSectionHeader('Notification Methods'),
                  SizedBox(height: 15.h),

                  _buildNotificationTile(
                    'Push Notifications',
                    'Receive notifications on your device',
                    Icons.notifications_outlined,
                    _pushNotifications,
                    (value) => setState(() => _pushNotifications = value),
                  ),

                  _buildNotificationTile(
                    'Email Notifications',
                    'Receive notifications via email',
                    Icons.email_outlined,
                    _emailNotifications,
                    (value) => setState(() => _emailNotifications = value),
                  ),

                  _buildNotificationTile(
                    'SMS Notifications',
                    'Receive notifications via SMS',
                    Icons.message_outlined,
                    _smsNotifications,
                    (value) => setState(() => _smsNotifications = value),
                  ),

                  SizedBox(height: 30.h),

                  // Notification Types Section
                  _buildSectionHeader('Notification Types'),
                  SizedBox(height: 15.h),

                  _buildNotificationTile(
                    'Course Updates',
                    'New courses, updates, and announcements',
                    Icons.school_outlined,
                    _courseUpdates,
                    (value) => setState(() => _courseUpdates = value),
                  ),

                  _buildNotificationTile(
                    'Assignments',
                    'Assignment deadlines and reminders',
                    Icons.assignment_outlined,
                    _assignments,
                    (value) => setState(() => _assignments = value),
                  ),

                  _buildNotificationTile(
                    'Messages',
                    'New messages from instructors and peers',
                    Icons.chat_outlined,
                    _messages,
                    (value) => setState(() => _messages = value),
                  ),

                  _buildNotificationTile(
                    'Reminders',
                    'Study reminders and scheduled notifications',
                    Icons.alarm_outlined,
                    _reminders,
                    (value) => setState(() => _reminders = value),
                  ),

                  _buildNotificationTile(
                    'Promotions',
                    'Special offers and discounts',
                    Icons.local_offer_outlined,
                    _promotions,
                    (value) => setState(() => _promotions = value),
                  ),

                  SizedBox(height: 30.h),

                  // Quiet Hours Section
                  _buildSectionHeader('Quiet Hours'),
                  SizedBox(height: 15.h),

                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Enable Quiet Hours',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            Switch(
                              value: false,
                              onChanged: (value) {
                                // Handle quiet hours toggle
                              },
                              activeColor: const Color(0xFF0961F5),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'From',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '10:00 PM',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'To',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '7:00 AM',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 55.h,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle save
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0961F5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      child: Text(
                        'Save Settings',
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

  Widget _buildNotificationTile(
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
}
