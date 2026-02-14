import 'package:json_annotation/json_annotation.dart';
import 'pricing_model.dart';

part 'subscription_request_model.g.dart';

@JsonSerializable()
class SubscriptionRequestModel {
  final int newPlanId;
  final int newBillingPeriod;
  final bool proRata;
  final bool immediate;
  final String discountCode; // ✅ Remove nullable
  final String paymentMethod; // ✅ Remove nullable

  const SubscriptionRequestModel({
    required this.newPlanId,
    required this.newBillingPeriod,
    this.proRata = true,
    this.immediate = true,
    this.discountCode = '', // ✅ Default to empty string
    this.paymentMethod = '', // ✅ Default to empty string
  });

  factory SubscriptionRequestModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionRequestModelToJson(this);

  factory SubscriptionRequestModel.create({
    required int planId,
    required BillingPeriod billingPeriod,
    bool proRata = true,
    bool immediate = true,
    String? discountCode,
    String? paymentMethod,
  }) {
    return SubscriptionRequestModel(
      newPlanId: planId,
      newBillingPeriod: billingPeriod.value,
      proRata: proRata,
      immediate: immediate,
      discountCode: discountCode ?? '', // ✅ Handle null
      paymentMethod: paymentMethod ?? 'Card', // ✅ Default payment method
    );
  }
}
