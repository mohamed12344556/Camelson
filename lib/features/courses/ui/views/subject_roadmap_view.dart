import 'package:camelson/core/constants/roadmap_constants.dart';
import 'package:camelson/features/courses/ui/widgets/gaming_animated_roadmap.dart';
import 'package:camelson/features/courses/ui/widgets/gaming_ui_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/models/subject_roadmap_model.dart';

class SubjectRoadmapView extends StatefulWidget {
  final SubjectRoadmap? roadmap;

  const SubjectRoadmapView({super.key, this.roadmap});

  @override
  State<SubjectRoadmapView> createState() => _SubjectRoadmapViewState();
}

class _SubjectRoadmapViewState extends State<SubjectRoadmapView>
    with TickerProviderStateMixin {
  late SubjectRoadmap roadmap;
  late AnimationController _headerAnimationController;
  late AnimationController _particleController;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;
  bool _showAchievements = false;

  // Animation Style - Default to timeline
  RoadmapAnimationStyle _currentStyle = RoadmapAnimationStyle.timeline;

  @override
  void initState() {
    super.initState();
    roadmap = widget.roadmap ?? _getSampleRoadmapData();

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _headerSlideAnimation = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _headerAnimationController.forward();
  }

  void _toggleAnimationStyle() {
    setState(() {
      _currentStyle = _currentStyle == RoadmapAnimationStyle.timeline
          ? RoadmapAnimationStyle.floatingOrbs
          : RoadmapAnimationStyle.timeline;
    });

    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F1FF), // lightWhite
      extendBodyBehindAppBar: true,
      appBar: _buildStudyStyleAppBar(),
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(),

          // Main Content
          Column(
            children: [
              const SizedBox(height: 100), // Space for app bar
              // Study Style Header
              AnimatedBuilder(
                animation: _headerAnimationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _headerSlideAnimation.value),
                    child: Opacity(
                      opacity: _headerFadeAnimation.value,
                      child: _buildStudyHeader(),
                    ),
                  );
                },
              ),

              // Roadmap Content
              Expanded(
                child: GamingAnimatedRoadmap(
                  key: ValueKey(_currentStyle), // هذا السطر مهم!
                  roadmap: roadmap,
                  onLessonTap: _handleLessonTap,
                  onChapterTap: _handleChapterTap,
                  initialStyle: _currentStyle,
                ),
              ),
            ],
          ),

          // Floating Achievements Button
          _buildFloatingAchievements(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildStudyStyleAppBar() {
    return CustomAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: 'خريطة ${roadmap.subjectName}',
      titleStyle: const TextStyle(
        color: Color(0xFF505050), // text
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
      actions: [
        // Animation Style Toggle Button
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF).withOpacity(0.9), // background
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: RoadmapStyleConfig.getColors(
                _currentStyle,
              ).primary.withOpacity(0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: RoadmapStyleConfig.getColors(
                  _currentStyle,
                ).primary.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              RoadmapStyleConfig.getIcon(_currentStyle),
              color: RoadmapStyleConfig.getColors(_currentStyle).primary,
            ),
            onPressed: _toggleAnimationStyle,
            tooltip: RoadmapStyleConfig.getName(_currentStyle),
          ),
        ),
        // Achievements Button
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF).withOpacity(0.9), // background
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFF6B35).withOpacity(0.5),
            ), // Orange
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B35).withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.emoji_events,
              color: Color(0xFFFF6B35),
            ), // Orange
            onPressed: () =>
                setState(() => _showAchievements = !_showAchievements),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticleBackgroundPainter(_particleController.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildStudyHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Stack(
        children: [
          // Soft Glow Effect
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2F98D7).withOpacity(0.2), // primary
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: const Color(0xFF73CBFF).withOpacity(0.1), // lightBlue
                  blurRadius: 40,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),

          // Main Container
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFFFFF), // background
                  Color(0xFFF0F3FF), // secondary
                  Color(0xFFE8F1FF), // lightWhite
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                width: 2,
                color: const Color(0xFF2F98D7).withOpacity(0.3), // primary
              ),
            ),
            child: Column(
              children: [
                // Title and Level
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Color(0xFF2F98D7),
                                Color(0xFF73CBFF),
                              ], // primary to lightBlue
                            ).createShader(bounds),
                            child: Text(
                              _getCurrentChapterName(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'الدرس الحالي',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(
                                0xFF2F98D7,
                              ).withOpacity(0.8), // primary
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Level Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF6B35),
                            Color(0xFFFF8A50),
                          ], // Orange gradient
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B35).withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Text(
                        'المستوى ${_getCurrentLevel()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Progress Section with Stats
                Row(
                  children: [
                    // Stats in a row
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildCompactStatItem(
                            'الفصول',
                            '${roadmap.chapters.length}',
                            Icons.library_books,
                            const Color(0xFF2F98D7),
                          ),
                          _buildCompactStatItem(
                            'مكتمل',
                            '${_getCompletedLessons()}',
                            Icons.check_circle,
                            const Color(0xFF4CAF50),
                          ),
                          _buildCompactStatItem(
                            'الإنجازات',
                            '${_getAchievementsCount()}',
                            Icons.emoji_events,
                            const Color(0xFFFF6B35),
                          ),
                          _buildCompactStatItem(
                            'النقاط',
                            '${_getTotalXP()}',
                            Icons.star,
                            const Color(0xFFFFD700),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Circular Progress with Icon
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: roadmap.overallProgress / 100,
                            strokeWidth: 6,
                            backgroundColor: const Color(
                              0xFF2F98D7,
                            ).withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF2F98D7),
                            ),
                          ),
                        ),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F98D7).withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF2F98D7).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${roadmap.overallProgress.toInt()}%',
                                style: const TextStyle(
                                  color: Color(0xFF2F98D7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(
                                Icons.school,
                                color: Color(0xFFFF6B35),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF505050).withOpacity(0.6),
            fontSize: 9,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingAchievements() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      right: 16,
      top: _showAchievements ? 115 : -250,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF).withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFF6B35).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2F98D7).withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'الإنجازات',
              style: TextStyle(
                color: Color(0xFFFF6B35),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            _buildAchievementItem('الخطوات الأولى', 'إكمال أول درس', true),
            _buildAchievementItem('المثابرة', 'إكمال 5 دروس', false),
            _buildAchievementItem('الإتقان', 'إكمال فصل كامل', false),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementItem(String title, String desc, bool unlocked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: unlocked
            ? const Color(0xFFFF6B35).withOpacity(0.1)
            : const Color(0xFFE6E6E6).withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            unlocked ? Icons.emoji_events : Icons.lock,
            color: unlocked ? const Color(0xFFFF6B35) : const Color(0xFF505050),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: unlocked
                        ? const Color(0xFFFF6B35)
                        : const Color(0xFF505050),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(
                    color: unlocked
                        ? const Color(0xFFFF6B35).withOpacity(0.8)
                        : const Color(0xFF505050).withOpacity(0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentChapterName() {
    for (var chapter in roadmap.chapters) {
      if (!chapter.isCompleted && !chapter.isLocked) {
        return 'الفصل ${chapter.chapterNumber}: ${chapter.chapterName}';
      }
    }
    return 'تم إكمال جميع الفصول!';
  }

  int _getCurrentLevel() {
    return (roadmap.overallProgress / 20).floor() + 1;
  }

  int _getCompletedLessons() {
    int completed = 0;
    for (var chapter in roadmap.chapters) {
      for (var lesson in chapter.lessons) {
        if (lesson.isCompleted) completed++;
      }
    }
    return completed;
  }

  int _getTotalXP() {
    int totalXP = 0;
    for (var chapter in roadmap.chapters) {
      for (var lesson in chapter.lessons) {
        if (lesson.isCompleted) {
          totalXP += _getXpReward(lesson);
        }
      }
    }
    return totalXP;
  }

  int _getAchievementsCount() {
    // Count unlocked achievements based on progress
    int achievements = 0;

    // First lesson completed
    if (_getCompletedLessons() >= 1) achievements++;

    // 5 lessons completed
    if (_getCompletedLessons() >= 5) achievements++;

    // First chapter completed
    bool hasCompletedChapter = roadmap.chapters.any(
      (chapter) => chapter.isCompleted,
    );
    if (hasCompletedChapter) achievements++;

    // High progress achievement
    if (roadmap.overallProgress >= 80) achievements++;

    return achievements;
  }

  void _handleLessonTap(LessonModel lesson, ChapterModel chapter) {
    HapticFeedback.lightImpact();

    if (lesson.isLocked) {
      _showStudyStyleDialog(
        'الدرس مغلق!',
        'يجب إكمال الدروس السابقة لفتح هذا الدرس.',
        Icons.lock,
        const Color(0xFFB00020),
      );
      return;
    }

    switch (lesson.type) {
      case LessonType.video:
        context.pushNamed(
          AppRoutes.courseContentsView,
          arguments: {'lesson': lesson, 'chapter': chapter},
        );
        break;
      case LessonType.quiz:
        _showStudyStyleDialog(
          'وضع الاختبار',
          'اختبارات التحدي قريباً!',
          Icons.quiz,
          const Color(0xFFFF6B35),
        );
        break;
      case LessonType.assignment:
        _showStudyStyleDialog(
          'مهمة خاصة',
          'المهام قريباً!',
          Icons.assignment,
          const Color(0xFF2F98D7),
        );
        break;
      case LessonType.reading:
        _showStudyStyleDialog(
          'مواد القراءة',
          'مواد القراءة قريباً!',
          Icons.menu_book,
          const Color(0xFF73CBFF),
        );
        break;
    }
  }

  void _handleChapterTap(ChapterModel chapter) {
    HapticFeedback.lightImpact();

    if (chapter.isLocked) {
      _showStudyStyleDialog(
        'الفصل مغلق!',
        'يجب إكمال الفصول السابقة لفتح هذه الرحلة التعليمية!',
        Icons.lock,
        const Color(0xFFB00020),
      );
      return;
    }

    _showChapterDetails(chapter);
  }

  void _showStudyStyleDialog(
    String title,
    String message,
    IconData icon,
    Color color,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 48),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(color: Color(0xFF505050), fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('فهمت'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChapterDetails(ChapterModel chapter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFF0F3FF)],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          border: Border.all(
            color: const Color(0xFF2F98D7).withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2F98D7),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2F98D7).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF2F98D7), Color(0xFF73CBFF)],
                    ).createShader(bounds),
                    child: Text(
                      chapter.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    chapter.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF505050),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F3FF),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFF2F98D7).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'تقدم الفصل',
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF505050).withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              '${chapter.progress.toInt()}%',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2F98D7),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              Container(
                                height: 12,
                                color: const Color(0xFFE6E6E6),
                              ),
                              Container(
                                height: 12,
                                width:
                                    (MediaQuery.of(context).size.width - 80) *
                                    (chapter.progress / 100),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF2F98D7),
                                      Color(0xFF73CBFF),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: chapter.lessons.length,
                itemBuilder: (context, index) {
                  final lesson = chapter.lessons[index];
                  return _buildStudyLessonCard(lesson, chapter, index);
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2F98D7), Color(0xFF73CBFF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2F98D7).withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    final currentLesson = chapter.lessons.firstWhere(
                      (l) => l.isCurrent,
                      orElse: () => chapter.lessons.first,
                    );
                    _handleLessonTap(currentLesson, chapter);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    chapter.progress > 0 ? 'متابعة التعلم' : 'بدء الفصل',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyLessonCard(
    LessonModel lesson,
    ChapterModel chapter,
    int index,
  ) {
    final IconData icon = _getLessonIcon(lesson.type);
    final Color iconColor = lesson.isCompleted
        ? const Color(0xFF4CAF50)
        : lesson.isLocked
        ? const Color(0xFFE6E6E6)
        : const Color(0xFF2F98D7);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: lesson.isCurrent
            ? const Color(0xFF2F98D7).withOpacity(0.05)
            : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: lesson.isCurrent
              ? const Color(0xFF2F98D7)
              : const Color(0xFFE6E6E6),
          width: lesson.isCurrent ? 2 : 1,
        ),
        boxShadow: lesson.isCurrent
            ? [
                BoxShadow(
                  color: const Color(0xFF2F98D7).withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: const Color(0xFF505050).withOpacity(0.05),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          _handleLessonTap(lesson, chapter);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: iconColor.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: lesson.isCompleted
                      ? const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                        )
                      : LinearGradient(
                          colors: [iconColor, iconColor.withOpacity(0.7)],
                        ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lesson.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF505050),
                            ),
                          ),
                        ),
                        if (lesson.isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2F98D7), Color(0xFF73CBFF)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'نشط',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.timer,
                          size: 16,
                          color: Color(0xFF505050),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${lesson.durationMinutes} دقيقة',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF505050),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Color(0xFFFF6B35),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_getXpReward(lesson)} نقطة',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFFF6B35),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getStatusColor(lesson).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getStatusColor(lesson).withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  _getStatusIcon(lesson),
                  color: _getStatusColor(lesson),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getLessonIcon(LessonType type) {
    switch (type) {
      case LessonType.video:
        return Icons.play_circle_filled;
      case LessonType.quiz:
        return Icons.quiz;
      case LessonType.assignment:
        return Icons.assignment_turned_in;
      case LessonType.reading:
        return Icons.menu_book;
    }
  }

  IconData _getStatusIcon(LessonModel lesson) {
    if (lesson.isCompleted) return Icons.check_circle;
    if (lesson.isLocked) return Icons.lock;
    if (lesson.isCurrent) return Icons.play_arrow;
    return Icons.radio_button_unchecked;
  }

  Color _getStatusColor(LessonModel lesson) {
    if (lesson.isCompleted) return const Color(0xFF4CAF50);
    if (lesson.isLocked) return const Color(0xFFE6E6E6);
    if (lesson.isCurrent) return const Color(0xFF2F98D7);
    return const Color(0xFF505050);
  }

  int _getXpReward(LessonModel lesson) {
    switch (lesson.type) {
      case LessonType.video:
        return 50;
      case LessonType.quiz:
        return 100;
      case LessonType.assignment:
        return 150;
      case LessonType.reading:
        return 75;
    }
  }

  // Sample data generator
  SubjectRoadmap _getSampleRoadmapData() {
    return SubjectRoadmap(
      subjectName: 'الرياضيات',
      overallProgress: 45.5,
      chapters: [
        ChapterModel(
          chapterNumber: 1,
          chapterName: 'الجبر الأساسي',
          title: 'أساسيات الجبر',
          description: 'تعلم أساسيات التعبيرات الجبرية والمعادلات',
          chapterColor: const Color(0xFF2F98D7),
          progress: 80.0,
          currentLesson: 2,
          isCompleted: false,
          isLocked: false,
          lessons: [
            LessonModel(
              lessonNumber: 1,
              title: 'مقدمة في المتغيرات',
              type: LessonType.video,
              durationMinutes: 15,
              isCompleted: true,
              isLocked: false,
              isCurrent: false,
            ),
            LessonModel(
              lessonNumber: 2,
              title: 'المعادلات البسيطة',
              type: LessonType.video,
              durationMinutes: 20,
              isCompleted: false,
              isLocked: false,
              isCurrent: true,
            ),
            LessonModel(
              lessonNumber: 3,
              title: 'اختبار تطبيقي',
              type: LessonType.quiz,
              durationMinutes: 10,
              isCompleted: false,
              isLocked: false,
              isCurrent: false,
            ),
          ],
        ),
        ChapterModel(
          chapterNumber: 2,
          chapterName: 'الجبر المتقدم',
          title: 'المفاهيم الجبرية المعقدة',
          description: 'الغوص أعمق في العمليات الجبرية المتقدمة',
          chapterColor: const Color(0xFF73CBFF),
          progress: 0.0,
          currentLesson: 1,
          isCompleted: false,
          isLocked: false,
          lessons: [
            LessonModel(
              lessonNumber: 1,
              title: 'المعادلات التربيعية',
              type: LessonType.video,
              durationMinutes: 25,
              isCompleted: false,
              isLocked: false,
              isCurrent: false,
            ),
            LessonModel(
              lessonNumber: 2,
              title: 'التحليل',
              type: LessonType.reading,
              durationMinutes: 30,
              isCompleted: false,
              isLocked: true,
              isCurrent: false,
            ),
          ],
        ),
      ],
    );
  }
}
