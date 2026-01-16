import 'package:flutter/material.dart';

/// A chip displaying a status badge with appropriate color.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool outlined;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (outlined) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Creates a "draft" status badge.
  factory StatusBadge.draft({Key? key}) {
    return StatusBadge(
      key: key,
      label: 'Draft',
      color: Colors.grey,
      icon: Icons.edit_outlined,
    );
  }

  /// Creates an "active" status badge.
  factory StatusBadge.active({Key? key}) {
    return StatusBadge(
      key: key,
      label: 'Active',
      color: Colors.green,
      icon: Icons.check_circle_outline,
    );
  }

  /// Creates a "closed" status badge.
  factory StatusBadge.closed({Key? key}) {
    return StatusBadge(
      key: key,
      label: 'Closed',
      color: Colors.blue,
      icon: Icons.lock_outline,
    );
  }

  /// Creates a "pending" status badge.
  factory StatusBadge.pending({Key? key}) {
    return StatusBadge(
      key: key,
      label: 'Pending',
      color: Colors.orange,
      icon: Icons.schedule,
    );
  }

  /// Creates a "cancelled" status badge.
  factory StatusBadge.cancelled({Key? key}) {
    return StatusBadge(
      key: key,
      label: 'Cancelled',
      color: Colors.red,
      icon: Icons.cancel_outlined,
    );
  }

  /// Creates a "vesting" status badge.
  factory StatusBadge.vesting({Key? key}) {
    return StatusBadge(
      key: key,
      label: 'Vesting',
      color: Colors.purple,
      icon: Icons.trending_up,
    );
  }

  /// Creates an "exercised" status badge.
  factory StatusBadge.exercised({Key? key}) {
    return StatusBadge(
      key: key,
      label: 'Exercised',
      color: Colors.green,
      icon: Icons.check,
    );
  }

  /// Creates an "expired" status badge.
  factory StatusBadge.expired({Key? key}) {
    return StatusBadge(
      key: key,
      label: 'Expired',
      color: Colors.grey,
      icon: Icons.timer_off,
    );
  }
}

/// A pill-shaped tag for categorizing items.
class TagPill extends StatelessWidget {
  final String label;
  final Color? color;
  final VoidCallback? onTap;
  final bool removable;
  final VoidCallback? onRemove;

  const TagPill({
    super.key,
    required this.label,
    this.color,
    this.onTap,
    this.removable = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: removable ? 8 : 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: chipColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(color: chipColor),
            ),
            if (removable) ...[
              const SizedBox(width: 4),
              InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(12),
                child: Icon(Icons.close, size: 16, color: chipColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A metric chip showing label and value.
class MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final IconData? icon;

  const MetricChip({
    super.key,
    required this.label,
    required this.value,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: chipColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
