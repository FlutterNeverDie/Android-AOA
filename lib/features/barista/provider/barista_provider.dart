import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../aoa/provider/aoa_provider.dart';
import '../model/m_order.dart';

/// 바리스타 모드의 주문 상태를 관리하는 Notifier
class BaristaNotifier extends Notifier<List<MOrder>> {
  @override
  List<MOrder> build() {
    // 앱이 실행되는 동안 계속 주문을 수집하도록 설정
    ref.keepAlive();

    // aoaProvider의 로그를 감시하여 주문 메시지가 오면 주문 목록에 추가
    ref.listen(aoaProvider, (previous, next) {
      if (next.logs.length > (previous?.logs.length ?? 0)) {
        final lastLog = next.logs.last;
        // "[결제]"로 시작하는 로그가 새로운 주문임을 판별
        if (lastLog.message.startsWith('[결제]')) {
          _addOrderFromLog(lastLog.message);
        }
      }
    });
    return [];
  }

  void _addOrderFromLog(String logMsg) {
    // 로그 예시: "[결제] [아메리카노(HOT) x1] 총 1,900원"
    final cleanMsg = logMsg.replaceFirst('[결제]', '').trim();

    // 가격 추출 시도 (가장 뒤의 '총 X원' 패턴 찾기)
    int price = 0;
    String nameOnly = cleanMsg;

    try {
      // '총' 키워드를 기준으로 나눔
      if (cleanMsg.contains('총')) {
        final parts = cleanMsg.split('총');
        // '총' 앞부분은 메뉴 정보
        nameOnly = parts.first.replaceAll('[', '').replaceAll(']', '').trim();
        // '총' 뒷부분에서 숫자만 추출
        final priceString = parts.last
            .replaceAll(',', '')
            .replaceAll(RegExp(r'[^0-9]'), '');
        if (priceString.isNotEmpty) {
          price = int.parse(priceString);
        }
      }
    } catch (e) {
      // 파싱 실패 시 기본값 0 유지
    }

    final order = MOrder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      menuName: nameOnly,
      totalPrice: price,
      orderedAt: DateTime.now(),
    );

    state = [order, ...state];
  }

  void updateOrderStatus(String id, OrderStatus newStatus) {
    state = [
      for (final order in state)
        if (order.id == id) order.copyWith(status: newStatus) else order,
    ];
  }

  void clearOrders() => state = [];
}

final baristaProvider = NotifierProvider<BaristaNotifier, List<MOrder>>(() {
  return BaristaNotifier();
});
