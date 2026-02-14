import 'dart:developer' as dev;

enum ReactionType {
  like, // 👍
  love, // ❤️
  laugh, // 😂
  wow, // 😮
  sad, // 😢
  angry, // 😡
  clap, // 👏
  fire, // 🔥
  correct, // ✅
  helpful, // 💡
}

class MessageReaction {
  final String id;
  final String messageId;
  final String userId;
  final String? userName; // Added to match backend MessageReactionDto
  final ReactionType type;
  final String reaction; // Raw reaction string from backend (emoji or text)
  final DateTime timestamp;

  MessageReaction({
    required this.id,
    required this.messageId,
    required this.userId,
    this.userName,
    required this.type,
    required this.reaction,
    required this.timestamp,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    try {
      // Handle different field names
      final id = json['id'] ?? json['Id'] ?? '';
      final messageId = json['messageId'] ?? json['MessageId'] ?? '';
      final userId = json['userId'] ?? json['UserId'] ?? '';
      final userName = json['userName'] ?? json['UserName'];

      // Handle reaction field - could be string emoji or int type
      final reactionValue =
          json['reaction'] ?? json['Reaction'] ?? json['type'];
      ReactionType type = ReactionType.like; // default
      String reactionString = '👍'; // default

      if (reactionValue is int) {
        type = ReactionType.values[reactionValue];
        reactionString = _getEmojiForType(type);
      } else if (reactionValue is String) {
        reactionString = reactionValue;
        // Map emoji/string to type
        type = _parseReactionType(reactionValue);
      }

      final timestampStr =
          json['timestamp'] ??
          json['Timestamp'] ??
          json['reactedAt'] ??
          json['ReactedAt'];
      final timestamp = timestampStr != null
          ? DateTime.parse(timestampStr)
          : DateTime.now();

      return MessageReaction(
        id: id,
        messageId: messageId,
        userId: userId,
        userName: userName,
        type: type,
        reaction: reactionString,
        timestamp: timestamp,
      );
    } catch (e) {
      dev.log('Error parsing MessageReaction: $e', name: 'MessageReaction');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'messageId': messageId,
      'userId': userId,
      'userName': userName,
      'reaction': reaction,
      'type': type.index,
      'timestamp': timestamp.toIso8601String(),
      'reactedAt': timestamp.toIso8601String(),
    };
  }

  /// Parse reaction string/emoji to ReactionType
  static ReactionType _parseReactionType(String reactionValue) {
    switch (reactionValue.toLowerCase()) {
      case '👍':
      case 'like':
      case 'thumbsup':
        return ReactionType.like;
      case '❤️':
      case '❤':
      case 'love':
      case 'heart':
        return ReactionType.love;
      case '😂':
      case 'laugh':
      case 'haha':
        return ReactionType.laugh;
      case '😮':
      case 'wow':
        return ReactionType.wow;
      case '😢':
      case 'sad':
        return ReactionType.sad;
      case '😡':
      case 'angry':
        return ReactionType.angry;
      case '👏':
      case 'clap':
        return ReactionType.clap;
      case '🔥':
      case 'fire':
        return ReactionType.fire;
      case '✅':
      case 'correct':
      case 'check':
        return ReactionType.correct;
      case '💡':
      case 'helpful':
      case 'idea':
        return ReactionType.helpful;
      default:
        dev.log('Unknown reaction type: $reactionValue, defaulting to like',
            name: 'MessageReaction');
        return ReactionType.like;
    }
  }

  /// Get emoji string for ReactionType
  static String _getEmojiForType(ReactionType type) {
    switch (type) {
      case ReactionType.like:
        return '👍';
      case ReactionType.love:
        return '❤️';
      case ReactionType.laugh:
        return '😂';
      case ReactionType.wow:
        return '😮';
      case ReactionType.sad:
        return '😢';
      case ReactionType.angry:
        return '😡';
      case ReactionType.clap:
        return '👏';
      case ReactionType.fire:
        return '🔥';
      case ReactionType.correct:
        return '✅';
      case ReactionType.helpful:
        return '💡';
    }
  }

  /// Get emoji for this reaction
  String get emoji => _getEmojiForType(type);
}
