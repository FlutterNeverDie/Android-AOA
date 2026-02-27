import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/aoa_provider.dart';
import '../widgets/w_glass_panel.dart';
import '../widgets/w_console_log.dart';

class HostModeScreen extends ConsumerStatefulWidget {
  const HostModeScreen({super.key});

  static const String routeName = 's_host_mode';

  @override
  ConsumerState<HostModeScreen> createState() => _HostModeScreenState();
}

class _HostModeScreenState extends ConsumerState<HostModeScreen> {
  final TextEditingController _manufacturerController = TextEditingController(
    text: 'SCS PRO',
  );
  final TextEditingController _modelController = TextEditingController(
    text: 'NMP-10',
  );
  final TextEditingController _versionController = TextEditingController(
    text: '1.0',
  );
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aoaProvider);
    final notifier = ref.read(aoaProvider.notifier);

    return Scaffold(
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
                          child: _buildLeftPanel(notifier),
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
                          child: _buildRightPanel(notifier),
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

  Widget _buildLeftPanel(AoaNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '제어 패널',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView(
            children: [
              _buildActionButton(
                'AOA 지원 확인',
                Icons.search_rounded,
                notifier.checkHostSupport,
                const Color(0xFF6366F1),
              ),
              const SizedBox(height: 24),
              const Text(
                '장치 식별 정보',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 12),
              _buildModernTextField(
                _manufacturerController,
                '제조사 (Manufacturer)',
              ),
              _buildModernTextField(_modelController, '모델명 (Model)'),
              _buildModernTextField(_versionController, '버전 (Version)'),
              _buildActionButton('액세서리 모드 시작', Icons.bolt_rounded, () {
                notifier.startHostHandshake(
                  _manufacturerController.text,
                  _modelController.text,
                  _versionController.text,
                );
              }, const Color(0xFF10B981)),
              const SizedBox(height: 24),
              const Text(
                '통신 설정',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                '통신 채널 개설',
                Icons.sync_rounded,
                notifier.setupCommunication,
                const Color(0xFFF59E0B),
              ),
              const SizedBox(height: 24),
              _buildChatInput(notifier),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRightPanel(AoaNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '기타 기능',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 20),
        _buildSubButton(
          '장치 스캔',
          Icons.refresh_rounded,
          () => notifier.checkHostSupport(),
        ),
        _buildSubButton('USB 권한 확인', Icons.vpn_key_rounded, () {}),
        _buildSubButton('네이티브 초기화', Icons.restart_alt_rounded, () {}),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFF94A3B8),
                size: 32,
              ),
              const SizedBox(height: 12),
              const Text(
                'SCS PRO NMP-10\nAndroid 11 전용',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 20),
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.08),
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.2)),
          minimumSize: const Size(double.infinity, 54),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildChatInput(AoaNotifier notifier) {
    return Column(
      children: [
        TextField(
          controller: _messageController,
          decoration: const InputDecoration(
            hintText: '메시지를 입력하세요...',
            hintStyle: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
          ),
          onSubmitted: (val) {
            if (val.isNotEmpty) {
              notifier.sendMessage(val);
              _messageController.clear();
            }
          },
        ),
        const SizedBox(height: 12),
        _buildActionButton('메시지 전송', Icons.send_rounded, () {
          if (_messageController.text.isNotEmpty) {
            notifier.sendMessage(_messageController.text);
            _messageController.clear();
          }
        }, const Color(0xFF6366F1)),
      ],
    );
  }

  Widget _buildSubButton(String label, IconData icon, VoidCallback onTap) {
    return SizedBox(
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
