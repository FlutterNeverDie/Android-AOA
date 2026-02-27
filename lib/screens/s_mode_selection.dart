import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/aoa_provider.dart';
import 's_host_mode.dart';
import 's_device_mode.dart';

class ModeSelectionScreen extends ConsumerWidget {
  const ModeSelectionScreen({super.key});

  static const String routeName = 's_mode_selection';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'AOA 프로토콜 모드 선택',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 80),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildModeCard(
                      context,
                      title: '호스트 모드',
                      subtitle: '액세서리 역할\n(USB 호스트)',
                      icon: Icons.settings_input_composite,
                      color: const Color(0xFF6366F1),
                      onTap: () {
                        ref.read(aoaProvider.notifier).setMode(AppMode.host);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HostModeScreen(),
                            settings: const RouteSettings(
                              name: HostModeScreen.routeName,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 32),
                    _buildModeCard(
                      context,
                      title: '디바이스 모드',
                      subtitle: '타겟 장치 역할\n(USB 디바이스)',
                      icon: Icons.android_rounded,
                      color: const Color(0xFF10B981),
                      onTap: () {
                        ref.read(aoaProvider.notifier).setMode(AppMode.device);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DeviceModeScreen(),
                            settings: const RouteSettings(
                              name: DeviceModeScreen.routeName,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
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
          top: -100,
          left: -100,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF6366F1).withValues(alpha: 0.08),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          right: -100,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEC4899).withValues(alpha: 0.05),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        height: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(icon, size: 56, color: color),
              ),
              const SizedBox(height: 32),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
