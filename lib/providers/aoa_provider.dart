import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/m_aoa.dart';
import '../repositories/repo_aoa.dart';

import '../models/m_pending_file.dart';

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
    List<MAoaLog>? currentLogs,
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

class AoaNotifier extends StateNotifier<AoaState> {
  final RepoAoa _repo;

  AoaNotifier(this._repo) : super(AoaState()) {
    _repo.logStream.listen((msg) {
      // 1. 상태 업데이트 및 네이티브 내부 로그 판별
      if (msg.startsWith('[') || msg.startsWith('->')) {
        LogType type = LogType.system;
        if (msg.contains('오류') || msg.contains('실패')) type = LogType.error;

        // 연결 상태 동기화
        if (msg.contains('연결됨') ||
            msg.contains('활성화되었습니다') ||
            msg.contains('Connected') ||
            msg.contains('성공')) {
          state = state.copyWith(isConnected: true);
        } else if (msg.contains('연결 종료') ||
            msg.contains('Disconnected') ||
            msg.contains('중단')) {
          state = state.copyWith(isConnected: false);
        }

        addLog(msg, type: type);
        return;
      }

      // 2. 보낸 메시지 로그 (네이티브 출력물)
      if (msg.contains('보냄:') || msg.contains('Sent:')) {
        // 이미 Flutter sendMessage에서 로그를 남기므로 여기서는 무시하거나 전용 타입 부여
        return;
      }

      // 3. 그 외의 모든 데이터는 AOA 수신 데이터로 간주하여 파서로 보냄
      _parseIncomingMessage(msg);
    });
  }

  void _parseIncomingMessage(String rawMsg) {
    // 레거시 접두어가 남아있을 경우를 대비해 제거 후 공백 정리
    final content = rawMsg
        .replaceFirst('수신됨:', '')
        .replaceFirst('Received:', '')
        .trim();

    // 1. 파일 전송 마커 처리
    if (content == 'FILE_START') {
      state = state.copyWith(fileBuffer: '', isReceivingFile: true);
      addLog('[파일] 데이터 수신 시작...', type: LogType.system);
      return;
    }

    if (content == 'FILE_END') {
      if (state.isReceivingFile) {
        state = state.copyWith(
          pendingFiles: [
            ...state.pendingFiles,
            PendingMenuFile(
              receivedAt: DateTime.now(),
              content: state.fileBuffer,
            ),
          ],
          isReceivingFile: false,
        );
        addLog('[파일] 데이터 수신 완료', type: LogType.system);
      }
      return;
    }

    // 2. 파일 데이터 수신 중 처리
    if (state.isReceivingFile) {
      state = state.copyWith(fileBuffer: state.fileBuffer + content);
      return;
    }

    // 3. 상호 제어 (LOCK) 플래그 처리
    if (content.startsWith('LOCK:')) {
      final status = content.substring(5);
      if (status == 'BUSY') {
        state = state.copyWith(
          isRemoteLocked: true,
          lockedBy: state.mode == AppMode.host ? 'Device' : 'Host',
        );
        addLog('[시스템] 상대방이 주문을 시작했습니다. (화면 잠금)', type: LogType.system);
      } else if (status == 'FREE') {
        state = state.copyWith(isRemoteLocked: false, lockedBy: null);
        addLog('[시스템] 상대방 이용 종료. (잠금 해제)', type: LogType.system);
      }
      return;
    }

    // 4. 타입별 메시지 처리
    if (content.startsWith('SELECT:')) {
      final itemName = content.substring(7);
      addLog('[주문] $itemName', type: LogType.system);
    } else if (content.startsWith('PAY:')) {
      final detail = content.substring(4);
      addLog('[결제] $detail', type: LogType.system);
    } else if (content.contains(':') && !content.startsWith('http')) {
      // 기타 플래그 형식
      addLog('[메시지] $content', type: LogType.received);
    } else {
      // 일반 텍스트
      addLog(content, type: LogType.received);
    }
  }

  void removePendingFile(int index) {
    final newList = List<PendingMenuFile>.from(state.pendingFiles);
    newList.removeAt(index);
    state = state.copyWith(pendingFiles: newList);
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

  Future<void> sendMenuFile(String jsonContent) async {
    await sendMessage('FILE_START');
    const int chunkSize = 8192;
    int index = 0;
    while (index < jsonContent.length) {
      int end = index + chunkSize;
      if (end > jsonContent.length) end = jsonContent.length;
      await sendMessage(jsonContent.substring(index, end));
      index = end;
      await Future.delayed(const Duration(milliseconds: 50));
    }
    await sendMessage('FILE_END');
  }

  Future<void> sendSelectItem(String itemName) async {
    await sendMessage('SELECT:$itemName');
  }

  Future<void> sendOrderPay(String orderDetail) async {
    await sendMessage('PAY:$orderDetail');
  }

  Future<void> sendLockSignal(bool isBusy) async {
    await sendMessage('LOCK:${isBusy ? "BUSY" : "FREE"}');
  }
}

final aoaRepositoryProvider = Provider((ref) => RepoAoa());

final aoaProvider = StateNotifierProvider<AoaNotifier, AoaState>((ref) {
  final repo = ref.watch(aoaRepositoryProvider);
  return AoaNotifier(repo);
});
