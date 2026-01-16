import 'package:flutter/material.dart';

/// A reusable page header component for tool pages.
///
/// Provides consistent layout with title, optional subtitle, and a child
/// widget (typically a [SummaryCardsRow] for displaying metrics).
///
/// Example:
/// ```dart
/// PageHeader(
///   title: 'Options',
///   subtitle: 'Manage stock option grants',
///   child: SummaryCardsRow(
///     cards: [
///       SummaryCard(label: 'Total', value: '1,000', icon: Icons.people, color: Colors.blue),
///       SummaryCard(label: 'Active', value: '500', icon: Icons.check, color: Colors.green),
///     ],
///   ),
/// )
/// ```
class PageHeader extends StatelessWidget {
  /// The main title displayed at the top.
  final String title;

  /// Optional subtitle displayed below the title.
  final String? subtitle;

  /// The child widget, typically a [SummaryCardsRow].
  final Widget? child;

  /// Padding around the header. Defaults to 16 on all sides.
  final EdgeInsets padding;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineMedium,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (child != null) ...[
            const SizedBox(height: 16),
            child!,
          ],
        ],
      ),
    );
  }
}
