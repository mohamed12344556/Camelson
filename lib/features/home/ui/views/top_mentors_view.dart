import 'dart:ui';

import 'package:camelson/features/courses/data/models/teacher_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_search_bar.dart';

class TopMentorsView extends StatefulWidget {
  const TopMentorsView({super.key});

  @override
  State<TopMentorsView> createState() => _TopMentorsViewState();
}

class _TopMentorsViewState extends State<TopMentorsView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSubject = 'All';
  String _selectedSort = 'Highest Rated';

  final List<String> _subjects = [
    'All',
    'Math',
    'Physics',
    'English',
    'Arabic',
    'Chemistry',
    'Biology',
  ];
  final List<String> _sortOptions = [
    'Highest Rated',
    'Most Students',
    'Newest',
    'Most Experienced',
  ];

  // Sample mentors data
  final List<TeacherModel> _allMentors = [
    TeacherModel(
      id: '1',
      name: 'Dr. Ahmed Hassan',
      subject: 'Physics Teacher',
      profileImage: 'assets/images/person2.png',
      studentsEnrolled: 1250,
      rating: 4.9,
      description:
          'Experienced physics teacher with 15+ years of teaching advanced physics concepts to secondary students.',
      grades: ['1 Secondary', '2 Secondary', '3 Secondary'],
      courses: [],
      reviews: [],
      yearsOfExperience: 15,
      verified: true,
    ),
    TeacherModel(
      id: '2',
      name: 'Sarah Johnson',
      subject: 'English Teacher',
      profileImage: 'assets/images/person2.png',
      studentsEnrolled: 890,
      rating: 4.8,
      description:
          'Native English speaker specializing in grammar, literature, and conversation skills.',
      grades: ['1 Secondary', '2 Secondary', '3 Secondary'],
      courses: [],
      reviews: [],
      yearsOfExperience: 10,
      verified: true,
    ),
    TeacherModel(
      id: '3',
      name: 'محمد عبدالله',
      subject: 'Arabic Teacher',
      profileImage: 'assets/images/person2.png',
      studentsEnrolled: 2100,
      rating: 4.95,
      description:
          'متخصص في تدريس اللغة العربية والأدب العربي لجميع المراحل الدراسية.',
      grades: ['1 Secondary', '2 Secondary', '3 Secondary'],
      courses: [],
      reviews: [],
      yearsOfExperience: 20,
      verified: true,
    ),
    TeacherModel(
      id: '4',
      name: 'Dr. Emma Wilson',
      subject: 'Chemistry Teacher',
      profileImage: 'assets/images/person2.png',
      studentsEnrolled: 756,
      rating: 4.7,
      description:
          'PhD in Chemistry with passion for making complex concepts easy to understand.',
      grades: ['2 Secondary', '3 Secondary'],
      courses: [],
      reviews: [],
      yearsOfExperience: 8,
      verified: true,
    ),
    TeacherModel(
      id: '5',
      name: 'Michael Chen',
      subject: 'Math Teacher',
      profileImage: 'assets/images/person2.png',
      studentsEnrolled: 1890,
      rating: 4.85,
      description:
          'Mathematics expert specializing in calculus, algebra, and problem-solving techniques.',
      grades: ['1 Secondary', '2 Secondary', '3 Secondary'],
      courses: [],
      reviews: [],
      yearsOfExperience: 12,
      verified: false,
    ),
    TeacherModel(
      id: '6',
      name: 'فاطمة الزهراء',
      subject: 'Biology Teacher',
      profileImage: 'assets/images/person2.png',
      studentsEnrolled: 567,
      rating: 4.6,
      description: 'متخصصة في علم الأحياء مع خبرة في تدريس المناهج المتقدمة.',
      grades: ['2 Secondary', '3 Secondary'],
      courses: [],
      reviews: [],
      yearsOfExperience: 6,
      verified: true,
    ),
  ];

  List<TeacherModel> _filteredMentors = [];

  @override
  void initState() {
    super.initState();
    _filteredMentors = List.from(_allMentors);
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _filteredMentors = _allMentors.where((mentor) {
        // Search filter
        final searchQuery = _searchController.text.toLowerCase();
        final matchesSearch =
            searchQuery.isEmpty ||
            mentor.name.toLowerCase().contains(searchQuery) ||
            mentor.subject.toLowerCase().contains(searchQuery);

        // Subject filter
        final matchesSubject =
            _selectedSubject == 'All' ||
            mentor.subject.toLowerCase().contains(
              _selectedSubject.toLowerCase(),
            );

        return matchesSearch && matchesSubject;
      }).toList();

      // Apply sorting
      _applySorting();
    });
  }

  void _applySorting() {
    switch (_selectedSort) {
      case 'Highest Rated':
        _filteredMentors.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Most Students':
        _filteredMentors.sort(
          (a, b) => b.studentsEnrolled.compareTo(a.studentsEnrolled),
        );
        break;
      case 'Newest':
        _filteredMentors = _filteredMentors.reversed.toList();
        break;
      case 'Most Experienced':
        _filteredMentors.sort(
          (a, b) =>
              (b.yearsOfExperience ?? 0).compareTo(a.yearsOfExperience ?? 0),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: 'Top Mentors',
        onBackPressed: () {
          context.setNavBarVisible(true);
          Navigator.pop(context);
        },
      ),
      body: Column(
        children: [
          // Search Bar
          CustomSearchBar(searchController: _searchController),

          // Filters
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                // Subject Filter Dropdown
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedSubject,
                      isExpanded: true,
                      underline: const SizedBox(),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.primary,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedSubject = value!;
                          _applyFilters();
                        });
                      },
                      items: _subjects.map((subject) {
                        return DropdownMenuItem(
                          value: subject,
                          child: Text(subject),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Sort Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: PopupMenuButton<String>(
                    initialValue: _selectedSort,
                    onSelected: (value) {
                      setState(() {
                        _selectedSort = value;
                        _applyFilters();
                      });
                    },
                    itemBuilder: (context) => _sortOptions
                        .map(
                          (option) =>
                              PopupMenuItem(value: option, child: Text(option)),
                        )
                        .toList(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 12.h,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.sort,
                            size: 20.sp,
                            color: Colors.grey[700],
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Sort',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Mentors List
          Expanded(
            child: _filteredMentors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search,
                          size: 80.sp,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No mentors found',
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: _filteredMentors.length,
                    itemBuilder: (context, index) {
                      return _buildMentorCard(_filteredMentors[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentorCard(TeacherModel mentor) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(AppRoutes.teacherProfile, arguments: mentor);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.8),
                  ],
                ),
              ),
              child: Row(
                children: [
                  // Profile Image with Glassmorphic effect
                  Stack(
                    children: [
                      Container(
                        width: 80.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary.withOpacity(0.1),
                              AppColors.primary.withOpacity(0.05),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: CircleAvatar(
                            radius: 37.r,
                            backgroundImage: AssetImage(mentor.profileImage),
                          ),
                        ),
                      ),
                      // Verified Badge
                      if (mentor.verified ?? false)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 24.w,
                            height: 24.h,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.w,
                              ),
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14.sp,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 16.w),
                  // Mentor Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name and Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                mentor.name,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF202244),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16.sp,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    mentor.rating.toString(),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF202244),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        // Subject
                        Text(
                          mentor.subject,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        // Stats Row
                        Row(
                          children: [
                            // Students Count
                            _buildStatChip(
                              icon: Icons.people,
                              value: '${mentor.studentsEnrolled}',
                              label: 'Students',
                            ),
                            SizedBox(width: 12.w),
                            // Experience
                            if (mentor.yearsOfExperience != null)
                              _buildStatChip(
                                icon: Icons.work_history,
                                value: '${mentor.yearsOfExperience}y',
                                label: 'Experience',
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Arrow Icon
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: AppColors.primary),
          SizedBox(width: 4.w),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF202244),
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            label,
            style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
