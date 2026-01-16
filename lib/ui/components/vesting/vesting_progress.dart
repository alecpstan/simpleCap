import 'package:flutter/material.dart';
import '../../../shared/formatters.dart';

/// A visual representation of vesting progress.
class VestingProgressBar extends StatelessWidget {
  const VestingProgressBar({
    super.key,
    required this.vestedPercent,
    required this.vestedQuantity,
    required this.totalQuantity,
    this.cliffDate,
    this.isCliffMet = true,
    this.vestingEndDate,
    this.nextVestingDate,
    this.nextVestingQuantity = 0,
    this.showDetails = true,
    this.compact = false,
  });

  /// Percentage vested (0-100).
  final double vestedPercent;

  /// Number of units vested.
  final int vestedQuantity;

  /// Total units in the grant.
  final int totalQuantity;

  /// Date when cliff is met (null if no cliff).
  final DateTime? cliffDate;

  /// Whether the cliff has been met.
  final bool isCliffMet;

  /// Date when vesting completes.
  final DateTime? vestingEndDate;

  /// Next vesting date (null if fully vested).
  final DateTime? nextVestingDate;

  /// Quantity vesting at next date.
  final int nextVestingQuantity;

  /// Whether to show detailed information below the bar.
  final bool showDetails;

  /// Use compact styling for list items.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isFullyVested = vestedPercent >= 100;
    final unvestedQuantity = totalQuantity - vestedQuantity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar
        _buildProgressBar(context, colorScheme),

        if (showDetails) ...[
          SizedBox(height: compact ? 4 : 8),
          // Status row
          _buildStatusRow(context, isFullyVested, unvestedQuantity),

          // Next vesting info (if not fully vested)
          if (!isFullyVested && nextVestingDate != null) ...[
            SizedBox(height: compact ? 2 : 4),
            _buildNextVestingRow(context),
          ],
        ],
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context, ColorScheme colorScheme) {
    final height = compact ? 8.0 : 12.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            // Background (unvested)
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
              ),
            ),

            // Cliff indicator (if cliff not met)
            if (!isCliffMet && cliffDate != null)
              Positioned.fill(
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _getCliffPosition(),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: colorScheme.outline, width: 2),
                      ),
                    ),
                  ),
                ),
              ),

            // Vested portion
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (vestedPercent / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(
    BuildContext context,
    bool isFullyVested,
    int unvestedQuantity,
  ) {
    final theme = Theme.of(context);
    final textStyle = compact
        ? theme.textTheme.bodySmall
        : theme.textTheme.bodyMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Vested amount
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFullyVested ? Icons.check_circle : Icons.schedule,
              size: compact ? 14 : 16,
              color: isFullyVested ? Colors.green : theme.colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              isFullyVested
                  ? 'Fully Vested'
                  : '${Formatters.compactNumber(vestedQuantity)} vested',
              style: textStyle?.copyWith(
                fontWeight: FontWeight.w500,
                color: isFullyVested ? Colors.green : null,
              ),
            ),
          ],
        ),

        // Percentage or unvested
        Text(
          isFullyVested
              ? '${Formatters.number(totalQuantity)} total'
              : '${vestedPercent.toStringAsFixed(1)}%',
          style: textStyle?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildNextVestingRow(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = compact
        ? theme.textTheme.labelSmall
        : theme.textTheme.bodySmall;

    final daysUntil = nextVestingDate!.difference(DateTime.now()).inDays;
    final daysText = daysUntil == 0
        ? 'today'
        : daysUntil == 1
        ? 'tomorrow'
        : 'in $daysUntil days';

    return Row(
      children: [
        Icon(
          Icons.event,
          size: compact ? 12 : 14,
          color: theme.colorScheme.secondary,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            'Next: ${Formatters.compactNumber(nextVestingQuantity)} shares $daysText (${Formatters.shortDate(nextVestingDate!)})',
            style: textStyle?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  double _getCliffPosition() {
    if (cliffDate == null || vestingEndDate == null) return 0;

    // Calculate cliff as a fraction of total vesting period
    // This is approximate - we'd need grant date for exact calculation
    return 0.25; // Default to 25% for 1-year cliff in 4-year vest
  }
}

/// A compact vesting chip for use in cards/lists.
class VestingChip extends StatelessWidget {
  const VestingChip({
    super.key,
    required this.vestedPercent,
    required this.isCliffMet,
  });

  final double vestedPercent;
  final bool isCliffMet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFullyVested = vestedPercent >= 100;

    Color backgroundColor;
    Color foregroundColor;
    IconData icon;
    String label;

    if (isFullyVested) {
      backgroundColor = Colors.green.withOpacity(0.1);
      foregroundColor = Colors.green;
      icon = Icons.check_circle;
      label = 'Vested';
    } else if (!isCliffMet) {
      backgroundColor = Colors.orange.withOpacity(0.1);
      foregroundColor = Colors.orange;
      icon = Icons.hourglass_empty;
      label = 'Cliff';
    } else {
      backgroundColor = theme.colorScheme.primaryContainer;
      foregroundColor = theme.colorScheme.onPrimaryContainer;
      icon = Icons.schedule;
      label = '${vestedPercent.toStringAsFixed(0)}%';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foregroundColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows a vesting schedule summary in text form.
class VestingScheduleSummary extends StatelessWidget {
  const VestingScheduleSummary({
    super.key,
    required this.scheduleName,
    this.grantDate,
    this.vestingEndDate,
    this.cliffDate,
  });

  final String scheduleName;
  final DateTime? grantDate;
  final DateTime? vestingEndDate;
  final DateTime? cliffDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_month, size: 16),
            const SizedBox(width: 8),
            Text(scheduleName, style: theme.textTheme.titleSmall),
          ],
        ),
        if (grantDate != null || vestingEndDate != null) ...[
          const SizedBox(height: 4),
          Text(
            _buildDateRange(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  String _buildDateRange() {
    final parts = <String>[];
    if (grantDate != null) {
      parts.add('Start: ${Formatters.shortDate(grantDate!)}');
    }
    if (cliffDate != null) {
      parts.add('Cliff: ${Formatters.shortDate(cliffDate!)}');
    }
    if (vestingEndDate != null) {
      parts.add('End: ${Formatters.shortDate(vestingEndDate!)}');
    }
    return parts.join(' • ');
  }
}
