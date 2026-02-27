import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/menu_provider.dart';
import '../providers/aoa_provider.dart';
import '../providers/cart_provider.dart';
import '../models/m_drink.dart';
import '../widgets/w_menu_app_bar.dart';
import '../widgets/w_menu_sidebar.dart';
import '../widgets/w_menu_item_card.dart';

class MenuBoardScreen extends ConsumerWidget {
  const MenuBoardScreen({super.key});

  static const String routeName = 's_menu_board';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuList = ref.watch(menuProvider);
    final aoaState = ref.watch(aoaProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // 1. 상단 앱바
              const WMenuAppBar(),

              // 2. 메인 컨텐츠 (그리드 + 사이드바)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  child: Row(
                    children: [
                      // 좌측: 메뉴 그리드
                      Expanded(
                        flex: 3,
                        child: Container(
                          color: const Color(0xFFF8FAFC),
                          child: menuList.isEmpty
                              ? _buildEmptyState()
                              : _buildMenuGrid(context, ref, menuList),
                        ),
                      ),

                      // 우측: 장바구니 사이드바
                      const WMenuSidebar(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 상대방 사용 중일 때 차단 오버레이
          if (aoaState.isRemoteLocked)
            Container(
              color: Colors.black.withValues(alpha: 0.6),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 30,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_person_rounded,
                        size: 80,
                        color: Color(0xFFBE123C),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '반대편 기기(${aoaState.lockedBy})에서\n주문 중입니다.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '주문이 끝날 때까지 잠시만 기다려 주세요.',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_drinks_outlined, size: 80, color: Colors.black12),
          SizedBox(height: 16),
          Text(
            '등록된 메뉴가 없습니다.\n동기화가 필요합니다.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 18),
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
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // 사진처럼 6열 배치
        childAspectRatio: 0.805, // 사진 속 카드의 세로 비율 반영
        crossAxisSpacing: 0, // 카드 내부 margin으로 간격 조절
        mainAxisSpacing: 0,
      ),
      itemCount: menuList.length,
      itemBuilder: (context, index) {
        final item = menuList[index];
        return WMenuItemCard(
          item: item,
          onTap: () {
            ref.read(cartProvider.notifier).addToCart(item);
            ref.read(aoaProvider.notifier).sendSelectItem(item.name);
          },
        );
      },
    );
  }
}
