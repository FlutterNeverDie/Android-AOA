import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/aoa_provider.dart';
import '../../../share/widget/w_action_button.dart';

class WDeviceControlPanel extends ConsumerStatefulWidget {
  final AoaNotifier notifier;

  const WDeviceControlPanel({super.key, required this.notifier});

  @override
  ConsumerState<WDeviceControlPanel> createState() =>
      _WDeviceControlPanelState();
}

class _WDeviceControlPanelState extends ConsumerState<WDeviceControlPanel> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
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
          const SizedBox(height: 24),
          WActionButton(
            label: '통신 채널 연결',
            icon: Icons.sync_rounded,
            onPressed: widget.notifier.setupCommunication,
            color: const Color(0xFF10B981),
          ),
          const SizedBox(height: 32),
          const Text(
            '메세지 전송',
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
              hintText: '호스트에게 보낼 응답...',
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
                widget.notifier.sendMessage(val);
                _messageController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
