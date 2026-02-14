import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../models/message_attachment.dart';
import '../models/pending_message.dart';
import '../repos/chat_repo.dart';

/// Manages the queue of pending messages for offline-first architecture
/// Automatically sends messages when connection is available
class MessageQueueManager {
  final Box<PendingMessage> _queueBox;
  final ChatRepository _chatRepository;
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _processingTimer;
  bool _isProcessing = false;

  MessageQueueManager({
    required Box<PendingMessage> queueBox,
    required ChatRepository chatRepository,
    Connectivity? connectivity,
  }) : _queueBox = queueBox,
       _chatRepository = chatRepository,
       _connectivity = connectivity ?? Connectivity();

  /// Initialize the queue manager and start monitoring connectivity
  Future<void> init() async {
    developer.log('🚀 Initializing MessageQueueManager', name: 'MessageQueue');

    // Start listening to connectivity changes
    _startConnectivityListener();

    // Process any pending messages immediately
    await _tryProcessQueue();

    // Start periodic processing (every 30 seconds)
    _startPeriodicProcessing();

    developer.log('✅ MessageQueueManager initialized', name: 'MessageQueue');
  }

  /// Add a new message to the queue
  Future<void> enqueueMessage(PendingMessage message) async {
    developer.log('📥 Enqueuing message: ${message.id}', name: 'MessageQueue');

    await _queueBox.put(message.id, message);

    developer.log(
      '✅ Message enqueued. Queue size: ${_queueBox.length}',
      name: 'MessageQueue',
    );

    // Try to process immediately
    await _tryProcessQueue();
  }

  /// Remove a message from the queue
  Future<void> removeMessage(String messageId) async {
    await _queueBox.delete(messageId);
    developer.log(
      '🗑️ Message removed from queue: $messageId',
      name: 'MessageQueue',
    );
  }

