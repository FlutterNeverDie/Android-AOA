import 'package:flutter/services.dart';

/// AOA(Android Open Accessory) 통신을 위한 로우레벨 저장소 클래스
/// 네이티브(Android/Kotlin)와 직접 통신하는 MethodChannel 및 EventChannel을 관리합니다.
class RepoAoa {
  // 네이티브와 약속된 채널명
  static const _methodChannel = MethodChannel('com.scspro.aoa/communication');
  static const _eventChannel = EventChannel('com.scspro.aoa/events');

  /// 네이티브로부터 실시간 이벤트를 받아오는 스트림 (로그, 수신 데이터 등)
  Stream<String> get logStream =>
      _eventChannel.receiveBroadcastStream().map((event) => event as String);

  /// 현재 기기가 USB 호스트 모드를 지원하는지 확인
  Future<bool> checkSupport() async {
    try {
      final bool? result = await _methodChannel.invokeMethod<bool>(
        'checkSupport',
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// USB 호스트에게 자신의 정보를 전달하고 AOA 핸드셰이크를 시작 (호스트 모드용)
  Future<void> startHostMode({
    required String manufacturer,
    required String model,
    required String version,
  }) async {
    await _methodChannel.invokeMethod('startAccessory', {
      'manufacturer': manufacturer,
      'model': model,
      'version': version,
    });
  }

  /// 네이티브 통신 채널(USB 읽기/쓰기 루프)을 설정하고 연결을 시도
  Future<bool> setupCommunication() async {
    try {
      final bool? result = await _methodChannel.invokeMethod<bool>(
        'setupCommunication',
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// 연결된 상대방 기기에게 메시지(문자열)를 전송
  Future<bool> sendMessage(String message) async {
    try {
      final bool? result = await _methodChannel.invokeMethod<bool>(
        'sendMessage',
        {'message': message},
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// 현재 앱의 모드(Host/Device)를 네이티브에 설정
  Future<void> setAppMode(String mode) async {
    await _methodChannel.invokeMethod('setAppMode', {'mode': mode});
  }
}
