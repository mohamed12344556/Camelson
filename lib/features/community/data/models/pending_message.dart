import 'package:hive_ce/hive.dart';

part 'pending_message.g.dart';

/// Represents a message waiting to be sent to the server
/// Used for offline-first architecture and automatic retry
@HiveType(typeId: 5)
class PendingMessage extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String roomId;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  int retryCount;

  @HiveField(5)
  String status; // 'pending', 'sending', 'failed', 'sent'

  @HiveField(6)
  final List<String>? attachmentPaths;

  @HiveField(7)
  final String? replyToId;

  @HiveField(8)
  final bool isQuestion;

  @HiveField(9)
  DateTime? lastAttemptAt;

  @HiveField(10)
  String? error;

  PendingMessage({
    required this.id,
    required this.roomId,
    required this.content,
    required this.timestamp,
    this.retryCount = 0,
    this.status = 'pending',
    this.attachmentPaths,
    this.replyToId,
    this.isQuestion = false,
    this.lastAttemptAt,
    this.error,
  });

  /// Check if this message should be retried
  bool get shouldRetry {
    return status == 'failed' && retryCount < 3;
  }

  /// Check if this message is ready to retry (based on exponential backoff)
  bool get isReadyToRetry {
    if (!shouldRetry) return false;
    if (lastAttemptAt == null) return true;

    // Exponential backoff: 5s, 10s, 20s
    final delaySeconds = 5 * (1 << retryCount); // 5 * 2^retryCount
    final nextRetryTime = lastAttemptAt!.add(Duration(seconds: delaySeconds));

    return DateTime.now().isAfter(nextRetryTime);
  }

  /// Mark as sending
  void markAsSending() {
    status = 'sending';
    lastAttemptAt = DateTime.now();
  }

  /// Mark as failed
  void markAsFailed(String errorMessage) {
    status = 'failed';
    retryCount++;
    error = errorMessage;
    lastAttemptAt = DateTime.now();
  }

  /// Mark as sent successfully
  void markAsSent() {
    status = 'sent';
  }

  @override
  String toString() {
    return 'PendingMessage(id: $id, roomId: $roomId, content: ${content.substring(0, content.length > 20 ? 20 : content.length)}, status: $status, retryCount: $retryCount)';
  }
}
