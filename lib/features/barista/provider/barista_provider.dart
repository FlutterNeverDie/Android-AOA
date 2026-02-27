import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../aoa/provider/aoa_provider.dart';
import '../model/m_order.dart';

/// 바리스타 모드의 주문 상태를 관리하는 Notifier
class BaristaNotifier extends Notifier<List<MOrder>> {
  @override
  List<MOrder> build() {
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

    // 간단한 파싱 logic (정교한 파싱은 실제 데이터 형식에 맞춰 보완 가능)
    final order = MOrder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      menuName: cleanMsg, // 전체 메시지를 메뉴 정보로 저장
      totalPrice: 0, // 상세 가격 파싱은 생략 (데모용)
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
