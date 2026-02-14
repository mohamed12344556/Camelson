import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/pricing_model.dart';
import '../../../data/models/resource_usage_model.dart';
import '../../../data/models/subscription_request_model.dart';
import '../../../data/repo/plans_repository.dart';
import 'plans_state.dart';

class PlansCubit extends Cubit<PlansState> {
  final PlansRepository _repository;

  PlansCubit(this._repository) : super(const PlansState());

  /// Load all student plans
  Future<void> loadStudentPlans() async {
    emit(state.copyWith(status: PlansStatus.loading));

    final result = await _repository.getStudentPlans();

    result.fold(
      (error) {
        log('Error loading plans: ${error.errorMessage?.message}');
        emit(
          state.copyWith(
            status: PlansStatus.error,
            errorMessage: error.errorMessage?.message ?? 'Failed to load plans',
          ),
        );
      },
      (plans) {
        log('Plans loaded successfully: ${plans.length} plans');
        emit(state.copyWith(status: PlansStatus.success, plans: plans));
      },
    );
  }

  /// Load plan details by ID
  Future<void> loadPlanDetails(int planId) async {
    emit(state.copyWith(status: PlansStatus.loading));

    final result = await _repository.getPlanById(planId);

    result.fold(
      (error) {
        log('Error loading plan details: ${error.errorMessage?.message}');
        emit(
          state.copyWith(
            status: PlansStatus.error,
            errorMessage:
                error.errorMessage?.message ?? 'Failed to load plan details',
          ),
        );
      },
      (plan) {
        log('Plan details loaded: ${plan.name}');
        emit(state.copyWith(status: PlansStatus.success, selectedPlan: plan));
      },
    );
  }

  /// Select billing period
  void selectBillingPeriod(BillingPeriod period) {
    log('Selected billing period: ${period.nameEn}');
    emit(state.copyWith(selectedBillingPeriod: period));
  }

  /// Request subscription/upgrade
  Future<void> requestSubscription({
    required int planId,
    bool proRata = true,
    bool immediate = true,
    String? discountCode,
    String? paymentMethod,
  }) async {
    emit(state.copyWith(subscriptionStatus: SubscriptionStatus.subscribing));

    final request = SubscriptionRequestModel.create(
      planId: planId,
      billingPeriod: state.selectedBillingPeriod,
      proRata: proRata,
      immediate: immediate,
      discountCode: discountCode,
      paymentMethod: paymentMethod,
    );

    final result = await _repository.requestSubscription(request);

    result.fold(
      (error) {
        log('Error requesting subscription: ${error.errorMessage?.message}');
        emit(
          state.copyWith(
            subscriptionStatus: SubscriptionStatus.error,
            errorMessage: error.errorMessage?.message ?? 'Subscription failed',
          ),
        );
      },
      (response) {
        log('Subscription request successful: ${response.paymentUrl}');
        emit(
          state.copyWith(
            subscriptionStatus: SubscriptionStatus.success,
            subscriptionResponse: response,
          ),
        );
      },
    );
  }

  /// Reset subscription status
  void resetSubscriptionStatus() {
    emit(
      state.copyWith(
        subscriptionStatus: SubscriptionStatus.idle,
        errorMessage: null,
      ),
    );
  }

