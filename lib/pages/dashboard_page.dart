import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cap_table_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/ownership_pie_chart.dart';
import '../widgets/section_card.dart';
import '../widgets/resizable_table.dart';
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

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Name Header
              _buildCompanyHeader(context, provider),
              const SizedBox(height: 16),

              // Stats Grid
              _buildStatsGrid(provider),
              const SizedBox(height: 24),

              // Ownership Chart
              _buildOwnershipChart(context),
              const SizedBox(height: 24),

              // Top Shareholders Table
              _buildShareholdersSection(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompanyHeader(BuildContext context, CapTableProvider provider) {
    return Text(
      provider.companyName,
      style: Theme.of(
        context,
      ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildStatsGrid(CapTableProvider provider) {
    final activeInvestorCount = provider.activeInvestors.length;
    final showFD = provider.showFullyDiluted;
    final shareCount = showFD
        ? provider.fullyDilutedShares
        : provider.totalCurrentShares;
    final shareLabel = showFD ? 'Fully Diluted' : 'Shares Issued';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // FD Toggle
        Row(
          children: [
            const Spacer(),
            const HelpIcon(helpKey: 'general.fullyDiluted', size: 14),
            const SizedBox(width: 4),
            FilterChip(
              label: Text(showFD ? 'Fully Diluted' : 'Issued Only'),
              selected: showFD,
              onSelected: (_) => provider.toggleFullyDiluted(),
              avatar: Icon(
                showFD ? Icons.unfold_more : Icons.unfold_less,
                size: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        StatsGrid(
          stats: [
            StatCard(
              title: 'Valuation',
              value: Formatters.compactCurrency(provider.latestValuation),
              icon: Icons.trending_up,
              color: Colors.green,
              helpKey: 'general.valuation',
            ),
            StatCard(
              title: 'Total Raised',
              value: Formatters.compactCurrency(provider.totalInvested),
              icon: Icons.attach_money,
              color: Colors.blue,
              subtitle: provider.outstandingConvertibles.isNotEmpty
                  ? '+ ${Formatters.compactCurrency(provider.totalConvertiblePrincipal)} convertibles'
                  : '${provider.rounds.length} rounds',
              helpKey: 'rounds.amountRaised',
            ),
            StatCard(
              title: shareLabel,
              value: Formatters.number(shareCount),
              icon: Icons.pie_chart,
              color: Colors.purple,
              subtitle: showFD && provider.convertibleShares > 0
                  ? 'Incl. ${Formatters.number(provider.convertibleShares)} from convertibles'
                  : '$activeInvestorCount active investors',
              helpKey: showFD ? 'general.fullyDiluted' : 'general.issuedShares',
            ),
            StatCard(
              title: 'Share Price',
              value: Formatters.currency(provider.latestSharePrice),
              icon: Icons.monetization_on,
              color: Colors.orange,
              helpKey: 'general.sharePrice',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOwnershipChart(BuildContext context) {
    return SectionCard(
      title: 'Ownership Breakdown',
      trailing: SegmentedButton<bool>(
        segments: const [
          ButtonSegment(
            value: false,
            label: Text('By Investor'),
            icon: Icon(Icons.person),
          ),
          ButtonSegment(
            value: true,
            label: Text('By Class'),
            icon: Icon(Icons.category),
          ),
        ],
        selected: {_showByShareClass},
        onSelectionChanged: (value) {
          setState(() {
            _showByShareClass = value.first;
          });
        },
      ),
      child: SizedBox(
        height: 300,
        child: OwnershipPieChart(showByShareClass: _showByShareClass),
      ),
    );
  }

  Widget _buildShareholdersSection(
    BuildContext context,
    CapTableProvider provider,
  ) {
    return SectionCard(
      title: 'Top Shareholders',
      child: _buildShareholdersTable(context, provider),
    );
  }

  Widget _buildShareholdersTable(
    BuildContext context,
    CapTableProvider provider,
  ) {
    final activeInvestors = provider.activeInvestors;
    if (activeInvestors.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No investors yet. Add investors to see the cap table.'),
      );
    }

    final sortedInvestors = List.from(activeInvestors)
      ..sort(
        (a, b) => provider
            .getOwnershipPercentage(b.id)
            .compareTo(provider.getOwnershipPercentage(a.id)),
      );

    const columns = [
      ResizableColumn(
        key: 'investor',
        label: 'Investor',
        defaultWidth: 120,
        minWidth: 80,
      ),
      ResizableColumn(
        key: 'type',
        label: 'Type',
        defaultWidth: 100,
        minWidth: 70,
      ),
      ResizableColumn(
        key: 'shares',
        label: 'Shares',
        defaultWidth: 100,
        minWidth: 70,
        numeric: true,
      ),
      ResizableColumn(
        key: 'ownership',
        label: 'Ownership',
        defaultWidth: 90,
        minWidth: 70,
        numeric: true,
      ),
      ResizableColumn(
        key: 'invested',
        label: 'Invested',
        defaultWidth: 100,
        minWidth: 70,
        numeric: true,
      ),
    ];

    final rows = sortedInvestors.take(10).map((investor) {
      final shares = provider.getCurrentSharesByInvestor(investor.id);
      final ownership = provider.getOwnershipPercentage(investor.id);
      final invested = provider.getInvestmentByInvestor(investor.id);

      return ResizableRow(
        cells: [
          Text(investor.name),
          Text(investor.typeDisplayName),
          Text(Formatters.number(shares)),
          Text(Formatters.percent(ownership)),
          Text(Formatters.compactCurrency(invested)),
        ],
      );
    }).toList();

    return ResizableTable(
      columns: columns,
      rows: rows,
      columnWidths: provider.tableColumnWidths,
      onColumnResized: (key, width) {
        provider.updateColumnWidth(key, width);
      },
    );
  }
}
