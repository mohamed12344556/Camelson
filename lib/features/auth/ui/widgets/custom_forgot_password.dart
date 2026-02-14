import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../generated/l10n.dart';

class CustomForgotPasswordText extends StatelessWidget {
  const CustomForgotPasswordText({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          context.pushNamed(AppRoutes.forgetPasswordView);
        },
        child: Text(
          S.of(context).forgot_password,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
    );
  }
}
