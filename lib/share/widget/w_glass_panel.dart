import 'package:flutter/material.dart';

class WGlassPanel extends StatelessWidget {
  final Widget child;
  final double? width;
  final double borderRadius;

  const WGlassPanel({
    super.key,
    required this.child,
    this.width,
    this.borderRadius = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.8)
            : Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        // 테마에 따른 보더 색상 변경
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(padding: const EdgeInsets.all(20.0), child: child),
      ),
    );
  }
}
