import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/aoa_provider.dart';
import '../providers/menu_provider.dart';

class WDeviceSubPanel extends ConsumerStatefulWidget {
  final AoaNotifier notifier;

  const WDeviceSubPanel({super.key, required this.notifier});

  @override
  ConsumerState<WDeviceSubPanel> createState() => _WDeviceSubPanelState();
}

class _WDeviceSubPanelState extends ConsumerState<WDeviceSubPanel> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '메뉴 데이터 관리',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 24),
          _buildActionButton(
            label: '메뉴 동기화',
            icon: Icons.folder_open_rounded,
            onPressed: () => _handleImportFromLocal(context),
            color: const Color(0xFF6366F1),
          ),
          const SizedBox(height: 40),
          const Text(
            '파일 전송 및 백업',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            label: '파일 선택 후 전송',
            icon: Icons.upload_file_rounded,
            onPressed: () => _handleFileUpload(context),
            color: const Color(0xFFF97316),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            label: '지정 파일 내보내기',
            icon: Icons.download_rounded,
            onPressed: () => _handleExportToLocal(context),
            color: const Color(0xFF06B6D4),
          ),
        ],
      ),
    );
  }

  /// 고정 경로 (/Download/Recipes.json)에서 파일을 읽어와 확인 후 동기화
  Future<void> _handleImportFromLocal(BuildContext context) async {
    try {
      if (Platform.isAndroid) {
        if (!await _requestPermissions()) return;
      }

      const path = '/storage/emulated/0/Download/Recipes.json';
      final file = File(path);

      if (!await file.exists()) {
        if (mounted) {
          _showSnackBar(
            context,
            'Recipes.json 파일을 찾을 수 없습니다.\n(Download 폴더를 확인해주세요)',
            isError: true,
          );
        }
        return;
      }

      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        throw Exception('파일 내용이 비어있습니다.');
      }

      if (mounted) {
        _showConfirmDialog(context, content);
      }
    } catch (e) {
      _showSnackBar(context, '파일 읽기 오류: $e', isError: true);
    }
  }

  /// 파일 선택 후 상대 기기(호스트)로 전송
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
        _showSnackBar(context, '메뉴 파일이 상대 기기로 전송되었습니다.');
      }
    }
  }

  /// 지정된 경로(/Download/Recipes.json)의 파일을 읽어 호스트 기기로 전송
  Future<void> _handleExportToLocal(BuildContext context) async {
    try {
      if (Platform.isAndroid) {
        if (!await _requestPermissions()) return;
      }

      const path = '/storage/emulated/0/Download/Recipes.json';
      final file = File(path);

      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.trim().isEmpty) {
          throw Exception('파일 내용이 비어있습니다.');
        }

        await widget.notifier.sendMenuFile(content);
        if (mounted) { 
          _showSnackBar(context, '지정 경로의 Recipes.json을 호스트로 전송했습니다.');
        }
      } else {
        if (mounted) {
          _showSnackBar(context, '파일을 찾을 수 없습니다: $path', isError: true);
        }
      }
    } catch (e) {
      _showSnackBar(context, '파일 전송 실패: $e', isError: true);
    }
  }

  Future<bool> _requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) status = await Permission.storage.request();

    if (await Permission.manageExternalStorage.isRestricted ||
        !await Permission.manageExternalStorage.isGranted) {
      await Permission.manageExternalStorage.request();
    }
    return status.isGranted;
  }

  void _showConfirmDialog(BuildContext context, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로컬 데이터 확인'),
        content: const Text('파일 내용을 확인하고 동기화하시겠습니까?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () => _showJsonViewer(context, content),
            child: const Text(
              '내용 확인',
              style: TextStyle(color: Color(0xFF6366F1)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(menuProvider.notifier)
                  .syncMenu(content);
              if (success && context.mounted) {
                _showSnackBar(context, '메뉴가 성공적으로 로드되었습니다.');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            child: const Text('불러오기'),
          ),
        ],
      ),
    );
  }

  void _showJsonViewer(BuildContext context, String json) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'JSON 원본 데이터',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(height: 32),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      json,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '닫기',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFEF4444)
            : const Color(0xFF10B981),
      ),
    );
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
          backgroundColor: isPrimary ? color : color.withOpacity(0.08),
          foregroundColor: isPrimary ? Colors.white : color,
          elevation: 0,
          side: isPrimary ? null : BorderSide(color: color.withOpacity(0.2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
