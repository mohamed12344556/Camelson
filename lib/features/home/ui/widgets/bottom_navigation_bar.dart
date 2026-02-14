import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/themes/font_weight_helper.dart';
import '../../data/models/tab_config.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final List<TabConfig> tabConfigs;
  final int selectedIndex;
  final ValueChanged<int> onTabTapped;

  const CustomBottomNavigationBar({
    super.key,
    required this.tabConfigs,
    required this.selectedIndex,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10.r,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                tabConfigs
                    .asMap()
                    .entries
                    .map((entry) => _buildNavItem(entry.key, entry.value))
                    .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, TabConfig config) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onTabTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16.w : 12.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            if (config.isProfile)
              _buildProfileIcon(isSelected)
            else
              _buildRegularIcon(config.iconPath, isSelected),
            if (isSelected) ...[
              SizedBox(width: 8.w),
              Text(
                config.label,
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeightHelper.medium,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRegularIcon(String iconPath, bool isSelected) {
    return SvgPicture.asset(
      iconPath,
      height: 24.h,
      width: 24.w,
      colorFilter: ColorFilter.mode(
        isSelected ? Colors.blue : Colors.black,
        BlendMode.srcIn,
      ),
    );
  }

  Widget _buildProfileIcon(bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isSelected ? 38.w : 32.w,
      height: isSelected ? 38.h : 32.h,
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isSelected ? Border.all(color: Colors.blue, width: 2.w) : null,
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/profile.png'),
          ),
        ),
      ),
    );
  }
}
