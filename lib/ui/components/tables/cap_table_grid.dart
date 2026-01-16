import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/formatters.dart';

/// Data model for a cap table row.
class CapTableRow {
  final String id;
  final String name;
  final String? subtitle;

  /// Confirmed (closed round) shares by column
  final Map<String, int> valuesByColumn;

  /// Pending (draft round) shares by column
  final Map<String, int> pendingByColumn;
  final int total;
  final int pendingTotal;
  final double percentage;

  const CapTableRow({
    required this.id,
    required this.name,
    this.subtitle,
    required this.valuesByColumn,
    this.pendingByColumn = const {},
    required this.total,
    this.pendingTotal = 0,
    required this.percentage,
  });

  /// Whether this row has any pending shares.
  bool get hasPending => pendingTotal > 0;
}

/// Data model for a cap table column.
class CapTableColumn {
  final String id;
  final String name;
  final String? subtitle;

  const CapTableColumn({required this.id, required this.name, this.subtitle});
}

/// A reusable spreadsheet-style cap table with resizable columns.
/// Features a frozen first column and synchronized horizontal scrolling.
class CapTableGrid extends StatefulWidget {
  final String tableId;
  final List<CapTableColumn> columns;
  final List<CapTableRow> rows;
  final Map<String, int> columnTotals;
  final Map<String, int> pendingColumnTotals;
  final int grandTotal;
  final int pendingGrandTotal;
  final String nameColumnHeader;
  final double minColumnWidth;
  final double maxColumnWidth;

  const CapTableGrid({
    super.key,
    required this.tableId,
    required this.columns,
    required this.rows,
    required this.columnTotals,
    this.pendingColumnTotals = const {},
    required this.grandTotal,
    this.pendingGrandTotal = 0,
    this.nameColumnHeader = 'Stakeholder',
    this.minColumnWidth = 60,
    this.maxColumnWidth = 300,
  });

  @override
  State<CapTableGrid> createState() => _CapTableGridState();
}

class _CapTableGridState extends State<CapTableGrid> {
  late Map<String, double> _columnWidths;
  double _nameColumnWidth = 180;
  double _totalColumnWidth = 110;
  double _percentColumnWidth = 80;
  bool _isLoaded = false;
  String? _resizingColumn;
  double _resizeStartX = 0;
  double _resizeStartWidth = 0;

  // Linked scroll controllers for synchronized horizontal scrolling
  final List<ScrollController> _scrollControllers = [];
  double _scrollOffset = 0;
  bool _isSyncing = false;

  static const String _prefsKeyPrefix = 'cap_table_widths_';

  @override
  void initState() {
    super.initState();
    _initializeWidths();
    _loadPersistedWidths();
  }

