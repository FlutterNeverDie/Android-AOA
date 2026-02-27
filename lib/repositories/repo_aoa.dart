import 'package:flutter/services.dart';

class RepoAoa {
  static const _methodChannel = MethodChannel('com.scspro.aoa/communication');
  static const _eventChannel = EventChannel('com.scspro.aoa/events');

  Stream<String> get logStream =>
      _eventChannel.receiveBroadcastStream().map((event) => event as String);

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

  // Device mode specific (if any native listeners are needed)
  Future<void> setAppMode(String mode) async {
    await _methodChannel.invokeMethod('setAppMode', {'mode': mode});
  }
}
