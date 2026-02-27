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
            child: Column(
              children: [
                _buildAppBar(context, isConnected),
                Expanded(
                  child: menuList.isEmpty
                      ? _buildEmptyState()
                      : _buildMenuGrid(context, ref, menuList),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isConnected) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AOA Tea Time',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
              Text(
                'Premium Kiosk Experience',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          const Spacer(),
          _buildStatusLabel(isConnected),
        ],
      ),
    );
  }

  Widget _buildStatusLabel(bool isConnected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isConnected
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConnected
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: isConnected ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            isConnected ? 'CONNECTED' : 'OFFLINE',
            style: TextStyle(
              fontSize: 12,
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
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    color: const Color(0xFFF8FAFC),
                    child: Center(
                      child: Icon(
                        _getIconData(item.type),
                        size: 64,
                        color: const Color(0xFF6366F1).withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.price}원',
                          style: const TextStyle(
                            fontSize: 16,
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
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // 주문 신호 전송 테스트
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
