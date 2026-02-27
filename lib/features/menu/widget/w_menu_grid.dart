import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/m_drink.dart';
import '../provider/cart_provider.dart';
import '../../aoa/provider/aoa_provider.dart';
import 'w_menu_item_card.dart';

/// 실제 상품들이 나열되는 그리드 위젯
class WMenuGrid extends ConsumerWidget {
  final List<DrinkModel> menuList;

  const WMenuGrid({super.key, required this.menuList});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // 5열 배치
        childAspectRatio: 0.805, // 카드의 세로 비율
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
      ),
      itemCount: menuList.length,
      itemBuilder: (context, index) {
        final item = menuList[index];
        return WMenuItemCard(
          item: item,
          onTap: () {
            // 장바구니 추가
            ref.read(cartProvider.notifier).addToCart(item);
            // 호스트에게 선택 정보 전송 (로그 표시용)
            ref.read(aoaProvider.notifier).sendSelectItem(item.name);
          },
        );
      },
    );
  }
}
