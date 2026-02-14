import 'package:json_annotation/json_annotation.dart';

part 'upgrade_request_model.g.dart';

/// Response wrapper for upgrade requests list
@JsonSerializable()
class UpgradeRequestsResponse {
  final bool success;
  final UpgradeRequestsData data;

  const UpgradeRequestsResponse({
    required this.success,
    required this.data,
  });

  factory UpgradeRequestsResponse.fromJson(Map<String, dynamic> json) =>
      _$UpgradeRequestsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UpgradeRequestsResponseToJson(this);
}

@JsonSerializable()
class UpgradeRequestsData {
  final List<UpgradeRequestModel> requests;
  final UpgradeRequestStatistics statistics;

  const UpgradeRequestsData({
    required this.requests,
    required this.statistics,
  });

  factory UpgradeRequestsData.fromJson(Map<String, dynamic> json) =>
      _$UpgradeRequestsDataFromJson(json);

  Map<String, dynamic> toJson() => _$UpgradeRequestsDataToJson(this);
}

@JsonSerializable()
class UpgradeRequestModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String currentPlanName;
  final int newPlanId;
  final String newPlanName;
  final String billingPeriod;
  final double amount;
  final String currency;
  final String status;
  final int statusCode;
  final String upgradeType;
  final bool startImmediately;
  final String? invoiceKey;
    final String? paymentUrl;  // ✅ إضافة هذا الحقل

  final String? errorMessage;
  final int retryCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool canCancel;
  final bool canRetry;

  const UpgradeRequestModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.currentPlanName,
    required this.newPlanId,
    required this.newPlanName,
    required this.billingPeriod,
    required this.amount,
    required this.currency,
    required this.status,
    required this.statusCode,
    required this.upgradeType,
    required this.startImmediately,
    this.invoiceKey,
    this.paymentUrl,
    this.errorMessage,
    required this.retryCount,
    required this.createdAt,
    required this.updatedAt,
    required this.canCancel,
    required this.canRetry,
  });

  factory UpgradeRequestModel.fromJson(Map<String, dynamic> json) =>
      _$UpgradeRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$UpgradeRequestModelToJson(this);

  /// Check if request is pending payment
  bool get isPendingPayment => status == 'PaymentPending';

  /// Check if request is completed
  bool get isCompleted => status == 'Completed';

  /// Check if request failed
  bool get isFailed => status == 'Failed';

  /// Check if request is cancelled
  bool get isCancelled => status == 'Cancelled';

  /// Check if request is scheduled (waiting for current plan to expire)
  bool get isScheduled => status == 'Scheduled' || statusCode == 11;
}

@JsonSerializable()
class UpgradeRequestStatistics {
  final int completed;
  final int pending;
  final int failed;
  final int cancelled;

  const UpgradeRequestStatistics({
    required this.completed,
    required this.pending,
    required this.failed,
    required this.cancelled,
  });

  factory UpgradeRequestStatistics.fromJson(Map<String, dynamic> json) =>
      _$UpgradeRequestStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$UpgradeRequestStatisticsToJson(this);

  int get total => completed + pending + failed + cancelled;
}
