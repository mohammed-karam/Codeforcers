import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color background = Color(0xFFF4F6F9);
  static const Color navy = Color(0xFF1B3B6F);
  static const Color blue = Color(0xFF2E6BD6);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE8ECF4);
  static const Color chipBackground = Color(0xFFF1F5F9);
  static const Color accentBlue = Color(0xFF2563EB);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [navy, blue],
  );

  static const LinearGradient level0Gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navy, blue],
  );

  static const LinearGradient level1Gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4338CA), Color(0xFF8B5CF6)],
  );

  static const LinearGradient aiTutorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0E7490), Color(0xFF06B6D4)],
  );
}
