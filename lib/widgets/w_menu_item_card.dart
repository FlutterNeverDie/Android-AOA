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

    return Container(
      margin: const EdgeInsets.all(8), // 카드 간 간격 (유저 요청: 상하좌우 패딩)
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)), // Slate 200
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 상단: 이미지 영역
                  Expanded(
                    flex: 6,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Icon(
                          _getIconData(item.type),
                          size: 70,
                          color: isHot
                              ? Colors.orange.withValues(alpha: 0.6)
                              : Colors.blue.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),

                  // 하단: 텍스트 정보 영역
                  Container(
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      border: Border(
                        top: BorderSide(color: Color(0xFFE2E8F0), width: 0.5),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B), // Slate 800
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '₩${NumberFormat('#,###').format(int.tryParse(item.price) ?? 0)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFBE123C), // Rose 700
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // HOT/ICE 태그
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isHot
                        ? Colors.red.withValues(alpha: 0.1)
                        : Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isHot
                          ? Colors.red.withValues(alpha: 0.5)
                          : Colors.blue.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    isHot ? 'HOT' : 'ICE',
                    style: TextStyle(
                      color: isHot ? Colors.red.shade700 : Colors.blue.shade700,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String type) {
    switch (type) {
      case 'AM':
        return Icons.local_cafe_rounded;
      case 'CO':
        return Icons.coffee_rounded;
      case 'CE':
        return Icons.coffee_maker_rounded;
      default:
        return Icons.local_drink_rounded;
    }
  }
}
