import 'package:flutter/material.dart';

/// The type of info box, determining its color scheme.
enum InfoBoxType { info, warning, error, success, tip }

/// An informational box with icon and message.
///
/// Used for inline help, warnings, or important notices.
class InfoBox extends StatelessWidget {
  final InfoBoxType type;
  final String? title;
  final String message;
  final Widget? action;
  final VoidCallback? onDismiss;

  const InfoBox({
    super.key,
    this.type = InfoBoxType.info,
    this.title,
    required this.message,
    this.action,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getColor(theme);
    final icon = _getIcon();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (action != null) ...[const SizedBox(height: 8), action!],
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: Icon(Icons.close, size: 18, color: color),
              onPressed: onDismiss,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }

  Color _getColor(ThemeData theme) {
    switch (type) {
      case InfoBoxType.info:
        return theme.colorScheme.primary;
      case InfoBoxType.warning:
        return Colors.orange;
      case InfoBoxType.error:
        return theme.colorScheme.error;
      case InfoBoxType.success:
        return Colors.green;
      case InfoBoxType.tip:
        return Colors.purple;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case InfoBoxType.info:
        return Icons.info_outline;
      case InfoBoxType.warning:
        return Icons.warning_amber_outlined;
      case InfoBoxType.error:
        return Icons.error_outline;
      case InfoBoxType.success:
        return Icons.check_circle_outline;
      case InfoBoxType.tip:
        return Icons.lightbulb_outline;
    }
  }

  /// Creates an info box.
  factory InfoBox.info({
    Key? key,
    String? title,
    required String message,
    Widget? action,
    VoidCallback? onDismiss,
  }) {
    return InfoBox(
      key: key,
      type: InfoBoxType.info,
      title: title,
      message: message,
      action: action,
      onDismiss: onDismiss,
    );
  }

  /// Creates a warning box.
  factory InfoBox.warning({
    Key? key,
    String? title,
    required String message,
    Widget? action,
    VoidCallback? onDismiss,
  }) {
    return InfoBox(
      key: key,
      type: InfoBoxType.warning,
      title: title,
      message: message,
      action: action,
      onDismiss: onDismiss,
    );
  }

  /// Creates an error box.
  factory InfoBox.error({
    Key? key,
    String? title,
    required String message,
    Widget? action,
    VoidCallback? onDismiss,
  }) {
    return InfoBox(
      key: key,
      type: InfoBoxType.error,
      title: title,
      message: message,
      action: action,
      onDismiss: onDismiss,
    );
  }

  /// Creates a success box.
  factory InfoBox.success({
    Key? key,
    String? title,
    required String message,
    Widget? action,
    VoidCallback? onDismiss,
  }) {
    return InfoBox(
      key: key,
      type: InfoBoxType.success,
      title: title,
      message: message,
      action: action,
      onDismiss: onDismiss,
    );
  }

  /// Creates a tip box.
  factory InfoBox.tip({
    Key? key,
    String? title,
    required String message,
    Widget? action,
    VoidCallback? onDismiss,
  }) {
    return InfoBox(
      key: key,
      type: InfoBoxType.tip,
      title: title,
      message: message,
      action: action,
      onDismiss: onDismiss,
    );
  }
}
