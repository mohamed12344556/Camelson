import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:simplify/core/api/token_manager.dart';
import 'package:simplify/core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/community_constants.dart';
import '../../../data/models/message.dart';
import '../../../data/models/message_attachment.dart';
import '../../../data/models/message_reaction.dart';
import '../../../data/models/pending_message.dart';
import '../../../data/models/user.dart';
import '../../../data/repos/chat_repo.dart';
import '../../../data/services/message_queue_manager.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;
  final MessageQueueManager? _queueManager;
  final _uuid = const Uuid();

  StreamSubscription? _messageSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _typingSubscription;
  StreamSubscription? _reactionSubscription;
  StreamSubscription? _messageDeletedSubscription;
  StreamSubscription? _messageUpdatedSubscription;

  Timer? _reconnectTimer;
  final Map<String, Timer> _typingTimers = {};

  // ✅ Track pending optimistic messages: tempId -> message content
  final Map<String, String> _pendingMessages = {};

  // ✅ Auto-retry mechanism
  final Map<String, Timer> _retryTimers = {}; // messageId -> retry timer
  final Map<String, int> _retryAttempts = {}; // messageId -> attempt count
  static const int _maxRetryAttempts = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  ChatBloc({
    required ChatRepository repository,
    MessageQueueManager? queueManager,
  }) : _repository = repository,
       _queueManager = queueManager,
       super(ChatInitial()) {
    on<ChatConnectRequested>(_onConnectRequested);
    on<ChatDisconnectRequested>(_onDisconnectRequested);
    on<ChatLoadMessagesRequested>(_onLoadMessagesRequested);
    on<ChatSendMessageRequested>(_onSendMessageRequested);
    on<ChatSendQuestionRequested>(_onSendQuestionRequested);
    on<ChatAddReactionRequested>(_onAddReactionRequested);
    on<ChatRemoveReactionRequested>(_onRemoveReactionRequested);
    on<ChatMessageReceived>(_onMessageReceived);
    on<ChatTypingStatusReceived>(_onTypingStatusReceived);
    on<ChatTypingRequested>(_onTypingRequested);
    on<ChatConnectionStatusChanged>(_onConnectionStatusChanged);
    on<ChatRetryFailedMessage>(_onRetryFailedMessage);
    on<ChatDeleteMessage>(_onDeleteMessage);
    on<ChatMarkMessagesAsRead>(_onMarkMessagesAsRead);
    on<ChatLeaveRoomRequested>(_onLeaveRoomRequested);
    on<ChatUpdateMessage>(_onUpdateMessage);
    on<ChatReactionReceived>(_onReactionReceived);
    on<ChatMessageDeleted>(_onMessageDeletedReceived);
    on<ChatMessageUpdated>(_onMessageUpdatedReceived);
  }

  // ✅ NEW: Handle leave room
  Future<void> _onLeaveRoomRequested(
    ChatLeaveRoomRequested event,
    Emitter<ChatState> emit,
  ) async {
    try {
      developer.log('🚪 Leaving room: ${event.roomId}', name: 'ChatBloc');

      // ✅ Leave SignalR room
      await _repository.leaveRoom(event.roomId);

      // ✅ Update state to view-only mode
      if (state is ChatLoaded) {
        emit((state as ChatLoaded).copyWith(isViewOnly: true));
      }

      developer.log('✅ Successfully left room', name: 'ChatBloc');
    } catch (e) {
      developer.log('❌ Error leaving room: $e', name: 'ChatBloc');
    }
  }

  Future<void> _onConnectRequested(
    ChatConnectRequested event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatLoading());

      // ✅ Check and refresh token if expired before connecting
      final tokens = await TokenManager.getTokens();
      if (tokens != null && TokenManager.isTokenExpired(tokens.accessToken)) {
        developer.log(
          'Token expired, refreshing before SignalR connection',
          name: 'ChatBloc',
        );
        final apiService = sl<ApiService>();

        // Disconnect first to ensure fresh connection with new token
        try {
          await _repository.disconnect();
        } catch (e) {
          developer.log(
            'Disconnect before refresh failed (may not be connected): $e',
            name: 'ChatBloc',
          );
        }

        final refreshed = await TokenManager.attemptTokenRefresh(apiService);
        if (!refreshed) {
          developer.log('Token refresh failed', name: 'ChatBloc');
          emit(
            ChatError(
              message: 'Authentication failed. Please login again.',
              previousState: state,
            ),
          );
          return;
        }
        developer.log(
          'Token refreshed successfully, reconnecting...',
          name: 'ChatBloc',
        );
      }

      await _repository.connect(event.userId);
      await _repository.joinRoom(event.roomId);

      final room = await _repository.getRoom(event.roomId);
      if (room == null) {
        emit(ChatError(message: 'Room not found', previousState: state));
        return;
      }

      // ✅ Wait for initial messages
      final messages = await _repository.waitForInitialMessages();

      // ✅ CRITICAL: Setup listeners قبل emit
      _setupStreamListeners(event.roomId);

      emit(
        ChatLoaded(
          room: room,
          messages: messages,
          users: {},
          connectionStatus: ConnectionStatus.connected,
          isLoadingMore: false,
          messageStatuses: {},
          currentPage: 1,
          lastUpdated: DateTime.now(), // ✅ Initial timestamp
          isViewOnly: event.isViewOnly,
        ),
      );
    } catch (e, stackTrace) {
      developer.log('Error connecting: $e\n$stackTrace', name: 'ChatBloc');
      emit(ChatError(message: e.toString(), previousState: state));
    }
  }

  // ✅ Make sure this method exists and is correct
  void _setupStreamListeners(String roomId) {
    // Cancel existing subscriptions
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    _typingSubscription?.cancel();
    _reactionSubscription?.cancel();
    _messageDeletedSubscription?.cancel();
    _messageUpdatedSubscription?.cancel();

    // Listen to new messages
    _messageSubscription = _repository.messageStream.listen(
      (message) {
        // ✅ Check if bloc is closed
        if (isClosed) {
          developer.log(
            '⚠️ Bloc is closed, ignoring message',
            name: 'ChatBloc',
          );
          return;
        }

        developer.log(
          '🔔 ChatBloc received message from stream: ${message.id}',
          name: 'ChatBloc',
        );
        if (message.roomId == roomId) {
          add(ChatMessageReceived(message));
        } else {
          developer.log(
            '⚠️ Message for different room: ${message.roomId} != $roomId',
            name: 'ChatBloc',
          );
        }
      },
      onError: (error) {
        developer.log('❌ Error in message stream: $error', name: 'ChatBloc');
      },
    );

    // Listen to connection status
    _connectionSubscription = _repository.connectionStream.listen(
      (status) {
        if (isClosed) return; // ✅ Check if closed
        developer.log(
          '🔌 Connection status changed: $status',
          name: 'ChatBloc',
        );
        add(ChatConnectionStatusChanged(status));
      },
      onError: (error) {
        developer.log('❌ Error in connection stream: $error', name: 'ChatBloc');
      },
    );

    // Listen to typing status
    _typingSubscription = _repository.typingStream.listen(
      (data) {
        if (isClosed) return; // ✅ Check if closed
        developer.log('⌨️ Typing status: $data', name: 'ChatBloc');
        add(
          ChatTypingStatusReceived(
            userId: data['userId'],
            isTyping: data['isTyping'],
          ),
        );
      },
      onError: (error) {
        developer.log('❌ Error in typing stream: $error', name: 'ChatBloc');
      },
    );

    // Setup stream listeners for reactions
    _reactionSubscription = _repository.reactionStream.listen((data) {
      if (isClosed) return; // ✅ Check if closed
      developer.log('👍 Reaction received in BLoC: $data', name: 'ChatBloc');
      add(
        ChatReactionReceived(
          messageId: data['messageId'],
          userId: data['userId'],
          reaction: data['reaction'],
        ),
      );
    });

    // ✅ Listen to message deleted
    _messageDeletedSubscription = _repository.messageDeletedStream.listen(
      (messageId) {
        if (isClosed) return; // ✅ Check if closed
        developer.log(
          '🗑️ Message deleted received in BLoC: $messageId',
          name: 'ChatBloc',
        );
        add(ChatMessageDeleted(messageId));
      },
      onError: (error) {
        developer.log(
          '❌ Error in message deleted stream: $error',
          name: 'ChatBloc',
        );
      },
    );

    // ✅ Listen to message updated
    _messageUpdatedSubscription = _repository.messageUpdatedStream.listen(
      (message) {
        if (isClosed) return; // ✅ Check if closed
        developer.log(
          '✏️ Message updated received in BLoC: ${message.id}',
          name: 'ChatBloc',
        );
        add(ChatMessageUpdated(message));
      },
      onError: (error) {
        developer.log(
          '❌ Error in message updated stream: $error',
          name: 'ChatBloc',
        );
      },
    );

    developer.log(
      '✅ Stream listeners setup complete for room: $roomId',
      name: 'ChatBloc',
    );
  }

  Future<void> _onDisconnectRequested(
    ChatDisconnectRequested event,
    Emitter<ChatState> emit,
  ) async {
    try {
      developer.log('🔌 Disconnecting from SignalR...', name: 'ChatBloc');

      // ✅ Cancel all subscriptions
      await _cleanup();

      // ✅ Disconnect from SignalR
      await _repository.disconnect();

      // ✅ Reset state
      emit(ChatInitial());

      developer.log('✅ Disconnected successfully', name: 'ChatBloc');
    } catch (e) {
      developer.log('❌ Error disconnecting: $e', name: 'ChatBloc');
    }
  }

  Future<void> _onLoadMessagesRequested(
    ChatLoadMessagesRequested event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
    if (currentState.isLoadingMore || currentState.hasReachedEnd) return;

    safeEmit(currentState.copyWith(isLoadingMore: true));

    try {
      final messages = await _repository.getMessages(
        roomId: event.roomId,
        page: event.page,
        limit: event.limit,
      );

      if (messages.isEmpty) {
        safeEmit(
          currentState.copyWith(hasReachedEnd: true, isLoadingMore: false),
        );
        return;
      }

      // Get new users if any
      final newUserIds = messages
          .map((m) => m.userId)
          .where((id) => !currentState.users.containsKey(id))
          .toSet();

      Map<String, User> updatedUsers = Map.from(currentState.users);
      if (newUserIds.isNotEmpty) {
        final newUsers = await _repository.getUsers(newUserIds.toList());
        for (var user in newUsers) {
          updatedUsers[user.id] = user;
        }
      }

      // Merge messages
      final allMessages = [...messages, ...currentState.messages];

      safeEmit(
        currentState.copyWith(
          messages: allMessages,
          users: updatedUsers,
          isLoadingMore: false,
          currentPage: event.page,
          hasReachedEnd: messages.length < event.limit,
        ),
      );
    } catch (e) {
      safeEmit(currentState.copyWith(isLoadingMore: false));
      safeEmit(ChatError(message: e.toString(), previousState: currentState));
    }
  }

  Future<void> _onSendMessageRequested(
    ChatSendMessageRequested event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
    final tempId = _uuid.v4();

    // Create optimistic message for UI
    final optimisticMessage = Message(
      id: tempId,
      roomId: currentState.room.id,
      userId: CommunityConstants.currentUser.id,
      content: event.content,
      isQuestion: false,
      timestamp: DateTime.now(),
      attachments: null,
      reactions: [],
      replyToId: event.replyToId,
      xpEarned: 10,
      user: CommunityConstants.currentUser,
    );

    // Add message optimistically to UI (at the end for chronological order)
    final updatedMessages = [...currentState.messages, optimisticMessage];
    final updatedStatuses = Map<String, MessageStatus>.from(
      currentState.messageStatuses,
    )..[tempId] = MessageStatus.sending;

    // Track pending message
    _pendingMessages[tempId] = event.content;
    developer.log(
      '✅ Added optimistic message to UI: $tempId',
      name: 'ChatBloc',
    );

    safeEmit(
      currentState.copyWith(
        messages: updatedMessages,
        messageStatuses: updatedStatuses,
      ),
    );

    // ✅ Add to queue - Queue Manager will handle sending
    if (_queueManager != null) {
      final pendingMessage = PendingMessage(
        id: tempId,
        roomId: currentState.room.id,
        content: event.content,
        timestamp: DateTime.now(),
        attachmentPaths: event.attachmentPaths,
        replyToId: event.replyToId,
        isQuestion: false,
      );

      await _queueManager.enqueueMessage(pendingMessage);
      developer.log(
        '📥 Message added to queue, waiting for server response via stream',
        name: 'ChatBloc',
      );

      // DON'T send here - Queue Manager will do it
      // The real server message will come through _onMessageReceived
    }
  }

  Future<void> _onSendQuestionRequested(
    ChatSendQuestionRequested event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
    final tempId = _uuid.v4();

    // Create optimistic message
    final optimisticMessage = Message(
      id: tempId,
      roomId: currentState.room.id,
      userId: CommunityConstants.currentUser.id,
      content: event.content,
      isQuestion: true,
      timestamp: DateTime.now(),
      attachments: null,
      reactions: [],
      replyToId: null,
      xpEarned: 5,
      user: CommunityConstants.currentUser,
    );

    // Add message optimistically (at the end for chronological order)
    final updatedMessages = [...currentState.messages, optimisticMessage];
    final updatedStatuses = Map<String, MessageStatus>.from(
      currentState.messageStatuses,
    )..[tempId] = MessageStatus.sending;

    // Track pending message
    _pendingMessages[tempId] = event.content;
    developer.log('✅ Added pending question: $tempId', name: 'ChatBloc');

    safeEmit(
      currentState.copyWith(
        messages: updatedMessages,
        messageStatuses: updatedStatuses,
      ),
    );

    try {
      // Upload attachments if any
      List<MessageAttachment>? attachments;
      if (event.attachmentPaths != null && event.attachmentPaths!.isNotEmpty) {
        attachments = await _repository.uploadAttachments(
          event.attachmentPaths!,
          tempId,
        );
      }

      // Send question
      final sentMessage = await _repository.sendQuestion(
        roomId: currentState.room.id,
        content: event.content,
        subject: event.subject,
        grade: event.grade,
        attachments: attachments,
      );

      // Replace optimistic message with real one
      final finalMessages = currentState.messages
          .map((m) => m.id == tempId ? sentMessage : m)
          .toList();

      final finalStatuses =
          Map<String, MessageStatus>.from(currentState.messageStatuses)
            ..remove(tempId)
            ..[sentMessage.id] = MessageStatus.sent;

      // Remove from pending messages
      _pendingMessages.remove(tempId);
      developer.log(
        '✅ Removed pending question: $tempId, server ID: ${sentMessage.id}',
        name: 'ChatBloc',
      );

      // ✅ Cancel any scheduled retry for this message
      _cancelAutoRetry(tempId);

      safeEmit(
        currentState.copyWith(
          messages: finalMessages,
          messageStatuses: finalStatuses,
        ),
      );
    } catch (e) {
      // Mark as failed
      final failedStatuses = Map<String, MessageStatus>.from(
        currentState.messageStatuses,
      )..[tempId] = MessageStatus.failed;

      // Remove from pending messages
      _pendingMessages.remove(tempId);
      developer.log(
        '❌ Removed failed pending question: $tempId',
        name: 'ChatBloc',
      );

      safeEmit(currentState.copyWith(messageStatuses: failedStatuses));

      // ✅ Schedule auto-retry
      _scheduleAutoRetry(tempId);
    }
  }

  // ✅ Update _onAddReactionRequested
  Future<void> _onAddReactionRequested(
    ChatAddReactionRequested event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;
    final currentState = state as ChatLoaded;

    try {
      final messageIndex = currentState.messages.indexWhere(
        (m) => m.id == event.messageId,
      );
      if (messageIndex == -1) return;

      final message = currentState.messages[messageIndex];

      // ✅ Check if user already has ANY reaction on this message
      final existingReaction = message.reactions.firstWhere(
        (r) => r.userId == CommunityConstants.currentUser.id,
        orElse: () => MessageReaction(
          id: '',
          messageId: '',
          userId: '',
          type: ReactionType.like,
          reaction: '👍', // Added required parameter
          timestamp: DateTime.now(),
        ),
      );

      // ✅ If user already reacted with the SAME type → remove it (toggle off)
      if (existingReaction.id.isNotEmpty &&
          existingReaction.type == event.reactionType) {
        developer.log(
          '🔄 User clicked same reaction → Removing it',
          name: 'ChatBloc',
        );
        add(
          ChatRemoveReactionRequested(
            messageId: event.messageId,
            reactionType: event.reactionType,
          ),
        );
        return;
      }

      // ✅ Remove old reaction (if exists) before adding new one
      final reactionsWithoutUser = message.reactions
          .where((r) => r.userId != CommunityConstants.currentUser.id)
          .toList();

      // Add new reaction
      final newReaction = MessageReaction(
        id: _uuid.v4(),
        messageId: event.messageId,
        userId: CommunityConstants.currentUser.id,
        type: event.reactionType,
        timestamp: DateTime.now(),
        reaction: event.reactionType.toString().split('.').last,
      );

      final updatedMessage = Message(
        id: message.id,
        roomId: message.roomId,
        userId: message.userId,
        content: message.content,
        isQuestion: message.isQuestion,
        timestamp: message.timestamp,
        attachments: message.attachments,
        reactions: [...reactionsWithoutUser, newReaction],
        replyToId: message.replyToId,
        xpEarned: message.xpEarned + 2,
        user: message.user,
      );

      final updatedMessages = List<Message>.from(currentState.messages)
        ..[messageIndex] = updatedMessage;

      safeEmit(currentState.copyWith(messages: updatedMessages));

      // Send to server
      await _repository.addReaction(
        currentState.room.id,
        event.messageId,
        event.reactionType,
      );
    } catch (e) {
      developer.log('❌ Error adding reaction: $e', name: 'ChatBloc');
      // Revert on error
      safeEmit(currentState);
    }
  }

  Future<void> _onRemoveReactionRequested(
    ChatRemoveReactionRequested event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;
    final currentState = state as ChatLoaded;

    try {
      final messageIndex = currentState.messages.indexWhere(
        (m) => m.id == event.messageId,
      );

      if (messageIndex == -1) return;

      final message = currentState.messages[messageIndex];

      // ✅ Remove reaction for current user with this type
      final updatedReactions = message.reactions
          .where(
            (r) =>
                !(r.userId == CommunityConstants.currentUser.id &&
                    r.type == event.reactionType),
          )
          .toList();

      // Check if actually removed anything
      if (updatedReactions.length == message.reactions.length) {
        developer.log('⚠️ No reaction found to remove', name: 'ChatBloc');
        return;
      }

      final updatedMessage = Message(
        id: message.id,
        roomId: message.roomId,
        userId: message.userId,
        content: message.content,
        isQuestion: message.isQuestion,
        timestamp: message.timestamp,
        attachments: message.attachments,
        reactions: updatedReactions,
        replyToId: message.replyToId,
        xpEarned: max(0, message.xpEarned - 2), // ✅ Don't go negative
        user: message.user,
      );

      final updatedMessages = List<Message>.from(currentState.messages)
        ..[messageIndex] = updatedMessage;

      safeEmit(currentState.copyWith(messages: updatedMessages));

      // ✅ Send to server with correct parameters
      await _repository.removeReaction(
        currentState.room.id,
        event.messageId,
        event.reactionType,
      );
    } catch (e) {
      developer.log('❌ Error removing reaction: $e', name: 'ChatBloc');
      // Revert on error
      safeEmit(currentState);
    }
  }

  void _onMessageReceived(ChatMessageReceived event, Emitter<ChatState> emit) {
    developer.log('📨 ChatBloc._onMessageReceived called', name: 'ChatBloc');
    developer.log('   Message ID: ${event.message.id}', name: 'ChatBloc');
    developer.log(
      '   Message content: ${event.message.content.substring(0, min(50, event.message.content.length))}',
      name: 'ChatBloc',
    );

    if (state is! ChatLoaded) {
      developer.log(
        '⚠️ State is not ChatLoaded, ignoring message',
        name: 'ChatBloc',
      );
      return;
    }

    final currentState = state as ChatLoaded;

    // Check if message already exists by ID
    final existsById = currentState.messages.any(
      (m) => m.id == event.message.id,
    );

    // Check if this is a duplicate of a pending message (by content and sender)
    final isDuplicatePending = _pendingMessages.values.any(
      (content) =>
          content == event.message.content &&
          event.message.userId == CommunityConstants.currentUser.id,
    );

    if (existsById || isDuplicatePending) {
      developer.log(
        '⚠️ Message already exists (ID match: $existsById, pending match: $isDuplicatePending), skipping',
        name: 'ChatBloc',
      );

      // If it matches a pending message, find and remove the temp one
      if (isDuplicatePending) {
        final tempIdToRemove = _pendingMessages.entries
            .firstWhere(
              (entry) => entry.value == event.message.content,
              orElse: () => MapEntry('', ''),
            )
            .key;

        if (tempIdToRemove.isNotEmpty) {
          _pendingMessages.remove(tempIdToRemove);

          // Replace temp message with real one
          final updatedMessages = currentState.messages
              .map((m) => m.id == tempIdToRemove ? event.message : m)
              .toList();

          // Remove message status for temp ID
          final updatedStatuses = Map<String, MessageStatus>.from(
            currentState.messageStatuses,
          )..remove(tempIdToRemove);

          // Remove from queue if queue manager exists
          if (_queueManager != null) {
            _queueManager.removeMessage(tempIdToRemove);
          }

          developer.log(
            '✅ Replaced temp message $tempIdToRemove with server message ${event.message.id}',
            name: 'ChatBloc',
          );
          developer.log(
            '📊 Messages before: ${currentState.messages.length}, after: ${updatedMessages.length}',
            name: 'ChatBloc',
          );
          developer.log(
            '📊 Last message ID before: ${currentState.messages.lastOrNull?.id}',
            name: 'ChatBloc',
          );
          developer.log(
            '📊 Last message ID after: ${updatedMessages.lastOrNull?.id}',
            name: 'ChatBloc',
          );

          final newState = currentState.copyWith(
            messages: updatedMessages,
            messageStatuses: updatedStatuses,
            forceUpdate: true, // ✅ Force UI rebuild
          );

          developer.log(
            '📤 Emitting new state with lastUpdated: ${newState.lastUpdated}',
            name: 'ChatBloc',
          );
          safeEmit(newState);
        }
      }

      return;
    }

    developer.log('✅ Adding message to state', name: 'ChatBloc');

    // Add new message at the end (chronological order)
    final updatedMessages = [...currentState.messages, event.message];

    // Add user if not exists
    Map<String, User> updatedUsers = Map.from(currentState.users);
    if (!updatedUsers.containsKey(event.message.userId)) {
      updatedUsers[event.message.userId] = event.message.user;
    }

    safeEmit(
      currentState.copyWith(messages: updatedMessages, users: updatedUsers),
    );

    developer.log(
      '✅ State emitted with ${updatedMessages.length} messages',
      name: 'ChatBloc',
    );
  }

  void _onTypingStatusReceived(
    ChatTypingStatusReceived event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatLoaded) return;
    final currentState = state as ChatLoaded;

    // ✅ Convert userId to User object
    List<User> updatedTypingUsers = List.from(currentState.typingUsers);

    if (event.isTyping) {
      // ✅ Check if user exists in users map
      final user = currentState.users[event.userId];
      if (user != null &&
          !updatedTypingUsers.any((u) => u.id == event.userId)) {
        updatedTypingUsers.add(user); // ✅ Add User object
      }

      // ✅ Auto-remove typing indicator after 3 seconds (safety timeout)
      _typingTimers[event.userId]?.cancel();
      _typingTimers[event.userId] = Timer(const Duration(seconds: 3), () {
        developer.log(
          '⏱️ Typing timeout for user: ${event.userId}',
          name: 'ChatBloc',
        );
        add(ChatTypingStatusReceived(userId: event.userId, isTyping: false));
      });
    } else {
      // ✅ Remove user by ID immediately
      updatedTypingUsers.removeWhere((u) => u.id == event.userId);
      // ✅ Cancel timer for this user
      _typingTimers[event.userId]?.cancel();
      _typingTimers.remove(event.userId);
    }

    safeEmit(
      currentState.copyWith(
        typingUsers: updatedTypingUsers,
        isTyping: updatedTypingUsers.isNotEmpty,
      ),
    );
  }

  // ✅ Handle typing request (when current user types)
  Future<void> _onTypingRequested(
    ChatTypingRequested event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;
    final currentState = state as ChatLoaded;

    try {
      await _repository.sendTypingIndicator(
        currentState.room.id,
        event.isTyping,
      );
    } catch (e) {
      developer.log('❌ Error sending typing indicator: $e', name: 'ChatBloc');
    }
  }

  void _onConnectionStatusChanged(
    ChatConnectionStatusChanged event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;

    if (event.status == ConnectionStatus.disconnected) {
      safeEmit(ChatReconnecting(previousState: currentState));
      _startReconnectTimer();
    } else if (event.status == ConnectionStatus.connected) {
      _reconnectTimer?.cancel();
      safeEmit(currentState.copyWith(connectionStatus: event.status));
    } else {
      safeEmit(currentState.copyWith(connectionStatus: event.status));
    }
  }

  Future<void> _onRetryFailedMessage(
    ChatRetryFailedMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
    final message = currentState.messages.firstWhere(
      (m) => m.id == event.messageId,
      orElse: () => throw Exception('Message not found'),
    );

    // Update status to sending
    final updatedStatuses = Map<String, MessageStatus>.from(
      currentState.messageStatuses,
    )..[event.messageId] = MessageStatus.sending;

    safeEmit(currentState.copyWith(messageStatuses: updatedStatuses));

    try {
      // Resend message
      final sentMessage = await _repository.sendMessage(
        roomId: currentState.room.id,
        content: message.content,
        attachments: message.attachments,
        replyToId: message.replyToId,
      );

      // Replace with new message
      final updatedMessages = currentState.messages
          .map((m) => m.id == event.messageId ? sentMessage : m)
          .toList();

      final finalStatuses =
          Map<String, MessageStatus>.from(currentState.messageStatuses)
            ..remove(event.messageId)
            ..[sentMessage.id] = MessageStatus.sent;

      // ✅ Cancel auto-retry on success
      _cancelAutoRetry(event.messageId);

      safeEmit(
        currentState.copyWith(
          messages: updatedMessages,
          messageStatuses: finalStatuses,
        ),
      );
    } catch (e) {
      // Mark as failed again
      final failedStatuses = Map<String, MessageStatus>.from(
        currentState.messageStatuses,
      )..[event.messageId] = MessageStatus.failed;

      safeEmit(currentState.copyWith(messageStatuses: failedStatuses));

      // ✅ Schedule another retry if not manually triggered
      // (Auto-retry already increments counter in _scheduleAutoRetry)
    }
  }

  Future<void> _onDeleteMessage(
    ChatDeleteMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;
    final currentState = state as ChatLoaded;

    try {
      // Call repository
      await _repository.deleteMessage(currentState.room.id, event.messageId);

      // Remove from state
      final updatedMessages = currentState.messages
          .where((m) => m.id != event.messageId)
          .toList();

      safeEmit(currentState.copyWith(messages: updatedMessages));
    } catch (e) {
      developer.log('❌ Error deleting message: $e', name: 'ChatBloc');
    }
  }

  // ✅ Add update message handler
  Future<void> _onUpdateMessage(
    ChatUpdateMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;
    final currentState = state as ChatLoaded;

    try {
      await _repository.updateMessage(
        currentState.room.id,
        event.messageId,
        event.newContent,
      );

      // Update in state
      final updatedMessages = currentState.messages.map((m) {
        if (m.id == event.messageId) {
          return Message(
            id: m.id,
            roomId: m.roomId,
            userId: m.userId,
            content: event.newContent,
            isQuestion: m.isQuestion,
            timestamp: m.timestamp,
            attachments: m.attachments,
            reactions: m.reactions,
            replyToId: m.replyToId,
            xpEarned: m.xpEarned,
            user: m.user,
          );
        }
        return m;
      }).toList();

      safeEmit(currentState.copyWith(messages: updatedMessages));
    } catch (e) {
      developer.log('❌ Error updating message: $e', name: 'ChatBloc');
    }
  }

  // ✅ Handle reaction received
  void _onReactionReceived(
    ChatReactionReceived event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatLoaded) return;
    final currentState = state as ChatLoaded;

    // Update message reactions in state
    final updatedMessages = currentState.messages.map((m) {
      if (m.id == event.messageId) {
        // ✅ Check if reaction already exists
        final reactionExists = m.reactions.any(
          (r) =>
              r.userId == event.userId &&
              r.type == _parseReactionType(event.reaction),
        );

        if (reactionExists) {
          developer.log(
            '⚠️ Reaction already exists, skipping...',
            name: 'ChatBloc',
          );
          return m; // Don't add duplicate
        }

        // Add new reaction
        final newReaction = MessageReaction(
          id: 'reaction_${DateTime.now().millisecondsSinceEpoch}',
          messageId: event.messageId,
          userId: event.userId,
          type: _parseReactionType(event.reaction),
          timestamp: DateTime.now(),
          reaction: event.reaction,
        );

        developer.log(
          '✅ Adding new reaction from user: ${event.userId}',
          name: 'ChatBloc',
        );

        return Message(
          id: m.id,
          roomId: m.roomId,
          userId: m.userId,
          content: m.content,
          isQuestion: m.isQuestion,
          timestamp: m.timestamp,
          attachments: m.attachments,
          reactions: [...m.reactions, newReaction],
          replyToId: m.replyToId,
          xpEarned: m.xpEarned,
          user: m.user,
        );
      }
      return m;
    }).toList();

    safeEmit(currentState.copyWith(messages: updatedMessages));
  }

  ReactionType _parseReactionType(String reaction) {
    switch (reaction.toLowerCase()) {
      case 'like':
        return ReactionType.like;
      case 'love':
        return ReactionType.love;
      case 'laugh':
        return ReactionType.laugh;
      case 'wow':
        return ReactionType.wow;
      case 'sad':
        return ReactionType.sad;
      case 'angry':
        return ReactionType.angry;
      case 'clap':
        return ReactionType.clap;
      case 'fire':
        return ReactionType.fire;
      case 'correct':
        return ReactionType.correct;
      case 'helpful':
        return ReactionType.helpful;
      default:
        return ReactionType.like;
    }
  }

  // ✅ Handle message deleted from server
  void _onMessageDeletedReceived(
    ChatMessageDeleted event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatLoaded) return;
    final currentState = state as ChatLoaded;

    developer.log(
      '🗑️ Handling message deletion in BLoC: ${event.messageId}',
      name: 'ChatBloc',
    );

    // Remove message from state
    final updatedMessages = currentState.messages
        .where((m) => m.id != event.messageId)
        .toList();

    safeEmit(currentState.copyWith(messages: updatedMessages));
    developer.log(
      '✅ Message removed from state: ${event.messageId}',
      name: 'ChatBloc',
    );
  }

  // ✅ Handle message updated from server
  void _onMessageUpdatedReceived(
    ChatMessageUpdated event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatLoaded) return;
    final currentState = state as ChatLoaded;

    developer.log(
      '✏️ Handling message update in BLoC: ${event.message.id}',
      name: 'ChatBloc',
    );

    // Update message in state
    final updatedMessages = currentState.messages.map((m) {
      if (m.id == event.message.id) {
        return event.message; // Replace with updated message
      }
      return m;
    }).toList();

    safeEmit(currentState.copyWith(messages: updatedMessages));
    developer.log(
      '✅ Message updated in state: ${event.message.id}',
      name: 'ChatBloc',
    );
  }

  Future<void> _onMarkMessagesAsRead(
    ChatMarkMessagesAsRead event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;

    // Update statuses
    final updatedStatuses = Map<String, MessageStatus>.from(
      currentState.messageStatuses,
    );
    for (final id in event.messageIds) {
      if (updatedStatuses[id] == MessageStatus.delivered) {
        updatedStatuses[id] = MessageStatus.read;
      }
    }

    safeEmit(currentState.copyWith(messageStatuses: updatedStatuses));

    try {
      await _repository.markMessagesAsRead(event.messageIds);
    } catch (e) {
      // Silent fail
    }
  }

  /// Schedule automatic retry for failed messages
  void _scheduleAutoRetry(String messageId) {
    // Cancel any existing retry timer for this message
    _retryTimers[messageId]?.cancel();

    // Get current attempt count (default to 0)
    final currentAttempt = _retryAttempts[messageId] ?? 0;

    // Check if we've exceeded max retry attempts
    if (currentAttempt >= _maxRetryAttempts) {
      developer.log(
        '⚠️ Max retry attempts reached for message: $messageId',
        name: 'ChatBloc',
      );
      _retryAttempts.remove(messageId);
      return;
    }

    // Exponential backoff: 2s, 4s, 8s
    final delay = _retryDelay * pow(2, currentAttempt).toInt();

    developer.log(
      '⏱️ Scheduling retry attempt ${currentAttempt + 1}/$_maxRetryAttempts for message: $messageId (delay: ${delay.inSeconds}s)',
      name: 'ChatBloc',
    );

    // Schedule retry
    _retryTimers[messageId] = Timer(delay, () {
      developer.log('🔄 Auto-retrying message: $messageId', name: 'ChatBloc');

      // Increment attempt counter
      _retryAttempts[messageId] = currentAttempt + 1;

      // Trigger retry event
      add(ChatRetryFailedMessage(messageId));

      // Remove timer reference
      _retryTimers.remove(messageId);
    });
  }

  /// Cancel auto-retry for a specific message
  void _cancelAutoRetry(String messageId) {
    _retryTimers[messageId]?.cancel();
    _retryTimers.remove(messageId);
    _retryAttempts.remove(messageId);
  }

  void _startReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (state is ChatReconnecting) {
        final previousState = (state as ChatReconnecting).previousState;
        if (previousState is ChatLoaded) {
          add(
            ChatConnectRequested(
              userId: CommunityConstants.currentUser.id,
              roomId: previousState.room.id,
            ),
          );
        }
      }
    });
  }

  Future<void> _cleanup() async {
    developer.log('🧹 Cleaning up subscriptions...', name: 'ChatBloc');

    // Cancel all stream subscriptions
    await _messageSubscription?.cancel();
    await _connectionSubscription?.cancel();
    await _typingSubscription?.cancel();
    await _reactionSubscription?.cancel();
    await _messageDeletedSubscription?.cancel();
    await _messageUpdatedSubscription?.cancel();

    // Cancel timers
    _reconnectTimer?.cancel();
    for (var timer in _typingTimers.values) {
      timer.cancel();
    }
    _typingTimers.clear();

    // ✅ Cancel all retry timers
    for (var timer in _retryTimers.values) {
      timer.cancel();
    }
    _retryTimers.clear();
    _retryAttempts.clear();

    developer.log('✅ Cleanup complete', name: 'ChatBloc');
  }

  @override
  Future<void> close() async {
    developer.log('🔒 ChatBloc closing...', name: 'ChatBloc');
    await _cleanup();
    return super.close();
  }
}
