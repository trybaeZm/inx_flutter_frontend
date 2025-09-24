import 'package:flutter/material.dart';

class NotionChartTheme {
  static const List<Color> categorical = <Color>[
    Color(0xFF3B82F6), // blue
    Color(0xFF10B981), // emerald
    Color(0xFFF59E0B), // amber
    Color(0xFFEF4444), // red
    Color(0xFF8B5CF6), // violet
    Color(0xFF06B6D4), // cyan
  ];

  static Color gridColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
  }

  static TextStyle axisTextStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      color: isDark ? Colors.grey[300] : Colors.grey[700],
      fontSize: 11,
    );
  }
}

