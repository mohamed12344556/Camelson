import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';

class DeepLinkingService {
  static final DeepLinkingService _instance = DeepLinkingService._internal();
  factory DeepLinkingService() => _instance;
  DeepLinkingService._internal();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  
  Function(String status, String? invoiceId)? onPaymentCallback;

  Future<void> initialize() async {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        log('📱 Deep link received: $uri');
        _handleDeepLink(uri);
      },
      onError: (err) {
        log('Deep link error: $err');
      },
    );

    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        log('📱 Initial deep link: $initialLink');
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      log('Error getting initial link: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    log('Processing deep link: ${uri.toString()}');
    log('   Scheme: ${uri.scheme}');
    log('   Host: ${uri.host}');
    log('   Path: ${uri.path}');
    log('   Query: ${uri.queryParameters}');

    // Custom URL Scheme للدفع
    if (uri.scheme == 'eolapp' && uri.host == 'payment') {
      _handlePaymentCallback(uri);
      return;
    }

    // App Links من الدومين
    if (uri.host == 'test-mh.runasp.net') {
      _handleAppLink(uri);
    }
  }

  void _handleAppLink(Uri uri) {
    final path = uri.path;
    log('App link path: $path');

    // Payment callback من الويب
    if (path.startsWith('/payment')) {
      _handlePaymentCallback(uri);
      return;
    }

    // Share links - يمكن إضافة المزيد حسب الحاجة
    if (onShareCallback != null) {
      onShareCallback!(uri);
    }
  }

  Function(Uri uri)? onShareCallback;

  void registerShareCallback(Function(Uri uri) callback) {
    onShareCallback = callback;
    log('Share callback registered');
  }

  void unregisterShareCallback() {
    onShareCallback = null;
  }

  void _handlePaymentCallback(Uri uri) {
    final path = uri.path.replaceFirst('/', '');
    final invoiceId = uri.queryParameters['invoice_id'] ?? 
                      uri.queryParameters['upgradeRequestId'];

    log('💳 Payment callback: $path, Invoice: $invoiceId');

    if (onPaymentCallback != null) {
      onPaymentCallback!(path, invoiceId);
    }
  }

  void registerPaymentCallback(Function(String status, String? invoiceId) callback) {
    onPaymentCallback = callback;
    log('✅ Payment callback registered');
  }

  void unregisterPaymentCallback() {
    onPaymentCallback = null;
    log('❌ Payment callback unregistered');
  }

  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }
}
