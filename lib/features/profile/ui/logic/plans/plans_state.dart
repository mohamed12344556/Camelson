import 'package:equatable/equatable.dart';
import '../../../data/models/current_subscription_model.dart';
import '../../../data/models/plan_model.dart';
import '../../../data/models/pricing_model.dart';
import '../../../data/models/resource_usage_model.dart';
import '../../../data/models/subscription_response_model.dart';
import '../../../data/models/upgrade_request_model.dart';
import '../../../data/models/upgrade_status_model.dart';

class PlansState extends Equatable {
  final PlansStatus status;
  final List<PlanModel> plans;
  final PlanModel? selectedPlan;
  final BillingPeriod selectedBillingPeriod;
  final SubscriptionResponseModel? subscriptionResponse;
  final String? errorMessage;
  final SubscriptionStatus subscriptionStatus;

  // Upgrade requests
  final List<UpgradeRequestModel> upgradeRequests;
  final UpgradeRequestStatistics? upgradeStatistics;
  final UpgradeRequestsStatus upgradeRequestsStatus;

  // Current subscription
  final CurrentSubscriptionModel? currentSubscription;
  final CurrentSubscriptionStatus currentSubscriptionStatus;

  // Upgrade status check
  final UpgradeStatusModel? upgradeStatus;
  final UpgradeStatusCheckStatus upgradeStatusCheckStatus;

  // Resource usage
  final Map<String, ResourceUsageModel> resourceUsages;
  final ResourceUsageStatus resourceUsageStatus;

  // Cancel upgrade
  final CancelUpgradeStatus cancelUpgradeStatus;

  const PlansState({
    this.status = PlansStatus.initial,
    this.plans = const [],
    this.selectedPlan,
    this.selectedBillingPeriod = BillingPeriod.monthly,
    this.subscriptionResponse,
    this.errorMessage,
    this.subscriptionStatus = SubscriptionStatus.idle,
    this.upgradeRequests = const [],
    this.upgradeStatistics,
    this.upgradeRequestsStatus = UpgradeRequestsStatus.initial,
    this.currentSubscription,
    this.currentSubscriptionStatus = CurrentSubscriptionStatus.initial,
    this.upgradeStatus,
    this.upgradeStatusCheckStatus = UpgradeStatusCheckStatus.initial,
    this.resourceUsages = const {},
    this.resourceUsageStatus = ResourceUsageStatus.initial,
    this.cancelUpgradeStatus = CancelUpgradeStatus.idle,
  });

  PlansState copyWith({
    PlansStatus? status,
    List<PlanModel>? plans,
    PlanModel? selectedPlan,
    BillingPeriod? selectedBillingPeriod,
    SubscriptionResponseModel? subscriptionResponse,
    String? errorMessage,
    SubscriptionStatus? subscriptionStatus,
    List<UpgradeRequestModel>? upgradeRequests,
    UpgradeRequestStatistics? upgradeStatistics,
    UpgradeRequestsStatus? upgradeRequestsStatus,
    CurrentSubscriptionModel? currentSubscription,
    CurrentSubscriptionStatus? currentSubscriptionStatus,
    UpgradeStatusModel? upgradeStatus,
    UpgradeStatusCheckStatus? upgradeStatusCheckStatus,
    Map<String, ResourceUsageModel>? resourceUsages,
    ResourceUsageStatus? resourceUsageStatus,
    CancelUpgradeStatus? cancelUpgradeStatus,
  }) {
    return PlansState(
      status: status ?? this.status,
      plans: plans ?? this.plans,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      selectedBillingPeriod:
          selectedBillingPeriod ?? this.selectedBillingPeriod,
      subscriptionResponse: subscriptionResponse ?? this.subscriptionResponse,
      errorMessage: errorMessage ?? this.errorMessage,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      upgradeRequests: upgradeRequests ?? this.upgradeRequests,
      upgradeStatistics: upgradeStatistics ?? this.upgradeStatistics,
      upgradeRequestsStatus: upgradeRequestsStatus ?? this.upgradeRequestsStatus,
      currentSubscription: currentSubscription ?? this.currentSubscription,
      currentSubscriptionStatus:
          currentSubscriptionStatus ?? this.currentSubscriptionStatus,
      upgradeStatus: upgradeStatus ?? this.upgradeStatus,
      upgradeStatusCheckStatus:
          upgradeStatusCheckStatus ?? this.upgradeStatusCheckStatus,
      resourceUsages: resourceUsages ?? this.resourceUsages,
      resourceUsageStatus: resourceUsageStatus ?? this.resourceUsageStatus,
      cancelUpgradeStatus: cancelUpgradeStatus ?? this.cancelUpgradeStatus,
    );
  }

  @override
  List<Object?> get props => [
    status,
    plans,
    selectedPlan,
    selectedBillingPeriod,
    subscriptionResponse,
    errorMessage,
    subscriptionStatus,
    upgradeRequests,
    upgradeStatistics,
    upgradeRequestsStatus,
    currentSubscription,
    currentSubscriptionStatus,
    upgradeStatus,
    upgradeStatusCheckStatus,
    resourceUsages,
    resourceUsageStatus,
    cancelUpgradeStatus,
  ];
}

enum PlansStatus { initial, loading, success, error }

enum SubscriptionStatus { idle, subscribing, success, error }

enum UpgradeRequestsStatus { initial, loading, success, error }

enum CurrentSubscriptionStatus { initial, loading, success, error }

enum UpgradeStatusCheckStatus { initial, loading, success, error }

enum ResourceUsageStatus { initial, loading, success, error }

enum CancelUpgradeStatus { idle, cancelling, success, error }
