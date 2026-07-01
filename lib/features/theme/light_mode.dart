import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xffEDE7D9), // Головний фон: Soft Linen

  colorScheme: const ColorScheme.light(
    primary: Color(0xff9055A2),         // Amethyst (Акценти, кнопки, прогрес-бари)
    surface: Colors.white,              // Чистий білий для карток на світлому фоні
    onSurface: Color(0xff333333),       // Graphite (Текст на картках)

    // Додаткові кольори палітри
    inverseSurface: Color(0xff000000),  // Black
    onInverseSurface: Color(0xffEDE7D9),// Soft Linen
    secondary: Color(0xff333333),       // Graphite
  ),

  // Автоматична прив'язка стилів доColorScheme
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: Color(0xff000000)), // Black
    titleTextStyle: TextStyle(color: Color(0xff000000), fontSize: 20, fontWeight: FontWeight.bold),
  ),
);

// Метод декорації текстових полів для світлої теми
InputDecoration inputDecorationLight(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Color(0xff333333)), // Graphite
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.7),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xff9055A2), width: 2), // Amethyst
    ),
  );
}