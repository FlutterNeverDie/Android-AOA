import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/aoa_provider.dart';
import '../models/m_aoa.dart';
import '../providers/menu_provider.dart';
import '../screens/s_menu_board.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
          _buildActionButton(
            label: '메뉴판 화면 이동',
            icon: Icons.grid_view_rounded,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MenuBoardScreen(),
                settings: const RouteSettings(name: MenuBoardScreen.routeName),
              ),
            ),
            color: const Color(0xFFF43F5E), // Rose color
            isPrimary: true,
          ),
          const SizedBox(height: 12),
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
            '수신된 메뉴 데이터 (동기화)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          _buildPendingFilesList(),
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

  Widget _buildPendingFilesList() {
    final state = ref.watch(aoaProvider);
    if (state.pendingFiles.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: const Text(
          '수신된 메뉴 파일이 없습니다.',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.pendingFiles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final file = state.pendingFiles[index];
        final timeStr = DateFormat('HH:mm:ss').format(file.receivedAt);
        return InkWell(
          onTap: () => _showSyncDialog(context, index, file),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.description_rounded,
                  size: 16,
                  color: Color(0xFF6366F1),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '수신됨 [$timeStr]',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                const Icon(
                  Icons.sync_alt_rounded,
                  size: 16,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSyncDialog(BuildContext context, int index, dynamic file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('메뉴 데이터 동기화'),
        content: const Text('수신된 데이터로 메뉴판을 업데이트하시겠습니까?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () => _showJsonViewer(context, file.content),
            child: const Text(
              'JSON 확인',
              style: TextStyle(color: Color(0xFF6366F1)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(menuProvider.notifier)
                  .syncMenu(file.content);
              if (success) {
                widget.notifier.removePendingFile(index);
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('메뉴 동기화 완료!')));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            child: const Text('동기화'),
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
}
