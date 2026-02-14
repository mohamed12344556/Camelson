import 'package:json_annotation/json_annotation.dart';

part 'subscription_response_model.g.dart';

/// Wrapper for subscription/upgrade response from API
@JsonSerializable()
class SubscriptionApiResponse {
  final bool success;
  final String? message;
  final SubscriptionResponseModel? data;
  final List<String> errors;

  const SubscriptionApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors = const [],
  });

  factory SubscriptionApiResponse.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionApiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionApiResponseToJson(this);
}

@JsonSerializable()
class SubscriptionResponseModel {
  final String upgradeRequestId;
  final String paymentUrl;
  final String invoiceKey;
  final double amount;
  final String currency;
  final int status;
  final DateTime createdAt;
  final SubscriptionDetailsModel details;
  final List<dynamic> nextActions;
  final bool canCancel;
  final bool canRetry;

  const SubscriptionResponseModel({
    required this.upgradeRequestId,
    required this.paymentUrl,
    required this.invoiceKey,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    required this.details,
    required this.nextActions,
    required this.canCancel,
    required this.canRetry,
  });

  factory SubscriptionResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionResponseModelToJson(this);
}

@JsonSerializable()
class SubscriptionDetailsModel {
  final String fromPlanName;
  final int toPlanId;
  final String toPlanName;
  final int billingPeriod;
  final bool startImmediately;
  final double proratedCredit;
  final double proratedCharge;
  final List<dynamic> newFeatures;
  final List<dynamic> improvedLimits;

  const SubscriptionDetailsModel({
    required this.fromPlanName,
    required this.toPlanId,
    required this.toPlanName,
    required this.billingPeriod,
    required this.startImmediately,
    required this.proratedCredit,
    required this.proratedCharge,
    required this.newFeatures,
    required this.improvedLimits,
  });

  factory SubscriptionDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionDetailsModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionDetailsModelToJson(this);
}
