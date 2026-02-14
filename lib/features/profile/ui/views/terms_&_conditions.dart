// Navigation extensions moved to core/utils/extensions.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class TermsAndConditionsView extends StatefulWidget {
  const TermsAndConditionsView({super.key});

  @override
  State<TermsAndConditionsView> createState() =>
      _TermsAndConditionsViewState();
}

class _TermsAndConditionsViewState extends State<TermsAndConditionsView> {
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
        title: 'Terms & Conditions',
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

                  // Header Info
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last Updated: January 15, 2025',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF0961F5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Please read these terms and conditions carefully before using our service.',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 25.h),

                  // Terms Content
                  _buildSection(
                    '1. Acceptance of Terms',
                    'By accessing and using this educational platform, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
                  ),

                  _buildSection(
                    '2. Use License',
                    'Permission is granted to temporarily download one copy of the materials on our educational platform for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title.',
                  ),

                  _buildSection(
                    '3. User Account',
                    'When you create an account with us, you must provide information that is accurate, complete, and current at all times. You are responsible for safeguarding the password and for any activities that occur under your account.',
                  ),

                  _buildSection(
                    '4. Course Access',
                    'Access to courses and materials is granted based on your subscription or payment status. We reserve the right to modify, suspend, or discontinue any course content at any time without notice.',
                  ),

                  _buildSection(
                    '5. Intellectual Property',
                    'All course materials, including but not limited to videos, texts, images, and audio files, are protected by copyright and other intellectual property laws. Unauthorized reproduction or distribution is strictly prohibited.',
                  ),

                  _buildSection(
                    '6. Payment Terms',
                    'Payment for courses and subscriptions must be made in advance. All fees are non-refundable unless otherwise stated in our refund policy. Prices are subject to change without notice.',
                  ),

                  _buildSection(
                    '7. Privacy Policy',
                    'Your privacy is important to us. Our Privacy Policy explains how we collect, use, and protect your information when you use our service.',
                  ),

                  _buildSection(
                    '8. Prohibited Uses',
                    'You may not use our service for any unlawful purpose or to solicit others to perform acts that would violate applicable laws. You may not transmit viruses, worms, or any code of a destructive nature.',
                  ),

                  _buildSection(
                    '9. Disclaimer',
                    'The information on this platform is provided on an "as is" basis. To the fullest extent permitted by law, we exclude all representations, warranties, and conditions relating to our website and the use of this platform.',
                  ),

                  _buildSection(
                    '10. Limitation of Liability',
                    'In no event shall our company or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on our platform.',
                  ),

                  _buildSection(
                    '11. Modifications',
                    'We may revise these terms of service at any time without notice. By using this platform, you are agreeing to be bound by the then current version of these terms of service.',
                  ),

                  _buildSection(
                    '12. Contact Information',
                    'If you have any questions about these Terms & Conditions, please contact us at support@eolapp.com',
                  ),

                  SizedBox(height: 30.h),

                  // Accept Button
                  SizedBox(
                    width: double.infinity,
                    height: 55.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0961F5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      child: Text(
                        'I Accept Terms & Conditions',
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

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          content,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }
}
