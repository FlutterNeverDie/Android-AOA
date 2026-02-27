import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/menu_provider.dart';
import '../providers/aoa_provider.dart';
import '../models/m_drink.dart';

class MenuBoardScreen extends ConsumerWidget {
  const MenuBoardScreen({super.key});

  static const String routeName = 's_menu_board';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuList = ref.watch(menuProvider);
    final isConnected = ref.watch(aoaProvider).isConnected;

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: menuList.isEmpty
                ? _buildEmptyState()
                : _buildMenuGrid(context, ref, menuList),
          ),
          // 우측 상단 닫기 버튼
          Positioned(
            top: 20,
            right: 20,
            child: Material(
              color: Colors.white.withValues(alpha: 0.8),
              shape: const CircleBorder(),
              elevation: 4,
              child: IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.black87,
                  size: 28,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          // 연결 상태 미니 레이블
          Positioned(
            bottom: 20,
            right: 20,
            child: _buildMiniStatusLabel(isConnected),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatusLabel(bool isConnected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 6,
            color: isConnected ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 6),
          Text(
            isConnected ? 'ON' : 'OFF',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isConnected ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.no_drinks_outlined,
            size: 80,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            '등록된 메뉴가 없습니다.\n디바이스에서 메뉴 설정을 전송해주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(
    BuildContext context,
    WidgetRef ref,
    List<DrinkModel> menuList,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6, // 1줄에 8개 배치
        childAspectRatio: 0.65, // 세로로 조금 더 길게
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: menuList.length,
      itemBuilder: (context, index) {
        final item = menuList[index];
        return _buildMenuCard(ref, item);
      },
    );
  }

  Widget _buildMenuCard(WidgetRef ref, DrinkModel item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 상단 아이콘/이미지 영역
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: const Color(0xFFF8FAFC),
                    child: Center(
                      child: Icon(
                        _getIconData(item.type),
                        size: 40, // 크기 축소
                        color: const Color(0xFF6366F1).withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
                // 하단 정보 영역
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13, // 폰트 크기 축소
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.price}원',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // HOT/ICE 태그 (예시)
            if (item.isHotDrink == 'H' || item.isHotDrink == 'I')
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: item.isHotDrink == 'H' ? Colors.red : Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.isHotDrink == 'H' ? 'HOT' : 'ICE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  ref
                      .read(aoaProvider.notifier)
                      .sendOrderStatus('${item.name} 주문됨');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String type) {
    switch (type) {
      case 'AM':
        return Icons.coffee_rounded;
      case 'CO':
        return Icons.coffee_maker_rounded;
      case 'CL':
        return Icons.local_cafe_rounded;
      case 'IC':
        return Icons.icecream_rounded;
      default:
        return Icons.local_drink_rounded;
    }
  }

  Widget _buildBackground() {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withValues(alpha: 0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
