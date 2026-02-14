import 'package:json_annotation/json_annotation.dart';
import 'feature_model.dart';
import 'pricing_model.dart';

part 'plan_model.g.dart'; // ✅ Correct

@JsonSerializable()
class PlanModel {
  final int id;
  final String name;
  final String? nameInAr;
  final String description;
  final String? descriptionInAr;
  final String planType;
  final PricingModel pricing;
  final String currency;
  final bool isActive;
  final bool forStudent;
  final bool isDefault;
  final List<FeatureModel> features;
  final List<dynamic> resources;
  final List<dynamic> activeDiscounts;
  final DateTime createdAt;

  const PlanModel({
    required this.id,
    required this.name,
    this.nameInAr,
    required this.description,
    this.descriptionInAr,
    required this.planType,
    required this.pricing,
    required this.currency,
    required this.isActive,
    required this.forStudent,
    required this.isDefault,
    required this.features,
    required this.resources,
    required this.activeDiscounts,
    required this.createdAt,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) =>
      _$PlanModelFromJson(json);

  Map<String, dynamic> toJson() => _$PlanModelToJson(this);

  String getLocalizedName(bool isArabic) {
    return isArabic && nameInAr != null ? nameInAr! : name;
  }

  String getLocalizedDescription(bool isArabic) {
    return isArabic && descriptionInAr != null ? descriptionInAr! : description;
  }

  PlanTypeEnum get planTypeEnum {
    return PlanTypeEnum.fromString(planType);
  }
}

enum PlanTypeEnum {
  free('Free', 'مجاني'),
  pro('Pro', 'احترافي'),
  enterprise('Enterprise', 'مؤسسي'),
  premium('Premium', 'مميز');

  final String nameEn;
  final String nameAr;

  const PlanTypeEnum(this.nameEn, this.nameAr);

  static PlanTypeEnum fromString(String value) {
    return PlanTypeEnum.values.firstWhere(
      (e) => e.nameEn.toLowerCase() == value.toLowerCase(),
      orElse: () => PlanTypeEnum.free,
    );
  }
}
