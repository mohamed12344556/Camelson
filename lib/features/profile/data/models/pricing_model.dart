import 'package:json_annotation/json_annotation.dart';

part 'pricing_model.g.dart'; // ✅ Correct

@JsonSerializable()
class PricingModel {
  final double monthly;
  final double quarterly;
  final double semiAnnual;
  final double annual;

  const PricingModel({
    required this.monthly,
    required this.quarterly,
    required this.semiAnnual,
    required this.annual,
  });

  factory PricingModel.fromJson(Map<String, dynamic> json) =>
      _$PricingModelFromJson(json);

  Map<String, dynamic> toJson() => _$PricingModelToJson(this);

  double getPriceForPeriod(BillingPeriod period) {
    switch (period) {
      case BillingPeriod.monthly:
        return monthly;
      case BillingPeriod.quarterly:
        return quarterly;
      case BillingPeriod.semiAnnual:
        return semiAnnual;
      case BillingPeriod.annual:
        return annual;
    }
  }
}

enum BillingPeriod {
  @JsonValue(1)
  monthly(1, 'Monthly', 'شهري'),
  @JsonValue(3)
  quarterly(3, 'Quarterly', 'ربع سنوي'),
  @JsonValue(6)
  semiAnnual(6, 'Semi-Annual', 'نصف سنوي'),
  @JsonValue(12)
  annual(12, 'Annual', 'سنوي');

  final int value;
  final String nameEn;
  final String nameAr;

  const BillingPeriod(this.value, this.nameEn, this.nameAr);

  static BillingPeriod fromValue(int value) {
    return BillingPeriod.values.firstWhere((e) => e.value == value);
  }
}
