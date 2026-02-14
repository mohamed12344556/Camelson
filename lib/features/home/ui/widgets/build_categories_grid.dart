import 'package:flutter/material.dart';

import 'category_card.dart';

class BuildCategoriesGrid extends StatelessWidget {
  final List<Map<String, String>> categories;
  final bool isSmallScreen;

  const BuildCategoriesGrid({
    super.key,
    required this.categories,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isSmallScreen ? 2 : 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return CategoryCard(category: categories[index]);
      },
    );
  }
}
