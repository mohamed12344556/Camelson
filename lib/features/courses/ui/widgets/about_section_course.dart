import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../data/models/course_section.dart';

class AboutSectionCourse extends StatelessWidget {
  final Course course;

  const AboutSectionCourse({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عرض تفاصيل المحتوى
          Expanded(
            child: ListView.builder(
              itemCount: course.sections.length,
              itemBuilder: (context, sectionIndex) {
                final section = course.sections[sectionIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عنوان القسم
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Section ${section.id} - ${section.title}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${section.totalDurationMinutes} Mins',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // عرض الدروس في كل قسم
                    ...section.lessons.map(
                      (lesson) => _buildLessonItem(lesson),
                    ),
                    if (sectionIndex < course.sections.length - 1)
                      Divider(color: AppColors.lightSecondary, thickness: 1),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonItem(CourseLesson lesson) {
    return Container(
      margin: const EdgeInsets.only(left: 10, bottom: 15),
      child: Row(
        children: [
          // رقم الدرس
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              lesson.id,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // معلومات الدرس
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${lesson.durationMinutes} Mins',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.text.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          // زر تشغيل الفيديو
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow,
              color: AppColors.background,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
