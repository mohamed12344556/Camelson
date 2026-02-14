import 'package:json_annotation/json_annotation.dart';

part 'resource_usage_model.g.dart';

/// Request model for using a resource
@JsonSerializable()
class UseResourceRequest {
  final int? count;
  final double? sizeInMB;
  final int? durationInMinutes;
  final String? details;
  final Map<String, String>? metadata;

  const UseResourceRequest({
    this.count,
    this.sizeInMB,
    this.durationInMinutes,
    this.details,
    this.metadata,
  });

  factory UseResourceRequest.fromJson(Map<String, dynamic> json) =>
      _$UseResourceRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UseResourceRequestToJson(this);

  /// Create request for count-based resources (like AI messages)
  factory UseResourceRequest.forCount(int count, {String? details}) {
    return UseResourceRequest(count: count, details: details);
  }

  /// Create request for size-based resources (like storage)
  factory UseResourceRequest.forSize(double sizeInMB, {String? details}) {
    return UseResourceRequest(sizeInMB: sizeInMB, details: details);
  }

  /// Create request for duration-based resources
  factory UseResourceRequest.forDuration(int durationInMinutes,
      {String? details}) {
    return UseResourceRequest(
        durationInMinutes: durationInMinutes, details: details);
  }
}

/// Response model for using a resource
@JsonSerializable()
class UseResourceResponse {
  final bool success;
  final String? message;
  final int remaining;
  final int currentUsage;
  final double currentSize;
  final int currentDuration;
  final int limit;
  final DateTime? nextResetTime;

  const UseResourceResponse({
    required this.success,
    this.message,
    required this.remaining,
    required this.currentUsage,
    required this.currentSize,
    required this.currentDuration,
    required this.limit,
    this.nextResetTime,
  });

  factory UseResourceResponse.fromJson(Map<String, dynamic> json) =>
      _$UseResourceResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UseResourceResponseToJson(this);

  /// Get usage percentage
  double get usagePercentage =>
      limit > 0 ? (currentUsage / limit) * 100 : 0;

  /// Check if near limit (>80%)
  bool get isNearLimit => usagePercentage >= 80;

  /// Check if at limit
  bool get isAtLimit => remaining <= 0;
}

/// Response model for getting resource usage
@JsonSerializable()
class ResourceUsageModel {
  final int id;
  final String resourceName;
  final int countUsed;
  final double sizeUsed;
  final int durationUsed;
  final double usagePercentage;
  final bool isNearLimit;
  final bool isOverLimit;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime lastUsedAt;
  final int resetCount;

  const ResourceUsageModel({
    required this.id,
    required this.resourceName,
    required this.countUsed,
    required this.sizeUsed,
    required this.durationUsed,
    required this.usagePercentage,
    required this.isNearLimit,
    required this.isOverLimit,
    required this.periodStart,
    required this.periodEnd,
    required this.lastUsedAt,
    required this.resetCount,
  });

  factory ResourceUsageModel.fromJson(Map<String, dynamic> json) =>
      _$ResourceUsageModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResourceUsageModelToJson(this);

  /// Get remaining time in period
  Duration get remainingPeriod => periodEnd.difference(DateTime.now());

  /// Check if period is active
  bool get isPeriodActive => DateTime.now().isBefore(periodEnd);
}
