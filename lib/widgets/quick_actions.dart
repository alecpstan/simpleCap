import 'package:flutter/material.dart';

/// A floating action button with multiple quick actions
class QuickActionsButton extends StatefulWidget {
  final List<QuickAction> actions;
  final IconData icon;
  final String? tooltip;

  const QuickActionsButton({
    super.key,
    required this.actions,
    this.icon = Icons.add,
    this.tooltip,
  });

  @override
  State<QuickActionsButton> createState() => _QuickActionsButtonState();
}

class _QuickActionsButtonState extends State<QuickActionsButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _close() {
    if (_isOpen) _toggle();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Mini action buttons
        ...widget.actions.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;
          final delay =
              (widget.actions.length - 1 - index) *
              (1.0 / widget.actions.length);

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final progress = Curves.easeOutBack.transform(
                ((_controller.value - delay) / (1.0 - delay)).clamp(0.0, 1.0),
              );
              return Opacity(
                opacity: progress,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - progress)),
                  child: Transform.scale(scale: progress, child: child),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Text(
                        action.label,
                        style: theme.textTheme.labelMedium,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton.small(
                    heroTag: 'quick_action_$index',
                    onPressed: () {
                      _close();
                      action.onPressed();
                    },
                    backgroundColor:
                        action.color ?? theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                    child: Icon(action.icon),
                  ),
                ],
              ),
            ),
          );
        }),

        // Main FAB
        FloatingActionButton(
          onPressed: _toggle,
          tooltip: widget.tooltip,
          child: AnimatedRotation(
            turns: _isOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(widget.icon),
          ),
        ),
      ],
    );
  }
}

/// A single quick action
class QuickAction {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  const QuickAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color,
  });
}

/// Bottom sheet for actions on mobile
Future<T?> showActionSheet<T>({
  required BuildContext context,
  required String title,
  String? subtitle,
  required List<ActionSheetItem<T>> items,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      final theme = Theme.of(context);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),

              // Items
              ...items.map((item) => _ActionSheetTile(item: item)),
            ],
          ),
        ),
      );
    },
  );
}

class _ActionSheetTile<T> extends StatelessWidget {
  final ActionSheetItem<T> item;

  const _ActionSheetTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = item.isDestructive
        ? theme.colorScheme.error
        : item.color ?? theme.colorScheme.onSurface;

    return ListTile(
      leading: Icon(item.icon, color: color),
      title: Text(
        item.label,
        style: TextStyle(
          color: color,
          fontWeight: item.isDestructive ? FontWeight.w600 : null,
        ),
      ),
      subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
      onTap: () => Navigator.of(context).pop(item.value),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

/// An item in an action sheet
class ActionSheetItem<T> {
  final String label;
  final String? subtitle;
  final IconData icon;
  final T value;
  final bool isDestructive;
  final Color? color;

  const ActionSheetItem({
    required this.label,
    this.subtitle,
    required this.icon,
    required this.value,
    this.isDestructive = false,
    this.color,
  });
}
