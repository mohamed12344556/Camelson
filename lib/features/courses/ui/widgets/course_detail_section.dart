import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../data/models/course_section.dart';
import '../views/description_section_course.dart';
import 'about_section_course.dart';

class CourseDetailSection extends StatefulWidget {
  final Course course;
  const CourseDetailSection({super.key, required this.course});

  @override
  State<CourseDetailSection> createState() => _CourseDetailSectionState();
}

class _CourseDetailSectionState extends State<CourseDetailSection> {
  int _currentTabIndex = 0;
  // Method to update current tab index
  void _updateTabIndex(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            //? Course Subject and Rate Section
            Row(
              children: [
                Text(
                  "Arabic",
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                const Spacer(),
                // Rate Section
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.yellow,
                    ),
                    Text(
                      "4.5",
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            //? Course Title Section
            Text(
              "Story Details Revision",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            //? Course Number of Lessons && Hours and Price Section
            Row(
              children: [
                Icon(
                  Icons.photo_camera_front,
                ),
                SizedBox(width: 10),
                Text(
                  "21 Lessons",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 20),
                Row(
                  children: [
                    Icon(
                      Icons.punch_clock_outlined,
                      color: Colors.black,
                    ),
                    Text(
                      "42 hours",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Text(
                  "12 \$",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            //? Tabs Section
            Row(
              children: [
                TabBarWidget(
                  index: 0,
                  title: 'About',
                  radius: 0,
                  // wannaChangeColorOfTabText: false,
                  // fillColor: Color(0xffB4E6FF),
                  isSelected: _currentTabIndex == 0,
                  onTap: _updateTabIndex,
                ),
                TabBarWidget(
                  index: 1,
                  title: 'Description',
                  radius: 0,
                  // wannaChangeColorOfTabText: false,
                  // fillColor: Color(0xffB4E6FF),
                  isSelected: _currentTabIndex == 1,
                  onTap: _updateTabIndex,
                ),
              ],
            ),
            //? Tabs Content Section
            Expanded(
              child: IndexedStack(
                index: _currentTabIndex,
                children: [
                  AboutSectionCourse(course: widget.course),
                  DescriptionSectionCourse(course: widget.course),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}