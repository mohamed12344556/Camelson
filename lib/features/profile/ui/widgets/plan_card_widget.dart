import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/core.dart';
import '../../data/models/plan_model.dart';
import '../../data/models/pricing_model.dart';

class PlanCardWidget extends StatelessWidget {
  final PlanModel plan;
  final BillingPeriod selectedPeriod;
  final VoidCallback onTap;
  final bool isCurrentPlan;

  const PlanCardWidget({
    super.key,
    required this.plan,
    required this.selectedPeriod,
    required this.onTap,
    this.isCurrentPlan = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    final isArabic = context.isArabic;
    final planColor = _getPlanColor();
    final price = plan.pricing.getPriceForPeriod(selectedPeriod);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280.w,
        margin: EdgeInsets.only(right: 16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [planColor.withOpacity(0.1), planColor.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isCurrentPlan ? planColor : planColor.withOpacity(0.3),
            width: isCurrentPlan ? 2.5 : 1.5,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan Type Badge
                  _buildPlanTypeBadge(planColor, isArabic),
                  SizedBox(height: 12.h),

                  // Plan Name
                  Text(
                    plan.getLocalizedName(isArabic),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Description
                  Text(
                    plan.getLocalizedDescription(isArabic),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),

                  // Price
                  _buildPriceSection(price, isDarkMode, isArabic),
                  SizedBox(height: 16.h),

                  // CTA Button
                  _buildCTAButton(planColor, isDarkMode, isArabic),
                ],
              ),
            ),

            // Current Plan Badge
            if (isCurrentPlan) _buildCurrentPlanBadge(planColor, isArabic),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanTypeBadge(Color color, bool isArabic) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        isArabic ? plan.planTypeEnum.nameAr : plan.planTypeEnum.nameEn,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPriceSection(double price, bool isDarkMode, bool isArabic) {
    if (price == 0) {
      return Text(
        isArabic ? 'مجاني' : 'Free',
        style: TextStyle(
          fontSize: 32.sp,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '\$',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        Text(
          isArabic ? price.toArabic() : price.toString(),
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        SizedBox(width: 4.w),
        Padding(
          padding: EdgeInsets.only(top: 8.h),
          child: Text(
            '/${_getPeriodLabel(isArabic)}',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCTAButton(Color color, bool isDarkMode, bool isArabic) {
    return Container(
      width: double.infinity,
      height: 48.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          isCurrentPlan
              ? (isArabic ? 'الخطة الحالية' : 'Current Plan')
              : (isArabic ? 'اشترك الآن' : 'Subscribe Now'),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPlanBadge(Color color, bool isArabic) {
    return Positioned(
      top: 16.h,
      right: isArabic ? null : 16.w,
      left: isArabic ? 16.w : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 16.sp),
            SizedBox(width: 4.w),
            Text(
              isArabic ? 'حالي' : 'Active',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPlanColor() {
    switch (plan.planTypeEnum) {
      case PlanTypeEnum.free:
        return Colors.green;
      case PlanTypeEnum.pro:
        return Colors.blue;
      case PlanTypeEnum.enterprise:
        return Colors.purple;
      case PlanTypeEnum.premium:
        return const Color(0xFFFFD700); // Gold
    }
  }

  String _getPeriodLabel(bool isArabic) {
    switch (selectedPeriod) {
      case BillingPeriod.monthly:
        return isArabic ? 'شهر' : 'month';
      case BillingPeriod.quarterly:
        return isArabic ? '3 أشهر' : '3 months';
      case BillingPeriod.semiAnnual:
        return isArabic ? '6 أشهر' : '6 months';
      case BillingPeriod.annual:
        return isArabic ? 'سنة' : 'year';
    }
  }
}
