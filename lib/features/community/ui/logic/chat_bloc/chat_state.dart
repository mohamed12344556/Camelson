import 'package:equatable/equatable.dart';

import '../../../data/models/message.dart';
import '../../../data/models/message_reaction.dart';
import '../../../data/models/room.dart';
import '../../../data/models/user.dart';
import 'chat_event.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final Room room;
  final List<Message> messages;
  final Map<String, User> users;
  final Map<String, List<MessageReaction>> reactions; // ✅ Added
  final List<User> typingUsers;
  final bool isTyping; // ✅ Added
  final ConnectionStatus connectionStatus;
  final bool hasReachedEnd;
  final bool isLoadingMore;
  final Map<String, MessageStatus> messageStatuses;
  final int currentPage;
  final DateTime? lastUpdated; // ✅ Force rebuild on message changes
  final bool isViewOnly; // ✅ User left room - view only mode

  const ChatLoaded({
    required this.room,
    required this.messages,
    required this.users,
    required this.connectionStatus,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.messageStatuses = const {},
    this.currentPage = 1,
    this.typingUsers = const [], // ✅ لازم يبقى List<User>
    this.isTyping = false,
    this.reactions = const {}, // ✅ Added
    this.lastUpdated,
    this.isViewOnly = false,
  });

  ChatLoaded copyWith({
    Room? room,
    List<Message>? messages,
    Map<String, User>? users,
    Map<String, List<MessageReaction>>? reactions, // ✅ Added
    List<User>? typingUsers,
    bool? isTyping, // ✅ Added
    ConnectionStatus? connectionStatus,
    bool? hasReachedEnd,
    bool? isLoadingMore,
    Map<String, MessageStatus>? messageStatuses,
    int? currentPage,
    bool forceUpdate = false, // ✅ Force timestamp update
    bool? isViewOnly,
  }) {
    // ✅ CRITICAL: Always create new timestamp when state changes
    final now = DateTime.now();

    return ChatLoaded(
      room: room ?? this.room,
      messages: messages ?? this.messages,
      users: users ?? this.users,
      reactions: reactions ?? this.reactions, // ✅ Added
      typingUsers: typingUsers ?? this.typingUsers,
      isTyping: isTyping ?? this.isTyping, // ✅ Added
      connectionStatus: connectionStatus ?? this.connectionStatus,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      messageStatuses: messageStatuses ?? this.messageStatuses,
      currentPage: currentPage ?? this.currentPage,
      lastUpdated: now, // ✅ Always update to force rebuild
      isViewOnly: isViewOnly ?? this.isViewOnly,
    );
  }

  @override
  List<Object?> get props => [
    room,
    messages,
    users,
    reactions, // ✅ Added
    typingUsers,
    isTyping, // ✅ Added
    connectionStatus,
    hasReachedEnd,
    isLoadingMore,
    messageStatuses,
    currentPage,
    lastUpdated, // ✅ Include in comparison
    isViewOnly,
  ];
}

class ChatError extends ChatState {
  final String message;
  final ChatState? previousState;

  const ChatError({required this.message, this.previousState});

  @override
  List<Object?> get props => [message, previousState];
}

class ChatReconnecting extends ChatState {
  final ChatState previousState;

  const ChatReconnecting({required this.previousState});

  @override
  List<Object?> get props => [previousState];
}

enum MessageStatus { sending, sent, failed, delivered, read }
