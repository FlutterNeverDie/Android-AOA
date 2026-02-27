import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/m_aoa.dart';
import '../repositories/repo_aoa.dart';

enum AppMode { selection, host, device }

class AoaState {
  final AppMode mode;
  final List<MAoaLog> logs;
  final bool isConnected;

  AoaState({
    this.mode = AppMode.selection,
    this.logs = const [],
    this.isConnected = false,
  });

  AoaState copyWith({AppMode? mode, List<MAoaLog>? logs, bool? isConnected}) {
    return AoaState(
      mode: mode ?? this.mode,
      logs: logs ?? this.logs,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

class AoaNotifier extends StateNotifier<AoaState> {
  final RepoAoa _repo; 

  AoaNotifier(this._repo) : super(AoaState()) {
    _repo.logStream.listen((msg) {
      LogType type = LogType.system;

      // 네이티브에서 넘어오는 한글 로그 패턴 매칭
      if (msg.contains('보냄:') || msg.contains('→ Sent:')) {
        type = LogType.sent;
      } else if (msg.contains('수신됨:') || msg.contains('Received:')) {
        type = LogType.received;
      } else if (msg.contains('오류') ||
          msg.contains('실패') ||
          msg.contains('Error') ||
          msg.contains('Failed')) {
        type = LogType.error;
      }

      addLog(msg, type: type);
    });
  }

  void setMode(AppMode mode) {
    state = state.copyWith(mode: mode);
    _repo.setAppMode(mode.name);
  }

  void addLog(String message, {LogType type = LogType.system}) {
    state = state.copyWith(
      logs: [
        ...state.logs,
        MAoaLog(timestamp: DateTime.now(), message: message, type: type),
      ],
    );
  }

  void clearLogs() {
    state = state.copyWith(logs: []);
  }

  Future<void> checkHostSupport() async {
    final supported = await _repo.checkSupport();
    addLog('호스트 지원 여부 확인: ${supported ? "지원됨" : "장치를 찾을 수 없음"}');
  }

  Future<void> startHostHandshake(
    String manuf,
    String model,
    String ver,
  ) async {
    addLog('호스트 모드 핸드셰이크를 시작합니다...');
    await _repo.startHostMode(manufacturer: manuf, model: model, version: ver);
  }

  Future<void> setupCommunication() async {
    addLog('통신 채널 동기화 시도 중...');
    final success = await _repo.setupCommunication();
    state = state.copyWith(isConnected: success);
    if (success) {
      addLog('통신 채널이 활성화되었습니다.');
    }
  }

  Future<void> sendMessage(String msg) async {
    final success = await _repo.sendMessage(msg);
    if (success) {
      addLog('보냄: $msg', type: LogType.sent);
    } else {
      addLog('메시지 전송 실패', type: LogType.error);
    }
  }
}

final aoaRepositoryProvider = Provider((ref) => RepoAoa());

final aoaProvider = StateNotifierProvider<AoaNotifier, AoaState>((ref) {
  final repo = ref.watch(aoaRepositoryProvider);
  return AoaNotifier(repo);
});