  @override
  void dispose() {
    for (final controller in _scrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Creates a new scroll controller that stays in sync with all others
  ScrollController _createLinkedScrollController() {
    final controller = ScrollController(initialScrollOffset: _scrollOffset);
    controller.addListener(() => _onScroll(controller));
    _scrollControllers.add(controller);
    return controller;
  }

  void _onScroll(ScrollController source) {
    if (_isSyncing) return;
    _isSyncing = true;
    _scrollOffset = source.offset;
    for (final controller in _scrollControllers) {
      if (controller != source && controller.hasClients) {
        controller.jumpTo(_scrollOffset);
      }
    }
    _isSyncing = false;
  }

  void _initializeWidths() {
    _columnWidths = {for (final col in widget.columns) col.id: 100};
  }

  Future<void> _loadPersistedWidths() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_prefsKeyPrefix${widget.tableId}';
      final json = prefs.getString(key);

      if (json != null) {
        final data = jsonDecode(json) as Map<String, dynamic>;

        if (data['nameColumn'] != null) {
          _nameColumnWidth = (data['nameColumn'] as num).toDouble();
        }
        if (data['totalColumn'] != null) {
          _totalColumnWidth = (data['totalColumn'] as num).toDouble();
        }
        if (data['percentColumn'] != null) {
          _percentColumnWidth = (data['percentColumn'] as num).toDouble();
        }
        if (data['columns'] != null) {
          final cols = data['columns'] as Map<String, dynamic>;
          for (final entry in cols.entries) {
            if (_columnWidths.containsKey(entry.key)) {
              _columnWidths[entry.key] = (entry.value as num).toDouble();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading column widths: $e');
    }

    if (mounted) {
      setState(() => _isLoaded = true);
    }
  }

  Future<void> _savePersistedWidths() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_prefsKeyPrefix${widget.tableId}';
      final data = {
        'nameColumn': _nameColumnWidth,
        'totalColumn': _totalColumnWidth,
        'percentColumn': _percentColumnWidth,
        'columns': _columnWidths,
      };
      await prefs.setString(key, jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving column widths: $e');
    }
  }

  void _startResize(String columnId, double startX, double currentWidth) {
    setState(() {
      _resizingColumn = columnId;
      _resizeStartX = startX;
      _resizeStartWidth = currentWidth;
    });
  }

  void _updateResize(double currentX) {
    if (_resizingColumn == null) return;

    final delta = currentX - _resizeStartX;
    final newWidth = (_resizeStartWidth + delta).clamp(
      widget.minColumnWidth,
      widget.maxColumnWidth,
    );

    setState(() {
      if (_resizingColumn == '_name') {
        _nameColumnWidth = newWidth;
      } else if (_resizingColumn == '_total') {
        _totalColumnWidth = newWidth;
      } else if (_resizingColumn == '_percent') {
        _percentColumnWidth = newWidth;
      } else {
        _columnWidths[_resizingColumn!] = newWidth;
      }
    });
  }

  void _endResize() {
    if (_resizingColumn != null) {
      _savePersistedWidths();
      setState(() => _resizingColumn = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outlineVariant;

    return MouseRegion(
      onExit: (_) => _endResize(),
      child: GestureDetector(
        onPanUpdate: (details) => _updateResize(details.globalPosition.dx),
        onPanEnd: (_) => _endResize(),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header row
                _buildHeaderRow(context, borderColor),
                // Data rows
                ...widget.rows.map(
                  (row) => _buildDataRow(context, row, borderColor),
                ),
                // Totals row
                _buildTotalsRow(context, borderColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the header row with frozen name column and scrollable data columns
  Widget _buildHeaderRow(BuildContext context, Color borderColor) {
    final theme = Theme.of(context);
    final headerBg = theme.colorScheme.surfaceContainerHighest;
    final headerStyle = theme.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Container(
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Frozen name column header
            Container(
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: borderColor, width: 2)),
              ),
              child: _buildResizableCell(
                context,
                columnId: '_name',
                width: _nameColumnWidth,
                borderColor: borderColor,
                child: Text(widget.nameColumnHeader, style: headerStyle),
                alignment: Alignment.centerLeft,
              ),
            ),
            // Scrollable columns
            Expanded(
              child: SingleChildScrollView(
                controller: _createLinkedScrollController(),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...widget.columns.map(
                      (col) => _buildResizableCell(
                        context,
                        columnId: col.id,
                        width: _columnWidths[col.id] ?? 100,
                        borderColor: borderColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              col.name,
                              style: headerStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (col.subtitle != null)
                              Text(
                                col.subtitle!,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                        alignment: Alignment.centerRight,
                      ),
                    ),
                    _buildResizableCell(
                      context,
                      columnId: '_total',
                      width: _totalColumnWidth,
                      borderColor: borderColor,
                      child: Text('Total', style: headerStyle),
                      alignment: Alignment.centerRight,
                      highlight: true,
                    ),
                    _buildResizableCell(
                      context,
                      columnId: '_percent',
                      width: _percentColumnWidth,
                      borderColor: borderColor,
                      child: Text('%', style: headerStyle),
                      alignment: Alignment.centerRight,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a data row with frozen name column and scrollable data columns
  Widget _buildDataRow(
    BuildContext context,
    CapTableRow row,
    Color borderColor,
  ) {
    final theme = Theme.of(context);
    final dataStyle = theme.textTheme.bodySmall?.copyWith(
      fontFamily: 'monospace',
      fontFamilyFallback: const ['Roboto Mono', 'Courier'],
    );

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Frozen name cell
            Container(
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: borderColor, width: 2)),
              ),
              child: Container(
                width: _nameColumnWidth,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      row.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (row.subtitle != null)
                      Text(
                        row.subtitle!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Scrollable data cells
            Expanded(
              child: SingleChildScrollView(
                controller: _createLinkedScrollController(),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...widget.columns.map((col) {
                      final value = row.valuesByColumn[col.id] ?? 0;
                      final pending = row.pendingByColumn[col.id] ?? 0;
                      return _buildCell(
                        context,
                        width: _columnWidths[col.id] ?? 100,
                        borderColor: borderColor,
                        child: _buildValueWithPending(
                          context,
                          value: value,
                          pending: pending,
                          style: dataStyle,
                        ),
                        alignment: Alignment.centerRight,
                      );
                    }),
                    _buildCell(
                      context,
                      width: _totalColumnWidth,
                      borderColor: borderColor,
                      child: _buildValueWithPending(
                        context,
                        value: row.total,
                        pending: row.pendingTotal,
                        style: dataStyle?.copyWith(fontWeight: FontWeight.w600),
                        showPendingLabel: true,
                      ),
                      alignment: Alignment.centerRight,
                      highlight: true,
                    ),
                    _buildCell(
                      context,
                      width: _percentColumnWidth,
                      borderColor: borderColor,
                      child: Text(
                        Formatters.percent(row.percentage),
                        style: dataStyle?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      alignment: Alignment.centerRight,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the totals row with frozen label and scrollable totals
  Widget _buildTotalsRow(BuildContext context, Color borderColor) {
    final theme = Theme.of(context);
    final totalsBg = theme.colorScheme.primaryContainer.withValues(alpha: 0.3);
    final totalsStyle = theme.textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.bold,
      fontFamily: 'monospace',
      fontFamilyFallback: const ['Roboto Mono', 'Courier'],
    );

    return Container(
      decoration: BoxDecoration(color: totalsBg),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Frozen TOTAL label
            Container(
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: borderColor, width: 2)),
              ),
              child: Container(
                width: _nameColumnWidth,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                alignment: Alignment.centerLeft,
                child: Text('TOTAL', style: totalsStyle),
              ),
            ),
            // Scrollable totals
            Expanded(
              child: SingleChildScrollView(
                controller: _createLinkedScrollController(),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...widget.columns.map((col) {
                      final total = widget.columnTotals[col.id] ?? 0;
                      final pending = widget.pendingColumnTotals[col.id] ?? 0;
                      return _buildCell(
                        context,
                        width: _columnWidths[col.id] ?? 100,
                        borderColor: borderColor,
                        child: _buildValueWithPending(
                          context,
                          value: total,
                          pending: pending,
                          style: totalsStyle,
                        ),
                        alignment: Alignment.centerRight,
                      );
                    }),
                    _buildCell(
                      context,
                      width: _totalColumnWidth,
                      borderColor: borderColor,
                      child: _buildValueWithPending(
                        context,
                        value: widget.grandTotal,
                        pending: widget.pendingGrandTotal,
                        style: totalsStyle?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                        showPendingLabel: true,
                      ),
                      alignment: Alignment.centerRight,
                      highlight: true,
                    ),
                    _buildCell(
                      context,
                      width: _percentColumnWidth,
                      borderColor: borderColor,
                      child: Text(
                        '100.00%',
                        style: totalsStyle?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      alignment: Alignment.centerRight,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResizableCell(
    BuildContext context, {
    required String columnId,
    required double width,
    required Color borderColor,
    required Widget child,
    Alignment alignment = Alignment.center,
    bool highlight = false,
    bool isLast = false,
    bool showBottomBorder = false,
    Color? backgroundColor,
  }) {
    final theme = Theme.of(context);
    final isResizing = _resizingColumn == columnId;

    return Stack(
      children: [
        Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color:
                backgroundColor ??
                (highlight
                    ? theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      )
                    : null),
            border: Border(
              right: isLast
                  ? BorderSide.none
                  : BorderSide(color: borderColor, width: 1),
              bottom: showBottomBorder
                  ? BorderSide(color: borderColor, width: 1)
                  : BorderSide.none,
            ),
          ),
          alignment: alignment,
          child: child,
        ),
        // Resize handle
        if (!isLast)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: GestureDetector(
                onPanStart: (details) =>
                    _startResize(columnId, details.globalPosition.dx, width),
                child: Container(
                  width: 8,
                  color: isResizing
                      ? theme.colorScheme.primary.withValues(alpha: 0.3)
                      : Colors.transparent,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Builds a value display that shows pending shares distinctly.
  Widget _buildValueWithPending(
    BuildContext context, {
    required int value,
    required int pending,
    TextStyle? style,
    bool showPendingLabel = false,
  }) {
    final theme = Theme.of(context);
    final total = value + pending;

    if (total == 0) {
      return Text(
        '-',
        style: style?.copyWith(color: theme.colorScheme.outline),
      );
    }

    // If no pending, just show the value
    if (pending == 0) {
      return Text(Formatters.number(value), style: style);
    }

    // If all pending (value is 0), show in amber/warning color
    if (value == 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            Formatters.number(pending),
            style: style?.copyWith(
              color: Colors.amber.shade700,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (showPendingLabel)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Tooltip(
                message: 'Pending from draft round',
                child: Icon(
                  Icons.pending_outlined,
                  size: 14,
                  color: Colors.amber.shade700,
                ),
              ),
            ),
        ],
      );
    }

    // Mix of confirmed and pending - show total with indicator
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(Formatters.number(total), style: style),
        if (showPendingLabel)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Tooltip(
              message: '${Formatters.number(pending)} pending from draft round',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '+${Formatters.compactNumber(pending)}',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade800,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCell(
    BuildContext context, {
    required double width,
    required Color borderColor,
    required Widget child,
    Alignment alignment = Alignment.center,
    bool highlight = false,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: highlight
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : null,
        border: isLast
            ? null
            : Border(right: BorderSide(color: borderColor, width: 1)),
      ),
      alignment: alignment,
      child: child,
    );
  }
}
