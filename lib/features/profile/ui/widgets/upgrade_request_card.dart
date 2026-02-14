import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/core.dart';
import '../../data/models/upgrade_request_model.dart';

class UpgradeRequestCard extends StatelessWidget {
  final UpgradeRequestModel request;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;
  final VoidCallback? onPayNow;
  final bool isCompact;
  final bool isCancelling;

  const UpgradeRequestCard({
    super.key,
    required this.request,
    this.onTap,
    this.onCancel,
    this.onRetry,
    this.onPayNow,
    this.isCompact = false,
    this.isCancelling = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    final isArabic = context.isArabic;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: isCompact ? 0 : 12.h),
        padding: EdgeInsets.all(isCompact ? 12.w : 16.w),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: _getStatusColor().withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: isCompact
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: isCompact
            ? _buildCompactContent(isDarkMode, isArabic)
            : _buildFullContent(isDarkMode, isArabic),
      ),
    );
  }

  Widget _buildCompactContent(bool isDarkMode, bool isArabic) {
    return Row(
      children: [
        _buildStatusIcon(),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                request.newPlanName,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                _getStatusText(isArabic),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: _getStatusColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Text(
          '${request.amount} ${request.currency}',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  // Widget _buildFullContent(bool isDarkMode, bool isArabic) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         children: [
  //           _buildStatusIcon(),
  //           SizedBox(width: 12.w),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   request.newPlanName,
  //                   style: TextStyle(
  //                     fontSize: 16.sp,
  //                     fontWeight: FontWeight.bold,
  //                     color: isDarkMode ? Colors.white : Colors.black,
  //                   ),
  //                 ),
  //                 SizedBox(height: 4.h),
  //                 _buildStatusBadge(isArabic),
  //               ],
  //             ),
  //           ),
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.end,
  //             children: [
  //               Text(
  //                 '${request.amount}',
  //                 style: TextStyle(
  //                   fontSize: 18.sp,
  //                   fontWeight: FontWeight.bold,
  //                   color: AppColors.primary,
  //                 ),
  //               ),
  //               Text(
  //                 request.currency,
  //                 style: TextStyle(
  //                   fontSize: 12.sp,
  //                   color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //       SizedBox(height: 12.h),
  //       Divider(color: isDarkMode ? Colors.grey[700] : Colors.grey[300]),
  //       SizedBox(height: 12.h),
  //       _buildInfoRow(
  //         isArabic ? 'نوع الترقية' : 'Upgrade Type',
  //         request.upgradeType,
  //         isDarkMode,
  //       ),
  //       SizedBox(height: 8.h),
  //       _buildInfoRow(
  //         isArabic ? 'فترة الفوترة' : 'Billing Period',
  //         request.billingPeriod,
  //         isDarkMode,
  //       ),
  //       SizedBox(height: 8.h),
  //       _buildInfoRow(
  //         isArabic ? 'تاريخ الطلب' : 'Request Date',
  //         _formatDate(request.createdAt),
  //         isDarkMode,
  //       ),
  //       if (request.canCancel || request.canRetry) ...[
  //         SizedBox(height: 12.h),
  //         Row(
  //           children: [
  //             if (request.canRetry)
  //               Expanded(
  //                 child: OutlinedButton.icon(
  //                   onPressed: onRetry,
  //                   icon: Icon(Icons.refresh, size: 18.sp),
  //                   label: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
  //                   style: OutlinedButton.styleFrom(
  //                     foregroundColor: Colors.orange,
  //                     side: const BorderSide(color: Colors.orange),
  //                   ),
  //                 ),
  //               ),
  //             if (request.canCancel && request.canRetry) SizedBox(width: 8.w),
  //             if (request.canCancel)
  //               Expanded(
  //                 child: OutlinedButton.icon(
  //                   onPressed: isCancelling ? null : onCancel,
  //                   icon: isCancelling
  //                       ? SizedBox(
  //                           width: 18.sp,
  //                           height: 18.sp,
  //                           child: const CircularProgressIndicator(
  //                             strokeWidth: 2,
  //                             color: Colors.red,
  //                           ),
  //                         )
  //                       : Icon(Icons.close, size: 18.sp),
  //                   label: Text(
  //                     isCancelling
  //                         ? (isArabic ? 'جاري الإلغاء...' : 'Cancelling...')
  //                         : (isArabic ? 'إلغاء' : 'Cancel'),
  //                   ),
  //                   style: OutlinedButton.styleFrom(
  //                     foregroundColor: Colors.red,
  //                     side: const BorderSide(color: Colors.red),
  //                   ),
  //                 ),
  //               ),
  //           ],
  //         ),
  //       ],
  //     ],
  //   );
  // }

  Widget _buildFullContent(bool isDarkMode, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildStatusIcon(),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.newPlanName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  _buildStatusBadge(isArabic),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${request.amount}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  request.currency,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Divider(color: isDarkMode ? Colors.grey[700] : Colors.grey[300]),
        SizedBox(height: 12.h),
        _buildInfoRow(
          isArabic ? 'نوع الترقية' : 'Upgrade Type',
          request.upgradeType,
          isDarkMode,
        ),
        SizedBox(height: 8.h),
        _buildInfoRow(
          isArabic ? 'فترة الفوترة' : 'Billing Period',
          request.billingPeriod,
          isDarkMode,
        ),
        SizedBox(height: 8.h),
        _buildInfoRow(
          isArabic ? 'تاريخ الطلب' : 'Request Date',
          _formatDate(request.createdAt),
          isDarkMode,
        ),

        // زر Pay Now للطلبات المعلقة للدفع
        if (request.isPendingPayment &&
            request.invoiceKey != null &&
            request.invoiceKey!.isNotEmpty) ...[
          SizedBox(height: 12.h),
          ElevatedButton.icon(
            onPressed: onPayNow,
            icon: Icon(Icons.payment, size: 18.sp),
            label: Text(isArabic ? 'ادفع الآن' : 'Pay Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 44.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],

        // أزرار الإلغاء والإعادة
        if (request.canCancel || request.canRetry) ...[
          SizedBox(height: 12.h),
          Row(
            children: [
              if (request.canRetry)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: Icon(Icons.refresh, size: 18.sp),
                    label: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                    ),
                  ),
                ),
              if (request.canCancel && request.canRetry) SizedBox(width: 8.w),
              if (request.canCancel)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isCancelling ? null : onCancel,
                    icon: isCancelling
                        ? SizedBox(
                            width: 18.sp,
                            height: 18.sp,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.red,
                            ),
                          )
                        : Icon(Icons.close, size: 18.sp),
                    label: Text(
                      isCancelling
                          ? (isArabic ? 'جاري الإلغاء...' : 'Cancelling...')
                          : (isArabic ? 'إلغاء' : 'Cancel'),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStatusIcon() {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(_getStatusIcon(), color: _getStatusColor(), size: 20.sp),
    );
  }

  Widget _buildStatusBadge(bool isArabic) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        _getStatusText(isArabic),
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
          color: _getStatusColor(),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (request.status) {
      case 'PaymentPending':
        return Colors.orange;
      case 'Completed':
        return Colors.green;
      case 'Failed':
        return Colors.red;
      case 'Cancelled':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon() {
    switch (request.status) {
      case 'PaymentPending':
        return Icons.pending_actions;
      case 'Completed':
        return Icons.check_circle;
      case 'Failed':
        return Icons.error;
      case 'Cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _getStatusText(bool isArabic) {
    switch (request.status) {
      case 'PaymentPending':
        return isArabic ? 'في انتظار الدفع' : 'Payment Pending';
      case 'Completed':
        return isArabic ? 'مكتمل' : 'Completed';
      case 'Failed':
        return isArabic ? 'فشل' : 'Failed';
      case 'Cancelled':
        return isArabic ? 'ملغي' : 'Cancelled';
      default:
        return request.status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
