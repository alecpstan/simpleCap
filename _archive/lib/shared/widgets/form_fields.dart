import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'help_icon.dart';
import '../utils/helpers.dart';

/// Standard text input field with consistent styling
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final String? helpKey;
  final String? prefixText;
  final String? suffixText;
  final Widget? suffix;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;
  final bool autofocus;
  final bool readOnly;
  final bool enabled;
  final bool obscureText;

  const AppTextField({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText,
    this.helpKey,
    this.prefixText,
    this.suffixText,
    this.suffix,
    this.prefixIcon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.autofocus = false,
    this.readOnly = false,
    this.enabled = true,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
        isDense: true,
        prefixText: prefixText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixText: suffixText,
        suffixIcon: _buildSuffixIcon(),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines,
      autofocus: autofocus,
      readOnly: readOnly,
      enabled: enabled,
      obscureText: obscureText,
    );
  }

  Widget? _buildSuffixIcon() {
    if (helpKey != null && suffix != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          suffix!,
          HelpIcon(helpKey: helpKey!),
        ],
      );
    }
    if (helpKey != null) {
      return HelpIcon(helpKey: helpKey!);
    }
    return suffix;
  }
}

/// Dropdown field with consistent styling
class AppDropdownField<T> extends StatelessWidget {
  final T? value;
  final String labelText;
  final String? helpKey;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;

  const AppDropdownField({
    super.key,
    this.value,
    required this.labelText,
    this.helpKey,
    required this.items,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        isDense: true,
        suffixIcon: helpKey != null ? HelpIcon(helpKey: helpKey!) : null,
      ),
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
    );
  }
}

/// Date picker field with consistent styling
class AppDateField extends StatelessWidget {
  final DateTime value;
  final String labelText;
  final String? helpKey;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final void Function(DateTime) onChanged;
  final bool enabled;

  const AppDateField({
    super.key,
    required this.value,
    required this.labelText,
    this.helpKey,
    this.firstDate,
    this.lastDate,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveFirstDate = firstDate ?? DateTime(2000);
    final effectiveLastDate = lastDate ?? DateTime(2100);

    return InkWell(
      onTap: enabled
          ? () async {
              final date = await showDatePicker(
                context: context,
                initialDate: value,
                firstDate: effectiveFirstDate,
                lastDate: effectiveLastDate,
              );
              if (date != null) {
                onChanged(date);
              }
            }
          : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
          isDense: true,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today, size: 18),
              if (helpKey != null) HelpIcon(helpKey: helpKey!),
            ],
          ),
        ),
        child: Text(
          Formatters.date(value),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: enabled ? null : theme.colorScheme.outline,
          ),
        ),
      ),
    );
  }
}

/// Info box with icon and text for contextual information
class InfoBox extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color? color;
  final bool compact;

  const InfoBox({
    super.key,
    required this.text,
    this.icon = Icons.info_outline,
    this.color,
    this.compact = false,
  });

  /// Blue-themed info box
  const InfoBox.info({super.key, required this.text, this.compact = false})
    : icon = Icons.info_outline,
      color = Colors.blue;

  /// Amber-themed warning box
  const InfoBox.warning({super.key, required this.text, this.compact = false})
    : icon = Icons.warning_amber_outlined,
      color = Colors.amber;

  /// Red-themed error box
  const InfoBox.error({super.key, required this.text, this.compact = false})
    : icon = Icons.error_outline,
      color = Colors.red;

  /// Green-themed success box
  const InfoBox.success({super.key, required this.text, this.compact = false})
    : icon = Icons.check_circle_outline,
      color = Colors.green;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    return Container(
      padding: EdgeInsets.all(compact ? 8 : 12),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: effectiveColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: effectiveColor, size: compact ? 16 : 20),
          SizedBox(width: compact ? 6 : 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: effectiveColor.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Summary/preview box for form previews
class PreviewBox extends StatelessWidget {
  final String? title;
  final List<PreviewRow> rows;
  final Color? color;

  const PreviewBox({super.key, this.title, required this.rows, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: effectiveColor,
              ),
            ),
            const SizedBox(height: 8),
          ],
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(row.label, style: theme.textTheme.bodySmall),
                  Text(
                    row.value,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A row in a PreviewBox
class PreviewRow {
  final String label;
  final String value;

  const PreviewRow(this.label, this.value);
}

/// Switch field with consistent styling
class AppSwitchField extends StatelessWidget {
  final bool value;
  final String title;
  final String? subtitle;
  final String? helpKey;
  final void Function(bool)? onChanged;
  final bool enabled;

  const AppSwitchField({
    super.key,
    required this.value,
    required this.title,
    this.subtitle,
    this.helpKey,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SwitchListTile(
            title: Text(title),
            subtitle: subtitle != null ? Text(subtitle!) : null,
            value: value,
            onChanged: enabled ? onChanged : null,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        if (helpKey != null) HelpIcon(helpKey: helpKey!),
      ],
    );
  }
}

/// Segmented button field with consistent styling
class AppSegmentedField<T> extends StatelessWidget {
  final Set<T> selected;
  final List<ButtonSegment<T>> segments;
  final void Function(Set<T>) onSelectionChanged;
  final String? label;
  final String? helpKey;
  final bool enabled;

  const AppSegmentedField({
    super.key,
    required this.selected,
    required this.segments,
    required this.onSelectionChanged,
    this.label,
    this.helpKey,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(label!, style: theme.textTheme.labelMedium),
                if (helpKey != null) HelpIcon(helpKey: helpKey!),
              ],
            ),
          ),
        SegmentedButton<T>(
          segments: segments,
          selected: selected,
          onSelectionChanged: enabled ? onSelectionChanged : (_) {},
        ),
      ],
    );
  }
}

/// Quick action chips for common values
class QuickValueChips extends StatelessWidget {
  final String label;
  final List<QuickValue> values;
  final void Function(dynamic value) onSelected;

  const QuickValueChips({
    super.key,
    required this.label,
    required this.values,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values.map((v) {
            return ActionChip(
              label: Text(v.label),
              onPressed: () => onSelected(v.value),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// A quick value option
class QuickValue {
  final String label;
  final dynamic value;

  const QuickValue(this.label, this.value);
}

/// Standard form section with title
class FormSection extends StatelessWidget {
  final String? title;
  final String? helpKey;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  const FormSection({
    super.key,
    this.title,
    this.helpKey,
    required this.children,
    this.padding = const EdgeInsets.only(bottom: 16),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Text(
                  title!,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (helpKey != null) HelpIcon(helpKey: helpKey!),
              ],
            ),
            const SizedBox(height: 12),
          ],
          ...children,
        ],
      ),
    );
  }
}
