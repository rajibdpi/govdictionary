import 'package:flutter/material.dart';

class AppColors {
  // 🌈 Primary Colors (Kept original or adjust as you want)
  static const Color primaryLight = Color(0xFFFFFFFF); // Soft Indigo
  static const Color primaryDark = Color(0xFF2E2E41); // Deeper Indigo
  static const Color accentLight = Color(0xFF457BE8); // Soft Sky Blue
  static const Color accentDark = Color(0xFF757580); // Aqua Blue

  // 🎨 Background Colors (from image)
  static const Color backgroundLight = Color(0xFFFFFFFF); // Light bluish
  static const Color backgroundDark = Color(0xFF2E2E41); // Soft dark

  // ✍️ Text Colors (from image & adjusted for contrast)
  static const Color textColor = Color(0xFF778899); // Muted gray
  static const Color textPrimaryLight = Color(0xFF1F2937); // Dark gray
  static const Color textSecondaryLight = Color(0xFF6B7280); // Muted gray
  static const Color textPrimaryDark = Color(0xFFFFFFFF); // White
  static const Color textSecondaryDark = Color(0xFFE7ECFF); // Soft light blue

  static const Color textLink = Color(0xFF778899); // Soft blue
  // ⚡ Status Colors (Kept original)
  static const Color error = Color(0xFFEF4444); // Soft red
  static const Color success = Color(0xFF10B981); // Soft green
  static const Color warning = Color(0xFFF59E0B); // Warm amber
  static const Color info = Color(0xFF3B82F6); // Soft blue

  // 🌅 Gradient (from image colors)
  static LinearGradient softBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      const Color(0xFFE6EDFF).withAlpha(25), // Light bluish
      const Color(0xFFFFFFFF).withAlpha(25), // White
    ],
  );
}
