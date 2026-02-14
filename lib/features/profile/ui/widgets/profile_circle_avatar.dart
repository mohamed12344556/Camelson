import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/themes/app_images.dart';

class ProfileCircleAvatar extends StatelessWidget {
  final String? imageUrl;
  final bool isLoading;

  const ProfileCircleAvatar({
    super.key,
    this.imageUrl,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return _buildShimmer(isDarkMode);
    }

    return CircleAvatar(
      radius: 50.r,
      backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
          ? NetworkImage(imageUrl!)
          : AssetImage(Assets.profile) as ImageProvider,
    );
  }

  Widget _buildShimmer(bool isDarkMode) {
    final baseColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[600]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: CircleAvatar(
        radius: 50.r,
        backgroundColor: Colors.white,
      ),
    );
  }
}
