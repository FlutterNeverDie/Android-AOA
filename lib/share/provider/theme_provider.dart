import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 앱의 테마 모드(Light/Dark)를 관리하는 프로바이더 (Riverpod 3.0 Notifier 스타일)
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  void setLightMode() => state = ThemeMode.light;
  void setDarkMode() => state = ThemeMode.dark;
}
