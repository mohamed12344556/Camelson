import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/models/course_section.dart';
import '../widgets/build_actions_icons.dart';
import '../widgets/course_detail_section.dart';
import '../widgets/elevated_button_for_video_player.dart';
import '../widgets/instructor_course_section.dart';
import '../widgets/reviews_course_section.dart';

class CourseDetailsView extends StatefulWidget {
  final Map<String, dynamic>? courseData;

  const CourseDetailsView({super.key, this.courseData});

  @override
  State<CourseDetailsView> createState() => _CourseDetailsViewState();
}

class _CourseDetailsViewState extends State<CourseDetailsView> {
  late final Course course;

  final ScrollController _scrollController = ScrollController();
  double _thumbnailHeight = 0;
  double _videoButtonPosition = 240;
  bool _isVideoButtonVisible = true;

  @override
  void initState() {
    super.initState();
    // Use provided courseData or fallback to default data
    if (widget.courseData != null) {
      // Convert library data to course format
      try {
        final courseData = _convertLibraryDataToCourseData(widget.courseData!);
        course = Course.fromJson(courseData);
      } catch (e) {
        // If conversion fails, use default data
        course = Course.fromJson(graphicDesignCourseData);
      }
    } else {
      course = Course.fromJson(graphicDesignCourseData);
    }

    _thumbnailHeight = 0.30; // Initial height percentage

    // Add scroll listener for animations
    _scrollController.addListener(_scrollListener);
  }

  // Convert library card data to course format
  Map<String, dynamic> _convertLibraryDataToCourseData(
    Map<String, dynamic> libraryData,
  ) {
    return {
      'id': libraryData['title'] ?? 'unknown',
      'title': libraryData['title'] ?? 'Unknown Course',
      'subject': libraryData['year'] ?? 'Medical',
      'description': libraryData['description'] ?? '',
      'instructor': 'Dr. Ahmed Hassan', // Default instructor
      'rating': 4.8,
      'thumbnailUrl': libraryData['image'] ?? 'assets/images/learning.png',
      'price': (libraryData['price'] ?? 0).toDouble(),
      'sections': [
        {
          'id': '01',
          'title': 'Introduction',
          'totalDurationMinutes': 90,
          'lessons': [
            {
              'id': '01',
              'title': 'Getting Started',
              'durationMinutes': 45,
              'isCompleted': false,
              'videoUrl': 'assets/videos/intro.mp4',
            },
            {
              'id': '02',
              'title': 'Course Overview',
              'durationMinutes': 45,
              'isCompleted': false,
              'videoUrl': 'assets/videos/overview.mp4',
            },
          ],
        },
      ],
    };
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // Scroll listener function for animations
  void _scrollListener() {
    final double offset = _scrollController.offset;
    final double maxOffset = 150; // Maximum offset for animation

    setState(() {
      // Animate thumbnail height
      if (offset <= maxOffset) {
        // Gradually reduce the height as you scroll
        _thumbnailHeight = 0.30 - (offset / maxOffset * 0.15);
        if (_thumbnailHeight < 0.15) _thumbnailHeight = 0.15;
      }

      // Animate video button position
      _videoButtonPosition = 240 - offset;
      if (_videoButtonPosition < 100) _videoButtonPosition = 100;

      // Hide video button when scrolled too far
      _isVideoButtonVisible = offset < 300;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        backgroundColor: AppColors.text,
        actions: [
          BuildActionsIcons(
            iconPath: 'assets/svgs/favoret.svg',
            onTap: () {
              // Handle favorite icon tap
            },
          ),
          BuildActionsIcons(
            iconPath: 'assets/svgs/Cart.svg',
            hasBadge: true,
            onTap: () {
              // Handle cart icon tap
            },
          ),
          BuildActionsIcons(
            iconPath: 'assets/svgs/shareIcon.svg',
            onTap: () {
              // Handle share icon tap
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                //? Thumbnail Section
                // قسم الصورة المصغرة للكورس
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  color: AppColors.text,
                  height: MediaQuery.of(context).size.height * _thumbnailHeight,
                  child: Stack(
                    children: [
                      // صورة الكورس
                      Image.asset(
                        course.thumbnailUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
                //? Details Section
                CourseDetailSection(course: course),
                //? Instructor Section
                InstructorCourseSection(course: course),
                //? Reviews Section
                ReviewsCourseSection(),
                //? Enroll Course Button Section
                CustomButton(
                  text: 'Enroll Course',
                  width: MediaQuery.of(context).size.width * 0.8,
                  onPressed: () {
                    // Navigate to Subject Roadmap instead of payment
                    context.pushNamed(
                      AppRoutes.subjectRoadmapView,
                      arguments: {
                        'courseTitle': course.title,
                        'courseId': course.id,
                      },
                    );
                  },
                ),
                SizedBox(height: 24),
              ],
            ),
            //? Instructor Video Player Button Section
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              top: _videoButtonPosition,
              right: 15,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isVideoButtonVisible ? 1.0 : 0.0,
                child: ElevatedButtonForVideoPlayer(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
