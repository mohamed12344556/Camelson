import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/core.dart';

class BottomCircleAvatar extends StatelessWidget {
  final String? name;
  final bool isLoading;

  const BottomCircleAvatar({
    super.key,
    this.name,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;

    if (isLoading) {
      return _buildShimmer(isDarkMode);
    }

    final displayName = name ?? 'User';
    final firstLetter =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Text(
          displayName,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        Positioned(
          right: -20.w,
          top: -40.h,
          child: Container(
            width: 35.w,
            height: 35.h,
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFF2F98D7), width: 3.w),
            ),
            child: Center(
              child: Text(
                firstLetter,
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w800,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmer(bool isDarkMode) {
    final baseColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[600]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 100.w,
            height: 24.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          Positioned(
            right: -20.w,
            top: -40.h,
            child: Container(
              width: 35.w,
              height: 35.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
