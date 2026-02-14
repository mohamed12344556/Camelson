/// Question role enumeration matching the backend
/// Defines the role of a user within a question/room
enum QuestionRole {
  /// Original creator with full permissions
  creator(0),

  /// Additional admins (if creator assigns)
  admin(1),

  /// Regular participants
  member(2);

  const QuestionRole(this.value);

  final int value;

  /// Convert from integer value to enum
  static QuestionRole fromValue(int value) {
    switch (value) {
      case 0:
        return QuestionRole.creator;
      case 1:
        return QuestionRole.admin;
      case 2:
        return QuestionRole.member;
      default:
        return QuestionRole.member; // Default to member for unknown values
    }
  }

  /// Check if user has admin privileges (creator or admin)
  bool get hasAdminPrivileges => this == QuestionRole.creator || this == QuestionRole.admin;

  /// Check if user is the creator
  bool get isCreator => this == QuestionRole.creator;

  /// Check if user is an admin
  bool get isAdmin => this == QuestionRole.admin;

  /// Check if user is a regular member
  bool get isMember => this == QuestionRole.member;

  /// Get display name in Arabic
  String get displayNameAr {
    switch (this) {
      case QuestionRole.creator:
        return 'منشئ السؤال';
      case QuestionRole.admin:
        return 'مشرف';
      case QuestionRole.member:
        return 'عضو';
    }
  }

  /// Get display name in English
  String get displayNameEn {
    switch (this) {
      case QuestionRole.creator:
        return 'Creator';
      case QuestionRole.admin:
        return 'Admin';
      case QuestionRole.member:
        return 'Member';
    }
  }
}
