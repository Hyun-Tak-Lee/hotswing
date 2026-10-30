import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 기기 네이티브 제어(화면 상시 켜짐, 생체 인증 등)를 위한 서비스.
class NativeDeviceService {
  /// [NativeDeviceService]의 싱글톤 인스턴스.
  static final NativeDeviceService instance = NativeDeviceService._();
  NativeDeviceService._();

  static const MethodChannel _channel = MethodChannel(
    'com.matching61.hotswing/device',
  );

  /// 화면 상시 켜짐(Wakelock) 상태를 설정합니다.
  Future<void> setKeepScreenOn({required bool enable}) async {
    try {
      await _channel.invokeMethod('setKeepScreenOn', {'enable': enable});
    } on MissingPluginException {
      debugPrint(
        'NativeDeviceService: setKeepScreenOn not implemented on this platform.',
      );
    } on PlatformException catch (e) {
      debugPrint('NativeDeviceService: setKeepScreenOn error: ${e.message}');
    } catch (e) {
      debugPrint('NativeDeviceService: setKeepScreenOn unexpected error: $e');
    }
  }
}

