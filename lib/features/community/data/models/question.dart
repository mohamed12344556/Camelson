import 'package:json_annotation/json_annotation.dart';
import 'question_role.dart';

part 'question.g.dart';

@JsonSerializable()
class Question {
  final String id;
  final String title;
  final String description;
  final String subjectName;
  final String subjectId;
  final String? imageUrl;
  final String? fileAttachment;
  final String? fileAttachmentCaption;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String creatorId;
  final String creatorName;
  final String? creatorImageUrl;
  final bool isClosed;
  final bool isPinned;
  final int viewCount;
  final int messageCount;
  final int memberCount;
  @JsonKey(defaultValue: [])
  final List<String> tags;
  final int currentUserRole; // 0=creator, 1=moderator, 2=member

  Question({
    required this.id,
    required this.title,
    required this.description,
    required this.subjectName,
    required this.subjectId,
    this.imageUrl,
    this.fileAttachment,
    this.fileAttachmentCaption,
    required this.createdAt,
    this.updatedAt,
    required this.creatorId,
    required this.creatorName,
    this.creatorImageUrl,
    required this.isClosed,
    required this.isPinned,
    required this.viewCount,
    required this.messageCount,
    required this.memberCount,
    this.tags = const [],
    required this.currentUserRole,
  });

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionToJson(this);

  /// Get the current user's role as QuestionRole enum
  QuestionRole get role => QuestionRole.fromValue(currentUserRole);

  /// Check if current user has admin privileges
  bool get hasAdminPrivileges => role.hasAdminPrivileges;

  /// Check if current user is the creator
  bool get isUserCreator => role.isCreator;

  /// Check if current user is an admin
  bool get isUserAdmin => role.isAdmin;

  /// Check if current user is a regular member
  bool get isUserMember => role.isMember;
}

@JsonSerializable()
class QuestionListResponse {
  final bool success;
  final List<Question> data;
  final String? message;
  final int? page;
  final int? pageSize;
  final int? totalPages;
  final int? totalCount;
  final bool? includeClosed; // Whether closed questions are included

  QuestionListResponse({
    required this.success,
    required this.data,
    this.message,
    this.page,
    this.pageSize,
    this.totalPages,
    this.totalCount,
    this.includeClosed,
  });

  factory QuestionListResponse.fromJson(Map<String, dynamic> json) =>
      _$QuestionListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionListResponseToJson(this);

  /// Check if there are more pages to load
  bool get hasMorePages {
    if (page == null || totalPages == null) return false;
    return page! < totalPages!;
  }

  /// Get the next page number (null if no more pages)
  int? get nextPage {
    if (!hasMorePages) return null;
    return page! + 1;
  }
}

@JsonSerializable()
class QuestionResponse {
  final bool success;
  final Question data;
  final String? message;

  QuestionResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory QuestionResponse.fromJson(Map<String, dynamic> json) =>
      _$QuestionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionResponseToJson(this);
}

@JsonSerializable()
class CreateQuestionRequest {
  final String subjectId;
  final String creatorId;
  final String title;
  final String description;

