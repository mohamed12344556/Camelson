import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import '../cache/shared_pref_helper.dart';
import '../constants/key_strings.dart';

class DeviceIdService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static String? _cachedDeviceId;

  static Future<String> getDeviceId() async {
    // Return cached value if available
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    // Try to get from storage first
    final storedId = await SharedPrefHelper.getString(StorageKeys.deviceId);
    if (storedId != null && storedId.isNotEmpty) {
      _cachedDeviceId = storedId;
      return storedId;
    }

    // Generate new device ID
    String deviceId;
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        // Use androidId or generate a unique identifier
        deviceId = androidInfo.id ?? 'EOL_MOBILE_APP';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        // Use identifierForVendor
        deviceId = iosInfo.identifierForVendor ?? 'EOL_MOBILE_APP';
      } else {
        deviceId = 'EOL_MOBILE_APP';
      }
    } catch (e) {
      // Fallback to default if device info fails
      deviceId = 'EOL_MOBILE_APP';
    }

    // Cache and store the device ID
    _cachedDeviceId = deviceId;
    await SharedPrefHelper.setData(StorageKeys.deviceId, deviceId);

    return deviceId;
  }

  static Future<void> clearDeviceId() async {
    _cachedDeviceId = null;
    await SharedPrefHelper.removeData(StorageKeys.deviceId);
  }
}
