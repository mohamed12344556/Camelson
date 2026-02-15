import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../data/models/course_model.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;

  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.text.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Navigate to course details
          context.pushNamed(
            AppRoutes.courseDetailsView,
            arguments: {'courseData': course.toJson()},
          );
          context.showSuccessSnackBar('Opening ${course.title}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Course image (black box in your design)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.asset(
                course.image,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),

            // Course info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.subject,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Course title
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),

                    // Instructor (if available)
                    if (course.instructor.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          course.instructor,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                      ),

                    const SizedBox(height: 8),

                    // Rating and student count
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.accent, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          course.rating.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '|',
                          style: TextStyle(color: AppColors.text.withValues(alpha: 0.6), fontSize: 16),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${course.studentsCount} Std',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.text.withValues(alpha: 0.6),
                          ),
                        ),

                        // Progress indicator (if available)
                        if (course.progress.isNotEmpty)
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  course.progress,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.text.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    // Progress bar (only for first item)
                    if (course.progress.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value:
                                course.progress.length /
                                100, // Estimate from image
                            backgroundColor: AppColors.lightSecondary,
                            color: AppColors.accent,
                            minHeight: 6,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