  /// Load user's upgrade requests
  Future<void> loadUpgradeRequests() async {
    emit(state.copyWith(upgradeRequestsStatus: UpgradeRequestsStatus.loading));

    final result = await _repository.getUpgradeRequests();

    result.fold(
      (error) {
        log('Error loading upgrade requests: ${error.errorMessage?.message}');
        emit(
          state.copyWith(
            upgradeRequestsStatus: UpgradeRequestsStatus.error,
            errorMessage:
                error.errorMessage?.message ?? 'Failed to load upgrade requests',
          ),
        );
      },
      (data) {
        log('Upgrade requests loaded: ${data.requests.length} requests');
        emit(
          state.copyWith(
            upgradeRequestsStatus: UpgradeRequestsStatus.success,
            upgradeRequests: data.requests,
            upgradeStatistics: data.statistics,
          ),
        );
      },
    );
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  /// Load current subscription
  Future<void> loadCurrentSubscription() async {
    emit(state.copyWith(
      currentSubscriptionStatus: CurrentSubscriptionStatus.loading,
    ));

    final result = await _repository.getCurrentSubscription();

    result.fold(
      (error) {
        log('Error loading current subscription: ${error.errorMessage?.message}');
        emit(
          state.copyWith(
            currentSubscriptionStatus: CurrentSubscriptionStatus.error,
            errorMessage:
                error.errorMessage?.message ?? 'Failed to load subscription',
          ),
        );
      },
      (subscription) {
        log('Current subscription loaded: ${subscription?.subscriptionPlanName}');
        emit(
          state.copyWith(
            currentSubscriptionStatus: CurrentSubscriptionStatus.success,
            currentSubscription: subscription,
          ),
        );
      },
    );
  }

  /// Cancel upgrade request
  Future<void> cancelUpgradeRequest({
    required String upgradeRequestId,
    required String reason,
  }) async {
    emit(state.copyWith(cancelUpgradeStatus: CancelUpgradeStatus.cancelling));

    final result = await _repository.cancelUpgradeRequest(
      upgradeRequestId: upgradeRequestId,
      reason: reason,
    );

    result.fold(
      (error) {
        log('Error cancelling upgrade: ${error.errorMessage?.message}');
        emit(
          state.copyWith(
            cancelUpgradeStatus: CancelUpgradeStatus.error,
            errorMessage:
                error.errorMessage?.message ?? 'Failed to cancel upgrade',
          ),
        );
      },
      (response) {
        log('Upgrade cancelled: ${response.message}');
        emit(state.copyWith(cancelUpgradeStatus: CancelUpgradeStatus.success));
        // Reload upgrade requests after cancellation
        loadUpgradeRequests();
      },
    );
  }

  /// Reset cancel upgrade status
  void resetCancelUpgradeStatus() {
    emit(state.copyWith(
      cancelUpgradeStatus: CancelUpgradeStatus.idle,
      errorMessage: null,
    ));
  }

  /// Cancel current subscription using the dedicated cancel endpoint
  Future<void> cancelCurrentSubscription({
    required String reason,
    bool immediate = true,
    bool requestRefund = false,
    String feedback = '',
  }) async {
    final currentSub = state.currentSubscription;
    if (currentSub == null) {
      log('No current subscription to cancel');
      emit(state.copyWith(
        cancelUpgradeStatus: CancelUpgradeStatus.error,
        errorMessage: 'No active subscription to cancel',
      ));
      return;
    }

    emit(state.copyWith(cancelUpgradeStatus: CancelUpgradeStatus.cancelling));

    final result = await _repository.cancelSubscription(
      reason: reason,
      immediate: immediate,
      requestRefund: requestRefund,
      feedback: feedback,
    );

    result.fold(
      (error) {
        log('Error cancelling subscription: ${error.errorMessage?.message}');
        emit(state.copyWith(
          cancelUpgradeStatus: CancelUpgradeStatus.error,
          errorMessage:
              error.errorMessage?.message ?? 'Failed to cancel subscription',
        ));
      },
      (response) {
        log('Subscription cancelled: ${response.message}');
        emit(state.copyWith(cancelUpgradeStatus: CancelUpgradeStatus.success));
        // Reload current subscription and upgrade requests
        loadCurrentSubscription();
        loadUpgradeRequests();
      },
    );
  }

  /// Check upgrade request status
  Future<void> checkUpgradeStatus(String upgradeRequestId) async {
    emit(state.copyWith(
      upgradeStatusCheckStatus: UpgradeStatusCheckStatus.loading,
    ));

    final result = await _repository.checkUpgradeStatus(upgradeRequestId);

    result.fold(
      (error) {
        log('Error checking upgrade status: ${error.errorMessage?.message}');
        emit(
          state.copyWith(
            upgradeStatusCheckStatus: UpgradeStatusCheckStatus.error,
            errorMessage:
                error.errorMessage?.message ?? 'Failed to check status',
          ),
        );
      },
      (status) {
        log('Upgrade status: ${status.statusName}');
        emit(
          state.copyWith(
            upgradeStatusCheckStatus: UpgradeStatusCheckStatus.success,
            upgradeStatus: status,
          ),
        );
      },
    );
  }

  /// Use a resource (count-based like AI messages)
  Future<void> useResourceCount({
    required String resourceKey,
    required int count,
    String? details,
  }) async {
    emit(state.copyWith(resourceUsageStatus: ResourceUsageStatus.loading));

    final result = await _repository.useResource(
      resourceKey: resourceKey,
      count: count,
      details: details,
    );

    result.fold(
      (error) {
        log('Error using resource: ${error.errorMessage?.message}');
        emit(
          state.copyWith(
            resourceUsageStatus: ResourceUsageStatus.error,
            errorMessage:
                error.errorMessage?.message ?? 'Failed to use resource',
          ),
        );
      },
      (response) {
        log('Resource used: ${response.remaining} remaining');
        emit(state.copyWith(resourceUsageStatus: ResourceUsageStatus.success));
      },
    );
  }

  /// Use a resource (size-based like storage)
  Future<void> useResourceSize({
    required String resourceKey,
    required double sizeInMB,
    String? details,
  }) async {
    emit(state.copyWith(resourceUsageStatus: ResourceUsageStatus.loading));

    final result = await _repository.useResource(
      resourceKey: resourceKey,
      sizeInMB: sizeInMB,
      details: details,
    );

    result.fold(
      (error) {
        log('Error using resource: ${error.errorMessage?.message}');
        emit(
          state.copyWith(
            resourceUsageStatus: ResourceUsageStatus.error,
            errorMessage:
                error.errorMessage?.message ?? 'Failed to use resource',
          ),
        );
      },
      (response) {
        log('Resource used: ${response.currentSize} MB used');
        emit(state.copyWith(resourceUsageStatus: ResourceUsageStatus.success));
      },
    );
  }

  /// Get resource usage by key
  Future<void> getResourceUsage(String resourceKey) async {
    emit(state.copyWith(resourceUsageStatus: ResourceUsageStatus.loading));

    final result = await _repository.getResourceUsage(resourceKey);

    result.fold(
      (error) {
        log('Error getting resource usage: ${error.errorMessage?.message}');
        emit(
          state.copyWith(
            resourceUsageStatus: ResourceUsageStatus.error,
            errorMessage:
                error.errorMessage?.message ?? 'Failed to get resource usage',
          ),
        );
      },
      (usage) {
        log('Resource usage: ${usage.usagePercentage}%');
        final updatedUsages = Map<String, ResourceUsageModel>.from(
          state.resourceUsages,
        );
        updatedUsages[resourceKey] = usage;
        emit(
          state.copyWith(
            resourceUsageStatus: ResourceUsageStatus.success,
            resourceUsages: updatedUsages,
          ),
        );
      },
    );
  }
}
