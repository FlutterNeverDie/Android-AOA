// MOrder 데이터 모델

enum OrderStatus { pending, preparing, completed, cancelled }

class MOrder {
  final String id;
  final String menuName;
  final int totalPrice;
  final DateTime orderedAt;
  final OrderStatus status;

  MOrder({
    required this.id,
    required this.menuName,
    required this.totalPrice,
    required this.orderedAt,
    this.status = OrderStatus.pending,
  });

  MOrder copyWith({
    String? id,
    String? menuName,
    int? totalPrice,
    DateTime? orderedAt,
    OrderStatus? status,
  }) {
    return MOrder(
      id: id ?? this.id,
      menuName: menuName ?? this.menuName,
      totalPrice: totalPrice ?? this.totalPrice,
      orderedAt: orderedAt ?? this.orderedAt,
      status: status ?? this.status,
    );
  }
}
