import 'package:json_annotation/json_annotation.dart';

part 'cancel_upgrade_model.g.dart';

/// Request model for cancelling an upgrade request
@JsonSerializable()
class CancelUpgradeRequest {
  @JsonKey(name: 'UpgradeRequestId')
  final String upgradeRequestId;
  @JsonKey(name: 'Reason')
  final String reason;

  const CancelUpgradeRequest({
    required this.upgradeRequestId,
    required this.reason,
  });

  factory CancelUpgradeRequest.fromJson(Map<String, dynamic> json) =>
      _$CancelUpgradeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CancelUpgradeRequestToJson(this);
}

/// Response model for cancel upgrade
@JsonSerializable()
class CancelUpgradeResponse {
  final bool success;
  final String? message;

  const CancelUpgradeResponse({
    required this.success,
    this.message,
  });

  factory CancelUpgradeResponse.fromJson(Map<String, dynamic> json) =>
      _$CancelUpgradeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CancelUpgradeResponseToJson(this);
}

/// Request model for cancelling the current subscription
@JsonSerializable()
class CancelSubscriptionRequest {
  final String reason;
  final bool immediate;
  final bool requestRefund;
  final String feedback;

  const CancelSubscriptionRequest({
    required this.reason,
    this.immediate = true,
    this.requestRefund = false,
    this.feedback = '',
  });

  factory CancelSubscriptionRequest.fromJson(Map<String, dynamic> json) =>
      _$CancelSubscriptionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CancelSubscriptionRequestToJson(this);
}

/// Response model for cancel subscription
@JsonSerializable()
class CancelSubscriptionResponse {
  final bool success;
  final String? message;
  final CancelSubscriptionData? data;

  const CancelSubscriptionResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory CancelSubscriptionResponse.fromJson(Map<String, dynamic> json) =>
      _$CancelSubscriptionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CancelSubscriptionResponseToJson(this);
}

@JsonSerializable()
class CancelSubscriptionData {
  final bool success;
  final String? message;
  final DateTime? cancellationDate;
  final DateTime? accessEndDate;
  final bool autoRenewDisabled;

  const CancelSubscriptionData({
    required this.success,
    this.message,
    this.cancellationDate,
    this.accessEndDate,
    this.autoRenewDisabled = false,
  });

  factory CancelSubscriptionData.fromJson(Map<String, dynamic> json) =>
      _$CancelSubscriptionDataFromJson(json);

  Map<String, dynamic> toJson() => _$CancelSubscriptionDataToJson(this);
}
