import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../features/auth/data/models/auth_request.dart';
import '../../features/community/data/models/community_constants.dart';
import '../core.dart';
import '../services/user_service.dart';
import 'api_constants.dart';
import 'api_service.dart';
import 'token_manager.dart';

class AuthInterceptor extends Interceptor {
  final bool shouldRefresh;
  bool _isRefreshing = false;

  AuthInterceptor({this.shouldRefresh = true});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final tokens = await TokenManager.getTokens();

    if (tokens != null) {
      options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';

      // تطبيق ملف تعريف الارتباط للطلبات المرتبطة بالتوكن
      if (_isRefreshEndpoint(options.path)) {
        options.headers['Cookie'] = 'RefreshToken=${tokens.refreshToken}';
      }
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    developer.log('خطأ بالطلب: ${err.requestOptions.path}');
    developer.log('كود الخطأ: ${err.response?.statusCode}');

    // التحقق من كون الخطأ 401 وليس بالفعل محاولة تجديد توكن
    if (err.response?.statusCode == 401 &&
        shouldRefresh &&
        !_isRefreshing &&
        !_isRefreshEndpoint(err.requestOptions.path)) {

      // Check if user has tokens before trying to refresh
      final tokens = await TokenManager.getTokens();

      // If no tokens, this is a public endpoint that requires authentication
      // Just pass the error through without logging out
      if (tokens == null) {
        return handler.next(err);
      }

      _isRefreshing = true;
      try {
        final result = await _handleTokenRefresh(err.requestOptions);
        _isRefreshing = false;
        return handler.resolve(result);
      } catch (e) {
        developer.log('فشل تجديد التوكن: $e');
        _isRefreshing = false;
        await _handleAuthError();
        // في هذه الحالة، قد تكون تم توجيه المستخدم للتسجيل أو تم تجديد التوكن
        // نعيد إرسال الخطأ الأصلي
        return handler.reject(err);
      }
    }
    return handler.next(err);
  }

  Future<Response<dynamic>> _handleTokenRefresh(
    RequestOptions originalRequest,
  ) async {
    final tokens = await TokenManager.getTokens();
    if (tokens == null) {
      throw const AuthException('No tokens available for refresh');
    }

    try {
      // استخدام ApiService بدلاً من الاتصال المباشر
      final cleanDio = DioFactory.getCleanDio();
      final apiService = ApiService(cleanDio);

      // إنشاء request body للـ refresh token
      final refreshRequest = AuthRequest.refreshToken(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      // استدعاء دالة تجديد التوكن
      final authResponse = await apiService.refreshToken(refreshRequest);

      // تسجيل استجابة API
      developer.log('استجابة تجديد التوكن: ${authResponse.isSuccess}');

      // التحقق من الاستجابة
      if (authResponse.isSuccess == true && authResponse.data != null) {
        final authData = authResponse.data;
        final newAccessToken = authData?.accessToken;
        final newRefreshToken = authData?.refreshToken;

        // التحقق من وجود التوكنات
        if (newAccessToken == null ||
            newRefreshToken == null ||
            newAccessToken.isEmpty ||
            newRefreshToken.isEmpty) {
          throw AuthException('لم يتم العثور على توكنات صالحة في الاستجابة');
        }

        // حفظ التوكن الجديد
        await TokenManager.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        // Update Community user from refresh token response if user data is present
        if (authData?.user != null) {
          final communityUser = UserService.convertToCommunityUser(
            authData!.user!,
          );
          CommunityConstants.updateCurrentUser(communityUser);
          developer.log('Token refresh: Community user updated - ${communityUser.name}');
        }

        // تحديث الطلب الأصلي وإعادة المحاولة
        originalRequest.headers['Authorization'] = 'Bearer $newAccessToken';

        final newRequestDio = DioFactory.getCleanDio();
        final opts = Options(
          method: originalRequest.method,
          headers: originalRequest.headers,
        );

        return newRequestDio.request<dynamic>(
          originalRequest.path,
          data: originalRequest.data,
          queryParameters: originalRequest.queryParameters,
          options: opts,
        );
      } else {
        final errorMsg = authResponse.message ?? "خطأ غير معروف";
        throw AuthException('فشل تجديد التوكن: $errorMsg');
      }
    } catch (e) {
      developer.log('خطأ في تجديد التوكن: $e');
      throw AuthException('فشل تجديد التوكن: $e');
    }
  }

  Future<void> _handleAuthError() async {
    // تسجيل الخروج وإعادة التوجيه لصفحة تسجيل الدخول
    await TokenManager.clearTokens();
    DioFactory.resetDio();
    _redirectToLogin();
  }

  void _redirectToLogin() {
    final context = NavigationService.navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.loginView, (route) => false);
    }
  }

  bool _isRefreshEndpoint(String path) {
    return path.contains(ApiConstants.refreshToken);
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}
