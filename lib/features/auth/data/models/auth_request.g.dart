// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthRequest _$AuthRequestFromJson(Map<String, dynamic> json) => AuthRequest(
  email: json['email'] as String?,
  password: json['password'] as String?,
  username: json['username'] as String?,
  name: json['name'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  confirmPassword: json['confirmPassword'] as String?,
  role: json['role'] as String?,
  academicStageId: (json['AcademicStageId'] as num?)?.toInt(),
  academicYearId: (json['AcademicYearId'] as num?)?.toInt(),
  academicSectionId: (json['AcademicSectionId'] as num?)?.toInt(),
  currentPassword: json['currentPassword'] as String?,
  newPassword: json['newPassword'] as String?,
  otp: json['otp'] as String?,
  accessToken: json['accessToken'] as String?,
  refreshToken: json['refreshToken'] as String?,
  verificationToken: json['verificationToken'] as String?,
);

Map<String, dynamic> _$AuthRequestToJson(AuthRequest instance) =>
    <String, dynamic>{
      'email': ?instance.email,
      'password': ?instance.password,
      'username': ?instance.username,
      'name': ?instance.name,
      'phoneNumber': ?instance.phoneNumber,
      'confirmPassword': ?instance.confirmPassword,
      'role': ?instance.role,
      'AcademicStageId': ?instance.academicStageId,
      'AcademicYearId': ?instance.academicYearId,
      'AcademicSectionId': ?instance.academicSectionId,
      'currentPassword': ?instance.currentPassword,
      'newPassword': ?instance.newPassword,
      'otp': ?instance.otp,
      'accessToken': ?instance.accessToken,
      'refreshToken': ?instance.refreshToken,
      'verificationToken': ?instance.verificationToken,
    };
