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
import '../widgets/custom_chips.dart';
import '../widgets/custom_rectangle_avatar_list.dart';
import '../widgets/library_card_list.dart';

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

  // Medical school years
  List<String> get _categories {
    final isArabic = context.isArabic;
    return isArabic
        ? [
            'الكل',
            'السنة الأولى',
            'السنة الثانية',
            'السنة الثالثة',
            'السنة الرابعة',
            'السنة الخامسة',
            'السنة السادسة',
          ]
        : [
            'All',
            'First Year',
            'Second Year',
            'Third Year',
            'Fourth Year',
            'Fifth Year',
            'Sixth Year',
          ];
  }

  // Libraries data list
  final List<Map<String, dynamic>> _librariesData = [
    {
      'title': 'Principles of Disease',
      'titleAr': 'مبادئ الأمراض',
      'description': 'A comprehensive resource designed to introduce learners to the fundamental concepts of pathology and microbiology.',
      'descriptionAr': 'مصدر شامل مصمم لتعريف المتعلمين بالمفاهيم الأساسية لعلم الأمراض والأحياء الدقيقة.',
      'image': 'assets/images/learning.png',
      'year': 'السنة الأولى',
      'yearEn': 'First Year',
      'subscribers': 12345,
      'price': 600,
    },
    {
      'title': 'Endocrine System',
      'titleAr': 'نظام الغدد الصماء',
      'description': 'A comprehensive overview of the endocrine system, focusing on hormone production, regulation, and their physiological effects.',
      'descriptionAr': 'نظرة شاملة على نظام الغدد الصماء، مع التركيز على إنتاج الهرمونات وتنظيمها وتأثيراتها الفسيولوجية.',
      'image': 'assets/images/learning.png',
      'year': 'السنة الثانية',
      'yearEn': 'Second Year',
      'subscribers': 10234,
      'price': 700,
    },
    {
      'title': 'Gynaecology Library',
      'titleAr': 'مكتبة أمراض النساء',
      'description': 'An in-depth study of the female reproductive system, including common conditions, diagnostic approaches, and treatment options.',
      'descriptionAr': 'دراسة متعمقة للجهاز التناسلي الأنثوي، بما في ذلك الحالات الشائعة ومناهج التشخيص وخيارات العلاج.',
      'image': 'assets/images/learning.png',
      'year': 'السنة الرابعة',
      'yearEn': 'Fourth Year',
      'subscribers': 8976,
      'price': 800,
    },
    {
      'title': 'Cardiovascular System',
      'titleAr': 'الجهاز القلبي الوعائي',
      'description': 'Detailed exploration of the cardiovascular system, covering anatomy, physiology, and common cardiovascular diseases.',
      'descriptionAr': 'استكشاف مفصل للجهاز القلبي الوعائي، يغطي التشريح ووظائف الأعضاء وأمراض القلب والأوعية الدموية الشائعة.',
      'image': 'assets/images/learning.png',
      'year': 'السنة الثالثة',
      'yearEn': 'Third Year',
      'subscribers': 11567,
      'price': 750,
    },
    {
      'title': 'Neurology & Psychiatry',
      'titleAr': 'الأمراض العصبية والنفسية',
      'description': 'Comprehensive study of neurological and psychiatric disorders, their diagnosis, and management strategies.',
      'descriptionAr': 'دراسة شاملة للاضطرابات العصبية والنفسية وتشخيصها واستراتيجيات إدارتها.',
      'image': 'assets/images/learning.png',
      'year': 'السنة الخامسة',
      'yearEn': 'Fifth Year',
      'subscribers': 9823,
      'price': 850,
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
      backgroundColor: AppColors.background,
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
                          //? Years Section
                          BuildRowOfTextAndTextButton(
                            text: 'سنين',
                            textEn: 'Years',
                            onPressed: () {
                              context.pushNamed(AppRoutes.categoriesView);
                              context.setNavBarVisible(false);
                            },
                          ),
                          CustomChips(
                            labels: _categories,
                            onSelected: (index) {
                              // Navigate to courses view with selected year filter
                              final selectedYear = index == 0
                                  ? 'All'
                                  : _categories[index];
                              context.pushNamed(
                                AppRoutes.coursesView,
                                arguments: {'year': selectedYear},
                              );
                              context.setNavBarVisible(false);
                            },
                          ),
                          SizedBox(height: 20.h),
                          //? Libraries Section
                          BuildRowOfTextAndTextButton(
                            text: 'المكتبات',
                            textEn: 'Libraries',
                            onPressed: () {
                              context.pushNamed(AppRoutes.streamingNowView);
                              context.setNavBarVisible(false);
                            },
                          ),
                          LibraryCardList(
                            itemCount: _librariesData.length,
                            librariesData: _librariesData,
                            cardHeight: 350,
                            cardWidth: 280,
                            spacing: 16,
                          ),
                          SizedBox(height: 20.h),
                          //? Top Mentor Section
                          BuildRowOfTextAndTextButton(
                            text: 'أفضل المدرسين',
                            textEn: 'Top Mentor',
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
            AppColors.background.withValues(alpha: 0.1),
            AppColors.background.withValues(alpha: 0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.text.withValues(alpha: 0.1),
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
                  colors: [AppColors.background.withValues(alpha: 0.3), Colors.transparent],
                ),
              ),
            ),
            // Bot icon placeholder
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.background.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.smart_toy_outlined,
                  color: AppColors.background,
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
                      color: AppColors.background.withValues(alpha: 0.5),
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
      ..color = color.withValues(alpha: 1.0 - animation.value)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius * animation.value, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
