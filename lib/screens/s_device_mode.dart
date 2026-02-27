import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/aoa_provider.dart';
import '../widgets/w_glass_panel.dart';
import '../widgets/w_console_log.dart';

class DeviceModeScreen extends ConsumerStatefulWidget {
  const DeviceModeScreen({super.key});

  static const String routeName = 's_device_mode';

  @override
  ConsumerState<DeviceModeScreen> createState() => _DeviceModeScreenState();
}

class _DeviceModeScreenState extends ConsumerState<DeviceModeScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aoaProvider);
    final notifier = ref.read(aoaProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              Expanded(
                child: Row(
                  children: [
                    WGlassPanel(width: 320, child: _buildLeftPanel(notifier)),
                    const SizedBox(width: 20),
                    Expanded(
                      child: WGlassPanel(
                        child: WConsoleLog(
                          logs: state.logs,
                          onClear: notifier.clearLogs,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
          '디바이스 모드',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const Spacer(),
        _buildStatusIndicator(),
      ],
    );
  }

  Widget _buildStatusIndicator() {
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
      child: const Row(
        children: [
          Icon(Icons.usb_rounded, size: 18, color: Color(0xFF6366F1)),
          SizedBox(width: 10),
          Text(
            '호스트 대기 중...',
            style: TextStyle(
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
          '기기 제어',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: const Text(
            '이 기기는 타겟(Device)으로 동작합니다. 호스트 기기에서 먼저 AOA 핸드셰이크를 시작해야 합니다.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          icon: const Icon(Icons.sync_rounded),
          label: const Text('통신 채널 연결'),
          onPressed: notifier.setupCommunication,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981).withOpacity(0.08),
            foregroundColor: const Color(0xFF10B981),
            side: const BorderSide(color: Color(0xFF10B981)),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          '메시지 전송',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _messageController,
          decoration: const InputDecoration(
            hintText: '호스트에게 보낼 응답...',
            hintStyle: TextStyle(fontSize: 14),
          ),
          onSubmitted: (val) {
            if (val.isNotEmpty) {
              notifier.sendMessage(val);
              _messageController.clear();
            }
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.send_rounded),
          label: const Text('호스트로 전송'),
          onPressed: () {
            if (_messageController.text.isNotEmpty) {
              notifier.sendMessage(_messageController.text);
              _messageController.clear();
            }
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }
}
