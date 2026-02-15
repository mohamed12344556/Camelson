import 'package:flutter/material.dart';

import '../../../../core/core.dart';

class CategoryCard extends StatelessWidget {
  final Map<String, String> category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    final displayName = isArabic
        ? (category['nameAr'] ?? category['name']!)
        : category['name']!;

    return GestureDetector(
      onTap: () {
        context.pushNamed(
          AppRoutes.coursesView,
          // arguments: {'categoryId': category['id']},
        );
        context.showSuccessSnackBar('$displayName ${isArabic ? 'تم اختيارها' : 'selected'}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.lightBackground,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.text.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.text.withValues(alpha: 0.05),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Image.asset(category['image']!, fit: BoxFit.contain),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
