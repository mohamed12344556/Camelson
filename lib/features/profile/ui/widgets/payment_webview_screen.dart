import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String upgradeRequestId;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.upgradeRequestId,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            log('Page started loading: $url');
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });

            _handleUrlChange(url);
          },
          onPageFinished: (String url) {
            log('Page finished loading: $url');
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            log('WebView error: ${error.description}');
            setState(() {
              _isLoading = false;
              _errorMessage = error.description;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            log('Navigation request: $url');

            if (url.startsWith('eolapp://')) {
              _handleDeepLink(url);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _handleUrlChange(String url) {
    if (url.contains('/api/fawaterk/success') || 
        url.contains('/api/fawaterk/failed') ||
        url.contains('payment/success') || 
        url.contains('payment/failed')) {
      
      final uri = Uri.parse(url);
      final invoiceId = uri.queryParameters['invoice_id'];
      
      log('Payment callback detected: $url');
      log('Invoice ID: $invoiceId');

      final isSuccess = url.contains('success');
      
      _returnToApp(isSuccess, invoiceId);
    }
  }

  void _handleDeepLink(String deepLink) {
    log('Deep link intercepted: $deepLink');
    
    final uri = Uri.parse(deepLink);
    final isSuccess = uri.path.contains('success');
    final invoiceId = uri.queryParameters['invoice_id'] ?? 
                      uri.queryParameters['upgradeRequestId'];
    
    _returnToApp(isSuccess, invoiceId);
  }

  void _returnToApp(bool isSuccess, String? invoiceId) {
    if (!mounted) return;

    Navigator.of(context).pop({
      'success': isSuccess,
      'invoiceId': invoiceId ?? widget.upgradeRequestId,
      'upgradeRequestId': widget.upgradeRequestId,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    final isArabic = context.isArabic;

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await _showCancelDialog(isArabic);
        return shouldPop ?? false;
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? AppColors.darkBackground : Colors.white,
        appBar: CustomAppBar(
          title: isArabic ? 'إتمام الدفع' : 'Complete Payment',
          onBackPressed: () async {
            final shouldPop = await _showCancelDialog(isArabic);
            if (shouldPop == true && mounted) {
              Navigator.of(context).pop({'success': false, 'cancelled': true});
            }
          },
        ),
        body: Stack(
          children: [
            if (_errorMessage != null)
              _buildErrorView(isArabic)
            else
              WebViewWidget(controller: _controller),
            
            if (_isLoading) _buildLoadingOverlay(isArabic),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(bool isArabic) {
    return Container(
      color: Colors.white.withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 16.h),
            Text(
              isArabic ? 'جاري تحميل بوابة الدفع...' : 'Loading payment gateway...',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(bool isArabic) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: Colors.red,
            ),
            SizedBox(height: 16.h),
            Text(
              isArabic ? 'حدث خطأ في تحميل الصفحة' : 'Failed to load page',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              _errorMessage ?? '',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _initializeWebView();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0961F5),
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              ),
              child: Text(
                isArabic ? 'إعادة المحاولة' : 'Retry',
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showCancelDialog(bool isArabic) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'إلغاء الدفع' : 'Cancel Payment'),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من إلغاء عملية الدفع؟'
              : 'Are you sure you want to cancel the payment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(isArabic ? 'لا' : 'No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(isArabic ? 'نعم، إلغاء' : 'Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