  /// Get all pending messages for a specific room
  List<PendingMessage> getPendingMessagesForRoom(String roomId) {
    return _queueBox.values
        .where((m) => m.roomId == roomId && m.status != 'sent')
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Get count of pending messages
  int get pendingCount {
    return _queueBox.values.where((m) => m.status == 'pending').length;
  }

  /// Start listening to connectivity changes
  void _startConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      developer.log('📡 Connectivity changed: $results', name: 'MessageQueue');

      // Check if we have any connection
      final hasConnection = results.any(
        (result) =>
            result != ConnectivityResult.none &&
            result != ConnectivityResult.bluetooth,
      );

      if (hasConnection) {
        developer.log(
          '✅ Connection available, processing queue...',
          name: 'MessageQueue',
        );
        _tryProcessQueue();
      }
    });
  }

  /// Start periodic processing of the queue
  void _startPeriodicProcessing() {
    _processingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _tryProcessQueue(),
    );
  }

  /// Try to process the queue (check connection first)
  Future<void> _tryProcessQueue() async {
    if (_isProcessing) {
      developer.log(
        '⏭️ Already processing queue, skipping',
        name: 'MessageQueue',
      );
      return;
    }

    final hasConnection = await _hasConnection();
    if (!hasConnection) {
      developer.log('❌ No connection available', name: 'MessageQueue');
      return;
    }

    await _processQueue();
  }

  /// Process all pending messages in the queue
  Future<void> _processQueue() async {
    if (_isProcessing) return;

    _isProcessing = true;
    developer.log('🔄 Processing message queue...', name: 'MessageQueue');

    try {
      // Get all messages that need to be sent (pending or ready to retry)
      final messagesToSend =
          _queueBox.values
              .where((m) => m.status == 'pending' || m.isReadyToRetry)
              .toList()
            ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      developer.log(
        '📊 Found ${messagesToSend.length} messages to send',
        name: 'MessageQueue',
      );

      // Send messages one by one (FIFO order)
      for (final message in messagesToSend) {
        await _sendMessage(message);

        // Small delay between messages to avoid overwhelming the server
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Clean up old sent messages
      await _cleanupSentMessages();

      developer.log('✅ Queue processing complete', name: 'MessageQueue');
    } catch (e) {
      developer.log('❌ Error processing queue: $e', name: 'MessageQueue');
    } finally {
      _isProcessing = false;
    }
  }

  /// Send a single message
  Future<void> _sendMessage(PendingMessage message) async {
    developer.log(
      '📤 Attempting to send message: ${message.id} (attempt ${message.retryCount + 1})',
      name: 'MessageQueue',
    );
    developer.log(
      '   Content: ${message.content.substring(0, min(50, message.content.length))}',
      name: 'MessageQueue',
    );
    developer.log('   Room ID: ${message.roomId}', name: 'MessageQueue');
    developer.log(
      '   Is Question: ${message.isQuestion}',
      name: 'MessageQueue',
    );

    try {
      // Mark as sending
      message.markAsSending();
      await message.save();
      developer.log('✅ Marked message as sending', name: 'MessageQueue');

      // Prepare attachments if any
      List<MessageAttachment>? attachments;
      if (message.attachmentPaths != null &&
          message.attachmentPaths!.isNotEmpty) {
        developer.log(
          '📎 Uploading ${message.attachmentPaths!.length} attachments',
          name: 'MessageQueue',
        );
        attachments = await _chatRepository.uploadAttachments(
          message.attachmentPaths!,
          message.id,
        );
        developer.log('✅ Attachments uploaded', name: 'MessageQueue');
      }

      // Send the message
      if (message.isQuestion) {
        developer.log('📨 Sending as question...', name: 'MessageQueue');
        await _chatRepository.sendQuestion(
          roomId: message.roomId,
          content: message.content,
          subject: '', // TODO: Store subject in PendingMessage if needed
          grade: '', // TODO: Store grade in PendingMessage if needed
          attachments: attachments,
        );
      } else {
        developer.log(
          '📨 Sending as message via SignalR...',
          name: 'MessageQueue',
        );
        final sentMessage = await _chatRepository.sendMessage(
          roomId: message.roomId,
          content: message.content,
          attachments: attachments,
          replyToId: message.replyToId,
        );
        developer.log(
          '✅ SignalR sendMessage returned with ID: ${sentMessage.id}',
          name: 'MessageQueue',
        );
      }

      // Success! Mark as sent and remove from queue
      message.markAsSent();
      await message.save();

      developer.log(
        '✅ Message sent successfully: ${message.id}',
        name: 'MessageQueue',
      );
      developer.log(
        '   Now waiting for server to broadcast NewMessage event...',
        name: 'MessageQueue',
      );

      // Remove from queue after a delay (to allow UI to update)
      Future.delayed(const Duration(seconds: 2), () {
        developer.log(
          '🗑️ Removing message from queue: ${message.id}',
          name: 'MessageQueue',
        );
        removeMessage(message.id);
      });
    } catch (e, stackTrace) {
      // Failed - mark as failed and schedule retry
      final errorMessage = e.toString();
      message.markAsFailed(errorMessage);
      await message.save();

      developer.log(
        '❌ Failed to send message: ${message.id}, error: $errorMessage',
        name: 'MessageQueue',
      );
      developer.log('   Stack trace: $stackTrace', name: 'MessageQueue');

      if (!message.shouldRetry) {
        developer.log(
          '⛔ Max retries reached for message: ${message.id}',
          name: 'MessageQueue',
        );
      }
    }
  }

  /// Check if we have an active internet connection
  Future<bool> _hasConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any(
        (result) =>
            result != ConnectivityResult.none &&
            result != ConnectivityResult.bluetooth,
      );
    } catch (e) {
      developer.log('❌ Error checking connectivity: $e', name: 'MessageQueue');
      return false;
    }
  }

  /// Clean up messages that have been sent successfully (older than 1 day)
  Future<void> _cleanupSentMessages() async {
    final now = DateTime.now();
    final messagesToDelete = <String>[];

    for (final message in _queueBox.values) {
      // Delete sent messages older than 1 day
      if (message.status == 'sent' &&
          now.difference(message.timestamp).inDays > 1) {
        messagesToDelete.add(message.id);
      }

      // Delete failed messages older than 7 days
      if (message.status == 'failed' &&
          now.difference(message.timestamp).inDays > 7) {
        messagesToDelete.add(message.id);
      }
    }

    for (final id in messagesToDelete) {
      await _queueBox.delete(id);
    }

    if (messagesToDelete.isNotEmpty) {
      developer.log(
        '🧹 Cleaned up ${messagesToDelete.length} old messages',
        name: 'MessageQueue',
      );
    }
  }

  /// Manual retry of a specific failed message
  Future<void> retryMessage(String messageId) async {
    final message = _queueBox.get(messageId);
    if (message == null) {
      developer.log('❌ Message not found: $messageId', name: 'MessageQueue');
      return;
    }

    if (message.status != 'failed') {
      developer.log(
        '⚠️ Message is not in failed state: $messageId',
        name: 'MessageQueue',
      );
      return;
    }

    // Reset retry count and status
    message.status = 'pending';
    message.retryCount = 0;
    await message.save();

    // Try to send immediately
    await _tryProcessQueue();
  }

  /// Retry all failed messages
  Future<void> retryAllFailed() async {
    final failedMessages = _queueBox.values
        .where((m) => m.status == 'failed')
        .toList();

    for (final message in failedMessages) {
      message.status = 'pending';
      message.retryCount = 0;
      await message.save();
    }

    developer.log(
      '🔄 Reset ${failedMessages.length} failed messages',
      name: 'MessageQueue',
    );

    await _tryProcessQueue();
  }

  /// Clear all messages from the queue
  Future<void> clearQueue() async {
    await _queueBox.clear();
    developer.log('🗑️ Queue cleared', name: 'MessageQueue');
  }

  /// Dispose resources
  void dispose() {
    developer.log('🔴 Disposing MessageQueueManager', name: 'MessageQueue');
    _connectivitySubscription?.cancel();
    _processingTimer?.cancel();
  }
}
