import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/m_drink.dart';
import '../repositories/repo_menu.dart';

final menuRepositoryProvider = Provider((ref) => MenuRepository());

final menuProvider = NotifierProvider<MenuNotifier, List<DrinkModel>>(() {
  return MenuNotifier();
});

class MenuNotifier extends Notifier<List<DrinkModel>> {
  MenuRepository get _repository => ref.read(menuRepositoryProvider);

  @override
  List<DrinkModel> build() {
    loadMenu();
    return [];
  }

  /// 로컬 파일에서 메뉴 데이터를 불러옵니다.
  Future<void> loadMenu() async {
    final data = await _repository.loadMenuData();
    if (data != null) {
      try {
        String sanitizedData = data.trim();
        // JSON 마지막 요소 뒤에 불필요한 쉼표가 있는 경우 제거 (예: [{}, {},])
        sanitizedData = sanitizedData.replaceAll(RegExp(r',\s*\]'), ']');

        final List<dynamic> jsonList = jsonDecode(sanitizedData);
        final newState = jsonList.map((e) => DrinkModel.fromJson(e)).toList();

        state = newState;

        // 성공 로그 (AOA 콘솔)
        // ignore: avoid_manual_providers_as_extension_setters
        // ref.read(aoaProvider.notifier).addLog('[시스템] 메뉴판 데이터 ${newState.length}건이 로드되었습니다.');
      } catch (e) {
        // 파싱 실패 시 상위 알림 (어려우면 print라도)
        debugPrint('Menu Parse Error: $e');
        state = [];
      }
    }
  }

  /// 새로운 JSON 데이터를 로컬에 저장하고 상태를 갱신합니다 (동기화).
  Future<bool> syncMenu(String jsonString) async {
    final success = await _repository.saveMenuData(jsonString);
    if (success) {
      await loadMenu();
    }
    return success;
  }

  /// 메뉴 리스트를 초기화합니다.
  Future<void> clearMenu() async {
    await _repository.deleteMenuData();
    state = [];
  }
}
