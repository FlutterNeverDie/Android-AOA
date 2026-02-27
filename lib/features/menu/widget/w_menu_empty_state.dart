import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../share/provider/theme_provider.dart';

/// 메뉴 데이터가 없을 때 표시되는 빈 상태 위젯
class WMenuEmptyState extends ConsumerWidget {
  const WMenuEmptyState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 비어있음을 나타내는 아이콘
          Icon(
            Icons.no_drinks_outlined,
            size: 100,
            color: isDark ? Colors.white10 : Colors.black12,
          ),
          const SizedBox(height: 24),
          // 안내 메시지
          Text(
            '등록된 메뉴가 없습니다.\n동기화가 필요합니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
              fontSize: 20,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
