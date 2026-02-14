import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/models/teacher_model.dart';
import '../widgets/course_lesson_card.dart';

class TeacherCourseContentView extends StatefulWidget {
  final TeacherModel? teacher;
  final TeacherCourse? course;

  const TeacherCourseContentView({super.key, this.teacher, this.course});

  @override
  State<TeacherCourseContentView> createState() =>
      _TeacherCourseContentViewState();
}

class _TeacherCourseContentViewState extends State<TeacherCourseContentView> {
  late TeacherModel teacher;
  late TeacherCourse course;
  bool isEnrolled = false; // This should come from user state
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize with widget data if available
    if (widget.teacher != null) {
      teacher = widget.teacher!;
      course = widget.course ?? teacher.courses.first;
      _isInitialized = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get data from arguments if not already initialized
    if (!_isInitialized) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      teacher = args?['teacher'] ?? widget.teacher ?? sampleTeacher;
      course = args?['course'] ?? widget.course ?? teacher.courses.first;
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(title: course.grade),
      body: Column(
        children: [
          // Teacher Info Header
          _buildTeacherHeader(),

          // Price Section
          _buildPriceSection(),

          // Progress Section (only for enrolled students)
          if (isEnrolled) _buildProgressSection(),

          // Course Content Header
          _buildCourseContentHeader(),

          // Lessons List
          Expanded(child: _buildLessonsList()),
        ],
      ),
    );
  }

  Widget _buildTeacherHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          // Teacher Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                teacher.profileImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.person, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Teacher Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacher.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${teacher.studentsEnrolled} Student enrolled in this course',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Course Price:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            course.price,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your English Study',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.emoji_events, color: Colors.amber[700]),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${course.studentProgress.toInt()}% about your Progress',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: course.studentProgress / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildCourseContentHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Course Content:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '${course.totalVideos} Videos',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: course.lessons.length,
      itemBuilder: (context, index) {
        final lesson = course.lessons[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CourseLessonCard(
            lesson: lesson,
            isEnrolled: isEnrolled,
            onTap: () {
              if (lesson.isFree || (isEnrolled && !lesson.isLocked)) {
                // Navigate to video player
                context.showSuccessSnackBar('Playing ${lesson.title}');
              } else if (!isEnrolled) {
                // Show enroll dialog
                _showEnrollDialog();
              } else {
                context.showErrorSnackBar('This lesson is locked');
              }
            },
          ),
        );
      },
    );
  }

  void _showEnrollDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Enroll in Course'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'To access all lessons, you need to enroll in this course.',
                ),
                const SizedBox(height: 16),
                Text(
                  'Course Price: ${course.price}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    isEnrolled = true;
                  });
                  // Navigate to payment
                  context.pushNamed(
                    AppRoutes.paymentView,
                    arguments: {'teacher': teacher, 'course': course},
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Enroll Now'),
              ),
            ],
          ),
    );
  }
}
