import 'package:flutter/material.dart';
import '../../../share/widget/w_glass_panel.dart';

class DAoaInfo extends StatefulWidget {
  final String initialManuf;
  final String initialModel;
  final String initialVer;
  final Function(String, String, String) onSave;

  const DAoaInfo({
    super.key,
    required this.initialManuf,
    required this.initialModel,
    required this.initialVer,
    required this.onSave,
  });

  @override
  State<DAoaInfo> createState() => _DAoaInfoState();
}

class _DAoaInfoState extends State<DAoaInfo> {
  late TextEditingController _manufController;
  late TextEditingController _modelController;
  late TextEditingController _verController;

  @override
  void initState() {
    super.initState();
    _manufController = TextEditingController(text: widget.initialManuf);
    _modelController = TextEditingController(text: widget.initialModel);
    _verController = TextEditingController(text: widget.initialVer);
  }

  @override
  void dispose() {
    _manufController.dispose();
    _modelController.dispose();
    _verController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: WGlassPanel(
        width: 400,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '장치 식별 정보 설정',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'AOA 핸드셰이크 시 전송할 정보입니다.\n디바이스의 필터 설정과 일치해야 합니다.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white60 : Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 24),
              _buildField(context, '제조사 (Manufacturer)', _manufController),
              const SizedBox(height: 16),
              _buildField(context, '모델명 (Model)', _modelController),
              const SizedBox(height: 16),
              _buildField(context, '버전 (Version)', _verController),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      '취소',
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      widget.onSave(
                        _manufController.text,
                        _modelController.text,
                        _verController.text,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('저장하기'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    BuildContext context,
    String label,
    TextEditingController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white38 : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white10 : const Color(0xFFCBD5E1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white10 : const Color(0xFFCBD5E1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
