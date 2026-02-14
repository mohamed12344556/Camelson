// Navigation extensions moved to core/utils/extensions.dart
import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import '../widgets/build_categories_grid.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  final List<Map<String, String>> allCategories = [
    {'name': 'Physics', 'image': 'assets/images/physics.png'},
    {'name': 'Chemistry', 'image': 'assets/images/chemistry.png'},
    {'name': 'Biology', 'image': 'assets/images/biology.png'},
    {'name': 'Mathematics', 'image': 'assets/images/math.png'},
    {'name': 'English', 'image': 'assets/images/english.png'},
    {'name': 'Arabic', 'image': 'assets/images/arabic.png'},
    {'name': 'French', 'image': 'assets/images/french.png'},
    {'name': 'Biology', 'image': 'assets/images/biology.png'},
    {'name': 'Chemistry', 'image': 'assets/images/chemistry.png'},
    {'name': 'Physics', 'image': 'assets/images/physics.png'},
    {'name': 'English', 'image': 'assets/images/english.png'},
    {'name': 'Biology', 'image': 'assets/images/biology.png'},
    {'name': 'Chemistry', 'image': 'assets/images/chemistry.png'},
    {'name': 'Physics', 'image': 'assets/images/physics.png'},
    {'name': 'English', 'image': 'assets/images/english.png'},
    {'name': 'Biology', 'image': 'assets/images/biology.png'},
    {'name': 'Chemistry', 'image': 'assets/images/chemistry.png'},
    {'name': 'Physics', 'image': 'assets/images/physics.png'},
    {'name': 'English', 'image': 'assets/images/english.png'},
  ];

  List<Map<String, String>> displayedCategories = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    displayedCategories = List.from(allCategories);
    _searchController.addListener(_filterCategories);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCategories() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        displayedCategories = List.from(allCategories);
      } else {
        displayedCategories =
            allCategories
                .where(
                  (category) => category['name']!.toLowerCase().contains(query),
                )
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Subject',
        onBackPressed: () {
          context.setNavBarVisible(true);
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            //? Search bar
            CustomSearchBar(searchController: _searchController),
            //? Categories grid
            Expanded(
              child:
                  displayedCategories.isEmpty
                      ? const Center(
                        child: Text(
                          'No subjects found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      )
                      : BuildCategoriesGrid(
                        categories: displayedCategories,
                        isSmallScreen: isSmallScreen,
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
