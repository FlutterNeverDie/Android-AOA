import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/aoa_provider.dart';
import '../model/m_aoa_state.dart';
import '../../../share/widget/w_glass_panel.dart';
import '../widget/w_console_log.dart';
import '../widget/w_host_sub_panel.dart';
import '../../menu/screen/s_menu_board.dart';
import '../../barista/screen/s_barista_dashboard.dart';
import '../../barista/screen/s_order_history.dart';
import '../../../share/provider/theme_provider.dart';

class HostModeScreen extends ConsumerStatefulWidget {
  const HostModeScreen({super.key});

  static const String routeName = 's_host_mode';

  @override
  ConsumerState<HostModeScreen> createState() => _HostModeScreenState();
}

class _HostModeScreenState extends ConsumerState<HostModeScreen> {
  final TextEditingController _messageController = TextEditingController();

  // 기본 장치 정보
  String _manuf = "SCS PRO";
  String _model = "NMP-10";
  String _ver = "1.0";

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aoaProvider);
    final notifier = ref.read(aoaProvider.notifier);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      resizeToAvoidBottomInset: false, // 레이아웃 안정성을 위해 false 설정
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
                          child: _buildLeftPanel(state, notifier),
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
                        // 우측 서브 패널 (분리된 위젯 사용)
                        WGlassPanel(
                          width: 320,
                          child: WHostSubPanel(
                            state: state,
                            notifier: notifier,
                            manufacturer: _manuf,
                            model: _model,
                            version: _ver,
                            onUpdateDeviceInfo: (m, mo, v) {
                              setState(() {
                                _manuf = m;
                                _model = mo;
                                _ver = v;
                              });
                            },
                          ),
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
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: isDark ? Colors.white70 : const Color(0xFF64748B),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          '호스트 모드 설정',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(width: 24),
        // 바리스타 대시보드 버튼
        _buildHeaderAction(
          icon: Icons.dashboard_customize_rounded,
          label: '바리스타 모드',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BaristaDashboardScreen(),
                settings: const RouteSettings(
                  name: BaristaDashboardScreen.routeName,
                ),
              ),
            );
          },
          color: const Color(0xFFD4A373),
        ),
        const SizedBox(width: 12),
        // 주문 내역 버튼
        _buildHeaderAction(
          icon: Icons.history_rounded,
          label: '주문 내역',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const OrderHistoryScreen(),
                settings: const RouteSettings(
                  name: OrderHistoryScreen.routeName,
                ),
              ),
            );
          },
          color: const Color(0xFF10B981),
        ),
        const SizedBox(width: 12),
        // 메뉴판 버튼 추가
        _buildHeaderAction(
          icon: Icons.grid_view_rounded,
          label: '메뉴판',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MenuBoardScreen(),
                settings: const RouteSettings(name: MenuBoardScreen.routeName),
              ),
            );
          },
          color: const Color(0xFFF43F5E),
        ),
        const SizedBox(width: 12),
        // 테마 전환 버튼
        _buildHeaderAction(
          icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          label: isDark ? '라이트 모드' : '다크 모드',
          onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          color: isDark ? const Color(0xFFD4A373) : const Color(0xFF2C1810),
        ),
        const Spacer(),
        _buildStatusBar(),
      ],
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final isConnected = ref.watch(aoaProvider).isConnected;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
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
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel(AoaState state, AoaNotifier notifier) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AOA 제어 및 전송',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 20),
        _buildActionButton(
          label: 'AOA 지원 확인',
          icon: Icons.search_rounded,
          onPressed: () => notifier.checkHostSupport(),
          color: const Color(0xFF6366F1),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          label: '액세서리 모드 시작',
          icon: Icons.play_arrow_rounded,
          onPressed: () => notifier.startHostHandshake(_manuf, _model, _ver),
          color: const Color(0xFF10B981),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          label: '통신 채널 개설',
          icon: Icons.lan_rounded,
          onPressed: () => notifier.setupCommunication(),
          color: const Color(0xFFF43F5E), // 일관성을 위해 색상 약간 변경 가능
        ),
        const SizedBox(height: 32),
        Text(
          '메시지 전송',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white38 : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _messageController,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: '메시지를 입력하세요...',
            hintStyle: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white24 : const Color(0xFF94A3B8),
            ),
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : const Color(0xFFF8FAFC),
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
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
          ),
          onSubmitted: (val) {
            if (val.isNotEmpty) {
              notifier.sendMessage(val);
              _messageController.clear();
            }
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 20),
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: isDark ? 0.2 : 0.1),
          foregroundColor: color,
          elevation: 0,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withValues(alpha: 0.2)),
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
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
              color: const Color(
                0xFF6366F1,
              ).withValues(alpha: isDark ? 0.08 : 0.05),
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
