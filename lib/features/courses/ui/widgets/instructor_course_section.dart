import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../data/models/teacher_model.dart';

class InstructorCourseSection extends StatelessWidget {
  final String instructorName;
  final String subject;
  final String? instructorImage;

  const InstructorCourseSection({
    super.key,
    this.instructorName = "Ahmed Ali",
    this.subject = "Arabic",
    this.instructorImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Instructor",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          InkWell(
            onTap: () {
              // Navigate to Teacher Profile
              // Create a sample teacher model for navigation
              final teacher = TeacherModel(
                id: 'teacher_1',
                name: instructorName,
                subject: '$subject Teacher',
                profileImage: instructorImage ?? 'assets/images/teacher.png',
                studentsEnrolled: 40,
                rating: 4.9,
                description: 'Lorem ipsum dolor sit amet consectetur...',
                grades: ['1 Secondary', '2 Secondary', '3 Secondary'],
                courses: [], // Will be populated from backend
                reviews: [], // Will be populated from backend
              );

              context.pushNamed(AppRoutes.teacherProfile, arguments: teacher);
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
                      color: Colors.black,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(
                          instructorImage ?? 'assets/images/teacher.png',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        instructorName,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        subject,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Icon(Icons.chat_outlined, color: Colors.black),
                ],
              ),
            ),
          ),
          Divider(color: Colors.grey[300], thickness: 1),
          Text(
            "What you'll Get",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: ListView.builder(
              itemCount: 6,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Row(
                    spacing: 10,
                    children: [
                      Icon(Icons.check, color: Colors.green),
                      Text(
                        "Learn Storytelling",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
