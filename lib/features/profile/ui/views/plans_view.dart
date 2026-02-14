import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/core.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/models/pricing_model.dart';
import '../../data/models/upgrade_request_model.dart';
import '../logic/plans/plans_cubit.dart';
import '../logic/plans/plans_state.dart';
import '../widgets/current_plan_badge_widget.dart';
import '../widgets/plan_card_widget.dart';
import '../widgets/plan_details_bottom_sheet.dart';
import '../widgets/upgrade_request_card.dart';
import 'upgrade_requests_view.dart';

class PlansView extends StatefulWidget {
  const PlansView({super.key});

  @override
  State<PlansView> createState() => _PlansViewState();
}

class _PlansViewState extends State<PlansView> {
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final cubit = context.read<PlansCubit>();
    cubit.loadStudentPlans();
    cubit.loadUpgradeRequests();
    cubit.loadCurrentSubscription();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    final isArabic = context.isArabic;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : Colors.white,
      appBar: CustomAppBar(
        title: isArabic ? 'خطط الاشتراك' : 'Subscription Plans',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BlocConsumer<PlansCubit, PlansState>(
                listener: _handleStateChanges,
                builder: (context, state) {
                  if (state.status == PlansStatus.loading) {
                    return _buildLoadingState();
                  }

                  if (state.status == PlansStatus.error) {
                    return _buildErrorState(state.errorMessage, isArabic);
                  }

                  if (state.status == PlansStatus.success &&
                      state.plans.isNotEmpty) {
                    return _buildSuccessState(state, isDarkMode, isArabic);
                  }

                  return _buildEmptyState(isArabic);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildAppBar(BuildContext context, bool isDarkMode, bool isArabic) {
  //   return Padding(
  //     padding: EdgeInsets.all(20.w),
  //     child: Row(
  //       children: [
  //         IconButton(
  //           onPressed: () => Navigator.pop(context),
  //           icon: Icon(
  //             isArabic ? Icons.arrow_forward : Icons.arrow_back,
  //             color: isDarkMode ? Colors.white : Colors.black,
  //           ),
  //         ),
  //         SizedBox(width: 12.w),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 isArabic ? 'خطط الاشتراك' : 'Subscription Plans',
  //                 style: TextStyle(
  //                   fontSize: 24.sp,
  //                   fontWeight: FontWeight.bold,
  //                   color: isDarkMode ? Colors.white : Colors.black,
  //                 ),
  //               ),
  //               Text(
  //                 isArabic
  //                     ? 'اختر الخطة المناسبة لك'
  //                     : 'Choose the plan that fits you',
  //                 style: TextStyle(
  //                   fontSize: 14.sp,
  //                   color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildSuccessState(PlansState state, bool isDarkMode, bool isArabic) {
    final pendingRequests = state.upgradeRequests
        .where((r) => r.isPendingPayment)
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pending Requests Banner
          if (pendingRequests.isNotEmpty)
            _buildPendingRequestsBanner(pendingRequests, isDarkMode, isArabic),

          // Current Plan Badge (from API)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: CurrentPlanBadge(
              planType: state.currentSubscription?.status ?? 'Free',
              planName:
                  state.currentSubscription?.subscriptionPlanName ??
                  (isArabic ? 'الخطة المجانية' : 'Free Plan'),
              daysRemaining: state.currentSubscription?.daysRemaining,
              isActive: state.currentSubscription?.isActive ?? false,
            ),
          ),

          // Cancel Subscription Button (only if active)
          if (state.currentSubscription != null &&
              state.currentSubscription!.isActive)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: _buildCancelSubscriptionButton(isDarkMode, isArabic),
            ),

          // Scheduled Plan Badge (if exists)
          if (_getScheduledRequest(state) != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: _buildScheduledPlanBadge(
                _getScheduledRequest(state)!,
                isDarkMode,
                isArabic,
              ),
            ),
          SizedBox(height: 24.h),

          // Billing Period Selector
          _buildBillingPeriodSelector(state, isDarkMode, isArabic),
          SizedBox(height: 24.h),

          // Plans Title with "My Requests" button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic ? 'الخطط المتاحة' : 'Available Plans',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                if (state.upgradeRequests.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => _navigateToUpgradeRequests(context),
                    icon: Icon(Icons.receipt_long, size: 18.sp),
                    label: Text(
                      isArabic ? 'طلباتي' : 'My Requests',
                      style: TextStyle(fontSize: 13.sp),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Horizontal Scrolling Plans
          SizedBox(
            height: 380.h,
            child: ListView.builder(
              padding: EdgeInsets.only(left: 20.w, right: 4.w),
              scrollDirection: Axis.horizontal,
              itemCount: state.plans.length,
              itemBuilder: (context, index) {
                final plan = state.plans[index];
                final isCurrentPlan =
                    state.currentSubscription != null &&
                    state.currentSubscription!.subscriptionPlanId == plan.id;
                return PlanCardWidget(
                  plan: plan,
                  selectedPeriod: state.selectedBillingPeriod,
                  isCurrentPlan: isCurrentPlan,
                  onTap: () => _showPlanDetails(context, plan),
                );
              },
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildPendingRequestsBanner(
    List pendingRequests,
    bool isDarkMode,
    bool isArabic,
  ) {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.15),
            Colors.orange.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.pending_actions,
                  color: Colors.orange,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic
                          ? 'لديك ${pendingRequests.length} طلب في انتظار الدفع'
                          : 'You have ${pendingRequests.length} pending payment',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      isArabic
                          ? 'أكمل الدفع للاستمتاع بالمميزات'
                          : 'Complete payment to enjoy features',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Show first pending request
          UpgradeRequestCard(
            request: pendingRequests.first,
            isCompact: true,
            onTap: () => _navigateToUpgradeRequests(context),
          ),
          if (pendingRequests.length > 1) ...[
            SizedBox(height: 8.h),
            Center(
              child: TextButton(
                onPressed: () => _navigateToUpgradeRequests(context),
                child: Text(
                  isArabic
                      ? 'عرض ${pendingRequests.length - 1} طلبات أخرى'
                      : 'View ${pendingRequests.length - 1} more requests',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _navigateToUpgradeRequests(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<PlansCubit>(),
          child: const UpgradeRequestsView(),
        ),
      ),
    );

    // ✅ Reload data when returning
    if (mounted) {
      _loadInitialData();
    }
  }

  Widget _buildBillingPeriodSelector(
    PlansState state,
    bool isDarkMode,
    bool isArabic,
  ) {
    return SizedBox(
      height: 50.h,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        scrollDirection: Axis.horizontal,
        itemCount: BillingPeriod.values.length,
        itemBuilder: (context, index) {
          final period = BillingPeriod.values[index];
          final isSelected = state.selectedBillingPeriod == period;

          return GestureDetector(
            onTap: () => context.read<PlansCubit>().selectBillingPeriod(period),
            child: Container(
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDarkMode ? Colors.grey[800] : Colors.grey[200]),
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  isArabic ? period.nameAr : period.nameEn,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : (isDarkMode ? Colors.white : Colors.black),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(String? errorMessage, bool isArabic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            errorMessage ??
                (isArabic ? 'حدث خطأ في تحميل الخطط' : 'Error loading plans'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.sp),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => context.read<PlansCubit>().loadStudentPlans(),
            child: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isArabic) {
    return Center(
      child: Text(
        isArabic ? 'لا توجد خطط متاحة' : 'No plans available',
        style: TextStyle(fontSize: 16.sp),
      ),
    );
  }

  Future<void> _showPlanDetails(BuildContext context, plan) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<PlansCubit>(),
        child: PlanDetailsBottomSheet(plan: plan),
      ),
    );

    // ✅ Reload data لما الـ sheet يقفل
    if (mounted) {
      _loadInitialData();
    }
  }

  /// Gets the first scheduled upgrade request (if any)
  UpgradeRequestModel? _getScheduledRequest(PlansState state) {
    final scheduled = state.upgradeRequests
        .where((r) => r.isScheduled)
        .toList();
    return scheduled.isNotEmpty ? scheduled.first : null;
  }

  Widget _buildCancelSubscriptionButton(bool isDarkMode, bool isArabic) {
    return BlocBuilder<PlansCubit, PlansState>(
      builder: (context, state) {
        final isCancelling =
            state.cancelUpgradeStatus == CancelUpgradeStatus.cancelling;

        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isCancelling
                ? null
                : () => _showCancelConfirmationDialog(context, isArabic),
            icon: isCancelling
                ? SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.red,
                    ),
                  )
                : Icon(Icons.cancel_outlined, size: 18.sp),
            label: Text(
              isArabic ? 'إلغاء الاشتراك' : 'Cancel Subscription',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCancelConfirmationDialog(BuildContext context, bool isArabic) {
    final reasonController = TextEditingController();
    final feedbackController = TextEditingController();
    final isDarkMode = context.isDarkMode;

    showDialog(
      context: context,
      builder: (dialogContext) => _CancelSubscriptionDialog(
        isDarkMode: isDarkMode,
        isArabic: isArabic,
        reasonController: reasonController,
        feedbackController: feedbackController,
        onConfirm: ({required bool immediate, required bool requestRefund}) {
          Navigator.pop(dialogContext);
          final reason = reasonController.text.trim();
          final feedback = feedbackController.text.trim();
          context.read<PlansCubit>().cancelCurrentSubscription(
            reason: reason.isEmpty ? 'User requested cancellation' : reason,
            immediate: immediate,
            requestRefund: requestRefund,
            feedback: feedback,
          );
        },
        onCancel: () => Navigator.pop(dialogContext),
      ),
    );
  }

  Widget _buildScheduledPlanBadge(
    UpgradeRequestModel scheduledRequest,
    bool isDarkMode,
    bool isArabic,
  ) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withValues(alpha: 0.1),
            Colors.blue.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.schedule, color: Colors.blue, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'الخطة المجدولة' : 'Scheduled Plan',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  scheduledRequest.newPlanName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  isArabic
                      ? 'ستبدأ بعد انتهاء الخطة الحالية'
                      : 'Starts after current plan expires',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Cancel scheduled plan button
          if (scheduledRequest.canCancel)
            IconButton(
              onPressed: () =>
                  _cancelScheduledPlan(context, scheduledRequest, isArabic),
              icon: Icon(
                Icons.close,
                color: Colors.red.withValues(alpha: 0.7),
                size: 20.sp,
              ),
              tooltip: isArabic ? 'إلغاء الجدولة' : 'Cancel scheduled plan',
            ),
        ],
      ),
    );
  }

  void _cancelScheduledPlan(
    BuildContext context,
    UpgradeRequestModel request,
    bool isArabic,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        backgroundColor: context.isDarkMode
            ? AppColors.darkBackground
            : Colors.white,
        title: Text(
          isArabic ? 'إلغاء الخطة المجدولة' : 'Cancel Scheduled Plan',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: context.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          isArabic
              ? 'هل تريد إلغاء جدولة "${request.newPlanName}"؟\nستبقى على خطتك الحالية.'
              : 'Cancel the scheduled switch to "${request.newPlanName}"?\nYou will stay on your current plan.',
          style: TextStyle(
            fontSize: 14.sp,
            color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              isArabic ? 'تراجع' : 'Go Back',
              style: TextStyle(
                color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<PlansCubit>().cancelUpgradeRequest(
                upgradeRequestId: request.id,
                reason: 'User cancelled scheduled plan switch',
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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _handleStateChanges(BuildContext context, PlansState state) {
    if (state.cancelUpgradeStatus == CancelUpgradeStatus.success) {
      context.showSuccessSnackBar(
        context.isArabic
            ? 'تم إلغاء الاشتراك بنجاح'
            : 'Subscription cancelled successfully',
      );
      context.read<PlansCubit>().resetCancelUpgradeStatus();

      // ✅ Reload كل البيانات
      _loadInitialData();
    }

    // ✅ Handle cancel subscription error
    if (state.cancelUpgradeStatus == CancelUpgradeStatus.error) {
      context.showErrorSnackBar(
        state.errorMessage ??
            (context.isArabic
                ? 'فشل إلغاء الاشتراك'
                : 'Failed to cancel subscription'),
      );
      context.read<PlansCubit>().resetCancelUpgradeStatus();
    }
  }
}

/// Stateful dialog for cancel subscription with immediate/refund toggles
class _CancelSubscriptionDialog extends StatefulWidget {
  final bool isDarkMode;
  final bool isArabic;
  final TextEditingController reasonController;
  final TextEditingController feedbackController;
  final void Function({required bool immediate, required bool requestRefund})
  onConfirm;
  final VoidCallback onCancel;

  const _CancelSubscriptionDialog({
    required this.isDarkMode,
    required this.isArabic,
    required this.reasonController,
    required this.feedbackController,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<_CancelSubscriptionDialog> createState() =>
      _CancelSubscriptionDialogState();
}

class _CancelSubscriptionDialogState extends State<_CancelSubscriptionDialog> {
  bool _immediate = true;
  bool _requestRefund = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.isDarkMode
          ? AppColors.darkBackground
          : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              widget.isArabic ? 'تأكيد إلغاء الاشتراك' : 'Confirm Cancellation',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isArabic
                  ? 'هل أنت متأكد من إلغاء اشتراكك؟ ستفقد الوصول إلى المميزات المدفوعة.'
                  : 'Are you sure you want to cancel? You will lose access to premium features.',
              style: TextStyle(
                fontSize: 14.sp,
                color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            SizedBox(height: 16.h),

            // Immediate toggle
            _buildToggleOption(
              title: widget.isArabic ? 'إلغاء فوري' : 'Cancel Immediately',
              subtitle: widget.isArabic
                  ? 'سيتم الإلغاء الآن وستفقد الوصول فوراً'
                  : 'Cancel now and lose access immediately',
              value: _immediate,
              onChanged: (val) => setState(() => _immediate = val),
            ),
            SizedBox(height: 8.h),

            // Request refund toggle
            _buildToggleOption(
              title: widget.isArabic ? 'طلب استرداد' : 'Request Refund',
              subtitle: widget.isArabic
                  ? 'طلب استرداد المبلغ المتبقي'
                  : 'Request a refund for remaining period',
              value: _requestRefund,
              onChanged: (val) => setState(() => _requestRefund = val),
            ),
            SizedBox(height: 16.h),

            // Reason field
            TextField(
              controller: widget.reasonController,
              maxLines: 2,
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: widget.isArabic
                    ? 'سبب الإلغاء (اختياري)'
                    : 'Reason for cancellation (optional)',
                hintStyle: TextStyle(
                  color: widget.isDarkMode
                      ? Colors.grey[500]
                      : Colors.grey[400],
                ),
                filled: true,
                fillColor: widget.isDarkMode
                    ? Colors.grey[850]
                    : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // Feedback field
            TextField(
              controller: widget.feedbackController,
              maxLines: 2,
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: widget.isArabic
                    ? 'ملاحظات إضافية (اختياري)'
                    : 'Additional feedback (optional)',
                hintStyle: TextStyle(
                  color: widget.isDarkMode
                      ? Colors.grey[500]
                      : Colors.grey[400],
                ),
                filled: true,
                fillColor: widget.isDarkMode
                    ? Colors.grey[850]
                    : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: Text(
            widget.isArabic ? 'تراجع' : 'Go Back',
            style: TextStyle(
              color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => widget.onConfirm(
            immediate: _immediate,
            requestRefund: _requestRefund,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Text(
            widget.isArabic ? 'تأكيد الإلغاء' : 'Confirm',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleOption({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: widget.isDarkMode
                        ? Colors.grey[500]
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: Colors.red.withValues(alpha: 0.5),
            activeThumbColor: Colors.red,
          ),
        ],
      ),
    );
  }
}
