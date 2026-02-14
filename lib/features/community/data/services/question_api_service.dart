import 'dart:developer' as dev;
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_service.dart';
import '../../../../core/api/dio_factory.dart';
import '../models/question.dart';
import '../models/subject.dart';

class QuestionApiService {
  static final QuestionApiService _instance = QuestionApiService._internal();
  factory QuestionApiService() => _instance;
  QuestionApiService._internal();

  late final ApiService _apiService = ApiService(DioFactory.getDio());

  /// Get all questions with pagination, search, and filtering
  Future<QuestionListResponse> getQuestions({
    int page = 1,
    int pageSize = 20,
    String? search,
    bool? active,
    String? subjectId,
  }) async {
    try {
      final response = await _apiService.getQuestions(
        page: page,
        pageSize: pageSize,
        search: search,
        active: active,
        subjectId: subjectId,
      );

      dev.log(
        'Get questions response: ${response.data.length} questions (page $page/${response.totalPages})',
        name: 'QuestionAPI',
      );

      return response;
    } catch (e) {
      dev.log('Error getting questions: $e', name: 'QuestionAPI', error: e);
      rethrow;
    }
  }

  /// Get a single question by ID
  Future<QuestionResponse> getQuestionById(String id) async {
    try {
      final response = await _apiService.getQuestionById(id);

      dev.log('Get question by ID response: $response', name: 'QuestionAPI');

      return response;
    } catch (e) {
      dev.log('Error getting question by ID: $e', name: 'QuestionAPI', error: e);
      rethrow;
    }
  }

  /// Create a new question
  Future<QuestionResponse> createQuestion({
    required String subjectId,
    required String creatorId,
    required String title,
    required String description,
    File? imageFile,
  }) async {
    try {
      // Create FormData for multipart request
      final dio = DioFactory.getDio();
      final formData = FormData.fromMap({
        'SubjectId': subjectId,
        'CreatorId': creatorId,
        'Title': title,
        'Description': description,
        if (imageFile != null)
          'ImageFile': await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split(Platform.pathSeparator).last,
          ),
      });

      final response = await dio.post(
        ApiConstants.questions,
        data: formData,
      );

      dev.log('Create question response: ${response.data}', name: 'QuestionAPI');

      return QuestionResponse.fromJson(response.data);
    } catch (e) {
      dev.log('Error creating question: $e', name: 'QuestionAPI', error: e);
      rethrow;
    }
  }

  /// Delete a question
  Future<bool> deleteQuestion(String id) async {
    try {
      final response = await _apiService.deleteQuestion(id);

      dev.log('Delete question response: $response', name: 'QuestionAPI');

      return response.success ?? false;
    } catch (e) {
      dev.log('Error deleting question: $e', name: 'QuestionAPI', error: e);
      rethrow;
    }
  }

  /// Get question members
  Future<QuestionMembersResponse> getQuestionMembers(String questionId) async {
    try {
      final response = await _apiService.getQuestionMembers(questionId);

      dev.log('Get question members response: $response', name: 'QuestionAPI');

      return response;
    } catch (e) {
      dev.log('Error getting question members: $e', name: 'QuestionAPI', error: e);
      rethrow;
    }
  }

  /// Get messages for a question
  Future<QuestionMessagesResponse> getQuestionMessages(String questionId) async {
    try {
      final response = await _apiService.getQuestionMessages(questionId);

      dev.log('Get question messages response: ${response.data.length} messages',
          name: 'QuestionAPI');

      return response;
    } catch (e) {
      dev.log('Error getting question messages: $e', name: 'QuestionAPI', error: e);
      rethrow;
    }
  }

  /// Get all subjects with pagination
  Future<SubjectsResponse> getSubjects({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiService.getSubjects(
        page: page,
        pageSize: pageSize,
      );

      dev.log('Get subjects response: ${response.data.length} subjects',
          name: 'QuestionAPI');

      return response;
    } catch (e) {
      dev.log('Error getting subjects: $e', name: 'QuestionAPI', error: e);
      rethrow;
    }
  }

  /// Close or leave a question
  Future<bool> closeQuestion(String id) async {
    try {
      final response = await _apiService.closeQuestion(id);

      dev.log('Close question response: ${response.success}', name: 'QuestionAPI');

      return response.success ?? false;
    } catch (e) {
      dev.log('Error closing question: $e', name: 'QuestionAPI', error: e);
      rethrow;
    }
  }

  /// Update a question (manual Dio implementation for FormData)
  Future<QuestionResponse> updateQuestion({
    required String id,
    String? title,
    String? description,
    String? subjectId,
    File? newImageFile,
    File? newAttachmentFile,
    bool removeImage = false,
    bool removeAttachment = false,
  }) async {
    try {
      final dio = DioFactory.getDio();
      final formData = FormData.fromMap({
        if (title != null) 'Title': title,
        if (description != null) 'Description': description,
        if (subjectId != null) 'SubjectId': subjectId,
        if (newImageFile != null)
          'NewImageFile': await MultipartFile.fromFile(
            newImageFile.path,
            filename: newImageFile.path.split(Platform.pathSeparator).last,
          ),
        if (newAttachmentFile != null)
          'NewAttachmentFile': await MultipartFile.fromFile(
            newAttachmentFile.path,
            filename: newAttachmentFile.path.split(Platform.pathSeparator).last,
          ),
        'RemoveImage': removeImage,
        'RemoveAttachment': removeAttachment,
      });

      final response = await dio.put(
        '${ApiConstants.questions}/$id',
        data: formData,
      );

      dev.log('Update question response: ${response.data}', name: 'QuestionAPI');

      return QuestionResponse.fromJson(response.data);
    } catch (e) {
      dev.log('Error updating question: $e', name: 'QuestionAPI', error: e);
      rethrow;
    }
  }
}
