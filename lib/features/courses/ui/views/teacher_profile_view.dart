import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/models/teacher_model.dart';
import '../widgets/teacher_review_card.dart';

class TeacherProfileView extends StatefulWidget {
  final TeacherModel? teacher;

  const TeacherProfileView({super.key, this.teacher});

  @override
  State<TeacherProfileView> createState() => _TeacherProfileViewState();
}

class _TeacherProfileViewState extends State<TeacherProfileView> {
  late final TeacherModel teacher;

  @override
  void initState() {
    super.initState();
    // Use passed teacher or sample data
    teacher = widget.teacher ?? sampleTeacher;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CustomAppBar(title: 'Profile'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teacher Info Section
            _buildTeacherInfoSection(),

            // Grades Cards Section
            _buildGradesSection(),

            // Description Section
            _buildDescriptionSection(),

            // Reviews Section
            _buildReviewsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Teacher Name
          Text(
            teacher.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF202244),
            ),
          ),
          const SizedBox(height: 8),

          // Subject
          Text(
            teacher.subject,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),

          // Students enrolled
          Text(
            '${teacher.studentsEnrolled} Student enrolled',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 12),

          // Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                teacher.rating.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Teacher Avatar with Badge
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!, width: 3),
                ),
                child: ClipOval(
                  child: Image.asset(
                    teacher.profileImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Badge "A"
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Center(
                    child: Text(
                      'A',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGradesSection() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: teacher.grades.length,
        itemBuilder: (context, index) {
          return _buildGradeCard(teacher.grades[index]);
        },
      ),
    );
  }

  Widget _buildGradeCard(String grade) {
    // Extract the number from grade (e.g., "3 Secondary" -> "3")
    final gradeNumber = grade.split(' ').first;

    return GestureDetector(
      onTap: () {
        // Navigate to course content for this grade
        final course = teacher.courses.firstWhere(
          (c) => c.grade == grade,
          orElse: () => teacher.courses.first,
        );
        context.pushNamed(
          AppRoutes.teacherCourseContent,
          arguments: {'teacher': teacher, 'course': course},
        );
      },
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF167F71),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              gradeNumber,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'SECONDARY',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.8),
                letterSpacing: 0.3,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF202244),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            teacher.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reviews:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF202244),
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: teacher.reviews.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return TeacherReviewCard(review: teacher.reviews[index]);
            },
          ),
        ],
      ),
    );
  }
}
