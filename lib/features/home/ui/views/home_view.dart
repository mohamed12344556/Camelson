import 'dart:ui';

// Navigation extensions moved to core/utils/extensions.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/modern_error_state.dart';
import '../../logic/home_cubit.dart';
import '../widgets/build_banner.dart';
import '../widgets/build_row_of_text_and_text_button.dart';
import '../widgets/custom_app_bar_widget.dart';
import '../widgets/custom_card_list.dart';
import '../widgets/custom_chips.dart';
import '../widgets/custom_rectangle_avatar_list.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  // Banner data moved to separate list
  final List<Map<String, String>> _bannerData = [
    {
      'title': 'Learn',
      'subtitle': 'Anywhere Anytime',
      'image': 'assets/images/learning.png',
    },
    {
      'title': 'Explore',
      'subtitle': 'New Horizons',
      'image': 'assets/images/learning.png',
    },
    {
      'title': 'Achieve',
      'subtitle': 'Your Goals',
      'image': 'assets/images/learning.png',
    },
    {
      'title': 'Discover',
      'subtitle': 'New Skills',
      'image': 'assets/images/learning.png',
    },
    {
      'title': 'Master',
      'subtitle': 'Your Craft',
      'image': 'assets/images/learning.png',
    },
  ];

  // Categories moved to separate list
  final List<String> _categories = [
    'All',
    'Arabic',
    'English',
    'Math',
    'Physics',
    'Science',
  ];

  // Streaming data list
  final List<Map<String, dynamic>> _streamingData = [
    {
      'title': 'Master JavaScript in 30 Days',
      'instructor': 'Sarah Johnson',
      'avatar': 'assets/images/person2.png',
      'duration': '02:15:30',
      'image': 'assets/images/teacher_streaming.jpg',
      'isLive': true,
    },
    {
      'title': 'Advanced Flutter Development',
      'instructor': 'Ahmed Hassan',
      'avatar': 'assets/images/person2.png',
      'duration': '01:45:20',
      'image': 'assets/images/teacher_streaming.jpg',
      'isLive': true,
    },
    {
      'title': 'UI/UX Design Fundamentals',
      'instructor': 'Emma Wilson',
      'avatar': 'assets/images/person2.png',
      'duration': '03:22:10',
      'image': 'assets/images/teacher_streaming.jpg',
      'isLive': false,
    },
    {
      'title': 'Python for Data Science',
      'instructor': 'Michael Chen',
      'avatar': 'assets/images/person2.png',
      'duration': '02:08:45',
      'image': 'assets/images/teacher_streaming.jpg',
      'isLive': true,
    },
    {
      'title': 'Digital Marketing Strategy',
      'instructor': 'Lisa Garcia',
      'avatar': 'assets/images/person2.png',
      'duration': '01:55:15',
      'image': 'assets/images/teacher_streaming.jpg',
      'isLive': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeOut),
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CustomAppBarWidget(),
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content
            BlocConsumer<HomeCubit, HomeState>(
              listener: (context, state) {
                if (state is HomeError &&
                    state.message.errorMessage?.code == 401) {
                  context.showErrorSnackBar(
                    'Authentication failed. Refreshing token...',
                  );
                  context.read<HomeCubit>().refreshToken();
                }

                if (state is HomeError) {
                  context.showErrorSnackBar(
                    state.message.errorMessage!.message ??
                        'Something went wrong',
                  );
                }
              },
              builder: (context, state) {
                // Error state
                if (state is HomeError) {
                  return ErrorStateExtension.fromErrorMessage(
                    state.message.errorMessage?.message,
                    onRetry: () {
                      context.read<HomeCubit>().loadingData();
                    },
                    secondaryButtonText: 'Contact Support',
                    onSecondaryAction: () {
                      // context.pushNamed(Routes.contactSupportView);
                    },
                  );
                }
                // Success state - show main content
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Skeletonizer(
                      enabled: state is HomeLoading,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //? Banner with glassmorphism effect
                          _buildGlassmorphicContainer(
                            child: BuildBanner(bannersData: _bannerData),
                          ),
                          SizedBox(height: 20.h),
                          //? Categories Section
                          BuildRowOfTextAndTextButton(
                            text: 'Categories',
                            onPressed: () {
                              context.pushNamed(AppRoutes.categoriesView);
                              context.setNavBarVisible(false);
                            },
                          ),
                          CustomChips(labels: _categories),
                          SizedBox(height: 20.h),
                          //? Streaming Now Section
                          BuildRowOfTextAndTextButton(
                            text: 'Streaming Now',
                            onPressed: () {
                              context.pushNamed(AppRoutes.streamingNowView);
                              context.setNavBarVisible(false);
                            },
                          ),
                          CustomCardList(
                            itemCount: _streamingData.length,
                            streamingData: _streamingData,
                            cardHeight: 150,
                            cardWidth: 256,
                            spacing: 19,
                            liveText: 'LIVE',
                          ),
                          SizedBox(height: 20.h),
                          //? Top Mentor Section
                          BuildRowOfTextAndTextButton(
                            text: 'Top Mentor',
                            onPressed: () {
                              context.pushNamed(AppRoutes.topMentorsView);
                              context.setNavBarVisible(false);
                            },
                          ),
                          CustomRectangleAvatarList(
                            itemCount: 15,
                            assetPrefix: 'assets/images/person2.png',
                            spacing: 16,
                          ),
                          SizedBox(height: 35.h),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // AI Bot Floating Action Button
            Positioned(
              bottom: 24,
              right: 16,
              child: ScaleTransition(
                scale: _fabScaleAnimation,
                child: _buildAIBotFAB(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassmorphicContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }

  Widget _buildAIBotFAB() {
    return GestureDetector(
      onTap: () {
        context.pushNamed(AppRoutes.aiChatView);
        context.setNavBarVisible(false);
      },
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF167F71), const Color(0xFF0A5F53)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF167F71).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: const Color(0xFF167F71).withOpacity(0.1),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glow effect
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.white.withOpacity(0.3), Colors.transparent],
                ),
              ),
            ),
            // Bot icon placeholder
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.smart_toy_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            // Pulse animation ring
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _fabAnimationController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: PulsePainter(
                      animation: _fabAnimationController,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for pulse effect
class PulsePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  PulsePainter({required this.animation, required this.color})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = color.withOpacity(1.0 - animation.value)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius * animation.value, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
