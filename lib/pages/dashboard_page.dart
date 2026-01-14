import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cap_table_provider.dart';
import '../widgets/ownership_pie_chart.dart';
import '../widgets/section_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/help_icon.dart';
import '../utils/helpers.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _showByShareClass = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<CapTableProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          slivers: [
            // Company header with key metrics
            SliverToBoxAdapter(child: _buildHeader(context, provider)),

            // 2x2 Stats grid
            SliverToBoxAdapter(child: _buildStatsGrid(context, provider)),

            // Ownership chart section
            SliverToBoxAdapter(child: _buildOwnershipChart(context, provider)),

            // Dividend chart section
            SliverToBoxAdapter(child: _buildDividendChart(context, provider)),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, CapTableProvider provider) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            provider.companyName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Valuation: ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              Text(
                Formatters.compactCurrency(provider.latestValuation),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 4),
              const HelpIcon(helpKey: 'general.valuation', size: 14),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, CapTableProvider provider) {
    final showFD = provider.showFullyDiluted;
    final shareCount = showFD
        ? provider.fullyDilutedShares
        : provider.totalCurrentShares;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: StatsGrid(
        stats: [
          StatCard(
            title: 'Total Raised',
            value: Formatters.compactCurrency(provider.totalInvested),
            icon: Icons.attach_money,
            color: Colors.blue,
            helpKey: 'general.raised',
          ),
          StatCard(
            title: showFD ? 'FD Shares' : 'Shares Outstanding',
            value: Formatters.compactNumber(shareCount),
            icon: Icons.pie_chart,
            color: Colors.purple,
            subtitle: showFD ? 'Fully Diluted' : 'Current',
            helpKey: 'general.shares',
          ),
          StatCard(
            title: 'Share Price',
            value: Formatters.currency(provider.latestSharePrice),
            icon: Icons.monetization_on,
            color: Colors.orange,
            helpKey: 'general.sharePrice',
          ),
          if (provider.outstandingConvertibles.isNotEmpty)
            StatCard(
              title: 'Convertibles',
              value: Formatters.compactCurrency(
                provider.totalConvertiblePrincipal,
              ),
              icon: Icons.receipt_long,
              color: Colors.teal,
              subtitle:
                  '${provider.outstandingConvertibles.length} outstanding',
            )
          else
            StatCard(
              title: 'Rounds',
              value: '${provider.rounds.length}',
              icon: Icons.layers,
              color: Colors.green,
              subtitle: '${provider.activeInvestors.length} investors',
            ),
        ],
      ),
    );
  }

  Widget _buildOwnershipChart(BuildContext context, CapTableProvider provider) {
    if (provider.activeInvestors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SectionCard(
        title: 'Ownership',
        trailing: SegmentedButton<bool>(
          segments: const [
            ButtonSegment(
              value: false,
              label: Text('Investor'),
              icon: Icon(Icons.person, size: 16),
            ),
            ButtonSegment(
              value: true,
              label: Text('Class'),
              icon: Icon(Icons.category, size: 16),
            ),
          ],
          selected: {_showByShareClass},
          onSelectionChanged: (value) {
            setState(() {
              _showByShareClass = value.first;
            });
          },
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        child: SizedBox(
          height: 280,
          child: OwnershipPieChart(showByShareClass: _showByShareClass),
        ),
      ),
    );
  }

  Widget _buildDividendChart(BuildContext context, CapTableProvider provider) {
    if (provider.activeInvestors.isEmpty) {
      return const SizedBox.shrink();
    }

    // Check if any share classes have dividend rates
    final hasDividendRates = provider.shareClasses.any(
      (sc) => sc.dividendRate > 0,
    );

    // Get total accrued dividends
    final totalDividends = provider.totalAccruedDividends;

    // Get dividend data per investor
    final dividendData = <String, double>{};
    for (final investor in provider.activeInvestors) {
      final dividends = provider.getAccruedDividendsByInvestor(investor.id);
      if (dividends > 0) {
        // Calculate percentage of total dividends
        final pct = totalDividends > 0
            ? (dividends / totalDividends) * 100
            : 0.0;
        dividendData[investor.name] = pct;
      }
    }

    // Sort by dividend share descending
    final sortedEntries = dividendData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final theme = Theme.of(context);
    final colors = [
      Colors.indigo,
      Colors.blue,
      Colors.teal,
      Colors.green,
      Colors.amber,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.pink,
      Colors.cyan,
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SectionCard(
        title: 'Dividend Split',
        trailing: hasDividendRates && totalDividends > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '\$${(totalDividends / 1000).toStringAsFixed(1)}k accrued',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!hasDividendRates)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'No share classes have dividend rates configured',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              )
            else if (sortedEntries.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'No dividends have accrued yet',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ...sortedEntries.take(10).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        data.key,
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${data.value.toStringAsFixed(1)}%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (sortedEntries.length > 10)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '+ ${sortedEntries.length - 10} more investors',
                  style: theme.textTheme.bodySmall?.copyWith(
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
