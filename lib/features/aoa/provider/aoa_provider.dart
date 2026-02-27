import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../model/m_aoa.dart';
import '../model/m_aoa_state.dart';
import '../model/m_pending_file.dart';
import '../repository/repo_aoa.dart';

/// AOA 통신의 비즈니스 로직을 담당하는 Notifier 클래스
/// 메시지 파싱, 파일 청크 전송, 상태 업데이트 등을 관리합니다.
class AoaNotifier extends StateNotifier<AoaState> {
  final RepoAoa _repo;

  AoaNotifier(this._repo) : super(AoaState()) {
    // 네이티브 이벤트를 리슨하여 상태를 실시간 업데이트
    _repo.logStream.listen(_handleNativeEvent);
  }

  /// 네이티브에서 올라온 이벤트를 판별하고 로직 처리 (시스템 메시지 vs 데이터 수신)
  void _handleNativeEvent(String msg) {
    // 1. '[' 또는 '->'로 시작하면 시스템 로그 혹은 연결 상태 처리 (Android Native 출력물)
    if (msg.startsWith('[') || msg.startsWith('->')) {
      _processSystemLog(msg);
      return;
    }

    // 2. 자신이 보낸 메시지의 에코는 콘솔 로그에서 제외 (이미 FlutterSendMessage에서 표시함)
    if (msg.contains('보냄:') || msg.contains('Sent:')) return;

    // 3. 그 외 기기로부터 수신된 실제 데이터 파싱
    _parseIncomingMessage(msg);
  }

  /// 시스템 수준의 로그와 연결/해제 상태를 처리
  void _processSystemLog(String msg) {
    LogType type = LogType.system;
    if (msg.contains('오류') || msg.contains('실패')) type = LogType.error;

    // 네이티브 메시지 내용을 분석하여 연결 상태 동기화
    if (msg.contains('연결됨') ||
        msg.contains('활성화되었습니다') ||
        msg.contains('Connected')) {
      state = state.copyWith(isConnected: true);
    } else if (msg.contains('연결 종료') || msg.contains('Disconnected')) {
      state = state.copyWith(isConnected: false);
    }

    addLog(msg, type: type);
  }

  /// 기기 간 약속된 프로토콜에 따라 수신 메시지를 처리
  void _parseIncomingMessage(String rawMsg) {
    // 접두어 제거 및 공백 정리
    final content = rawMsg
        .replaceFirst('수신됨:', '')
        .replaceFirst('Received:', '')
        .trim();

    // 1. 파일 전송 프로토콜 (FILE_START ~ 데이터 ~ FILE_END)
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

    // 파일 데이터를 받는 중이라면 버퍼에 계속 쌓음
    if (state.isReceivingFile) {
      state = state.copyWith(fileBuffer: state.fileBuffer + content);
      return;
    }

    // 2. 상호 제어 신호 (LOCK:BUSY / LOCK:FREE)
    // 상대방 앱에서 특정 상품을 선택 중이거나 작업 중일 때 화면을 잠그는 용도
    if (content.startsWith('LOCK:')) {
      final isBusy = content.substring(5) == 'BUSY';
      state = state.copyWith(
        isRemoteLocked: isBusy,
        lockedBy: isBusy
            ? (state.mode == AppMode.host ? 'Device' : 'Host')
            : null,
      );
      addLog(isBusy ? '[시스템] 상대방 이용 중 (화면 잠금)' : '[시스템] 상대방 이용 종료 (잠금 해제)');
      return;
    }

    // 3. 비즈니스 로그 (주문 / 결제 / 일반 메시지)
    if (content.startsWith('SELECT:')) {
      addLog('[주문] ${content.substring(7)}');
    } else if (content.startsWith('PAY:')) {
      addLog('[결제] ${content.substring(4)}');
    } else {
      addLog(content, type: LogType.received);
    }
  }

  // --- 외부 위젯에서 호출하는 액션 메서드들 ---

  /// 앱 모드 설정 (Host <-> Device)
  void setMode(AppMode mode) {
    state = state.copyWith(mode: mode);
    _repo.setAppMode(mode.name);
  }

  /// 콘솔 로그 추가
  void addLog(String message, {LogType type = LogType.system}) {
    state = state.copyWith(
      logs: [
        ...state.logs,
        MAoaLog(timestamp: DateTime.now(), message: message, type: type),
      ],
    );
  }

  /// 로그 기록 삭제
  void clearLogs() => state = state.copyWith(logs: []);

  /// 수신 대기 중인 파일 리스트에서 특정 인덱스 제거
  void removePendingFile(int index) {
    final newList = List<PendingMenuFile>.from(state.pendingFiles);
    newList.removeAt(index);
    state = state.copyWith(pendingFiles: newList);
  }

  /// 네이티브 통신 채널 동기화 시도
  Future<void> setupCommunication() async {
    addLog('통신 채널 동기화 시도 중...');
    final success = await _repo.setupCommunication();
    state = state.copyWith(isConnected: success);
    if (success) addLog('통신 채널 활성화 완료');
  }

  /// 문자열 전송
  Future<void> sendMessage(String msg) async {
    final success = await _repo.sendMessage(msg);
    if (success) {
      addLog('보냄: $msg', type: LogType.sent);
    } else {
      addLog('전송 실패', type: LogType.error);
    }
  }

  /// 대용량 JSON 파일을 청크(Chunk) 단위로 쪼개서 상대방에게 전송
  /// (네이티브 버퍼 제한 및 안정적인 수신을 위해 분할 전송)
  Future<void> sendMenuFile(String jsonContent) async {
    await sendMessage('FILE_START');
    const int chunkSize = 8192; // 8KB 단위로 전송
    int index = 0;
    while (index < jsonContent.length) {
      int end = (index + chunkSize > jsonContent.length)
          ? jsonContent.length
          : index + chunkSize;
      await sendMessage(jsonContent.substring(index, end));
      index = end;
      // 수신부 버퍼 처리를 위해 아주 짧은 딜레이 부여
      await Future.delayed(const Duration(milliseconds: 50));
    }
    await sendMessage('FILE_END');
  }

  /// 호스트 지원 여부 확인 (네트워크/USB 환경 체크)
  Future<void> checkHostSupport() async {
    final supported = await _repo.checkSupport();
    addLog('호스트 지원 여부 확인: ${supported ? "지원됨" : "장치를 찾을 수 없음"}');
  }

  /// 호스트 모드 핸드셰이크 시작
  Future<void> startHostHandshake(
    String manuf,
    String model,
    String ver,
  ) async {
    addLog('호스트 모드 핸드셰이크를 시작합니다...');
    await _repo.startHostMode(manufacturer: manuf, model: model, version: ver);
  }

  // --- 비즈니스 로직 전용 메시지 래퍼 ---
  Future<void> sendSelectItem(String item) => sendMessage('SELECT:$item');
  Future<void> sendOrderPay(String detail) => sendMessage('PAY:$detail');
  Future<void> sendLockSignal(bool isBusy) =>
      sendMessage('LOCK:${isBusy ? "BUSY" : "FREE"}');
}

// Providers
final aoaRepositoryProvider = Provider((ref) => RepoAoa());

final aoaProvider = StateNotifierProvider<AoaNotifier, AoaState>((ref) {
  final repo = ref.watch(aoaRepositoryProvider);
  return AoaNotifier(repo);
});
