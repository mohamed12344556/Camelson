import 'dart:async';
import 'dart:developer' as dev;
import '../../../../core/services/signalr_service.dart';
import '../models/community_models.dart';
import '../models/question.dart';
import 'question_api_service.dart';

/// Service that handles real-time chat for Questions using SignalR
class QuestionChatService {
  static final QuestionChatService _instance =
      QuestionChatService._internal();
  factory QuestionChatService() => _instance;
  QuestionChatService._internal();

  final QuestionApiService _apiService = QuestionApiService();
  final SignalRService _signalR = SignalRService();

  // Stream controllers for real-time chat events
  final _messagesController = StreamController<List<QuestionMessage>>.broadcast();
  final _newMessageController = StreamController<QuestionMessage>.broadcast();
  final _messageDeletedController = StreamController<String>.broadcast();
  final _messageUpdatedController = StreamController<QuestionMessage>.broadcast();
  final _typingUsersController = StreamController<List<String>>.broadcast();
  final _onlineUsersController = StreamController<List<String>>.broadcast();
  final _previousMessagesController = StreamController<Map<String, dynamic>>.broadcast(); // ✅ NEW
  final _userJoinedController = StreamController<Map<String, dynamic>>.broadcast(); // ✅ NEW
  final _userLeftController = StreamController<Map<String, dynamic>>.broadcast(); // ✅ NEW
  final _userOnlineStatusController = StreamController<Map<String, dynamic>>.broadcast(); // ✅ NEW
  final _userActivityController = StreamController<Map<String, dynamic>>.broadcast(); // ✅ NEW

  // Public streams
  Stream<List<QuestionMessage>> get onAllMessages => _messagesController.stream;
  Stream<QuestionMessage> get onNewMessage => _newMessageController.stream;
  Stream<String> get onMessageDeleted => _messageDeletedController.stream;
  Stream<QuestionMessage> get onMessageUpdated => _messageUpdatedController.stream;
  Stream<List<String>> get onTypingUsers => _typingUsersController.stream;
  Stream<List<String>> get onOnlineUsers => _onlineUsersController.stream;
  Stream<Map<String, dynamic>> get onPreviousMessages => _previousMessagesController.stream; // ✅ NEW
  Stream<Map<String, dynamic>> get onUserJoined => _userJoinedController.stream; // ✅ NEW
  Stream<Map<String, dynamic>> get onUserLeft => _userLeftController.stream; // ✅ NEW
  Stream<Map<String, dynamic>> get onUserOnlineStatus => _userOnlineStatusController.stream; // ✅ NEW
  Stream<Map<String, dynamic>> get onUserActivity => _userActivityController.stream; // ✅ NEW

  bool _isInitialized = false;
  String? _currentQuestionId;

