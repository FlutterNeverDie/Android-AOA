import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/m_drink.dart';

class WMenuItemCard extends StatelessWidget {
  final DrinkModel item;
  final VoidCallback onTap;

  const WMenuItemCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isHot = item.isHotDrink == 'H';
    // 이외의 경우에는 무조건 ICE로 처리 (사용자 요청)
    final bool showIceBadge = !isHot;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black12, width: 0.5),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 제품 이미지/아이콘 영역
                Expanded(
                  flex: 6,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 옅은 배경 아이콘
                          Opacity(
                            opacity: 0.1,
                            child: Icon(
                              _getIconData(item.type),
                              size: 100,
                              color: Colors.green,
                            ),
                          ),
                          // "품절" 표시 제거됨
                        ],
                      ),
                    ),
                  ),
                ),

                // 제품 정보 영역
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.black12, width: 0.5),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF334155),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₩${NumberFormat('#,###').format(int.tryParse(item.price) ?? 0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD97706), // 오렌지/브라운 톤 가격
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // HOT/ICE 태그 (상단 왼쪽)
            if (isHot || showIceBadge)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isHot
                        ? Colors.red.withValues(alpha: 0.1)
                        : Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isHot
                          ? Colors.red.withValues(alpha: 0.5)
                          : Colors.blue.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    isHot ? 'HOT' : 'ICE',
                    style: TextStyle(
                      color: isHot ? Colors.red : Colors.blue,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
        return Icons.coffee;
      case 'CO':
        return Icons.coffee_maker;
      default:
        return Icons.local_drink;
    }
  }
}
