// lib/core/utils/login_validator.dart
import 'package:camelson/generated/l10n.dart';

// class LoginValidator {
//   static bool isTeacherEmail(String email) {
//     // التحقق من أن البريد الإلكتروني ينتهي بـ @teacher.eol.edu
//     return email.toLowerCase().endsWith('@teacher.eol.edu');
//   }

//   static bool isStudentEmail(String email) {
//     // التحقق من أن البريد الإلكتروني ينتهي بـ @student.eol.edu
//     return email.toLowerCase().endsWith('@student.eol.edu');
//   }

//   static String? validateEmail(String? email, bool isTeacher) {
//     if (email == null || email.isEmpty) {
//       return S.current.email_required;
//     }

//     if (!email.contains('@')) {
//       return S.current.invalid_email_format;
//     }

//     if (isTeacher) {
//       if (!isTeacherEmail(email)) {
//         return S.current.teacher_email_required;
//       }
//     } else {
//       if (!isStudentEmail(email)) {
//         return S.current.student_email_required;
//       }
//     }

//     return null;
//   }

//   static String? validatePassword(String? password) {
//     if (password == null || password.isEmpty) {
//       return S.current.password_required;
//     }

//     if (password.length < 8) {
//       return S.current.password_min_length;
//     }

//     return null;
//   }
// }
class LoginValidator {
  static String? validateEmail(String? value, bool isTeacher) {
    if (value == null || value.isEmpty) {
      return S.current.field_required;
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.field_required;
    }
    return null;
  }
}
