part of 'auth_cubit.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthLoggedOut extends AuthState {}

class AuthError extends AuthState {
  final ApiErrorModel error;
  AuthError(this.error);
}

// Login States
class LoginSuccess extends AuthState {}

class LoginError extends AuthState {
  final ApiErrorModel errorMessage;
  LoginError(this.errorMessage);
}

// SignUp States
class SignUpSuccess extends AuthState {
  final String email;
  SignUpSuccess({required this.email});
}

class SignUpError extends AuthState {
  final ApiErrorModel message;
  SignUpError({required this.message});
}

class SignUpFormChanged extends AuthState {}

// OTP States
class OtpSuccess extends AuthState {}

class OtpError extends AuthState {
  final ApiErrorModel message;
  OtpError({required this.message});
}

// Reset Password States
class ResetPasswordSuccess extends AuthState {}

class ResetPasswordFailure extends AuthState {
  final ApiErrorModel message;
  ResetPasswordFailure({required this.message});
}

// Verify Reset Password OTP States
class VerifyResetPasswordOTPSuccess extends AuthState {}

class VerifyResetPasswordOTPError extends AuthState {
  final ApiErrorModel message;
  VerifyResetPasswordOTPError({required this.message});
}
