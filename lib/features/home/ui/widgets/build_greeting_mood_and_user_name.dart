import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/core.dart';

class BuildGreetingMoodAndUserName extends StatelessWidget {
  final String? userName;
  final bool isLoading;

  const BuildGreetingMoodAndUserName({
    super.key,
    this.userName,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _getGreeting(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                SizedBox(width: 8.w),
                _buildLottieIcon(),
              ],
            ),
            SizedBox(height: 4.h),
            isLoading ? _buildShimmer(isDarkMode) : _buildName(isDarkMode),
          ],
        ),
        // SizedBox(width: 8.w),
        // _buildLottieIcon(),
      ],
    );
  }

  Widget _buildName(bool isDarkMode) {
    final displayName = userName ?? 'Guest';
    return Text(
      '$displayName!',
      style: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : Colors.black,
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
        width: 120.w,
        height: 28.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.r),
        ),
      ),
    );
  }

  Widget _buildLottieIcon() {
    final hour = DateTime.now().hour;
    String lottieAsset;

    if (hour < 12) {
      // Morning - Sun animation
      lottieAsset = 'assets/lottie/sunny.json';
    } else if (hour < 17) {
      // Afternoon - Sunny/Cloud animation
      lottieAsset = 'assets/lottie/rainy icon.json';
    } else if (hour < 21) {
      // Evening - Sunset animation
      lottieAsset = 'assets/lottie/Weather Night - Clear sky.json';
    } else {
      // Night - Moon animation
      lottieAsset = 'assets/lottie/Weather-partly cloudy.json';
    }

    return Lottie.asset(
      lottieAsset,
      width: 35.w,
      height: 35.h,
      fit: BoxFit.contain,
      repeat: true,
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else if (hour < 21) {
      return 'Good evening';
    } else {
      return 'Good night';
    }
  }
}
