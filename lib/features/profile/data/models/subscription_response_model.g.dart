// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionApiResponse _$SubscriptionApiResponseFromJson(
  Map<String, dynamic> json,
) => SubscriptionApiResponse(
  success: json['success'] as bool,
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : SubscriptionResponseModel.fromJson(
          json['data'] as Map<String, dynamic>,
        ),
  errors:
      (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$SubscriptionApiResponseToJson(
  SubscriptionApiResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
  'errors': instance.errors,
};

SubscriptionResponseModel _$SubscriptionResponseModelFromJson(
  Map<String, dynamic> json,
) => SubscriptionResponseModel(
  upgradeRequestId: json['upgradeRequestId'] as String,
  paymentUrl: json['paymentUrl'] as String,
  invoiceKey: json['invoiceKey'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
  status: (json['status'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  details: SubscriptionDetailsModel.fromJson(
    json['details'] as Map<String, dynamic>,
  ),
  nextActions: json['nextActions'] as List<dynamic>,
  canCancel: json['canCancel'] as bool,
  canRetry: json['canRetry'] as bool,
);

Map<String, dynamic> _$SubscriptionResponseModelToJson(
  SubscriptionResponseModel instance,
) => <String, dynamic>{
  'upgradeRequestId': instance.upgradeRequestId,
  'paymentUrl': instance.paymentUrl,
  'invoiceKey': instance.invoiceKey,
  'amount': instance.amount,
  'currency': instance.currency,
  'status': instance.status,
  'createdAt': instance.createdAt.toIso8601String(),
  'details': instance.details,
  'nextActions': instance.nextActions,
  'canCancel': instance.canCancel,
  'canRetry': instance.canRetry,
};

SubscriptionDetailsModel _$SubscriptionDetailsModelFromJson(
  Map<String, dynamic> json,
) => SubscriptionDetailsModel(
  fromPlanName: json['fromPlanName'] as String,
  toPlanId: (json['toPlanId'] as num).toInt(),
  toPlanName: json['toPlanName'] as String,
  billingPeriod: (json['billingPeriod'] as num).toInt(),
  startImmediately: json['startImmediately'] as bool,
  proratedCredit: (json['proratedCredit'] as num).toDouble(),
  proratedCharge: (json['proratedCharge'] as num).toDouble(),
  newFeatures: json['newFeatures'] as List<dynamic>,
  improvedLimits: json['improvedLimits'] as List<dynamic>,
);

Map<String, dynamic> _$SubscriptionDetailsModelToJson(
  SubscriptionDetailsModel instance,
) => <String, dynamic>{
  'fromPlanName': instance.fromPlanName,
  'toPlanId': instance.toPlanId,
  'toPlanName': instance.toPlanName,
  'billingPeriod': instance.billingPeriod,
  'startImmediately': instance.startImmediately,
  'proratedCredit': instance.proratedCredit,
  'proratedCharge': instance.proratedCharge,
  'newFeatures': instance.newFeatures,
  'improvedLimits': instance.improvedLimits,
};