  /// Initialize SignalR connection and setup handlers
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _signalR.connect();
      _setupChatEventHandlers();
      _isInitialized = true;
      dev.log('QuestionChatService initialized', name: 'QuestionChat');
    } catch (e) {
      dev.log('Error initializing QuestionChatService: $e',
          name: 'QuestionChat', error: e);
      rethrow;
    }
  }

  /// Setup SignalR event handlers for chat events
  void _setupChatEventHandlers() {
    _signalR.onMessageReceived.listen((data) {
      try {
        if (data is Map<String, dynamic>) {
          final type = data['type'];
          final payload = data['data'];

          dev.log('📨 Received event: $type', name: 'QuestionChat');

          switch (type) {
            case 'JoinedQuestion':
              _handleJoinedQuestion(payload);
              break;
            case 'AllMessagesLoaded':
              _handleAllMessagesLoaded(payload);
              break;
            case 'NewMessage':
              _handleNewMessage(payload);
              break;
            case 'MessageDeleted':
              _handleMessageDeleted(payload);
              break;
            case 'MessageUpdated':
              _handleMessageUpdated(payload);
              break;
            case 'UserTyping':
              _handleUserTyping(payload);
              break;
            case 'OnlineUsers':
              _handleOnlineUsers(payload);
              break;
            case 'UserJoined':
            case 'UserJoinedQuestion':
              _handleUserJoined(payload);
              break;
            case 'UserLeft':
              _handleUserLeft(payload);
              break;
            case 'MessageReacted':
              _handleMessageReaction(payload);
              break;
            case 'PreviousMessages': // ✅ NEW
              _handlePreviousMessages(payload);
              break;
            case 'UserOnlineStatus': // ✅ NEW
              _handleUserOnlineStatus(payload);
              break;
            case 'UserActivity': // ✅ NEW
              _handleUserActivity(payload);
              break;
            case 'Error':
              _handleError(payload);
              break;
          }
        }
      } catch (e) {
        dev.log('Error handling chat event: $e', name: 'QuestionChat', error: e);
      }
    });
  }

  void _handleJoinedQuestion(dynamic data) {
    dev.log('✅ Successfully joined question', name: 'QuestionChat');
  }

  void _handleAllMessagesLoaded(dynamic data) {
    try {
      if (data is Map) {
        final messages = data['Messages'] ?? data['messages'];
        if (messages is List) {
          final messageList = messages
              .map((m) => QuestionMessage.fromJson(m as Map<String, dynamic>))
              .toList();

          // Sort by date (oldest first)
          messageList.sort((a, b) => a.sentAt.compareTo(b.sentAt));

          _messagesController.add(messageList);
          dev.log('📥 Loaded ${messageList.length} messages', name: 'QuestionChat');
        }
      }
    } catch (e) {
      dev.log('Error parsing all messages: $e', name: 'QuestionChat', error: e);
    }
  }

  void _handleNewMessage(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        final message = QuestionMessage.fromJson(data);
        _newMessageController.add(message);
        dev.log('📩 New message received: ${message.id}', name: 'QuestionChat');
      } else if (data is List && data.isNotEmpty) {
        final message = QuestionMessage.fromJson(data[0] as Map<String, dynamic>);
        _newMessageController.add(message);
        dev.log('📩 New message received: ${message.id}', name: 'QuestionChat');
      }
    } catch (e) {
      dev.log('Error parsing new message: $e', name: 'QuestionChat', error: e);
    }
  }

  void _handleMessageDeleted(dynamic data) {
    try {
      String? messageId;

      if (data is Map<String, dynamic>) {
        messageId = data['MessageId'] ?? data['messageId'];
      } else if (data is List && data.isNotEmpty && data[0] is Map) {
        final map = data[0] as Map<String, dynamic>;
        messageId = map['MessageId'] ?? map['messageId'];
      } else if (data is String) {
        messageId = data;
      }

      if (messageId != null) {
        _messageDeletedController.add(messageId);
        dev.log('🗑️ Message deleted: $messageId', name: 'QuestionChat');
      }
    } catch (e) {
      dev.log('Error handling message deletion: $e', name: 'QuestionChat', error: e);
    }
  }

  void _handleMessageUpdated(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        final messageId = data['MessageId'] ?? data['messageId'];
        final newContent = data['NewContent'] ?? data['newContent'];

        if (messageId != null && newContent != null) {
          // Create updated message object
          final updatedMessage = QuestionMessage(
            id: messageId,
            content: newContent,
            senderId: data['UpdatedBy'] ?? data['updatedBy'] ?? '',
            senderName: '',
            questionId: _currentQuestionId ?? '',
            contentType: 0, // MessageContentType.text = 0
            sentAt: DateTime.now(),
            editedAt: DateTime.now(),
            reactions: [],
          );

          _messageUpdatedController.add(updatedMessage);
          dev.log('✏️ Message updated: $messageId', name: 'QuestionChat');
        }
      }
    } catch (e) {
      dev.log('Error handling message update: $e', name: 'QuestionChat', error: e);
    }
  }

  void _handleUserTyping(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        final userId = data['UserId'] ?? data['userId'];
        final isTyping = data['IsTyping'] ?? data['isTyping'] ?? false;

        // You can implement typing indicator logic here
        dev.log('⌨️ User $userId typing: $isTyping', name: 'QuestionChat');
      }
    } catch (e) {
      dev.log('Error handling typing: $e', name: 'QuestionChat', error: e);
    }
  }

  void _handleOnlineUsers(dynamic data) {
    try {
      if (data is List) {
        final userIds = data.cast<String>();
        _onlineUsersController.add(userIds);
        dev.log('👥 Online users: ${userIds.length}', name: 'QuestionChat');
      }
    } catch (e) {
      dev.log('Error handling online users: $e', name: 'QuestionChat', error: e);
    }
  }

  void _handleUserJoined(dynamic data) {
    try {
      if (data is List && data.isNotEmpty) {
        final payload = data[0] as Map<String, dynamic>;
        _userJoinedController.add(payload);
        dev.log('👋 User joined: ${payload['userName']}', name: 'QuestionChat');
      } else if (data is Map<String, dynamic>) {
        _userJoinedController.add(data);
        dev.log('👋 User joined: ${data['userName']}', name: 'QuestionChat');
      }
    } catch (e) {
      dev.log('Error handling user joined: $e', name: 'QuestionChat', error: e);
    }
  }

  void _handleUserLeft(dynamic data) {
    try {
      if (data is List && data.isNotEmpty) {
        final payload = data[0] as Map<String, dynamic>;
        _userLeftController.add(payload);
        dev.log('👋 User left: ${payload['userId']}', name: 'QuestionChat');
      } else if (data is Map<String, dynamic>) {
        _userLeftController.add(data);
        dev.log('👋 User left: ${data['userId']}', name: 'QuestionChat');
      }
    } catch (e) {
      dev.log('Error handling user left: $e', name: 'QuestionChat', error: e);
    }
  }

  void _handleMessageReaction(dynamic data) {
    dev.log('👍 Reaction added', name: 'QuestionChat');
  }

  // ✅ NEW: Handle previous messages (pagination)
  void _handlePreviousMessages(dynamic data) {
    try {
      if (data is List && data.isNotEmpty) {
        final payload = data[0] as Map<String, dynamic>;
        final messages = payload['messages'] as List?;
        final page = payload['page'] as int?;
        final hasMore = payload['hasMore'] as bool?;

        if (messages != null) {
          final messageList = messages
              .map((m) => QuestionMessage.fromJson(m as Map<String, dynamic>))
              .toList();

          _previousMessagesController.add({
            'messages': messageList,
            'page': page,
            'hasMore': hasMore ?? false,
          });

          dev.log('📥 Previous messages loaded: ${messageList.length} messages, page: $page',
              name: 'QuestionChat');
        }
      }
    } catch (e) {
      dev.log('Error handling previous messages: $e', name: 'QuestionChat', error: e);
    }
  }

  // ✅ NEW: Handle user online status change
  void _handleUserOnlineStatus(dynamic data) {
    try {
      if (data is List && data.isNotEmpty) {
        final payload = data[0] as Map<String, dynamic>;
        _userOnlineStatusController.add(payload);
        dev.log(
          '🟢 User ${payload['userId']} is ${payload['isOnline'] ? 'online' : 'offline'}',
          name: 'QuestionChat',
        );
      } else if (data is Map<String, dynamic>) {
        _userOnlineStatusController.add(data);
        dev.log(
          '🟢 User ${data['userId']} is ${data['isOnline'] ? 'online' : 'offline'}',
          name: 'QuestionChat',
        );
      }
    } catch (e) {
      dev.log('Error handling user online status: $e', name: 'QuestionChat', error: e);
    }
  }

  // ✅ NEW: Handle user activity (LastSeen)
  void _handleUserActivity(dynamic data) {
    try {
      if (data is List && data.isNotEmpty) {
        final payload = data[0] as Map<String, dynamic>;
        _userActivityController.add(payload);
        dev.log('⏰ User activity: ${payload['userId']} - ${payload['action']}',
            name: 'QuestionChat');
      } else if (data is Map<String, dynamic>) {
        _userActivityController.add(data);
        dev.log('⏰ User activity: ${data['userId']} - ${data['action']}',
            name: 'QuestionChat');
      }
    } catch (e) {
      dev.log('Error handling user activity: $e', name: 'QuestionChat', error: e);
    }
  }

  void _handleError(dynamic data) {
    final errorMessage = data is String ? data : data.toString();
    dev.log('❌ Server error: $errorMessage', name: 'QuestionChat', error: errorMessage);
  }

  // ==================== Chat Operations ====================

  /// Join a question's chat room
  Future<void> joinQuestion(String questionId) async {
    try {
      if (!_signalR.isConnected) {
        await _signalR.connect();
      }

      _currentQuestionId = questionId;
      await _signalR.joinQuestion(questionId);
      dev.log('Joined question: $questionId', name: 'QuestionChat');
    } catch (e) {
      dev.log('Error joining question: $e', name: 'QuestionChat', error: e);
      rethrow;
    }
  }

  /// Leave a question's chat room
  Future<void> leaveQuestion(String questionId) async {
    try {
      await _signalR.leaveQuestion(questionId);
      if (_currentQuestionId == questionId) {
        _currentQuestionId = null;
      }
      dev.log('Left question: $questionId', name: 'QuestionChat');
    } catch (e) {
      dev.log('Error leaving question: $e', name: 'QuestionChat', error: e);
      rethrow;
    }
  }

  /// Send a text message
  Future<void> sendMessage({
    required String questionId,
    required String content,
    String? replyToMessageId,
  }) async {
    try {
      await _signalR.sendTextMessage(
        questionId,
        content,
        replyToMessageId: replyToMessageId,
      );
      dev.log('Message sent to question: $questionId', name: 'QuestionChat');
    } catch (e) {
      dev.log('Error sending message: $e', name: 'QuestionChat', error: e);
      rethrow;
    }
  }

  /// Send a message with file
  Future<void> sendMessageWithFile({
    required String questionId,
    required String content,
    required String fileData,
    required String fileName,
    required String fileType,
    bool isAudio = false,
    String? replyToMessageId,
  }) async {
    try {
      await _signalR.sendMessageWithFile(
        questionId: questionId,
        content: content,
        fileData: fileData,
        fileName: fileName,
        fileType: fileType,
        isAudio: isAudio,
        replyToMessageId: replyToMessageId,
      );
      dev.log('File message sent to question: $questionId', name: 'QuestionChat');
    } catch (e) {
      dev.log('Error sending file message: $e', name: 'QuestionChat', error: e);
      rethrow;
    }
  }

  /// Delete a message
  Future<void> deleteMessage({
    required String questionId,
    required String messageId,
  }) async {
    try {
      await _signalR.deleteMessage(questionId, messageId);
      dev.log('Message deleted: $messageId', name: 'QuestionChat');
    } catch (e) {
      dev.log('Error deleting message: $e', name: 'QuestionChat', error: e);
      rethrow;
    }
  }

  /// Update/edit a message
  Future<void> updateMessage({
    required String questionId,
    required String messageId,
    required String newContent,
  }) async {
    try {
      await _signalR.updateMessage(questionId, messageId, newContent);
      dev.log('Message updated: $messageId', name: 'QuestionChat');
    } catch (e) {
      dev.log('Error updating message: $e', name: 'QuestionChat', error: e);
      rethrow;
    }
  }

  /// Send typing indicator
  Future<void> sendTypingIndicator({
    required String questionId,
    required bool isTyping,
  }) async {
    try {
      await _signalR.sendTypingIndicator(questionId, isTyping);
    } catch (e) {
      dev.log('Error sending typing indicator: $e', name: 'QuestionChat', error: e);
    }
  }

  /// React to a message
  Future<void> reactToMessage({
    required String questionId,
    required String messageId,
    required String reaction,
  }) async {
    try {
      await _signalR.reactToMessage(questionId, messageId, reaction);
      dev.log('Reacted to message: $messageId', name: 'QuestionChat');
    } catch (e) {
      dev.log('Error reacting to message: $e', name: 'QuestionChat', error: e);
      rethrow;
    }
  }

  /// Get messages via API (fallback or initial load)
  Future<List<QuestionMessage>> getMessagesViaApi(String questionId) async {
    try {
      final response = await _apiService.getQuestionMessages(questionId);
      return response.data;
    } catch (e) {
      dev.log('Error getting messages via API: $e', name: 'QuestionChat', error: e);
      rethrow;
    }
  }

  // ✅ NEW: Get previous messages via SignalR (Pagination)
  Future<void> getPreviousMessages({
    required String questionId,
    required int page,
    int pageSize = 50,
  }) async {
    try {
      await _signalR.getPreviousMessages(
        questionId: questionId,
        page: page,
        pageSize: pageSize,
      );
      dev.log('📥 Requested previous messages: page $page', name: 'QuestionChat');
    } catch (e) {
      dev.log('Error requesting previous messages: $e', name: 'QuestionChat', error: e);
      rethrow;
    }
  }

  // ✅ NEW: Update last seen
  Future<void> updateLastSeen(String questionId) async {
    try {
      await _signalR.updateLastSeen(questionId);
      dev.log('✅ Last seen updated for question: $questionId', name: 'QuestionChat');
    } catch (e) {
      dev.log('Error updating last seen: $e', name: 'QuestionChat', error: e);
    }
  }

  /// Check if connected
  bool get isConnected => _signalR.isConnected;

  /// Disconnect
  Future<void> disconnect() async {
    if (_currentQuestionId != null) {
      await leaveQuestion(_currentQuestionId!);
    }
    await _signalR.disconnect();
    _isInitialized = false;
  }

  /// Dispose resources
  void dispose() {
    _messagesController.close();
    _newMessageController.close();
    _messageDeletedController.close();
    _messageUpdatedController.close();
    _typingUsersController.close();
    _onlineUsersController.close();
    _previousMessagesController.close(); // ✅ NEW
    _userJoinedController.close(); // ✅ NEW
    _userLeftController.close(); // ✅ NEW
    _userOnlineStatusController.close(); // ✅ NEW
    _userActivityController.close(); // ✅ NEW
  }
}
