import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/community_constants.dart';
import '../../../data/models/question.dart';
import '../../../data/models/room.dart';
import '../../../data/repos/chat_repo.dart';
import '../../../data/services/question_service.dart';
import 'community_event.dart';
import 'community_state.dart';

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  final ChatRepository _repository;
  final QuestionService _questionService;
  StreamSubscription? _questionAddedSubscription;
  StreamSubscription? _questionUpdatedSubscription;
  StreamSubscription? _questionDeletedSubscription;

  CommunityBloc({
    required ChatRepository repository,
    required QuestionService questionService,
  }) : _repository = repository,
       _questionService = questionService,
       super(CommunityState.initial()) {
    on<CommunityLoadRequested>(_onLoadRequested);
    on<CommunitySearchRequested>(_onSearchRequested);
    on<CommunitySearchQueryChanged>(_onSearchQueryChanged);
    on<CommunityQuestionSubmitted>(_onQuestionSubmitted);
    on<CommunityPolicyAccepted>(_onPolicyAccepted);
    on<CommunityRefreshRequested>(_onRefreshRequested);
    on<CommunityQuestionAdded>(_onQuestionAdded);
    on<CommunityQuestionUpdated>(_onQuestionUpdated);
    on<CommunityQuestionDeleted>(_onQuestionDeleted);
    on<CommunityFilterChanged>(_onFilterChanged);
    on<CommunityLoadMoreRequested>(_onLoadMoreRequested);
    on<CommunityRoomLeft>(_onRoomLeft);

    _initializeQuestionService();
  }

  /// Initialize QuestionService and setup real-time listeners
  Future<void> _initializeQuestionService() async {
    try {
      await _questionService.initialize();

      // Listen for question added events
      _questionAddedSubscription = _questionService.onQuestionAdded.listen((
        question,
      ) {
        add(CommunityQuestionAdded(question));
      });

      // Listen for question updated events
      _questionUpdatedSubscription = _questionService.onQuestionUpdated.listen((
        question,
      ) {
        add(CommunityQuestionUpdated(question));
      });

      // Listen for question deleted events
      _questionDeletedSubscription = _questionService.onQuestionDeleted.listen((
        questionId,
      ) {
        add(CommunityQuestionDeleted(questionId));
      });

      dev.log(
        'QuestionService initialized in CommunityBloc',
        name: 'CommunityBloc',
      );
    } catch (e) {
      dev.log(
        'Error initializing QuestionService: $e',
        name: 'CommunityBloc',
        error: e,
      );
    }
  }

  Future<void> _onLoadRequested(
    CommunityLoadRequested event,
    Emitter<CommunityState> emit,
  ) async {
    if (state.status == CommunityStatus.loaded && !event.forceRefresh) {
      return; // Already loaded, no need to reload
    }

    emit(state.copyWith(status: CommunityStatus.loading, currentPage: 1));

    try {
      // Initialize repository if needed
      await _repository.init();

      // Determine if we want active questions only or all
      final bool? activeFilter = state.filter == QuestionFilter.active ? true : null;

      // Load questions from API with pagination
      final response = await _questionService.getQuestionsWithPagination(
        page: 1,
        pageSize: state.pageSize,
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
        active: activeFilter,
      );

      // Convert questions to rooms (for compatibility with existing UI)
      final rooms = response.data.map((q) => _questionToRoom(q)).toList();

      final currentUser = CommunityConstants.currentUser;

      emit(
        state.copyWith(
          status: CommunityStatus.loaded,
          rooms: rooms,
          filteredRooms: rooms,
          questions: response.data,
          filteredQuestions: response.data,
          currentUser: currentUser,
          currentPage: response.page ?? 1,
          totalPages: response.totalPages,
          totalCount: response.totalCount,
          hasMorePages: response.hasMorePages,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CommunityStatus.error,
          errorMessage: 'فشل في تحميل البيانات: ${e.toString()}',
        ),
      );
    }
  }

  void _onSearchRequested(
    CommunitySearchRequested event,
    Emitter<CommunityState> emit,
  ) {
    if (state.status != CommunityStatus.loaded) return;

    List<Room> filteredRooms;
    List<Question> filteredQuestions;

    if (event.query.isEmpty) {
      filteredRooms = state.rooms;
      filteredQuestions = state.questions;
    } else {
      // Filter rooms based on search query
      filteredRooms = state.rooms
          .where(
            (room) =>
                room.name.contains(event.query) ||
                room.subject.contains(event.query) ||
                room.grade.contains(event.query),
          )
          .toList();

      // Filter questions based on search query
      filteredQuestions = state.questions
          .where(
            (q) =>
                q.title.contains(event.query) ||
                q.description.contains(event.query) ||
                q.subjectName.contains(event.query),
          )
          .toList();
    }

    emit(
      state.copyWith(
        filteredRooms: filteredRooms,
        filteredQuestions: filteredQuestions,
        searchQuery: event.query,
      ),
    );
  }

  void _onSearchQueryChanged(
    CommunitySearchQueryChanged event,
    Emitter<CommunityState> emit,
  ) {
    if (state.status != CommunityStatus.loaded) return;

    List<Room> filteredRooms;
    List<Question> filteredQuestions;

    if (event.query.isEmpty) {
      filteredRooms = state.rooms;
      filteredQuestions = state.questions;
    } else {
      // Filter rooms based on search query
      filteredRooms = state.rooms
          .where(
            (room) =>
                room.name.contains(event.query) ||
                room.subject.contains(event.query) ||
                room.grade.contains(event.query),
          )
          .toList();

      // Filter questions based on search query
      filteredQuestions = state.questions
          .where(
            (q) =>
                q.title.contains(event.query) ||
                q.description.contains(event.query) ||
                q.subjectName.contains(event.query),
          )
          .toList();
    }

    emit(
      state.copyWith(
        filteredRooms: filteredRooms,
        filteredQuestions: filteredQuestions,
        searchQuery: event.query,
      ),
    );
  }

  Future<void> _onQuestionSubmitted(
    CommunityQuestionSubmitted event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      // Get current user ID (in production, get from auth state)
      final creatorId =
          state.currentUser?.id ?? CommunityConstants.currentUser.id;

      // Find subject ID from subject name (you need to implement this mapping)
      final subjectId = _getSubjectIdFromName(event.question.subject);

      // Create question via API
      final newQuestion = await _questionService.createQuestion(
        subjectId: subjectId,
        creatorId: creatorId,
        title: '${event.question.subject} - ${event.question.grade}',
        description: event.question.content,
      );

      // The question will be added to the list via SignalR event
      // But we can optimistically update the UI
      final updatedQuestions = [newQuestion, ...state.questions];
      final updatedRooms = updatedQuestions
          .map((q) => _questionToRoom(q))
          .toList();

      // Filter if needed
      List<Room> filteredRooms;
      List<Question> filteredQuestions;

      if (state.searchQuery.isEmpty) {
        filteredRooms = updatedRooms;
        filteredQuestions = updatedQuestions;
      } else {
        filteredRooms = updatedRooms
            .where(
              (r) =>
                  r.name.contains(state.searchQuery) ||
                  r.subject.contains(state.searchQuery) ||
                  r.grade.contains(state.searchQuery),
            )
            .toList();

        filteredQuestions = updatedQuestions
            .where(
              (q) =>
                  q.title.contains(state.searchQuery) ||
                  q.description.contains(state.searchQuery) ||
                  q.subjectName.contains(state.searchQuery),
            )
            .toList();
      }

      emit(
        state.copyWith(
          rooms: updatedRooms,
          filteredRooms: filteredRooms,
          questions: updatedQuestions,
          filteredQuestions: filteredQuestions,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CommunityStatus.error,
          errorMessage: 'فشل في إرسال السؤال: ${e.toString()}',
        ),
      );
    }
  }

  void _onPolicyAccepted(
    CommunityPolicyAccepted event,
    Emitter<CommunityState> emit,
  ) {
    try {
      // Update user policy acceptance
      // In production, this would make an API call

      // Update current user in state
      final updatedUser = state.currentUser?.copyWith(hasAgreedToPolicy: true);

      emit(state.copyWith(currentUser: updatedUser));
    } catch (e) {
      emit(
        state.copyWith(
          status: CommunityStatus.error,
          errorMessage: 'فشل في قبول الشروط: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onRefreshRequested(
    CommunityRefreshRequested event,
    Emitter<CommunityState> emit,
  ) async {
    // Trigger a fresh load
    add(CommunityLoadRequested(forceRefresh: true));
  }

  // Real-time event handlers
  void _onQuestionAdded(
    CommunityQuestionAdded event,
    Emitter<CommunityState> emit,
  ) {
    // Cast event.question to Question type
    if (event.question is! Question) return;

    final question = event.question as Question;

    // Check if question already exists
    final exists = state.questions.any((q) => q.id == question.id);
    if (exists) return;

    final updatedQuestions = <Question>[question, ...state.questions];
    final updatedRooms = updatedQuestions
        .map((q) => _questionToRoom(q))
        .toList();

    // Apply search filter if needed
    final List<Question> filteredQuestions;
    final List<Room> filteredRooms;

    if (state.searchQuery.isEmpty) {
      filteredQuestions = updatedQuestions;
      filteredRooms = updatedRooms;
    } else {
      filteredQuestions = updatedQuestions
          .where(
            (q) =>
                q.title.contains(state.searchQuery) ||
                q.description.contains(state.searchQuery) ||
                q.subjectName.contains(state.searchQuery),
          )
          .toList();

      filteredRooms = updatedRooms
          .where(
            (r) =>
                r.name.contains(state.searchQuery) ||
                r.subject.contains(state.searchQuery),
          )
          .toList();
    }

    emit(
      state.copyWith(
        questions: updatedQuestions,
        filteredQuestions: filteredQuestions,
        rooms: updatedRooms,
        filteredRooms: filteredRooms,
      ),
    );
  }

  void _onQuestionUpdated(
    CommunityQuestionUpdated event,
    Emitter<CommunityState> emit,
  ) {
    // Cast event.question to Question type
    if (event.question is! Question) return;

    final question = event.question as Question;

    final updatedQuestions = state.questions.map((q) {
      return q.id == question.id ? question : q;
    }).toList();

    final updatedRooms = updatedQuestions
        .map((q) => _questionToRoom(q))
        .toList();

    emit(state.copyWith(questions: updatedQuestions, rooms: updatedRooms));

    // Re-apply search filter
    add(CommunitySearchRequested(state.searchQuery));
  }

  void _onQuestionDeleted(
    CommunityQuestionDeleted event,
    Emitter<CommunityState> emit,
  ) {
    final updatedQuestions = state.questions
        .where((q) => q.id != event.questionId)
        .toList();
    final updatedRooms = updatedQuestions
        .map((q) => _questionToRoom(q))
        .toList();

    emit(state.copyWith(questions: updatedQuestions, rooms: updatedRooms));

    // Re-apply search filter
    add(CommunitySearchRequested(state.searchQuery));
  }

  // Helper methods
  Room _questionToRoom(Question question) {
    return Room(
      id: question.id,
      name: question.title,
      subject: question.subjectName,
      grade: '', // You might need to extract this from question data
      memberCount: question.memberCount,
      messageCount: question.messageCount,
      createdAt: question.createdAt,
      lastMessage: question.description,
      lastMessageTime: question.updatedAt ?? question.createdAt,
      unreadCount: 0,
    );
  }

  String _getSubjectIdFromName(String subjectName) {
    // TODO: Implement proper mapping from subject name to ID
    // For now, return a default ID
    return '8e6a753c-8d82-41cf-b1da-b2660d2c98f1'; // Art subject ID from Postman
  }

  // New Event Handlers
  Future<void> _onFilterChanged(
    CommunityFilterChanged event,
    Emitter<CommunityState> emit,
  ) async {
    if (state.filter == event.filter) return;

    emit(state.copyWith(
      filter: event.filter,
      status: CommunityStatus.loading,
      currentPage: 1,
    ));

    try {
      // Determine if we want active questions only or all
      final bool? activeFilter = event.filter == QuestionFilter.active ? true : null;

      // Load questions from API with new filter
      final response = await _questionService.getQuestionsWithPagination(
        page: 1,
        pageSize: state.pageSize,
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
        active: activeFilter,
      );

      // Convert questions to rooms
      final rooms = response.data.map((q) => _questionToRoom(q)).toList();

      emit(
        state.copyWith(
          status: CommunityStatus.loaded,
          rooms: rooms,
          filteredRooms: rooms,
          questions: response.data,
          filteredQuestions: response.data,
          currentPage: response.page ?? 1,
          totalPages: response.totalPages,
          totalCount: response.totalCount,
          hasMorePages: response.hasMorePages,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CommunityStatus.error,
          errorMessage: 'فشل في تطبيق الفلتر: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onLoadMoreRequested(
    CommunityLoadMoreRequested event,
    Emitter<CommunityState> emit,
  ) async {
    // Don't load more if already loading or no more pages
    if (state.status == CommunityStatus.loadingMore || !state.hasMorePages) {
      return;
    }

    emit(state.copyWith(status: CommunityStatus.loadingMore));

    try {
      final nextPage = state.currentPage + 1;

      // Determine if we want active questions only or all
      final bool? activeFilter = state.filter == QuestionFilter.active ? true : null;

      // Load next page
      final response = await _questionService.getQuestionsWithPagination(
        page: nextPage,
        pageSize: state.pageSize,
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
        active: activeFilter,
      );

      // Append new questions to existing list
      final updatedQuestions = [...state.questions, ...response.data];
      final updatedRooms = updatedQuestions.map((q) => _questionToRoom(q)).toList();

      // Apply search filter if needed
      List<Question> filteredQuestions;
      List<Room> filteredRooms;

      if (state.searchQuery.isEmpty) {
        filteredQuestions = updatedQuestions;
        filteredRooms = updatedRooms;
      } else {
        filteredQuestions = updatedQuestions
            .where(
              (q) =>
                  q.title.contains(state.searchQuery) ||
                  q.description.contains(state.searchQuery) ||
                  q.subjectName.contains(state.searchQuery),
            )
            .toList();

        filteredRooms = updatedRooms
            .where(
              (r) =>
                  r.name.contains(state.searchQuery) ||
                  r.subject.contains(state.searchQuery),
            )
            .toList();
      }

      emit(
        state.copyWith(
          status: CommunityStatus.loaded,
          rooms: updatedRooms,
          filteredRooms: filteredRooms,
          questions: updatedQuestions,
          filteredQuestions: filteredQuestions,
          currentPage: response.page ?? nextPage,
          totalPages: response.totalPages,
          totalCount: response.totalCount,
          hasMorePages: response.hasMorePages,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CommunityStatus.loaded, // Return to loaded state on error
          errorMessage: 'فشل في تحميل المزيد: ${e.toString()}',
        ),
      );
    }
  }

  void _onRoomLeft(
    CommunityRoomLeft event,
    Emitter<CommunityState> emit,
  ) {
    final updatedLeftRooms = {...state.leftRoomIds, event.roomId};
    emit(state.copyWith(leftRoomIds: updatedLeftRooms));
  }

  @override
  Future<void> close() {
    _questionAddedSubscription?.cancel();
    _questionUpdatedSubscription?.cancel();
    _questionDeletedSubscription?.cancel();
    return super.close();
  }
}
