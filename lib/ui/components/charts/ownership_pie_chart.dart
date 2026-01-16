import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Data for a single pie chart section.
class OwnershipSlice {
  final String id;
  final String name;
  final int shares;
  final Color color;

  const OwnershipSlice({
    required this.id,
    required this.name,
    required this.shares,
    required this.color,
  });

  double getPercentage(int totalShares) {
    if (totalShares == 0) return 0;
    return (shares / totalShares) * 100;
  }
}

/// A pie chart showing ownership distribution.
class OwnershipPieChart extends StatefulWidget {
  final List<OwnershipSlice> slices;
  final double size;
  final bool showLegend;
  final bool interactive;

  const OwnershipPieChart({
    super.key,
    required this.slices,
    this.size = 200,
    this.showLegend = true,
    this.interactive = true,
  });

  @override
  State<OwnershipPieChart> createState() => _OwnershipPieChartState();
}

class _OwnershipPieChartState extends State<OwnershipPieChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.slices.isEmpty) {
      return SizedBox(
        height: widget.size,
        child: Center(
          child: Text(
            'No ownership data',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      );
    }

    final totalShares = widget.slices.fold(0, (sum, s) => sum + s.shares);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.size,
          child: PieChart(
            PieChartData(
              pieTouchData: widget.interactive
                  ? PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              response == null ||
                              response.touchedSection == null) {
                            _touchedIndex = null;
                            return;
                          }
                          _touchedIndex =
                              response.touchedSection!.touchedSectionIndex;
                        });
                      },
                    )
                  : null,
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: widget.size * 0.25,
              sections: _buildSections(totalShares),
            ),
          ),
        ),
        if (widget.showLegend) ...[
          const SizedBox(height: 16),
          _buildLegend(totalShares),
        ],
      ],
    );
  }

  List<PieChartSectionData> _buildSections(int totalShares) {
    return widget.slices.asMap().entries.map((entry) {
      final index = entry.key;
      final slice = entry.value;
      final isTouched = index == _touchedIndex;
      final percentage = slice.getPercentage(totalShares);

      return PieChartSectionData(
        color: slice.color,
        value: slice.shares.toDouble(),
        title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: isTouched ? widget.size * 0.35 : widget.size * 0.3,
        titleStyle: TextStyle(
          fontSize: isTouched ? 14 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
        ),
        badgePositionPercentageOffset: 1.1,
      );
    }).toList();
  }

  Widget _buildLegend(int totalShares) {
    // Sort by shares descending
    final sortedSlices = List<OwnershipSlice>.from(widget.slices)
      ..sort((a, b) => b.shares.compareTo(a.shares));

    // Show top entries, group rest as "Others"
    final maxEntries = 6;
    final displaySlices = sortedSlices.take(maxEntries).toList();
    final othersCount = sortedSlices.length - maxEntries;

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        ...displaySlices.map((slice) {
          final percentage = slice.getPercentage(totalShares);
          return _LegendItem(
            color: slice.color,
            label: slice.name,
            value: '${percentage.toStringAsFixed(1)}%',
          );
        }),
        if (othersCount > 0)
          _LegendItem(
            color: Colors.grey,
            label: '+$othersCount others',
            value: '',
          ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall,
          overflow: TextOverflow.ellipsis,
        ),
        if (value.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Default colors for pie chart slices.
class ChartColors {
  static const List<Color> ownership = [
    Color(0xFF3F51B5), // Indigo
    Color(0xFF2196F3), // Blue
    Color(0xFF009688), // Teal
    Color(0xFF4CAF50), // Green
    Color(0xFFFFC107), // Amber
    Color(0xFFFF9800), // Orange
    Color(0xFFF44336), // Red
    Color(0xFF9C27B0), // Purple
    Color(0xFFE91E63), // Pink
    Color(0xFF00BCD4), // Cyan
  ];

  static Color getColor(int index) {
    return ownership[index % ownership.length];
  }
}
