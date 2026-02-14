import 'package:equatable/equatable.dart';

import '../../../data/models/question.dart';
import '../../../data/models/room.dart';
import '../../../data/models/user.dart';

enum CommunityStatus { initial, loading, loaded, error, loadingMore }

enum QuestionFilter { all, active }

class CommunityState extends Equatable {
  final CommunityStatus status;
  final List<Room> rooms;
  final List<Room> filteredRooms;
  final List<Question> questions;
  final List<Question> filteredQuestions;
  final User? currentUser;
  final String searchQuery;
  final QuestionFilter filter;
  final String? errorMessage;

  // Pagination fields
  final int currentPage;
  final int pageSize;
  final int? totalPages;
  final int? totalCount;
  final bool hasMorePages;

  // Track rooms the user has left (view-only on re-entry)
  final Set<String> leftRoomIds;

  const CommunityState({
    required this.status,
    required this.rooms,
    required this.filteredRooms,
    required this.questions,
    required this.filteredQuestions,
    this.currentUser,
    this.searchQuery = '',
    this.filter = QuestionFilter.active,
    this.errorMessage,
    this.currentPage = 1,
    this.pageSize = 20,
    this.totalPages,
    this.totalCount,
    this.hasMorePages = false,
    this.leftRoomIds = const {},
  });

  factory CommunityState.initial() {
    return const CommunityState(
      status: CommunityStatus.initial,
      rooms: [],
      filteredRooms: [],
      questions: [],
      filteredQuestions: [],
      searchQuery: '',
      leftRoomIds: {},
    );
  }

  CommunityState copyWith({
    CommunityStatus? status,
    List<Room>? rooms,
    List<Room>? filteredRooms,
    List<Question>? questions,
    List<Question>? filteredQuestions,
    User? currentUser,
    String? searchQuery,
    QuestionFilter? filter,
    String? errorMessage,
    int? currentPage,
    int? pageSize,
    int? totalPages,
    int? totalCount,
    bool? hasMorePages,
    Set<String>? leftRoomIds,
  }) {
    return CommunityState(
      status: status ?? this.status,
      rooms: rooms ?? this.rooms,
      filteredRooms: filteredRooms ?? this.filteredRooms,
      questions: questions ?? this.questions,
      filteredQuestions: filteredQuestions ?? this.filteredQuestions,
      currentUser: currentUser ?? this.currentUser,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      leftRoomIds: leftRoomIds ?? this.leftRoomIds,
    );
  }

  // Convenience getters for backward compatibility
  List<Room> get activeRooms => rooms;
  List<Question> get allQuestions => questions;

  @override
  List<Object?> get props => [
    status,
    rooms,
    filteredRooms,
    questions,
    filteredQuestions,
    currentUser,
    searchQuery,
    filter,
    errorMessage,
    currentPage,
    pageSize,
    totalPages,
    totalCount,
    hasMorePages,
    leftRoomIds,
  ];
}
