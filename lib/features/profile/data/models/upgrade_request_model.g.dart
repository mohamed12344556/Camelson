// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upgrade_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpgradeRequestsResponse _$UpgradeRequestsResponseFromJson(
  Map<String, dynamic> json,
) => UpgradeRequestsResponse(
  success: json['success'] as bool,
  data: UpgradeRequestsData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UpgradeRequestsResponseToJson(
  UpgradeRequestsResponse instance,
) => <String, dynamic>{'success': instance.success, 'data': instance.data};

UpgradeRequestsData _$UpgradeRequestsDataFromJson(Map<String, dynamic> json) =>
    UpgradeRequestsData(
      requests: (json['requests'] as List<dynamic>)
          .map((e) => UpgradeRequestModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      statistics: UpgradeRequestStatistics.fromJson(
        json['statistics'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$UpgradeRequestsDataToJson(
  UpgradeRequestsData instance,
) => <String, dynamic>{
  'requests': instance.requests,
  'statistics': instance.statistics,
};

UpgradeRequestModel _$UpgradeRequestModelFromJson(Map<String, dynamic> json) =>
    UpgradeRequestModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      currentPlanName: json['currentPlanName'] as String,
      newPlanId: (json['newPlanId'] as num).toInt(),
      newPlanName: json['newPlanName'] as String,
      billingPeriod: json['billingPeriod'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      statusCode: (json['statusCode'] as num).toInt(),
      upgradeType: json['upgradeType'] as String,
      startImmediately: json['startImmediately'] as bool,
      invoiceKey: json['invoiceKey'] as String?,
      paymentUrl: json['paymentUrl'] as String?,
      errorMessage: json['errorMessage'] as String?,
      retryCount: (json['retryCount'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      canCancel: json['canCancel'] as bool,
      canRetry: json['canRetry'] as bool,
    );

Map<String, dynamic> _$UpgradeRequestModelToJson(
  UpgradeRequestModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'userName': instance.userName,
  'userEmail': instance.userEmail,
  'currentPlanName': instance.currentPlanName,
  'newPlanId': instance.newPlanId,
  'newPlanName': instance.newPlanName,
  'billingPeriod': instance.billingPeriod,
  'amount': instance.amount,
  'currency': instance.currency,
  'status': instance.status,
  'statusCode': instance.statusCode,
  'upgradeType': instance.upgradeType,
  'startImmediately': instance.startImmediately,
  'invoiceKey': instance.invoiceKey,
  'paymentUrl': instance.paymentUrl,
  'errorMessage': instance.errorMessage,
  'retryCount': instance.retryCount,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'canCancel': instance.canCancel,
  'canRetry': instance.canRetry,
};

UpgradeRequestStatistics _$UpgradeRequestStatisticsFromJson(
  Map<String, dynamic> json,
) => UpgradeRequestStatistics(
  completed: (json['completed'] as num).toInt(),
  pending: (json['pending'] as num).toInt(),
  failed: (json['failed'] as num).toInt(),
  cancelled: (json['cancelled'] as num).toInt(),
);

Map<String, dynamic> _$UpgradeRequestStatisticsToJson(
  UpgradeRequestStatistics instance,
) => <String, dynamic>{
  'completed': instance.completed,
  'pending': instance.pending,
  'failed': instance.failed,
  'cancelled': instance.cancelled,
};
