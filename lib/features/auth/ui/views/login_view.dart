import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/google_sign_in_service.dart';
import '../../../../core/constants/key_strings.dart';
import '../../../../core/core.dart';
import '../../../../generated/l10n.dart';
import '../logic/auth_cubit.dart';
// TODO: Uncomment when social media login is ready
// import '../widgets/continue_with.dart';
import '../widgets/custom_forgot_password.dart';
// TODO: Uncomment when social media login is ready
// import '../widgets/custom_social_button.dart';

Future<void> signIn(BuildContext context) async {
  try {
    log('بدء عملية تسجيل الدخول بـ Google...');

    // إظهار مؤشر التحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // تسجيل الدخول بـ Google
    final account = await GoogleSignInService.signIn();

    if (account != null) {
      log('Google user email: ${account.email}');
      log('Google user id: ${account.id}');
      log('Google user display name: ${account.displayName}');
      log('Google user photo: ${account.photoUrl}');

      // الحصول على Authorization (access token)
      final authorization = await account.authorizationClient.authorizeScopes(
        ['email', 'profile'],
      );
      final accessToken = authorization.accessToken;

      // الحصول على Authentication (id token)
      final authentication = account.authentication;
      final idToken = authentication.idToken;

      if (accessToken.isNotEmpty) {
        log('تم الحصول على Access Token بنجاح');
        log('Token preview: ${accessToken.substring(0, 20)}...');
        if (idToken != null && idToken.isNotEmpty) {
          log('ID Token preview: ${idToken.substring(0, 20)}...');
        } else {
          log('No ID Token returned from Google Sign-In');
        }

        // حفظ بيانات المستخدم
        await GoogleSignInService.saveGoogleUserData(
          account: account,
          accessToken: accessToken,
          idToken: idToken,
        );

        // إخفاء مؤشر التحميل
        Navigator.of(context).pop();

        // التحقق من أن البيانات تم حفظها بنجاح
        await GoogleSignInService.debugStorageState();

        final token = await SharedPrefHelper.getSecuredString(
          StorageKeys.accessToken,
        );
        final isGoogleUser = await SharedPrefHelper.getBool(
          StorageKeys.isLoggedInAsGoogle,
        );
        final isLoggedIn = await SharedPrefHelper.getBool(
          StorageKeys.isLoggedIn,
        );

        log('بعد الحفظ:');
        log('- hasToken: ${token.isNotEmpty}');
        log('- isGoogleUser: $isGoogleUser');
        log('- isLoggedIn: $isLoggedIn');

        if (token.isNotEmpty && isGoogleUser && isLoggedIn) {
          // إظهار رسالة النجاح
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     backgroundColor: Colors.green,
          //     duration: const Duration(seconds: 2),
          //     content: Text('مرحباً، ${account.displayName ?? account.email}!'),
          //   ),
          // );
          context.showSuccessSnackBar(
            'مرحباً، ${account.displayName ?? account.email}!',
          );

          // تحديث AppState
          AppState.isLoggedIn = true;
          AppState.isLoggedInAsGoogle = true;

          // الانتقال إلى الصفحة الرئيسية
          context.pushNamedAndRemoveUntil(
            AppRoutes.hostView,
            predicate: (route) => false,
          );
        } else {
          throw Exception(
            'فشل في حفظ بيانات المستخدم - التحقق من البيانات فشل',
          );
        }
      } else {
        throw Exception('فشل في الحصول على رمز الوصول');
      }
    } else {
      Navigator.of(context).pop();
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     backgroundColor: Colors.orange,
      //     content: Text('تم إلغاء تسجيل الدخول'),
      //   ),
      // );
      context.showErrorSnackBar('تم إلغاء تسجيل الدخول');
    }
  } catch (e) {
    // إخفاء مؤشر التحميل
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    log('خطأ في تسجيل الدخول بـ Google: $e');

    // إظهار معلومات التشخيص
    await GoogleSignInService.debugStorageState();

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     backgroundColor: Colors.red,
    //     duration: const Duration(seconds: 4),
    //     content: Text('فشل تسجيل الدخول: $e'),
    //   ),
    // );
    context.showErrorSnackBar('فشل تسجيل الدخول: $e');
  }
}

class LogInView extends StatefulWidget {
  const LogInView({super.key});

  @override
  State<LogInView> createState() => _LogInViewState();
}

class _LogInViewState extends State<LogInView> {
  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is LoginSuccess) {
                context.pushReplacementNamed(AppRoutes.hostView);
                context.showSuccessSnackBar("Login successful");
              } else if (state is LoginError) {
                context.showErrorSnackBar(
                  state.errorMessage.errorMessage!.message!,
                );
              }
            },
            builder: (context, state) {
              final cubit = context.read<AuthCubit>();
              return Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          S.of(context).app_title,
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.blue,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        S.of(context).email_label,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextFormField(
                        controller: cubit.loginEmailController,
                        label: !cubit.isTeacherSelected
                            ? S.of(context).email_placeholder_teacher
                            : S.of(context).email_placeholder_student,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value?.isEmpty == true
                            ? S.of(context).field_required
                            : null,
                        onChanged: (value) => cubit.validateEmail(value),
                        focusNode: cubit.loginEmailFocusNode,
                        nextFocusNode: cubit.loginPasswordFocusNode,
                        isLastField: false,
                        onFieldSubmitted: (value) {
                          FocusScope.of(
                            context,
                          ).requestFocus(cubit.loginPasswordFocusNode);
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        S.of(context).password_label,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextFormField(
                        controller: cubit.loginPasswordController,
                        label: S.of(context).password_placeholder,
                        icon: Icons.lock_outline,
                        isPassword: true,
                        isPasswordVisible: cubit.isPasswordVisible,
                        validator: LoginValidator.validatePassword,
                        onTogglePasswordVisibility:
                            cubit.togglePasswordVisibility,
                        onChanged: (value) => cubit.validatePassword(value),
                        focusNode: cubit.loginPasswordFocusNode,
                        isLastField: true,
                      ),
                      const CustomForgotPasswordText(),
                      // TODO: Uncomment when social media login is ready on backend
                      // const ContinueWith(),
                      // const SizedBox(height: 16),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //   children: [
                      //     CustomSocialButton(
                      //       imagePath: Assets.google,
                      //       onTap: () {
                      //         signIn(context);
                      //       },
                      //     ),
                      //     CustomSocialButton(
                      //       imagePath: Assets.facebook,
                      //       onTap: () {
                      //         log('Facebook');
                      //       },
                      //     ),
                      //     CustomSocialButton(
                      //       imagePath: Assets.apple,
                      //       onTap: () {
                      //         log('Apple');
                      //       },
                      //     ),
                      //   ],
                      // ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: S.of(context).sign_in_button,
                        isLoading: state is AuthLoading,
                        onPressed: _canSubmit(cubit)
                            ? () {
                                FocusScope.of(context).unfocus();
                                cubit.handleSignIn(formKey);
                              }
                            : null,
                      ),
                      const SizedBox(height: 16),
                      CustomRichText(
                        firstText: S.of(context).sign_up_prompt,
                        secondText: S.of(context).signup_button,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () =>
                              context.pushNamed(AppRoutes.registerView),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  bool _canSubmit(AuthCubit cubit) {
    return cubit.loginEmailController.text.isNotEmpty &&
        cubit.loginPasswordController.text.isNotEmpty;
  }
}
