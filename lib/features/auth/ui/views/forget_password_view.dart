import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../../../generated/l10n.dart';
import '../logic/auth_cubit.dart';
import '../widgets/contact_option_tile.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  String selectedOption = '';
  final Map<String, String> contactOptions = {'email': '', 'phone': ''};

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.pushNamed(
            AppRoutes.otpAuthenticateView,
            arguments: {
              'email': contactOptions['email'],
              'isPasswordReset': true,
            },
          );
        } else if (state is AuthError) {
          context.showSnackBar(state.error.errorMessage!.message!);
        }
      },
      builder: (context, state) {
        final cubit = context.read<AuthCubit>();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const BackButton(color: Colors.black),
            title: Text(
              S.of(context).forget_pass_title_page,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        Text(
                          S.of(context).instruction_text,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ...contactOptions.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: ContactOptionTile(
                              value: entry.key,
                              title: entry.key == 'email'
                                  ? 'Via Email'
                                  : 'Via SMS',
                              subtitle: entry.value.isEmpty
                                  ? entry.key == 'email'
                                        ? 'Enter your email'
                                        : 'Enter your phone number'
                                  : entry.value,
                              icon: entry.key == 'email'
                                  ? Icons.email_outlined
                                  : Icons.phone_android_outlined,
                              selectedOption: selectedOption,
                              onOptionSelected: (selectedValue, inputValue) {
                                setState(() {
                                  selectedOption = selectedValue;
                                  if (inputValue != null) {
                                    contactOptions[selectedValue] = inputValue;
                                  }
                                });
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                // Bottom button section - outside scroll view
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: CustomButton(
                    text: S.of(context).button_continue,
                    onPressed: _canSubmit(selectedOption, contactOptions, state)
                        ? () => _handleSubmit(
                            cubit,
                            selectedOption,
                            contactOptions,
                          )
                        : null,
                    isLoading: state is AuthLoading,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _canSubmit(
    String selectedOption,
    Map<String, String> contactOptions,
    AuthState state,
  ) {
    return selectedOption.isNotEmpty &&
        contactOptions[selectedOption]!.isNotEmpty &&
        state is! AuthLoading;
  }

  void _handleSubmit(
    AuthCubit cubit,
    String selectedOption,
    Map<String, String> contactOptions,
  ) {
    if (selectedOption == 'email') {
      cubit.sendForgotPasswordOTP(email: contactOptions['email']!);
    }
  }
}
