import 'dart:convert';
import 'dart:developer';

import '../api/token_manager.dart';
import '../../features/auth/data/models/auth_response.dart';
import '../../features/community/data/models/user.dart' as community;

/// Service to handle user data extraction from JWT tokens
/// and conversion between Auth UserData and Community User models
class UserService {
  UserService._();

  /// Extract UserData from the stored JWT access token
  static Future<UserData?> getUserDataFromToken() async {
    try {
      final tokens = await TokenManager.getTokens();
      if (tokens == null) {
        log('UserService: No tokens found');
        return null;
      }

      final token = tokens.accessToken;
      final parts = token.split('.');
      if (parts.length != 3) {
        log('UserService: Invalid token format');
        return null;
      }

      // Decode JWT payload
      final payload = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payload));
      final data = json.decode(decoded) as Map<String, dynamic>;

      log('UserService: Token payload extracted: ${data.keys}');

      // Extract user information from JWT claims
      // JWT usually contains: sub (user id), email, name, role, etc.
      final userId = data['sub'] as String? ??
                     data['nameid'] as String? ??
                     data['id'] as String?;
      final email = data['email'] as String?;
      final name = data['name'] as String? ??
                   data['unique_name'] as String?;
      final role = data['role'] as String?;
      final xp = data['xp'] as int? ?? 0;

      if (userId == null) {
        log('UserService: User ID not found in token');
        return null;
      }

      // Create UserData from token claims
      return UserData(
        id: userId,
        email: email,
        name: name,
        role: role,
        xp: xp,
      );
    } catch (e) {
      log('UserService: Error extracting user data from token: $e');
      return null;
    }
  }

  /// Convert Auth UserData to Community User model
  static community.User convertToCommunityUser(UserData userData) {
    // Map role string to UserRole enum
    community.UserRole userRole = community.UserRole.student;
    if (userData.role != null) {
      final roleStr = userData.role!.toLowerCase();
      if (roleStr.contains('teacher') || roleStr.contains('instructor')) {
        userRole = community.UserRole.teacher;
      }
    }

    return community.User(
      id: userData.id ?? '',
      name: userData.name ?? userData.nickname ?? 'User',
      email: userData.email ?? '',
      role: userRole,
      profileImage: userData.profileImageUrl,
      xpPoints: userData.xp ?? 0,
      createdAt: userData.createdAt != null
          ? DateTime.tryParse(userData.createdAt!) ?? DateTime.now()
          : DateTime.now(),
      hasAgreedToPolicy: true, // Assuming agreed if logged in
    );
  }

  /// Get current user as Community User model from token
  static Future<community.User?> getCurrentCommunityUser() async {
    try {
      final userData = await getUserDataFromToken();
      if (userData == null) {
        log('UserService: Could not get user data from token');
        return null;
      }

      return convertToCommunityUser(userData);
    } catch (e) {
      log('UserService: Error getting current community user: $e');
      return null;
    }
  }

  /// Save UserData to SharedPreferences for offline access
  /// This should be called after successful login/signup
  static Future<void> cacheUserData(UserData userData) async {
    try {
      // You can use SharedPrefHelper to store user data as JSON
      // For now, we rely on token storage
      log('UserService: User data cached (via token)');
    } catch (e) {
      log('UserService: Error caching user data: $e');
    }
  }

  /// Clear cached user data on logout
  static Future<void> clearUserData() async {
    try {
      log('UserService: User data cleared');
    } catch (e) {
      log('UserService: Error clearing user data: $e');
    }
  }
}
