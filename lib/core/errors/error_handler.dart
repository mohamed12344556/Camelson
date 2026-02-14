import 'package:dio/dio.dart';

import 'api_error_model.dart';

class ApiErrorHandler {
  static ApiErrorModel handle(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionError:
          return ApiErrorModel(
            errorMessage: ErrorData(
              message: 'Connection to server failed',
              code: 500,
            ),
            status: false,
          );
        case DioExceptionType.cancel:
          return ApiErrorModel(
            errorMessage: ErrorData(
              message: "Request to the server was cancelled",
              code: 499,
            ),
            status: false,
          );
        case DioExceptionType.connectionTimeout:
          return ApiErrorModel(
            errorMessage: ErrorData(
              message: "Connection timeout with the server",
              code: 408,
            ),
            status: false,
          );
        case DioExceptionType.unknown:
          return ApiErrorModel(
            errorMessage: ErrorData(
              message:
                  "Connection to the server failed due to internet connection",
              code: 0,
            ),
            status: false,
          );
        case DioExceptionType.receiveTimeout:
          return ApiErrorModel(
            errorMessage: ErrorData(
              message: "Receive timeout in connection with the server",
              code: 408,
            ),
            status: false,
          );
        case DioExceptionType.badResponse:
          return _handleError(error.response?.statusCode, error.response?.data);
        case DioExceptionType.sendTimeout:
          return ApiErrorModel(
            errorMessage: ErrorData(
              message: "Send timeout in connection with the server",
              code: 408,
            ),
            status: false,
          );
        default:
          return ApiErrorModel(
            errorMessage: ErrorData(
              message: "Something went wrong",
              code: 500,
            ),
            status: false,
          );
      }
    } else {
      return ApiErrorModel(
        errorMessage: ErrorData(
          message: 'Unknown error occurred',
          code: 500,
        ),
        status: false,
      );
    }
  }

  static ApiErrorModel _handleError(int? statusCode, dynamic response) {
    // Handle different error response formats
    String errorMessage = 'Unknown error occurred';
    int errorCode = statusCode ?? 500;

    if (response != null) {
      // New backend format: { "error": "message" } or { "message": "text", "errors": [...] }
      if (response['error'] is String) {
        errorMessage = response['error'];
      } else if (response['message'] is String) {
        errorMessage = response['message'];
        // Check if there are specific errors in errors array
        if (response['errors'] is List && (response['errors'] as List).isNotEmpty) {
          errorMessage = (response['errors'] as List).first.toString();
        }
      } else if (response['error'] is Map) {
        // Old backend format: { "error": { "description": "...", "statusCode": 500 } }
        errorMessage = response['error']?['description'] ?? errorMessage;
        errorCode = response['error']?['statusCode'] ?? errorCode;
      }
    }

    return ApiErrorModel(
      errorMessage: ErrorData(
        message: errorMessage,
        code: errorCode,
      ),
      status: false,
      data: response?['data'],
    );
  }
}
