import 'package:json_annotation/json_annotation.dart';

part 'current_subscription_model.g.dart';

/// Response wrapper for current subscription
@JsonSerializable()
class CurrentSubscriptionResponse {
  final bool success;
  final CurrentSubscriptionModel? data;

  const CurrentSubscriptionResponse({
    required this.success,
    this.data,
  });

  factory CurrentSubscriptionResponse.fromJson(Map<String, dynamic> json) =>
      _$CurrentSubscriptionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentSubscriptionResponseToJson(this);
}

/// Model representing user's current subscription
@JsonSerializable()
class CurrentSubscriptionModel {
  final int id;
  final String userId;
  final int subscriptionPlanId;
  final String subscriptionPlanName;
  final int billingPeriod;
  final double monthlyPrice;
  final DateTime startDate;
  final DateTime endDate;
  final int daysRemaining;
  final String status;
  final String paymentStatus;
  final bool autoRenew;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isExpired;
  final bool isCancelled;

  const CurrentSubscriptionModel({
    required this.id,
    required this.userId,
    required this.subscriptionPlanId,
    required this.subscriptionPlanName,
    required this.billingPeriod,
    required this.monthlyPrice,
    required this.startDate,
    required this.endDate,
    required this.daysRemaining,
    required this.status,
    required this.paymentStatus,
    required this.autoRenew,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.isExpired,
    required this.isCancelled,
  });

  factory CurrentSubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$CurrentSubscriptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentSubscriptionModelToJson(this);

  /// Check if subscription is in good standing
  bool get isInGoodStanding => isActive && !isExpired && !isCancelled;

  /// Get billing period name
  String get billingPeriodName {
    switch (billingPeriod) {
      case 1:
        return 'Monthly';
      case 3:
        return 'Quarterly';
      case 6:
        return 'Semi-Annual';
      case 12:
        return 'Annual';
      default:
        return 'Unknown';
    }
  }
}
