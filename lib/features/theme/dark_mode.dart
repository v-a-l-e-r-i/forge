import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xff242424), // Головний фон: Black

  colorScheme: const ColorScheme.dark(
    primary: Color(0xff9055A2),         // Amethyst (Акценти, кнопки, прогрес-бари)
    surface: Color(0xff333333),         // Graphite (Фон для карток)
    onSurface: Colors.white,            // Білий текст на картках

    // Додаткові кольори палітри
    inverseSurface: Color(0xff242424),  // Black
    onInverseSurface: Color(0xffEDE7D9),// Soft Linen
    secondary: Color(0xffEDE7D9),       // Soft Linen
  ),

  // Автоматична прив'язка стилів до ColorScheme
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
  ),
);

// Метод декорації текстових полів для темної теми
InputDecoration inputDecorationDark(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Color(0xffEDE7D9)), // Soft Linen
    filled: true,
    fillColor: const Color(0xff333333), // Graphite
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xff9055A2), width: 2), // Amethyst
    ),
  );
}