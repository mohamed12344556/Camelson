import 'dart:async';
import 'dart:developer';
import 'package:camelson/core/api/api_constants.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../api/token_manager.dart';

class SignalRService {
  HubConnection? _hubConnection;
  final _messageReceivedController = StreamController<dynamic>.broadcast();
  final _connectionStateController =
      StreamController<HubConnectionState>.broadcast();

  Stream<dynamic> get onMessageReceived => _messageReceivedController.stream;
  Stream<HubConnectionState> get onConnectionStateChanged =>
      _connectionStateController.stream;

  bool get isConnected => _hubConnection?.state == HubConnectionState.Connected;

  Future<void> connect() async {
    if (isConnected) return;

    try {
      // ✅ Use hardcoded URL or from config
      final hubUrl = ApiConstants.communityHubUrl;

      log('🔌 SignalR: Connecting to $hubUrl', name: 'SignalRService');

      _hubConnection = HubConnectionBuilder()
          .withUrl(
            hubUrl,
            options: HttpConnectionOptions(
              accessTokenFactory: () async {
                final currentToken = await _getToken();
                log(
                  'SignalR: accessTokenFactory providing token (length: ${currentToken?.length ?? 0})',
                  name: 'SignalRService',
                );
                return currentToken ?? ''; // ✅ Return empty string if null
              },
            ),
          )
          .withAutomaticReconnect()
          .build();

      _setupEventHandlers();

      await _hubConnection!.start();
      log('✅ SignalR: Connected Successfully', name: 'SignalRService');

      _connectionStateController.add(HubConnectionState.Connected);
    } catch (e, stackTrace) {
      log('❌ SignalR: Connection failed: $e', name: 'SignalRService');
      log('SignalR connection error', error: e, stackTrace: stackTrace);
      _connectionStateController.add(HubConnectionState.Disconnected);
      rethrow;
    }
  }

  Future<String?> _getToken() async {
    try {
      final tokens = await TokenManager.getTokens();
      final token = tokens?.accessToken;

      if (token != null && token.isNotEmpty) {
        log(
          'SignalR: Token Retrieved (Present - Length: ${token.length})',
          name: 'SignalRService',
        );
      } else {
        log(
          '⚠️ SignalR: No token found in secure storage',
          name: 'SignalRService',
        );
      }

      return token;
    } catch (e) {
      log('❌ SignalR: Error retrieving token: $e', name: 'SignalRService');
      return null;
    }
  }

  void _setupEventHandlers() {
    // ✅ Fixed: Use proper callback types
    _hubConnection!.onclose(({error}) {
      log('🔴 SignalR: Connection closed: $error', name: 'SignalRService');
      _connectionStateController.add(HubConnectionState.Disconnected);
    });

    _hubConnection!.onreconnecting(({error}) {
      log('🔄 SignalR: Reconnecting...', name: 'SignalRService');
      _connectionStateController.add(HubConnectionState.Reconnecting);
    });

    _hubConnection!.onreconnected(({connectionId}) {
      log(
        '✅ SignalR: Reconnected with ID: $connectionId',
        name: 'SignalRService',
      );
      _connectionStateController.add(HubConnectionState.Connected);
    });

    // Listen to all events
    final eventNames = [
      'AllMessagesLoaded',
      'NewMessage',
      'MessageDeleted',
      'MessageUpdated',
      'MessageReacted',
      'UserTyping',
      'JoinedQuestion',
      'OnlineUsers',
      'MessageCountUpdated',
      'PreviousMessages', // ✅ NEW: Pagination
      'UserJoinedQuestion', // ✅ NEW: User joined
      'UserLeft', // ✅ NEW: User left
      'UserOnlineStatus', // ✅ NEW: Online status change
      'UserActivity', // ✅ NEW: User activity (LastSeen)
    ];

    for (final eventName in eventNames) {
      _hubConnection!.on(eventName, (args) {
        log('📨 SignalR: Event "$eventName"', name: 'SignalRService');
        _messageReceivedController.add({'type': eventName, 'data': args});
      });
    }
  }

  void ensureConnected() {
    if (!isConnected) {
      throw Exception('SignalR not connected. Call connect() first.');
    }
  }

  // ✅ Join question room
  Future<void> joinQuestion(String questionId) async {
    ensureConnected();
    try {
      log(
        'SignalR: Invoking JoinQuestion with args: [$questionId]',
        name: 'SignalRService',
      );
      await _hubConnection!.invoke('JoinQuestion', args: [questionId]);
      log('SignalR: Joined Question ($questionId)', name: 'SignalRService');
    } catch (e) {
      log('❌ SignalR: Error joining question: $e', name: 'SignalRService');
      rethrow;
    }
  }

  // ✅ Leave question room
  Future<void> leaveQuestion(String questionId) async {
    ensureConnected();
    try {
      await _hubConnection!.invoke('LeaveQuestion', args: [questionId]);
      log('SignalR: Left Question ($questionId)', name: 'SignalRService');
    } catch (e) {
      log('❌ SignalR: Error leaving question: $e', name: 'SignalRService');
    }
  }

  // ✅ Send text message
  Future<void> sendTextMessage(
    String questionId,
    String content, {
    String? replyToMessageId,
  }) async {
    ensureConnected();

    try {
      log(
        '📤 Sending text message to question: $questionId',
        name: 'SignalRService',
      );
      log('   Content: $content', name: 'SignalRService');
      if (replyToMessageId != null) {
        log('   Reply to: $replyToMessageId', name: 'SignalRService');
      }

      // ✅ Must send ALL 7 parameters to match C# method signature
      await _hubConnection!.invoke(
        'SendMessage',
        args: <Object>[
          questionId, // Required
          content, // Required
          replyToMessageId ?? '',
          '',
          '',
          '',
          false,
        ],
      );

      log('✅ Text message sent successfully', name: 'SignalRService');
    } catch (e) {
      log('❌ Error sending text message: $e', name: 'SignalRService');
      rethrow;
    }
  }

