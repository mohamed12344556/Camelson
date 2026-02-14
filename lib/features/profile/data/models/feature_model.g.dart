// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeatureModel _$FeatureModelFromJson(Map<String, dynamic> json) => FeatureModel(
  id: (json['id'] as num).toInt(),
  description: json['description'] as String,
  descriptionInAr: json['descriptionInAr'] as String?,
  isPositive: json['isPositive'] as bool,
  isAvailable: json['isAvailable'] as bool,
  displayOrder: (json['displayOrder'] as num).toInt(),
  icon: json['icon'] as String,
);

Map<String, dynamic> _$FeatureModelToJson(FeatureModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'descriptionInAr': instance.descriptionInAr,
      'isPositive': instance.isPositive,
      'isAvailable': instance.isAvailable,
      'displayOrder': instance.displayOrder,
      'icon': instance.icon,
    };
