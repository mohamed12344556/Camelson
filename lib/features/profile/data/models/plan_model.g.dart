// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlanModel _$PlanModelFromJson(Map<String, dynamic> json) => PlanModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  nameInAr: json['nameInAr'] as String?,
  description: json['description'] as String,
  descriptionInAr: json['descriptionInAr'] as String?,
  planType: json['planType'] as String,
  pricing: PricingModel.fromJson(json['pricing'] as Map<String, dynamic>),
  currency: json['currency'] as String,
  isActive: json['isActive'] as bool,
  forStudent: json['forStudent'] as bool,
  isDefault: json['isDefault'] as bool,
  features: (json['features'] as List<dynamic>)
      .map((e) => FeatureModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  resources: json['resources'] as List<dynamic>,
  activeDiscounts: json['activeDiscounts'] as List<dynamic>,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$PlanModelToJson(PlanModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'nameInAr': instance.nameInAr,
  'description': instance.description,
  'descriptionInAr': instance.descriptionInAr,
  'planType': instance.planType,
  'pricing': instance.pricing,
  'currency': instance.currency,
  'isActive': instance.isActive,
  'forStudent': instance.forStudent,
  'isDefault': instance.isDefault,
  'features': instance.features,
  'resources': instance.resources,
  'activeDiscounts': instance.activeDiscounts,
  'createdAt': instance.createdAt.toIso8601String(),
};
