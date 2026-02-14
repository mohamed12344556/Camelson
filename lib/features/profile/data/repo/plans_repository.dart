import 'package:dartz/dartz.dart';

import '../../../../core/core.dart';
import '../models/cancel_upgrade_model.dart';
import '../models/current_subscription_model.dart';
import '../models/plan_model.dart';
import '../models/resource_usage_model.dart';
import '../models/subscription_request_model.dart';
import '../models/subscription_response_model.dart';
import '../models/upgrade_request_model.dart';
import '../models/upgrade_status_model.dart';

class PlansRepository {
  final ApiService _apiService;

  PlansRepository(this._apiService);

  /// Get all student plans
  Future<Either<ApiErrorModel, List<PlanModel>>> getStudentPlans() async {
    try {
      final response = await _apiService.getStudentPlans();
      return Right(response);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  /// Get plan details by ID
  Future<Either<ApiErrorModel, PlanModel>> getPlanById(int planId) async {
    try {
      final response = await _apiService.getPlanById(planId);
      return Right(response);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  /// Request subscription or upgrade
  Future<Either<ApiErrorModel, SubscriptionResponseModel>> requestSubscription(
    SubscriptionRequestModel request,
  ) async {
    try {
      final response = await _apiService.requestSubscription(request.toJson());
      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        return Left(
          ApiErrorModel(
            errorMessage: ErrorData(
              message: response.message ?? 'Subscription request failed',
            ),
          ),
        );
      }
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  /// Get current user's upgrade requests
  Future<Either<ApiErrorModel, UpgradeRequestsData>> getUpgradeRequests() async {
    try {
      final response = await _apiService.getUpgradeRequests();
      if (response.success) {
        return Right(response.data);
      } else {
        return Left(
          ApiErrorModel(
            errorMessage: ErrorData(message: 'Failed to load upgrade requests'),
          ),
        );
      }
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  /// Get current subscription
  Future<Either<ApiErrorModel, CurrentSubscriptionModel?>> getCurrentSubscription() async {
    try {
      final response = await _apiService.getCurrentSubscription();
      if (response.success) {
        return Right(response.data);
      } else {
        return Left(
          ApiErrorModel(
            errorMessage: ErrorData(message: 'Failed to load current subscription'),
          ),
        );
      }
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  /// Cancel upgrade request
  Future<Either<ApiErrorModel, CancelUpgradeResponse>> cancelUpgradeRequest({
    required String upgradeRequestId,
    required String reason,
  }) async {
    try {
      final request = CancelUpgradeRequest(
        upgradeRequestId: upgradeRequestId,
        reason: reason,
      );
      final response = await _apiService.cancelUpgradeRequest(request);
      if (response.success) {
        return Right(response);
      } else {
        return Left(
          ApiErrorModel(
            errorMessage: ErrorData(
              message: response.message ?? 'Failed to cancel upgrade request',
            ),
          ),
        );
      }
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  /// Cancel current subscription
  Future<Either<ApiErrorModel, CancelSubscriptionResponse>> cancelSubscription({
    required String reason,
    bool immediate = true,
    bool requestRefund = false,
    String feedback = '',
  }) async {
    try {
      final request = CancelSubscriptionRequest(
        reason: reason,
        immediate: immediate,
        requestRefund: requestRefund,
        feedback: feedback,
      );
      final response = await _apiService.cancelSubscription(request);
      if (response.success) {
        return Right(response);
      } else {
        return Left(
          ApiErrorModel(
            errorMessage: ErrorData(
              message: response.message ?? 'Failed to cancel subscription',
            ),
          ),
        );
      }
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  /// Check upgrade request status
  Future<Either<ApiErrorModel, UpgradeStatusModel>> checkUpgradeStatus(
    String upgradeRequestId,
  ) async {
    try {
      final response = await _apiService.checkUpgradeStatus(upgradeRequestId);
      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        return Left(
          ApiErrorModel(
            errorMessage: ErrorData(message: 'Failed to check upgrade status'),
          ),
        );
      }
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  /// Use a resource
  Future<Either<ApiErrorModel, UseResourceResponse>> useResource({
    required String resourceKey,
    int? count,
    double? sizeInMB,
    int? durationInMinutes,
    String? details,
  }) async {
    try {
      final request = UseResourceRequest(
        count: count,
        sizeInMB: sizeInMB,
        durationInMinutes: durationInMinutes,
        details: details,
      );
      final response = await _apiService.useResource(resourceKey, request);
      if (response.success) {
        return Right(response);
      } else {
        return Left(
          ApiErrorModel(
            errorMessage: ErrorData(
              message: response.message ?? 'Failed to use resource',
            ),
          ),
        );
      }
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  /// Get resource usage by key
  Future<Either<ApiErrorModel, ResourceUsageModel>> getResourceUsage(
    String resourceKey,
  ) async {
    try {
      final response = await _apiService.getResourceUsage(resourceKey);
      return Right(response);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }
}
