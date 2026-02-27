import 'dart:convert';
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
        final List<dynamic> jsonList = jsonDecode(data);
        state = jsonList.map((e) => DrinkModel.fromJson(e)).toList();
      } catch (e) {
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
