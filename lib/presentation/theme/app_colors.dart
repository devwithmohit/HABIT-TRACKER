import 'package:flutter/material.dart';

/// App color palette
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF5A52E0);
  static const Color primaryLight = Color(0xFF9B96FF);

  // Accent colors
  static const Color accent = Color(0xFFFF6584);
  static const Color accentLight = Color(0xFFFF8BA0);

  // Neutral colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F5);

  // Text colors
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textDisabled = Color(0xFFADB5BD);

  // Dark theme colors
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariantDark = Color(0xFF2A2A2A);

  // AMOLED theme colors
  static const Color backgroundAmoled = Color(0xFF000000);
  static const Color surfaceAmoled = Color(0xFF0A0A0A);

  // Status colors
  static const Color success = Color(0xFF51CF66);
  static const Color warning = Color(0xFFFCC419);
  static const Color error = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF339AF0);

  // Habit colors (for customization)
  static const List<Color> habitColors = [
    Color(0xFFFF6B6B), // Red
    Color(0xFFFF8787), // Light Red
    Color(0xFFFA5252), // Dark Red
    Color(0xFFFF922B), // Orange
    Color(0xFFFFC078), // Light Orange
    Color(0xFFFCC419), // Yellow
    Color(0xFFFFF3BF), // Light Yellow
    Color(0xFF51CF66), // Green
    Color(0xFF8CE99A), // Light Green
    Color(0xFF2F9E44), // Dark Green
    Color(0xFF339AF0), // Blue
    Color(0xFF74C0FC), // Light Blue
    Color(0xFF1C7ED6), // Dark Blue
    Color(0xFF6C63FF), // Purple
    Color(0xFF9B96FF), // Light Purple
    Color(0xFF5A52E0), // Dark Purple
    Color(0xFFCC5DE8), // Pink
    Color(0xFFE599F7), // Light Pink
    Color(0xFFFF6584), // Hot Pink
    Color(0xFF868E96), // Gray
  ];

  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Streak colors (for motivation)
  static Color getStreakColor(int days) {
    if (days == 0) return textDisabled;
    if (days < 7) return info;
    if (days < 30) return success;
    if (days < 90) return warning;
    return accent; // 90+ days
  }

  // Get color by hex string
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  // Convert color to hex string
  static String toHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}
