import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A date picker field with consistent styling.
class AppDatePicker extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final String label;
  final String? hint;
  final String? errorText;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;
  final String? dateFormat;
  final bool showClearButton;

  const AppDatePicker({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.hint,
    this.errorText,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
    this.dateFormat,
    this.showClearButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final format = DateFormat(dateFormat ?? 'dd/MM/yyyy');
    final displayText = value != null ? format.format(value!) : '';

    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint ?? 'DD/MM/YYYY',
        errorText: errorText,
        prefixIcon: const Icon(Icons.calendar_today),
        suffixIcon: showClearButton && value != null && enabled
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => onChanged(null),
                tooltip: 'Clear date',
              )
            : null,
      ),
      controller: TextEditingController(text: displayText),
      readOnly: true,
      enabled: enabled,
      onTap: enabled ? () => _showDatePicker(context) : null,
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
    );
    if (picked != null) {
      onChanged(picked);
    }
  }
}

/// A date range picker for selecting a period.
class AppDateRangePicker extends StatelessWidget {
  final DateTimeRange? value;
  final ValueChanged<DateTimeRange?> onChanged;
  final String label;
  final String? hint;
  final String? errorText;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;
  final String? dateFormat;

  const AppDateRangePicker({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.hint,
    this.errorText,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
    this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    final format = DateFormat(dateFormat ?? 'dd/MM/yyyy');
    final displayText = value != null
        ? '${format.format(value!.start)} - ${format.format(value!.end)}'
        : '';

    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint ?? 'Select date range',
        errorText: errorText,
        prefixIcon: const Icon(Icons.date_range),
        suffixIcon: value != null && enabled
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => onChanged(null),
                tooltip: 'Clear dates',
              )
            : null,
      ),
      controller: TextEditingController(text: displayText),
      readOnly: true,
      enabled: enabled,
      onTap: enabled ? () => _showDateRangePicker(context) : null,
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange:
          value ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          ),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
    );
    if (picked != null) {
      onChanged(picked);
    }
  }
}
