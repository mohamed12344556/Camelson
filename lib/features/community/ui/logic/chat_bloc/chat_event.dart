import 'package:equatable/equatable.dart';

import '../../../data/models/message.dart';
import '../../../data/models/message_reaction.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

// Connection Events
class ChatConnectRequested extends ChatEvent {
  final String userId;
  final String roomId;
  final bool isViewOnly;

  const ChatConnectRequested({
    required this.userId,
    required this.roomId,
    this.isViewOnly = false,
  });

  @override
  List<Object> get props => [userId, roomId, isViewOnly];
}

class ChatDisconnectRequested extends ChatEvent {}

// Message Events
class ChatLoadMessagesRequested extends ChatEvent {
  final String roomId;
  final int page;
  final int limit;

  const ChatLoadMessagesRequested({
    required this.roomId,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object> get props => [roomId, page, limit];
}

class ChatSendMessageRequested extends ChatEvent {
  final String content;
  final List<String>? attachmentPaths;
  final String? replyToId;

  const ChatSendMessageRequested({
    required this.content,
    this.attachmentPaths,
    this.replyToId,
  });

  @override
  List<Object?> get props => [content, attachmentPaths, replyToId];
}

class ChatSendQuestionRequested extends ChatEvent {
  final String content;
  final String subject;
  final String grade;
  final List<String>? attachmentPaths;

  const ChatSendQuestionRequested({
    required this.content,
    required this.subject,
    required this.grade,
    this.attachmentPaths,
  });

  @override
  List<Object?> get props => [content, subject, grade, attachmentPaths];
}

// Reaction Events
class ChatAddReactionRequested extends ChatEvent {
  final String messageId;
  final ReactionType reactionType;

  const ChatAddReactionRequested({
    required this.messageId,
    required this.reactionType,
  });

  @override
  List<Object> get props => [messageId, reactionType];
}

class ChatRemoveReactionRequested extends ChatEvent {
  final String messageId;
  final ReactionType reactionType; // ✅ مش reactionId

  const ChatRemoveReactionRequested({
    required this.messageId,
    required this.reactionType,
  });

  @override
  List<Object?> get props => [messageId, reactionType];
}

// ✅ Add this new event
class ChatLeaveRoomRequested extends ChatEvent {
  final String roomId;

  const ChatLeaveRoomRequested(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

// WebSocket Events
class ChatMessageReceived extends ChatEvent {
  final Message message;

  const ChatMessageReceived(this.message);

  @override
  List<Object> get props => [message];
}

class ChatTypingStatusReceived extends ChatEvent {
  final String userId;
  final bool isTyping;

  const ChatTypingStatusReceived({
    required this.userId,
    required this.isTyping,
  });

  @override
  List<Object> get props => [userId, isTyping];
}

// ✅ Add typing request event (when current user types)
class ChatTypingRequested extends ChatEvent {
  final bool isTyping;

  const ChatTypingRequested({required this.isTyping});

  @override
  List<Object> get props => [isTyping];
}

class ChatConnectionStatusChanged extends ChatEvent {
  final ConnectionStatus status;

  const ChatConnectionStatusChanged(this.status);

  @override
  List<Object> get props => [status];
}

// Other Events
class ChatRetryFailedMessage extends ChatEvent {
  final String messageId;

  const ChatRetryFailedMessage(this.messageId);

  @override
  List<Object> get props => [messageId];
}

class ChatDeleteMessage extends ChatEvent {
  final String messageId;

  const ChatDeleteMessage(this.messageId);

  @override
  List<Object> get props => [messageId];
}

class ChatMarkMessagesAsRead extends ChatEvent {
  final List<String> messageIds;

  const ChatMarkMessagesAsRead(this.messageIds);

  @override
  List<Object> get props => [messageIds];
}

// Update message event
class ChatUpdateMessage extends ChatEvent {
  final String messageId;
  final String newContent;

  const ChatUpdateMessage({required this.messageId, required this.newContent});
}

// Reaction received event
class ChatReactionReceived extends ChatEvent {
  final String messageId;
  final String userId;
  final String reaction;

  const ChatReactionReceived({
    required this.messageId,
    required this.userId,
    required this.reaction,
  });
}

// ✅ Message deleted event (from server)
class ChatMessageDeleted extends ChatEvent {
  final String messageId;

  const ChatMessageDeleted(this.messageId);

  @override
  List<Object> get props => [messageId];
}

// ✅ Message updated event (from server)
class ChatMessageUpdated extends ChatEvent {
  final Message message;

  const ChatMessageUpdated(this.message);

  @override
  List<Object> get props => [message];
}

enum ConnectionStatus { connecting, connected, disconnected, error }
