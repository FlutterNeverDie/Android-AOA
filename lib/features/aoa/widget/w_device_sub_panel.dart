import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import '../provider/aoa_provider.dart';
import '../../menu/provider/menu_provider.dart';
import '../../../share/widget/w_action_button.dart';
import '../../menu/widget/d_menu_import_confirm.dart';

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
          WActionButton(
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
          WActionButton(
            label: '파일 선택 후 전송',
            icon: Icons.upload_file_rounded,
            onPressed: () => _handleFileUpload(context),
            color: const Color(0xFFF97316),
          ),
          const SizedBox(height: 12),
          WActionButton(
            label: '지정 파일 내보내기',
            icon: Icons.send_and_archive_rounded,
            onPressed: () => _handleSendFixedFileToHost(context),
            color: const Color(0xFF06B6D4),
          ),
        ],
      ),
    );
  }

  /// 고정 경로 (/Download/Recipes.json)에서 파일을 읽어와 확인 후 동기화
  Future<void> _handleImportFromLocal(BuildContext context) async {
    try {
      if (Platform.isAndroid && !await _requestPermissions()) return;

      final content = await ref.read(menuProvider.notifier).readFixedPathFile();

      if (content == null) {
        if (mounted) {
          _showSnackBar(
            context,
            'Recipes.json 파일을 찾을 수 없습니다.\n(Download 폴더를 확인해주세요)',
            isError: true,
          );
        }
        return;
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => MenuImportConfirmDialog(
            content: content,
            onConfirm: () async {
              final success = await ref
                  .read(menuProvider.notifier)
                  .syncMenu(content);
              if (success && mounted) {
                _showSnackBar(context, '메뉴가 성공적으로 로드되었습니다.');
              }
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) _showSnackBar(context, '파일 읽기 오류: $e', isError: true);
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
      if (mounted) _showSnackBar(context, '메뉴 파일이 상대 기기로 전송되었습니다.');
    }
  }

  /// 지정된 경로(/Download/Recipes.json)의 파일을 읽어 호스트 기기로 전송
  Future<void> _handleSendFixedFileToHost(BuildContext context) async {
    try {
      if (Platform.isAndroid && !await _requestPermissions()) return;

      final content = await ref.read(menuProvider.notifier).readFixedPathFile();

      if (content != null) {
        await widget.notifier.sendMenuFile(content);
        if (mounted)
          _showSnackBar(context, '지정 경로의 Recipes.json을 호스트로 전송했습니다.');
      } else {
        if (mounted)
          _showSnackBar(context, '지정된 파일을 찾을 수 없습니다.', isError: true);
      }
    } catch (e) {
      if (mounted) _showSnackBar(context, '파일 전송 실패: $e', isError: true);
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
}
