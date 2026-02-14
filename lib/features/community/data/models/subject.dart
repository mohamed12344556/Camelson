import 'package:json_annotation/json_annotation.dart';

part 'subject.g.dart';

/// Subject/Topic model for community questions
@JsonSerializable()
class Subject {
  final String id;
  final String name;
  final String? description;
  final String? gradeLevel;
  final String? color;
  final String? language; // 'en' or 'ar'
  final DateTime createdAt;
  final bool isActive;

  Subject({
    required this.id,
    required this.name,
    this.description,
    this.gradeLevel,
    this.color,
    this.language,
    required this.createdAt,
    this.isActive = true,
  });

  factory Subject.fromJson(Map<String, dynamic> json) =>
      _$SubjectFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectToJson(this);
}

/// Response wrapper for subjects list
@JsonSerializable()
class SubjectsResponse {
  final bool success;
  final List<Subject> data;
  final int? page;
  final int? pageSize;
  final int? totalCount;
  final int? totalPages;
  final String? message;

  SubjectsResponse({
    required this.success,
    required this.data,
    this.page,
    this.pageSize,
    this.totalCount,
    this.totalPages,
    this.message,
  });

  factory SubjectsResponse.fromJson(Map<String, dynamic> json) =>
      _$SubjectsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectsResponseToJson(this);
}

/// Request to add member to question
@JsonSerializable()
class AddMemberRequest {
  final String userId;
  final int role; // 0=creator, 1=admin, 2=member

  AddMemberRequest({
    required this.userId,
    required this.role,
  });

  Map<String, dynamic> toJson() => _$AddMemberRequestToJson(this);
}
