class MAoaLog {
  final DateTime timestamp;
  final String message;
  final LogType type;

  MAoaLog({
    required this.timestamp,
    required this.message,
    this.type = LogType.system,
  });

  String get formattedTime =>
      '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
}

enum LogType { system, sent, received, error }

class MAoaDevice {
  final String manufacturer;
  final String model;
  final String version;
  final String? serialNumber;

  MAoaDevice({
    required this.manufacturer,
    required this.model,
    required this.version,
    this.serialNumber,
  });
}
