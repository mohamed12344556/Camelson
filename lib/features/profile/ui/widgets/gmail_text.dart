import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/core.dart';

class GmailText extends StatelessWidget {
  final String? email;
  final bool isLoading;

  const GmailText({
    super.key,
    this.email,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;

    if (isLoading) {
      return _buildShimmer(isDarkMode);
    }

    return Text(
      email ?? 'email@example.com',
      style: TextStyle(
        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        fontWeight: FontWeight.w500,
        fontSize: 14.sp,
      ),
    );
  }

  Widget _buildShimmer(bool isDarkMode) {
    final baseColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[600]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: 160.w,
        height: 16.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.r),
        ),
      ),
    );
  }
}
