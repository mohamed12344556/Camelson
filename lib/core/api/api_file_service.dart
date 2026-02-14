import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import 'api_constants.dart';

/// Service for handling file uploads and multipart/form-data requests
///
/// This service provides manual Dio implementations for file upload operations
/// since Retrofit has issues with nullable multipart files.
class ApiFileService {
  final Dio _dio;

  ApiFileService(this._dio);

  /// Upload profile image
  ///
  /// POST /api/User/profile-image
  ///
  /// Example:
  /// ```dart
  /// final file = File('/path/to/image.jpg');
  /// final response = await apiFileService.uploadProfileImage(file);
  /// ```
  Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    try {
      developer.log('Uploading profile image: ${imageFile.path}',
          name: 'ApiFileService');

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        ApiConstants.updateProfileImage,
        data: formData,
      );

      developer.log('Profile image uploaded successfully',
          name: 'ApiFileService');
      return response.data as Map<String, dynamic>;
    } catch (e, stackTrace) {
      developer.log(
        'Error uploading profile image',
        name: 'ApiFileService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Create a new question with optional files
  ///
  /// POST /api/Questions
  ///
  /// Example:
  /// ```dart
  /// final response = await apiFileService.createQuestion(
  ///   title: 'My Question',
  ///   description: 'Question details',
  ///   subjectId: 'subject-uuid',
  ///   creatorId: 'user-uuid',
  ///   imageFile: File('/path/to/image.jpg'),
  ///   attachmentFile: File('/path/to/document.pdf'),
  /// );
  /// ```
  Future<Map<String, dynamic>> createQuestion({
    required String title,
    required String description,
    required String subjectId,
    required String creatorId,
    File? imageFile,
    File? attachmentFile,
    List<String>? tags,
  }) async {
    try {
      developer.log(
        'Creating question: $title',
        name: 'ApiFileService',
      );

      final formDataMap = <String, dynamic>{
        'Title': title,
        'Description': description,
        'SubjectId': subjectId,
        'CreatorId': creatorId,
      };

      // Add image file if provided
      if (imageFile != null) {
        formDataMap['ImageFile'] = await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        );
      }

      // Add attachment file if provided
      if (attachmentFile != null) {
        formDataMap['AttachmentFile'] = await MultipartFile.fromFile(
          attachmentFile.path,
          filename: attachmentFile.path.split('/').last,
        );
      }

      // Add tags if provided
      if (tags != null && tags.isNotEmpty) {
        for (int i = 0; i < tags.length; i++) {
          formDataMap['Tags[$i]'] = tags[i];
        }
      }

      final formData = FormData.fromMap(formDataMap);

      final response = await _dio.post(
        ApiConstants.questions,
        data: formData,
      );

      developer.log('Question created successfully', name: 'ApiFileService');
      return response.data as Map<String, dynamic>;
    } catch (e, stackTrace) {
      developer.log(
        'Error creating question',
        name: 'ApiFileService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Update an existing question with optional new files
  ///
  /// PUT /api/Questions/{id}
  ///
  /// Example:
  /// ```dart
  /// final response = await apiFileService.updateQuestion(
  ///   questionId: 'question-uuid',
  ///   title: 'Updated Title',
  ///   newImageFile: File('/path/to/new-image.jpg'),
  ///   removeAttachment: true,
  /// );
  /// ```
  Future<Map<String, dynamic>> updateQuestion({
    required String questionId,
    String? title,
    String? description,
    String? subjectId,
    bool? isClosed,
    bool? isPinned,
    File? newImageFile,
    bool removeImage = false,
    File? newAttachmentFile,
    String? fileAttachmentCaption,
    bool removeAttachment = false,
    List<String>? addTags,
    List<String>? removeTags,
  }) async {
    try {
      developer.log(
        'Updating question: $questionId',
        name: 'ApiFileService',
      );

      final formDataMap = <String, dynamic>{};

      // Add text fields only if provided (backend handles null as "no change")
      if (title != null) formDataMap['Title'] = title;
      if (description != null) formDataMap['Description'] = description;
      if (subjectId != null) formDataMap['SubjectId'] = subjectId;
      if (isClosed != null) formDataMap['IsClosed'] = isClosed;
      if (isPinned != null) formDataMap['IsPinned'] = isPinned;

      // Add new image file if provided
      if (newImageFile != null) {
        formDataMap['NewImageFile'] = await MultipartFile.fromFile(
          newImageFile.path,
          filename: newImageFile.path.split('/').last,
        );
      }
      formDataMap['RemoveImage'] = removeImage;

      // Add new attachment file if provided
      if (newAttachmentFile != null) {
        formDataMap['NewAttachmentFile'] = await MultipartFile.fromFile(
          newAttachmentFile.path,
          filename: newAttachmentFile.path.split('/').last,
        );
      }
      if (fileAttachmentCaption != null) {
        formDataMap['FileAttachmentCaption'] = fileAttachmentCaption;
      }
      formDataMap['RemoveAttachment'] = removeAttachment;

      // Add tags to add
      if (addTags != null && addTags.isNotEmpty) {
        for (int i = 0; i < addTags.length; i++) {
          formDataMap['AddTags[$i]'] = addTags[i];
        }
      }

      // Add tags to remove
      if (removeTags != null && removeTags.isNotEmpty) {
        for (int i = 0; i < removeTags.length; i++) {
          formDataMap['RemoveTags[$i]'] = removeTags[i];
        }
      }

      final formData = FormData.fromMap(formDataMap);

      final response = await _dio.put(
        '${ApiConstants.questions}/$questionId',
        data: formData,
      );

      developer.log('Question updated successfully', name: 'ApiFileService');
      return response.data as Map<String, dynamic>;
    } catch (e, stackTrace) {
      developer.log(
        'Error updating question',
        name: 'ApiFileService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Send a message with optional file attachment
  ///
  /// This is a fallback REST API method for when SignalR is unavailable.
  /// Prefer using SignalR for real-time messaging when connected.
  ///
  /// POST /api/Messages (hypothetical - check with backend)
  ///
  /// Example:
  /// ```dart
  /// final response = await apiFileService.sendMessageWithFile(
  ///   questionId: 'question-uuid',
  ///   content: 'Check this file',
  ///   contentType: 2, // file
  ///   file: File('/path/to/document.pdf'),
  ///   fileCaption: 'Important document',
  /// );
  /// ```
  Future<Map<String, dynamic>> sendMessageWithFile({
    required String questionId,
    required String content,
    required int contentType,
    String? replyToMessageId,
    File? file,
    String? fileCaption,
  }) async {
    try {
      developer.log(
        'Sending message with file to question: $questionId',
        name: 'ApiFileService',
      );

      final formDataMap = <String, dynamic>{
        'QuestionId': questionId,
        'Content': content,
        'ContentType': contentType,
      };

      if (replyToMessageId != null) {
        formDataMap['ReplyToMessageId'] = replyToMessageId;
      }

      if (file != null) {
        formDataMap['File'] = await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        );
      }

      if (fileCaption != null) {
        formDataMap['FileCaption'] = fileCaption;
      }

      final formData = FormData.fromMap(formDataMap);

      // Note: This endpoint might need adjustment based on actual backend API
      final response = await _dio.post(
        '/api/Messages', // Verify this endpoint with backend
        data: formData,
      );

      developer.log('Message sent successfully', name: 'ApiFileService');
      return response.data as Map<String, dynamic>;
    } catch (e, stackTrace) {
      developer.log(
        'Error sending message with file',
        name: 'ApiFileService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Add a reaction to a message (REST API fallback)
  ///
  /// POST /api/Messages/{messageId}/reactions (hypothetical)
  ///
  /// Example:
  /// ```dart
  /// await apiFileService.addReaction(
  ///   messageId: 'message-uuid',
  ///   reaction: '👍',
  /// );
  /// ```
  Future<Map<String, dynamic>> addReaction({
    required String messageId,
    required String reaction,
  }) async {
    try {
      developer.log(
        'Adding reaction "$reaction" to message: $messageId',
        name: 'ApiFileService',
      );

      final response = await _dio.post(
        '/api/Messages/$messageId/reactions',
        data: {
          'Reaction': reaction,
        },
      );

      developer.log('Reaction added successfully', name: 'ApiFileService');
      return response.data as Map<String, dynamic>;
    } catch (e, stackTrace) {
      developer.log(
        'Error adding reaction',
        name: 'ApiFileService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Remove a reaction from a message (REST API fallback)
  ///
  /// DELETE /api/Messages/{messageId}/reactions/{reactionId}
  ///
  /// Example:
  /// ```dart
  /// await apiFileService.removeReaction(
  ///   messageId: 'message-uuid',
  ///   reactionId: 'reaction-uuid',
  /// );
  /// ```
  Future<Map<String, dynamic>> removeReaction({
    required String messageId,
    required String reactionId,
  }) async {
    try {
      developer.log(
        'Removing reaction $reactionId from message: $messageId',
        name: 'ApiFileService',
      );

      final response = await _dio.delete(
        '/api/Messages/$messageId/reactions/$reactionId',
      );

      developer.log('Reaction removed successfully', name: 'ApiFileService');
      return response.data as Map<String, dynamic>;
    } catch (e, stackTrace) {
      developer.log(
        'Error removing reaction',
        name: 'ApiFileService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
