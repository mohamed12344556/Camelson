import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/core.dart';

class CurrentPlanBadge extends StatelessWidget {
  final String planType;
  final String? planName;
  final int? daysRemaining;
  final bool isActive;

  const CurrentPlanBadge({
    super.key,
    required this.planType,
    this.planName,
    this.daysRemaining,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    final isArabic = context.isArabic;
    final color = _getPlanColor(planType);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          // Avatar with colored border
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
              gradient: LinearGradient(
                colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
              ),
            ),
            child: Center(
              child: Icon(_getPlanIcon(planType), color: color, size: 30.sp),
            ),
          ),
          SizedBox(width: 16.w),

          // Plan Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'خطتك الحالية' : 'Your Current Plan',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  planName ?? _getLocalizedPlanType(planType, isArabic),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),

          // Badge and Days Remaining
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isActive ? color : Colors.grey,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  isActive
                      ? (isArabic ? 'نشط' : 'Active')
                      : (isArabic ? 'غير نشط' : 'Inactive'),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (daysRemaining != null && daysRemaining! > 0) ...[
                SizedBox(height: 4.h),
                Text(
                  isArabic
                      ? '$daysRemaining يوم متبقي'
                      : '$daysRemaining days left',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: daysRemaining! <= 7 ? Colors.orange : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getPlanColor(String planType) {
    switch (planType.toLowerCase()) {
      case 'free':
        return Colors.green;
      case 'pro':
        return Colors.blue;
      case 'enterprise':
        return Colors.purple;
      case 'premium':
        return const Color(0xFFFFD700);
      default:
        return Colors.grey;
    }
  }

  IconData _getPlanIcon(String planType) {
    switch (planType.toLowerCase()) {
      case 'free':
        return Icons.school;
      case 'pro':
        return Icons.workspace_premium;
      case 'enterprise':
        return Icons.business;
      case 'premium':
        return Icons.diamond;
      default:
        return Icons.person;
    }
  }

  String _getLocalizedPlanType(String planType, bool isArabic) {
    if (!isArabic) return planType;

    switch (planType.toLowerCase()) {
      case 'free':
        return 'مجاني';
      case 'pro':
        return 'احترافي';
      case 'enterprise':
        return 'مؤسسي';
      case 'premium':
        return 'مميز';
      default:
        return planType;
    }
  }
}
