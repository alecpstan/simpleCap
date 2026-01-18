import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/providers/collapsible_notice_provider.dart';

/// The type of collapsible notice, determining its color scheme.
enum NoticeType { info, warning, action, success }

/// A collapsible notice box with Hide/Show toggle.
///
/// Used for actionable notices like exercisable options, pending MFN upgrades,
/// or other user-actionable items. Can be collapsed to a single line.
class CollapsibleNotice extends ConsumerStatefulWidget {
  /// The type of notice (affects colors and icon).
  final NoticeType type;

  /// The title shown in both collapsed and expanded states.
  final String title;

  /// The detailed message shown only when expanded.
  final String message;

  /// Optional count to show in the title (e.g., "3 options ready").
  final int? count;

  /// Optional action widget (e.g., a button) shown when expanded.
  final Widget? action;

  /// Optional callback when the notice is dismissed entirely.
  final VoidCallback? onDismiss;

  /// Initial collapsed state. Defaults to false (expanded).
  final bool initiallyCollapsed;

  /// Key for persisting collapsed state across rebuilds.
  final String? persistKey;

  const CollapsibleNotice({
    super.key,
    this.type = NoticeType.action,
    required this.title,
    required this.message,
    this.count,
    this.action,
    this.onDismiss,
    this.initiallyCollapsed = false,
    this.persistKey,
  });

  /// Creates an action notice (blue/primary color, for actionable items).
  factory CollapsibleNotice.action({
    Key? key,
    required String title,
    required String message,
    int? count,
    Widget? action,
    VoidCallback? onDismiss,
    bool initiallyCollapsed = false,
    String? persistKey,
  }) {
    return CollapsibleNotice(
      key: key,
      type: NoticeType.action,
      title: title,
      message: message,
      count: count,
      action: action,
      onDismiss: onDismiss,
      initiallyCollapsed: initiallyCollapsed,
      persistKey: persistKey,
    );
  }

  /// Creates a warning notice (orange color).
  factory CollapsibleNotice.warning({
    Key? key,
    required String title,
    required String message,
    int? count,
    Widget? action,
    VoidCallback? onDismiss,
    bool initiallyCollapsed = false,
    String? persistKey,
  }) {
    return CollapsibleNotice(
      key: key,
      type: NoticeType.warning,
      title: title,
      message: message,
      count: count,
      action: action,
      onDismiss: onDismiss,
      initiallyCollapsed: initiallyCollapsed,
      persistKey: persistKey,
    );
  }

  /// Creates an info notice (subtle, informational).
  factory CollapsibleNotice.info({
    Key? key,
    required String title,
    required String message,
    int? count,
    Widget? action,
    VoidCallback? onDismiss,
    bool initiallyCollapsed = false,
    String? persistKey,
  }) {
    return CollapsibleNotice(
      key: key,
      type: NoticeType.info,
      title: title,
      message: message,
      count: count,
      action: action,
      onDismiss: onDismiss,
      initiallyCollapsed: initiallyCollapsed,
      persistKey: persistKey,
    );
  }

  /// Creates a success notice (green color).
  factory CollapsibleNotice.success({
    Key? key,
    required String title,
    required String message,
    int? count,
    Widget? action,
    VoidCallback? onDismiss,
    bool initiallyCollapsed = false,
    String? persistKey,
  }) {
    return CollapsibleNotice(
      key: key,
      type: NoticeType.success,
      title: title,
      message: message,
      count: count,
      action: action,
      onDismiss: onDismiss,
      initiallyCollapsed: initiallyCollapsed,
      persistKey: persistKey,
    );
  }

  @override
  ConsumerState<CollapsibleNotice> createState() => _CollapsibleNoticeState();
}

class _CollapsibleNoticeState extends ConsumerState<CollapsibleNotice>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool? _localCollapsed; // Local override when user toggles

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    // Set initial animation value based on widget's initial state
    if (!widget.initiallyCollapsed) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _getIsCollapsed() {
    // If user has toggled locally this session, use that
    if (_localCollapsed != null) {
      return _localCollapsed!;
    }

    // Otherwise check persisted state
    if (widget.persistKey != null) {
      final persistedState = ref.watch(collapsedNoticeStateProvider);
      return persistedState.maybeWhen(
        data: (states) => states[widget.persistKey] ?? widget.initiallyCollapsed,
        orElse: () => widget.initiallyCollapsed,
      );
    }

    return widget.initiallyCollapsed;
  }

  void _toggleCollapse() {
    final newCollapsed = !_getIsCollapsed();
    
    setState(() {
      _localCollapsed = newCollapsed;
      if (newCollapsed) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    });

    // Persist the state if we have a persist key
    if (widget.persistKey != null) {
      ref
          .read(collapsedNoticeStateProvider.notifier)
          .setCollapsed(widget.persistKey!, newCollapsed);
    }
  }

  Color _getColor(ThemeData theme) {
    switch (widget.type) {
      case NoticeType.info:
        return theme.colorScheme.outline;
      case NoticeType.warning:
        return Colors.orange;
      case NoticeType.action:
        return theme.colorScheme.primary;
      case NoticeType.success:
        return Colors.green;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case NoticeType.info:
        return Icons.info_outline;
      case NoticeType.warning:
        return Icons.warning_amber_outlined;
      case NoticeType.action:
        return Icons.notifications_active_outlined;
      case NoticeType.success:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCollapsed = _getIsCollapsed();
    
    // Sync animation controller with collapsed state (for initial load from persistence)
    if (_localCollapsed == null) {
      _controller.value = isCollapsed ? 0.0 : 1.0;
    }

    final theme = Theme.of(context);
    final color = _getColor(theme);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row (always visible)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
            child: Row(
              children: [
                Icon(_getIcon(), color: color, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _buildTitle(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Hide/Show button
                TextButton(
                  onPressed: _toggleCollapse,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: color,
                  ),
                  child: Text(
                    isCollapsed ? 'Show' : 'Hide',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (widget.onDismiss != null) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.close, size: 18, color: color),
                    onPressed: widget.onDismiss,
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ],
            ),
          ),

          // Expandable content
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(
                  height: 1,
                  thickness: 1,
                  color: color.withValues(alpha: 0.15),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.message,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                      if (widget.action != null) ...[
                        const SizedBox(height: 12),
                        widget.action!,
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildTitle() {
    if (widget.count != null && widget.count! > 0) {
      return '${widget.title} (${widget.count})';
    }
    return widget.title;
  }
}
