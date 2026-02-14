import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/core.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/models/upgrade_request_model.dart';
import '../logic/plans/plans_cubit.dart';
import '../logic/plans/plans_state.dart';
import '../widgets/upgrade_request_card.dart';

class UpgradeRequestsView extends StatefulWidget {
  const UpgradeRequestsView({super.key});

  @override
  State<UpgradeRequestsView> createState() => _UpgradeRequestsViewState();
}

class _UpgradeRequestsViewState extends State<UpgradeRequestsView> {
  @override
  void initState() {
    super.initState();
    context.read<PlansCubit>().loadUpgradeRequests();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    final isArabic = context.isArabic;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : Colors.grey[50],
      appBar: CustomAppBar(
        title: isArabic ? 'طلبات الترقية' : 'Upgrade Requests',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: BlocConsumer<PlansCubit, PlansState>(
        listener: (context, state) {
          // Handle cancel success
          if (state.cancelUpgradeStatus == CancelUpgradeStatus.success) {
            context.showSuccessSnackBar(
              isArabic
                  ? 'تم إلغاء الطلب بنجاح'
                  : 'Request cancelled successfully',
            );
            context.read<PlansCubit>().resetCancelUpgradeStatus();
          }
          // Handle cancel error
          if (state.cancelUpgradeStatus == CancelUpgradeStatus.error) {
            context.showErrorSnackBar(
              state.errorMessage ??
                  (isArabic ? 'فشل إلغاء الطلب' : 'Failed to cancel request'),
            );
            context.read<PlansCubit>().resetCancelUpgradeStatus();
          }
        },
        builder: (context, state) {
          if (state.upgradeRequestsStatus == UpgradeRequestsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.upgradeRequestsStatus == UpgradeRequestsStatus.error) {
            return _buildErrorState(state.errorMessage, isArabic);
          }

          if (state.upgradeRequests.isEmpty) {
            return _buildEmptyState(isDarkMode, isArabic);
          }

          return _buildContent(state, isDarkMode, isArabic);
        },
      ),
    );
  }

  Widget _buildContent(PlansState state, bool isDarkMode, bool isArabic) {
    return RefreshIndicator(
      onRefresh: () => context.read<PlansCubit>().loadUpgradeRequests(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.upgradeStatistics != null)
              _buildStatisticsCard(state, isDarkMode, isArabic),
            SizedBox(height: 20.h),
            Text(
              isArabic ? 'جميع الطلبات' : 'All Requests',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 12.h),
            ...state.upgradeRequests.map(
              (request) => UpgradeRequestCard(
                request: request,
                isCancelling:
                    state.cancelUpgradeStatus == CancelUpgradeStatus.cancelling,
                onCancel: request.canCancel
                    ? () => _showCancelDialog(context, request.id, isArabic)
                    : null,
                onRetry: request.canRetry
                    ? () {
                        // TODO: Implement retry logic
                      }
                    : null,
                // إضافة callback للدفع
                onPayNow:
                    (request.isPendingPayment &&
                        request.invoiceKey != null &&
                        request.invoiceKey!.isNotEmpty)
                    ? () => _navigateToPayment(context, request)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToPayment(
    BuildContext context,
    UpgradeRequestModel request,
  ) async {
    // ✅ تحقق من وجود paymentUrl أو invoiceKey
    String? paymentUrl = request.paymentUrl;

    // إذا ما كان في paymentUrl من الباك إند، استخدم invoiceKey مباشرة
    if (paymentUrl == null || paymentUrl.isEmpty) {
      if (request.invoiceKey == null || request.invoiceKey!.isEmpty) {
        context.showErrorSnackBar(
          context.isArabic
              ? 'رابط الدفع غير متوفر'
              : 'Payment URL not available',
        );
        return;
      }
      // استخدم invoiceKey كـ URL مباشرة (إذا كان الباك إند يرسل URL كامل في invoiceKey)
      paymentUrl = request.invoiceKey!;
    }

    log('Opening payment URL: $paymentUrl');

    // فتح رابط الدفع في المتصفح الخارجي
    final uri = Uri.parse(paymentUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      // تحديث قائمة الطلبات عند العودة
      if (context.mounted) {
        context.read<PlansCubit>().loadUpgradeRequests();
      }
    } else {
      if (context.mounted) {
        context.showErrorSnackBar(
          context.isArabic ? 'تعذر فتح المتصفح' : 'Could not open browser',
        );
      }
    }
  }

  Widget _buildStatisticsCard(
    PlansState state,
    bool isDarkMode,
    bool isArabic,
  ) {
    final stats = state.upgradeStatistics!;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'إحصائيات الطلبات' : 'Request Statistics',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildStatItem(
                isArabic ? 'معلقة' : 'Pending',
                stats.pending.toString(),
                Colors.orange,
                isDarkMode,
              ),
              _buildStatItem(
                isArabic ? 'مكتملة' : 'Completed',
                stats.completed.toString(),
                Colors.green,
                isDarkMode,
              ),
              _buildStatItem(
                isArabic ? 'فاشلة' : 'Failed',
                stats.failed.toString(),
                Colors.red,
                isDarkMode,
              ),
              _buildStatItem(
                isArabic ? 'ملغاة' : 'Cancelled',
                stats.cancelled.toString(),
                Colors.grey,
                isDarkMode,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    bool isDarkMode,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode, bool isArabic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80.sp,
            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            isArabic ? 'لا توجد طلبات ترقية' : 'No upgrade requests',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            isArabic
                ? 'عند الاشتراك في خطة جديدة ستظهر هنا'
                : 'When you subscribe to a new plan, it will appear here',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(
    BuildContext context,
    String requestId,
    bool isArabic,
  ) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isArabic ? 'إلغاء الطلب' : 'Cancel Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isArabic
                  ? 'هل أنت متأكد من إلغاء هذا الطلب؟'
                  : 'Are you sure you want to cancel this request?',
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: isArabic
                    ? 'سبب الإلغاء (اختياري)'
                    : 'Reason (optional)',
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(isArabic ? 'لا' : 'No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<PlansCubit>().cancelUpgradeRequest(
                upgradeRequestId: requestId,
                reason: reasonController.text.isNotEmpty
                    ? reasonController.text
                    : 'User requested cancellation',
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              isArabic ? 'نعم، إلغاء' : 'Yes, Cancel',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
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
                (isArabic
                    ? 'حدث خطأ في تحميل الطلبات'
                    : 'Error loading requests'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.sp),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => context.read<PlansCubit>().loadUpgradeRequests(),
            child: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
          ),
        ],
      ),
    );
  }
}
