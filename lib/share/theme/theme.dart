import 'package:flutter/material.dart';

class AppTheme {
  // 프리미엄 카페 테마 색상상
  static const primaryColor = Color(0xFF2C1810); // 에스프레소 브라운
  static const accentColor = Color(0xFFD4A373); // 라떼 골드
  static const secondaryColor = Color(0xFFBE123C); // 포인트 레드 (Rose 700)
  static const bgColor = Color(0xFFFAF9F6); // 리넨 화이트 (아이보리 톤)
  static const cardColor = Colors.white;
  static const borderColor = Color(0xFFE2E8F0);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: bgColor,
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        error: secondaryColor,
        surface: cardColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF475569), // Slate 600
          fontSize: 16,
        ),
      ),
    );
  }
}
