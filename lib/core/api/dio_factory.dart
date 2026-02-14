import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'api_constants.dart';
import 'auth_interceptor.dart';
import 'cache_config.dart';
import 'headers_interceptor.dart';

class DioFactory {
  static Dio? _dio;
  static AuthInterceptor? _authInterceptor;
  static HeadersInterceptor? _headersInterceptor;

  static Dio getDio({bool withAuth = true, bool withCache = true}) {
    if (_dio == null) {
      _dio = Dio();
      _dio!.options.baseUrl = ApiConstants.baseUrl;
      _dio!.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Add cache interceptor first (before auth and headers)
      if (withCache) {
        // Add custom interceptor to override cache policy for specific endpoints
        _dio!.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              // Check if this is a real-time API endpoint (Questions, Community, SignalR)
              final path = options.path.toLowerCase();

              if (path.contains('/api/questions') ||
                  path.contains('/communityhub') ||
                  path.contains('community')) {
                // Override cache options for real-time endpoints
                options.extra.addAll(CacheConfig.getNoCacheOptions().toExtra());
              }

              return handler.next(options);
            },
          ),
        );

        // Add the main cache interceptor
        _dio!.interceptors.add(
          DioCacheInterceptor(options: CacheConfig.getCacheOptions()),
        );
      }

      // Add headers interceptor (for all requests)
      _headersInterceptor = HeadersInterceptor();
      _dio!.interceptors.add(_headersInterceptor!);

      // Add auth interceptor if needed
      if (withAuth) {
        _authInterceptor = AuthInterceptor();
        _dio!.interceptors.add(_authInterceptor!);
      }

      // Add logger last
      _dio!.interceptors.add(
        PrettyDioLogger(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
          compact: false,
          maxWidth: 90,
        ),
      );
    }
    return _dio!;
  }

  static Dio getCleanDio() {
    final cleanDio = Dio();
    cleanDio.options.baseUrl = ApiConstants.baseUrl;
    cleanDio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add headers interceptor to clean dio as well
    cleanDio.interceptors.add(HeadersInterceptor());

    return cleanDio;
  }

  static void setAuthHeader(String accessToken) {
    _dio?.options.headers['Authorization'] = 'Bearer $accessToken';
  }

  static void clearAuthHeaders() {
    _dio?.options.headers.remove('Authorization');
    _dio?.options.headers.remove('Cookie');
  }

  static void resetDio() {
    _authInterceptor = null;
    _headersInterceptor = null;
    _dio = null;
  }

  /// Clear all cached API responses
  static Future<void> clearCache() async {
    await CacheConfig.clearCache();
  }

  /// Delete specific cache entry by key
  static Future<void> deleteCacheByKey(String key) async {
    await CacheConfig.deleteCacheByKey(key);
  }
}