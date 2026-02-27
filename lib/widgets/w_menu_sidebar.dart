import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/cart_provider.dart';

class WMenuSidebar extends ConsumerWidget {
  const WMenuSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Container(
      width: 320,
      color: const Color(0xFFF1F5F9), // 연한 그레이 배경
      child: Column(
        children: [
          // 장바구니 타이틀
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            color: Colors.white,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.shopping_cart, color: Colors.black54, size: 30,),
                SizedBox(width: 10),
                Text(
                  '장바구니',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // 테이블 헤더
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            color: const Color(0xFF1E293B),
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '음료 / 가격 / 수량',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                InkWell(
                    onTap:  () => cartNotifier.clearCart(),
                    child: Text('삭제', style: TextStyle(color: Colors.white, fontSize: 13))),
              ],
            ),
          ),

          // 주문 목록 영역 (스크롤 가능)
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12),
              ),
              child: cart.items.isEmpty
                  ? const Center(
                      child: Text(
                        '선택된 음료가 없습니다.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: cart.items.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, indent: 10, endIndent: 10),
                      itemBuilder: (context, index) {
                        final item = cart.items[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${item.drink.isHotDrink == 'H' ? '[HOT]' : '[ICE]'} ${item.drink.name}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${NumberFormat('#,###').format(int.tryParse(item.drink.price) ?? 0)}원',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'x${item.quantity}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 15),
                              IconButton(
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    cartNotifier.removeFromCart(item),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),

          // 결제 정보 영역
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '결제 금액',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                    Row(
                      children: [
                        Text(
                          NumberFormat('#,###').format(cart.totalPrice),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFBE123C), // 강조 색상
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '원',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // 주문 하기/안내 메인 버튼
                SizedBox(
                  width: double.infinity,
                  height: 120,
                  child: ElevatedButton(
                    onPressed: cart.items.isEmpty
                        ? null
                        : () {
                            // 주문 완료 처리 (예시: 모든 항목 비우기)
                            cartNotifier.clearCart();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '주문이 완료되었습니다.',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBE123C), // 사진의 레드 색상
                      disabledBackgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      cart.items.isEmpty ? '음료 선택 후\n눌러 주세요' : '주문 하기',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
