import 'package:flutter/material.dart';
import '../constants/api_constants.dart';

extension ThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

extension StringX on String {
  String get capitalize =>
      isEmpty ? '' : this[0].toUpperCase() + substring(1).toLowerCase();

  String get titleCase => split('-')
      .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
      .join(' ');
}

extension DoubleX on double {
  String get priceFormatted {
    if (this >= 1000) {
      return '\$${(this / 1000).toStringAsFixed(this % 1000 == 0 ? 0 : 1)}k';
    }
    return '\$${toStringAsFixed(truncateToDouble() == this ? 0 : 2)}';
  }
}

extension IntX on int {
  String get pageSkip => (this * ApiConstants.pageSize).toString();
}
