import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: Colors.grey[900],  // Фон всего приложения
  primaryColor: Colors.green,  // Основной цвет
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Color(0xFFC9F24C)), // Текст с цветом #C9F24C
    bodyMedium: TextStyle(color: Color(0xFFC9F24C)), // Текст с цветом #C9F24C
    bodySmall: TextStyle(color: Color(0xFFC9F24C)), // Для мелкого текста
    headlineLarge: TextStyle(
      color: Color(0xFFC9F24C),  // Текст заголовков с цветом #C9F24C
      fontWeight: FontWeight.bold,
      fontSize: 24.0,
    ), // Для крупных заголовков
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[900],  // Фон AppBar теперь такой же, как у всего приложения
    foregroundColor: const Color(0xFFC9F24C),  // Цвет текста и иконок для AppBar с цветом #C9F24C
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[800],  // Цвет фона для полей ввода
    border: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFFC9F24C)),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFFC9F24C)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFFC9F24C), width: 2.0),
    ),
    hintStyle: const TextStyle(color: Color(0xFFC9F24C)),
    labelStyle: const TextStyle(color: Color(0xFFC9F24C)),
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);
