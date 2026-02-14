import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import '../../../../core/widgets/tab_bar_widget.dart';
import '../../data/models/course_model.dart';
import '../widgets/course_card.dart';

class CoursesView extends StatefulWidget {
  const CoursesView({super.key});

  @override
  State<CoursesView> createState() => _CoursesViewState();
}

class _CoursesViewState extends State<CoursesView> {
  final List<CourseModel> allCourses = [
    CourseModel(
      title: 'Story Points',
      subject: 'Arabic',
      instructor: '',
      rating: 3.9,
      studentsCount: 7830,
      progress: '10/31',
      isFree: true,
      image: 'assets/images/arabic.png',
    ),
    CourseModel(
      title: 'Story with practise',
      subject: 'Arabic',
      instructor: 'Mr/Ahmed Sultan',
      rating: 4.2,
      studentsCount: 7830,
      progress: '1',
      isFree: true,
      image: 'assets/images/arabic.png',
    ),
    CourseModel(
      title: 'Story with practise',
      subject: 'Arabic',
      instructor: 'Mr/Ahmed Sultan',
      rating: 4.2,
      studentsCount: 7830,
      progress: '',
      isFree: true,
      image: 'assets/images/arabic.png',
    ),
    CourseModel(
      title: 'Story with practise',
      subject: 'Arabic',
      instructor: 'Mr/Ahmed Sultan',
      rating: 4.2,
      studentsCount: 7830,
      progress: '',
      isFree: true,
      image: 'assets/images/arabic.png',
    ),
    CourseModel(
      title: 'Story with practise',
      subject: 'Arabic',
      instructor: 'Mr/Ahmed Sultan',
      rating: 4.2,
      studentsCount: 7830,
      progress: '',
      isFree: false,
      image: 'assets/images/arabic.png',
    ),
  ];

  int _currentTabIndex = 0; // Default tab
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

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
    return Scaffold(
      appBar: CustomAppBar(title: 'Courses'),
      backgroundColor: Colors.grey[50],
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
                    title: 'All',
                    isSelected: _currentTabIndex == 0,
                    onTap: _updateTabIndex,
                  ),
                  const SizedBox(width: 12),
                  TabBarWidget(
                    index: 1,
                    title: 'Paid',
                    isSelected: _currentTabIndex == 1,
                    onTap: _updateTabIndex,
                  ),
                  const SizedBox(width: 12),
                  TabBarWidget(
                    index: 2,
                    title: 'For Free',
                    isSelected: _currentTabIndex == 2,
                    onTap: _updateTabIndex,
                  ),
                ],
              ),
            ),
            // Display search results count when searching
            if (_searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Found ${filteredCourses.length} results for "$_searchQuery"',
                  style: const TextStyle(
                    color: Colors.black54,
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
                        ? const Center(
                          child: Text(
                            'No courses found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
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
