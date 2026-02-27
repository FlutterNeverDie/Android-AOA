import 'package:flutter/material.dart';
import '../model/m_aoa.dart';

class WConsoleLog extends StatefulWidget {
  final List<MAoaLog> logs;
  final VoidCallback onClear;

  const WConsoleLog({super.key, required this.logs, required this.onClear});

  @override
  State<WConsoleLog> createState() => _WConsoleLogState();
}

class _WConsoleLogState extends State<WConsoleLog> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(WConsoleLog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.logs.length != oldWidget.logs.length) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '시스템 콘솔',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            TextButton.icon(
              onPressed: widget.onClear,
              icon: const Icon(Icons.delete_sweep_rounded, size: 20),
              label: const Text('비우기'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              // 밝은 테마에 어울리는 부드러운 다크 색상 또는 아주 연한 회색
              color: const Color(0xFF1E293B), // 콘솔은 가독성을 위해 다크 유지
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SelectionArea(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: widget.logs.length,
                itemBuilder: (context, index) {
                  final log = widget.logs[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 13,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(
                            text: '${log.formattedTime} ',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                          ),
                          TextSpan(
                            text: log.message,
                            style: TextStyle(
                              color: _getLogColor(log.type),
                              fontWeight: log.type != LogType.system
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getLogColor(LogType type) {
    switch (type) {
      case LogType.sent:
        return const Color(0xFF4ADE80); // Bright Green
      case LogType.received:
        return const Color(0xFFFB923C); // Bright Orange
      case LogType.error:
        return const Color(0xFFF87171); // Bright Red
      case LogType.system:
        return const Color(0xFFE2E8F0); // Off White
    }
  }
}
