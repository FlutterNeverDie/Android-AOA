import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../provider/barista_provider.dart';
import '../model/m_order.dart';
import '../../../share/provider/theme_provider.dart';

class BaristaDashboardScreen extends ConsumerWidget {
  static const routeName = 's_barista_dashboard';

  const BaristaDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(baristaProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          '바리스타 모드',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? const Color(0xFFD4A373) : const Color(0xFF2C1810),
            ),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 화면 너비가 800px 이하인 경우 세로 배치, 이상이면 가로 배치
          final isNarrow = constraints.maxWidth < 800;

          if (isNarrow) {
            return Column(
              children: [
                _buildSummaryHeader(context, orders),
                Expanded(child: _buildOrderGrid(context, ref, orders)),
              ],
            );
          }

          return Row(
            children: [
              // 왼쪽: 통계 및 요약 (사이드바 스타일)
              _buildSummarySidebar(context, orders),

              // 오른쪽: 실시간 주문 카드 목록
              Expanded(child: _buildOrderGrid(context, ref, orders)),
            ],
          );
        },
      ),
    );
  }

  /// 좁은 화면에서의 상단 요약 바
  Widget _buildSummaryHeader(BuildContext context, List<MOrder> orders) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pendingCount = orders
        .where((o) => o.status == OrderStatus.pending)
        .length;
    final preparingCount = orders
        .where((o) => o.status == OrderStatus.preparing)
        .length;
    final completedCount = orders
        .where((o) => o.status == OrderStatus.completed)
        .length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white10
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItemMini('대기', pendingCount, Colors.orange),
          _buildStatItemMini('제조', preparingCount, Colors.blue),
          _buildStatItemMini('완료', completedCount, Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatItemMini(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8),
        Text(
          '$count',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  /// 공통 주문 그리드 영역
  Widget _buildOrderGrid(
    BuildContext context,
    WidgetRef ref,
    List<MOrder> orders,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded, color: Color(0xFFD4A373)),
              const SizedBox(width: 8),
              const Text(
                '실시간 주문 현황',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              Text(
                '총 ${orders.length}개의 주문',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: orders.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 400,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          mainAxisExtent: 220,
                        ),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(context, ref, orders[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySidebar(BuildContext context, List<MOrder> orders) {
    final pendingCount = orders
        .where((o) => o.status == OrderStatus.pending)
        .length;
    final preparingCount = orders
        .where((o) => o.status == OrderStatus.preparing)
        .length;
    final completedCount = orders
        .where((o) => o.status == OrderStatus.completed)
        .length;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark
                ? Colors.white10
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '오늘의 성과',
                  style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 8),
                const Text(
                  '힘내세요, 바리스타님!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 32),
                _buildStatItem('대기 중', pendingCount, Colors.orange),
                const SizedBox(height: 16),
                _buildStatItem('제조 중', preparingCount, Colors.blue),
                const SizedBox(height: 16),
                _buildStatItem('완료됨', completedCount, Colors.green),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A373).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.tips_and_updates_rounded,
                    color: Color(0xFFD4A373),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '주문 수락 후 제조를 시작하세요.',
                      style: TextStyle(
                        color: Color(0xFF78350F),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        Text(
          '$count',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Widget _buildOrderCard(BuildContext context, WidgetRef ref, MOrder order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Text(
                  DateFormat('HH:mm').format(order.orderedAt),
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildStatusBadge(order.status),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                order.menuName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Text(
                  '${NumberFormat('#,###').format(order.totalPrice)}원',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4A373),
                  ),
                ),
                const Spacer(),
                _buildActionButtons(ref, order),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButtons(WidgetRef ref, MOrder order) {
    if (order.status == OrderStatus.pending) {
      return ElevatedButton(
        onPressed: () => ref
            .read(baristaProvider.notifier)
            .updateOrderStatus(order.id, OrderStatus.preparing),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C1810),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('수락'),
      );
    } else if (order.status == OrderStatus.preparing) {
      return ElevatedButton(
        onPressed: () => ref
            .read(baristaProvider.notifier)
            .updateOrderStatus(order.id, OrderStatus.completed),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('완료'),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.coffee_rounded,
            size: 80,
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 20),
          const Text(
            '현재 들어온 주문이 없습니다.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
