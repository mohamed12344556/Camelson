import 'package:json_annotation/json_annotation.dart';

part 'feature_model.g.dart';

@JsonSerializable()
class FeatureModel {
  final int id;
  final String description;
  final String? descriptionInAr;
  final bool isPositive;
  final bool isAvailable;
  final int displayOrder;
  final String icon;

  const FeatureModel({
    required this.id,
    required this.description,
    this.descriptionInAr,
    required this.isPositive,
    required this.isAvailable,
    required this.displayOrder,
    required this.icon,
  });

  factory FeatureModel.fromJson(Map<String, dynamic> json) =>
      _$FeatureModelFromJson(json);

  Map<String, dynamic> toJson() => _$FeatureModelToJson(this);

  String getLocalizedDescription(bool isArabic) {
    return isArabic && descriptionInAr != null ? descriptionInAr! : description;
  }
}
