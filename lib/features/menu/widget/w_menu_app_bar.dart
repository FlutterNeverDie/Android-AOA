import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WMenuAppBar extends StatelessWidget {
  const WMenuAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80, // 높이를 조금 더 여유롭게 조정
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Color(0xFF2C1810), // 에스프레소 브라운
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 왼쪽: 홈 버튼 + 시간
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white60,
                  size: 28,
                ),
                tooltip: '닫기',
              ),
              const SizedBox(width: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getKoreanDayName(DateTime.now()),
                    style: const TextStyle(
                      color: Color(0xFFD4A373),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    DateFormat('HH:mm').format(DateTime.now()),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'JetBrains Mono',
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 중앙: 로고
          const Row(
            children: [
              Text(
                'TEA TIME',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 8,
                ),
              ),
            ],
          ),

          // 오른쪽: 시스템 상태 (심플하게)
          Row(
            children: [
              _buildStatusIcon(
                Icons.wifi_tethering_rounded,
                Colors.greenAccent,
              ),
              const SizedBox(width: 20),
              _buildStatusIcon(Icons.power_rounded, Colors.white38),
              const SizedBox(width: 20),
              const Icon(Icons.more_vert_rounded, color: Colors.white38),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  String _getKoreanDayName(DateTime date) {
    const days = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return days[date.weekday - 1];
  }
}
