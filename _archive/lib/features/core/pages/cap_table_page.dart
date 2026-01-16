import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/core_cap_table_provider.dart';
import '../../../shared/widgets/resizable_table.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/utils/helpers.dart';

class CapTablePage extends StatefulWidget {
  const CapTablePage({super.key});

  @override
  State<CapTablePage> createState() => _CapTablePageState();
}

class _CapTablePageState extends State<CapTablePage> {
  bool _showFullyDiluted = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<CoreCapTableProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final activeInvestors = provider.activeInvestors;
        if (activeInvestors.isEmpty) {
          return const EmptyState(
            icon: Icons.table_chart_outlined,
            title: 'No shareholders yet',
            subtitle: 'Add investors and transactions to see your cap table',
          );
        }

        // Get share classes that have current shares
        final usedShareClassIds = <String>{};
        for (final investor in activeInvestors) {
          for (final shareClass in provider.shareClasses) {
            final shares = provider.getCurrentSharesByInvestorAndClass(
              investor.id,
              shareClass.id,
            );
            if (shares > 0) {
              usedShareClassIds.add(shareClass.id);
            }
          }
        }

        final usedShareClasses = provider.shareClasses
            .where((sc) => usedShareClassIds.contains(sc.id))
            .toList();

        return Column(
          children: [
            // Controls bar
            _buildControlsBar(context, provider),
            // Table
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildCapTable(
                    context,
                    provider,
                    activeInvestors,
                    usedShareClasses,
                  ),
                ),
              ),
            ),
            // Summary footer
            _buildSummaryFooter(context, provider),
          ],
        );
      },
    );
  }

  Widget _buildControlsBar(BuildContext context, CoreCapTableProvider provider) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Cap Table',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Fully diluted toggle
          FilterChip(
            label: const Text('Fully Diluted'),
            selected: _showFullyDiluted,
            onSelected: (value) {
              setState(() {
                _showFullyDiluted = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCapTable(
    BuildContext context,
    CoreCapTableProvider provider,
    List investors,
    List shareClasses,
  ) {
    final theme = Theme.of(context);

    // Build columns: Investor, each share class, Total, Ownership %
    final columns = <ResizableColumn>[
      const ResizableColumn(
        key: 'investor',
        label: 'Shareholder',
        defaultWidth: 160,
        minWidth: 120,
      ),
      ...shareClasses.map((sc) => ResizableColumn(
            key: sc.id,
            label: sc.name,
            defaultWidth: 100,
            minWidth: 80,
            numeric: true,
          )),
      const ResizableColumn(
        key: 'total',
        label: 'Total',
        defaultWidth: 100,
        minWidth: 80,
        numeric: true,
      ),
      const ResizableColumn(
        key: 'ownership',
        label: 'Ownership',
        defaultWidth: 90,
        minWidth: 70,
        numeric: true,
      ),
    ];

    // Calculate totals for fully diluted view
    final totalShares = _showFullyDiluted
        ? provider.fullyDilutedShares
        : provider.totalCurrentShares;

    // Build rows
    final rows = <ResizableRow>[];

    // Sort investors by ownership (descending)
    final sortedInvestors = List.from(investors)
      ..sort((a, b) {
        final aShares = provider.getCurrentSharesByInvestor(a.id);
        final bShares = provider.getCurrentSharesByInvestor(b.id);
        return bShares.compareTo(aShares);
      });

    for (final investor in sortedInvestors) {
      final investorShares = provider.getCurrentSharesByInvestor(investor.id);
      final ownership = totalShares > 0
          ? (investorShares / totalShares * 100)
          : 0.0;

      final cells = <Widget>[
        // Investor name
        Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                investor.name.isNotEmpty ? investor.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                investor.name,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        // Shares per class
        ...shareClasses.map((sc) {
          final shares = provider.getCurrentSharesByInvestorAndClass(
            investor.id,
            sc.id,
          );
          return Text(
            shares > 0 ? Formatters.number(shares) : '-',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: shares > 0 ? null : theme.colorScheme.outline,
            ),
          );
        }),
        // Total
        Text(
          Formatters.number(investorShares),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        // Ownership %
        Text(
          '${ownership.toStringAsFixed(2)}%',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ];

      rows.add(ResizableRow(cells: cells));
    }

    // Add ESOP pool row if fully diluted and pool exists
    if (_showFullyDiluted && provider.unallocatedEsopShares > 0) {
      final esopShares = provider.unallocatedEsopShares;
      final esopOwnership = totalShares > 0
          ? (esopShares / totalShares * 100)
          : 0.0;

      final esopCells = <Widget>[
        Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: Colors.orange.withValues(alpha: 0.2),
              child: const Icon(Icons.card_giftcard, size: 14, color: Colors.orange),
            ),
            const SizedBox(width: 8),
            Text(
              'ESOP Pool (Unallocated)',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        ...shareClasses.map((_) => Text(
              '-',
              style: TextStyle(color: theme.colorScheme.outline),
            )),
        Text(
          Formatters.number(esopShares),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${esopOwnership.toStringAsFixed(2)}%',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
      ];

      rows.add(ResizableRow(cells: esopCells));
    }

    // Add convertibles row if fully diluted and convertibles exist
    if (_showFullyDiluted && provider.convertibleShares > 0) {
      final convShares = provider.convertibleShares;
      final convOwnership = totalShares > 0
          ? (convShares / totalShares * 100)
          : 0.0;

      final convCells = <Widget>[
        Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: Colors.teal.withValues(alpha: 0.2),
              child: const Icon(Icons.receipt_long, size: 14, color: Colors.teal),
            ),
            const SizedBox(width: 8),
            Text(
              'Convertibles (Est.)',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        ...shareClasses.map((_) => Text(
              '-',
              style: TextStyle(color: theme.colorScheme.outline),
            )),
        Text(
          Formatters.number(convShares),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${convOwnership.toStringAsFixed(2)}%',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
      ];

      rows.add(ResizableRow(cells: convCells));
    }

    return ResizableTable(
      columns: columns,
      rows: rows,
      columnWidths: provider.tableColumnWidths,
      onColumnResized: (key, width) {
        provider.updateColumnWidth(key, width);
      },
    );
  }

  Widget _buildSummaryFooter(BuildContext context, CoreCapTableProvider provider) {
    final theme = Theme.of(context);
    final totalShares = _showFullyDiluted
        ? provider.fullyDilutedShares
        : provider.totalCurrentShares;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            label: 'Total Shares',
            value: Formatters.compactNumber(totalShares),
          ),
          _SummaryItem(
            label: 'Shareholders',
            value: '${provider.activeInvestors.length}',
          ),
          _SummaryItem(
            label: 'Share Classes',
            value: '${provider.shareClasses.where((sc) =>
                provider.getOwnershipByShareClass()[sc.id] != null
            ).length}',
          ),
          if (provider.latestValuation > 0)
            _SummaryItem(
              label: 'Valuation',
              value: Formatters.compactCurrency(provider.latestValuation),
            ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
