import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../../../generated/l10n.dart';
import '../logic/auth_cubit.dart';
import '../widgets/animated_lock_icon.dart';

class ResetPasswordView extends StatelessWidget {
  final Map<String, dynamic>? arguments;
  const ResetPasswordView({super.key, this.arguments});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final email = arguments?['email'] as String?;
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is ResetPasswordSuccess) {
          // تغيير AuthSuccess
          context.pushNamedAndRemoveUntil(
            AppRoutes.loginView, // تغيير homeView
            predicate: (_) => false,
          );
        } else if (state is ResetPasswordFailure) {
          // تغيير AuthError
          context.showSnackBar(state.message.errorMessage!.message!);
        }
      },
      builder: (context, state) {
        final cubit = context.read<AuthCubit>();
        // تحديث الإيميل في الـ cubit
        if (email != null) {
          cubit.selectedEmail = email;
        }
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              S.of(context).reset_pass_title_page,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const AnimatedLockIcon(svgPath: Assets.password),
                  const SizedBox(height: 24),
                  Text(
                    S.of(context).screen_title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    S.of(context).tip_text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomTextFormField(
                    controller: cubit.loginPasswordController,
                    label: S.of(context).password_label_reset_page,
                    icon: Icons.lock_outlined,
                    isPassword: true,
                    isPasswordVisible: cubit.isPasswordVisible,
                    validator: LoginValidator.validatePassword,
                    onChanged: (value) => cubit.checkPassword(value),
                    onTogglePasswordVisibility: cubit.togglePasswordVisibility,
                  ),
                  _buildPasswordStrengthIndicator(cubit),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    controller: cubit.confirmPasswordController,
                    label: S.of(context).confirm_password_label,
                    icon: Icons.lock_outlined,
                    isPassword: true,
                    isPasswordVisible: cubit.isConfirmPasswordVisible,
                    validator:
                        (value) =>
                            value != cubit.loginPasswordController.text
                                ? S.of(context).passwords_dont_match
                                : null,
                    onChanged: (_) {},
                    onTogglePasswordVisibility:
                        cubit.toggleConfirmPasswordVisibility,
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: S.of(context).reset_password_button,
                    onPressed:
                        _canSubmit(cubit) && state is! AuthLoading
                            ? () => cubit.resetPassword(formKey)
                            : null,
                    isLoading: state is AuthLoading,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPasswordStrengthIndicator(AuthCubit cubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCriteriaRow('Minimum 8 characters', cubit.hasMinLength),
        _buildCriteriaRow('Contains uppercase letter', cubit.hasUppercase),
        _buildCriteriaRow('Contains lowercase letter', cubit.hasLowercase),
        _buildCriteriaRow('Contains number', cubit.hasNumber),
        _buildCriteriaRow('Contains special character', cubit.hasSpecialChar),
      ],
    );
  }

  Widget _buildCriteriaRow(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.error,
            color: isMet ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? Colors.green : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  bool _canSubmit(AuthCubit cubit) {
    return cubit.hasMinLength &&
        cubit.hasUppercase &&
        cubit.hasLowercase &&
        cubit.hasNumber &&
        cubit.hasSpecialChar &&
        cubit.loginPasswordController.text.isNotEmpty &&
        cubit.confirmPasswordController.text.isNotEmpty &&
        cubit.loginPasswordController.text ==
            cubit.confirmPasswordController.text;
  }
}
