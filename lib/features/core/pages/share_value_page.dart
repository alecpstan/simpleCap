import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/core_cap_table_provider.dart';
import '../models/transaction.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/avatars.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/info_widgets.dart';
import '../../../shared/utils/helpers.dart';

class ShareValuePage extends StatelessWidget {
  const ShareValuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CoreCapTableProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.investors.isEmpty) {
          return const EmptyState(
            icon: Icons.account_balance_wallet_outlined,
            title: 'No shareholders yet',
            subtitle: 'Add investors and shareholdings to see share values',
          );
        }

        final latestSharePrice = provider.latestSharePrice;
        if (latestSharePrice == 0) {
          return const EmptyState(
            icon: Icons.trending_up_outlined,
            title: 'No valuation data',
            subtitle:
                'Add investment rounds with valuations to calculate share values',
          );
        }

        // Sort investors by share value (highest first)
        final sortedInvestors = List.from(provider.investors)
          ..sort(
            (a, b) => provider
                .getShareValueByInvestor(b.id)
                .compareTo(provider.getShareValueByInvestor(a.id)),
          );

        // Filter to only investors with current shares (excluding exited)
        final investorsWithShares = sortedInvestors
            .where((i) => provider.getCurrentSharesByInvestor(i.id) > 0)
            .toList();

        // Get exited investors
        final exitedInvestors = provider.exitedInvestors;

        if (investorsWithShares.isEmpty && exitedInvestors.isEmpty) {
          return const EmptyState(
            icon: Icons.pie_chart_outline,
            title: 'No shareholdings',
            subtitle: 'Add shareholdings to investment rounds to see values',
          );
        }

        final totalValue = investorsWithShares.fold<double>(
          0,
          (sum, i) =>
              sum +
              (provider.getCurrentSharesByInvestor(i.id) * latestSharePrice),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Card
              SectionCard(
                title: 'Valuation Summary',
                icon: Icons.insights,
                helpKey: 'general.valuation',
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: MiniStat(
                            label: 'Share Price',
                            value: Formatters.currency(latestSharePrice),
                            helpKey: 'general.sharePrice',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MiniStat(
                            label: 'Total Value',
                            value: Formatters.compactCurrency(totalValue),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: MiniStat(
                            label: 'Company Valuation',
                            value: Formatters.compactCurrency(
                              provider.latestValuation,
                            ),
                            helpKey: 'general.valuation',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MiniStat(
                            label: 'Total Shares',
                            value: Formatters.number(
                              provider.totalIssuedShares,
                            ),
                            helpKey: 'general.issuedShares',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Shareholders List
              if (investorsWithShares.isNotEmpty) ...[
                Text(
                  'Shareholder Values',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...investorsWithShares.map((investor) {
                  return _ShareholderValueCard(
                    investor: investor,
                    provider: provider,
                  );
                }),
              ],

              // Exited Investors Section
              if (exitedInvestors.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Exited Investors',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Investors who have sold all their shares',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                ...exitedInvestors.map((investor) {
                  return _ExitedInvestorCard(
                    investor: investor,
                    provider: provider,
                  );
                }),
              ],

              // Partial Sellers Section (investors who have sold some shares but still hold some)
              if (provider.investorsWithSales
                  .where((i) => provider.getCurrentSharesByInvestor(i.id) > 0)
                  .isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Partial Sales',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Investors who have sold some shares',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                ...provider.investorsWithSales
                    .where((i) => provider.getCurrentSharesByInvestor(i.id) > 0)
                    .map((investor) {
                      return _PartialSellerCard(
                        investor: investor,
                        provider: provider,
                      );
                    }),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ShareholderValueCard extends StatelessWidget {
  final dynamic investor;
  final CoreCapTableProvider provider;

  const _ShareholderValueCard({required this.investor, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentShares = provider.getCurrentSharesByInvestor(investor.id);
    final shareValue = provider.getShareValueByInvestor(investor.id);
    final sharesSold = provider.getSharesSoldByInvestor(investor.id);
    final ownership = provider.getOwnershipPercentage(investor.id);
    final invested = provider.getInvestmentByInvestor(investor.id);
    final acquisitions = provider.getAcquisitionsByInvestor(investor.id);
    final saleProceeds = provider.getSaleProceedsByInvestor(investor.id);

    // Calculate gain/loss (current value + sale proceeds - invested)
    final totalValue = shareValue + saleProceeds;
    final gain = totalValue - invested;
    final gainPercent = invested > 0 ? (gain / invested) * 100 : 0.0;
    final isPositive = gain >= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: InvestorAvatar(name: investor.name, type: investor.type),
        title: Text(
          investor.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            Text(
              Formatters.currency(shareValue),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (isPositive ? Colors.green : Colors.red).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${isPositive ? '+' : ''}${Formatters.percent(gainPercent)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        ),
        trailing: Text(
          Formatters.percent(ownership),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),

                // Summary stats
                Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        label: 'Current Shares',
                        value: Formatters.number(currentShares),
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        label: 'Amount Invested',
                        value: Formatters.currency(invested),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        label: 'Current Value',
                        value: Formatters.currency(shareValue),
                        valueColor: theme.colorScheme.primary,
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        label: 'Total Gain/Loss',
                        value:
                            '${isPositive ? '+' : ''}${Formatters.currency(gain)}',
                        valueColor: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),

                // Show sale info if any shares were sold
                if (sharesSold > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _StatItem(
                          label: 'Shares Sold',
                          value: Formatters.number(sharesSold),
                        ),
                      ),
                      Expanded(
                        child: _StatItem(
                          label: 'Sale Proceeds',
                          value: Formatters.currency(saleProceeds),
                          valueColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],

                if (acquisitions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Acquisition Breakdown',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...acquisitions.map((transaction) {
                    final round = transaction.roundId != null
                        ? provider.getRoundById(transaction.roundId!)
                        : null;
                    final shareClass = provider.getShareClassById(
                      transaction.shareClassId,
                    );
                    final hasVesting =
                        provider.getVestingByTransaction(transaction.id) !=
                        null;
                    final holdingValue =
                        transaction.numberOfShares * provider.latestSharePrice;
                    final holdingGain = holdingValue - transaction.totalAmount;
                    final holdingGainPercent = transaction.totalAmount > 0
                        ? (holdingGain / transaction.totalAmount) * 100
                        : 0.0;

                    // Determine the transaction label
                    String transactionLabel;
                    if (round != null) {
                      transactionLabel = round.name;
                    } else {
                      // Use transaction type for non-round acquisitions
                      switch (transaction.type) {
                        case TransactionType.grant:
                          transactionLabel = 'Share Grant';
                        case TransactionType.secondaryPurchase:
                          transactionLabel = 'Secondary Purchase';
                        case TransactionType.optionExercise:
                          transactionLabel = 'Option Exercise';
                        default:
                          transactionLabel = 'Direct Purchase';
                      }
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          transactionLabel,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (hasVesting) ...[
                                          const SizedBox(width: 6),
                                          const TermChip(label: 'Vesting'),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      '${shareClass?.name ?? 'Unknown Class'} • ${Formatters.date(transaction.date)}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme.colorScheme.outline,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    Formatters.currency(holdingValue),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${holdingGain >= 0 ? '+' : ''}${Formatters.percent(holdingGainPercent)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: holdingGain >= 0
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  hasVesting
                                      ? '${Formatters.number(provider.getVestedShares(transaction.id))} / ${Formatters.number(transaction.numberOfShares)} shares vested'
                                      : '${Formatters.number(transaction.numberOfShares)} shares',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                              Text(
                                'Paid: ${Formatters.currency(transaction.totalAmount)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Price: ${Formatters.currency(transaction.pricePerShare)}/share',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                              ),
                              Text(
                                'Now: ${Formatters.currency(provider.latestSharePrice)}/share',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatItem({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _ExitedInvestorCard extends StatelessWidget {
  final dynamic investor;
  final CoreCapTableProvider provider;

  const _ExitedInvestorCard({required this.investor, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sales = provider.getSalesByInvestor(investor.id);
    final sharesSold = provider.getSharesSoldByInvestor(investor.id);
    final invested = provider.getInvestmentByInvestor(investor.id);
    final proceeds = provider.getSaleProceedsByInvestor(investor.id);
    final realizedProfit = provider.getRealizedProfitByInvestor(investor.id);
    final profitPercent = invested > 0
        ? (realizedProfit / invested) * 100
        : 0.0;
    final isPositive = realizedProfit >= 0;

    // Find exit date (latest sale date)
    DateTime? exitDate;
    if (sales.isNotEmpty) {
      exitDate = sales
          .map((s) => s.date)
          .reduce((a, b) => a.isAfter(b) ? a : b);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Stack(
          children: [
            InvestorAvatar(name: investor.name, type: investor.type),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.exit_to_app,
                  size: 14,
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Text(
              investor.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'EXITED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Text(
              '${isPositive ? '+' : ''}${Formatters.currency(realizedProfit)}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isPositive ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (isPositive ? Colors.green : Colors.red).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${isPositive ? '+' : ''}${Formatters.percent(profitPercent)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        ),
        trailing: exitDate != null
            ? Text(
                Formatters.date(exitDate),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              )
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),

                // Summary stats
                Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        label: 'Total Invested',
                        value: Formatters.currency(invested),
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        label: 'Total Proceeds',
                        value: Formatters.currency(proceeds),
                        valueColor: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        label: 'Shares Sold',
                        value: Formatters.number(sharesSold),
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        label: 'Realized Profit',
                        value:
                            '${isPositive ? '+' : ''}${Formatters.currency(realizedProfit)}',
                        valueColor: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),

                // Sale transactions
                if (sales.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Sale Transactions',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...sales.map((sale) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _getTransactionTypeLabel(sale.type),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                Formatters.date(sale.date),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${Formatters.number(sale.numberOfShares)} shares',
                                style: theme.textTheme.bodySmall,
                              ),
                              Text(
                                ' @ ${Formatters.currency(sale.pricePerShare)}/share',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total: ${Formatters.currency(sale.totalAmount)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                          if (sale.counterpartyInvestorId != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Buyer: ${provider.getInvestorById(sale.counterpartyInvestorId!)?.name ?? 'Unknown'}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTransactionTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.secondarySale:
        return 'Secondary Sale';
      case TransactionType.buyback:
        return 'Company Buyback';
      case TransactionType.purchase:
        return 'Purchase';
      case TransactionType.secondaryPurchase:
        return 'Secondary Purchase';
      case TransactionType.grant:
        return 'Grant';
      case TransactionType.optionExercise:
        return 'Option Exercise';
      case TransactionType.conversion:
        return 'Convertible Conversion';
      case TransactionType.reequitization:
        return 'Re-equitization';
    }
  }
}

/// Card for investors who have sold some but not all shares
class _PartialSellerCard extends StatelessWidget {
  final dynamic investor;
  final CoreCapTableProvider provider;

  const _PartialSellerCard({required this.investor, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentShares = provider.getCurrentSharesByInvestor(investor.id);
    final totalAcquired = provider.getSharesByInvestor(investor.id);
    final sharesSold = provider.getSharesSoldByInvestor(investor.id);
    final proceeds = provider.getSaleProceedsByInvestor(investor.id);
    final currentValue = currentShares * provider.latestSharePrice;
    final realizedProfit = provider.getRealizedProfitByInvestor(investor.id);
    final sales = provider.getSalesByInvestor(investor.id);

    // Calculate percentage sold
    final percentSold = totalAcquired > 0
        ? (sharesSold / totalAcquired) * 100
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Stack(
          children: [
            InvestorAvatar(name: investor.name, type: investor.type),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.swap_horiz,
                  size: 14,
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Text(
              investor.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${Formatters.percent(percentSold)} SOLD',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          'Sold ${Formatters.number(sharesSold)} shares for ${Formatters.currency(proceeds)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),

                // Summary stats
                Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        label: 'Original Shares',
                        value: Formatters.number(totalAcquired),
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        label: 'Shares Sold',
                        value: Formatters.number(sharesSold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        label: 'Current Shares',
                        value: Formatters.number(currentShares),
                        valueColor: theme.colorScheme.primary,
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        label: 'Sale Proceeds',
                        value: Formatters.currency(proceeds),
                        valueColor: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        label: 'Current Value',
                        value: Formatters.currency(currentValue),
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        label: 'Realized Profit',
                        value:
                            '${realizedProfit >= 0 ? '+' : ''}${Formatters.currency(realizedProfit)}',
                        valueColor: realizedProfit >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),

                // Sale transactions
                if (sales.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Sale Transactions',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...sales.map((sale) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _getTransactionTypeLabel(sale.type),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                Formatters.date(sale.date),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${Formatters.number(sale.numberOfShares)} shares',
                                style: theme.textTheme.bodySmall,
                              ),
                              Text(
                                ' @ ${Formatters.currency(sale.pricePerShare)}/share',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total: ${Formatters.currency(sale.totalAmount)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                          if (sale.counterpartyInvestorId != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Buyer: ${provider.getInvestorById(sale.counterpartyInvestorId!)?.name ?? 'Unknown'}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTransactionTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.secondarySale:
        return 'Secondary Sale';
      case TransactionType.buyback:
        return 'Company Buyback';
      case TransactionType.purchase:
        return 'Purchase';
      case TransactionType.secondaryPurchase:
        return 'Secondary Purchase';
      case TransactionType.grant:
        return 'Grant';
      case TransactionType.optionExercise:
        return 'Option Exercise';
      case TransactionType.conversion:
        return 'Convertible Conversion';
      case TransactionType.reequitization:
        return 'Re-equitization';
    }
  }
}
