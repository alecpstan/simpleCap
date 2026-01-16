import 'package:intl/intl.dart';

/// Centralized formatting utilities for consistent display across the app.
///
/// Locale: en_AU (Australian English)
/// Currency: AUD ($)
class Formatters {
  Formatters._();

  // === Number Formatters ===

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

  static final DateFormat _shortDateFormat = DateFormat('dd/MM/yy');

  // === Currency Formatting ===

  /// Full currency format: $1,234.56
  static String currency(double value) => _currencyFormat.format(value);

  /// Compact currency for large values: $1.2M, $500K
  /// Falls back to full format for values under $1M
  static String compactCurrency(double value) {
    if (value.abs() >= 1000000) {
      return _compactCurrencyFormat.format(value);
    }
    return _currencyFormat.format(value);
  }

  /// Compact with custom suffix: $1.5B, $2.3M, $50K
  static String compactCurrencyString(double value) {
    return '\$${compactNumberString(value)}';
  }

  // === Number Formatting ===

  /// Full number format with thousands separators: 1,234,567
  static String number(int value) => _numberFormat.format(value);

  /// Compact number for large values: 12K, 1.5M
  /// Falls back to full format for values under 10K
  static String compactNumber(int value) {
    if (value.abs() >= 10000) {
      return _compactNumberFormat.format(value);
    }
    return _numberFormat.format(value);
  }

  /// Compact number string with B/M/K suffixes (no currency symbol)
  static String compactNumberString(double value) {
    final absValue = value.abs();
    final sign = value < 0 ? '-' : '';

    if (absValue >= 1e9) return '$sign${(absValue / 1e9).toStringAsFixed(1)}B';
    if (absValue >= 1e6) return '$sign${(absValue / 1e6).toStringAsFixed(1)}M';
    if (absValue >= 1e3) return '$sign${(absValue / 1e3).toStringAsFixed(0)}K';
    return value.toStringAsFixed(0);
  }

  /// Format share count with label: "1,234 shares"
  static String shares(int value) => '${_numberFormat.format(value)} shares';

  // === Percentage Formatting ===

  /// Percentage with 2 decimal places: 12.34%
  static String percent(double value) => '${_percentFormat.format(value)}%';

  /// Percentage with no decimal places: 12%
  static String percentWhole(double value) => '${value.round()}%';

  // === Date Formatting ===

  /// Standard date format: 16 Jan 2026
  static String date(DateTime value) => _dateFormat.format(value);

  /// Short date format: 16/01/26
  static String shortDate(DateTime value) => _shortDateFormat.format(value);

  // === Dynamic Value Formatting ===

  /// Format a dynamic value appropriately based on its type
  static String formatValue(dynamic value) {
    if (value is double) {
      if (value.abs() > 1000) return currency(value);
      return value.toStringAsFixed(2);
    }
    if (value is int) return number(value);
    if (value is bool) return value ? 'Yes' : 'No';
    if (value is DateTime) return date(value);
    return value.toString();
  }
}

/// String manipulation utilities.
class StringHelpers {
  StringHelpers._();

  /// Convert camelCase to Title Case.
  /// Example: "preMoneyValuation" -> "Pre Money Valuation"
  static String camelToTitle(String text) {
    if (text.isEmpty) return text;
    return text
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .trim()
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');
  }

  /// Get initials from a name (up to 2 characters)
  static String initials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
