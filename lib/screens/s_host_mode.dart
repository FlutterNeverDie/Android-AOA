import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/aoa_provider.dart';
import '../widgets/w_glass_panel.dart';
import '../widgets/w_console_log.dart';
import '../dialogs/d_aoa_info.dart';

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
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.72,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 좌측 제어 패널
                        WGlassPanel(
                          width: 320,
                          child: _buildLeftPanel(state, notifier),
                        ),
                        const SizedBox(width: 20),
                        // 중앙 콘솔
                        Expanded(
                          child: WGlassPanel(
                            child: WConsoleLog(
                              logs: state.logs,
                              onClear: notifier.clearLogs,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // 우측 서브 패널
                        WGlassPanel(
                          width: 240,
                          child: _buildRightPanel(state, notifier),
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
            '설정 및 도구',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 20),
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
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
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
}
