import 'package:simplify/features/home/ui/widgets/custom_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_search_bar.dart';

class StreamingNowView extends StatefulWidget {
  const StreamingNowView({super.key});

  @override
  State<StreamingNowView> createState() => _StreamingNowViewState();
}

class _StreamingNowViewState extends State<StreamingNowView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _selectedSort = 'Most Popular';

  final List<String> _filters = [
    'All',
    'Live',
    'Recorded',
    'Math',
    'Physics',
    'English',
    'Arabic',
  ];
  final List<String> _sortOptions = [
    'Most Popular',
    'Newest First',
    'Duration',
    'Most Viewers',
  ];

  // Sample streaming data
  final List<Map<String, dynamic>> _allStreamingData = [
    {
      'title': 'Master JavaScript in 30 Days',
      'instructor': 'Sarah Johnson',
      'avatar': 'assets/images/person2.png',
      'duration': '02:15:30',
      'image': 'assets/images/teacher_streaming.jpg',
      'isLive': true,
      'viewers': 1250,
      'rating': 4.8,
      'subject': 'Programming',
      'level': 'Intermediate',
    },
    {
      'title': 'Advanced Flutter Development',
      'instructor': 'Ahmed Hassan',
      'avatar': 'assets/images/person2.png',
      'duration': '01:45:20',
      'image': 'assets/images/teacher_streaming.jpg',
      'isLive': true,
      'viewers': 890,
      'rating': 4.9,
      'subject': 'Programming',
      'level': 'Advanced',
    },
    {
      'title': 'UI/UX Design Fundamentals',
      'instructor': 'Emma Wilson',
      'avatar': 'assets/images/person2.png',
      'duration': '03:22:10',
      'image': 'assets/images/teacher_streaming.jpg',
      'isLive': false,
      'viewers': 2340,
      'rating': 4.7,
      'subject': 'Design',
      'level': 'Beginner',
    },
    {
      'title': 'Python for Data Science',
      'instructor': 'Michael Chen',
      'avatar': 'assets/images/person2.png',
      'duration': '02:08:45',
      'image': 'assets/images/teacher_streaming.jpg',
      'isLive': true,
      'viewers': 567,
      'rating': 4.6,
      'subject': 'Programming',
      'level': 'Intermediate',
    },
    {
      'title': 'Digital Marketing Strategy',
      'instructor': 'Lisa Garcia',
      'avatar': 'assets/images/person2.png',
      'duration': '01:55:15',
      'image': 'assets/images/teacher_streaming.jpg',
      'isLive': false,
      'viewers': 3210,
      'rating': 4.5,
      'subject': 'Marketing',
      'level': 'Beginner',
    },
    // Add more items for demonstration
    {
      'title': 'Physics for Engineers',
      'instructor': 'Dr. Ahmed Ali',
      'avatar': 'assets/images/person2.png',
      'duration': '02:30:00',
      'image': 'assets/images/teacher_streaming.jpg',
      'isLive': true,
      'viewers': 445,
      'rating': 4.9,
      'subject': 'Physics',
      'level': 'Advanced',
    },
    {
      'title': 'English Grammar Mastery',
      'instructor': 'Jennifer Smith',
      'avatar': 'assets/images/person2.png',
      'duration': '01:20:30',
      'image': 'assets/images/teacher_streaming.jpg',
      'isLive': false,
      'viewers': 1890,
      'rating': 4.7,
      'subject': 'English',
      'level': 'Intermediate',
    },
    {
      'title': 'Arabic Literature',
      'instructor': 'محمد عبدالله',
      'avatar': 'assets/images/person2.png',
      'duration': '02:00:00',
      'image': 'assets/images/teacher_streaming.jpg',
      'isLive': true,
      'viewers': 756,
      'rating': 4.8,
      'subject': 'Arabic',
      'level': 'Advanced',
    },
  ];

  List<Map<String, dynamic>> _filteredData = [];

  @override
  void initState() {
    super.initState();
    _filteredData = List.from(_allStreamingData);
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _filteredData = _allStreamingData.where((course) {
        // Search filter
        final searchQuery = _searchController.text.toLowerCase();
        final matchesSearch =
            searchQuery.isEmpty ||
            course['title'].toString().toLowerCase().contains(searchQuery) ||
            course['instructor'].toString().toLowerCase().contains(searchQuery);

        // Category filter
        final matchesFilter =
            _selectedFilter == 'All' ||
            (_selectedFilter == 'Live' && course['isLive']) ||
            (_selectedFilter == 'Recorded' && !course['isLive']) ||
            course['subject'] == _selectedFilter;

        return matchesSearch && matchesFilter;
      }).toList();

      // Apply sorting
      _applySorting();
    });
  }

  void _applySorting() {
    switch (_selectedSort) {
      case 'Most Popular':
        _filteredData.sort((a, b) => b['viewers'].compareTo(a['viewers']));
        break;
      case 'Newest First':
        // In real app, you'd sort by date
        _filteredData = _filteredData.reversed.toList();
        break;
      case 'Duration':
        _filteredData.sort((a, b) => a['duration'].compareTo(b['duration']));
        break;
      case 'Most Viewers':
        _filteredData.sort((a, b) => b['viewers'].compareTo(a['viewers']));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: 'Streaming Now',
        onBackPressed: () {
          context.setNavBarVisible(true);
          Navigator.pop(context);
        },
      ),
      body: Column(
        children: [
          // Search Bar
          CustomSearchBar(searchController: _searchController),

          // Filters and Sort
          Container(
            height: 50.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                // Filter Chips
                Expanded(
                  child: CustomChips(
                    labels: _filters,
                    initialSelectedIndex: _filters.indexOf(_selectedFilter),
                    onSelected: (index) {
                      setState(() {
                        _selectedFilter = _filters[index];
                        _applyFilters();
                      });
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                // Sort Button
                _buildSortButton(),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Streaming Grid
          Expanded(
            child: _filteredData.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          // Icons.live_tv_off,
                          Icons.live_tv_outlined,
                          size: 80.sp,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No streams found',
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(16.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                    ),
                    itemCount: _filteredData.length,
                    itemBuilder: (context, index) {
                      return _buildStreamCard(_filteredData[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton() {
    return Container(
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
            .map((option) => PopupMenuItem(value: option, child: Text(option)))
            .toList(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            children: [
              Icon(Icons.sort, size: 20.sp, color: Colors.grey[700]),
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
    );
  }

  Widget _buildStreamCard(Map<String, dynamic> stream) {
    return GestureDetector(
      onTap: () {
        // Navigate to course detail or video player
        BuildContextExtensions(
          context,
        ).showSuccessSnackBar('Opening ${stream['title']}');
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail with glassmorphic effect
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(stream['image']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Live indicator
                        if (stream['isLive'])
                          Positioned(
                            top: 8.h,
                            right: 8.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6.w,
                                    height: 6.h,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'LIVE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // Viewers count
                        Positioned(
                          bottom: 8.h,
                          left: 8.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.visibility,
                                  color: Colors.white,
                                  size: 14.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '${stream['viewers']}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Course info
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            stream['title'],
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          // Instructor info
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 12.r,
                                backgroundImage: AssetImage(stream['avatar']),
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  stream['instructor'],
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          // Rating and duration
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 14.sp,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    stream['rating'].toString(),
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                stream['duration'],
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
