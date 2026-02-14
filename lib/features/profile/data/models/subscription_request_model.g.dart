// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionRequestModel _$SubscriptionRequestModelFromJson(
  Map<String, dynamic> json,
) => SubscriptionRequestModel(
  newPlanId: (json['newPlanId'] as num).toInt(),
  newBillingPeriod: (json['newBillingPeriod'] as num).toInt(),
  proRata: json['proRata'] as bool? ?? true,
  immediate: json['immediate'] as bool? ?? true,
  discountCode: json['discountCode'] as String? ?? '',
  paymentMethod: json['paymentMethod'] as String? ?? '',
);

Map<String, dynamic> _$SubscriptionRequestModelToJson(
  SubscriptionRequestModel instance,
) => <String, dynamic>{
  'newPlanId': instance.newPlanId,
  'newBillingPeriod': instance.newBillingPeriod,
  'proRata': instance.proRata,
  'immediate': instance.immediate,
  'discountCode': instance.discountCode,
  'paymentMethod': instance.paymentMethod,
};
