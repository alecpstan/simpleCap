import 'package:flutter/material.dart';

/// A column definition for the resizable table
class ResizableColumn {
  final String key;
  final String label;
  final double minWidth;
  final double defaultWidth;
  final bool numeric;

  const ResizableColumn({
    required this.key,
    required this.label,
    this.minWidth = 60,
    this.defaultWidth = 100,
    this.numeric = false,
  });
}

/// A row of data for the resizable table
class ResizableRow {
  final List<Widget> cells;

  const ResizableRow({required this.cells});
}

/// A table widget with draggable column borders for resizing
class ResizableTable extends StatefulWidget {
  final List<ResizableColumn> columns;
  final List<ResizableRow> rows;
  final Map<String, double> columnWidths;
  final void Function(String columnKey, double newWidth)? onColumnResized;
  final EdgeInsets padding;

  const ResizableTable({
    super.key,
    required this.columns,
    required this.rows,
    this.columnWidths = const {},
    this.onColumnResized,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<ResizableTable> createState() => _ResizableTableState();
}

class _ResizableTableState extends State<ResizableTable> {
  late Map<String, double> _columnWidths;
  int? _resizingColumnIndex;

  @override
  void initState() {
    super.initState();
    _initColumnWidths();
  }

  @override
  void didUpdateWidget(ResizableTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.columnWidths != widget.columnWidths) {
      _initColumnWidths();
    }
  }

  void _initColumnWidths() {
    _columnWidths = {};
    for (final column in widget.columns) {
      _columnWidths[column.key] =
          widget.columnWidths[column.key] ?? column.defaultWidth;
    }
  }

  double _getColumnWidth(String key) {
    return _columnWidths[key] ?? 100;
  }

  void _onDragUpdate(int columnIndex, double delta) {
    final column = widget.columns[columnIndex];
    final currentWidth = _getColumnWidth(column.key);
    final newWidth = (currentWidth + delta).clamp(column.minWidth, 500.0);

    setState(() {
      _columnWidths[column.key] = newWidth;
    });
  }

  void _onDragEnd(int columnIndex) {
    final column = widget.columns[columnIndex];
    final width = _getColumnWidth(column.key);
    widget.onColumnResized?.call(column.key, width);
    setState(() {
      _resizingColumnIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.bold,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate total width needed
        double totalWidth = 0;
        for (final column in widget.columns) {
          totalWidth += _getColumnWidth(column.key);
        }

        // If table fits, expand columns proportionally to fill width
        final availableWidth = constraints.maxWidth - widget.padding.horizontal;
        final shouldExpand =
            totalWidth < availableWidth && availableWidth.isFinite;
        final scaleFactor = shouldExpand ? availableWidth / totalWidth : 1.0;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: widget.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: List.generate(widget.columns.length, (index) {
                    final column = widget.columns[index];
                    final width = _getColumnWidth(column.key) * scaleFactor;
                    final isLast = index == widget.columns.length - 1;

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width:
                              width -
                              (isLast ? 0 : 8), // Account for resize handle
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                          alignment: column.numeric
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Text(column.label, style: headerStyle),
                        ),
                        if (!isLast) _buildResizeHandle(index),
                      ],
                    );
                  }),
                ),
              ),
              // Data rows
              ...widget.rows.map((row) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ),
                  child: Row(
                    children: List.generate(widget.columns.length, (index) {
                      final column = widget.columns[index];
                      final width = _getColumnWidth(column.key) * scaleFactor;

                      return Container(
                        width: width,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                        alignment: column.numeric
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: index < row.cells.length
                            ? row.cells[index]
                            : const SizedBox(),
                      );
                    }),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResizeHandle(int columnIndex) {
    final isResizing = _resizingColumnIndex == columnIndex;

    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) {
          setState(() {
            _resizingColumnIndex = columnIndex;
          });
        },
        onHorizontalDragUpdate: (details) {
          _onDragUpdate(columnIndex, details.delta.dx);
        },
        onHorizontalDragEnd: (_) {
          _onDragEnd(columnIndex);
        },
        child: Container(
          width: 8,
          height: 40,
          alignment: Alignment.center,
          child: Container(
            width: 2,
            height: 20,
            decoration: BoxDecoration(
              color: isResizing
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ),
    );
  }
}
