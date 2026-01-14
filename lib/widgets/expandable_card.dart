import 'package:flutter/material.dart';

/// A card with a summary that expands to show details
/// Primary UI pattern for the mobile-first design
class ExpandableCard extends StatefulWidget {
  /// Leading widget (typically an avatar or icon)
  final Widget? leading;

  /// Title text
  final String title;

  /// Subtitle text (optional)
  final String? subtitle;

  /// Trailing widget when collapsed (optional, e.g., a value)
  final Widget? trailing;

  /// Summary chips to show below title when collapsed
  final List<Widget>? chips;

  /// Content to show when expanded
  final Widget expandedContent;

  /// Whether the card starts expanded
  final bool initiallyExpanded;

  /// Callback when card is tapped (before expand/collapse)
  final VoidCallback? onTap;

  /// Actions to show at bottom when expanded
  final List<Widget>? actions;

  /// Color accent for the card
  final Color? accentColor;

  /// Whether to show expand indicator
  final bool showExpandIcon;

  const ExpandableCard({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.chips,
    required this.expandedContent,
    this.initiallyExpanded = false,
    this.onTap,
    this.actions,
    this.accentColor,
    this.showExpandIcon = true,
  });

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _iconTurns;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _iconTurns = _controller.drive(
      Tween<double>(
        begin: 0.0,
        end: 0.5,
      ).chain(CurveTween(curve: Curves.easeIn)),
    );
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeIn));
    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap?.call();
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = widget.accentColor ?? theme.colorScheme.primary;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header - always visible
          InkWell(
            onTap: _handleTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (widget.leading != null) ...[
                        widget.leading!,
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (widget.subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                widget.subtitle!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (widget.trailing != null) ...[
                        const SizedBox(width: 8),
                        widget.trailing!,
                      ],
                      if (widget.showExpandIcon) ...[
                        const SizedBox(width: 8),
                        RotationTransition(
                          turns: _iconTurns,
                          child: Icon(
                            Icons.expand_more,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (widget.chips != null && widget.chips!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(spacing: 6, runSpacing: 4, children: widget.chips!),
                  ],
                ],
              ),
            ),
          ),

          // Expandable content
          ClipRect(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _heightFactor.value,
                  child: child,
                );
              },
              child: Column(
                children: [
                  Divider(height: 1, color: accentColor.withValues(alpha: 0.2)),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: widget.expandedContent,
                  ),
                  if (widget.actions != null && widget.actions!.isNotEmpty) ...[
                    Divider(height: 1, color: theme.colorScheme.outlineVariant),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: widget.actions!,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A simple chip for displaying key-value info
class InfoTag extends StatelessWidget {
  final String label;
  final String? value;
  final IconData? icon;
  final Color? color;

  const InfoTag({
    super.key,
    required this.label,
    this.value,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tagColor = color ?? theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tagColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: tagColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: tagColor),
            const SizedBox(width: 4),
          ],
          Text(
            value != null ? '$label: $value' : label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: tagColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// A row for displaying label-value pairs in expanded content
class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;
  final bool highlight;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.trailing,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              color: highlight ? theme.colorScheme.primary : null,
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

/// A progress indicator with label
class ProgressRow extends StatelessWidget {
  final String label;
  final double progress;
  final String? valueText;
  final Color? color;

  const ProgressRow({
    super.key,
    required this.label,
    required this.progress,
    this.valueText,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = color ?? theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              Text(
                valueText ?? '${(progress * 100).toStringAsFixed(0)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: progressColor.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
