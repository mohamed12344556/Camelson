import 'dart:io';

import 'package:dio/dio.dart';

import '../../features/auth/data/models/auth_response.dart';
import 'api_constants.dart';
import 'dio_factory.dart';

class ProfileImageService {
  static final Dio _dio = DioFactory.getDio();

  /// Upload profile image using multipart/form-data
  static Future<SimpleResponse> uploadProfileImage(File imageFile) async {
    try {
      // Create multipart file
      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      // Make request
      final response = await _dio.post(
        ApiConstants.updateProfileImage,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      // Parse response
      return SimpleResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }
}
