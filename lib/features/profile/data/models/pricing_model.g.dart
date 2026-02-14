// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pricing_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PricingModel _$PricingModelFromJson(Map<String, dynamic> json) => PricingModel(
  monthly: (json['monthly'] as num).toDouble(),
  quarterly: (json['quarterly'] as num).toDouble(),
  semiAnnual: (json['semiAnnual'] as num).toDouble(),
  annual: (json['annual'] as num).toDouble(),
);

Map<String, dynamic> _$PricingModelToJson(PricingModel instance) =>
    <String, dynamic>{
      'monthly': instance.monthly,
      'quarterly': instance.quarterly,
      'semiAnnual': instance.semiAnnual,
      'annual': instance.annual,
    };