  CreateQuestionRequest({
    required this.subjectId,
    required this.creatorId,
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toJson() => _$CreateQuestionRequestToJson(this);
}

@JsonSerializable()
class QuestionMember {
  final String id; // Member ID (not userId - from API response)
  final String userId;
  final String userName;
  final int role; // 0=creator, 1=moderator, 2=member
  final DateTime joinedAt;
  final bool isOnline;
  final bool isTeacher;
  final int messagesCount;

  QuestionMember({
    required this.id,
    required this.userId,
    required this.userName,
    required this.role,
    required this.joinedAt,
    required this.isOnline,
    required this.isTeacher,
    required this.messagesCount,
  });

  factory QuestionMember.fromJson(Map<String, dynamic> json) =>
      _$QuestionMemberFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionMemberToJson(this);

  /// Get the member's role as QuestionRole enum
  QuestionRole get memberRole => QuestionRole.fromValue(role);

  /// Check if member has admin privileges
  bool get hasAdminPrivileges => memberRole.hasAdminPrivileges;

  /// Check if member is the creator
  bool get isCreator => memberRole.isCreator;

  /// Check if member is an admin (moderator)
  bool get isAdmin => memberRole.isAdmin;

  /// Check if member is a regular member
  bool get isMember => memberRole.isMember;
}

@JsonSerializable()
class QuestionMembersResponse {
  final bool success;
  final List<QuestionMember> data;
  final int? totalCount;
  final String? message;

  QuestionMembersResponse({
    required this.success,
    required this.data,
    this.totalCount,
    this.message,
  });

  factory QuestionMembersResponse.fromJson(Map<String, dynamic> json) =>
      _$QuestionMembersResponseFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionMembersResponseToJson(this);
}

// Message Content Type enum
// IMPORTANT: Order must match backend ContentType enum exactly
// Backend: Text=0, Image=1, File=2, Audio=3, Video=4
enum MessageContentType {
  text,  // 0
  image, // 1
  file,  // 2 - FIXED: was audio
  audio, // 3 - FIXED: was video
  video; // 4 - FIXED: was file

  int get value {
    switch (this) {
      case MessageContentType.text:
        return 0;
      case MessageContentType.image:
        return 1;
      case MessageContentType.file:
        return 2;
      case MessageContentType.audio:
        return 3;
      case MessageContentType.video:
        return 4;
    }
  }

  static MessageContentType fromValue(int value) {
    switch (value) {
      case 0:
        return MessageContentType.text;
      case 1:
        return MessageContentType.image;
      case 2:
        return MessageContentType.file;
      case 3:
        return MessageContentType.audio;
      case 4:
        return MessageContentType.video;
      default:
        return MessageContentType.text;
    }
  }
}

@JsonSerializable()
class QuestionMessage {
  final String id;
  final String content;
  final int contentType; // 0=text, 1=image, 2=file, 3=audio, 4=video
  final String? fileUrl;
  final String? fileName;
  final String? fileCaption;
  final int? fileSize;
  final String? fileSizeFormatted; // Human readable size from backend
  final DateTime sentAt;
  final DateTime? editedAt;
  final String senderId;
  final String senderName;
  final String? senderImageUrl;
  final String questionId;
  final String? replyToMessageId;
  final QuestionMessage? replyToMessage; // Full message object if replying
  final List<MessageReaction> reactions;
  final List<MessageStatus> statuses; // Message delivery/read status
  final bool isDeleted;
  final bool isCurrentUserSender; // If current user sent this message
  final bool canEdit; // If current user can edit (based on time window)
  final bool canDelete; // If current user can delete (based on role/time)

  QuestionMessage({
    required this.id,
    required this.content,
    required this.contentType,
    this.fileUrl,
    this.fileName,
    this.fileCaption,
    this.fileSize,
    this.fileSizeFormatted,
    required this.sentAt,
    this.editedAt,
    required this.senderId,
    required this.senderName,
    this.senderImageUrl,
    required this.questionId,
    this.replyToMessageId,
    this.replyToMessage,
    this.reactions = const [],
    this.statuses = const [],
    this.isDeleted = false,
    this.isCurrentUserSender = false,
    this.canEdit = false,
    this.canDelete = false,
  });

  factory QuestionMessage.fromJson(Map<String, dynamic> json) =>
      _$QuestionMessageFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionMessageToJson(this);

  /// Get content type as enum
  MessageContentType get type => MessageContentType.fromValue(contentType);

  /// Check if this is a text message
  bool get isText => type == MessageContentType.text;

  /// Check if this is an image message
  bool get isImage => type == MessageContentType.image;

  /// Check if this is an audio message
  bool get isAudio => type == MessageContentType.audio;

  /// Check if this is a video message
  bool get isVideo => type == MessageContentType.video;

  /// Check if this is a file message
  bool get isFile => type == MessageContentType.file;

  /// Check if message has been edited
  bool get isEdited => editedAt != null;

  /// Format file size
  String get formattedFileSize {
    if (fileSize == null) return '';

    final bytes = fileSize!;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// Message delivery and read status types
enum StatusType {
  notDelivered, // 0
  delivered,    // 1
  read;         // 2

  int get value {
    switch (this) {
      case StatusType.notDelivered:
        return 0;
      case StatusType.delivered:
        return 1;
      case StatusType.read:
        return 2;
    }
  }

  static StatusType fromValue(int value) {
    switch (value) {
      case 0:
        return StatusType.notDelivered;
      case 1:
        return StatusType.delivered;
      case 2:
        return StatusType.read;
      default:
        return StatusType.notDelivered;
    }
  }
}

@JsonSerializable()
class MessageStatus {
  final String id;
  final String messageId;
  final String userId;
  final String userName;
  final int status; // 0=NotDelivered, 1=Delivered, 2=Read
  final DateTime? deliveredAt;
  final DateTime? readAt;

  MessageStatus({
    required this.id,
    required this.messageId,
    required this.userId,
    required this.userName,
    required this.status,
    this.deliveredAt,
    this.readAt,
  });

  factory MessageStatus.fromJson(Map<String, dynamic> json) =>
      _$MessageStatusFromJson(json);

  Map<String, dynamic> toJson() => _$MessageStatusToJson(this);

  /// Get status as enum
  StatusType get statusType => StatusType.fromValue(status);

  /// Check if message is delivered
  bool get isDelivered => statusType == StatusType.delivered || statusType == StatusType.read;

  /// Check if message is read
  bool get isRead => statusType == StatusType.read;
}

@JsonSerializable()
class MessageReaction {
  final String id;
  final String reaction;
  final String userId;
  final String userName;
  final DateTime reactedAt;

  MessageReaction({
    required this.id,
    required this.reaction,
    required this.userId,
    required this.userName,
    required this.reactedAt,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) =>
      _$MessageReactionFromJson(json);

  Map<String, dynamic> toJson() => _$MessageReactionToJson(this);
}

@JsonSerializable()
class QuestionMessagesResponse {
  final bool success;
  final List<QuestionMessage> data;
  final String? message;

  QuestionMessagesResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory QuestionMessagesResponse.fromJson(Map<String, dynamic> json) =>
      _$QuestionMessagesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionMessagesResponseToJson(this);
}
