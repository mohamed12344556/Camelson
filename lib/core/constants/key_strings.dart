// constants.dart
import 'dart:developer';

import '../api/google_sign_in_service.dart';
import '../api/token_manager.dart';
import '../core.dart';

class AppConstants {
  const AppConstants._();

  // Shared Preferences Keys
  static const String languageKey = "language_key";
  static const String themeKey = "theme_key";
  static const String userDataKey = "user_data_key";
  static const String onboardingKey = "onboarding_key";
}

// api_constants.dart
class ApiConstants {
  const ApiConstants._();

  // Base URL
  static const String baseUrl = 'https://eol.runasp.net';

  // Auth Endpoints
  static const String login = '/api/Account/Login';
  static const String signup = '/api/Account/SignUp';
  static const String refreshToken = '/api/Account/RefreshToken';
  static const String forgotPassword = '/api/Account/ForgotPassword';
  static const String resetPassword = '/api/Account/ResetPassword';
  static const String verifyResetPasswordOTP =
      '/api/Account/VerifyResetPasswordOTP';
  static const String revokeToken = '/api/Account/RevokeToken';
  static const String verifyEmail = '/api/Account/VerifyEmail';
  static const String resendVerificationCode =
      '/api/Account/ResendVerificationCode';

  // User Profile Endpoints
  static const String getUserProfile = '/api/Profile/GetUserProfile';
  static const String editUserProfile = '/api/Profile/EditUserProfile';
}

class StorageKeys {
  const StorageKeys._();

  // Key for onboarding
  static const String hasSeenOnboarding = 'has_seen_onboarding';

  // Auth Related
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String googleIdToken = 'google_id_token';
  static const String userId = 'user_id';
  static const String isLoggedIn = 'is_logged_in';
  static const String isLoggedInAsGoogle = 'is_logged_in_as_google';
  static const String deviceId = 'device_id';

  // User Data
  static const String userData = 'user_data';
  static const String userSettings = 'user_settings';
  static const String userPreferences = 'user_preferences';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String userProfilePic = 'user_profile_pic';

  // Helper method to check user type for password reset
  String checkUserWannaRestPasswordOrSignup({
    required Map<String, dynamic> args,
  }) {
    if (args['isRegistered'] == false) {
      log('user is not registered');
      return "${args["email"]}";
    } else {
      log('user is registered');
      return "${args["value"]}";
    }
  }
}

// api_keys.dart
class ApiKeys {
  const ApiKeys._();

  // Common Response Keys
  static const String status = 'status';
  static const String message = 'message';
  static const String error = 'error';
  static const String data = 'data';

  // Auth Related
  static const String token = 'token';
  static const String refreshToken = 'refreshToken';

  // User Related
  static const String id = 'id';
  static const String email = 'email';
  static const String password = 'password';
  static const String confirmPassword = 'confirmPassword';
  static const String name = 'name';
  static const String phone = 'phone';
  static const String location = 'location';
  static const String profilePic = 'profilePicture';
}

// error_constants.dart
class ErrorConstants {
  const ErrorConstants._();

  // HTTP Errors
  static const String badRequest = 'Bad request error';
  static const String unauthorized = 'Unauthorized error';
  static const String forbidden = 'Forbidden error';
  static const String notFound = 'Not found error';
  static const String serverError = 'Internal server error';

  // Network Errors
  static const String noInternet = 'No internet connection';
  static const String timeout = 'Request timeout';
  static const String unknown = 'Unknown error occurred';

  // Auth Errors
  static const String invalidCredentials = 'Invalid email or password';
  static const String tokenExpired = 'Session expired, please login again';
  static const String invalidToken = 'Invalid authentication token';

  // Validation Errors
  static const String invalidEmail = 'Please enter a valid email';
  static const String invalidPassword =
      'Password must be at least 8 characters';
  static const String passwordMismatch = 'Passwords do not match';
  static const String requiredField = 'This field is required';
}

class AppState {
  static bool isLoggedIn = false;
  static String? currentLocale;
  static bool isDarkMode = false;
  static bool isLoggedInAsGoogle = false;

  const AppState._();

