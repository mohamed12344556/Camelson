import 'dart:convert';
import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/data/models/auth_request.dart';
import '../cache/shared_pref_helper.dart';
import '../constants/key_strings.dart';
import 'api_service.dart';
import 'dio_factory.dart';

class TokenPair {
  final String accessToken;
  final String refreshToken;

  const TokenPair({
    required this.accessToken,
    required this.refreshToken,
  });
}

class TokenManager {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      if (accessToken.isEmpty || refreshToken.isEmpty) {
        throw const StorageException('Invalid tokens received');
      }

      await Future.wait(<Future<dynamic>>[
        _storage.write(key: StorageKeys.accessToken, value: accessToken),
        _storage.write(key: StorageKeys.refreshToken, value: refreshToken),
        SharedPrefHelper.setData(StorageKeys.isLoggedIn, true),
      ]);

      AppState.isLoggedIn = true;
      DioFactory.setAuthHeader(accessToken);
      
      // تسجيل معلومات انتهاء صلاحية التوكن الجديد
      await logTokenExpiryInfo(accessToken);
    } catch (e) {
      throw StorageException('Failed to save tokens: $e');
    }
  }

  static Future<TokenPair?> getTokens() async {
    try {
      final accessToken = await _storage.read(key: StorageKeys.accessToken);
      final refreshToken = await _storage.read(key: StorageKeys.refreshToken);
      // log('accessToken: $accessToken, refreshToken: $refreshToken');
      if (accessToken == null || refreshToken == null) return null;

      return TokenPair(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearTokens() async {
    try {
      await Future.wait(<Future<dynamic>>[
        _storage.delete(key: StorageKeys.accessToken),
        _storage.delete(key: StorageKeys.refreshToken),
        SharedPrefHelper.setData(StorageKeys.isLoggedIn, false),
      ]);
      AppState.isLoggedIn = false;
      DioFactory.clearAuthHeaders();
    } catch (e) {
      throw StorageException('Failed to clear tokens: $e');
    }
  }

  static bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payload));
      final data = json.decode(decoded);

      if (!data.containsKey('exp')) return true;

      final expiry = DateTime.fromMillisecondsSinceEpoch(data['exp'] * 1000);
      // إضافة هامش أمان 30 ثانية قبل انتهاء الصلاحية
      return DateTime.now()
          .isAfter(expiry.subtract(const Duration(seconds: 30)));
    } catch (e) {
      return true;
    }
  }

  static Future<bool> hasValidTokens() async {
    try {
      final tokens = await getTokens();
      if (tokens == null) {
        AppState.isLoggedIn = false;
        await SharedPrefHelper.setData(StorageKeys.isLoggedIn, false);
        return false;
      }

      final isValid = !isTokenExpired(tokens.accessToken);

      if (isValid) {
        AppState.isLoggedIn = true;
        DioFactory.setAuthHeader(tokens.accessToken);
        return true;
      }

      // Access token expired, try to refresh
      log('Access token expired, attempting refresh...');

      try {
        final cleanDio = DioFactory.getCleanDio();
        final apiService = ApiService(cleanDio);
        final refreshed = await attemptTokenRefresh(apiService);

        if (refreshed) {
          log('Token refresh successful in hasValidTokens');
          return true;
        }
      } catch (e) {
        log('Token refresh failed in hasValidTokens: $e');
      }

      // Refresh failed
      AppState.isLoggedIn = false;
      await SharedPrefHelper.setData(StorageKeys.isLoggedIn, false);
      return false;
    } catch (e) {
      AppState.isLoggedIn = false;
      await SharedPrefHelper.setData(StorageKeys.isLoggedIn, false);
      return false;
    }
  }

  static Future<Duration?> getTokenTimeRemaining() async {
    try {
      final tokens = await getTokens();
      if (tokens == null) return null;

      final token = tokens.accessToken;
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payload));
      final data = json.decode(decoded);

      if (!data.containsKey('exp')) return null;

      final expiryDate =
          DateTime.fromMillisecondsSinceEpoch(data['exp'] * 1000);
      return expiryDate.difference(DateTime.now());
    } catch (e) {
      return null;
    }
  }

  static Future<void> checkTokenExpiry() async {
    final timeRemaining = await TokenManager.getTokenTimeRemaining();
    if (timeRemaining != null) {
      if (timeRemaining.isNegative) {
        log('التوكن منتهي الصلاحية');
      } else {
        final minutes = timeRemaining.inMinutes;
        final seconds = timeRemaining.inSeconds % 60;
        log('الوقت المتبقي للتوكن: $minutes دقيقة و $seconds ثانية');
      }
    } else {
      log('لا يوجد توكن أو حدث خطأ في قراءته');
    }
  }

  static Future<bool> hasTokens() async {
    final tokens = await getTokens();
    return tokens != null;
  }

  /// Attempts to refresh the access token using the stored refresh token
  /// Returns true if refresh succeeded, false otherwise
  static Future<bool> attemptTokenRefresh(ApiService apiService) async {
    try {
      log('Attempting token refresh...');

      final tokens = await getTokens();
      if (tokens == null) {
        log('No tokens available for refresh');
        return false;
      }

      // Check if access token is actually expired
      if (!isTokenExpired(tokens.accessToken)) {
        log('Access token is still valid, no refresh needed');
        return true;
      }

      // Create refresh token request
      final refreshRequest = AuthRequest.refreshToken(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      // Call refresh token endpoint
      final response = await apiService.refreshToken(refreshRequest);

      if (response.isSuccess && response.data != null) {
        // Save new tokens
        await saveTokens(
          accessToken: response.data!.accessToken!,
          refreshToken: response.data!.refreshToken!,
        );

        AppState.isLoggedIn = true;
        await SharedPrefHelper.setData(StorageKeys.isLoggedIn, true);

        log('Token refresh successful');
        return true;
      } else {
        log('Token refresh failed: ${response.message}');
        // Clear invalid tokens
        await clearTokens();
        return false;
      }
    } catch (e) {
      log('Error during token refresh: $e');
      // Clear tokens on error
      await clearTokens();
      return false;
    }
  }

  // دالة جديدة لاستخراج وقت انتهاء التوكن كتاريخ
  static Future<DateTime?> getTokenExpiryDate(String token) async {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payload));
      final data = json.decode(decoded);

      if (!data.containsKey('exp')) return null;

      return DateTime.fromMillisecondsSinceEpoch(data['exp'] * 1000);
    } catch (e) {
      log('خطأ في استخراج تاريخ انتهاء التوكن: $e');
      return null;
    }
  }
  
  // دالة لتسجيل معلومات انتهاء التوكن
  static Future<void> logTokenExpiryInfo(String token) async {
    final expiryDate = await getTokenExpiryDate(token);
    if (expiryDate != null) {
      final now = DateTime.now();
      final difference = expiryDate.difference(now);
      
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      
      log('تم تجديد التوكن - تاريخ الانتهاء: $expiryDate');
      log('الوقت المتبقي: $hours ساعة و $minutes دقيقة');
    }
  }
}

class StorageException implements Exception {
  final String message;
  const StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}