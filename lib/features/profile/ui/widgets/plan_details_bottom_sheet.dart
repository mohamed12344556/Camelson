import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/core.dart';
import '../../data/models/plan_model.dart';
import '../../data/models/pricing_model.dart';
import '../logic/plans/plans_cubit.dart';
import '../logic/plans/plans_state.dart';

class PlanDetailsBottomSheet extends StatefulWidget {
  final PlanModel plan;

  const PlanDetailsBottomSheet({super.key, required this.plan});

  @override
  State<PlanDetailsBottomSheet> createState() => _PlanDetailsBottomSheetState();
}

class _PlanDetailsBottomSheetState extends State<PlanDetailsBottomSheet> {
  final _discountController = TextEditingController();
  String _selectedPaymentMethod = 'Card';

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    final isArabic = context.isArabic;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkBackground : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          _buildDragHandle(),
          _buildHeader(context, isDarkMode, isArabic),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPlanInfoCard(isDarkMode, isArabic),
                  SizedBox(height: 24.h),
                  _buildBillingPeriodSection(context, isDarkMode, isArabic),
                  SizedBox(height: 24.h),

                  // ✅ Discount Code Field
                  _buildDiscountCodeField(isDarkMode, isArabic),
                  SizedBox(height: 24.h),

                  // ✅ Payment Method Selector
                  _buildPaymentMethodSelector(isDarkMode, isArabic),
                  SizedBox(height: 24.h),

