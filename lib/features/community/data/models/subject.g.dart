// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subject _$SubjectFromJson(Map<String, dynamic> json) => Subject(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  gradeLevel: json['gradeLevel'] as String?,
  color: json['color'] as String?,
  language: json['language'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$SubjectToJson(Subject instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'gradeLevel': instance.gradeLevel,
  'color': instance.color,
  'language': instance.language,
  'createdAt': instance.createdAt.toIso8601String(),
  'isActive': instance.isActive,
};

SubjectsResponse _$SubjectsResponseFromJson(Map<String, dynamic> json) =>
    SubjectsResponse(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((e) => Subject.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (json['page'] as num?)?.toInt(),
      pageSize: (json['pageSize'] as num?)?.toInt(),
      totalCount: (json['totalCount'] as num?)?.toInt(),
      totalPages: (json['totalPages'] as num?)?.toInt(),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$SubjectsResponseToJson(SubjectsResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
      'page': instance.page,
      'pageSize': instance.pageSize,
      'totalCount': instance.totalCount,
      'totalPages': instance.totalPages,
      'message': instance.message,
    };

AddMemberRequest _$AddMemberRequestFromJson(Map<String, dynamic> json) =>
    AddMemberRequest(
      userId: json['userId'] as String,
      role: (json['role'] as num).toInt(),
    );

Map<String, dynamic> _$AddMemberRequestToJson(AddMemberRequest instance) =>
    <String, dynamic>{'userId': instance.userId, 'role': instance.role};