  // ✅ Send message with file
  Future<void> sendMessageWithFile({
    required String questionId,
    required String content,
    required String fileData,
    required String fileName,
    required String fileType,
    required bool isAudio,
    String? replyToMessageId,
  }) async {
    ensureConnected();

    try {
      log('📤 Sending file message:', name: 'SignalRService');
      log('   - Question: $questionId', name: 'SignalRService');
      log('   - Content: $content', name: 'SignalRService');
      log('   - File: $fileName ($fileType)', name: 'SignalRService');
      log('   - Is Audio: $isAudio', name: 'SignalRService');

      await _hubConnection!.invoke(
        'SendMessage',
        args: <Object>[
          questionId, // 1: questionId
          content, // 2: content
          replyToMessageId ?? "", // 3: replyToMessageId (can be null)
          fileData, // 4: fileData
          fileName, // 5: fileName
          fileType, // 6: fileType
          isAudio, // 7: isAudio
        ],
      );

      log('✅ File message sent', name: 'SignalRService');
    } catch (e) {
      log('❌ Error sending file message: $e', name: 'SignalRService');
      rethrow;
    }
  }

  // ✅ Delete message
  Future<void> deleteMessage(String questionId, String messageId) async {
    ensureConnected();

    try {
      log('🗑️ Deleting message: $messageId', name: 'SignalRService');

      await _hubConnection!.invoke(
        'DeleteMessage',
        args: [questionId, messageId],
      );

      log('✅ Message deleted', name: 'SignalRService');
    } catch (e) {
      log('❌ Error deleting message: $e', name: 'SignalRService');
      rethrow;
    }
  }

  // ✅ Update message
  Future<void> updateMessage(
    String questionId,
    String messageId,
    String newContent,
  ) async {
    ensureConnected();

    try {
      log('✏️ Updating message: $messageId', name: 'SignalRService');

      await _hubConnection!.invoke(
        'UpdateMessage',
        args: [questionId, messageId, newContent],
      );

      log('✅ Message updated', name: 'SignalRService');
    } catch (e) {
      log('❌ Error updating message: $e', name: 'SignalRService');
      rethrow;
    }
  }

  // ✅ React to message
  Future<void> reactToMessage(
    String questionId,
    String messageId,
    String reaction,
  ) async {
    ensureConnected();

    try {
      log(
        '👍 Reacting to message: $messageId with $reaction',
        name: 'SignalRService',
      );

      await _hubConnection!.invoke(
        'ReactToMessage',
        args: [questionId, messageId, reaction],
      );

      log('✅ Reaction sent', name: 'SignalRService');
    } catch (e) {
      log('❌ Error sending reaction: $e', name: 'SignalRService');
      rethrow;
    }
  }

  // ✅ NEW: Remove reaction from message
  /// Remove reaction from message
  Future<void> removeReaction(
    String messageId,
    String userId, // ✅ استخدم userId بدلاً من roomId
  ) async {
    ensureConnected();

    try {
      log(
        '🗑️ SignalR: Removing reaction from message: $messageId',
        name: 'SignalRService',
      );

      await _hubConnection!.invoke(
        'RemoveReaction',
        args: [
          messageId,
          userId, // ✅ الترتيب الصحيح
        ],
      );

      log('✅ SignalR: Reaction removed successfully', name: 'SignalRService');
    } catch (e) {
      log('❌ SignalR: Error removing reaction: $e', name: 'SignalRService');
      rethrow;
    }
  }

  // ✅ Mark message as read
  Future<void> markAsRead(String questionId, String messageId) async {
    ensureConnected();

    try {
      await _hubConnection!.invoke('MarkAsRead', args: [questionId, messageId]);
    } catch (e) {
      log('❌ Error marking message as read: $e', name: 'SignalRService');
    }
  }

  // ✅ Send typing indicator
  Future<void> sendTypingIndicator(String questionId, bool isTyping) async {
    if (!isConnected) return;

    try {
      await _hubConnection!.invoke('Typing', args: [questionId, isTyping]);
    } catch (e) {
      log('❌ Error sending typing indicator: $e', name: 'SignalRService');
    }
  }

  // ✅ NEW: Get previous messages (Pagination)
  Future<void> getPreviousMessages({
    required String questionId,
    required int page,
    required int pageSize,
  }) async {
    ensureConnected();

    try {
      log(
        '📥 Getting previous messages: page=$page, size=$pageSize',
        name: 'SignalRService',
      );

      await _hubConnection!.invoke(
        'GetPreviousMessages',
        args: [questionId, page, pageSize],
      );

      log('✅ Previous messages request sent', name: 'SignalRService');
    } catch (e) {
      log('❌ Error getting previous messages: $e', name: 'SignalRService');
      rethrow;
    }
  }

  // ✅ NEW: Update last seen
  Future<void> updateLastSeen(String questionId) async {
    if (!isConnected) return;

    try {
      await _hubConnection!.invoke('UpdateLastSeen', args: [questionId]);
      log('✅ Last seen updated', name: 'SignalRService');
    } catch (e) {
      log('❌ Error updating last seen: $e', name: 'SignalRService');
    }
  }

  Future<void> disconnect() async {
    try {
      await _hubConnection?.stop();
      log('🔴 SignalR: Disconnected', name: 'SignalRService');
    } catch (e) {
      log('❌ SignalR: Error disconnecting: $e', name: 'SignalRService');
    }
  }

  void dispose() {
    _messageReceivedController.close();
    _connectionStateController.close();
    disconnect();
  }
}
