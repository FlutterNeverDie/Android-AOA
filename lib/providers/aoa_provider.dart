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

  AoaState({
    this.mode = AppMode.selection,
    this.logs = const [],
    this.isConnected = false,
    this.pendingFiles = const [],
    this.fileBuffer = '',
    this.isReceivingFile = false,
  });

  AoaState copyWith({
    AppMode? mode,
    List<MAoaLog>? logs,
    bool? isConnected,
    List<PendingMenuFile>? pendingFiles,
    String? fileBuffer,
    bool? isReceivingFile,
  }) {
    return AoaState(
      mode: mode ?? this.mode,
      logs: logs ?? this.logs,
      isConnected: isConnected ?? this.isConnected,
      pendingFiles: pendingFiles ?? this.pendingFiles,
      fileBuffer: fileBuffer ?? this.fileBuffer,
      isReceivingFile: isReceivingFile ?? this.isReceivingFile,
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
        // 원본 수신 로그는 남기되, UI 로그 추가는 _parseIncomingMessage에서 제어함
        _parseIncomingMessage(msg);
      } else if (msg.contains('오류') ||
          msg.contains('실패') ||
          msg.contains('Error') ||
          msg.contains('Failed')) {
        type = LogType.error;
      } else if (msg.contains('연결 종료') || msg.contains('Disconnected')) {
        state = state.copyWith(isConnected: false);
      } else if (msg.contains('연결됨') ||
          msg.contains('활성화되었습니다') ||
          msg.contains('Connected')) {
        state = state.copyWith(isConnected: true);
      }

      addLog(msg, type: type);
    });
  }

  void _parseIncomingMessage(String rawMsg) {
    // 1. 순수 내용 추출 (네이티브 접두어 제거)
    final content = rawMsg
        .replaceFirst('수신됨:', '')
        .replaceFirst('Received:', '')
        .trim();

    // 2. 파일 전송 마커 처리 (시스템/파일 플래그)
    if (content == 'FILE_SYNC_START') {
      state = state.copyWith(fileBuffer: '', isReceivingFile: true);
      addLog('[파일] 메뉴 데이터 수신 시작...', type: LogType.system);
      return;
    }

    if (content == 'FILE_SYNC_END') {
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
        addLog('[파일] 메뉴 동기화 데이터 수신 완료', type: LogType.system);
      }
      return;
    }

    // 3. 파일 데이터 수신 중 처리 (중간 청크들은 로그를 남기지 않음)
    if (state.isReceivingFile) {
      state = state.copyWith(fileBuffer: state.fileBuffer + content);
      return;
    }

    // 4. 타입별 메시지 처리
    if (content.startsWith('SELECT_ITEM:')) {
      final itemName = content.substring('SELECT_ITEM:'.length);
      addLog('[주문] $itemName', type: LogType.system);
    } else if (content.startsWith('ORDER_PAY:')) {
      final list = content.substring('ORDER_PAY:'.length);
      addLog('[결제] $list', type: LogType.system);
    } else if (content.startsWith('ORDER_STATUS:')) {
      final status = content.substring('ORDER_STATUS:'.length);
      addLog('[상태] $status', type: LogType.system);
    } else if (content.startsWith('FILE_SYNC:')) {
      final jsonContent = content.substring('FILE_SYNC:'.length);
      state = state.copyWith(
        pendingFiles: [
          ...state.pendingFiles,
          PendingMenuFile(receivedAt: DateTime.now(), content: jsonContent),
        ],
      );
      addLog('[파일] 단일 패킷 메뉴 데이터 수신됨', type: LogType.system);
    } else if (content.contains(':') && !content.startsWith('http')) {
      // 플래그 형식이지만(콜론 포함) 위에서 처리되지 않은 경우
      addLog('[정의되지 않은 메시지] $content', type: LogType.error);
    } else {
      // 일반 메시지 (채팅 등)
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
    // 크기가 크면 쪼개서 보냄 (청크 전송)
    await sendMessage('FILE_SYNC_START');

    // 8KB씩 쪼개서 전송하여 확실한 전달 도모
    const int chunkSize = 8192;
    int index = 0;
    while (index < jsonContent.length) {
      int end = index + chunkSize;
      if (end > jsonContent.length) end = jsonContent.length;
      await sendMessage(jsonContent.substring(index, end));
      index = end;
      // 너무 빠르면 네이티브 버퍼가 꼬일 수 있으므로 아주 짧은 지연
      await Future.delayed(const Duration(milliseconds: 50));
    }

    await sendMessage('FILE_SYNC_END');
  }

  Future<void> sendOrderStatus(String status) async {
    await sendMessage('ORDER_STATUS:$status');
  }

  Future<void> sendSelectItem(String itemName) async {
    await sendMessage('SELECT_ITEM:$itemName');
  }

  Future<void> sendOrderPay(String orderDetail) async {
    await sendMessage('ORDER_PAY:$orderDetail');
  }
}

final aoaRepositoryProvider = Provider((ref) => RepoAoa());

final aoaProvider = StateNotifierProvider<AoaNotifier, AoaState>((ref) {
  final repo = ref.watch(aoaRepositoryProvider);
  return AoaNotifier(repo);
});
