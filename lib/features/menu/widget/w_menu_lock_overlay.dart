import 'dart:ui';
import 'package:flutter/material.dart';

/// 상대방 기기가 사용 중일 때 화면을 블러 처리하고 잠금을 표시하는 프리미엄 오버레이
class WMenuLockOverlay extends StatelessWidget {
  final String? lockedBy;

  const WMenuLockOverlay({super.key, this.lockedBy});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // 강력한 블러 효과
          child: Container(
            color: const Color(0xFF2C1810).withOpacity(0.3), // 에스프레소 톤 오버레이
            child: Center(
              child: Container(
                width: 480,
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 40,
                      spreadRadius: -10,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 장식용 아이콘 컨테이너
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBE123C).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_person_rounded,
                        size: 72,
                        color: Color(0xFFBE123C),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      '반대쪽 기기에서\n사용 중입니다',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                        height: 1.25,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF64748B),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            '잠시만 기다려 주세요',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
