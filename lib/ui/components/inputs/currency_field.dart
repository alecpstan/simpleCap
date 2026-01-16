import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// A text field for currency input with automatic formatting.
///
/// Formats as the user types (e.g., "1234567" → "$1,234,567.00").
class CurrencyField extends StatefulWidget {
  final String label;
  final double? initialValue;
  final ValueChanged<double?>? onChanged;
  final String? errorText;
  final String? helperText;
  final bool enabled;
  final String currencySymbol;
  final int decimalPlaces;

  const CurrencyField({
    super.key,
    required this.label,
    this.initialValue,
    this.onChanged,
    this.errorText,
    this.helperText,
    this.enabled = true,
    this.currencySymbol = '\$',
    this.decimalPlaces = 2,
  });

  @override
  State<CurrencyField> createState() => _CurrencyFieldState();
}

class _CurrencyFieldState extends State<CurrencyField> {
  late TextEditingController _controller;
  late NumberFormat _formatter;

  @override
  void initState() {
    super.initState();
    _formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: widget.decimalPlaces,
    );

    final initialText = widget.initialValue != null
        ? _formatter.format(widget.initialValue).trim()
        : '';
    _controller = TextEditingController(text: initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double? _parseValue(String text) {
    final clean = text.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(clean);
  }

  void _onChanged(String text) {
    final value = _parseValue(text);
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixText: widget.currencySymbol,
        helperText: widget.helperText,
        errorText: widget.errorText,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        _CurrencyInputFormatter(decimalPlaces: widget.decimalPlaces),
      ],
      onChanged: _onChanged,
      enabled: widget.enabled,
    );
  }
}

/// Input formatter that formats numbers with commas.
class _CurrencyInputFormatter extends TextInputFormatter {
  final int decimalPlaces;
  late final NumberFormat _formatter;

  _CurrencyInputFormatter({this.decimalPlaces = 2}) {
    _formatter = NumberFormat.decimalPattern();
    _formatter.maximumFractionDigits = decimalPlaces;
    _formatter.minimumFractionDigits = 0;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-numeric characters except decimal point
    String clean = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');

    // Handle decimal point
    final parts = clean.split('.');
    if (parts.length > 2) {
      // More than one decimal point - keep only first
      clean = '${parts[0]}.${parts.sublist(1).join('')}';
    }

    // Limit decimal places
    if (parts.length == 2 && parts[1].length > decimalPlaces) {
      clean = '${parts[0]}.${parts[1].substring(0, decimalPlaces)}';
    }

    // Parse and format
    final number = double.tryParse(clean);
    if (number == null) {
      return newValue;
    }

    // Format with commas
    String formatted;
    if (clean.contains('.')) {
      final decimalPart = clean.split('.')[1];
      formatted = '${_formatter.format(number.floor())}.$decimalPart';
    } else {
      formatted = _formatter.format(number);
    }

    // Calculate new cursor position
    final oldCursorOffset = oldValue.selection.end;
    final oldLength = oldValue.text.length;
    final newLength = formatted.length;
    final newCursorOffset = oldCursorOffset + (newLength - oldLength);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: newCursorOffset.clamp(0, formatted.length),
      ),
    );
  }
}
