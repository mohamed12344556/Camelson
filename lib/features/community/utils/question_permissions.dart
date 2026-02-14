import '../data/models/question.dart';
import '../data/models/question_role.dart';

/// Utility class for checking question permissions
class QuestionPermissions {
  /// Check if user can delete the question
  static bool canDeleteQuestion(Question question) {
    return question.isUserCreator;
  }

  /// Check if user can edit the question
  static bool canEditQuestion(Question question) {
    return question.hasAdminPrivileges; // Creator or Admin
  }

  /// Check if user can pin/unpin the question
  static bool canPinQuestion(Question question) {
    return question.hasAdminPrivileges;
  }

  /// Check if user can close the question
  static bool canCloseQuestion(Question question) {
    return question.hasAdminPrivileges;
  }

  /// Check if user can assign admins
  static bool canAssignAdmins(Question question) {
    return question.isUserCreator; // Only creator can assign admins
  }

  /// Check if user can delete messages
  static bool canDeleteMessages(Question question) {
    return question.hasAdminPrivileges;
  }

  /// Check if user can kick members
  static bool canKickMembers(Question question) {
    return question.hasAdminPrivileges;
  }

  /// Get permission summary for UI
  static Map<String, bool> getPermissions(Question question) {
    return {
      'canDelete': canDeleteQuestion(question),
      'canEdit': canEditQuestion(question),
      'canPin': canPinQuestion(question),
      'canClose': canCloseQuestion(question),
      'canAssignAdmins': canAssignAdmins(question),
      'canDeleteMessages': canDeleteMessages(question),
      'canKickMembers': canKickMembers(question),
    };
  }

  /// Get role display name
  static String getRoleDisplayName(QuestionRole role, {bool isArabic = true}) {
    return isArabic ? role.displayNameAr : role.displayNameEn;
  }

  /// Get role color for UI
  static String getRoleColor(QuestionRole role) {
    switch (role) {
      case QuestionRole.creator:
        return '#FFD700'; // Gold
      case QuestionRole.admin:
        return '#FF6B6B'; // Red
      case QuestionRole.member:
        return '#4ECDC4'; // Teal
    }
  }
}
