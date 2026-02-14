// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cancel_upgrade_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CancelUpgradeRequest _$CancelUpgradeRequestFromJson(
  Map<String, dynamic> json,
) => CancelUpgradeRequest(
  upgradeRequestId: json['UpgradeRequestId'] as String,
  reason: json['Reason'] as String,
);

Map<String, dynamic> _$CancelUpgradeRequestToJson(
  CancelUpgradeRequest instance,
) => <String, dynamic>{
  'UpgradeRequestId': instance.upgradeRequestId,
  'Reason': instance.reason,
};

CancelUpgradeResponse _$CancelUpgradeResponseFromJson(
  Map<String, dynamic> json,
) => CancelUpgradeResponse(
  success: json['success'] as bool,
  message: json['message'] as String?,
);

Map<String, dynamic> _$CancelUpgradeResponseToJson(
  CancelUpgradeResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
};

CancelSubscriptionRequest _$CancelSubscriptionRequestFromJson(
  Map<String, dynamic> json,
) => CancelSubscriptionRequest(
  reason: json['reason'] as String,
  immediate: json['immediate'] as bool? ?? true,
  requestRefund: json['requestRefund'] as bool? ?? false,
  feedback: json['feedback'] as String? ?? '',
);

Map<String, dynamic> _$CancelSubscriptionRequestToJson(
  CancelSubscriptionRequest instance,
) => <String, dynamic>{
  'reason': instance.reason,
  'immediate': instance.immediate,
  'requestRefund': instance.requestRefund,
  'feedback': instance.feedback,
};

CancelSubscriptionResponse _$CancelSubscriptionResponseFromJson(
  Map<String, dynamic> json,
) => CancelSubscriptionResponse(
  success: json['success'] as bool,
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : CancelSubscriptionData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CancelSubscriptionResponseToJson(
  CancelSubscriptionResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

CancelSubscriptionData _$CancelSubscriptionDataFromJson(
  Map<String, dynamic> json,
) => CancelSubscriptionData(
  success: json['success'] as bool,
  message: json['message'] as String?,
  cancellationDate: json['cancellationDate'] == null
      ? null
      : DateTime.parse(json['cancellationDate'] as String),
  accessEndDate: json['accessEndDate'] == null
      ? null
      : DateTime.parse(json['accessEndDate'] as String),
  autoRenewDisabled: json['autoRenewDisabled'] as bool? ?? false,
);

Map<String, dynamic> _$CancelSubscriptionDataToJson(
  CancelSubscriptionData instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'cancellationDate': instance.cancellationDate?.toIso8601String(),
  'accessEndDate': instance.accessEndDate?.toIso8601String(),
  'autoRenewDisabled': instance.autoRenewDisabled,
};
