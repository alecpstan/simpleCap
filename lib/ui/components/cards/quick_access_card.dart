import 'package:flutter/material.dart';

/// A styled card for quick access tools in the dashboard.
///
/// Displays an icon, label, and subtitle in a compact format.
/// Supports locked state with a lock icon overlay.
class QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isLocked;

  const QuickAccessCard({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    required this.color,
    required this.onTap,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = isLocked ? theme.colorScheme.outline : color;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLocked ? null : onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: effectiveColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: effectiveColor, size: 22),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isLocked ? theme.colorScheme.outline : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (isLocked)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.lock,
                    size: 14,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A grid layout for QuickAccessCards.
class QuickAccessGrid extends StatelessWidget {
  final List<QuickAccessCard> cards;
  final int columnsPerRow;

  const QuickAccessGrid({
    super.key,
    required this.cards,
    this.columnsPerRow = 3,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            (constraints.maxWidth - (columnsPerRow - 1) * 8) / columnsPerRow;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cards.map((card) {
            return SizedBox(width: cardWidth, child: card);
          }).toList(),
        );
      },
    );
  }
}

/// Data model for a tool card (used for reordering).
class ToolCardData {
  final String id;
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isLocked;

  const ToolCardData({
    required this.id,
    required this.icon,
    required this.label,
    this.subtitle,
    required this.color,
    required this.onTap,
    this.isLocked = false,
  });

  QuickAccessCard toCard() => QuickAccessCard(
    icon: icon,
    label: label,
    subtitle: subtitle,
    color: color,
    onTap: onTap,
    isLocked: isLocked,
  );
}

/// A reorderable grid layout for QuickAccessCards with drag and drop.
class ReorderableQuickAccessGrid extends StatefulWidget {
  final List<ToolCardData> tools;
  final List<String> order;
  final void Function(int oldIndex, int newIndex) onReorder;
  final int columnsPerRow;

  const ReorderableQuickAccessGrid({
    super.key,
    required this.tools,
    required this.order,
    required this.onReorder,
    this.columnsPerRow = 3,
  });

  @override
  State<ReorderableQuickAccessGrid> createState() =>
      _ReorderableQuickAccessGridState();
}

class _ReorderableQuickAccessGridState
    extends State<ReorderableQuickAccessGrid> {
  int? _draggedIndex;

  List<ToolCardData> get _orderedTools {
    final toolMap = {for (final t in widget.tools) t.id: t};
    return widget.order
        .where((id) => toolMap.containsKey(id))
        .map((id) => toolMap[id]!)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderedTools = _orderedTools;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            (constraints.maxWidth - (widget.columnsPerRow - 1) * 8) /
            widget.columnsPerRow;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(orderedTools.length, (index) {
            final tool = orderedTools[index];
            final isDragged = _draggedIndex == index;

            return LongPressDraggable<int>(
              data: index,
              delay: const Duration(milliseconds: 150),
              feedback: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: cardWidth,
                  child: Opacity(opacity: 0.9, child: tool.toCard()),
                ),
              ),
              childWhenDragging: SizedBox(
                width: cardWidth,
                child: Card(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  child: const SizedBox(height: 90),
                ),
              ),
              onDragStarted: () {
                setState(() => _draggedIndex = index);
              },
              onDragEnd: (_) {
                setState(() => _draggedIndex = null);
              },
              child: DragTarget<int>(
                onWillAcceptWithDetails: (details) => details.data != index,
                onAcceptWithDetails: (details) {
                  widget.onReorder(details.data, index);
                },
                builder: (context, candidateData, rejectedData) {
                  final isTarget = candidateData.isNotEmpty;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: cardWidth,
                    decoration: isTarget
                        ? BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          )
                        : null,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isDragged ? 0.0 : 1.0,
                      child: tool.toCard(),
                    ),
                  );
                },
              ),
            );
          }),
        );
      },
    );
  }
}
