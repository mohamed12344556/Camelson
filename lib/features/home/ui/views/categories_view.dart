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
    {
      'name': 'First Year',
      'nameAr': 'السنة الأولى',
      'image': 'assets/images/learning.png',
    },
    {
      'name': 'Second Year',
      'nameAr': 'السنة الثانية',
      'image': 'assets/images/learning.png',
    },
    {
      'name': 'Third Year',
      'nameAr': 'السنة الثالثة',
      'image': 'assets/images/learning.png',
    },
    {
      'name': 'Fourth Year',
      'nameAr': 'السنة الرابعة',
      'image': 'assets/images/learning.png',
    },
    {
      'name': 'Fifth Year',
      'nameAr': 'السنة الخامسة',
      'image': 'assets/images/learning.png',
    },
    {
      'name': 'Sixth Year',
      'nameAr': 'السنة السادسة',
      'image': 'assets/images/learning.png',
    },
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
                  (category) =>
                      category['name']!.toLowerCase().contains(query) ||
                      (category['nameAr']?.contains(query) ?? false),
                )
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isArabic = context.isArabic;

    return Scaffold(
      appBar: CustomAppBar(
        title: isArabic ? 'السنين' : 'Years',
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
                      ? Center(
                        child: Text(
                          isArabic ? 'لا توجد سنوات' : 'No years found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.text.withValues(alpha: 0.6),
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
