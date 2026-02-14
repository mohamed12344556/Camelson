import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import '../../../../core/services/signalr_service.dart';
import '../models/question.dart';
import '../models/subject.dart';
import 'question_api_service.dart';

/// Service that integrates Question API with SignalR real-time updates
class QuestionService {
  static final QuestionService _instance = QuestionService._internal();
  factory QuestionService() => _instance;
  QuestionService._internal();

  final QuestionApiService _apiService = QuestionApiService();
  final SignalRService _signalR = SignalRService();

  // Stream controllers for real-time updates
  final _questionAddedController = StreamController<Question>.broadcast();
  final _questionUpdatedController = StreamController<Question>.broadcast();
  final _questionDeletedController = StreamController<String>.broadcast();

  // Public streams
  Stream<Question> get onQuestionAdded => _questionAddedController.stream;
  Stream<Question> get onQuestionUpdated => _questionUpdatedController.stream;
  Stream<String> get onQuestionDeleted => _questionDeletedController.stream;

  bool _isInitialized = false;

  /// Initialize SignalR connection and setup question event handlers
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Connect to SignalR
      await _signalR.connect();

      // Setup question-specific event handlers
      _setupQuestionEventHandlers();

      _isInitialized = true;
      dev.log('QuestionService initialized successfully', name: 'QuestionService');
    } catch (e) {
      dev.log('Error initializing QuestionService: $e', name: 'QuestionService', error: e);
      rethrow;
    }
  }

  /// Setup SignalR event handlers for question events
  void _setupQuestionEventHandlers() {
    _signalR.onMessageReceived.listen((data) {
      try {
        if (data is Map<String, dynamic>) {
          final type = data['type'];

          switch (type) {
            case 'QuestionAdded':
              _handleQuestionAdded(data['data']);
              break;
            case 'QuestionUpdated':
              _handleQuestionUpdated(data['data']);
              break;
            case 'QuestionDeleted':
              _handleQuestionDeleted(data['data']);
              break;
          }
        }
      } catch (e) {
        dev.log('Error handling question event: $e', name: 'QuestionService', error: e);
      }
    });
  }

  void _handleQuestionAdded(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        final question = Question.fromJson(data);
        _questionAddedController.add(question);
        dev.log('Question added: ${question.id}', name: 'QuestionService');
      }
    } catch (e) {
      dev.log('Error handling question added: $e', name: 'QuestionService', error: e);
    }
  }

  void _handleQuestionUpdated(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        final question = Question.fromJson(data);
        _questionUpdatedController.add(question);
        dev.log('Question updated: ${question.id}', name: 'QuestionService');
      }
    } catch (e) {
      dev.log('Error handling question updated: $e', name: 'QuestionService', error: e);
    }
  }

  void _handleQuestionDeleted(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        final questionId = data['questionId'] as String;
        _questionDeletedController.add(questionId);
        dev.log('Question deleted: $questionId', name: 'QuestionService');
      } else if (data is String) {
        _questionDeletedController.add(data);
        dev.log('Question deleted: $data', name: 'QuestionService');
      }
    } catch (e) {
      dev.log('Error handling question deleted: $e', name: 'QuestionService', error: e);
    }
  }

  // ==================== API Methods ====================

  /// Get all questions with pagination, search, and filtering
  Future<QuestionListResponse> getQuestionsWithPagination({
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

      return response;
    } catch (e) {
      dev.log('Error getting questions: $e', name: 'QuestionService', error: e);
      rethrow;
    }
  }

  /// Get all questions with pagination (simple version - returns list only)
  Future<List<Question>> getQuestions({
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

      return response.data;
    } catch (e) {
      dev.log('Error getting questions: $e', name: 'QuestionService', error: e);
      rethrow;
    }
  }

  /// Get a single question by ID
  Future<Question> getQuestionById(String id) async {
    try {
      final response = await _apiService.getQuestionById(id);
      return response.data;
    } catch (e) {
      dev.log('Error getting question by ID: $e', name: 'QuestionService', error: e);
      rethrow;
    }
  }

  /// Create a new question (also notifies via SignalR)
  Future<Question> createQuestion({
    required String subjectId,
    required String creatorId,
    required String title,
    required String description,
    File? imageFile,
  }) async {
    try {
      final response = await _apiService.createQuestion(
        subjectId: subjectId,
        creatorId: creatorId,
        title: title,
        description: description,
        imageFile: imageFile,
      );

      // The backend should notify all connected clients via SignalR
      // So we don't need to manually emit here

      return response.data;
    } catch (e) {
      dev.log('Error creating question: $e', name: 'QuestionService', error: e);
      rethrow;
    }
  }

  /// Delete a question (also notifies via SignalR)
  Future<bool> deleteQuestion(String id) async {
    try {
      final success = await _apiService.deleteQuestion(id);

      // The backend should notify all connected clients via SignalR
      // So we don't need to manually emit here

      return success;
    } catch (e) {
      dev.log('Error deleting question: $e', name: 'QuestionService', error: e);
      rethrow;
    }
  }

  /// Get question members
  Future<List<QuestionMember>> getQuestionMembers(String questionId) async {
    try {
      final response = await _apiService.getQuestionMembers(questionId);
      return response.data;
    } catch (e) {
      dev.log('Error getting question members: $e', name: 'QuestionService', error: e);
      rethrow;
    }
  }

  /// Get all subjects
  Future<List<Subject>> getSubjects({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiService.getSubjects(
        page: page,
        pageSize: pageSize,
      );
      return response.data;
    } catch (e) {
      dev.log('Error getting subjects: $e', name: 'QuestionService', error: e);
      rethrow;
    }
  }

  /// Close/Leave a question
  Future<bool> closeQuestion(String id) async {
    try {
      final success = await _apiService.closeQuestion(id);
      return success;
    } catch (e) {
      dev.log('Error closing question: $e', name: 'QuestionService', error: e);
      rethrow;
    }
  }

  /// Update a question
  Future<Question> updateQuestion({
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
      final response = await _apiService.updateQuestion(
        id: id,
        title: title,
        description: description,
        subjectId: subjectId,
        newImageFile: newImageFile,
        newAttachmentFile: newAttachmentFile,
        removeImage: removeImage,
        removeAttachment: removeAttachment,
      );

      return response.data;
    } catch (e) {
      dev.log('Error updating question: $e', name: 'QuestionService', error: e);
      rethrow;
    }
  }

  // ==================== SignalR Methods ====================

  /// Join a question room (for real-time updates)
  Future<void> joinQuestionRoom(String questionId) async {
    try {
      await _signalR.joinQuestion(questionId);
      dev.log('Joined question room: $questionId', name: 'QuestionService');
    } catch (e) {
      dev.log('Error joining question room: $e', name: 'QuestionService', error: e);
      rethrow;
    }
  }

  /// Leave a question room
  Future<void> leaveQuestionRoom(String questionId) async {
    try {
      await _signalR.leaveQuestion(questionId);
      dev.log('Left question room: $questionId', name: 'QuestionService');
    } catch (e) {
      dev.log('Error leaving question room: $e', name: 'QuestionService', error: e);
      rethrow;
    }
  }

  /// Check if SignalR is connected
  bool get isConnected => _signalR.isConnected;

  /// Disconnect from SignalR
  Future<void> disconnect() async {
    await _signalR.disconnect();
    _isInitialized = false;
  }

  /// Dispose resources
  void dispose() {
    _questionAddedController.close();
    _questionUpdatedController.close();
    _questionDeletedController.close();
    _signalR.dispose();
  }
}
