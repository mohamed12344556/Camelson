import 'package:json_annotation/json_annotation.dart';

part 'upgrade_status_model.g.dart';

/// Response wrapper for upgrade status check
@JsonSerializable()
class UpgradeStatusResponse {
  final bool success;
  final UpgradeStatusModel? data;

  const UpgradeStatusResponse({
    required this.success,
    this.data,
  });

  factory UpgradeStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$UpgradeStatusResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UpgradeStatusResponseToJson(this);
}

/// Model for upgrade request status details
@JsonSerializable()
class UpgradeStatusModel {
  final bool success;
  final String? message;
  final String upgradeRequestId;
  final int status;
  final int statusCode;
  final String? invoiceKey;
  final double amount;
  final String currency;
  final bool isApplied;
  final UpgradeStatusDetails? details;
  final List<dynamic> nextActions;
  final bool canCancel;
  final bool canRetry;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UpgradeStatusModel({
    required this.success,
    this.message,
    required this.upgradeRequestId,
    required this.status,
    required this.statusCode,
    this.invoiceKey,
    required this.amount,
    required this.currency,
    required this.isApplied,
    this.details,
    required this.nextActions,
    required this.canCancel,
    required this.canRetry,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UpgradeStatusModel.fromJson(Map<String, dynamic> json) =>
      _$UpgradeStatusModelFromJson(json);

  Map<String, dynamic> toJson() => _$UpgradeStatusModelToJson(this);

  /// Get human-readable status name
  String get statusName {
    switch (status) {
      case 1:
        return 'Pending';
      case 2:
        return 'Payment Pending';
      case 10:
        return 'Payment Received';
      case 20:
        return 'Applied';
      case 30:
        return 'Pending Review';
      case 40:
        return 'Completed';
      case 50:
        return 'Cancelled';
      case 60:
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  bool get isPending => status == 1 || status == 30;
  bool get isPaymentPending => status == 2;
  bool get isCompleted => status == 40;
  bool get isCancelled => status == 50;
  bool get isFailed => status == 60;
}

/// Details of upgrade request
@JsonSerializable()
class UpgradeStatusDetails {
  final int fromPlanId;
  final int toPlanId;
  final int billingPeriod;
  final bool startImmediately;
  final double proratedCredit;
  final double proratedCharge;
  final List<dynamic> newFeatures;
  final List<dynamic> improvedLimits;

  const UpgradeStatusDetails({
    required this.fromPlanId,
    required this.toPlanId,
    required this.billingPeriod,
    required this.startImmediately,
    required this.proratedCredit,
    required this.proratedCharge,
    required this.newFeatures,
    required this.improvedLimits,
  });

  factory UpgradeStatusDetails.fromJson(Map<String, dynamic> json) =>
      _$UpgradeStatusDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$UpgradeStatusDetailsToJson(this);
}
