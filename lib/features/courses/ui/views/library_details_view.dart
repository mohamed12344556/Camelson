import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/models/library_model.dart';
import '../widgets/lecture_card_widget.dart';

class LibraryDetailsView extends StatefulWidget {
  final LibraryModel library;

  const LibraryDetailsView({
    super.key,
    required this.library,
  });

  @override
  State<LibraryDetailsView> createState() => _LibraryDetailsViewState();
}

class _LibraryDetailsViewState extends State<LibraryDetailsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock lectures data
  final List<LectureModel> mockLectures = [
    LectureModel(
      id: '1',
      title: 'Intro to Topic',
      description:
          'This lecture offers a foundational introduction to the subject, setting the stage for deeper...',
      type: 'Introduction',
      duration: '45 min',
      isCompleted: false,
    ),
    LectureModel(
      id: '2',
      title: 'Core Concepts',
      description:
          'In this session, we dive into the essential principles, terminology and key frameworks that form...',
      type: 'Core',
      duration: '60 min',
      isCompleted: false,
    ),
    LectureModel(
      id: '3',
      title: 'Case Studies',
      description:
          'Through detailed real-world examples, this lecture demonstrates how theoretical...',
      type: 'Case Study',
      duration: '55 min',
      isCompleted: false,
    ),
    LectureModel(
      id: '4',
      title: 'Q&A Session',
      description:
          'This interactive session addresses frequently asked questions and common...',
      type: 'Q&A',
      duration: '40 min',
      isCompleted: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: widget.library.title,
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              padding: const EdgeInsets.all(4),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Lectures'),
                Tab(text: 'Book'),
              ],
            ),
          ),

          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Overview Tab
                _buildOverviewTab(),

                // Lectures Tab
                _buildLecturesTab(),

                // Book Tab
                _buildBookTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About This Library',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.library.description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoRow(
            Icons.people_outline,
            'Subscribers',
            '${widget.library.subscribersCount}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.school_outlined,
            'Year',
            widget.library.year,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.attach_money,
            'Price',
            '\$${widget.library.price.toInt()}',
          ),
        ],
      ),
    );
  }

  Widget _buildLecturesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockLectures.length,
      itemBuilder: (context, index) {
        return LectureCardWidget(
          lecture: mockLectures[index],
          onTap: () {
            // Navigate to lecture content
          },
        );
      },
    );
  }

  Widget _buildBookTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book,
            size: 80,
            color: AppColors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Book content will be available here',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              // Open book or download
            },
            icon: const Icon(Icons.download, color: Colors.white),
            label: const Text(
              'Download Book',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
