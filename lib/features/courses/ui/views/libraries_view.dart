import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import '../../data/models/library_model.dart';
import '../widgets/library_card.dart';

class LibrariesView extends StatefulWidget {
  const LibrariesView({super.key});

  @override
  State<LibrariesView> createState() => _LibrariesViewState();
}

class _LibrariesViewState extends State<LibrariesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> years = [
    'All',
    'First Year',
    'Second Year',
    'Third Year',
    'Fourth Year',
    'Fifth Year',
  ];

  final List<LibraryModel> allLibraries = [
    LibraryModel(
      id: '1',
      title: 'Principles of Disease',
      description:
          'Principles of Disease is a comprehensive resource designed to introduce learners to the fundamental concepts of pathology and microbiology.',
      year: 'First Year',
      subscribersCount: 12345,
      price: 500,
      imageUrl: 'assets/images/library_placeholder.png',
    ),
    LibraryModel(
      id: '2',
      title: 'Endocrine System',
      description:
          'A comprehensive overview of the endocrine system, focusing on hormone production, regulation...',
      year: 'Second Year',
      subscribersCount: 12345,
      price: 600,
      imageUrl: 'assets/images/library_placeholder.png',
    ),
    LibraryModel(
      id: '3',
      title: 'Gynaecology library',
      description:
          'An in depth study of the female reproductive system, including common conditions, diagnostic...',
      year: 'Fourth Year',
      subscribersCount: 12345,
      price: 600,
      imageUrl: 'assets/images/library_placeholder.png',
    ),
    LibraryModel(
      id: '4',
      title: 'Principles of Disease',
      description:
          'An in-depth exploration of the fundamental concepts of disease, including causes, mechanisms...',
      year: 'First Year',
      subscribersCount: 12345,
      price: 600,
      imageUrl: 'assets/images/library_placeholder.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: years.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<LibraryModel> get filteredLibraries {
    List<LibraryModel> result = [];

    // Filter by tab
    if (_tabController.index == 0) {
      result = List.from(allLibraries);
    } else {
      final selectedYear = years[_tabController.index];
      result = allLibraries.where((lib) => lib.year == selectedYear).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
            (lib) =>
                lib.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                lib.description
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: 'Libraries',
      ),
      body: Column(
        children: [
          // Search Bar
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

          // Year Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.text,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              padding: const EdgeInsets.all(4),
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              onTap: (index) => setState(() {}),
              tabs: years.map((year) => Tab(text: year)).toList(),
            ),
          ),

          // Libraries Grid
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: years.map((year) {
                return RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(const Duration(seconds: 1));
                    setState(() {});
                  },
                  child: filteredLibraries.isEmpty
                      ? const Center(
                          child: Text(
                            'No libraries found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: filteredLibraries.length,
                          itemBuilder: (context, index) {
                            return LibraryCard(
                              library: filteredLibraries[index],
                            );
                          },
                        ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
