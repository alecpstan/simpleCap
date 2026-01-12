import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cap_table_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/ownership_pie_chart.dart';
import '../widgets/section_card.dart';
import '../widgets/info_widgets.dart';
import '../widgets/dialogs.dart';
import '../widgets/resizable_table.dart';
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

              // Summary Row
              _buildSummaryChips(provider),
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
    return Row(
      children: [
        Expanded(
          child: Text(
            provider.companyName,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _editCompanyName(context, provider),
          tooltip: 'Edit company name',
        ),
      ],
    );
  }

  Widget _buildStatsGrid(CapTableProvider provider) {
    return StatsGrid(
      stats: [
        StatCard(
          title: 'Valuation',
          value: Formatters.compactCurrency(provider.latestValuation),
          icon: Icons.trending_up,
          color: Colors.green,
        ),
        StatCard(
          title: 'Total Raised',
          value: Formatters.compactCurrency(provider.totalInvested),
          icon: Icons.attach_money,
          color: Colors.blue,
        ),
        StatCard(
          title: 'Shares Issued',
          value: Formatters.number(provider.totalCurrentShares),
          icon: Icons.pie_chart,
          color: Colors.purple,
        ),
        StatCard(
          title: 'Share Price',
          value: Formatters.currency(provider.latestSharePrice),
          icon: Icons.monetization_on,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildSummaryChips(CapTableProvider provider) {
    final activeInvestorCount = provider.activeInvestors.length;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        InfoChip(
          label: '$activeInvestorCount Active Investors',
          icon: Icons.people,
        ),
        InfoChip(label: '${provider.rounds.length} Rounds', icon: Icons.layers),
        InfoChip(
          label: '${provider.shareClasses.length} Share Classes',
          icon: Icons.category,
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
        height: 250,
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

  Future<void> _editCompanyName(
    BuildContext context,
    CapTableProvider provider,
  ) async {
    final result = await showTextInputDialog(
      context: context,
      title: 'Company Name',
      initialValue: provider.companyName,
      labelText: 'Company Name',
      hintText: 'e.g., My Company Pty Ltd',
    );

    if (result != null && result.isNotEmpty) {
      await provider.updateCompanyName(result);
    }
  }
}
