import 'package:flutter/material.dart';

/// An empty state placeholder with icon, title, and optional action.
///
/// Used when lists/sections have no data to display.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: iconColor ?? theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Convenience constructor for a "no items" state.
  factory EmptyState.noItems({
    Key? key,
    required String itemType,
    VoidCallback? onAdd,
  }) {
    return EmptyState(
      key: key,
      icon: Icons.inbox_outlined,
      title: 'No ${itemType}s yet',
      message: 'Get started by adding your first $itemType.',
      actionLabel: onAdd != null ? 'Add $itemType' : null,
      onAction: onAdd,
    );
  }

  /// Convenience constructor for a "no results" state.
  factory EmptyState.noResults({
    Key? key,
    String? searchQuery,
    VoidCallback? onClear,
  }) {
    return EmptyState(
      key: key,
      icon: Icons.search_off,
      title: 'No results found',
      message: searchQuery != null
          ? 'No items match "$searchQuery"'
          : 'Try adjusting your filters',
      actionLabel: onClear != null ? 'Clear filters' : null,
      onAction: onClear,
    );
  }

  /// Convenience constructor for an error state.
  factory EmptyState.error({Key? key, String? message, VoidCallback? onRetry}) {
    return EmptyState(
      key: key,
      icon: Icons.error_outline,
      title: 'Something went wrong',
      message: message ?? 'Please try again later.',
      actionLabel: onRetry != null ? 'Retry' : null,
      onAction: onRetry,
      iconColor: Colors.red,
    );
  }
}

/// A full-page empty state with larger styling.
class EmptyPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  const EmptyPage({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 96, color: theme.colorScheme.outline),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                if (message != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    message!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (action != null) ...[const SizedBox(height: 32), action!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
