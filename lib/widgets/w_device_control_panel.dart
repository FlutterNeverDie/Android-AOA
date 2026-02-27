import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/aoa_provider.dart';
import '../models/m_aoa.dart';

class WDeviceControlPanel extends StatefulWidget {
  final AoaNotifier notifier;

  const WDeviceControlPanel({super.key, required this.notifier});

  @override
  State<WDeviceControlPanel> createState() => _WDeviceControlPanelState();
}

class _WDeviceControlPanelState extends State<WDeviceControlPanel> {
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
          const SizedBox(height: 32),
          _buildActionButton(
            label: '통신 채널 연결',
            icon: Icons.sync_rounded,
            onPressed: widget.notifier.setupCommunication,
            color: const Color(0xFF10B981),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            label: '메뉴 설정 파일 업로드',
            icon: Icons.upload_file_rounded,
            onPressed: () => _handleFileUpload(context),
            color: const Color(0xFF6366F1),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            label: 'Recipes.json 내보내기',
            icon: Icons.ios_share_rounded,
            onPressed: () => _handleExportRecipes(context),
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

  Future<void> _handleFileUpload(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      await widget.notifier.sendMenuFile(content);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('메뉴 파일이 전송되었습니다.')));
      }
    }
  }

  Future<void> _handleExportRecipes(BuildContext context) async {
    try {
      // 1. 권한 확인 및 요청
      if (Platform.isAndroid) {
        // 일반 저장소 권한 확인
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }

        // Android 11+(SDK 30) 이상을 위한 전체 파일 관리 권한 확인 (필요한 경우)
        if (await Permission.manageExternalStorage.isRestricted ||
            !await Permission.manageExternalStorage.isGranted) {
          await Permission.manageExternalStorage.request();
        }
      }

      const path = '/storage/emulated/0/Download/Recipes.json';
      final file = File(path);

      if (await file.exists()) {
        final content = await file.readAsString();
        // 데이터가 비어있는지 확인
        if (content.trim().isEmpty) {
          throw Exception('파일 내용이 비어있습니다.');
        }

        await widget.notifier.sendMenuFile(content);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Download 폴더의 Recipes.json을 전송했습니다.'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recipes.json 파일을 찾을 수 없습니다. (Download 폴더 확인)'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('파일 접근 오류: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
      widget.notifier.addLog('[오류] 파일 내보내기 실패: $e', type: LogType.error);
    }
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    bool isPrimary = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 20),
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? color : color.withValues(alpha: 0.08),
          foregroundColor: isPrimary ? Colors.white : color,
          elevation: 0,
          side: isPrimary
              ? null
              : BorderSide(color: color.withValues(alpha: 0.2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
