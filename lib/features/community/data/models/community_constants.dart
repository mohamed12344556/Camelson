import 'user.dart';
import '../../../../core/services/user_service.dart';

/// Community constants and default values
class CommunityConstants {
  CommunityConstants._();

  // Default Current User (will be replaced with actual user from auth)
  static User _currentUser = User(
    id: 'guest',
    name: 'Guest User',
    email: 'guest@example.com',
    role: UserRole.student,
    xpPoints: 0,
    createdAt: DateTime.now(),
    hasAgreedToPolicy: false,
  );

  /// Get current user (fetched from token if available)
  static User get currentUser => _currentUser;

  /// Initialize current user from stored token
  static Future<void> initializeCurrentUser() async {
    final user = await UserService.getCurrentCommunityUser();
    if (user != null) {
      _currentUser = user;
    }
  }

  /// Update current user manually (e.g., after login/signup)
  static void updateCurrentUser(User user) {
    _currentUser = user;
  }

  /// Reset to guest user (e.g., on logout)
  static void resetCurrentUser() {
    _currentUser = User(
      id: 'guest',
      name: 'Guest User',
      email: 'guest@example.com',
      role: UserRole.student,
      xpPoints: 0,
      createdAt: DateTime.now(),
      hasAgreedToPolicy: false,
    );
  }

  // Grades
  static const List<String> grades = [
    'الأول الثانوي',
    'الثاني الثانوي',
    'الثالث الثانوي',
  ];

  // Subjects
  static const List<String> subjects = [
    'الرياضيات',
    'الفيزياء',
    'الكيمياء',
    'الأحياء',
    'اللغة العربية',
    'اللغة الإنجليزية',
    'التاريخ',
    'الجغرافيا',
  ];

  // Policy Text
  static const String policyText = '''
أهلاً بك في مجتمع التعلم التفاعلي!

قبل البدء في المشاركة، يرجى الاطلاع على القواعد التالية:

📚 قواعد المشاركة:
• استخدم لغة مهذبة ومحترمة
• اطرح أسئلة واضحة ومفصلة
• ساعد زملاءك بإجابات مفيدة
• تجنب النسخ المباشر من المصادر

🎯 نظام النقاط:
• 5 نقاط لكل سؤال تطرحه
• 10 نقاط لكل إجابة تقدمها
• نقاط إضافية عند تفاعل الآخرين مع إجاباتك

⚠️ تحذيرات:
• لا تشارك معلومات شخصية
• تجنب الرسائل العشوائية
• احترم جميع الأعضاء والمعلمين

بالموافقة على هذه القواعد، أنت تساهم في بناء بيئة تعليمية إيجابية للجميع.
''';
}
