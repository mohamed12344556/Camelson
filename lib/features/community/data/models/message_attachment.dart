enum AttachmentType { image, pdf, document, audio, video }

class MessageAttachment {
  final String id;
  final String messageId;
  final String fileName;
  final String url;
  final AttachmentType type;
  final int size;
  final DateTime uploadedAt;

  MessageAttachment({
    required this.id,
    required this.messageId,
    required this.fileName,
    required this.url,
    required this.type,
    required this.size,
    required this.uploadedAt,
  });

  factory MessageAttachment.fromJson(Map<String, dynamic> json) {
    return MessageAttachment(
      id: json['id'],
      messageId: json['messageId'],
      fileName: json['fileName'],
      url: json['url'],
      type: AttachmentType.values[json['type']],
      size: json['size'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'messageId': messageId,
      'fileName': fileName,
      'url': url,
      'type': type.index,
      'size': size,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }
}
