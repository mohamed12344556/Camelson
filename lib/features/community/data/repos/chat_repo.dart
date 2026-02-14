import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;

import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../../core/core.dart';
import '../../../../core/services/signalr_service.dart';
import '../../ui/logic/chat_bloc/chat_event.dart';
import '../../utils/question_to_room_adapter.dart';
import '../models/community_constants.dart';
import '../models/message.dart';
import '../models/message_attachment.dart';
import '../models/message_reaction.dart';
import '../models/question.dart';
import '../models/room.dart';
import '../models/user.dart';
import '../services/question_service.dart';

class ChatRepository {
  final SignalRService _signalRService;
  Box<Map>? _messagesBox;
  Box<Map>? _roomsBox;
  bool _isInitialized = false;

  // Stream controllers
  final _messageStreamController = StreamController<Message>.broadcast();
  final _messageDeletedStreamController =
      StreamController<String>.broadcast(); // messageId
  final _messageUpdatedStreamController = StreamController<Message>.broadcast();
  final _connectionStreamController =
      StreamController<ConnectionStatus>.broadcast();
  final _typingStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  Completer<List<Message>>?
  _allMessagesLoadedCompleter; // ✅ Make nullable to reset
  final _reactionStreamController = StreamController.broadcast();

  // Streams
  Stream<Message> get messageStream => _messageStreamController.stream;
  Stream<ConnectionStatus> get connectionStream =>
      _connectionStreamController.stream;
  Stream<Map<String, dynamic>> get typingStream =>
      _typingStreamController.stream;
  Stream<String> get messageDeletedStream =>
      _messageDeletedStreamController.stream;
  Stream<Message> get messageUpdatedStream =>
      _messageUpdatedStreamController.stream;
  Stream get reactionStream => _reactionStreamController.stream;

  ChatRepository({SignalRService? signalRService})
    : _signalRService = signalRService ?? SignalRService();

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Initialize Hive boxes with proper error handling
      _messagesBox = await sl.getAsync<Box<Map>>(
        instanceName: 'chat_messages_box',
      );
      _roomsBox = await sl.getAsync<Box<Map>>(instanceName: 'chat_rooms_box');

