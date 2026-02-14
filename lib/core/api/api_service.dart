import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../features/auth/data/models/auth_request.dart';
import '../../features/auth/data/models/auth_response.dart';
import '../../features/community/data/models/question.dart';
import '../../features/community/data/models/subject.dart';
import '../../features/profile/data/models/cancel_upgrade_model.dart';
import '../../features/profile/data/models/current_subscription_model.dart';
import '../../features/profile/data/models/plan_model.dart';
import '../../features/profile/data/models/resource_usage_model.dart';
import '../../features/profile/data/models/subscription_response_model.dart';
import '../../features/profile/data/models/upgrade_request_model.dart';
import '../../features/profile/data/models/upgrade_status_model.dart';
import 'api_constants.dart';

part 'api_service.g.dart';

@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio) = _ApiService;

  // Auth Endpoints
  @POST(ApiConstants.login)
  Future<AuthResponse> login(@Body() AuthRequest request);

  @POST(ApiConstants.signup)
  Future<AuthResponse> signup(@Body() AuthRequest request);

  @POST(ApiConstants.refreshToken)
  Future<AuthResponse> refreshToken(@Body() AuthRequest request);

  @POST(ApiConstants.forgotPassword)
  Future<SimpleResponse> forgotPassword(@Body() AuthRequest request);

  @POST(ApiConstants.verifyOtp)
  Future<SimpleResponse> verifyOtp(@Body() AuthRequest request);

  @POST(ApiConstants.resetPassword)
  Future<SimpleResponse> resetPassword(@Body() AuthRequest request);

  @POST(ApiConstants.changePassword)
  Future<SimpleResponse> changePassword(@Body() AuthRequest request);

  @POST(ApiConstants.logout)
  Future<SimpleResponse> logout();

  // Profile Endpoints
  @GET(ApiConstants.getUserProfile)
  Future<ProfileResponse> getUserProfile();

  // Student Profile Endpoints
  @GET(ApiConstants.getStudentProfile)
  Future<StudentProfileResponse> getStudentProfile();

  @PUT(ApiConstants.updateStudentProfile)
  Future<StudentProfileResponse> updateStudentProfile(
    @Body() UpdateStudentProfileRequest request,
  );

  // TODO: Fix MultipartFile issue with retrofit
  // @POST(ApiConstants.updateProfileImage)
  // @MultiPart()
  // Future<SimpleResponse> updateProfileImage(@Part() MultipartFile file);

  // Academic Endpoints
  @GET(ApiConstants.getAcademicStages)
  Future<AcademicStagesResponse> getAcademicStages();

  @GET(ApiConstants.getAcademicYears)
  Future<AcademicYearsResponse> getAcademicYears();

  @GET(ApiConstants.getAcademicSections)
  Future<AcademicSectionsResponse> getAcademicSections();

  // Community/Questions Endpoints

  /// GET Questions with search, filter, and pagination
  /// - page: Page number (default 1)
  /// - pageSize: Number of items per page (default 20)
  /// - search: Search keyword in title/description
  /// - active: Filter by status (false=all, true=active only)
  @GET(ApiConstants.questions)
  Future<QuestionListResponse> getQuestions({
    @Query('page') int? page,
    @Query('pageSize') int? pageSize,
    @Query('search') String? search,
    @Query('active') bool? active,
    @Query('subjectId') String? subjectId,
  });

  /// GET Single question by ID
  @GET('${ApiConstants.questions}/{id}')
  Future<QuestionResponse> getQuestionById(@Path('id') String id);

  /// POST Create new question
  /// Note: Use manual FormData for file upload due to retrofit multipart issues
  @POST(ApiConstants.questions)
  Future<QuestionResponse> createQuestion(@Body() Map<String, dynamic> body);

  /// DELETE Question by ID
  @DELETE('${ApiConstants.questions}/{id}')
  Future<SimpleResponse> deleteQuestion(@Path('id') String id);

  /// GET All members of a question with their status
  @GET('${ApiConstants.questions}/{id}/all-members')
  Future<QuestionMembersResponse> getQuestionMembers(@Path('id') String id);

  /// GET All messages in a question
  @GET('${ApiConstants.questions}/{id}/messages/all')
  Future<QuestionMessagesResponse> getQuestionMessages(@Path('id') String id);

  /// GET All subjects with pagination
  @GET(ApiConstants.subjects)
  Future<SubjectsResponse> getSubjects({
    @Query('page') int? page,
    @Query('pageSize') int? pageSize,
  });

  /// POST Close/Leave a question
  @POST('${ApiConstants.questions}/{id}/close')
  Future<SimpleResponse> closeQuestion(@Path('id') String id);

  // NOTE: PUT Edit Question and POST Add Member commented out due to retrofit multipart issues
  // Use manual Dio implementation with FormData instead

  // Subscription Plans Endpoints

  /// GET all subscription plans for students
  @GET('/api/SubscriptionPlans/student')
  Future<List<PlanModel>> getStudentPlans();

  /// GET plan details by ID
  @GET('/api/SubscriptionPlans/{planId}')
  Future<PlanModel> getPlanById(@Path('planId') int planId);

  /// POST request subscription or upgrade
  /// Returns wrapped response with success, message, data, errors
  @POST('/api/Subscription/request-upgrade')
  Future<SubscriptionApiResponse> requestSubscription(
    @Body() Map<String, dynamic> request,
  );

  /// GET current user's upgrade requests
  @GET('/api/subscription/upgrade-requests')
  Future<UpgradeRequestsResponse> getUpgradeRequests();

  /// GET current subscription
  @GET('/api/subscription/current')
  Future<CurrentSubscriptionResponse> getCurrentSubscription();

  /// POST cancel upgrade request
  @POST('/api/subscription/cancel-upgrade')
  Future<CancelUpgradeResponse> cancelUpgradeRequest(
    @Body() CancelUpgradeRequest request,
  );

  /// POST cancel current subscription
  @POST(ApiConstants.cancelSubscription)
  Future<CancelSubscriptionResponse> cancelSubscription(
    @Body() CancelSubscriptionRequest request,
  );

  /// GET check upgrade request status
  @GET('/api/subscription/check-upgrade-status/{upgradeRequestId}')
  Future<UpgradeStatusResponse> checkUpgradeStatus(
    @Path('upgradeRequestId') String upgradeRequestId,
  );

  // Resource Usage Endpoints

  /// POST use a resource
  @POST('/api/Resourceusage/use/{resourceKey}')
  Future<UseResourceResponse> useResource(
    @Path('resourceKey') String resourceKey,
    @Body() UseResourceRequest request,
  );

  /// GET resource usage by key
  @GET('/api/Resourceusage/{resourceKey}')
  Future<ResourceUsageModel> getResourceUsage(
    @Path('resourceKey') String resourceKey,
  );
}

//! flutter pub run build_runner build --delete-conflicting-outputs
