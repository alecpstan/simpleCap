import 'package:flutter/material.dart';

/// A styled dropdown with consistent appearance.
class AppDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String label;
  final String? hint;
  final String? errorText;
  final bool enabled;
  final Widget? prefixIcon;

  const AppDropdown({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
    required this.label,
    this.hint,
    this.errorText,
    this.enabled = true,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        prefixIcon: prefixIcon,
      ),
    );
  }

  /// Helper to build a dropdown from an enum.
  static AppDropdown<E> fromEnum<E extends Enum>({
    Key? key,
    required E? value,
    required List<E> values,
    required ValueChanged<E?>? onChanged,
    required String label,
    String? hint,
    String? errorText,
    bool enabled = true,
    Widget? prefixIcon,
    String Function(E)? labelBuilder,
  }) {
    return AppDropdown<E>(
      key: key,
      value: value,
      items: values.map((e) {
        final label = labelBuilder?.call(e) ?? _enumToLabel(e);
        return DropdownMenuItem<E>(value: e, child: Text(label));
      }).toList(),
      onChanged: onChanged,
      label: label,
      hint: hint,
      errorText: errorText,
      enabled: enabled,
      prefixIcon: prefixIcon,
    );
  }

  static String _enumToLabel<E extends Enum>(E value) {
    // Convert camelCase to Title Case
    final name = value.name;
    final buffer = StringBuffer();
    for (int i = 0; i < name.length; i++) {
      final char = name[i];
      if (i == 0) {
        buffer.write(char.toUpperCase());
      } else if (char.toUpperCase() == char && char.toLowerCase() != char) {
        buffer.write(' $char');
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }
}

/// A segmented button group for selecting from a small set of options.
class SegmentedSelector<T> extends StatelessWidget {
  final T selected;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;
  final bool enabled;

  const SegmentedSelector({
    super.key,
    required this.selected,
    required this.options,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<T>(
      segments: options.entries
          .map((e) => ButtonSegment<T>(value: e.key, label: Text(e.value)))
          .toList(),
      selected: {selected},
      onSelectionChanged: enabled
          ? (selection) {
              if (selection.isNotEmpty) {
                onChanged(selection.first);
              }
            }
          : null,
    );
  }
}
