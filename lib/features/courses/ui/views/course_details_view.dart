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
  const CourseDetailsView({super.key});

  @override
  State<CourseDetailsView> createState() => _CourseDetailsViewState();
}

class _CourseDetailsViewState extends State<CourseDetailsView> {
  final course = Course.fromJson(graphicDesignCourseData);

  final ScrollController _scrollController = ScrollController();
  double _thumbnailHeight = 0;
  double _videoButtonPosition = 240;
  bool _isVideoButtonVisible = true;

  @override
  void initState() {
    super.initState();
    _thumbnailHeight = 0.30; // Initial height percentage

    // Add scroll listener for animations
    _scrollController.addListener(_scrollListener);
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
        backgroundColor: Colors.black,
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
                  color: Colors.black,
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
                InstructorCourseSection(),
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
