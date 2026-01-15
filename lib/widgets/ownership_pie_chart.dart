import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/cap_table_provider.dart';
import '../utils/helpers.dart';

class OwnershipPieChart extends StatelessWidget {
  final bool showByShareClass;
  final bool showVestedOnly;

  const OwnershipPieChart({
    super.key,
    this.showByShareClass = false,
    this.showVestedOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CapTableProvider>(
      builder: (context, provider, child) {
        final Map<String, double> ownership;
        if (showByShareClass) {
          ownership = provider.getOwnershipByShareClass();
        } else if (showVestedOnly) {
          ownership = provider.getVestedOwnershipByInvestor();
        } else {
          ownership = provider.getOwnershipByInvestor();
        }

        if (ownership.isEmpty) {
          return const Center(child: Text('No shareholdings yet'));
        }

        final sections = <PieChartSectionData>[];
        final legendItems = <Widget>[];
        int colorIndex = 0;

        ownership.forEach((id, percentage) {
          String name;
          if (showByShareClass) {
            final shareClass = provider.getShareClassById(id);
            name = shareClass?.name ?? 'Unknown';
          } else {
            final investor = provider.getInvestorById(id);
            name = investor?.name ?? 'Unknown';
          }

          final color = AppColors.getChartColor(colorIndex);

          sections.add(
            PieChartSectionData(
              value: percentage,
              title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
              color: color,
              radius: 80,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );

          legendItems.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '$name (${percentage.toStringAsFixed(1)}%)',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          );

          colorIndex++;
        });

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 400;
            final chartRadius = isWide ? 80.0 : 60.0;
            final centerRadius = isWide ? 40.0 : 25.0;

            if (isWide) {
              return Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        sections: sections
                            .map(
                              (s) => PieChartSectionData(
                                value: s.value,
                                title: s.title,
                                color: s.color,
                                radius: chartRadius,
                                titleStyle: s.titleStyle,
                              ),
                            )
                            .toList(),
                        centerSpaceRadius: centerRadius,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: legendItems,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              // Narrow layout - chart on top, legend below
              return Column(
                children: [
                  SizedBox(
                    height: 180,
                    child: PieChart(
                      PieChartData(
                        sections: sections
                            .map(
                              (s) => PieChartSectionData(
                                value: s.value,
                                title: s.title,
                                color: s.color,
                                radius: chartRadius,
                                titleStyle: s.titleStyle,
                              ),
                            )
                            .toList(),
                        centerSpaceRadius: centerRadius,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 4,
                        children: legendItems,
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }
}
