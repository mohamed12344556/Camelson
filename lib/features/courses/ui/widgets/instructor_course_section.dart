import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../data/models/course_section.dart';
import '../../data/models/teacher_model.dart';

class InstructorCourseSection extends StatelessWidget {
  final Course? course;

  InstructorCourseSection({
    super.key,
    this.course,
  });

  // Medical course benefits
  static final List<String> _courseBenefits = [
    'Master anatomical structures and terminology',
    'Understand body systems and their functions',
    'Learn clinical correlations for medical practice',
    'Access high-quality video lectures',
    'Study with detailed illustrations and diagrams',
    'Prepare effectively for medical exams',
  ];

  @override
  Widget build(BuildContext context) {
    final instructorName = course?.instructor ?? 'Prof. Ahmed Hassan';
    final subject = course?.subject ?? 'Anatomy';

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Instructor",
            style: TextStyle(
              color: AppColors.text,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          InkWell(
            onTap: () {
              // Navigate to Teacher Profile
              // Use sample teacher data
              context.pushNamed(AppRoutes.teacherProfile, arguments: sampleTeacher);
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.lightSecondary,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/person2.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          instructorName,
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 5),
                        Text(
                          '$subject Professor',
                          style: TextStyle(
                            color: AppColors.text.withValues(alpha: 0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: AppColors.text.withValues(alpha: 0.6), size: 18),
                ],
              ),
            ),
          ),
          Divider(color: AppColors.lightSecondary, thickness: 1),
          Text(
            "What you'll Get",
            style: TextStyle(
              color: AppColors.text,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: ListView.builder(
              itemCount: _courseBenefits.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 2),
                        child: Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _courseBenefits[index],
                          style: TextStyle(
                            color: AppColors.text.withValues(alpha: 0.87),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