                  _buildFeaturesSection(isDarkMode, isArabic),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
          _buildSubscribeButton(context, isDarkMode, isArabic),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode, bool isArabic) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              isArabic ? 'تفاصيل الخطة' : 'Plan Details',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanInfoCard(bool isDarkMode, bool isArabic) {
    final planColor = _getPlanColor();

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [planColor.withOpacity(0.15), planColor.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: planColor.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: planColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: planColor, width: 1),
            ),
            child: Text(
              isArabic
                  ? widget.plan.planTypeEnum.nameAr
                  : widget.plan.planTypeEnum.nameEn,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: planColor,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            widget.plan.getLocalizedName(isArabic),
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            widget.plan.getLocalizedDescription(isArabic),
            style: TextStyle(
              fontSize: 15.sp,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingPeriodSection(
    BuildContext context,
    bool isDarkMode,
    bool isArabic,
  ) {
    return BlocBuilder<PlansCubit, PlansState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'اختر فترة الاشتراك' : 'Select Billing Period',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 12.h),
            ...BillingPeriod.values.map((period) {
              final price = widget.plan.pricing.getPriceForPeriod(period);
              final isSelected = state.selectedBillingPeriod == period;

              return _buildBillingPeriodTile(
                context,
                period,
                price,
                isSelected,
                isDarkMode,
                isArabic,
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildBillingPeriodTile(
    BuildContext context,
    BillingPeriod period,
    double price,
    bool isSelected,
    bool isDarkMode,
    bool isArabic,
  ) {
    final planColor = _getPlanColor();

    return GestureDetector(
      onTap: () => context.read<PlansCubit>().selectBillingPeriod(period),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? planColor.withOpacity(0.1)
              : (isDarkMode ? Colors.grey[850] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? planColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? planColor : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: planColor,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? period.nameAr : period.nameEn,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  if (period != BillingPeriod.monthly)
                    Text(
                      _getSavingsText(period, isArabic),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              price == 0 ? (isArabic ? 'مجاني' : 'Free') : '\$$price',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: planColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ NEW: Discount Code Field
  Widget _buildDiscountCodeField(bool isDarkMode, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'كود الخصم (اختياري)' : 'Discount Code (Optional)',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        SizedBox(height: 12.h),
        TextField(
          controller: _discountController,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: isArabic ? 'أدخل كود الخصم' : 'Enter discount code',
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            filled: true,
            fillColor: isDarkMode ? Colors.grey[850] : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: _getPlanColor(), width: 2),
            ),
            prefixIcon: Icon(Icons.discount, color: _getPlanColor()),
            suffixIcon: _discountController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _discountController.clear();
                      });
                    },
                  )
                : null,
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  // ✅ NEW: Payment Method Selector
  Widget _buildPaymentMethodSelector(bool isDarkMode, bool isArabic) {
    final paymentMethods = [
      {
        'value': 'Card',
        'label': isArabic ? 'بطاقة' : 'Card',
        'icon': Icons.credit_card,
      },
      {
        'value': 'Cash',
        'label': isArabic ? 'كاش' : 'Cash',
        'icon': Icons.money,
      },
      {
        'value': 'Wallet',
        'label': isArabic ? 'محفظة' : 'Wallet',
        'icon': Icons.account_balance_wallet,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'طريقة الدفع' : 'Payment Method',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: paymentMethods.map((method) {
            final isSelected = _selectedPaymentMethod == method['value'];
            final planColor = _getPlanColor();

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = method['value'] as String;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: 8.w),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? planColor.withOpacity(0.1)
                        : (isDarkMode ? Colors.grey[850] : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected ? planColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        method['icon'] as IconData,
                        color: isSelected ? planColor : Colors.grey,
                        size: 32.sp,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        method['label'] as String,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? planColor
                              : (isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(bool isDarkMode, bool isArabic) {
    if (widget.plan.features.isEmpty) return const SizedBox.shrink();

    final sortedFeatures = [...widget.plan.features]
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'المميزات المتضمنة' : 'Included Features',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        SizedBox(height: 12.h),
        ...sortedFeatures.map((feature) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  feature.isPositive ? Icons.check_circle : Icons.cancel,
                  color: feature.isPositive ? Colors.green : Colors.red,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    feature.getLocalizedDescription(isArabic),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSubscribeButton(
    BuildContext context,
    bool isDarkMode,
    bool isArabic,
  ) {
    return BlocConsumer<PlansCubit, PlansState>(
      listener: (context, state) {
        // Handle cancel subscription success
        if (state.cancelUpgradeStatus == CancelUpgradeStatus.success) {
          Navigator.pop(context);
          context.showSuccessSnackBar(
            isArabic
                ? 'تم إلغاء الاشتراك بنجاح'
                : 'Subscription cancelled successfully',
          );
          context.read<PlansCubit>().resetCancelUpgradeStatus();
        }
        // Handle cancel subscription error
        if (state.cancelUpgradeStatus == CancelUpgradeStatus.error) {
          context.showErrorSnackBar(
            state.errorMessage ??
                (isArabic ? 'فشل إلغاء الاشتراك' : 'Failed to cancel subscription'),
          );
          context.read<PlansCubit>().resetCancelUpgradeStatus();
        }
      },
      builder: (context, state) {
        final price = widget.plan.pricing.getPriceForPeriod(
          state.selectedBillingPeriod,
        );
        final isSubscribing =
            state.subscriptionStatus == SubscriptionStatus.subscribing;
        final isCancelling =
            state.cancelUpgradeStatus == CancelUpgradeStatus.cancelling;

        // Check if this is the user's current plan
        final isCurrentPlan = state.currentSubscription != null &&
            state.currentSubscription!.subscriptionPlanId == widget.plan.id &&
            state.currentSubscription!.isActive;

        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkBackground : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: isCurrentPlan
              ? _buildCancelButton(context, isDarkMode, isArabic, isCancelling)
              : _buildSubscribeButtonContent(
                  context,
                  isDarkMode,
                  isArabic,
                  price,
                  isSubscribing,
                ),
        );
      },
    );
  }

  Widget _buildSubscribeButtonContent(
    BuildContext context,
    bool isDarkMode,
    bool isArabic,
    double price,
    bool isLoading,
  ) {
    return ElevatedButton(
      onPressed: isLoading ? null : () => _handleSubscribe(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: _getPlanColor(),
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 56.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        elevation: 4,
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  price == 0
                      ? (isArabic ? 'ابدأ مجاناً' : 'Start Free')
                      : (isArabic ? 'اشترك الآن' : 'Subscribe Now'),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (price > 0) ...[
                  SizedBox(width: 8.w),
                  Text(
                    '• \$$price',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildCancelButton(
    BuildContext context,
    bool isDarkMode,
    bool isArabic,
    bool isLoading,
  ) {
    return ElevatedButton(
      onPressed: isLoading
          ? null
          : () => _showCancelConfirmationDialog(context, isArabic),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 56.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        elevation: 4,
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cancel_outlined, size: 24.sp),
                SizedBox(width: 8.w),
                Text(
                  isArabic ? 'إلغاء الاشتراك' : 'Cancel Subscription',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );
  }

  void _showCancelConfirmationDialog(BuildContext context, bool isArabic) {
    final reasonController = TextEditingController();
    final isDarkMode = context.isDarkMode;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.darkBackground : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                isArabic ? 'تأكيد إلغاء الاشتراك' : 'Confirm Cancellation',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic
                  ? 'هل أنت متأكد من إلغاء اشتراكك؟ ستفقد الوصول إلى المميزات المدفوعة.'
                  : 'Are you sure you want to cancel your subscription? You will lose access to premium features.',
              style: TextStyle(
                fontSize: 14.sp,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: isArabic
                    ? 'سبب الإلغاء (اختياري)'
                    : 'Reason for cancellation (optional)',
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[850] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              isArabic ? 'تراجع' : 'Cancel',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _handleCancelSubscription(
                context,
                reasonController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              isArabic ? 'تأكيد الإلغاء' : 'Confirm',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCancelSubscription(BuildContext context, String reason) {
    final cubit = context.read<PlansCubit>();
    cubit.cancelCurrentSubscription(
      reason: reason.isEmpty ? 'User requested cancellation' : reason,
    );
  }

  // ✅ UPDATED: Handle Subscribe with discount and payment method
  void _handleSubscribe(BuildContext context) async {
    final cubit = context.read<PlansCubit>();
    final isArabic = context.isArabic;
    final state = cubit.state;

    // Check if user has an active subscription and is switching to a different plan
    final hasActiveSubscription = state.currentSubscription != null &&
        state.currentSubscription!.isActive &&
        state.currentSubscription!.subscriptionPlanId != widget.plan.id;

    if (hasActiveSubscription) {
      final immediate = await _showSwitchPlanDialog(context, isArabic);
      if (immediate == null || !context.mounted) return;
      await _executeSubscription(context, immediate: immediate);
    } else {
      await _executeSubscription(context, immediate: true);
    }
  }

  /// Shows a dialog asking the user whether to switch immediately or schedule
  Future<bool?> _showSwitchPlanDialog(
    BuildContext context,
    bool isArabic,
  ) async {
    final isDarkMode = context.isDarkMode;
    final cubit = context.read<PlansCubit>();
    final currentPlanName =
        cubit.state.currentSubscription?.subscriptionPlanName ?? '';
    final daysRemaining =
        cubit.state.currentSubscription?.daysRemaining ?? 0;

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.darkBackground : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.swap_horiz, color: AppColors.primary, size: 28.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                isArabic ? 'تغيير الخطة' : 'Switch Plan',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic
                  ? 'أنت مشترك حالياً في "$currentPlanName" ومتبقي $daysRemaining يوم.\nهل تريد التغيير فوراً أم بعد انتهاء خطتك الحالية؟'
                  : 'You are currently on "$currentPlanName" with $daysRemaining days remaining.\nDo you want to switch immediately or after your current plan expires?',
              style: TextStyle(
                fontSize: 14.sp,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                height: 1.5,
              ),
            ),
            SizedBox(height: 20.h),
            // Immediate option
            _buildSwitchOption(
              context: dialogContext,
              isDarkMode: isDarkMode,
              isArabic: isArabic,
              icon: Icons.flash_on,
              color: Colors.orange,
              title: isArabic ? 'تغيير فوري' : 'Switch Immediately',
              subtitle: isArabic
                  ? 'سيتم التحويل الآن مع حساب الفرق'
                  : 'Switch now with pro-rata adjustment',
              onTap: () => Navigator.pop(dialogContext, true),
            ),
            SizedBox(height: 12.h),
            // Scheduled option
            _buildSwitchOption(
              context: dialogContext,
              isDarkMode: isDarkMode,
              isArabic: isArabic,
              icon: Icons.schedule,
              color: Colors.blue,
              title: isArabic ? 'بعد انتهاء الخطة الحالية' : 'After Current Plan Ends',
              subtitle: isArabic
                  ? 'سيتم التحويل تلقائياً بعد $daysRemaining يوم'
                  : 'Will switch automatically after $daysRemaining days',
              onTap: () => Navigator.pop(dialogContext, false),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, null),
            child: Text(
              isArabic ? 'إلغاء' : 'Cancel',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchOption({
    required BuildContext context,
    required bool isDarkMode,
    required bool isArabic,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isArabic ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
              color: color,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _executeSubscription(
    BuildContext context, {
    required bool immediate,
  }) async {
    final cubit = context.read<PlansCubit>();
    final isArabic = context.isArabic;

    final discountCode = _discountController.text.trim();

    log('Starting subscription request for plan: ${widget.plan.id}');
    log('Billing period: ${cubit.state.selectedBillingPeriod.nameEn}');
    log('Payment method: $_selectedPaymentMethod');
    log('Immediate: $immediate');

    await cubit.requestSubscription(
      planId: widget.plan.id,
      immediate: immediate,
      discountCode: discountCode.isEmpty ? '' : discountCode,
      paymentMethod: _selectedPaymentMethod,
    );

    if (!context.mounted) return;

    final state = cubit.state;

    log('Subscription status after request: ${state.subscriptionStatus}');
    log('Subscription response: ${state.subscriptionResponse}');

    if (state.subscriptionStatus == SubscriptionStatus.success &&
        state.subscriptionResponse != null) {
      // ✅ تحقق من صحة الـ URL قبل الفتح
      var paymentUrl = state.subscriptionResponse!.paymentUrl;
      final invoiceKey = state.subscriptionResponse!.invoiceKey;
      log('Payment URL received: $paymentUrl');
      log('Invoice Key: $invoiceKey');

      // ✅ إذا كان paymentUrl فارغ، استخدم invoiceKey (الباك إند قد يرسل URL في invoiceKey)
      if (paymentUrl.isEmpty && invoiceKey.isNotEmpty) {
        log('paymentUrl is empty, using invoiceKey as URL');
        paymentUrl = invoiceKey;
      }

      if (paymentUrl.isEmpty) {
        context.showErrorSnackBar(
          isArabic ? 'رابط الدفع فارغ' : 'Payment URL is empty',
        );
        return;
      }

      // Validate URL format
      try {
        final uri = Uri.parse(paymentUrl);
        if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
          log('Invalid URL scheme: ${uri.scheme}');
          context.showErrorSnackBar(
            isArabic ? 'رابط الدفع غير صالح' : 'Invalid payment URL format',
          );
          return;
        }
      } catch (e) {
        log('Error parsing payment URL: $e');
        context.showErrorSnackBar(
          isArabic ? 'خطأ في رابط الدفع' : 'Error in payment URL',
        );
        return;
      }

      Navigator.pop(context);

      // فتح رابط الدفع في المتصفح الخارجي
      final uri = Uri.parse(paymentUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } else {
        if (context.mounted) {
          context.showErrorSnackBar(
            isArabic ? 'تعذر فتح المتصفح' : 'Could not open browser',
          );
        }
      }
    } else if (state.subscriptionStatus == SubscriptionStatus.error) {
      log('Subscription error: ${state.errorMessage}');
      Navigator.pop(context);
      context.showErrorSnackBar(
        state.errorMessage ??
            (isArabic ? 'فشل الاشتراك' : 'Subscription failed'),
      );
      cubit.resetSubscriptionStatus();
    }
  }

  Color _getPlanColor() {
    switch (widget.plan.planTypeEnum) {
      case PlanTypeEnum.free:
        return Colors.green;
      case PlanTypeEnum.pro:
        return Colors.blue;
      case PlanTypeEnum.enterprise:
        return Colors.purple;
      case PlanTypeEnum.premium:
        return const Color(0xFFFFD700);
    }
  }

  String _getSavingsText(BillingPeriod period, bool isArabic) {
    final percentage = switch (period) {
      BillingPeriod.quarterly => 10,
      BillingPeriod.semiAnnual => 15,
      BillingPeriod.annual => 25,
      _ => 0,
    };

    return isArabic ? 'وفر ${percentage.toArabic()}٪' : 'Save $percentage%';
  }
}
