// Navigation extensions moved to core/utils/extensions.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_search_bar.dart';

class HelpCenterView extends StatefulWidget {
  const HelpCenterView({super.key});

  @override
  State<HelpCenterView> createState() => _HelpCenterViewState();
}

class _HelpCenterViewState extends State<HelpCenterView> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredFAQItems = [];

  final List<Map<String, dynamic>> _faqItems = [
    {
      'question': 'How do I reset my password?',
      'answer':
          'Go to the login screen and tap "Forgot Password". Enter your email address and follow the instructions sent to your email.',
      'isExpanded': false,
    },
    {
      'question': 'How can I access my purchased courses?',
      'answer':
          'Your purchased courses are available in the "My Courses" section. You can access them anytime as long as your subscription is active.',
      'isExpanded': false,
    },
    {
      'question': 'Can I download courses for offline viewing?',
      'answer':
          'Yes, premium subscribers can download course content for offline viewing. Look for the download icon next to each lesson.',
      'isExpanded': false,
    },
    {
      'question': 'How do I cancel my subscription?',
      'answer':
          'You can cancel your subscription in the Payment Options section of your profile. The cancellation will take effect at the end of your current billing period.',
      'isExpanded': false,
    },
    {
      'question': 'Is there a student discount available?',
      'answer':
          'Yes, we offer student discounts. Contact our support team with your valid student ID to learn more about available discounts.',
      'isExpanded': false,
    },
    {
      'question': 'How do I contact customer support?',
      'answer':
          'You can contact our support team through the "Contact Support" option below, or email us directly at support@eolapp.com.',
      'isExpanded': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredFAQItems = _faqItems;
    // Hide navigation bar when entering this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.setNavBarVisible(false);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFAQItems(String query) {
    setState(() {
      _filteredFAQItems =
          _faqItems.where((item) {
            return item['question'].toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                item['answer'].toLowerCase().contains(query.toLowerCase());
          }).toList();
    });
  }

  void _onClearPressed() {
    _searchController.clear();
    _filterFAQItems('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: CustomAppBar(
        title: 'Help Center',
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

                  // Search Bar using CustomSearchBar
                  CustomSearchBar(
                    isPaddingZero: true,
                    searchController: _searchController,
                    onChanged: _filterFAQItems,
                    onClearPressed: _onClearPressed,
                  ),

                  SizedBox(height: 25.h),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: 15.h),

                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          'Contact Support',
                          Icons.support_agent,
                          () => _contactSupport(),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildQuickActionCard(
                          'Report Issue',
                          Icons.bug_report,
                          () => _reportIssue(),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          'User Guide',
                          Icons.menu_book,
                          () => _openUserGuide(),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildQuickActionCard(
                          'Video Tutorials',
                          Icons.play_circle,
                          () => _openVideoTutorials(),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 30.h),

                  // FAQ Section
                  Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: 15.h),

                  // FAQ List
                  _filteredFAQItems.isEmpty
                      ? _buildNoResultsMessage()
                      : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredFAQItems.length,
                        itemBuilder: (context, index) {
                          return _buildFAQItem(index);
                        },
                      ),

                  SizedBox(height: 30.h),

                  // Contact Info
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0961F5), Color(0xFF2F98D7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.headset_mic,
                          color: Colors.white,
                          size: 40.sp,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Still Need Help?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Our support team is available 24/7 to help you with any questions or issues.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 15.h),
                        ElevatedButton(
                          onPressed: () => _contactSupport(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0961F5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 30.w,
                              vertical: 12.h,
                            ),
                          ),
                          child: Text(
                            'Contact Support',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
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

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Container(
              width: 45.w,
              height: 45.h,
              decoration: BoxDecoration(
                color: const Color(0xFF0961F5),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: Colors.white, size: 20.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ExpansionTile(
        title: Text(
          _filteredFAQItems[index]['question'],
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: Text(
              _filteredFAQItems[index]['answer'],
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
        onExpansionChanged: (expanded) {
          setState(() {
            _filteredFAQItems[index]['isExpanded'] = expanded;
          });
        },
      ),
    );
  }

  Widget _buildNoResultsMessage() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 64.sp, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Try searching with different keywords',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  void _contactSupport() {
    // Handle contact support
  }

  void _reportIssue() {
    // Handle report issue
  }

  void _openUserGuide() {
    // Handle open user guide
  }

  void _openVideoTutorials() {
    // Handle open video tutorials
  }
}
