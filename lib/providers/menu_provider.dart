import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/m_drink.dart';
import '../repositories/repo_menu.dart';

/// MenuRepository 주입을 위한 프로바이더
final menuRepositoryProvider = Provider((ref) => MenuRepository());

/// 메뉴 상태(상품 리스트)를 관리하는 Notifier 클래스
/// 로컬 DB처럼 작동하며, UI에 실시간으로 데이터 변화를 전달합니다.
class MenuNotifier extends Notifier<List<DrinkModel>> {
  MenuRepository get _repository => ref.read(menuRepositoryProvider);

  @override
  List<DrinkModel> build() {
    // 앱이 구동될 때 자동으로 내부 저장소에서 마지막 동기화 데이터를 불러옵니다.
    _initMenu();
    return [];
  }

  /// 앱 내부에 저장된 메뉴 파일 로드 시도
  Future<void> _initMenu() async {
    final data = await _repository.loadFromInternal();
    if (data != null) {
      _applyJsonToState(data);
    }
  }

  /// 수신된 또는 읽어온 JSON 문자열을 파싱하여 실제 객체 리스트로 변환 후 상태 적용
  bool _applyJsonToState(String jsonString) {
    try {
      String sanitizedData = jsonString.trim();
      // 실수로 들어간 마지막 쉼표(Trailing Comma) 보정 로직
      sanitizedData = sanitizedData.replaceAll(RegExp(r',\s*\]'), ']');

      final List<dynamic> jsonList = jsonDecode(sanitizedData);
      // JSON 데이터를 DrinkModel 객체 리스트로 매핑
      final newState = jsonList.map((e) => DrinkModel.fromJson(e)).toList();

      // UI에 변경 알림 전송
      state = newState;
      return true;
    } catch (e) {
      debugPrint('메뉴 파싱 실패: $e');
      return false;
    }
  }

  /// 안드로이드 다운로드 폴더(/Download/Recipes.json)에서 직접 고정 파일을 읽어옴
  Future<String?> readFixedPathFile() async {
    return await _repository.loadFromFixedPath();
  }

  /// 새로운 데이터 수신/불러오기 시: 내부 저장소에 저장(캐싱)한 뒤 상태 갱신
  /// 다음에 앱을 켤 때 이 데이터를 자동으로 불러오게 됩니다.
  Future<bool> syncMenu(String jsonString) async {
    final success = await _repository.saveToInternal(jsonString);
    if (success) {
      return _applyJsonToState(jsonString);
    }
    return false;
  }

  /// 모든 메뉴 데이터 초기화 (내부 파일 삭제 및 UI 리스트 비우기)
  Future<void> clearMenu() async {
    await _repository.deleteInternal();
    state = [];
  }

  /// 현재 메모리에 로드된 메뉴 상태를 JSON 문자열로 변환 (파일 전송 시 사용)
  String toJsonString() {
    return jsonEncode(state.map((e) => e.toJson()).toList());
  }
}

/// 전역적으로 메뉴 상태에 접근할 수 있는 프로바이더 정의
final menuProvider = NotifierProvider<MenuNotifier, List<DrinkModel>>(() {
  return MenuNotifier();
});
