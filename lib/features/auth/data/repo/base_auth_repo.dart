import 'package:dartz/dartz.dart';

import '../../../../core/core.dart';

abstract class BaseAuthRepository {
  final ApiService _apiService;
  
  BaseAuthRepository(this._apiService);

  Future<Either<ApiErrorModel, T>> handleRequest<T>(
    Future<T> Function() request
  ) async {
    try {
      final response = await request();
      if (_isSuccessResponse(response)) {
        return Right(response);
      }
      return Left(_getErrorFromResponse(response));
    } catch (error) {
      return Left(ApiErrorHandler.handle(error));
    }
  }

  bool _isSuccessResponse(dynamic response) {
    // Check for the new backend structure using 'success' field
    if (response is Map && response.containsKey('success')) {
      return response['success'] == true;
    }
    // Check for response objects with 'success' or 'isSuccess' getter
    try {
      final success = (response as dynamic).success;
      return success == true;
    } catch (_) {
      // Fallback to old structure
      return response?.status == true;
    }
  }

  ApiErrorModel _getErrorFromResponse(dynamic response) {
    // Try to extract error from new backend structure
    try {
      final message = (response as dynamic).message ?? 'Request failed';
      final errors = (response as dynamic).errors;
      return ApiErrorModel(
        errorMessage: ErrorData(
          message: errors != null && errors.isNotEmpty ? errors[0] : message,
        ),
        status: false,
      );
    } catch (_) {
      // Fallback to old structure
      return ApiErrorModel(
        errorMessage: response?.error ?? ErrorData(message: 'Request failed'),
        status: response?.status ?? false,
      );
    }
  }
}