      // Setup WebSocket listeners
      _setupWebSocketListeners();

      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize ChatRepository: $e');
    }
  }

  void _ensureInitialized() {
    if (!_isInitialized || _messagesBox == null || _roomsBox == null) {
      throw Exception('ChatRepository not initialized. Call init() first.');
    }
  }

  // Connection Methods
  Future<void> connect(String userId) async {
    _ensureInitialized();
    await _signalRService.connect();
    _connectionStreamController.add(ConnectionStatus.connected);
  }

  Future<void> disconnect() async {
    _ensureInitialized();
    await _signalRService.disconnect();
    _connectionStreamController.add(ConnectionStatus.disconnected);
  }

  Future<void> joinRoom(String roomId) async {
    _ensureInitialized();

    // ✅ Reset completer for new join
    _allMessagesLoadedCompleter = Completer<List<Message>>();

    await _signalRService.joinQuestion(roomId);
  }

  Future<void> leaveRoom(String roomId) async {
    _ensureInitialized();
    try {
      log('🚪 Repository: Leaving room $roomId', name: 'ChatRepository');
      await _signalRService.leaveQuestion(roomId);
      log('✅ Repository: Left room successfully', name: 'ChatRepository');
    } catch (e) {
      log('❌ Repository: Error leaving room: $e', name: 'ChatRepository');
      rethrow;
    }
  }

  // Room Methods
  Future<Room?> getRoom(String roomId) async {
    _ensureInitialized();
    try {
      // Check cache first
      final cachedRoom = _roomsBox!.get(roomId);
      if (cachedRoom != null) {
        return Room.fromJson(Map<String, dynamic>.from(cachedRoom));
      }

      // Fetch Question from API and convert to Room
      final questionService = QuestionService();
      final question = await questionService.getQuestionById(roomId);
      final room = QuestionToRoomAdapter.questionToRoom(question);

      // Cache the room
      await _roomsBox!.put(roomId, room.toJson());

      return room;
    } catch (e) {
      throw Exception('Failed to get room: $e');
    }
  }

  // Message Methods
  Future<List<Message>> getMessages({
    required String roomId,
    required int page,
    required int limit,
  }) async {
    _ensureInitialized();
    try {
      // In production, this would make an API call with pagination
      // For now, return cached messages only
      final cachedMessages = <Message>[];

      for (final key in _messagesBox!.keys) {
        final messageData = _messagesBox!.get(key);
        if (messageData != null) {
          final message = Message.fromJson(
            Map<String, dynamic>.from(messageData),
          );
          if (message.roomId == roomId) {
            cachedMessages.add(message);
          }
        }
      }

      // Sort by timestamp (newest first)
      cachedMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Apply pagination
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;

      if (startIndex >= cachedMessages.length) {
        return [];
      }

      return cachedMessages.sublist(
        startIndex,
        endIndex > cachedMessages.length ? cachedMessages.length : endIndex,
      );
    } catch (e) {
      throw Exception('Failed to get messages: $e');
    }
  }

  Future<Message> sendMessage({
    required String roomId,
    required String content,
    List<MessageAttachment>? attachments,
    String? replyToId,
  }) async {
    _ensureInitialized();

    try {
      // Check if there are attachments
      if (attachments != null && attachments.isNotEmpty) {
        // Send as file
        await _sendMessageWithAttachment(
          roomId: roomId,
          content: content,
          attachment: attachments.first,
          replyToId: replyToId,
        );
      } else {
        // Send as text ONLY
        if (content.trim().isEmpty) {
          throw Exception('Message content cannot be empty');
        }

        log(
          '📤 Sending text message to question: $roomId',
          name: 'ChatRepository',
        );
        log('   Content: ${content.trim()}...', name: 'ChatRepository');

        await _signalRService.sendTextMessage(
          roomId,
          content.trim(),
          replyToMessageId: replyToId,
        );

        log('✅ Text message sent successfully', name: 'ChatRepository');
      }

      // ✅ Return a dummy message - the real message will come via SignalR NewMessage event
      // Queue Manager and ChatBloc will handle the optimistic UI
      final message = Message(
        id: 'temp_sent_${DateTime.now().millisecondsSinceEpoch}',
        roomId: roomId,
        userId: CommunityConstants.currentUser.id,
        content: content,
        isQuestion: false,
        timestamp: DateTime.now(),
        attachments: attachments,
        reactions: [],
        replyToId: replyToId,
        xpEarned: 10,
        user: CommunityConstants.currentUser,
      );

      log(
        '✅ Message sent, waiting for server confirmation via SignalR',
        name: 'ChatRepository',
      );

      return message;
    } catch (e) {
      log('❌ Error in sendMessage: $e', name: 'ChatRepository');
      throw Exception('Failed to send message: $e');
    }
  }

  // ✅ Helper method للملفات
  Future<void> _sendMessageWithAttachment({
    required String roomId,
    required String content,
    required MessageAttachment attachment,
    String? replyToId,
  }) async {
    try {
      final file = File(attachment.url); // Local path

      if (!await file.exists()) {
        throw Exception('File not found: ${attachment.url}');
      }

      // Read file as bytes
      final bytes = await file.readAsBytes();
      final base64Data = base64Encode(bytes);

      // Determine file type
      String fileType;
      bool isAudio = false;

      switch (attachment.type) {
        case AttachmentType.image:
          fileType = 'image/${attachment.fileName.split('.').last}';
          break;
        case AttachmentType.audio:
          fileType = 'audio/webm';
          isAudio = true;
          break;
        case AttachmentType.video:
          fileType = 'video/mp4';
          break;
        case AttachmentType.pdf:
          fileType = 'application/pdf';
          break;
        default:
          fileType = 'application/octet-stream';
      }

      log('📎 Sending file:', name: 'ChatRepository');
      log('  Type: $fileType', name: 'ChatRepository');
      log('  Name: ${attachment.fileName}', name: 'ChatRepository');
      log('  Size: ${bytes.length} bytes', name: 'ChatRepository');
      log('  Base64 length: ${base64Data.length}', name: 'ChatRepository');

      // Send via SignalR
      await _signalRService.sendMessageWithFile(
        questionId: roomId,
        content: content.isEmpty ? attachment.fileName : content,
        fileData: base64Data,
        fileName: attachment.fileName,
        fileType: fileType,
        isAudio: isAudio,
        replyToMessageId: replyToId,
      );

      log('✅ File sent successfully', name: 'ChatRepository');
    } catch (e) {
      log('❌ Error sending file: $e', name: 'ChatRepository');
      rethrow;
    }
  }

  // Future<Message> sendQuestion({
  //   required String roomId,
  //   required String content,
  //   required String subject,
  //   required String grade,
  //   List<MessageAttachment>? attachments,
  // }) async {
  //   _ensureInitialized();
  //   try {
  //     // Create question message
  //     final message = Message(
  //       id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
  //       roomId: roomId,
  //       userId: CommunityConstants.currentUser.id,
  //       content: content,
  //       isQuestion: true,
  //       timestamp: DateTime.now(),
  //       attachments: attachments,
  //       reactions: [],
  //       replyToId: null,
  //       xpEarned: 5,
  //       user: CommunityConstants.currentUser,
  //     );

  //     // Send via SignalR
  //     await _signalRService.sendMessage('SendQuestion', [
  //       roomId,
  //       content,
  //       subject,
  //       grade,
  //       CommunityConstants.currentUser.id,
  //       attachments?.map((a) => a.url).toList() ?? [],
  //     ]);

  //     // Cache message
  //     await _messagesBox!.put(message.id, message.toJson());

  //     // Simulate receiving the message
  //     Timer(const Duration(milliseconds: 500), () {
  //       _messageStreamController.add(message);
  //     });

  //     return message;
  //   } catch (e) {
  //     throw Exception('Failed to send question: $e');
  //   }
  // }

  Future<Message> sendQuestion({
    required String roomId,
    required String content,
    required String subject,
    required String grade,
    List<MessageAttachment>? attachments,
  }) async {
    _ensureInitialized();
    try {
      // ❌ Backend doesn't have 'SendQuestion' method!
      // You need to create the question via REST API first

      // Option 1: Just send as regular message
      return await sendMessage(
        roomId: roomId,
        content: content,
        attachments: attachments,
      );

      // Option 2: Create question via REST API first (recommended)
      // See below for implementation
    } catch (e) {
      throw Exception('Failed to send question: $e');
    }
  }

  // Reaction Methods
  // ✅ Update addReaction method
  Future<void> addReaction(
    String roomId,
    String messageId,
    ReactionType type,
  ) async {
    _ensureInitialized();
    try {
      // Convert ReactionType to string
      final reactionString = type.toString().split('.').last;

      log(
        '👍 Sending reaction: $reactionString for message $messageId',
        name: 'ChatRepository',
      );

      await _signalRService.reactToMessage(roomId, messageId, reactionString);
    } catch (e) {
      throw Exception('Failed to add reaction: $e');
    }
  }

  /// Remove reaction from message
  /// ✅ Remove reaction from message
  Future<void> removeReaction(
    String roomId,
    String messageId,
    ReactionType type,
  ) async {
    _ensureInitialized();

    try {
      // Convert ReactionType to string
      final reactionString = type.toString().split('.').last;

      log(
        '🗑️ Removing reaction: $reactionString from message: $messageId',
        name: 'ChatRepository',
      );

      // ✅ Call SignalR RemoveReaction method with correct parameters
      // Backend expects: RemoveReaction(messageId, userId)
      await _signalRService.removeReaction(
        messageId,
        CommunityConstants.currentUser.id,
      );

      log('✅ Reaction removed successfully', name: 'ChatRepository');
    } catch (e) {
      log('❌ Error removing reaction: $e', name: 'ChatRepository');
      throw Exception('Failed to remove reaction: $e');
    }
  }

  // User Methods
  Future<List<User>> getUsers(List<String> userIds) async {
    _ensureInitialized();
    try {
      // In production, this would make an API call to get user details
      // For now, return empty list
      return [];
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  // Message Status Methods
  Future<void> deleteMessage(String roomId, String messageId) async {
    _ensureInitialized();
    try {
      await _signalRService.deleteMessage(roomId, messageId);
      await _messagesBox!.delete(messageId);
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  Future<void> updateMessage(
    String roomId,
    String messageId,
    String newContent,
  ) async {
    _ensureInitialized();
    try {
      await _signalRService.updateMessage(roomId, messageId, newContent);
    } catch (e) {
      throw Exception('Failed to update message: $e');
    }
  }

  Future<void> markMessagesAsRead(List<String> messageIds) async {
    _ensureInitialized();
    try {
      // In production, this would make an API call
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      // Silent fail
    }
  }

  // Attachment Methods
  // إصلاح دالة uploadAttachments في chat_repo.dart
  Future<List<MessageAttachment>> uploadAttachments(
    List<String> filePaths,
    String messageId,
  ) async {
    _ensureInitialized();
    try {
      final attachments = <MessageAttachment>[];

      for (final path in filePaths) {
        final file = File(path);
        final fileName = path.split('/').last;
        final fileSize = await file.length();

        // Determine file type
        AttachmentType type;
        if (path.endsWith('.pdf')) {
          type = AttachmentType.pdf;
        } else if (path.endsWith('.jpg') ||
            path.endsWith('.jpeg') ||
            path.endsWith('.png')) {
          type = AttachmentType.image;
        } else if (path.endsWith('.m4a') ||
            path.endsWith('.wav') ||
            path.endsWith('.mp3') ||
            path.endsWith('.aac')) {
          type = AttachmentType.audio;
        } else {
          type = AttachmentType.document;
        }

        // ** هنا الإصلاح الأساسي **
        // بدلاً من إنشاء URL وهمي، احفظ المسار المحلي مباشرة
        final attachment = MessageAttachment(
          id: 'att_${DateTime.now().millisecondsSinceEpoch}',
          messageId: messageId,
          fileName: fileName,
          url: path, // ✅ استخدم المسار المحلي مباشرة
          type: type,
          size: fileSize,
          uploadedAt: DateTime.now(),
        );

        log('📎 Created attachment:', name: 'ChatRepository'); // للتشخيص
        log('   ID: ${attachment.id}', name: 'ChatRepository');
        log('   Type: ${attachment.type}', name: 'ChatRepository');
        log('   Path: ${attachment.url}', name: 'ChatRepository');
        log('   Size: ${attachment.size} bytes', name: 'ChatRepository');

        attachments.add(attachment);
      }

      return attachments;
    } catch (e) {
      throw Exception('Failed to upload attachments: $e');
    }
  }

  // SignalR Event Handlers
  void _setupWebSocketListeners() {
    _signalRService.onMessageReceived.listen((data) {
      try {
        if (data is Map) {
          final type = data['type'];
          final eventData = data['data'];

          log('📨 SignalR Event: $type', name: 'ChatRepository');

          switch (type) {
            case 'AllMessagesLoaded':
              _handleAllMessagesLoaded(eventData);
              break;

            case 'NewMessage':
              _handleNewMessage(eventData);
              break;

            case 'MessageDeleted':
              _handleMessageDeleted(eventData);
              break;

            case 'MessageUpdated':
              _handleMessageUpdated(eventData);
              break;
            case 'MessageReacted': // ✅ Handle reaction event
              _handleMessageReacted(eventData);
              break;

            case 'UserTyping':
              _handleUserTyping(eventData); // ✅ Fixed
              break;

            case 'JoinedQuestion':
              log('✅ Joined question successfully', name: 'ChatRepository');
              break;

            case 'OnlineUsers':
              _handleOnlineUsers(eventData);
              break;

            case 'MessageCountUpdated':
              log(
                '📊 Message count updated: $eventData',
                name: 'ChatRepository',
              );
              break;

            default:
              log('⚠️ Unknown event type: $type', name: 'ChatRepository');
          }
        }
      } catch (e, stackTrace) {
        log(
          '❌ Error processing message',
          name: 'ChatRepository',
          error: e,
          stackTrace: stackTrace,
        );
      }
    });

    // Connection state events
    _signalRService.onConnectionStateChanged.listen((state) {
      switch (state.toString()) {
        case 'HubConnectionState.Connected':
          _connectionStreamController.add(ConnectionStatus.connected);
          break;
        case 'HubConnectionState.Disconnected':
          _connectionStreamController.add(ConnectionStatus.disconnected);
          break;
        case 'HubConnectionState.Reconnecting':
          _connectionStreamController.add(ConnectionStatus.connecting);
          break;
        default:
          _connectionStreamController.add(ConnectionStatus.connecting);
      }
    });
  }

  // ✅ Handle MessageDeleted event
  void _handleMessageDeleted(dynamic eventData) {
    try {
      log('🗑️ MessageDeleted received: $eventData', name: 'ChatRepository');

      String? messageId;
      if (eventData is List && eventData.isNotEmpty) {
        messageId = eventData[0] as String?;
      } else if (eventData is String) {
        messageId = eventData;
      } else if (eventData is Map) {
        messageId = eventData['messageId'] ?? eventData['MessageId'];
      }

      if (messageId != null) {
        log(
          '✅ Deleting message from cache: $messageId',
          name: 'ChatRepository',
        );
        _messagesBox?.delete(messageId);

        // ✅ Emit to stream so BLoC can update UI
        _messageDeletedStreamController.add(messageId);
        log('✅ MessageDeleted event sent to stream', name: 'ChatRepository');
      }
    } catch (e) {
      log('❌ Error handling MessageDeleted: $e', name: 'ChatRepository');
    }
  }

  // ✅ Handle MessageUpdated event
  Future<void> _handleMessageUpdated(dynamic eventData) async {
    try {
      log('✏️ MessageUpdated received: $eventData', name: 'ChatRepository');

      if (eventData is List && eventData.isNotEmpty) {
        final data = eventData[0];
        if (data is Map) {
          final jsonMap = Map<String, dynamic>.from(data);
          final updatedMessage = Message.fromJson(jsonMap);

          // Update in cache (no dedup needed for updates)
          if (_messagesBox != null) {
            await _messagesBox!.put(updatedMessage.id, updatedMessage.toJson());
          }

          // ✅ Send to dedicated update stream (not new message stream)
          _messageUpdatedStreamController.add(updatedMessage);
          log('✅ MessageUpdated event sent to stream', name: 'ChatRepository');
        }
      }
    } catch (e) {
      log('❌ Error handling MessageUpdated: $e', name: 'ChatRepository');
    }
  }

  // ✅ Add this new method
  void _handleUserTyping(dynamic eventData) {
    try {
      log(
        '⌨️ handleUserTyping called with: $eventData',
        name: 'ChatRepository',
      );

      if (eventData == null) return;

      Map<String, dynamic>? typingData;

      // Case 1: eventData is a List with one map
      if (eventData is List && eventData.isNotEmpty) {
        final firstItem = eventData[0];
        if (firstItem is Map) {
          typingData = Map<String, dynamic>.from(firstItem);
        }
      }
      // Case 2: eventData is directly a Map
      else if (eventData is Map) {
        typingData = Map<String, dynamic>.from(eventData);
      }

      if (typingData != null) {
        final userId = typingData['userId'] ?? typingData['UserId'];
        final isTyping =
            typingData['isTyping'] ?? typingData['IsTyping'] ?? true;

        log(
          '✅ User typing parsed: userId=$userId, isTyping=$isTyping',
          name: 'ChatRepository',
        );

        _typingStreamController.add({'userId': userId, 'isTyping': isTyping});
      } else {
        log('⚠️ Could not parse UserTyping data', name: 'ChatRepository');
      }
    } catch (e, stackTrace) {
      log('❌ Error handling UserTyping: $e', name: 'ChatRepository');
      log(
        'Stack trace: ${stackTrace.toString().split('\n').take(3).join('\n')}',
        name: 'ChatRepository',
      );
    }
  }

  void _handleOnlineUsers(dynamic eventData) {
    try {
      log(
        '👥 handleOnlineUsers called with: $eventData',
        name: 'ChatRepository',
      );

      if (eventData == null) return;

      List<String>? userIds;

      // Case 1: eventData is a List with another list inside
      if (eventData is List && eventData.isNotEmpty) {
        final firstItem = eventData[0];
        if (firstItem is List) {
          userIds = firstItem.cast<String>();
        } else if (firstItem is String) {
          userIds = eventData.cast<String>();
        }
      }

      if (userIds != null) {
        log('✅ Online users: ${userIds.length} users', name: 'ChatRepository');
        // You can add this to a stream if needed
      }
    } catch (e, stackTrace) {
      log('❌ Error handling OnlineUsers: $e', name: 'ChatRepository');
    }
  }

  Future<void> _handleAllMessagesLoaded(dynamic eventData) async {
    try {
      log('🔵 AllMessagesLoaded received', name: 'ChatRepository');

      if (eventData == null) {
        log('⚠️ eventData is null', name: 'ChatRepository');
        if (_allMessagesLoadedCompleter?.isCompleted == false) {
          _allMessagesLoadedCompleter!.complete([]);
        }
        return;
      }

      List<Message> messages = [];

      // FIXED: Handle the nested structure from SignalR
      if (eventData is List && eventData.isNotEmpty) {
        final firstArg = eventData[0];

        if (firstArg is Map) {
          final messagesData =
              firstArg['messages'] ??
              firstArg['Messages'] ??
              firstArg['data'] ??
              firstArg['Data'];

          if (messagesData is List) {
            log(
              '📦 Found ${messagesData.length} messages in nested structure',
              name: 'ChatRepository',
            );
            messages = _parseMessageList(messagesData);
          }
        }
      } else if (eventData is Map) {
        final messagesData =
            eventData['messages'] ??
            eventData['Messages'] ??
            eventData['data'] ??
            eventData['Data'];

        if (messagesData is List) {
          log(
            '📦 Found ${messagesData.length} messages in Map structure',
            name: 'ChatRepository',
          );
          messages = _parseMessageList(messagesData);
        }
      }

      log('✅ Parsed ${messages.length} messages', name: 'ChatRepository');

      // ✅ SAVE ALL MESSAGES TO CACHE with deduplication
      log(
        '💾 Saving ${messages.length} messages to cache...',
        name: 'ChatRepository',
      );
      int savedCount = 0;
      for (final message in messages) {
        if (await _saveMessageToCache(message)) {
          savedCount++;
        }
      }
      log(
        '✅ Saved $savedCount new messages to Hive cache (${messages.length - savedCount} already existed)',
        name: 'ChatRepository',
      );

      // Sort messages by date (oldest first)
      messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));

      // Complete the future
      if (_allMessagesLoadedCompleter?.isCompleted == false) {
        _allMessagesLoadedCompleter!.complete(messages);
      }

      log(
        '✅ Completed future with ${messages.length} messages',
        name: 'ChatRepository',
      );
    } catch (e, stackTrace) {
      log('❌ Error handling AllMessagesLoaded: $e', name: 'ChatRepository');
      log('   Stack trace: $stackTrace', name: 'ChatRepository');
      if (_allMessagesLoadedCompleter?.isCompleted == false) {
        _allMessagesLoadedCompleter!.completeError(e, stackTrace);
      }
    }
  }

  List<Message> _parseMessageList(List messagesData) {
    final messages = <Message>[];

    log(
      '🔄 Parsing ${messagesData.length} messages...',
      name: 'ChatRepository',
    );

    for (var i = 0; i < messagesData.length; i++) {
      try {
        final msgData = messagesData[i];

        if (msgData is Map) {
          // Convert to Map<String, dynamic> for proper JSON parsing
          final jsonMap = Map<String, dynamic>.from(msgData);
          final message = Message.fromJson(jsonMap);
          messages.add(message);
          log(
            '✅ [$i] Parsed message: ${message.id.substring(0, 8)}...',
            name: 'ChatRepository',
          );
        } else {
          log(
            '⚠️ [$i] Message data is not a Map: ${msgData.runtimeType}',
            name: 'ChatRepository',
          );
        }
      } catch (e, stackTrace) {
        log(
          '⚠️ [$i] Error parsing individual message: $e',
          name: 'ChatRepository',
        );
        log('   Data: ${messagesData[i]}', name: 'ChatRepository');
        log(
          '   Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}',
          name: 'ChatRepository',
        );
      }
    }

    log(
      '✅ Successfully parsed ${messages.length} out of ${messagesData.length} messages',
      name: 'ChatRepository',
    );
    return messages;
  }

  Future<void> _handleNewMessage(dynamic eventData) async {
    try {
      log(
        '🔔 ============ NEW MESSAGE EVENT RECEIVED ============',
        name: 'ChatRepository',
      );
      log(
        '📨 NewMessage received: ${eventData.toString().substring(0, min(100, eventData.toString().length))}...',
        name: 'ChatRepository',
      );

      if (eventData == null) {
        log('⚠️ NewMessage eventData is null', name: 'ChatRepository');
        return;
      }

      Message? message;

      // Case 1: eventData is a List with one message
      if (eventData is List && eventData.isNotEmpty) {
        log(
          '📋 eventData is a List with ${eventData.length} items',
          name: 'ChatRepository',
        );
        final msgData = eventData[0];
        if (msgData is Map) {
          final jsonMap = Map<String, dynamic>.from(msgData);
          message = Message.fromJson(jsonMap);
        }
      }
      // Case 2: eventData is directly a Map
      else if (eventData is Map) {
        log('📋 eventData is a Map', name: 'ChatRepository');
        final jsonMap = Map<String, dynamic>.from(eventData);
        message = Message.fromJson(jsonMap);
      }

      if (message != null) {
        log('✅ New message parsed successfully!', name: 'ChatRepository');
        log('   Message ID: ${message.id}', name: 'ChatRepository');
        log(
          '   Content: ${message.content.substring(0, min(50, message.content.length))}',
          name: 'ChatRepository',
        );
        log('   Sender ID: ${message.userId}', name: 'ChatRepository');
        log('   Room ID: ${message.roomId}', name: 'ChatRepository');
        log(
          '   Is from current user: ${message.userId == CommunityConstants.currentUser.id}',
          name: 'ChatRepository',
        );

        // ✅ SAVE TO CACHE HERE - with Backend ID and deduplication
        log(
          '💾 Saving message to cache: ${message.id}',
          name: 'ChatRepository',
        );
        await _saveMessageToCache(message);

        // ✅ Send to stream
        log(
          '📤 Broadcasting message to stream listeners...',
          name: 'ChatRepository',
        );
        log(
          '   Stream has ${_messageStreamController.hasListener ? 'ACTIVE' : 'NO'} listeners',
          name: 'ChatRepository',
        );
        _messageStreamController.add(message);
        log('✅ Message broadcast complete!', name: 'ChatRepository');
        log(
          '🔔 ================================================',
          name: 'ChatRepository',
        );
      } else {
        log('❌ Could not parse NewMessage', name: 'ChatRepository');
        log(
          '   EventData type: ${eventData.runtimeType}',
          name: 'ChatRepository',
        );
        log('   EventData: $eventData', name: 'ChatRepository');
      }
    } catch (e, stackTrace) {
      log('❌ Error handling NewMessage: $e', name: 'ChatRepository');
      log(
        '   Stack trace: ${stackTrace.toString().split('\n').take(5).join('\n')}',
        name: 'ChatRepository',
      );
    }
  }

  // ✅ Add handler for reactions
  void _handleMessageReacted(dynamic eventData) {
    try {
      log('👍 MessageReacted received: $eventData', name: 'ChatRepository');
      if (eventData == null) return;

      Map? reactionData;
      if (eventData is List && eventData.isNotEmpty) {
        final firstItem = eventData[0];
        if (firstItem is Map) {
          reactionData = Map<String, dynamic>.from(firstItem);
        }
      } else if (eventData is Map) {
        reactionData = Map<String, dynamic>.from(eventData);
      }

      if (reactionData != null) {
        final messageId =
            reactionData['messageId'] ?? reactionData['MessageId'];
        final userId = reactionData['userId'] ?? reactionData['UserId'];
        final reaction = reactionData['reaction'] ?? reactionData['Reaction'];

        log(
          '✅ Reaction parsed: messageId=$messageId, reaction=$reaction',
          name: 'ChatRepository',
        );

        // Send to stream
        _reactionStreamController.add({
          'messageId': messageId,
          'userId': userId,
          'reaction': reaction,
        });
      }
    } catch (e, stackTrace) {
      log('❌ Error handling MessageReacted: $e', name: 'ChatRepository');
    }
  }

  // Add this method to get initial messages
  Future<List<Message>> waitForInitialMessages() async {
    // ✅ Create completer if not exists
    _allMessagesLoadedCompleter ??= Completer<List<Message>>();

    return await _allMessagesLoadedCompleter!.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        log(
          '⚠️ Timeout waiting for initial messages, returning cache',
          name: 'ChatRepository',
        );
        return <Message>[];
      },
    );
  }

  // ✅ Send typing indicator
  Future<void> sendTypingIndicator(String roomId, bool isTyping) async {
    try {
      log(
        '📤 Sending typing indicator to room: $roomId, isTyping: $isTyping',
        name: 'ChatRepository',
      );
      await _signalRService.sendTypingIndicator(roomId, isTyping);
      log('✅ Typing indicator sent successfully', name: 'ChatRepository');
    } catch (e) {
      log('❌ Error sending typing indicator: $e', name: 'ChatRepository');
      log('Stack trace: ${StackTrace.current}', name: 'ChatRepository');
      rethrow;
    }
  }

  /// Save message to Hive cache with deduplication check
  /// Returns true if saved, false if already exists
  Future<bool> _saveMessageToCache(Message message) async {
    if (_messagesBox == null) {
      log(
        '⚠️ Messages box not initialized, skipping cache save',
        name: 'ChatRepository',
      );
      return false;
    }

    try {
      // Check if message already exists
      if (_messagesBox!.containsKey(message.id)) {
        log(
          '⚠️ Message already in cache: ${message.id}, skipping',
          name: 'ChatRepository',
        );
        return false;
      }

      // Save to cache
      await _messagesBox!.put(message.id, message.toJson());
      log('✅ Message saved to cache: ${message.id}', name: 'ChatRepository');
      return true;
    } catch (e) {
      log('❌ Error saving message to cache: $e', name: 'ChatRepository');
      return false;
    }
  }

  // Cleanup
  Future<void> dispose() async {
    await _messageStreamController.close();
    await _messageDeletedStreamController.close();
    await _messageUpdatedStreamController.close();
    await _connectionStreamController.close();
    await _typingStreamController.close();
    await _messagesBox?.close();
    await _roomsBox?.close();
  }
}
