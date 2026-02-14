import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../languages/language_cubit.dart';
import 'api_constants.dart';

class HeadersInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Get device ID
      // final deviceId = await DeviceIdService.getDeviceId();
      final deviceId = 'EOL_MOBILE_APP';

      // Get current language from LanguageCubit
      final language = LanguageCubit.instance.getCurrentLanguageCode();

      // Add required headers
      options.headers[ApiConstants.appSignatureHeaderKey] =
          ApiConstants.appSignature;
      options.headers[ApiConstants.appIdHeaderKey] = deviceId;
      options.headers[ApiConstants.languageHeaderKey] = language;

      debugPrint('Headers Interceptor - Added headers:');
      debugPrint(
        '  ${ApiConstants.appSignatureHeaderKey}: ${ApiConstants.appSignature}',
      );
      debugPrint('  ${ApiConstants.appIdHeaderKey}: $deviceId');
      debugPrint('  ${ApiConstants.languageHeaderKey}: $language');

      handler.next(options);
    } catch (e) {
      debugPrint('Headers Interceptor - Error: $e');
      handler.next(options);
    }
  }
}
