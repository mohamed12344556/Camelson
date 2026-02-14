import 'package:json_annotation/json_annotation.dart';

part 'auth_request.g.dart';

@JsonSerializable(includeIfNull: false)
class AuthRequest {
  final String? email;
  final String? password;
  final String? username;
  final String? name;
  final String? phoneNumber;
  final String? confirmPassword;
  final String? role;
  @JsonKey(name: 'AcademicStageId')
  final int? academicStageId;
  @JsonKey(name: 'AcademicYearId')
  final int? academicYearId;
  @JsonKey(name: 'AcademicSectionId')
  final int? academicSectionId;
  final String? currentPassword;
  final String? newPassword;
  final String? otp;
  final String? accessToken;
  final String? refreshToken;
  final String? verificationToken;

  const AuthRequest({
    this.email,
    this.password,
    this.username,
    this.name,
    this.phoneNumber,
    this.confirmPassword,
    this.role,
    this.academicStageId,
    this.academicYearId,
    this.academicSectionId,
    this.currentPassword,
    this.newPassword,
    this.otp,
    this.accessToken,
    this.refreshToken,
    this.verificationToken,
  });

  //? Factory methods for different types of requests
  factory AuthRequest.login({
    required String email,
    required String password,
  }) {
    return AuthRequest(
      email: email,
      password: password,
    );
  }

  factory AuthRequest.signup({
    required String name,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
    required String role,
    required int academicStageId,
    required int academicYearId,
    required int academicSectionId,
  }) {
    return AuthRequest(
      name: name,
      username: username,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      confirmPassword: confirmPassword,
      role: role,
      academicStageId: academicStageId,
      academicYearId: academicYearId,
      academicSectionId: academicSectionId,
    );
  }

  factory AuthRequest.verifyOtp({
    required String email,
    required String otp,
  }) {
    return AuthRequest(
      email: email,
      otp: otp,
    );
  }

  factory AuthRequest.forgotPassword({
    required String email,
  }) {
    return AuthRequest(
      email: email,
    );
  }

  factory AuthRequest.resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
    required String verificationToken,
  }) {
    return AuthRequest(
      email: email,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
      verificationToken: verificationToken,
    );
  }

  factory AuthRequest.changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    return AuthRequest(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }

  factory AuthRequest.refreshToken({
    required String accessToken,
    required String refreshToken,
  }) {
    return AuthRequest(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Map<String, dynamic> toJson() => _$AuthRequestToJson(this);
}
