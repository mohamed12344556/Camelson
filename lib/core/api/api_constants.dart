class ApiConstants {
  static const String baseUrl = 'https://test-mh.runasp.net';
  // static const String baseUrl = 'https://anucleate-inhalingly-raymundo.ngrok-free.dev';

  // App Headers Constants
  static const String appSignature = 'IY9qKIbHD9aJvbgkvOc5+l6RWrLkGRXJJZp90d2ML7Q=';
  static const String appIdHeaderKey = 'X-App-Id';
  static const String appSignatureHeaderKey = 'X-App-Signature';
  static const String languageHeaderKey = 'X-Language';

  // Auth Endpoints
  static const String login = '/api/auth/login';
  static const String signup = '/api/Auth/register';
  static const String refreshToken = '/api/Auth/refresh-token';
  static const String forgotPassword = '/api/Auth/forgot-password';
  static const String verifyOtp = '/api/Auth/verify-otp';
  static const String resetPassword = '/api/Auth/reset-password';
  static const String changePassword = '/api/Auth/change-password';
  static const String logout = '/api/Auth/logout';

  // User Profile Endpoints
  static const String getUserProfile = '/api/User/profile';
  static const String updateProfileImage = '/api/User/profile-image';

  // Student Profile Endpoints
  static const String getStudentProfile = '/api/Student/profile';
  static const String updateStudentProfile = '/api/Student/profile';

  // Academic Endpoints
  static const String getAcademicStages = '/api/Academic/stages';
  static const String getAcademicYears = '/api/Academic/years';
  static const String getAcademicSections = '/api/Academic/sections';

  // Community/Questions Endpoints
  static const String questions = '/api/Questions';
  static String questionById(String id) => '/api/Questions/$id';
  static String questionMembers(String id) => '/api/Questions/$id/members';
  static const String subjects = '/api/Subjects';

  // Subscription Endpoints
  static const String cancelSubscription = '/api/subscription/cancel';

  // SignalR Hub Endpoints
  static const String communityHub = '/communityHub';

  // Helper method to get full SignalR URL
  static String get communityHubUrl => '$baseUrl$communityHub';
}