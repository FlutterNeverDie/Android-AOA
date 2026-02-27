import 'm_aoa.dart';
import 'm_pending_file.dart';

enum AppMode { selection, host, device }

class AoaState {
  final AppMode mode;
  final List<MAoaLog> logs;
  final bool isConnected;
  final List<PendingMenuFile> pendingFiles;
  final String fileBuffer; // 파일 조각을 모으는 버퍼
  final bool isReceivingFile; // 파일 수신 중인지 여부

  final bool isRemoteLocked; // 상대방이 사용 중인지 여부
  final String? lockedBy; // 누구에 의해 잠겼는지 (Host/Device)

  AoaState({
    this.mode = AppMode.selection,
    this.logs = const [],
    this.isConnected = false,
    this.pendingFiles = const [],
    this.fileBuffer = '',
    this.isReceivingFile = false,
    this.isRemoteLocked = false,
    this.lockedBy,
  });

  AoaState copyWith({
    AppMode? mode,
    List<MAoaLog>? logs,
    bool? isConnected,
    List<PendingMenuFile>? pendingFiles,
    String? fileBuffer,
    bool? isReceivingFile,
    bool? isRemoteLocked,
    String? lockedBy,
  }) {
    return AoaState(
      mode: mode ?? this.mode,
      logs: logs ?? this.logs,
      isConnected: isConnected ?? this.isConnected,
      pendingFiles: pendingFiles ?? this.pendingFiles,
      fileBuffer: fileBuffer ?? this.fileBuffer,
      isReceivingFile: isReceivingFile ?? this.isReceivingFile,
      isRemoteLocked: isRemoteLocked ?? this.isRemoteLocked,
      lockedBy: lockedBy ?? this.lockedBy,
    );
  }
}
