import 'package:flutter/material.dart';

/// 상대방 기기가 사용 중일 때 화면을 차단하는 오버레이 위젯
class WMenuLockOverlay extends StatelessWidget {
  final String? lockedBy; // 누가 잠갔는지 표시 (Host/Device)

  const WMenuLockOverlay({super.key, this.lockedBy});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6), // 반투명 배경
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 잠금 아이콘
              const Icon(
                Icons.lock_person_rounded,
                size: 80,
                color: Color(0xFFBE123C), // 강조 레드
              ),
              const SizedBox(height: 24),
              // 제목
              Text(
                '반대편 기기($lockedBy)에서\n사용 중입니다.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              // 안내 문구
              const Text(
                '주문이 끝날 때까지 잠시만 기다려 주세요.',
                style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
