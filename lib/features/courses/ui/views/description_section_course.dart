import 'package:flutter/material.dart';

import '../../data/models/course_section.dart';

class DescriptionSectionCourse extends StatefulWidget {
  final Course course;
  const DescriptionSectionCourse({super.key, required this.course});

  @override
  State<DescriptionSectionCourse> createState() =>
      _DescriptionSectionCourseState();
}

class _DescriptionSectionCourseState extends State<DescriptionSectionCourse> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // وصف الدورة مع إمكانية توسيع النص
          LayoutBuilder(
            builder: (context, constraints) {
              // الحصول على وصف الدورة من النموذج
              String description = widget.course.description;

              // إذا لم يكن هناك وصف، نستخدم نصًا وهميًا للعرض
              if (description.isEmpty) {
                description = "الراجل مكتبش وصف اعمل انا ايه 😑";
              }

              // إنشاء TextPainter لحساب حجم النص
              final TextSpan textSpan = TextSpan(
                text: description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              );

              final TextPainter textPainter = TextPainter(
                text: textSpan,
                maxLines: _expanded ? null : 3,
                textDirection: TextDirection.ltr,
              )..layout(maxWidth: constraints.maxWidth);

              // التحقق مما إذا كان النص يتجاوز 3 أسطر
              final bool isTextOverflow = textPainter.didExceedMaxLines;

              // عرض النص كاملاً أو مختصراً حسب حالة التوسيع
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    maxLines: _expanded ? null : 3,
                    overflow: _expanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                  ),

                  // إظهار زر "Read More" فقط إذا كان النص طويلاً
                  if (isTextOverflow || _expanded)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _expanded = !_expanded;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _expanded ? "Read Less" : "Read More",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
