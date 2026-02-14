import 'package:camelson/features/community/data/models/message_attachment.dart';
import 'package:camelson/features/community/data/models/message_reaction.dart';
import 'package:camelson/features/community/data/models/user.dart';
import 'dart:developer' as dev;

enum MessageContentType {
  text, // 0
  image, // 1
  file, // 2
  audio, // 3
  video, // 4
}

class Message {
  final String id;
  final String roomId;
  final String userId;
  final String content;
  final bool isQuestion;
  final DateTime timestamp;
  final List<MessageAttachment>? attachments;
  final List<MessageReaction> reactions;
  final String? replyToId;
  final int xpEarned;
  final User user;

  // Additional fields from backend
  final int contentType;
  final String senderId;
  final String senderName;
  final String? questionId;
  final DateTime sentAt;
  final DateTime? editedAt;
  final String? fileUrl;
  final String? fileName;
  final String? fileCaption;
  final int? fileSize;
  final String? replyToMessageId;

  Message({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.content,
    required this.isQuestion,
    required this.timestamp,
    this.attachments,
    required this.reactions,
    this.replyToId,
    required this.xpEarned,
    required this.user,
    // Backend fields
    this.contentType = 0,
    String? senderId,
    String? senderName,
    this.questionId,
    DateTime? sentAt,
    this.editedAt,
    this.fileUrl,
    this.fileName,
    this.fileCaption,
    this.fileSize,
    this.replyToMessageId,
  }) : senderId = senderId ?? userId,
       senderName = senderName ?? user.name,
       sentAt = sentAt ?? timestamp;

  factory Message.fromJson(Map<String, dynamic> json) {
    try {
      // Handle different field name variations from backend
      final id = json['id'] ?? json['Id'] ?? '';
      final content = json['content'] ?? json['Content'] ?? '';
      final contentType = json['contentType'] ?? json['ContentType'] ?? 0;

      final senderId =
          json['senderId'] ?? json['SenderId'] ?? json['userId'] ?? '';

      // ✅ الحل الذكي للاسم
      String senderName =
          json['senderName'] ??
          json['SenderName'] ??
          json['userName'] ??
          json['UserName'] ??
          '';

      // ✅ لو الاسم فاضي أو عبارة عن إيميل، نستخرج الاسم من الإيميل
      if (senderName.isEmpty || senderName.contains('@')) {
        final email = json['email'] ?? json['Email'] ?? senderName;
        if (email.isNotEmpty && email.contains('@')) {
          // خد الجزء قبل @ واعمله capitalize
          senderName = _extractNameFromEmail(email);
        } else if (email.isNotEmpty) {
          senderName = email;
        } else {
          // لو مافيش إيميل خالص، استخدم جزء من الـ ID
          senderName =
              'User ${senderId.substring(0, senderId.length > 4 ? 4 : senderId.length)}';
        }
      }

      final questionId = json['questionId'] ?? json['QuestionId'];
      final roomId = questionId ?? json['roomId'] ?? '';

      // Parse timestamp
      final sentAtStr = json['sentAt'] ?? json['SentAt'] ?? json['timestamp'];
      final sentAt = sentAtStr != null
          ? (sentAtStr is String ? DateTime.parse(sentAtStr) : DateTime.now())
          : DateTime.now();

      final editedAtStr = json['editedAt'] ?? json['EditedAt'];
      final editedAt = editedAtStr != null
          ? DateTime.tryParse(editedAtStr)
          : null;

      final fileUrl = json['fileUrl'] ?? json['FileUrl'];
      final fileName = json['fileName'] ?? json['FileName'];
      final fileCaption = json['fileCaption'] ?? json['FileCaption'];
      final fileSize = json['fileSize'] ?? json['FileSize'];
      final replyToMessageId =
          json['replyToMessageId'] ?? json['ReplyToMessageId'];

      // Parse reactions safely
      List<MessageReaction> reactions = [];
      if (json['reactions'] != null && json['reactions'] is List) {
        try {
          reactions = (json['reactions'] as List)
              .map((r) {
                try {
                  return MessageReaction.fromJson(r as Map<String, dynamic>);
                } catch (e) {
                  dev.log('Error parsing reaction: $e', name: 'Message');
                  return null;
                }
              })
              .whereType<MessageReaction>()
              .toList();
        } catch (e) {
          dev.log('Error parsing reactions list: $e', name: 'Message');
        }
      }

      // Parse attachments
      List<MessageAttachment>? attachments;
      if (json['attachments'] != null && json['attachments'] is List) {
        try {
          attachments = (json['attachments'] as List)
              .map((a) => MessageAttachment.fromJson(a as Map<String, dynamic>))
              .toList();
        } catch (e) {
          dev.log('Error parsing attachments: $e', name: 'Message');
        }
      }

      // ✅ Create user object with smart name handling
      final user = User(
        id: senderId,
        name: senderName, // ✅ هنا هيبقى الاسم الذكي اللي استخرجناه
        email: json['email'] ?? json['Email'] ?? '',
        role: UserRole.student,
        profileImage: json['senderImageUrl'] ?? json['SenderImageUrl'],
        xpPoints: 0,
        createdAt: sentAt,
        hasAgreedToPolicy: true,
      );

      return Message(
        id: id,
        content: content,
        contentType: contentType,
        senderId: senderId,
        senderName: senderName,
        questionId: questionId,
        roomId: roomId,
        sentAt: sentAt,
        editedAt: editedAt,
        fileUrl: fileUrl,
        fileName: fileName,
        fileCaption: fileCaption,
        fileSize: fileSize,
        replyToMessageId: replyToMessageId,
        reactions: reactions,
        userId: senderId,
        timestamp: sentAt,
        isQuestion: false,
        attachments: attachments,
        replyToId: replyToMessageId,
        xpEarned: 0,
        user: user,
      );
    } catch (e, stackTrace) {
      dev.log(
        'Error parsing message: $e',
        name: 'Message',
        error: e,
        stackTrace: stackTrace,
      );
      dev.log('JSON: $json', name: 'Message');
      rethrow;
    }
  }

