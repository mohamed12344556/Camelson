// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrentSubscriptionResponse _$CurrentSubscriptionResponseFromJson(
  Map<String, dynamic> json,
) => CurrentSubscriptionResponse(
  success: json['success'] as bool,
  data: json['data'] == null
      ? null
      : CurrentSubscriptionModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CurrentSubscriptionResponseToJson(
  CurrentSubscriptionResponse instance,
) => <String, dynamic>{'success': instance.success, 'data': instance.data};

CurrentSubscriptionModel _$CurrentSubscriptionModelFromJson(
  Map<String, dynamic> json,
) => CurrentSubscriptionModel(
  id: (json['id'] as num).toInt(),
  userId: json['userId'] as String,
  subscriptionPlanId: (json['subscriptionPlanId'] as num).toInt(),
  subscriptionPlanName: json['subscriptionPlanName'] as String,
  billingPeriod: (json['billingPeriod'] as num).toInt(),
  monthlyPrice: (json['monthlyPrice'] as num).toDouble(),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  daysRemaining: (json['daysRemaining'] as num).toInt(),
  status: json['status'] as String,
  paymentStatus: json['paymentStatus'] as String,
  autoRenew: json['autoRenew'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  isActive: json['isActive'] as bool,
  isExpired: json['isExpired'] as bool,
  isCancelled: json['isCancelled'] as bool,
);

Map<String, dynamic> _$CurrentSubscriptionModelToJson(
  CurrentSubscriptionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'subscriptionPlanId': instance.subscriptionPlanId,
  'subscriptionPlanName': instance.subscriptionPlanName,
  'billingPeriod': instance.billingPeriod,
  'monthlyPrice': instance.monthlyPrice,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'daysRemaining': instance.daysRemaining,
  'status': instance.status,
  'paymentStatus': instance.paymentStatus,
  'autoRenew': instance.autoRenew,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'isActive': instance.isActive,
  'isExpired': instance.isExpired,
  'isCancelled': instance.isCancelled,
};
