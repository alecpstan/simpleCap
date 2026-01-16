import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_AU',
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _compactCurrencyFormat =
      NumberFormat.compactCurrency(
        locale: 'en_AU',
        symbol: '\$',
        decimalDigits: 1,
      );

  static final NumberFormat _numberFormat = NumberFormat('#,###', 'en_AU');

  static final NumberFormat _compactNumberFormat = NumberFormat.compact(
    locale: 'en_AU',
  );

  static final NumberFormat _percentFormat = NumberFormat('##0.00', 'en_AU');

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  static String currency(double value) => _currencyFormat.format(value);

  static String compactCurrency(double value) {
    if (value >= 1000000) {
      return _compactCurrencyFormat.format(value);
    }
    return _currencyFormat.format(value);
  }

  static String number(int value) => _numberFormat.format(value);

  static String compactNumber(int value) {
    if (value >= 10000) {
      return _compactNumberFormat.format(value);
    }
    return _numberFormat.format(value);
  }

  static String shares(int value) => '${_numberFormat.format(value)} shares';

  static String percent(double value) => '${_percentFormat.format(value)}%';

  static String date(DateTime value) => _dateFormat.format(value);

  /// Format large numbers with B/M/K suffixes (no currency symbol).
  /// Use for displaying counts or plain numbers compactly.
  /// Examples: 1500000000 -> "1.5B", 2500000 -> "2.5M", 50000 -> "50K"
  static String compactNumberString(double value) {
    if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(1)}B';
    if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(1)}M';
    if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(0)}K';
    return value.toStringAsFixed(0);
  }

  /// Format large currency values with B/M/K suffixes and $ symbol.
  /// Examples: 1500000000 -> "$1.5B", 2500000 -> "$2.5M"
  static String compactCurrencyString(double value) {
    return '\$${compactNumberString(value)}';
  }
}

/// String manipulation utilities.
class StringHelpers {
  /// Convert camelCase to Title Case.
  /// Example: "preMoneyValuation" -> "Pre Money Valuation"
  static String camelToTitle(String text) {
    if (text.isEmpty) return text;
    return text
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .trim()
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  /// Format a dynamic value for display (useful for metadata).
  static String formatValue(dynamic value) {
    if (value is double) {
      if (value > 1000) return Formatters.currency(value);
      return value.toStringAsFixed(2);
    }
    if (value is bool) return value ? 'Yes' : 'No';
    if (value is int) return Formatters.number(value);
    return value.toString();
  }
}

class AppColors {
  static const List<Color> chartColors = [
    Color(0xFF2196F3), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFF44336), // Red
    Color(0xFFFF9800), // Orange
    Color(0xFF9C27B0), // Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFFE91E63), // Pink
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
    Color(0xFFFFEB3B), // Yellow
  ];

  static Color getChartColor(int index) {
    return chartColors[index % chartColors.length];
  }
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 600) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
