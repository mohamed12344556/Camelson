import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';
import 'criteria_indicator.dart';

class PasswordCriteriaWidget extends StatelessWidget {
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;
  final bool hasSpecialChar;

  const PasswordCriteriaWidget({
    super.key,
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumber,
    required this.hasSpecialChar,
  });

  double get strength {
    int strengthCount = [
      hasMinLength,
      hasUppercase,
      hasLowercase,
      hasNumber,
      hasSpecialChar
    ].where((criteria) => criteria).length;
    return strengthCount / 5;
  }

  Color _getStrengthColor(double strength) {
    if (strength <= 0.2) return Colors.red;
    if (strength <= 0.4) return Colors.orange;
    if (strength <= 0.6) return Colors.yellow[700]!;
    if (strength <= 0.8) return Colors.blue;
    return Colors.green;
  }

  String _getStrengthText(double strength) {
    if (strength <= 0.2) return 'Weak';
    if (strength <= 0.4) return 'Fair';
    if (strength <= 0.6) return 'Good';
    if (strength <= 0.8) return 'Strong';
    return 'Very Strong';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Row(
                    children: [
                      Flexible(
                        flex: (strength * 100).toInt(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _getStrengthColor(strength),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: ((1 - strength) * 100).toInt(),
                        child: Container(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getStrengthText(strength),
                style: TextStyle(
                  color: _getStrengthColor(strength),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              CriteriaIndicator(
                criterion: hasMinLength,
                text: S.of(context).password_criteria_min_length,
                icon: Icons.text_fields_rounded,
              ),
              CriteriaIndicator(
                criterion: hasUppercase,
                text: S.of(context).password_criteria_uppercase,
                icon: Icons.keyboard_capslock_rounded,
              ),
              CriteriaIndicator(
                criterion: hasLowercase,
                text: S.of(context).password_criteria_lowercase,
                icon: Icons.keyboard_alt_rounded,
              ),
              CriteriaIndicator(
                criterion: hasNumber,
                text: S.of(context).password_criteria_number,
                icon: Icons.tag_rounded,
              ),
              CriteriaIndicator(
                criterion: hasSpecialChar,
                text: S.of(context).password_criteria_special_char,
                icon: Icons.star_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
