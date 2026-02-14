// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_usage_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UseResourceRequest _$UseResourceRequestFromJson(Map<String, dynamic> json) =>
    UseResourceRequest(
      count: (json['count'] as num?)?.toInt(),
      sizeInMB: (json['sizeInMB'] as num?)?.toDouble(),
      durationInMinutes: (json['durationInMinutes'] as num?)?.toInt(),
      details: json['details'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$UseResourceRequestToJson(UseResourceRequest instance) =>
    <String, dynamic>{
      'count': instance.count,
      'sizeInMB': instance.sizeInMB,
      'durationInMinutes': instance.durationInMinutes,
      'details': instance.details,
      'metadata': instance.metadata,
    };

UseResourceResponse _$UseResourceResponseFromJson(Map<String, dynamic> json) =>
    UseResourceResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      remaining: (json['remaining'] as num).toInt(),
      currentUsage: (json['currentUsage'] as num).toInt(),
      currentSize: (json['currentSize'] as num).toDouble(),
      currentDuration: (json['currentDuration'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      nextResetTime: json['nextResetTime'] == null
          ? null
          : DateTime.parse(json['nextResetTime'] as String),
    );

Map<String, dynamic> _$UseResourceResponseToJson(
  UseResourceResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'remaining': instance.remaining,
  'currentUsage': instance.currentUsage,
  'currentSize': instance.currentSize,
  'currentDuration': instance.currentDuration,
  'limit': instance.limit,
  'nextResetTime': instance.nextResetTime?.toIso8601String(),
};

ResourceUsageModel _$ResourceUsageModelFromJson(Map<String, dynamic> json) =>
    ResourceUsageModel(
      id: (json['id'] as num).toInt(),
      resourceName: json['resourceName'] as String,
      countUsed: (json['countUsed'] as num).toInt(),
      sizeUsed: (json['sizeUsed'] as num).toDouble(),
      durationUsed: (json['durationUsed'] as num).toInt(),
      usagePercentage: (json['usagePercentage'] as num).toDouble(),
      isNearLimit: json['isNearLimit'] as bool,
      isOverLimit: json['isOverLimit'] as bool,
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      lastUsedAt: DateTime.parse(json['lastUsedAt'] as String),
      resetCount: (json['resetCount'] as num).toInt(),
    );

Map<String, dynamic> _$ResourceUsageModelToJson(ResourceUsageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'resourceName': instance.resourceName,
      'countUsed': instance.countUsed,
      'sizeUsed': instance.sizeUsed,
      'durationUsed': instance.durationUsed,
      'usagePercentage': instance.usagePercentage,
      'isNearLimit': instance.isNearLimit,
      'isOverLimit': instance.isOverLimit,
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'lastUsedAt': instance.lastUsedAt.toIso8601String(),
      'resetCount': instance.resetCount,
    };
