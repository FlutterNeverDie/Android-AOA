import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../provider/barista_provider.dart';
import '../model/m_order.dart';

class OrderHistoryScreen extends ConsumerWidget {
  static const routeName = 's_order_history';

  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 모든 주문 내역 (완료된 주문 포함)
    final allOrders = ref.watch(baristaProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 통계 계산
    final totalSales = allOrders.fold<int>(
      0,
      (sum, order) => sum + order.totalPrice,
    );
    final completedCount = allOrders
        .where((o) => o.status == OrderStatus.completed)
        .length;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          '주문 내역',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 요약 카드 (오늘의 실적)
            _buildSummaryCard(
              context,
              totalSales,
              allOrders.length,
              completedCount,
            ),
            const SizedBox(height: 32),
            const Text(
              '상세 내역',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: allOrders.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      itemCount: allOrders.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildHistoryItem(context, allOrders[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    int totalSales,
    int totalCount,
    int completedCount,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final f = NumberFormat('#,###');

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFF2C1810), const Color(0xFF4A2B1F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '오늘의 총 매출',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${f.format(totalSales)}원',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Container(height: 60, width: 1, color: Colors.white12),
          _buildStatMini('전체 주문', '$totalCount건'),
          _buildStatMini('완료 주문', '$completedCount건'),
        ],
      ),
    );
  }

  Widget _buildStatMini(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(BuildContext context, MOrder order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final f = NumberFormat('#,###');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFD4A373).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.coffee_rounded,
              color: Color(0xFFD4A373),
              size: 24,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.menuName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('yyyy.MM.dd HH:mm').format(order.orderedAt),
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${f.format(order.totalPrice)}원',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFD4A373),
                ),
              ),
              const SizedBox(height: 4),
              _buildSmallStatus(order.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatus(OrderStatus status) {
    Color color;
    String text;
    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        text = '대기';
        break;
      case OrderStatus.preparing:
        color = Colors.blue;
        text = '준비';
        break;
      case OrderStatus.completed:
        color = Colors.green;
        text = '완료';
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        text = '취소';
        break;
    }
    return Text(
      text,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.list_alt_rounded,
            size: 64,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text('주문 상세 내역이 없습니다.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
