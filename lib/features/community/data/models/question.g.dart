// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) => Question(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  subjectName: json['subjectName'] as String,
  subjectId: json['subjectId'] as String,
  imageUrl: json['imageUrl'] as String?,
  fileAttachment: json['fileAttachment'] as String?,
  fileAttachmentCaption: json['fileAttachmentCaption'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  creatorId: json['creatorId'] as String,
  creatorName: json['creatorName'] as String,
  creatorImageUrl: json['creatorImageUrl'] as String?,
  isClosed: json['isClosed'] as bool,
  isPinned: json['isPinned'] as bool,
  viewCount: (json['viewCount'] as num).toInt(),
  messageCount: (json['messageCount'] as num).toInt(),
  memberCount: (json['memberCount'] as num).toInt(),
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  currentUserRole: (json['currentUserRole'] as num).toInt(),
);

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'subjectName': instance.subjectName,
  'subjectId': instance.subjectId,
  'imageUrl': instance.imageUrl,
  'fileAttachment': instance.fileAttachment,
  'fileAttachmentCaption': instance.fileAttachmentCaption,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'creatorId': instance.creatorId,
  'creatorName': instance.creatorName,
  'creatorImageUrl': instance.creatorImageUrl,
  'isClosed': instance.isClosed,
  'isPinned': instance.isPinned,
  'viewCount': instance.viewCount,
  'messageCount': instance.messageCount,
  'memberCount': instance.memberCount,
  'tags': instance.tags,
  'currentUserRole': instance.currentUserRole,
};

QuestionListResponse _$QuestionListResponseFromJson(
  Map<String, dynamic> json,
) => QuestionListResponse(
  success: json['success'] as bool,
  data: (json['data'] as List<dynamic>)
      .map((e) => Question.fromJson(e as Map<String, dynamic>))
      .toList(),
  message: json['message'] as String?,
  page: (json['page'] as num?)?.toInt(),
  pageSize: (json['pageSize'] as num?)?.toInt(),
  totalPages: (json['totalPages'] as num?)?.toInt(),
  totalCount: (json['totalCount'] as num?)?.toInt(),
  includeClosed: json['includeClosed'] as bool?,
);

Map<String, dynamic> _$QuestionListResponseToJson(
  QuestionListResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data,
  'message': instance.message,
  'page': instance.page,
  'pageSize': instance.pageSize,
  'totalPages': instance.totalPages,
  'totalCount': instance.totalCount,
  'includeClosed': instance.includeClosed,
};

