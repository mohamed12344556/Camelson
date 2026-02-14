import 'dart:developer';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';
import '../../../../../../core/core.dart';
import '../../../../../../generated/l10n.dart';
import '../logic/auth_cubit.dart';

class OTPAuthenticateView extends StatefulWidget {
  final Map<String, dynamic> arguments;

  const OTPAuthenticateView({super.key, required this.arguments});

  @override
  State<OTPAuthenticateView> createState() => _OTPAuthenticateViewState();
}

class _OTPAuthenticateViewState extends State<OTPAuthenticateView> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final smartAuth = SmartAuth.instance;

  @override
  void initState() {
    super.initState();
    _listenForSmsCode();
  }

  @override
  void dispose() {
    // Remove listeners if SMS code is not received yet
    smartAuth.removeSmsRetrieverApiListener();
    smartAuth.removeUserConsentApiListener();
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  // Listen for SMS code on Android
  Future<void> _listenForSmsCode() async {
    try {
      // Try User Consent API first (requires user interaction but more reliable)
      final res = await smartAuth.getSmsWithUserConsentApi();

      if (res.hasData) {
        final code = res.requireData.code;
        if (code != null && mounted) {
          pinController.text = code;
          pinController.selection = TextSelection.fromPosition(
            TextPosition(offset: code.length),
          );

          // Auto-trigger verification
          context.read<AuthCubit>().updateUserInput(code);
          if (context.read<AuthCubit>().isOtpValid) {
            context.read<AuthCubit>().verifyOtp();
          }
        }
      } else if (res.isCanceled) {
        log('SMS autofill canceled by user');
      } else {
        log('SMS autofill failed: $res');
      }
    } catch (e) {
      log('SMS autofill error: $e');
      // Continue normally if autofill fails
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPasswordReset =
        widget.arguments['isPasswordReset'] as bool? ?? false;
    final email = widget.arguments['email'] as String;

    log('Received email in OTP view: $email');

    // Initialize email in AuthCubit
    context.read<AuthCubit>().setEmail(email, isReset: isPasswordReset);

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is OtpSuccess) {
          if (isPasswordReset) {
            context.pushNamedAndRemoveUntil(
              AppRoutes.resetPasswordView,
              predicate: (route) => false,
              arguments: {'email': email},
            );
          } else {
            context.pushNamedAndRemoveUntil(
              AppRoutes.loginView,
              predicate: (route) => false,
            );
          }
        } else if (state is OtpError) {
          context.showSnackBar(state.message.errorMessage!.message!);
        }
      },
      builder: (context, state) {
        final cubit = context.read<AuthCubit>();

        // Define Pinput themes
        final defaultPinTheme = PinTheme(
          width: 56,
          height: 60,
          textStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
        );

        final focusedPinTheme = defaultPinTheme.copyWith(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).primaryColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        );

        final submittedPinTheme = defaultPinTheme.copyWith(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green, width: 1.5),
          ),
        );

        final errorPinTheme = defaultPinTheme.copyWith(
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red, width: 2),
          ),
        );

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: const BackButton(color: Colors.black),
            title: Text(
              isPasswordReset ? 'Reset Password' : 'Verify Email',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPasswordReset
                      ? 'Enter the code sent to reset your password'
                      : 'Enter the verification code sent to your email',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 32),
                // Pinput Widget with SMS Autofill
                Center(
                  child: Pinput(
                    controller: pinController,
                    focusNode: focusNode,
                    length: cubit.otpLength,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: submittedPinTheme,
                    errorPinTheme: state is OtpError ? errorPinTheme : null,
                    onChanged: (value) {
                      cubit.updateUserInput(value);
                    },
                    onCompleted: (pin) {
                      cubit.updateUserInput(pin);
                      if (cubit.isOtpValid) {
                        cubit.verifyOtp();
                      }
                    },
                    pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                    showCursor: true,
                    cursor: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 9),
                          width: 22,
                          height: 1,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                    hapticFeedbackType: HapticFeedbackType.lightImpact,
                    animationDuration: const Duration(milliseconds: 300),
                    enableSuggestions: true,
                  ),
                ),
                const SizedBox(height: 16),
                CustomRichText(
                  firstText: S.of(context).resend_instruction,
                  secondText: cubit.canResend
                      ? S.of(context).resend_button
                      : cubit.timerText,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      if (cubit.canResend) {
                        cubit.resendOtp();
                      }
                    },
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: S.of(context).verify_button,
                  onPressed: cubit.isOtpValid && state is! AuthLoading
                      ? () => cubit.verifyOtp()
                      : null,
                  isLoading: state is AuthLoading,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
