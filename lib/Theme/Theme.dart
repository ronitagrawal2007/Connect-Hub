import 'package:flutter/material.dart';

ThemeData themeData = ThemeData(
  brightness: Brightness.light,

  // Scaffold background color using the very soft, clean cream tint
  scaffoldBackgroundColor: const Color(0xFFFFF8F0),

  colorScheme: ColorScheme.light(
    // Cream white base surface
    surface: const Color(0xFFFFF8F0),

    // Warm sandy tan as the primary action/accent color
    primary: const Color(0xFFC08552),

    // Medium brown/terracotta for sub-elements or container highlights
    secondary: const Color(0xFF8C5A3C),

    // Deep espresso dark brown for high-contrast typography, icons, and focus outlines
    tertiary: const Color(0xFF4B2E2B),

    // Fallback inverse color (e.g. text resting inside deep espresso buttons)
    inversePrimary: Colors.white,
  ),

  // Automatically apply the deep espresso color to text globally
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF4B2E2B)),
    bodyMedium: TextStyle(color: Color(0xFF4B2E2B)),
    headlineMedium: TextStyle(
      color: Color(0xFF4B2E2B),
      fontWeight: FontWeight.bold,
    ),
  ),
);
