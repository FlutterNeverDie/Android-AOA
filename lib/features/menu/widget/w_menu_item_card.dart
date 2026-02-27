import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/m_drink.dart';

class WMenuItemCard extends StatelessWidget {
  final DrinkModel item;
  final VoidCallback onTap;

  const WMenuItemCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isHot = item.isHotDrink == 'H';

    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // 더 둥근 모서리
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C1810).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 아이콘/이미지 영역 (상단)
                    Expanded(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: (isHot ? Colors.orange : Colors.blue)
                                .withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIconData(item.type),
                            size: 60,
                            color: isHot
                                ? const Color(0xFFD97706)
                                : const Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 정보 영역 (하단)
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₩${NumberFormat('#,###').format(int.tryParse(item.price) ?? 0)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFBE123C),
                      ),
                    ),
                  ],
                ),
              ),

              // HOT/ICE 배지
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isHot
                        ? const Color(0xFFFEF2F2)
                        : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isHot
                          ? const Color(0xFFFECACA)
                          : const Color(0xFFBFDBFE),
                    ),
                  ),
                  child: Text(
                    isHot ? 'HOT' : 'ICE',
                    style: TextStyle(
                      color: isHot
                          ? const Color(0xFFB91C1C)
                          : const Color(0xFF1D4ED8),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
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
        return Icons.coffee_rounded;
      case 'CO':
        return Icons.local_cafe_rounded;
      case 'CE':
        return Icons.wine_bar_rounded;
      default:
        return Icons.local_drink_rounded;
    }
  }
}
