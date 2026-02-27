import 'package:flutter/material.dart';

class WMenuSidebar extends StatelessWidget {
  const WMenuSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      color: const Color(0xFFF1F5F9), // 연한 그레이 배경
      child: Column(
        children: [
          // 장바구니 타이틀
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            color: Colors.white,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_basket_outlined, color: Colors.black54),
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
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '음료 / 가격',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                Text('삭제', style: TextStyle(color: Colors.white, fontSize: 13)),
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
              child: const Center(
                child: Text(
                  '선택된 음료가 없습니다.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),

          // 결제 정보 영역
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '결제 금액',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '0',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
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
                  height: 100,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBE123C), // 사진의 레드 색상
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      '음료 선택 후\n눌러 주세요',
                      textAlign: TextAlign.center,
                      style: TextStyle(
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
