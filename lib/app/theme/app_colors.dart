import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary (blue)
  static const primary = Color(0xFF2563EB);
  static const primaryDark = Color(0xFF1D4ED8);
  static const primaryLight = Color(0xFF60A5FA);

  // Accent (amber — prices, badges)
  static const accent = Color(0xFFF59E0B);

  // Status
  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF10B981);
  static const discount = Color(0xFFEF4444);

  // Light
  static const backgroundLight = Color(0xFFF8FAFC);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const onSurfaceLight = Color(0xFF1E293B);
  static const subtitleLight = Color(0xFF64748B);
  static const borderLight = Color(0xFFE2E8F0);

  // Dark
  static const backgroundDark = Color(0xFF0F172A);
  static const surfaceDark = Color(0xFF1E293B);
  static const onSurfaceDark = Color(0xFFF1F5F9);
  static const subtitleDark = Color(0xFF94A3B8);
  static const borderDark = Color(0xFF334155);
}
