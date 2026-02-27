import 'dart:ui';
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
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        // 더 확실하게 보이는 보더 추가
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
