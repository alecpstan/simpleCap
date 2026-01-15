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
  bool _showVestedOnly = false;

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
    final unvestedCount = provider.totalUnvestedShares;

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
            subtitle: showFD
                ? 'Fully Diluted'
                : unvestedCount > 0
                ? '${Formatters.compactNumber(unvestedCount)} unvested'
                : 'All vested',
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

    final hasUnvested = provider.totalUnvestedShares > 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SectionCard(
        title: 'Ownership',
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<bool>(
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
            if (hasUnvested && !_showByShareClass) ...[
              const SizedBox(height: 8),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('All')),
                  ButtonSegment(value: true, label: Text('Vested')),
                ],
                selected: {_showVestedOnly},
                onSelectionChanged: (value) {
                  setState(() {
                    _showVestedOnly = value.first;
                  });
                },
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ],
        ),
        child: SizedBox(
          height: 280,
          child: OwnershipPieChart(
            showByShareClass: _showByShareClass,
            showVestedOnly: _showVestedOnly && !_showByShareClass,
          ),
        ),
      ),
    );
  }

  Widget _buildDividendChart(BuildContext context, CapTableProvider provider) {
    if (provider.activeInvestors.isEmpty) {
      return const SizedBox.shrink();
    }

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

    // Check if any share classes have dividend rates (for cumulative preferred)
    final hasDividendRates = provider.shareClasses.any(
      (sc) => sc.dividendRate > 0,
    );

    // If no share classes have dividend rates, don't show this section
    if (!hasDividendRates) {
      return const SizedBox.shrink();
    }

    // Get total accrued cumulative preferred dividends
    final totalAccruedDividends = provider.totalAccruedDividends;

    // Get cumulative preferred dividend data per investor (actual $ amounts)
    final preferredDividendData = <String, double>{};
    for (final investor in provider.activeInvestors) {
      final dividends = provider.getAccruedDividendsByInvestor(investor.id);
      if (dividends > 0) {
        preferredDividendData[investor.name] = dividends;
      }
    }

    // Sort by dividend amount descending
    final sortedPreferredEntries = preferredDividendData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SectionCard(
        title: 'Cumulative Preferred Dividends',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (totalAccruedDividends > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${Formatters.compactCurrency(totalAccruedDividends)} total',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            Tooltip(
              message:
                  'Cumulative preferred dividends accrue automatically based on each share class\'s dividend rate. These are typically paid at a liquidity event (exit), not from company profits.',
              child: Icon(
                Icons.info_outline,
                size: 16,
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sortedPreferredEntries.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'No dividends have accrued yet',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ...sortedPreferredEntries.take(10).toList().asMap().entries.map((
              entry,
            ) {
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
                      Formatters.compactCurrency(data.value),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (sortedPreferredEntries.length > 10)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '+ ${sortedPreferredEntries.length - 10} more investors',
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
