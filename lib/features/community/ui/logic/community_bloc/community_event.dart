import 'package:equatable/equatable.dart';
import '../../logic/community_bloc/community_state.dart';

abstract class CommunityEvent extends Equatable {
  const CommunityEvent();

  @override
  List<Object?> get props => [];
}

class CommunityLoadRequested extends CommunityEvent {
  final bool forceRefresh;
  
  const CommunityLoadRequested({this.forceRefresh = false});

  @override
  List<Object> get props => [forceRefresh];
}

class CommunitySearchRequested extends CommunityEvent {
  final String query;

  const CommunitySearchRequested(this.query);

  @override
  List<Object> get props => [query];
}

class CommunitySearchQueryChanged extends CommunityEvent {
  final String query;

  const CommunitySearchQueryChanged(this.query);

  @override
  List<Object> get props => [query];
}

class CommunityQuestionSubmitted extends CommunityEvent {
  final QuestionData question;
  
  const CommunityQuestionSubmitted(this.question);

  @override
  List<Object> get props => [question];
}

class CommunityPolicyAccepted extends CommunityEvent {
  final String userId;
  
  const CommunityPolicyAccepted(this.userId);

  @override
  List<Object> get props => [userId];
}

class CommunityRefreshRequested extends CommunityEvent {
  const CommunityRefreshRequested();
}

// Real-time events from SignalR
class CommunityQuestionAdded extends CommunityEvent {
  final dynamic question;

  const CommunityQuestionAdded(this.question);

  @override
  List<Object> get props => [question];
}

class CommunityQuestionUpdated extends CommunityEvent {
  final dynamic question;

  const CommunityQuestionUpdated(this.question);

  @override
  List<Object> get props => [question];
}

class CommunityQuestionDeleted extends CommunityEvent {
  final String questionId;

  const CommunityQuestionDeleted(this.questionId);

  @override
  List<Object> get props => [questionId];
}

// New Events for Filter and Pagination
class CommunityFilterChanged extends CommunityEvent {
  final QuestionFilter filter;

  const CommunityFilterChanged(this.filter);

  @override
  List<Object> get props => [filter];
}

class CommunityLoadMoreRequested extends CommunityEvent {
  const CommunityLoadMoreRequested();
}

class CommunityRoomLeft extends CommunityEvent {
  final String roomId;

  const CommunityRoomLeft(this.roomId);

  @override
  List<Object> get props => [roomId];
}

// Question Data Model for form submissions
class QuestionData extends Equatable {
  final String content;
  final String subject;
  final String grade;
  final List<String>? attachments;

  const QuestionData({
    required this.content,
    required this.subject,
    required this.grade,
    this.attachments,
  });

  @override
  List<Object?> get props => [content, subject, grade, attachments];
}