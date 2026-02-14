import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';
import 'strength_item.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;
  final bool hasSpecialChar;

  const PasswordStrengthIndicator({
    super.key,
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumber,
    required this.hasSpecialChar,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StrengthItem(
            text: S.of(context).password_min_length_reset,
            isMet: hasMinLength,
          ),
          StrengthItem(
            text: S.of(context).password_criteria_uppercase,
            isMet: hasUppercase,
          ),
          StrengthItem(
            text: S.of(context).password_criteria_lowercase,
            isMet: hasLowercase,
          ),
          StrengthItem(
            text: S.of(context).password_criteria_number,
            isMet: hasNumber,
          ),
          StrengthItem(
            text: S.of(context).password_criteria_special_char,
            isMet: hasSpecialChar,
          ),
        ],
      ),
    );
  }
}
