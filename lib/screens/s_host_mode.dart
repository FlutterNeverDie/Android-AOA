import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/aoa_provider.dart';
import '../widgets/w_glass_panel.dart';
import '../widgets/w_console_log.dart';
import '../dialogs/d_aoa_info.dart';
import '../providers/menu_provider.dart';
import 's_menu_board.dart';
import 'package:intl/intl.dart';

class HostModeScreen extends ConsumerStatefulWidget {
  const HostModeScreen({super.key});

  static const String routeName = 's_host_mode';

  @override
  ConsumerState<HostModeScreen> createState() => _HostModeScreenState();
}

class _HostModeScreenState extends ConsumerState<HostModeScreen> {
  final TextEditingController _messageController = TextEditingController();

  // 기본 장치 정보
  String _manuf = "SCS PRO";
  String _model = "NMP-10";
  String _ver = "1.0";

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aoaProvider);
    final notifier = ref.read(aoaProvider.notifier);

    return Scaffold(
      resizeToAvoidBottomInset: false, // 레이아웃 안정성을 위해 false 설정
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 좌측 제어 패널
                        WGlassPanel(
                          width: 320,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: _buildLeftPanel(state, notifier),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // 중앙 콘솔
                        Expanded(
                          child: WGlassPanel(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: WConsoleLog(
                                logs: state.logs,
                                onClear: notifier.clearLogs,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // 우측 서브 패널
                        WGlassPanel(
                          width: 320,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: _buildRightPanel(state, notifier),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Color(0xFF64748B),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 16),
        const Text(
          '호스트 모드 설정',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const Spacer(),
        _buildStatusBar(),
      ],
    );
  }

  Widget _buildStatusBar() {
    final isConnected = ref.watch(aoaProvider).isConnected;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isConnected
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            isConnected ? '채널 활성화됨' : '연결 끊김',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel(AoaState state, AoaNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AOA 제어 및 전송',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 20),
          _buildActionButton(
            label: 'AOA 지원 확인',
            icon: Icons.search_rounded,
            onPressed: () => notifier.checkHostSupport(),
            color: const Color(0xFF6366F1),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            label: '액세서리 모드 시작',
            icon: Icons.play_arrow_rounded,
            onPressed: () => notifier.startHostHandshake(_manuf, _model, _ver),
            color: const Color(0xFF10B981),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            label: '통신 채널 개설',
            icon: Icons.lan_rounded,
            onPressed: () => notifier.setupCommunication(),
            color: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 32),
          const Text(
            '메시지 전송',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            decoration: InputDecoration(
              hintText: '메시지를 입력하세요...',
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFF94A3B8),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
            onSubmitted: (val) {
              if (val.isNotEmpty) {
                notifier.sendMessage(val);
                _messageController.clear();
              }
            },
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            label: '메시지 전송',
            icon: Icons.send_rounded,
            onPressed: () {
              if (_messageController.text.isNotEmpty) {
                notifier.sendMessage(_messageController.text);
                _messageController.clear();
              }
            },
            color: const Color(0xFF6366F1),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            label: '메뉴판 보기',
            icon: Icons.grid_view_rounded,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MenuBoardScreen(),
                  settings: const RouteSettings(
                    name: MenuBoardScreen.routeName,
                  ),
                ),
              );
            },
            color: const Color(0xFFEC4899),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel(AoaState state, AoaNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '수신된 설정 파일 (JSON)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: state.pendingFiles.isEmpty
                ? _buildEmptyPendingList()
                : _buildPendingFileList(state, notifier),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),
          const Text(
            '설정 및 도구',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          _buildSubButton(
            label: '장치 정보 설정',
            icon: Icons.settings_suggest_rounded,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => DAoaInfo(
                  initialManuf: _manuf,
                  initialModel: _model,
                  initialVer: _ver,
                  onSave: (m, mo, v) {
                    setState(() {
                      _manuf = m;
                      _model = mo;
                      _ver = v;
                    });
                  },
                ),
              );
            },
          ),
          _buildSubButton(
            label: '로그 지우기',
            icon: Icons.delete_outline_rounded,
            onTap: () => notifier.clearLogs(),
          ),
          _buildSubButton(
            label: '모드 선택 페이지',
            icon: Icons.home_outlined,
            onTap: () => notifier.setMode(AppMode.selection),
          ),
          _buildSubButton(
            label: '강제 연결 종료',
            icon: Icons.link_off_rounded,
            onTap: () {
              // TODO: 명시적 연결 종료 명령 전달 (추후 네이티브 보완 가능)
              notifier.addLog('[안내] 연결 종료 요청됨');
            },
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '현재 설정',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '제조사: $_manuf',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
                Text(
                  '모델명: $_model',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
                Text(
                  '버전: $_ver',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 20),
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          elevation: 0,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withOpacity(0.2)),
          ),
        ),
      ),
    );
  }

  Widget _buildSubButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: TextButton.icon(
          icon: Icon(icon, size: 22, color: const Color(0xFF64748B)),
          label: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: onTap,
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Positioned(
          top: -150,
          left: -150,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF6366F1).withOpacity(0.05),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyPendingList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, color: Color(0xFFCBD5E1), size: 32),
          SizedBox(height: 8),
          Text(
            '수신된 파일 없음',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingFileList(AoaState state, AoaNotifier notifier) {
    return ListView.separated(
      itemCount: state.pendingFiles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final file = state.pendingFiles[index];
        final timeStr = DateFormat('HH:mm:ss').format(file.receivedAt);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.description_outlined,
                    size: 16,
                    color: Color(0xFF6366F1),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '메뉴 구성 ($timeStr)',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final success = await ref
                        .read(menuProvider.notifier)
                        .syncMenu(file.content);
                    if (success) {
                      notifier.removePendingFile(index);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('메뉴 데이터가 동기화되었습니다.')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('동기화', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
