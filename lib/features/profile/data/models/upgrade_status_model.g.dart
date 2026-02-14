// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upgrade_status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpgradeStatusResponse _$UpgradeStatusResponseFromJson(
  Map<String, dynamic> json,
) => UpgradeStatusResponse(
  success: json['success'] as bool,
  data: json['data'] == null
      ? null
      : UpgradeStatusModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UpgradeStatusResponseToJson(
  UpgradeStatusResponse instance,
) => <String, dynamic>{'success': instance.success, 'data': instance.data};

UpgradeStatusModel _$UpgradeStatusModelFromJson(Map<String, dynamic> json) =>
    UpgradeStatusModel(
      success: json['success'] as bool,
      message: json['message'] as String?,
      upgradeRequestId: json['upgradeRequestId'] as String,
      status: (json['status'] as num).toInt(),
      statusCode: (json['statusCode'] as num).toInt(),
      invoiceKey: json['invoiceKey'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      isApplied: json['isApplied'] as bool,
      details: json['details'] == null
          ? null
          : UpgradeStatusDetails.fromJson(
              json['details'] as Map<String, dynamic>,
            ),
      nextActions: json['nextActions'] as List<dynamic>,
      canCancel: json['canCancel'] as bool,
      canRetry: json['canRetry'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UpgradeStatusModelToJson(UpgradeStatusModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'upgradeRequestId': instance.upgradeRequestId,
      'status': instance.status,
      'statusCode': instance.statusCode,
      'invoiceKey': instance.invoiceKey,
      'amount': instance.amount,
      'currency': instance.currency,
      'isApplied': instance.isApplied,
      'details': instance.details,
      'nextActions': instance.nextActions,
      'canCancel': instance.canCancel,
      'canRetry': instance.canRetry,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

UpgradeStatusDetails _$UpgradeStatusDetailsFromJson(
  Map<String, dynamic> json,
) => UpgradeStatusDetails(
  fromPlanId: (json['fromPlanId'] as num).toInt(),
  toPlanId: (json['toPlanId'] as num).toInt(),
  billingPeriod: (json['billingPeriod'] as num).toInt(),
  startImmediately: json['startImmediately'] as bool,
  proratedCredit: (json['proratedCredit'] as num).toDouble(),
  proratedCharge: (json['proratedCharge'] as num).toDouble(),
  newFeatures: json['newFeatures'] as List<dynamic>,
  improvedLimits: json['improvedLimits'] as List<dynamic>,
);

Map<String, dynamic> _$UpgradeStatusDetailsToJson(
  UpgradeStatusDetails instance,
) => <String, dynamic>{
  'fromPlanId': instance.fromPlanId,
  'toPlanId': instance.toPlanId,
  'billingPeriod': instance.billingPeriod,
  'startImmediately': instance.startImmediately,
  'proratedCredit': instance.proratedCredit,
  'proratedCharge': instance.proratedCharge,
  'newFeatures': instance.newFeatures,
  'improvedLimits': instance.improvedLimits,
};
