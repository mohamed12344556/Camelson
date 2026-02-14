import 'package:json_annotation/json_annotation.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
  final bool? success;
  final String? message;
  final AuthData? data;
  final List<String>? errors;

  const AuthResponse({
    this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);

  bool get isSuccess => success == true;
  bool get hasData => data != null;
  bool get hasErrors => errors != null && errors!.isNotEmpty;
}

@JsonSerializable()
class AuthData {
  final String? accessToken;
  final String? refreshToken;
  final String? expiresAt;
  final UserData? user;
  final String? verificationToken;

  const AuthData({
    this.accessToken,
    this.refreshToken,
    this.expiresAt,
    this.user,
    this.verificationToken,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) =>
      _$AuthDataFromJson(json);

  Map<String, dynamic> toJson() => _$AuthDataToJson(this);
}

@JsonSerializable()
class UserData {
  final String? id;
  final String? email;
  final String? name;
  final String? nickname;
  final int? gender;
  final String? phoneNumber;
  final String? dateOfBirth;
  final int? xp;
  final String? role;
  final String? profileImageUrl;
  final bool? isActive;
  final bool? emailConfirmed;
  final bool? phoneNumberConfirmed;
  final bool? twoFactorEnabled;
  final int? subscriptionPlanId;
  final int? academicStageId;
  final int? academicYearId;
  final int? academicSectionId;
  final AcademicStage? academicStage;
  final AcademicYear? academicYear;
  final AcademicSection? academicSection;
  final SubscriptionPlan? subscriptionPlan;
  final List<String>? roles;
  final String? createdAt;
  final String? language;

  const UserData({
    this.id,
    this.email,
    this.name,
    this.nickname,
    this.gender,
    this.phoneNumber,
    this.dateOfBirth,
    this.xp,
    this.role,
    this.profileImageUrl,
    this.isActive,
    this.emailConfirmed,
    this.phoneNumberConfirmed,
    this.twoFactorEnabled,
    this.subscriptionPlanId,
    this.academicStageId,
    this.academicYearId,
    this.academicSectionId,
    this.academicStage,
    this.academicYear,
    this.academicSection,
    this.subscriptionPlan,
    this.roles,
    this.createdAt,
    this.language,
  });

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}

@JsonSerializable()
class AcademicStage {
  final int? id;
  final String? stageName;
  final String? stageNameInAr;
  final String? name;
  final String? nameInAr;

  const AcademicStage({
    this.id,
    this.stageName,
    this.stageNameInAr,
    this.name,
    this.nameInAr,
  });

  factory AcademicStage.fromJson(Map<String, dynamic> json) =>
      _$AcademicStageFromJson(json);

  Map<String, dynamic> toJson() => _$AcademicStageToJson(this);
}

@JsonSerializable()
class AcademicYear {
  final int? id;
  final String? yearName;
  final String? yearNameInAr;
  final int? academicStageId;
  final AcademicStage? academicStage;
  final String? name;
  final String? nameInAr;

  const AcademicYear({
    this.id,
    this.yearName,
    this.yearNameInAr,
    this.academicStageId,
    this.academicStage,
    this.name,
    this.nameInAr,
  });

  factory AcademicYear.fromJson(Map<String, dynamic> json) =>
      _$AcademicYearFromJson(json);

  Map<String, dynamic> toJson() => _$AcademicYearToJson(this);
}

@JsonSerializable()
class AcademicSection {
  final int? id;
  final String? sectionName;
  final String? sectionNameInAr;
  final String? name;
  final String? nameInAr;

  const AcademicSection({
    this.id,
    this.sectionName,
    this.sectionNameInAr,
    this.name,
    this.nameInAr,
  });

  factory AcademicSection.fromJson(Map<String, dynamic> json) =>
      _$AcademicSectionFromJson(json);

  Map<String, dynamic> toJson() => _$AcademicSectionToJson(this);
}

@JsonSerializable()
class SubscriptionPlan {
  final int? id;
  final String? name;
  final String? nameInAr;
  final String? description;
  final String? descriptionInAr;
  final double? monthlyPrice;
  final double? quarterlyPrice;
  final double? semiAnnualPrice;
  final double? annualPrice;
  final String? currency;
  final bool? isDefault;
  final bool? isActive;
  final List<SubscriptionRole>? roles;

