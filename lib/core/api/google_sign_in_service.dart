import 'dart:developer';

import 'package:google_sign_in/google_sign_in.dart';

import '../constants/key_strings.dart';
import '../core.dart';

class GoogleSignInService {
  static final GoogleSignIn _googleSignInService = GoogleSignIn.instance;

  /// Sign in with Google
  static Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignInService.authenticate();
      log('Google Sign-in successful: ${account.email}');
      return account;
    } catch (e) {
      log('Google Sign-in error: $e');
      return null;
    }
  }

  /// Sign out from Google
  static Future<void> signOut() async {
    try {
      await _googleSignInService.signOut();
      // Clear Google user data
      await _clearGoogleUserData();
      log('Google Sign-out successful');
    } catch (e) {
      log('Google Sign-out error: $e');
    }
  }

  /// Check if user is signed in
  static Future<bool> isSignedIn() async {
    try {
      final account = await _googleSignInService
          .attemptLightweightAuthentication();
      final hasValidToken = await _hasValidGoogleToken();
      return account != null && hasValidToken;
    } catch (e) {
      log('Error checking Google sign-in status: $e');
      return false;
    }
  }

  /// Get current user
  static Future<GoogleSignInAccount?> getCurrentUser() async {
    try {
      return await _googleSignInService.attemptLightweightAuthentication();
    } catch (e) {
      log('Error getting current Google user: $e');
      return null;
    }
  }

  /// Save Google user data - IMPROVED VERSION
  static Future<void> saveGoogleUserData({
    required GoogleSignInAccount account,
    required String accessToken,
    String? idToken,
  }) async {
    try {
      log('Starting to save Google user data...');

      // تحقق من صحة البيانات قبل الحفظ
      if (accessToken.isEmpty) {
        throw Exception('Access token is empty');
      }

      // حفظ التوكن أولاً
      await SharedPrefHelper.setSecuredString(
        StorageKeys.accessToken,
        accessToken,
      );

      // التحقق من حفظ التوكن
      final savedToken = await SharedPrefHelper.getSecuredString(
        StorageKeys.accessToken,
      );
      if (savedToken.isEmpty) {
        throw Exception('Failed to save access token');
      }
      log('Access token saved and verified successfully');

      // حفظ Google ID Token إذا كان متاحاً
      if (idToken != null && idToken.isNotEmpty) {
        await SharedPrefHelper.setSecuredString(
          StorageKeys.googleIdToken,
          idToken,
        );
        log('Google ID token saved');
      }

      // حفظ بيانات المستخدم
      await SharedPrefHelper.setData(StorageKeys.userEmail, account.email);
      await SharedPrefHelper.setData(
        StorageKeys.userName,
        account.displayName ?? '',
      );
      await SharedPrefHelper.setData(
        StorageKeys.userProfilePic,
        account.photoUrl ?? '',
      );

      // حفظ حالة تسجيل الدخول عبر Google أولاً
      await SharedPrefHelper.setData(StorageKeys.isLoggedInAsGoogle, true);

      // ثم حفظ حالة تسجيل الدخول العامة
      await SharedPrefHelper.setData(StorageKeys.isLoggedIn, true);

      // تحديث الحالة في الذاكرة
      AppState.isLoggedInAsGoogle = true;
      AppState.isLoggedIn = true;

      // التحقق النهائي من حفظ البيانات
      await _verifyDataSaved();

      log('Google user data saved successfully');
    } catch (e) {
      log('Error saving Google user data: $e');
      // محاولة تنظيف البيانات المحفوظة جزئياً
      await _clearPartialData();
      throw Exception('Failed to save Google user data: $e');
    }
  }

  /// التحقق من حفظ البيانات بنجاح
  static Future<void> _verifyDataSaved() async {
    try {
      final token = await SharedPrefHelper.getSecuredString(
        StorageKeys.accessToken,
      );
      final isGoogle = await SharedPrefHelper.getBool(
        StorageKeys.isLoggedInAsGoogle,
      );
      final isLoggedIn = await SharedPrefHelper.getBool(StorageKeys.isLoggedIn);

      log('Data verification:');
      log('- Has token: ${token.isNotEmpty}');
      log('- Is Google user: $isGoogle');
      log('- Is logged in: $isLoggedIn');

      if (token.isEmpty || !isGoogle || !isLoggedIn) {
        throw Exception('Data verification failed');
      }
    } catch (e) {
      log('Data verification error: $e');
      rethrow;
    }
  }

  /// تنظيف البيانات المحفوظة جزئياً في حالة الخطأ
  static Future<void> _clearPartialData() async {
    try {
      await SharedPrefHelper.removeSecuredString(StorageKeys.accessToken);
      await SharedPrefHelper.removeSecuredString(StorageKeys.googleIdToken);
      await SharedPrefHelper.setData(StorageKeys.isLoggedInAsGoogle, false);
      await SharedPrefHelper.setData(StorageKeys.isLoggedIn, false);

      AppState.isLoggedInAsGoogle = false;
      AppState.isLoggedIn = false;

      log('Partial data cleared');
    } catch (e) {
      log('Error clearing partial data: $e');
    }
  }

  /// Check if user has valid Google token
  static Future<bool> _hasValidGoogleToken() async {
    try {
      final token = await SharedPrefHelper.getSecuredString(
        StorageKeys.accessToken,
      );
      final isGoogleUser = await SharedPrefHelper.getBool(
        StorageKeys.isLoggedInAsGoogle,
      );

      log(
        'Token check - has token: ${token.isNotEmpty}, is Google user: $isGoogleUser',
      );
      return token.isNotEmpty && isGoogleUser;
    } catch (e) {
      log('Error checking Google token: $e');
      return false;
    }
  }

  /// Clear Google user data
  static Future<void> _clearGoogleUserData() async {
    try {
      await SharedPrefHelper.removeSecuredString(StorageKeys.accessToken);
      await SharedPrefHelper.removeSecuredString(StorageKeys.googleIdToken);
      await SharedPrefHelper.removeData(StorageKeys.userEmail);
      await SharedPrefHelper.removeData(StorageKeys.userName);
      await SharedPrefHelper.removeData(StorageKeys.userProfilePic);
      await SharedPrefHelper.removeData(StorageKeys.isLoggedInAsGoogle);
      await SharedPrefHelper.removeData(StorageKeys.isLoggedIn);

      // Clear AppState in memory
      AppState.isLoggedInAsGoogle = false;
      AppState.isLoggedIn = false;

      log('Google user data cleared successfully');
    } catch (e) {
      log('Error clearing Google user data: $e');
    }
  }

  /// Check if token is expired
  static Future<bool> isTokenExpired() async {
    try {
      final account = await _googleSignInService
          .attemptLightweightAuthentication();
      if (account == null) return true;

      final authorization = await account.authorizationClient
          .authorizationForScopes(['email', 'profile']);
      return authorization == null || authorization.accessToken.isEmpty;
    } catch (e) {
      log('Error checking token expiration: $e');
      return true;
    }
  }

  /// Refresh Google token
  static Future<String?> refreshToken() async {
    try {
      final account = await _googleSignInService
          .attemptLightweightAuthentication();
      if (account == null) return null;

      final authorization = await account.authorizationClient.authorizeScopes([
        'email',
        'profile',
      ]);
      final accessToken = authorization.accessToken;
      if (accessToken.isNotEmpty) {
        await SharedPrefHelper.setSecuredString(
          StorageKeys.accessToken,
          accessToken,
        );
        log('Google token refreshed successfully');
        return accessToken;
      }
      return null;
    } catch (e) {
      log('Error refreshing Google token: $e');
      return null;
    }
  }

  /// Validate Google session - IMPROVED VERSION
  static Future<bool> validateGoogleSession() async {
    try {
      final account = await _googleSignInService
          .attemptLightweightAuthentication();
      final hasValidToken = await _hasValidGoogleToken();
      final isGoogleUser = await SharedPrefHelper.getBool(
        StorageKeys.isLoggedInAsGoogle,
      );

      final isValid = account != null && hasValidToken && isGoogleUser;

      log(
        'Google session validation - account: ${account != null}, hasValidToken: $hasValidToken, isGoogleUser: $isGoogleUser, isValid: $isValid',
      );

      return isValid;
    } catch (e) {
      log('Error validating Google session: $e');
      return false;
    }
  }

  /// إضافة دالة للتحقق من حالة التخزين (للتشخيص)
  static Future<void> debugStorageState() async {
    try {
      log('=== Storage Debug Info ===');

      // تحقق من FlutterSecureStorage
      final allSecuredData = await SharedPrefHelper.getAllSecuredData();
      log('Secured storage keys: ${allSecuredData.keys.toList()}');

      final token = await SharedPrefHelper.getSecuredString(
        StorageKeys.accessToken,
      );
      log('Access token exists: ${token.isNotEmpty}');

      final isGoogle = await SharedPrefHelper.getBool(
        StorageKeys.isLoggedInAsGoogle,
      );
      final isLoggedIn = await SharedPrefHelper.getBool(StorageKeys.isLoggedIn);

      log('Is Google user: $isGoogle');
      log('Is logged in: $isLoggedIn');
      log('AppState.isLoggedInAsGoogle: ${AppState.isLoggedInAsGoogle}');
      log('AppState.isLoggedIn: ${AppState.isLoggedIn}');

      log('=== End Storage Debug ===');
    } catch (e) {
      log('Error in debug storage state: $e');
    }
  }
}
