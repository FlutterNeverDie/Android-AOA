import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/aoa_provider.dart';
import '../models/m_pending_file.dart';
import '../providers/menu_provider.dart';
import '../dialogs/d_aoa_info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WHostSubPanel extends ConsumerWidget {
  final AoaState state;
  final AoaNotifier notifier;
  final String manufacturer;
  final String model;
  final String version;
  final Function(String, String, String) onUpdateDeviceInfo;

  const WHostSubPanel({
    super.key,
    required this.state,
    required this.notifier,
    required this.manufacturer,
    required this.model,
    required this.version,
    required this.onUpdateDeviceInfo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '수신된 메뉴 데이터',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          // 파일 목록 영역 - 내용만큼만 차지하도록 shrinkWrap 사용
          if (state.pendingFiles.isEmpty)
            _buildEmptyPendingList()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.pendingFiles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final file = state.pendingFiles[index];
                return _buildPendingFileItem(context, ref, index, file);
              },
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1),
          ),
          const Text(
            '설정 및 도구',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          _buildSubButton(
            label: '장치 정보 설정',
            icon: Icons.settings_suggest_rounded,
            onTap: () => _showAoaInfoDialog(context),
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
          _buildSubButton(
            label: '강제 연결 종료',
            icon: Icons.link_off_rounded,
            onTap: () => notifier.addLog('[안내] 연결 종료 요청됨'),
          ),
          const SizedBox(height: 24),
          _buildDeviceInfoCard(),
        ],
      ),
    );
  }

  Widget _buildEmptyPendingList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: const Column(
        children: [
          Icon(Icons.folder_open_rounded, color: Color(0xFFCBD5E1), size: 32),
          SizedBox(height: 12),
          Text(
            '수신된 데이터가 없습니다.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingFileItem(
    BuildContext context,
    WidgetRef ref,
    int index,
    PendingMenuFile file,
  ) {
    final timeStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(file.receivedAt);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _showSyncConfirmation(context, ref, index, file),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.description_rounded,
                  size: 18,
                  color: Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '메뉴 데이터 수신',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeStr,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }

  void _showSyncConfirmation(
    BuildContext context,
    WidgetRef ref,
    int index,
    PendingMenuFile file,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('메뉴 데이터 동기화'),
        content: const Text('선택한 데이터로 전체 메뉴판을 업데이트하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
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
                notifier.removePendingFile(index);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('메뉴가 성공적으로 업데이트되었습니다.'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('동기화 실행'),
          ),
        ],
      ),
    );
  }

  void _showAoaInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DAoaInfo(
        initialManuf: manufacturer,
        initialModel: model,
        initialVer: version,
        onSave: onUpdateDeviceInfo,
      ),
    );
  }

  Widget _buildSubButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SizedBox(
        width: double.infinity,
        child: TextButton.icon(
          icon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
          label: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          onPressed: onTap,
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
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
              SizedBox(width: 6),
              Text(
                '현재 설정 정보',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildInfoRow('제조사', manufacturer),
          _buildInfoRow('모델명', model),
          _buildInfoRow('버전', version),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