  const SubscriptionPlan({
    this.id,
    this.name,
    this.nameInAr,
    this.description,
    this.descriptionInAr,
    this.monthlyPrice,
    this.quarterlyPrice,
    this.semiAnnualPrice,
    this.annualPrice,
    this.currency,
    this.isDefault,
    this.isActive,
    this.roles,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPlanFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionPlanToJson(this);
}

@JsonSerializable()
class SubscriptionRole {
  final int? id;
  final String? roleName;
  final String? roleNameInAr;
  final int? resourceType;
  final int? limitType;
  final int? maxCount;
  final double? maxSize;
  final String? unit;
  final String? description;
  final String? descriptionInAr;
  final bool? isUnlimited;
  final int? priority;
  final String? createdAt;

  const SubscriptionRole({
    this.id,
    this.roleName,
    this.roleNameInAr,
    this.resourceType,
    this.limitType,
    this.maxCount,
    this.maxSize,
    this.unit,
    this.description,
    this.descriptionInAr,
    this.isUnlimited,
    this.priority,
    this.createdAt,
  });

  factory SubscriptionRole.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionRoleFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionRoleToJson(this);
}

// Simple response for endpoints that return only success/message
@JsonSerializable()
class SimpleResponse {
  final bool? success;
  final String? message;
  final dynamic data;
  final List<String>? errors;

  const SimpleResponse({
    this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory SimpleResponse.fromJson(Map<String, dynamic> json) =>
      _$SimpleResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SimpleResponseToJson(this);

  bool get isSuccess => success == true;
}

// Profile response
@JsonSerializable()
class ProfileResponse {
  final bool? success;
  final String? message;
  final UserData? data;
  final List<String>? errors;

  const ProfileResponse({
    this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileResponseToJson(this);

  bool get isSuccess => success == true;
}

// Academic Stages Response
@JsonSerializable()
class AcademicStagesResponse {
  final bool? success;
  final String? message;
  final List<AcademicStage>? data;
  final List<String>? errors;

  const AcademicStagesResponse({
    this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory AcademicStagesResponse.fromJson(Map<String, dynamic> json) =>
      _$AcademicStagesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AcademicStagesResponseToJson(this);

  bool get isSuccess => success == true;
}

// Academic Years Response
@JsonSerializable()
class AcademicYearsResponse {
  final bool? success;
  final String? message;
  final List<AcademicYear>? data;
  final List<String>? errors;

  const AcademicYearsResponse({
    this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory AcademicYearsResponse.fromJson(Map<String, dynamic> json) =>
      _$AcademicYearsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AcademicYearsResponseToJson(this);

  bool get isSuccess => success == true;
}

// Academic Sections Response
@JsonSerializable()
class AcademicSectionsResponse {
  final bool? success;
  final String? message;
  final List<AcademicSection>? data;
  final List<String>? errors;

  const AcademicSectionsResponse({
    this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory AcademicSectionsResponse.fromJson(Map<String, dynamic> json) =>
      _$AcademicSectionsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AcademicSectionsResponseToJson(this);

  bool get isSuccess => success == true;
}

// Update Student Profile Request
@JsonSerializable(includeIfNull: false)
class UpdateStudentProfileRequest {
  final String? name;
  final String? nickname;
  final int? gender;
  final String? phoneNumber;
  final String? dateOfBirth;
  final int? academicStageId;
  final int? academicYearId;
  final int? academicSectionId;

  const UpdateStudentProfileRequest({
    this.name,
    this.nickname,
    this.gender,
    this.phoneNumber,
    this.dateOfBirth,
    this.academicStageId,
    this.academicYearId,
    this.academicSectionId,
  });

  factory UpdateStudentProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateStudentProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateStudentProfileRequestToJson(this);
}

// Student Profile Response (same structure as ProfileResponse)
@JsonSerializable()
class StudentProfileResponse {
  final bool? success;
  final String? message;
  final UserData? data;
  final List<String>? errors;

  const StudentProfileResponse({
    this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory StudentProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$StudentProfileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$StudentProfileResponseToJson(this);

  bool get isSuccess => success == true;
}