  // ✅ Helper method لاستخراج الاسم من الإيميل
  static String _extractNameFromEmail(String email) {
    if (!email.contains('@')) return email;

    // خد الجزء قبل @
    String username = email.split('@').first;

    // لو فيه أرقام كتير في الآخر، احذفها (مثال: omas28325 → omas)
    final hasTrailingNumbers = RegExp(r'\d{3,}$').hasMatch(username);
    if (hasTrailingNumbers) {
      username = username.replaceAll(RegExp(r'\d+$'), '');
    }

    // اعمل capitalize للحرف الأول
    if (username.isNotEmpty) {
      username = username[0].toUpperCase() + username.substring(1);
    }

    return username.isEmpty ? email.split('@').first : username;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'userId': userId,
      'content': content,
      'isQuestion': isQuestion,
      'timestamp': timestamp.toIso8601String(),
      'attachments': attachments?.map((a) => a.toJson()).toList(),
      'reactions': reactions.map((r) => r.toJson()).toList(),
      'replyToId': replyToId,
      'xpEarned': xpEarned,
      'user': user.toJson(),
      // Backend fields
      'contentType': contentType,
      'senderId': senderId,
      'senderName': senderName,
      'questionId': questionId,
      'sentAt': sentAt.toIso8601String(),
      'editedAt': editedAt?.toIso8601String(),
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileCaption': fileCaption,
      'fileSize': fileSize,
      'replyToMessageId': replyToMessageId,
    };
  }

  // Helper method to get content type as enum
  MessageContentType get contentTypeEnum {
    if (contentType >= 0 && contentType < MessageContentType.values.length) {
      return MessageContentType.values[contentType];
    }
    return MessageContentType.text;
  }

  // ✅ Helper methods for checking message types
  bool get isAudioMessage => contentTypeEnum == MessageContentType.audio;
  bool get isImageMessage => contentTypeEnum == MessageContentType.image;
  bool get isFileMessage => contentTypeEnum == MessageContentType.file;
  bool get isVideoMessage => contentTypeEnum == MessageContentType.video;
  bool get hasFile => fileUrl != null && fileUrl!.isNotEmpty;
}
