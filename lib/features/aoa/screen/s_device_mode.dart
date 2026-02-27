import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/aoa_provider.dart';
import '../../../share/widget/w_glass_panel.dart';
import '../widget/w_console_log.dart';
import '../widget/w_device_control_panel.dart';
import '../widget/w_device_sub_panel.dart';
import '../../barista/screen/s_barista_dashboard.dart';
import '../../barista/screen/s_order_history.dart';
import '../../menu/screen/s_menu_board.dart';
import '../../../share/provider/theme_provider.dart';

class DeviceModeScreen extends ConsumerStatefulWidget {
  const DeviceModeScreen({super.key});

  static const String routeName = 's_device_mode';

  @override
  ConsumerState<DeviceModeScreen> createState() => _DeviceModeScreenState();
}

class _DeviceModeScreenState extends ConsumerState<DeviceModeScreen> {
  @override
  Widget build(BuildContext context) {
    final aoaState = ref.watch(aoaProvider);
    final aoaNotifier = ref.read(aoaProvider.notifier);

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                        // 좌측: 디바이스 제어 패널 (통신 설정, 메뉴판 이동)
                        WGlassPanel(
                          width: 320,
                          child: WDeviceControlPanel(notifier: aoaNotifier),
                        ),
                        const SizedBox(width: 20),

                        // 중앙: 콘솔 로그
                        Expanded(
                          child: WGlassPanel(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: WConsoleLog(
                                logs: aoaState.logs,
                                onClear: aoaNotifier.clearLogs,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),

                        // 우측: 서브 패널 (로컬 파일 관리)
                        WGlassPanel(
                          width: 320,
                          child: WDeviceSubPanel(notifier: aoaNotifier),
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
          '디바이스 모드',
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
              color: Colors.black.withOpacity(isDark ? 0.1 : 0.02),
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
            color: Colors.black.withOpacity(isDark ? 0.1 : 0.03),
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
                  : const Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            isConnected ? '호스트 연결됨' : '호스트 대기 중...',
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

  Widget _buildBackground() {
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
              color: const Color(0xFF6366F1).withOpacity(0.05),
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
