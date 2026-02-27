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

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. 상단 앱바
          const WMenuAppBar(),

          // 2. 메인 컨텐츠 (그리드 + 사이드바)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
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
            ref.read(aoaProvider.notifier).sendOrderStatus('${item.name} 선택됨');
          },
        );
      },
    );
  }
}