  /// Initialize AppState by reading from storage
  static Future<void> initialize() async {
    try {
      log('Initializing AppState...');

      await GoogleSignInService.debugStorageState();

      // Read stored values
      final loggedIn = await SharedPrefHelper.getBool(StorageKeys.isLoggedIn);
      final googleLogin = await SharedPrefHelper.getBool(
        StorageKeys.isLoggedInAsGoogle,
      );
      final token = await SharedPrefHelper.getSecuredString(
        StorageKeys.accessToken,
      );

      log(
        'Stored values - loggedIn: $loggedIn, googleLogin: $googleLogin, hasToken: ${token.isNotEmpty}',
      );

      // Set initial state from storage
      isLoggedIn = loggedIn;
      isLoggedInAsGoogle = googleLogin;

      // Basic validation (detailed validation with refresh happens in hasValidSession)
      if (loggedIn && token.isEmpty) {
        // Clear invalid state - no token but marked as logged in
        log('No token found but logged in state exists, clearing');
        await clearAuthenticationState();
      }

      log(
        'AppState initialized - isLoggedIn: $isLoggedIn, isLoggedInAsGoogle: $isLoggedInAsGoogle',
      );
    } catch (e) {
      log('Error initializing AppState: $e');
      // Reset to safe defaults on error
      isLoggedIn = false;
      isLoggedInAsGoogle = false;
    }
  }

  static Future<void> logout() async {
    try {
      // Clear regular tokens
      await TokenManager.clearTokens();

      // Sign out from Google if logged in via Google
      if (isLoggedInAsGoogle) {
        await GoogleSignInService.signOut();
      }

      // Clear all authentication state
      await clearAuthenticationState();

      log('User logged out successfully');
    } catch (e) {
      log('Error during logout: $e');
    }
  }

  /// Clear all authentication states - IMPROVED VERSION
  static Future<void> clearAuthenticationState() async {
    try {
      // Clear memory state
      isLoggedIn = false;
      isLoggedInAsGoogle = false;

      // Clear storage
      await SharedPrefHelper.setData(StorageKeys.isLoggedIn, false);
      await SharedPrefHelper.setData(StorageKeys.isLoggedInAsGoogle, false);

      log('Authentication state cleared');
    } catch (e) {
      log('Error clearing authentication state: $e');
    }
  }

  /// Check if user has valid session with auto-refresh support
  static Future<bool> hasValidSession({ApiService? apiService}) async {
    try {
      final token = await SharedPrefHelper.getSecuredString(
        StorageKeys.accessToken,
      );
      final loggedIn = await SharedPrefHelper.getBool(StorageKeys.isLoggedIn);
      final googleLogin = await SharedPrefHelper.getBool(
        StorageKeys.isLoggedInAsGoogle,
      );

      bool hasValidSession = false;

      // Check if we have tokens (regardless of isLoggedIn flag)
      if (token.isNotEmpty) {
        if (googleLogin) {
          // Google sign-in validation
          hasValidSession = await GoogleSignInService.validateGoogleSession();
        } else {
          // Regular JWT validation
          final tokens = await TokenManager.getTokens();
          if (tokens != null) {
            final isExpired = TokenManager.isTokenExpired(tokens.accessToken);

            if (!isExpired) {
              // Token is still valid
              hasValidSession = true;
              log('Access token is still valid');
            } else {
              // Token expired, attempt refresh
              log('Access token expired, attempting refresh...');

              if (apiService != null) {
                hasValidSession = await TokenManager.attemptTokenRefresh(apiService);
                if (hasValidSession) {
                  log('Token refresh successful - user session restored');
                } else {
                  log('Token refresh failed - user needs to re-login');
                }
              } else {
                log('ApiService not provided, cannot refresh token');
                hasValidSession = false;
              }
            }
          }
        }
      }

      log(
        'hasValidSession check - loggedIn: $loggedIn, hasToken: ${token.isNotEmpty}, googleLogin: $googleLogin, valid: $hasValidSession',
      );
      return hasValidSession;
    } catch (e) {
      log('Error checking valid session: $e');
      return false;
    }
  }

  /// Check if user is logged in via Google - IMPROVED VERSION
  static Future<bool> isUserLoggedInViaGoogle() async {
    try {
      final googleLogin = await SharedPrefHelper.getBool(
        StorageKeys.isLoggedInAsGoogle,
      );

      if (!googleLogin) return false;

      final hasValidSession = await GoogleSignInService.validateGoogleSession();

      log(
        'isUserLoggedInViaGoogle - googleLogin: $googleLogin, hasValidSession: $hasValidSession',
      );
      return hasValidSession;
    } catch (e) {
      log('Error checking Google login status: $e');
      return false;
    }
  }
}
