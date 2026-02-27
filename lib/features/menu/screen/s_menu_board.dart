import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/menu_provider.dart';
import '../../aoa/provider/aoa_provider.dart';
import '../widget/w_menu_app_bar.dart';
import '../widget/w_menu_sidebar.dart';
import '../widget/w_menu_grid.dart';
import '../widget/w_menu_empty_state.dart';
import '../widget/w_menu_lock_overlay.dart';

/// 메인 메뉴판 화면
/// 상단바, 메뉴 그리드, 우측 장바구니로 구성되며 상대방 기기의 잠금 상태를 감시합니다.
class MenuBoardScreen extends ConsumerWidget {
  const MenuBoardScreen({super.key});

  static const String routeName = 's_menu_board';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 메뉴 데이터 및 통신 상태 관찰
    final menuList = ref.watch(menuProvider);
    final aoaState = ref.watch(aoaProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // 1. 커스텀 상단 앱바 (로고, 시계 등)
              const WMenuAppBar(),

              // 2. 메인 컨텐츠 영역
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  child: Row(
                    children: [
                      // 좌측 영역: 메뉴 그리드 혹은 빈 상태 표시 
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9), // 부드러운 배경색
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                          ),
                          child: menuList.isEmpty
                              ? const WMenuEmptyState()
                              : WMenuGrid(menuList: menuList),
                        ),
                      ),

                      // 우측 영역: 장바구니 사이드바
                      const WMenuSidebar(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 상대방(Host 혹은 Device)이 사용 중일 때 나타나는 잠금 화면
          if (aoaState.isRemoteLocked)
            WMenuLockOverlay(lockedBy: aoaState.lockedBy),
        ],
      ),
    );
  }
}
