import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WMenuAppBar extends StatelessWidget {
  const WMenuAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B), // 네이비 톤
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 왼쪽: 홈 버튼 + 시간
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.home_rounded, color: Colors.white70),
                tooltip: '관리 화면으로 돌아가기',
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('HH:mm').format(DateTime.now()),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // 중앙: 로고 및 타이틀
          Row(
            children: [
              const Text(
                'TeaTime',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.coffee,
                  color: Color(0xFF1E293B),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'COFFEE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),

          // 오른쪽: 상태 아이콘
          Row(
            children: [
              const Text(
                '102C',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(width: 15),
              const Icon(Icons.security, color: Colors.white70, size: 20),
              const SizedBox(width: 10),
              const Icon(Icons.wifi, color: Colors.white70, size: 20),
              const SizedBox(width: 10),
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