QuestionResponse _$QuestionResponseFromJson(Map<String, dynamic> json) =>
    QuestionResponse(
      success: json['success'] as bool,
      data: Question.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$QuestionResponseToJson(QuestionResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
      'message': instance.message,
    };

CreateQuestionRequest _$CreateQuestionRequestFromJson(
  Map<String, dynamic> json,
) => CreateQuestionRequest(
  subjectId: json['subjectId'] as String,
  creatorId: json['creatorId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
);

Map<String, dynamic> _$CreateQuestionRequestToJson(
  CreateQuestionRequest instance,
) => <String, dynamic>{
  'subjectId': instance.subjectId,
  'creatorId': instance.creatorId,
  'title': instance.title,
  'description': instance.description,
};

QuestionMember _$QuestionMemberFromJson(Map<String, dynamic> json) =>
    QuestionMember(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      role: (json['role'] as num).toInt(),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      isOnline: json['isOnline'] as bool,
      isTeacher: json['isTeacher'] as bool,
      messagesCount: (json['messagesCount'] as num).toInt(),
    );

Map<String, dynamic> _$QuestionMemberToJson(QuestionMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'role': instance.role,
      'joinedAt': instance.joinedAt.toIso8601String(),
      'isOnline': instance.isOnline,
      'isTeacher': instance.isTeacher,
      'messagesCount': instance.messagesCount,
    };

QuestionMembersResponse _$QuestionMembersResponseFromJson(
  Map<String, dynamic> json,
) => QuestionMembersResponse(
  success: json['success'] as bool,
  data: (json['data'] as List<dynamic>)
      .map((e) => QuestionMember.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalCount: (json['totalCount'] as num?)?.toInt(),
  message: json['message'] as String?,
);

Map<String, dynamic> _$QuestionMembersResponseToJson(
  QuestionMembersResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data,
  'totalCount': instance.totalCount,
  'message': instance.message,
};

QuestionMessage _$QuestionMessageFromJson(Map<String, dynamic> json) =>
    QuestionMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      contentType: (json['contentType'] as num).toInt(),
      fileUrl: json['fileUrl'] as String?,
      fileName: json['fileName'] as String?,
      fileCaption: json['fileCaption'] as String?,
      fileSize: (json['fileSize'] as num?)?.toInt(),
      fileSizeFormatted: json['fileSizeFormatted'] as String?,
      sentAt: DateTime.parse(json['sentAt'] as String),
      editedAt: json['editedAt'] == null
          ? null
          : DateTime.parse(json['editedAt'] as String),
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderImageUrl: json['senderImageUrl'] as String?,
      questionId: json['questionId'] as String,
      replyToMessageId: json['replyToMessageId'] as String?,
      replyToMessage: json['replyToMessage'] == null
          ? null
          : QuestionMessage.fromJson(
              json['replyToMessage'] as Map<String, dynamic>,
            ),
      reactions:
          (json['reactions'] as List<dynamic>?)
              ?.map((e) => MessageReaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      statuses:
          (json['statuses'] as List<dynamic>?)
              ?.map((e) => MessageStatus.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isDeleted: json['isDeleted'] as bool? ?? false,
      isCurrentUserSender: json['isCurrentUserSender'] as bool? ?? false,
      canEdit: json['canEdit'] as bool? ?? false,
      canDelete: json['canDelete'] as bool? ?? false,
    );

Map<String, dynamic> _$QuestionMessageToJson(QuestionMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'contentType': instance.contentType,
      'fileUrl': instance.fileUrl,
      'fileName': instance.fileName,
      'fileCaption': instance.fileCaption,
      'fileSize': instance.fileSize,
      'fileSizeFormatted': instance.fileSizeFormatted,
      'sentAt': instance.sentAt.toIso8601String(),
      'editedAt': instance.editedAt?.toIso8601String(),
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'senderImageUrl': instance.senderImageUrl,
      'questionId': instance.questionId,
      'replyToMessageId': instance.replyToMessageId,
      'replyToMessage': instance.replyToMessage,
      'reactions': instance.reactions,
      'statuses': instance.statuses,
      'isDeleted': instance.isDeleted,
      'isCurrentUserSender': instance.isCurrentUserSender,
      'canEdit': instance.canEdit,
      'canDelete': instance.canDelete,
    };

MessageStatus _$MessageStatusFromJson(Map<String, dynamic> json) =>
    MessageStatus(
      id: json['id'] as String,
      messageId: json['messageId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      status: (json['status'] as num).toInt(),
      deliveredAt: json['deliveredAt'] == null
          ? null
          : DateTime.parse(json['deliveredAt'] as String),
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
    );

Map<String, dynamic> _$MessageStatusToJson(MessageStatus instance) =>
    <String, dynamic>{
      'id': instance.id,
      'messageId': instance.messageId,
      'userId': instance.userId,
      'userName': instance.userName,
      'status': instance.status,
      'deliveredAt': instance.deliveredAt?.toIso8601String(),
      'readAt': instance.readAt?.toIso8601String(),
    };

MessageReaction _$MessageReactionFromJson(Map<String, dynamic> json) =>
    MessageReaction(
      id: json['id'] as String,
      reaction: json['reaction'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      reactedAt: DateTime.parse(json['reactedAt'] as String),
    );

Map<String, dynamic> _$MessageReactionToJson(MessageReaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reaction': instance.reaction,
      'userId': instance.userId,
      'userName': instance.userName,
      'reactedAt': instance.reactedAt.toIso8601String(),
    };

QuestionMessagesResponse _$QuestionMessagesResponseFromJson(
  Map<String, dynamic> json,
) => QuestionMessagesResponse(
  success: json['success'] as bool,
  data: (json['data'] as List<dynamic>)
      .map((e) => QuestionMessage.fromJson(e as Map<String, dynamic>))
      .toList(),
  message: json['message'] as String?,
);

Map<String, dynamic> _$QuestionMessagesResponseToJson(
  QuestionMessagesResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data,
  'message': instance.message,
};
