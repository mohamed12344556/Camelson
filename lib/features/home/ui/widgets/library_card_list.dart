import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/core.dart';
import '../../../../core/themes/font_weight_helper.dart';

class LibraryCardList extends StatelessWidget {
  final int itemCount;
  final double cardWidth;
  final double cardHeight;
  final double spacing;
  final List<Map<String, dynamic>> librariesData;

  const LibraryCardList({
    super.key,
    required this.itemCount,
    required this.librariesData,
    this.cardWidth = 280.0,
    this.cardHeight = 350.0,
    this.spacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;

    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final dataIndex = index % librariesData.length;
          final data = librariesData[dataIndex];

          return Padding(
            padding: EdgeInsets.only(right: spacing),
            child: Container(
              width: cardWidth,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.text.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      image: DecorationImage(
                        image: AssetImage(data['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Year badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5F3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isArabic ? data['year'] : data['yearEn'],
                              style: TextStyle(
                                color: const Color(0xFF167F71),
                                fontSize: 11.sp,
                                fontWeight: FontWeightHelper.semiBold,
                              ),
                            ),
                          ),

                          SizedBox(height: 10.h),

                          // Title
                          Text(
                            isArabic ? data['titleAr'] : data['title'],
                            style: TextStyle(
                              color: const Color(0xff202244),
                              fontSize: 16.sp,
                              fontWeight: FontWeightHelper.bold,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          SizedBox(height: 6.h),

                          // Description
                          Expanded(
                            child: Text(
                              isArabic
                                  ? data['descriptionAr']
                                  : data['description'],
                              style: TextStyle(
                                color: const Color(0xff545454),
                                fontSize: 12.sp,
                                fontWeight: FontWeightHelper.regular,
                                height: 1.4,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          SizedBox(height: 12.h),

                          // Subscribers count
                          Row(
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 16,
                                color: const Color(0xff545454),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_formatNumber(data['subscribers'])} ${isArabic ? 'مشترك' : 'Subscribers'}',
                                style: TextStyle(
                                  color: const Color(0xff545454),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeightHelper.medium,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 12.h),

                          // Price and Join button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Price
                              Text(
                                '${data['price']} ${isArabic ? 'جنيه' : 'EGP'}',
                                style: TextStyle(
                                  color: const Color(0xFF167F71),
                                  fontSize: 18.sp,
                                  fontWeight: FontWeightHelper.bold,
                                ),
                              ),

                              // Join button
                              ElevatedButton(
                                onPressed: () {
                                  log(
                                    'LibraryCardList - Join button pressed for ${data['title']}',
                                  );
                                  log('Navigate to course details with data: $data');
                                  context.setNavBarVisible(false);

                                  // Use root navigator to ensure navigation works
                                  Navigator.of(context, rootNavigator: true).pushNamed(
                                    AppRoutes.courseDetailsView,
                                    arguments: {
                                      'courseId': dataIndex,
                                      'courseData': data,
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.background,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  isArabic ? 'انضم' : 'JOIN',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeightHelper.bold,
                                  ),
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
            ),
          );
        },
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
