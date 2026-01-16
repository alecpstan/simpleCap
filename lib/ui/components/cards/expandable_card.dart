import 'package:flutter/material.dart';

/// An expandable card showing a summary that reveals details when tapped.
///
/// Primary UI pattern for list items with variable detail.
class ExpandableCard extends StatefulWidget {
  /// Leading widget (typically an avatar).
  final Widget? leading;

  /// Title text.
  final String title;

  /// Badge shown inline with title (e.g., stakeholder type).
  final Widget? titleBadge;

  /// Subtitle text.
  final String? subtitle;

  /// Trailing widget when collapsed.
  final Widget? trailing;

  /// Badge positioned in the top-right corner above the expand icon.
  final Widget? cornerBadge;

  /// Summary chips below the title.
  final List<Widget>? chips;

  /// Status badges (always shown on separate row).
  final List<Widget>? badges;

  /// Content shown when expanded.
  final Widget expandedContent;

  /// Whether to start expanded.
  final bool initiallyExpanded;

  /// Actions at the bottom when expanded.
  final List<Widget>? actions;

  /// Accent color for the card.
  final Color? accentColor;

  /// Whether to show the expand indicator.
  final bool showExpandIcon;

  /// External expansion controller.
  final ValueNotifier<bool>? expansionController;

  const ExpandableCard({
    super.key,
    this.leading,
    required this.title,
    this.titleBadge,
    this.subtitle,
    this.trailing,
    this.cornerBadge,
    this.chips,
    this.badges,
    required this.expandedContent,
    this.initiallyExpanded = false,
    this.actions,
    this.accentColor,
    this.showExpandIcon = true,
    this.expansionController,
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

    widget.expansionController?.addListener(_onExternalChange);
  }

  @override
  void dispose() {
    widget.expansionController?.removeListener(_onExternalChange);
    _controller.dispose();
    super.dispose();
  }

  void _onExternalChange() {
    final shouldExpand = widget.expansionController?.value ?? false;
    if (shouldExpand != _isExpanded) {
      _handleTap();
    }
  }

  void _handleTap() {
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header - always visible
          InkWell(
            onTap: _handleTap,
            child: Stack(
              children: [
                Padding(
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
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        widget.title,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (widget.titleBadge != null) ...[
                                      const SizedBox(width: 8),
                                      widget.titleBadge!,
                                    ],
                                  ],
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
                          if (widget.trailing != null) widget.trailing!,
                          if (widget.showExpandIcon) ...[
                            const SizedBox(width: 8),
                            RotationTransition(
                              turns: _iconTurns,
                              child: const Icon(Icons.expand_more),
                            ),
                          ],
                        ],
                      ),
                      if (widget.chips != null && widget.chips!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(spacing: 8, runSpacing: 4, children: widget.chips!),
                      ],
                      if (widget.badges != null && widget.badges!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(spacing: 8, runSpacing: 4, children: widget.badges!),
                      ],
                    ],
                  ),
                ),
                // Corner badge positioned in top-right
                if (widget.cornerBadge != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: widget.cornerBadge!,
                  ),
              ],
            ),
          ),

          // Expanded content
          ClipRect(
            child: AnimatedBuilder(
              animation: _heightFactor,
              builder: (context, child) {
                return Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _heightFactor.value,
                  child: child,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: widget.expandedContent,
                  ),
                  if (widget.actions != null && widget.actions!.isNotEmpty) ...[
                    const Divider(height: 1),
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
