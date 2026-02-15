import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import '../../data/models/course_model.dart';
import '../widgets/course_card.dart';

class CoursesView extends StatefulWidget {
  final String? selectedYear;

  const CoursesView({super.key, this.selectedYear});

  @override
  State<CoursesView> createState() => _CoursesViewState();
}

class _CoursesViewState extends State<CoursesView> {
  final List<CourseModel> allCourses = [
    CourseModel(
      title: 'Human Anatomy',
      subject: 'First Year',
      instructor: 'Dr. Sarah Ahmed',
      rating: 4.8,
      studentsCount: 12450,
      progress: '15/40',
      isFree: true,
      image: 'assets/images/learning.png',
    ),
    CourseModel(
      title: 'Physiology Fundamentals',
      subject: 'First Year',
      instructor: 'Dr. Mohamed Hassan',
      rating: 4.7,
      studentsCount: 11230,
      progress: '8/35',
      isFree: true,
      image: 'assets/images/learning.png',
    ),
    CourseModel(
      title: 'Biochemistry Essentials',
      subject: 'Second Year',
      instructor: 'Dr. Fatima Ali',
      rating: 4.6,
      studentsCount: 10890,
      progress: '20/45',
      isFree: false,
      image: 'assets/images/learning.png',
    ),
    CourseModel(
      title: 'Pathology Principles',
      subject: 'Third Year',
      instructor: 'Dr. Ahmed Mahmoud',
      rating: 4.9,
      studentsCount: 9876,
      progress: '12/38',
      isFree: true,
      image: 'assets/images/learning.png',
    ),
    CourseModel(
      title: 'Clinical Medicine',
      subject: 'Fourth Year',
      instructor: 'Dr. Layla Ibrahim',
      rating: 4.8,
      studentsCount: 8765,
      progress: '5/30',
      isFree: false,
      image: 'assets/images/learning.png',
    ),
    CourseModel(
      title: 'Pharmacology Mastery',
      subject: 'Third Year',
      instructor: 'Dr. Youssef Kamal',
      rating: 4.7,
      studentsCount: 9234,
      progress: '',
      isFree: true,
      image: 'assets/images/learning.png',
    ),
    CourseModel(
      title: 'Surgery Fundamentals',
      subject: 'Fifth Year',
      instructor: 'Dr. Nour Eldin',
      rating: 4.9,
      studentsCount: 7890,
      progress: '3/25',
      isFree: false,
      image: 'assets/images/learning.png',
    ),
    CourseModel(
      title: 'Pediatrics Essentials',
      subject: 'Sixth Year',
      instructor: 'Dr. Hoda Salah',
      rating: 4.8,
      studentsCount: 6543,
      progress: '',
      isFree: true,
      image: 'assets/images/learning.png',
    ),
  ];

  int _currentTabIndex = 0; // Default tab
  String _searchQuery = '';
  String? _yearFilter;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _yearFilter = widget.selectedYear;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Method to update current tab index
  void _updateTabIndex(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  List<CourseModel> get filteredCourses {
    List<CourseModel> result = [];

    // First filter by tab
    switch (_currentTabIndex) {
      case 0: // All
        result = List.from(allCourses);
        break;
      case 1: // Paid
        result = allCourses.where((course) => !course.isFree).toList();
        break;
      case 2: // For Free
        result = allCourses.where((course) => course.isFree).toList();
        break;
    }

    // Filter by year if selected
    if (_yearFilter != null && _yearFilter != 'All' && _yearFilter != 'الكل' && _yearFilter!.isNotEmpty) {
      result = result.where((course) {
        // Map Arabic to English year names for comparison
        final yearMap = {
          'السنة الأولى': 'First Year',
          'السنة الثانية': 'Second Year',
          'السنة الثالثة': 'Third Year',
          'السنة الرابعة': 'Fourth Year',
          'السنة الخامسة': 'Fifth Year',
          'السنة السادسة': 'Sixth Year',
        };

        final englishYear = yearMap[_yearFilter] ?? _yearFilter;
        return course.subject == englishYear || course.subject == _yearFilter;
      }).toList();
    }

    // Then filter by search query if any
    if (_searchQuery.isNotEmpty) {
      result =
          result
              .where(
                (course) =>
                    course.title.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    course.instructor.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = false;
    final isArabic = context.isArabic;

    return Scaffold(
      appBar: CustomAppBar(title: isArabic ? 'الكورسات' : 'Courses'),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            //? Search Bar
            CustomSearchBar(
              searchController: _searchController,
              onClearPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                });
              },
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            //? Tab bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  TabBarWidget(
                    index: 0,
                    title: isArabic ? 'الكل' : 'All',
                    isSelected: _currentTabIndex == 0,
                    onTap: _updateTabIndex,
                  ),
                  const SizedBox(width: 12),
                  TabBarWidget(
                    index: 1,
                    title: isArabic ? 'مدفوعة' : 'Paid',
                    isSelected: _currentTabIndex == 1,
                    onTap: _updateTabIndex,
                  ),
                  const SizedBox(width: 12),
                  TabBarWidget(
                    index: 2,
                    title: isArabic ? 'مجانية' : 'For Free',
                    isSelected: _currentTabIndex == 2,
                    onTap: _updateTabIndex,
                  ),
                ],
              ),
            ),
            // Display year filter if selected
            if (_yearFilter != null && _yearFilter != 'All' && _yearFilter!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      isArabic ? 'السنة المختارة: ' : 'Selected Year: ',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Chip(
                      label: Text(
                        _yearFilter!,
                        style: const TextStyle(
                          color: AppColors.background,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: const Color(0xff73CBFF),
                      deleteIcon: const Icon(
                        Icons.close,
                        size: 16,
                        color: AppColors.background,
                      ),
                      onDeleted: () {
                        setState(() {
                          _yearFilter = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            // Display search results count when searching
            if (_searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  isArabic
                      ? 'تم العثور على ${filteredCourses.length} نتيجة لـ "$_searchQuery"'
                      : 'Found ${filteredCourses.length} results for "$_searchQuery"',
                  style: TextStyle(
                    color: AppColors.text.withValues(alpha: 0.54),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            //? Course list
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  // Simulate a network call or data refresh
                  await Future.delayed(const Duration(seconds: 1));
                  setState(() {
                    // Update the state if needed
                  });
                },
                child:
                    filteredCourses.isEmpty
                        ? Center(
                          child: Text(
                            isArabic ? 'لا توجد كورسات' : 'No courses found',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.text.withValues(alpha: 0.54),
                            ),
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredCourses.length,
                          itemBuilder: (context, index) {
                            return Skeletonizer(
                              enabled: isLoading,
                              child: CourseCard(course: filteredCourses[index]),
                            );
                          },
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
