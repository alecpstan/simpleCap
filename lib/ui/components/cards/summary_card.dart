import 'package:flutter/material.dart';

/// A compact summary card for displaying metrics inline.
///
/// Typically used in a row at the top of list pages.
class SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: content,
      );
    }
    return content;
  }
}

/// A small statistic display with label and value.
///
/// More compact than SummaryCard, for inline display.
class MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const MiniStat({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

/// A responsive row layout for SummaryCards.
///
/// Displays cards in a 2-column grid with the last card taking full width
/// if there's an odd number of cards. This ensures a consistent layout
/// across tool pages.
class SummaryCardsRow extends StatelessWidget {
  /// The list of SummaryCard widgets to display.
  final List<Widget> cards;

  /// Spacing between cards. Defaults to 8.0.
  final double spacing;

  const SummaryCardsRow({
    super.key,
    required this.cards,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Max 2 cards per row
        final cardsPerRow = cards.length == 1 ? 1 : 2;
        final totalSpacing = spacing * (cardsPerRow - 1);
        final cardWidth = (constraints.maxWidth - totalSpacing) / cardsPerRow;
        final fullWidth = constraints.maxWidth;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards.asMap().entries.map((entry) {
            final index = entry.key;
            final card = entry.value;
            // Last card gets full width if odd total
            final isLastOdd = cards.length.isOdd && index == cards.length - 1;
            final width = isLastOdd ? fullWidth : cardWidth;
            return SizedBox(width: width, child: card);
          }).toList(),
        );
      },
    );
  }
}

/// A colored chip for displaying results/metrics.
class ResultChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const ResultChip({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: color),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
