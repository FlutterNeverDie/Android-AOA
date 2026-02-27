import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/aoa_provider.dart';
import '../widgets/w_glass_panel.dart';
import '../widgets/w_console_log.dart';
import '../widgets/w_host_sub_panel.dart';
import 's_menu_board.dart';

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
                        // 우측 서브 패널 (분리된 위젯 사용)
                        WGlassPanel(
                          width: 320,
                          child: WHostSubPanel(
                            state: state,
                            notifier: notifier,
                            manufacturer: _manuf,
                            model: _model,
                            version: _ver,
                            onUpdateDeviceInfo: (m, mo, v) {
                              setState(() {
                                _manuf = m;
                                _model = mo;
                                _ver = v;
                              });
                            },
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
            color: Colors.black.withValues(alpha: 0.03),
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
    return Column(
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
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
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
          label: '메뉴판 보기',
          icon: Icons.grid_view_rounded,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MenuBoardScreen(),
                settings: const RouteSettings(name: MenuBoardScreen.routeName),
              ),
            );
          },
          color: const Color(0xFFEC4899),
        ),
      ],
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
          backgroundColor: color.withValues(alpha: 0.1),
          foregroundColor: color,
          elevation: 0,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withValues(alpha: 0.2)),
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
              color: const Color(0xFF6366F1).withValues(alpha: 0.05),
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
}
