import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/esop_pool_change.dart';
import '../../core/models/investor.dart';
import '../models/option_grant.dart';
import '../models/warrant.dart';
import '../../core/models/share_class.dart';
import '../../core/models/transaction.dart';
import '../../core/models/vesting_schedule.dart';
import '../../core/providers/core_cap_table_provider.dart'
    hide EsopDilutionMethod;
import '../../valuations/providers/valuations_provider.dart';
import '../../valuations/widgets/valuation_wizard_screen.dart';
import '../providers/esop_provider.dart';
import '../../../shared/utils/helpers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/form_fields.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/info_widgets.dart';
import '../../../shared/widgets/avatars.dart';
import '../../../shared/widgets/dialogs.dart';
import '../../../shared/widgets/expandable_card.dart';

class OptionsPage extends StatefulWidget {
  const OptionsPage({super.key});

  @override
  State<OptionsPage> createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<CoreCapTableProvider, EsopProvider, ValuationsProvider>(
      builder:
          (context, coreProvider, esopProvider, valuationsProvider, child) {
            if (coreProvider.isLoading || !esopProvider.isInitialized) {
              return const Center(child: CircularProgressIndicator());
            }

            // Check for expired grants and warrants
            WidgetsBinding.instance.addPostFrameCallback((_) {
              esopProvider.updateExpiredOptionGrants();
              esopProvider.updateExpiredWarrants();
            });

            return Scaffold(
              appBar: AppBar(
                title: const Text('Equity Plans'),
                bottom: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Options', icon: Icon(Icons.card_giftcard)),
                    Tab(text: 'Warrants', icon: Icon(Icons.receipt_long)),
                    Tab(text: 'Shares', icon: Icon(Icons.inventory_2)),
                    Tab(text: 'Vesting', icon: Icon(Icons.schedule)),
                  ],
                ),
              ),
              body: TabBarView(
                controller: _tabController,
                children: [
                  // Options Tab
                  _buildOptionsTab(
                    context,
                    coreProvider,
                    esopProvider,
                    valuationsProvider,
                  ),
                  // Warrants Tab
                  _buildWarrantsTab(context, coreProvider, esopProvider),
                  // Shares Tab
                  _buildSharesTab(context, coreProvider),
                  // Vesting Tab
                  _buildVestingTab(context, coreProvider),
                ],
              ),
              floatingActionButton: _buildFAB(
                context,
                coreProvider,
                esopProvider,
                valuationsProvider,
              ),
            );
          },
    );
  }

  Widget _buildFAB(
    BuildContext context,
    CoreCapTableProvider coreProvider,
    EsopProvider esopProvider,
    ValuationsProvider valuationsProvider,
  ) {
    // Show different FAB based on current tab
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        switch (_tabController.index) {
          case 0:
            return FloatingActionButton.extended(
              onPressed: () => _showGrantDialog(
                context,
                coreProvider,
                esopProvider,
                valuationsProvider,
              ),
              icon: const Icon(Icons.add),
              label: const Text('Grant Options'),
            );
          case 1:
            return FloatingActionButton.extended(
              onPressed: () =>
                  _showWarrantDialog(context, coreProvider, esopProvider),
              icon: const Icon(Icons.add),
              label: const Text('Issue Warrant'),
            );
          case 2:
            return FloatingActionButton.extended(
              onPressed: () => _showVestingSharesDialog(context, coreProvider),
              icon: const Icon(Icons.add),
              label: const Text('Add Shares'),
            );
          case 3:
          default:
            // No FAB for vesting tab - vesting is tied to grants/transactions
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildOptionsTab(
    BuildContext context,
    CoreCapTableProvider coreProvider,
    EsopProvider esopProvider,
    ValuationsProvider valuationsProvider,
  ) {
    final grants = esopProvider.optionGrants;
    final activeGrants = esopProvider.activeOptionGrants;
    final inactiveGrants = grants.where((g) {
      return g.status == OptionGrantStatus.fullyExercised ||
          g.status == OptionGrantStatus.expired ||
          g.status == OptionGrantStatus.cancelled ||
          g.status == OptionGrantStatus.forfeited;
    }).toList();

    if (grants.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPoolManagement(context, coreProvider, esopProvider),
            const SizedBox(height: 16),
            _buildSummaryCards(context, esopProvider),
            const SizedBox(height: 24),
            const EmptyState(
              icon: Icons.card_giftcard,
              title: 'No Option Grants',
              subtitle:
                  'Grant stock options to employees, advisors, or contractors.',
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        // ESOP Pool Management - always visible
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildPoolManagement(context, coreProvider, esopProvider),
          ),
        ),

        // Summary stats - always visible
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSummaryCards(context, esopProvider),
          ),
        ),

        // Active grants
        if (activeGrants.isNotEmpty) ...[
          _buildSectionHeader(context, 'Active Grants', activeGrants.length),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildGrantCard(
                context,
                coreProvider,
                esopProvider,
                activeGrants[index],
              ),
              childCount: activeGrants.length,
            ),
          ),
        ],

        // History (exercised/cancelled/expired)
        if (inactiveGrants.isNotEmpty) ...[
          _buildSectionHeader(context, 'History', inactiveGrants.length),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildGrantCard(
                context,
                coreProvider,
                esopProvider,
                inactiveGrants[index],
                isHistory: true,
              ),
              childCount: inactiveGrants.length,
            ),
          ),
        ],

        // Bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildWarrantsTab(
    BuildContext context,
    CoreCapTableProvider coreProvider,
    EsopProvider esopProvider,
  ) {
    final warrants = esopProvider.warrants;
    final activeWarrants = esopProvider.activeWarrants;
    final pendingWarrants = esopProvider.pendingWarrants;
    final sharePrice = coreProvider.latestSharePrice;
    final inactiveWarrants = warrants.where((w) {
      return w.status == WarrantStatus.fullyExercised ||
          w.status == WarrantStatus.expired ||
          w.status == WarrantStatus.cancelled;
    }).toList();

    if (warrants.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWarrantsSummary(context, esopProvider, sharePrice),
            const SizedBox(height: 24),
            const EmptyState(
              icon: Icons.receipt_long,
              title: 'No Warrants',
              subtitle:
                  'Issue warrants to investors as part of funding rounds or deals.',
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        // Warrants Summary
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildWarrantsSummary(context, esopProvider, sharePrice),
          ),
        ),

        // Pending warrants (issued in draft rounds)
        if (pendingWarrants.isNotEmpty) ...[
          _buildSectionHeaderWithBadge(
            context,
            'Pending Warrants',
            pendingWarrants.length,
            badgeText: 'Draft Round',
            badgeColor: Colors.amber,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildWarrantCard(
                context,
                coreProvider,
                esopProvider,
                pendingWarrants[index],
              ),
              childCount: pendingWarrants.length,
            ),
          ),
        ],

        // Active warrants
        if (activeWarrants.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            'Active Warrants',
            activeWarrants.length,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildWarrantCard(
                context,
                coreProvider,
                esopProvider,
                activeWarrants[index],
              ),
              childCount: activeWarrants.length,
            ),
          ),
        ],

        // History (exercised/cancelled/expired warrants)
        if (inactiveWarrants.isNotEmpty) ...[
          _buildSectionHeader(context, 'History', inactiveWarrants.length),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildWarrantCard(
                context,
                coreProvider,
                esopProvider,
                inactiveWarrants[index],
              ),
              childCount: inactiveWarrants.length,
            ),
          ),
        ],

        // Bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildWarrantsSummary(
    BuildContext context,
    EsopProvider esopProvider,
    double sharePrice,
  ) {
    final totalOutstanding = esopProvider.totalWarrantsOutstanding;
    final totalExercised = esopProvider.totalWarrantsExercised;
    final activeWarrants = esopProvider.activeWarrants;

    // Calculate total intrinsic value
    final totalIntrinsicValue = activeWarrants.fold(
      0.0,
      (sum, w) => sum + w.intrinsicValue(sharePrice),
    );

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SummaryCard(
          label: 'Outstanding',
          value: Formatters.compactNumber(totalOutstanding),
          icon: Icons.receipt_long,
          color: Colors.blue,
        ),
        SummaryCard(
          label: 'Exercised',
          value: Formatters.compactNumber(totalExercised),
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        SummaryCard(
          label: 'Intrinsic Value',
          value: Formatters.compactCurrency(totalIntrinsicValue),
          icon: Icons.trending_up,
          color: Colors.amber,
        ),
      ],
    );
  }

  Widget _buildWarrantsList(
    BuildContext context,
    CoreCapTableProvider coreProvider,
    EsopProvider esopProvider,
    List<Warrant> warrants,
  ) {
    return Column(
      children: warrants.map((warrant) {
        final investor = coreProvider.getInvestorById(warrant.investorId);
        final shareClass = warrant.shareClassId != null
            ? coreProvider.getShareClassById(warrant.shareClassId!)
            : null;
        final sharePrice = coreProvider.latestSharePrice;
        final isInTheMoney = warrant.isInTheMoney(sharePrice);
        final intrinsicValue = warrant.intrinsicValue(sharePrice);

        return ExpandableCard(
          leading: CircleAvatar(
            backgroundColor: warrant.status.color.withValues(alpha: 0.2),
            child: Icon(
              Icons.receipt_long,
              color: warrant.status.color,
              size: 20,
            ),
          ),
          title: investor?.name ?? 'Unknown',
          subtitle:
              '${Formatters.number(warrant.remainingWarrants)} warrants @ ${Formatters.currency(warrant.strikePrice)}',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: warrant.status.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              warrant.status.displayName,
              style: TextStyle(
                color: warrant.status.color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          chips: [
            InfoTag(
              label: 'Exercised',
              value: Formatters.compactNumber(warrant.exercisedCount),
              color: Colors.blue,
            ),
            if (isInTheMoney)
              InfoTag(
                label: 'In the Money',
                icon: Icons.trending_up,
                color: Colors.green,
              ),
            InfoTag(
              label: 'Value',
              value: Formatters.compactCurrency(intrinsicValue),
              color: isInTheMoney ? Colors.green : Colors.grey,
            ),
          ],
          expandedContent: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DetailRow(
                label: 'Number of Warrants',
                value: Formatters.number(warrant.numberOfWarrants),
              ),
              DetailRow(
                label: 'Strike Price',
                value: Formatters.currency(warrant.strikePrice),
              ),
              DetailRow(
                label: 'Share Class',
                value: shareClass?.name ?? 'Not specified',
              ),
              DetailRow(
                label: 'Issue Date',
                value: Formatters.date(warrant.issueDate),
              ),
              DetailRow(
                label: 'Expiry Date',
                value: Formatters.date(warrant.expiryDate),
              ),
              const Divider(height: 16),
              DetailRow(
                label: 'Exercised',
                value: Formatters.number(warrant.exercisedCount),
              ),
              DetailRow(
                label: 'Remaining',
                value: Formatters.number(warrant.remainingWarrants),
              ),
              DetailRow(
                label: 'Current Share Price',
                value: Formatters.currency(sharePrice),
              ),
              const Divider(height: 16),
              // Value section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isInTheMoney
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isInTheMoney ? Icons.trending_up : Icons.trending_flat,
                      color: isInTheMoney ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isInTheMoney ? 'In The Money' : 'Out of Money',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isInTheMoney ? Colors.green : Colors.grey,
                            ),
                          ),
                          Text(
                            'Intrinsic value: ${Formatters.currency(intrinsicValue)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (warrant.sourceConvertibleId != null) ...[
                const SizedBox(height: 8),
                DetailRow(
                  label: 'Source',
                  value:
                      'From Convertible (${((warrant.coveragePercent ?? 0) * 100).toStringAsFixed(0)}% coverage)',
                ),
              ],
              if (warrant.notes != null && warrant.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                DetailRow(label: 'Notes', value: warrant.notes!),
              ],
            ],
          ),
          actions: [
            if (warrant.canExercise)
              FilledButton.icon(
                onPressed: () => _showExerciseWarrantDialog(
                  context,
                  coreProvider,
                  esopProvider,
                  warrant,
                ),
                icon: const Icon(Icons.fitness_center, size: 18),
                label: const Text('Exercise'),
              ),
            TextButton.icon(
              onPressed: () => _showWarrantDialog(
                context,
                coreProvider,
                esopProvider,
                existingWarrant: warrant,
              ),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
            ),
            TextButton.icon(
              onPressed: () =>
                  _confirmDeleteWarrant(context, esopProvider, warrant),
              icon: const Icon(
                Icons.delete_outline,
                size: 18,
                color: Colors.red,
              ),
              label: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
          accentColor: warrant.status.color,
        );
      }).toList(),
    );
  }

  /// Build a single warrant card for use in SliverList
  Widget _buildWarrantCard(
    BuildContext context,
    CoreCapTableProvider coreProvider,
    EsopProvider esopProvider,
    Warrant warrant,
  ) {
    final investor = coreProvider.getInvestorById(warrant.investorId);
    final shareClass = warrant.shareClassId != null
        ? coreProvider.getShareClassById(warrant.shareClassId!)
        : null;
    final sharePrice = coreProvider.latestSharePrice;
    final isInTheMoney = warrant.isInTheMoney(sharePrice);
    final intrinsicValue = warrant.intrinsicValue(sharePrice);

    return ExpandableCard(
      leading: CircleAvatar(
        backgroundColor: warrant.status.color.withValues(alpha: 0.2),
        child: Icon(Icons.receipt_long, color: warrant.status.color, size: 20),
      ),
      title: investor?.name ?? 'Unknown',
      subtitle:
          '${Formatters.number(warrant.remainingWarrants)} warrants @ ${Formatters.currency(warrant.strikePrice)}',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: warrant.status.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          warrant.status.displayName,
          style: TextStyle(
            color: warrant.status.color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chips: [
        InfoTag(
          label: 'Exercised',
          value: Formatters.compactNumber(warrant.exercisedCount),
          color: Colors.blue,
        ),
        if (isInTheMoney)
          InfoTag(
            label: 'In the Money',
            icon: Icons.trending_up,
            color: Colors.green,
          ),
        InfoTag(
          label: 'Value',
          value: Formatters.compactCurrency(intrinsicValue),
          color: isInTheMoney ? Colors.green : Colors.grey,
        ),
      ],
      expandedContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailRow(
            label: 'Number of Warrants',
            value: Formatters.number(warrant.numberOfWarrants),
          ),
          DetailRow(
            label: 'Strike Price',
            value: Formatters.currency(warrant.strikePrice),
          ),
          DetailRow(
            label: 'Share Class',
            value: shareClass?.name ?? 'Not specified',
          ),
          DetailRow(
            label: 'Issue Date',
            value: Formatters.date(warrant.issueDate),
          ),
          DetailRow(
            label: 'Expiry Date',
            value: Formatters.date(warrant.expiryDate),
          ),
          const Divider(height: 16),
          DetailRow(
            label: 'Exercised',
            value: Formatters.number(warrant.exercisedCount),
          ),
          DetailRow(
            label: 'Remaining',
            value: Formatters.number(warrant.remainingWarrants),
          ),
          DetailRow(
            label: 'Current Share Price',
            value: Formatters.currency(sharePrice),
          ),
          const Divider(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isInTheMoney
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  isInTheMoney ? Icons.trending_up : Icons.trending_flat,
                  color: isInTheMoney ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isInTheMoney ? 'In The Money' : 'Out of Money',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isInTheMoney ? Colors.green : Colors.grey,
                        ),
                      ),
                      Text(
                        'Intrinsic value: ${Formatters.currency(intrinsicValue)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (warrant.sourceConvertibleId != null) ...[
            const SizedBox(height: 8),
            DetailRow(
              label: 'Source',
              value:
                  'From Convertible (${((warrant.coveragePercent ?? 0) * 100).toStringAsFixed(0)}% coverage)',
            ),
          ],
          if (warrant.notes != null && warrant.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            DetailRow(label: 'Notes', value: warrant.notes!),
          ],
        ],
      ),
      actions: [
        if (warrant.canExercise)
          FilledButton.icon(
            onPressed: () => _showExerciseWarrantDialog(
              context,
              coreProvider,
              esopProvider,
              warrant,
            ),
            icon: const Icon(Icons.fitness_center, size: 18),
            label: const Text('Exercise'),
          ),
        TextButton.icon(
          onPressed: () => _showWarrantDialog(
            context,
            coreProvider,
            esopProvider,
            existingWarrant: warrant,
          ),
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('Edit'),
        ),
        TextButton.icon(
          onPressed: () =>
              _confirmDeleteWarrant(context, esopProvider, warrant),
          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
          label: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
      accentColor: warrant.status.color,
    );
  }

  Widget _buildSharesTab(BuildContext context, CoreCapTableProvider provider) {
    // Get transactions of type 'grant' that have vesting schedules
    final grantTransactions = provider.transactions
        .where((t) => t.type == TransactionType.grant)
        .toList();

    // Get vesting shares (grants with vesting schedules)
    final vestingShares = grantTransactions.where((t) {
      return provider.vestingSchedules.any((vs) => vs.transactionId == t.id);
    }).toList();

    // Get non-vesting shares (grants without vesting schedules)
    final immediateShares = grantTransactions.where((t) {
      return !provider.vestingSchedules.any((vs) => vs.transactionId == t.id);
    }).toList();

    if (grantTransactions.isEmpty) {
      return const EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'No Share Grants',
        subtitle: 'Add founder or employee shares with vesting schedules.',
      );
    }

    return CustomScrollView(
      slivers: [
        // Summary stats
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildSharesSummary(context, provider, grantTransactions),
          ),
        ),

        // Vesting shares section
        if (vestingShares.isNotEmpty) ...[
          _buildSectionHeader(context, 'Vesting Shares', vestingShares.length),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildShareCard(
                context,
                provider,
                vestingShares[index],
                showVesting: true,
              ),
              childCount: vestingShares.length,
            ),
          ),
        ],

        // Immediate (non-vesting) shares section
        if (immediateShares.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            'Immediate Shares',
            immediateShares.length,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildShareCard(
                context,
                provider,
                immediateShares[index],
                showVesting: false,
              ),
              childCount: immediateShares.length,
            ),
          ),
        ],

        // Bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildSharesSummary(
    BuildContext context,
    CoreCapTableProvider provider,
    List<Transaction> grantTransactions,
  ) {
    final totalShares = grantTransactions.fold<int>(
      0,
      (sum, t) => sum + t.numberOfShares,
    );

    final vestingCount = grantTransactions.where((t) {
      return provider.vestingSchedules.any((vs) => vs.transactionId == t.id);
    }).length;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SummaryCard(
          label: 'Total Shares',
          value: Formatters.compactNumber(totalShares),
          icon: Icons.pie_chart,
          color: Colors.green,
        ),
        SummaryCard(
          label: 'With Vesting',
          value: vestingCount.toString(),
          icon: Icons.schedule,
          color: Colors.blue,
        ),
        SummaryCard(
          label: 'Immediate',
          value: (grantTransactions.length - vestingCount).toString(),
          icon: Icons.flash_on,
          color: Colors.grey,
        ),
      ],
    );
  }

  /// Build a single share card for use in SliverList
  Widget _buildShareCard(
    BuildContext context,
    CoreCapTableProvider provider,
    Transaction transaction, {
    required bool showVesting,
  }) {
    final investor = provider.getInvestorById(transaction.investorId);
    final shareClass = provider.getShareClassById(transaction.shareClassId);
    final round = transaction.roundId != null
        ? provider.getRoundById(transaction.roundId!)
        : null;
    final vestingSchedule = provider.vestingSchedules
        .cast<VestingSchedule?>()
        .firstWhere(
          (vs) => vs?.transactionId == transaction.id,
          orElse: () => null,
        );
    final vestedPercent = vestingSchedule?.vestingPercentage ?? 100;
    final totalValue = transaction.numberOfShares * transaction.pricePerShare;

    return ExpandableCard(
      leading: InvestorAvatar(
        name: investor?.name ?? '?',
        type: investor?.type,
        radius: 18,
      ),
      title: investor?.name ?? 'Unknown',
      subtitle:
          '${Formatters.number(transaction.numberOfShares)} ${shareClass?.name ?? 'shares'}',
      trailing: showVesting && vestingSchedule != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${vestedPercent.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
      chips: [
        if (round != null) InfoTag(label: round.name, color: Colors.indigo),
        InfoTag(
          label: 'Value',
          value: Formatters.compactCurrency(totalValue),
          color: Colors.green,
        ),
        if (showVesting && vestingSchedule != null)
          InfoTag(
            label: 'Vesting',
            value: '${vestingSchedule.vestingPeriodMonths}mo',
            color: Colors.blue,
          ),
      ],
      expandedContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailRow(
            label: 'Shares',
            value: Formatters.number(transaction.numberOfShares),
          ),
          DetailRow(label: 'Share Class', value: shareClass?.name ?? 'Unknown'),
          DetailRow(
            label: 'Grant Date',
            value: Formatters.date(transaction.date),
          ),
          if (round != null) DetailRow(label: 'Round', value: round.name),
          DetailRow(
            label: 'Price/Share',
            value: Formatters.currency(transaction.pricePerShare),
          ),
          DetailRow(
            label: 'Total Value',
            value: Formatters.currency(totalValue),
            highlight: true,
          ),
          if (vestingSchedule != null) ...[
            const Divider(height: 16),
            DetailRow(
              label: 'Start Date',
              value: Formatters.date(vestingSchedule.startDate),
            ),
            DetailRow(
              label: 'Vesting Schedule',
              value:
                  '${vestingSchedule.vestingPeriodMonths}mo with ${vestingSchedule.cliffMonths}mo cliff',
            ),
            ProgressRow(
              label: 'Vesting Progress',
              progress: vestedPercent / 100,
              color: vestedPercent >= 100 ? Colors.green : Colors.blue,
            ),
          ],
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: () => _showVestingSharesDialog(
            context,
            provider,
            existingTransaction: transaction,
          ),
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('Edit'),
        ),
        TextButton.icon(
          onPressed: () => _confirmDeleteShare(context, provider, transaction),
          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
          label: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
      accentColor: showVesting ? Colors.blue : Colors.green,
    );
  }

  Future<void> _confirmDeleteShare(
    BuildContext context,
    CoreCapTableProvider provider,
    Transaction transaction,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Share Grant?'),
        content: const Text(
          'This will permanently delete this share grant and any associated vesting schedule. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Delete associated vesting schedule if exists
      final vestingSchedule = provider.vestingSchedules
          .cast<VestingSchedule?>()
          .firstWhere(
            (vs) => vs?.transactionId == transaction.id,
            orElse: () => null,
          );
      if (vestingSchedule != null) {
        provider.deleteVestingSchedule(vestingSchedule.id);
      }

      // Delete the transaction
      provider.deleteTransactionById(transaction.id);

      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Share grant deleted')));
    }
  }

  Future<void> _showVestingSharesDialog(
    BuildContext context,
    CoreCapTableProvider provider, {
    Transaction? existingTransaction,
  }) async {
    final investors = provider.investors;
    final shareClasses = provider.shareClasses;
    final rounds = provider.rounds;

    if (investors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add investors first before granting shares'),
        ),
      );
      return;
    }

    if (shareClasses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add share classes first in Settings')),
      );
      return;
    }

    // Form state
    String? selectedInvestorId = existingTransaction?.investorId;
    String? selectedShareClassId =
        existingTransaction?.shareClassId ?? shareClasses.first.id;
    String? selectedRoundId = existingTransaction?.roundId;
    final sharesController = TextEditingController(
      text: existingTransaction?.numberOfShares.toString() ?? '',
    );
    final priceController = TextEditingController(
      text:
          existingTransaction?.pricePerShare.toString() ??
          provider.latestSharePrice.toString(),
    );
    DateTime grantDate = existingTransaction?.date ?? DateTime.now();

    // Vesting state
    bool hasVesting = false;
    int vestingMonths = 48;
    int cliffMonths = 12;
    VestingFrequency vestingFrequency = VestingFrequency.monthly;

    // Load existing vesting schedule if editing
    VestingSchedule? existingVesting;
    if (existingTransaction != null) {
      existingVesting = provider.vestingSchedules
          .cast<VestingSchedule?>()
          .firstWhere(
            (vs) => vs?.transactionId == existingTransaction.id,
            orElse: () => null,
          );
      if (existingVesting != null) {
        hasVesting = true;
        vestingMonths = existingVesting.vestingPeriodMonths;
        cliffMonths = existingVesting.cliffMonths;
        vestingFrequency = existingVesting.frequency;
      }
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          title: Text(
            existingTransaction == null
                ? 'Add Vesting Shares'
                : 'Edit Vesting Shares',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Investor dropdown
                AppDropdownField<String>(
                  labelText: 'Shareholder',
                  value: selectedInvestorId,
                  items: investors
                      .map(
                        (i) =>
                            DropdownMenuItem(value: i.id, child: Text(i.name)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedInvestorId = value),
                ),
                const SizedBox(height: 16),

                // Share class dropdown
                AppDropdownField<String>(
                  labelText: 'Share Class',
                  value: selectedShareClassId,
                  items: shareClasses
                      .map(
                        (sc) => DropdownMenuItem(
                          value: sc.id,
                          child: Text(sc.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedShareClassId = value),
                ),
                const SizedBox(height: 16),

                // Round dropdown (optional)
                AppDropdownField<String>(
                  labelText: 'Round (Optional)',
                  value: selectedRoundId,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None')),
                    ...rounds.map(
                      (r) => DropdownMenuItem(value: r.id, child: Text(r.name)),
                    ),
                  ],
                  onChanged: (value) => setState(() => selectedRoundId = value),
                ),
                const SizedBox(height: 16),

                // Number of shares
                AppTextField(
                  labelText: 'Number of Shares',
                  controller: sharesController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Price per share
                AppTextField(
                  labelText: 'Price per Share',
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  prefixText: '\$',
                ),
                const SizedBox(height: 16),

                // Grant date
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Grant Date'),
                  subtitle: Text(Formatters.date(grantDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: grantDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => grantDate = date);
                    }
                  },
                ),
                const Divider(height: 24),

                // Vesting toggle
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Add Vesting Schedule'),
                  value: hasVesting,
                  onChanged: (value) => setState(() => hasVesting = value),
                ),

                if (hasVesting) ...[
                  const SizedBox(height: 8),

                  // Vesting period
                  Row(
                    children: [
                      Expanded(
                        child: AppDropdownField<int>(
                          labelText: 'Vesting Period',
                          value: vestingMonths,
                          items: const [
                            DropdownMenuItem(value: 12, child: Text('1 year')),
                            DropdownMenuItem(value: 24, child: Text('2 years')),
                            DropdownMenuItem(value: 36, child: Text('3 years')),
                            DropdownMenuItem(value: 48, child: Text('4 years')),
                            DropdownMenuItem(value: 60, child: Text('5 years')),
                          ],
                          onChanged: (value) =>
                              setState(() => vestingMonths = value ?? 48),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppDropdownField<int>(
                          labelText: 'Cliff',
                          value: cliffMonths,
                          items: const [
                            DropdownMenuItem(value: 0, child: Text('No cliff')),
                            DropdownMenuItem(value: 6, child: Text('6 months')),
                            DropdownMenuItem(value: 12, child: Text('1 year')),
                            DropdownMenuItem(
                              value: 18,
                              child: Text('18 months'),
                            ),
                            DropdownMenuItem(value: 24, child: Text('2 years')),
                          ],
                          onChanged: (value) =>
                              setState(() => cliffMonths = value ?? 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Vesting frequency
                  AppDropdownField<VestingFrequency>(
                    labelText: 'Vesting Frequency',
                    value: vestingFrequency,
                    items: const [
                      DropdownMenuItem(
                        value: VestingFrequency.monthly,
                        child: Text('Monthly'),
                      ),
                      DropdownMenuItem(
                        value: VestingFrequency.quarterly,
                        child: Text('Quarterly'),
                      ),
                      DropdownMenuItem(
                        value: VestingFrequency.annually,
                        child: Text('Annually'),
                      ),
                    ],
                    onChanged: (value) => setState(
                      () =>
                          vestingFrequency = value ?? VestingFrequency.monthly,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (selectedInvestorId == null ||
                    selectedShareClassId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select investor and share class'),
                    ),
                  );
                  return;
                }
                final shares = int.tryParse(sharesController.text);
                if (shares == null || shares <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid number of shares'),
                    ),
                  );
                  return;
                }
                Navigator.pop(context, true);
              },
              child: Text(existingTransaction == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final shares = int.parse(sharesController.text);
      final price = double.tryParse(priceController.text) ?? 0.0;

      if (existingTransaction != null) {
        // Update existing transaction
        final updatedTransaction = existingTransaction.copyWith(
          investorId: selectedInvestorId,
          shareClassId: selectedShareClassId,
          roundId: selectedRoundId,
          numberOfShares: shares,
          pricePerShare: price,
          date: grantDate,
        );

        // Find and remove old transaction, add updated one
        provider.deleteTransactionById(existingTransaction.id);
        provider.addTransaction(updatedTransaction);

        // Handle vesting schedule
        if (existingVesting != null) {
          provider.deleteVestingSchedule(existingVesting.id);
        }
        if (hasVesting) {
          final newVesting = VestingSchedule(
            transactionId: updatedTransaction.id,
            startDate: grantDate,
            vestingPeriodMonths: vestingMonths,
            cliffMonths: cliffMonths,
            frequency: vestingFrequency,
          );
          provider.addVestingSchedule(newVesting);
        }
      } else {
        // Create new transaction
        final transaction = Transaction(
          investorId: selectedInvestorId!,
          shareClassId: selectedShareClassId!,
          roundId: selectedRoundId,
          type: TransactionType.grant,
          numberOfShares: shares,
          pricePerShare: price,
          date: grantDate,
        );

        provider.addTransaction(transaction);

        // Create vesting schedule if enabled
        if (hasVesting) {
          final vestingSchedule = VestingSchedule(
            transactionId: transaction.id,
            startDate: grantDate,
            vestingPeriodMonths: vestingMonths,
            cliffMonths: cliffMonths,
            frequency: vestingFrequency,
          );
          provider.addVestingSchedule(vestingSchedule);
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              existingTransaction == null
                  ? 'Share grant added'
                  : 'Share grant updated',
            ),
          ),
        );
      }
    }
  }

  Widget _buildVestingTab(BuildContext context, CoreCapTableProvider provider) {
    // Gather all vesting items
    final vestingSchedules = provider.vestingSchedules;
    final milestones = provider.milestones;
    final hoursSchedules = provider.hoursVestingSchedules;
    final grantsWithVesting = provider.optionGrants
        .where((g) => g.vestingScheduleId != null)
        .toList();

    final totalItems =
        vestingSchedules.length +
        milestones.length +
        hoursSchedules.length +
        grantsWithVesting.length;

    if (totalItems == 0) {
      return const EmptyState(
        icon: Icons.schedule_outlined,
        title: 'No vesting schedules',
        subtitle:
            'Vesting schedules are created when granting options or allocating shares with vesting terms.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary stats
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SummaryCard(
                label: 'Time-Based',
                value: vestingSchedules.length.toString(),
                icon: Icons.schedule,
                color: Colors.blue,
              ),
              if (grantsWithVesting.isNotEmpty)
                SummaryCard(
                  label: 'Option Grants',
                  value: grantsWithVesting.length.toString(),
                  icon: Icons.card_giftcard,
                  color: Colors.orange,
                ),
              if (milestones.isNotEmpty)
                SummaryCard(
                  label: 'Milestone',
                  value: milestones.length.toString(),
                  icon: Icons.flag,
                  color: Colors.purple,
                ),
              if (hoursSchedules.isNotEmpty)
                SummaryCard(
                  label: 'Hours-Based',
                  value: hoursSchedules.length.toString(),
                  icon: Icons.access_time,
                  color: Colors.teal,
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Time-based vesting schedules
          if (vestingSchedules.isNotEmpty) ...[
            _buildVestingSectionHeader(
              context,
              'Time-Based Vesting',
              Icons.access_time,
              Colors.blue,
            ),
            const SizedBox(height: 8),
            ...vestingSchedules.map((schedule) {
              final transaction = provider.transactions
                  .cast<Transaction?>()
                  .firstWhere(
                    (t) => t?.id == schedule.transactionId,
                    orElse: () => null,
                  );
              final investor = transaction != null
                  ? provider.getInvestorById(transaction.investorId)
                  : null;

              return _VestingListTile(
                title: investor?.name ?? 'Unknown',
                subtitle:
                    '${schedule.vestingPeriodMonths}mo with ${schedule.cliffMonths}mo cliff',
                progress: schedule.vestingPercentage / 100,
                color: Colors.blue,
                isTerminated: schedule.leaverStatus != LeaverStatus.active,
              );
            }),
            const SizedBox(height: 16),
          ],

          // Option grants with vesting
          if (grantsWithVesting.isNotEmpty) ...[
            _buildVestingSectionHeader(
              context,
              'Option Grant Vesting',
              Icons.card_giftcard,
              Colors.orange,
            ),
            const SizedBox(height: 8),
            ...grantsWithVesting.map((grant) {
              final investor = provider.getInvestorById(grant.investorId);
              final vestingPercent = provider.getOptionVestingPercent(grant);

              return _VestingListTile(
                title: investor?.name ?? 'Unknown',
                subtitle:
                    '${Formatters.compactNumber(grant.numberOfOptions)} options @ ${Formatters.currency(grant.strikePrice)}',
                progress: vestingPercent / 100,
                color: Colors.orange,
                isTerminated:
                    grant.status == OptionGrantStatus.cancelled ||
                    grant.status == OptionGrantStatus.forfeited,
              );
            }),
            const SizedBox(height: 16),
          ],

          // Milestone vesting
          if (milestones.isNotEmpty) ...[
            _buildVestingSectionHeader(
              context,
              'Milestone Vesting',
              Icons.flag,
              Colors.purple,
            ),
            const SizedBox(height: 8),
            ...milestones.map((milestone) {
              final investor = provider.getInvestorById(
                milestone.investorId ?? '',
              );

              return _VestingListTile(
                title: milestone.name,
                subtitle: investor?.name ?? 'Unknown investor',
                progress: milestone.progress,
                color: Colors.purple,
                isTerminated: milestone.isLapsed,
              );
            }),
            const SizedBox(height: 16),
          ],

          // Hours-based vesting
          if (hoursSchedules.isNotEmpty) ...[
            _buildVestingSectionHeader(
              context,
              'Hours-Based Vesting',
              Icons.timer,
              Colors.teal,
            ),
            const SizedBox(height: 8),
            ...hoursSchedules.map((hours) {
              final investor = provider.getInvestorById(hours.investorId);

              return _VestingListTile(
                title: investor?.name ?? 'Unknown',
                subtitle:
                    '${hours.hoursLogged.toStringAsFixed(0)}/${hours.totalHoursCommitment}h logged',
                progress: hours.progress,
                color: Colors.teal,
                isTerminated: false,
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildVestingSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Section header matching main pages (investors, rounds, etc.)
  SliverToBoxAdapter _buildSectionHeader(
    BuildContext context,
    String title,
    int count,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section header with additional badge (e.g., "Draft Round")
  SliverToBoxAdapter _buildSectionHeaderWithBadge(
    BuildContext context,
    String title,
    int count, {
    required String badgeText,
    required Color badgeColor,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  fontSize: 10,
                  color: HSLColor.fromColor(
                    badgeColor,
                  ).withLightness(0.35).toColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showWarrantDialog(
    BuildContext context,
    CoreCapTableProvider coreProvider,
    EsopProvider esopProvider, {
    Warrant? existingWarrant,
  }) async {
    final investors = coreProvider.investors;
    final shareClasses = coreProvider.shareClasses;
    final rounds = coreProvider.rounds;

    if (investors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add investors first before issuing warrants'),
        ),
      );
      return;
    }

    String? selectedInvestorId = existingWarrant?.investorId;
    String? selectedShareClassId = existingWarrant?.shareClassId;
    String? selectedRoundId = existingWarrant?.roundId;
    final numberOfWarrantsController = TextEditingController(
      text: existingWarrant?.numberOfWarrants.toString() ?? '',
    );
    final strikePriceController = TextEditingController(
      text:
          existingWarrant?.strikePrice.toString() ??
          coreProvider.latestSharePrice.toString(),
    );
    DateTime issueDate = existingWarrant?.issueDate ?? DateTime.now();
    DateTime expiryDate =
        existingWarrant?.expiryDate ??
        DateTime.now().add(const Duration(days: 365 * 5));
    final notesController = TextEditingController(
      text: existingWarrant?.notes ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          title: Text(
            existingWarrant == null ? 'Issue Warrant' : 'Edit Warrant',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedInvestorId,
                  decoration: const InputDecoration(labelText: 'Investor'),
                  items: investors
                      .map(
                        (inv) => DropdownMenuItem(
                          value: inv.id,
                          child: Text(inv.name),
                        ),
                      )
                      .toList(),
                  onChanged: existingWarrant == null
                      ? (value) => setState(() => selectedInvestorId = value)
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedShareClassId,
                  decoration: const InputDecoration(labelText: 'Share Class'),
                  items: shareClasses
                      .map(
                        (sc) => DropdownMenuItem(
                          value: sc.id,
                          child: Text(sc.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedShareClassId = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRoundId,
                  decoration: const InputDecoration(
                    labelText: 'Issued in Round (Optional)',
                    helperText:
                        'Select if this warrant is part of a funding round',
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('No round (standalone warrant)'),
                    ),
                    ...rounds.map(
                      (r) => DropdownMenuItem(
                        value: r.id,
                        child: Row(
                          children: [
                            Text(r.name),
                            if (!r.isClosed) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Draft',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                  onChanged: existingWarrant == null
                      ? (value) => setState(() => selectedRoundId = value)
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: numberOfWarrantsController,
                  decoration: const InputDecoration(
                    labelText: 'Number of Warrants',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: strikePriceController,
                  decoration: const InputDecoration(
                    labelText: 'Strike Price',
                    prefixText: '\$',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Issue Date'),
                  subtitle: Text(DateFormat.yMMMd().format(issueDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: issueDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => issueDate = picked);
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Expiry Date'),
                  subtitle: Text(DateFormat.yMMMd().format(expiryDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: expiryDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => expiryDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (selectedInvestorId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select an investor')),
                  );
                  return;
                }
                final numWarrants =
                    int.tryParse(numberOfWarrantsController.text) ?? 0;
                final strikePrice =
                    double.tryParse(strikePriceController.text) ?? 0;
                if (numWarrants <= 0 || strikePrice <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter valid values')),
                  );
                  return;
                }
                Navigator.pop(context, true);
              },
              child: Text(existingWarrant == null ? 'Issue' : 'Save'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final numWarrants = int.tryParse(numberOfWarrantsController.text) ?? 0;
      final strikePrice = double.tryParse(strikePriceController.text) ?? 0;

      if (existingWarrant == null) {
        // Determine status based on round state
        // If warrant is issued in a draft round, it should be pending
        WarrantStatus status = WarrantStatus.active;
        if (selectedRoundId != null) {
          final round = coreProvider.getRoundById(selectedRoundId!);
          if (round != null && !round.isClosed) {
            status = WarrantStatus.pending;
          }
        }

        // Create new warrant
        final warrant = Warrant(
          investorId: selectedInvestorId!,
          numberOfWarrants: numWarrants,
          strikePrice: strikePrice,
          issueDate: issueDate,
          expiryDate: expiryDate,
          shareClassId: selectedShareClassId,
          roundId: selectedRoundId,
          status: status,
          notes: notesController.text.isEmpty ? null : notesController.text,
        );
        await esopProvider.addWarrant(warrant);
      } else {
        // Update existing warrant
        final updated = existingWarrant.copyWith(
          numberOfWarrants: numWarrants,
          strikePrice: strikePrice,
          issueDate: issueDate,
          expiryDate: expiryDate,
          shareClassId: selectedShareClassId,
          notes: notesController.text.isEmpty ? null : notesController.text,
        );
        await esopProvider.updateWarrant(updated);
      }
    }
  }

  Future<void> _showExerciseWarrantDialog(
    BuildContext context,
    CoreCapTableProvider coreProvider,
    EsopProvider esopProvider,
    Warrant warrant,
  ) async {
    final exerciseCountController = TextEditingController(
      text: warrant.remainingWarrants.toString(),
    );
    DateTime exerciseDate = DateTime.now();
    final notesController = TextEditingController();

    final sharePrice = coreProvider.latestSharePrice;
    final isInTheMoney = warrant.isInTheMoney(sharePrice);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final numToExercise = int.tryParse(exerciseCountController.text) ?? 0;
          final exerciseCost = numToExercise * warrant.strikePrice;
          final exerciseValue = numToExercise * sharePrice;
          final exerciseGain = exerciseValue - exerciseCost;

          Widget infoRow(String label, String value, {Color? valueColor}) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: valueColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            title: const Text('Exercise Warrants'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  infoRow(
                    'Available',
                    Formatters.number(warrant.remainingWarrants),
                  ),
                  infoRow(
                    'Strike Price',
                    Formatters.currency(warrant.strikePrice),
                  ),
                  infoRow('Current Price', Formatters.currency(sharePrice)),
                  infoRow(
                    'Status',
                    isInTheMoney ? 'In the Money' : 'Out of the Money',
                    valueColor: isInTheMoney ? Colors.green : Colors.red,
                  ),
                  const Divider(height: 24),
                  TextFormField(
                    controller: exerciseCountController,
                    decoration: InputDecoration(
                      labelText: 'Number to Exercise',
                      helperText: 'Max: ${warrant.remainingWarrants}',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Exercise Date'),
                    subtitle: Text(DateFormat.yMMMd().format(exerciseDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: exerciseDate,
                        firstDate: warrant.issueDate,
                        lastDate: warrant.expiryDate,
                      );
                      if (picked != null) {
                        setState(() => exerciseDate = picked);
                      }
                    },
                  ),
                  const Divider(height: 24),
                  Text(
                    'Exercise Summary',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  infoRow('Exercise Cost', Formatters.currency(exerciseCost)),
                  infoRow('Market Value', Formatters.currency(exerciseValue)),
                  infoRow(
                    'Gain/Loss',
                    Formatters.currency(exerciseGain),
                    valueColor: exerciseGain >= 0 ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final num = int.tryParse(exerciseCountController.text) ?? 0;
                  if (num <= 0 || num > warrant.remainingWarrants) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invalid number of warrants'),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(context, true);
                },
                child: const Text('Exercise'),
              ),
            ],
          );
        },
      ),
    );

    if (result == true) {
      final numToExercise = int.tryParse(exerciseCountController.text) ?? 0;
      await esopProvider.exerciseWarrants(
        warrantId: warrant.id,
        numberOfWarrants: numToExercise,
        exerciseDate: exerciseDate,
        notes: notesController.text.isEmpty ? null : notesController.text,
      );
    }
  }

  Future<void> _confirmDeleteWarrant(
    BuildContext context,
    EsopProvider esopProvider,
    Warrant warrant,
  ) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete Warrant',
      message: 'Are you sure you want to delete this warrant?',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true) {
      await esopProvider.deleteWarrant(warrant.id);
    }
  }

  Widget _buildSummaryCards(BuildContext context, EsopProvider esopProvider) {
    final totalGranted = esopProvider.optionGrants.fold(
      0,
      (sum, g) => sum + g.numberOfOptions,
    );
    final totalExercised = esopProvider.totalOptionsExercised;
    final totalRemaining = esopProvider.totalOptionsGranted;
    final totalVested = esopProvider.totalVestedOptions;

    // Use vested intrinsic value for accurate representation
    final vestedIntrinsicValue = esopProvider.totalVestedIntrinsicValue;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SummaryCard(
          label: 'Total Granted',
          value: Formatters.compactNumber(totalGranted),
          icon: Icons.card_giftcard,
          color: Colors.blue,
        ),
        SummaryCard(
          label: 'Vested',
          value: Formatters.compactNumber(totalVested),
          icon: Icons.lock_open,
          color: Colors.indigo,
        ),
        SummaryCard(
          label: 'Exercised',
          value: Formatters.compactNumber(totalExercised),
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        SummaryCard(
          label: 'Outstanding',
          value: Formatters.compactNumber(totalRemaining),
          icon: Icons.pending,
          color: Colors.orange,
        ),
        SummaryCard(
          label: 'Vested Value',
          value: Formatters.compactCurrency(vestedIntrinsicValue),
          icon: Icons.trending_up,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildPoolManagement(
    BuildContext context,
    CoreCapTableProvider coreProvider,
    EsopProvider esopProvider,
  ) {
    final theme = Theme.of(context);
    final poolShares = esopProvider.esopPoolShares;
    final hasPool = esopProvider.esopPoolChanges.isNotEmpty;

    // If no pool exists yet, show creation prompt
    if (!hasPool) {
      return SectionCard(
        title: 'ESOP Pool',
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(
                Icons.card_giftcard_outlined,
                size: 48,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No ESOP Pool Created',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create an Employee Share Option Pool to grant options to employees, advisors, and contractors.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () =>
                    _showTopUpDialog(context, coreProvider, esopProvider),
                icon: const Icon(Icons.add),
                label: const Text('Create ESOP Pool'),
              ),
            ],
          ),
        ),
      );
    }

    final allocatedShares = esopProvider.allocatedEsopShares;
    final unallocatedShares = esopProvider.unallocatedEsopShares;
    final totalShares = coreProvider.totalCurrentShares;

    // Calculate percentages
    final poolPercent = totalShares > 0
        ? (poolShares / totalShares) * 100
        : 0.0;
    final allocatedPercent = poolShares > 0
        ? (allocatedShares / poolShares) * 100
        : 0.0;
    final targetPercent = esopProvider.esopPoolPercent;

    // Check if pool needs top-up
    final needsTopUp = poolPercent < targetPercent;
    final topUpNeeded = needsTopUp
        ? ((targetPercent / 100) * totalShares - poolShares).round()
        : 0;

    return SectionCard(
      title: 'ESOP Pool',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${poolPercent.toStringAsFixed(1)}% of cap table',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(width: 8),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 20),
            tooltip: 'Pool Settings',
            onPressed: () =>
                _showPoolSettingsDialog(context, coreProvider, esopProvider),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            tooltip: 'Add to Pool',
            onPressed: () =>
                _showTopUpDialog(context, coreProvider, esopProvider),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 24,
              child: Row(
                children: [
                  // Allocated portion
                  Expanded(
                    flex: allocatedShares > 0 ? allocatedShares : 0,
                    child: Container(
                      color: Colors.blue,
                      alignment: Alignment.center,
                      child: allocatedPercent > 15
                          ? Text(
                              'Allocated',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ),
                  // Unallocated portion
                  Expanded(
                    flex: unallocatedShares > 0 ? unallocatedShares : 1,
                    child: Container(
                      color: Colors.blue.shade200,
                      alignment: Alignment.center,
                      child: (100 - allocatedPercent) > 15
                          ? Text(
                              'Available',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.blue.shade900,
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Stats row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pool',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    Text(
                      Formatters.number(poolShares),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Allocated',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    Text(
                      Formatters.number(allocatedShares),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    Text(
                      Formatters.number(unallocatedShares),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Top-up suggestion if needed
          if (needsTopUp && topUpNeeded > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.amber.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pool is below target (${targetPercent.toStringAsFixed(0)}%). '
                      'Add ${Formatters.number(topUpNeeded)} shares to reach target.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showTopUpDialog(
                      context,
                      coreProvider,
                      esopProvider,
                      suggestedShares: topUpNeeded,
                    ),
                    child: const Text('Top Up'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showTopUpDialog(
    BuildContext context,
    CoreCapTableProvider coreProvider,
    EsopProvider esopProvider, {
    int? suggestedShares,
    EsopPoolChange? existingChange,
  }) {
    showDialog(
      context: context,
      builder: (context) => _PoolChangeDialog(
        coreProvider: coreProvider,
        esopProvider: esopProvider,
        suggestedShares: suggestedShares,
        existingChange: existingChange,
      ),
    );
  }

  void _showPoolSettingsDialog(
    BuildContext context,
    CoreCapTableProvider coreProvider,
    EsopProvider esopProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => _PoolSettingsDialog(
        coreProvider: coreProvider,
        esopProvider: esopProvider,
      ),
    );
  }

  /// Build a single grant card for use in SliverList
  Widget _buildGrantCard(
    BuildContext context,
    CoreCapTableProvider coreProvider,
    EsopProvider esopProvider,
    OptionGrant grant, {
    bool isHistory = false,
  }) {
    final investor = coreProvider.getInvestorById(grant.investorId);
    final shareClass = coreProvider.getShareClassById(grant.shareClassId);
    final vesting = grant.vestingScheduleId != null
        ? coreProvider.getVestingScheduleById(grant.vestingScheduleId!)
        : null;
    final currentPrice = coreProvider.latestSharePrice;
    final inTheMoney = currentPrice > grant.strikePrice;

    // Use provider methods for consistent vesting calculations
    final vestedPercent = coreProvider.getOptionVestingPercent(grant);
    final vestedOptions = coreProvider.getVestedOptionsForGrant(grant);
    final exercisableOptions = coreProvider.getExercisableOptionsForGrant(
      grant,
    );
    final vestedIntrinsicValue = coreProvider.getVestedIntrinsicValueForGrant(
      grant,
    );
    final canExercise = grant.canExercise && exercisableOptions > 0;

    return ExpandableCard(
      leading: InvestorAvatar(
        name: investor?.name ?? '?',
        type: investor?.type,
        radius: 18,
      ),
      title: investor?.name ?? 'Unknown',
      subtitle:
          '${Formatters.number(grant.numberOfOptions)} options @ ${Formatters.currency(grant.strikePrice)}',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: grant.status.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          grant.statusDisplayName,
          style: TextStyle(
            color: grant.status.color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chips: [
        InfoTag(
          label: 'Vested',
          value: '${vestedPercent.toStringAsFixed(0)}%',
          color: vestedPercent >= 100 ? Colors.green : Colors.orange,
        ),
        InfoTag(
          label: 'Exercised',
          value: Formatters.compactNumber(grant.exercisedCount),
          color: Colors.blue,
        ),
        InfoTag(
          label: 'Value',
          value: Formatters.compactCurrency(grant.intrinsicValue(currentPrice)),
          color: inTheMoney ? Colors.green : Colors.grey,
        ),
      ],
      expandedContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailRow(label: 'Share Class', value: shareClass?.name ?? 'Unknown'),
          DetailRow(
            label: 'Grant Date',
            value: Formatters.date(grant.grantDate),
          ),
          DetailRow(
            label: 'Expiry Date',
            value: Formatters.date(grant.expiryDate),
          ),
          const Divider(height: 16),
          DetailRow(
            label: 'Vested Options',
            value: Formatters.number(vestedOptions),
          ),
          DetailRow(
            label: 'Exercisable',
            value: Formatters.number(exercisableOptions),
          ),
          DetailRow(
            label: 'Exercised',
            value: Formatters.number(grant.exercisedCount),
          ),
          DetailRow(
            label: 'Remaining',
            value: Formatters.number(grant.remainingOptions),
          ),
          if (vesting != null) ...[
            const Divider(height: 16),
            DetailRow(
              label: 'Vesting Schedule',
              value:
                  '${vesting.vestingPeriodMonths ~/ 12}yr / ${vesting.cliffMonths}mo cliff',
            ),
            ProgressRow(
              label: 'Vesting Progress',
              progress: vestedPercent / 100,
              color: vestedPercent >= 100 ? Colors.green : Colors.orange,
            ),
          ],
          const Divider(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: inTheMoney
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  inTheMoney ? Icons.trending_up : Icons.trending_flat,
                  color: inTheMoney ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inTheMoney ? 'In The Money' : 'Out of Money',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: inTheMoney ? Colors.green : Colors.grey,
                        ),
                      ),
                      Text(
                        'Vested intrinsic value: ${Formatters.currency(vestedIntrinsicValue)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (canExercise)
          FilledButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => ExerciseOptionsDialog(
                  grant: grant,
                  coreProvider: coreProvider,
                  esopProvider: esopProvider,
                  maxExercisable: exercisableOptions,
                ),
              );
            },
            icon: const Icon(Icons.check_circle, size: 18),
            label: const Text('Exercise'),
          ),
        TextButton.icon(
          onPressed: grant.exercisedCount == 0
              ? () {
                  showDialog(
                    context: context,
                    builder: (ctx) => GrantOptionsDialog(
                      coreProvider: coreProvider,
                      esopProvider: esopProvider,
                      valuationsProvider: context.read<ValuationsProvider>(),
                      grant: grant,
                    ),
                  );
                }
              : null,
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('Edit'),
        ),
        TextButton.icon(
          onPressed: () async {
            final confirmed = await showConfirmDialog(
              context: context,
              title: 'Delete Grant',
              message: 'Are you sure you want to delete this option grant?',
            );
            if (confirmed && context.mounted) {
              await esopProvider.deleteOptionGrant(grant.id);
              if (context.mounted) {
                showSuccessSnackbar(context, 'Option grant deleted');
              }
            }
          },
          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
          label: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
      accentColor: grant.status.color,
    );
  }

  IconData _getStatusIcon(OptionGrantStatus status) {
    switch (status) {
      case OptionGrantStatus.pending:
        return Icons.pending_outlined;
      case OptionGrantStatus.active:
        return Icons.card_giftcard;
      case OptionGrantStatus.pendingExercise:
        return Icons.hourglass_empty;
      case OptionGrantStatus.partiallyExercised:
        return Icons.timelapse;
      case OptionGrantStatus.fullyExercised:
        return Icons.check_circle;
      case OptionGrantStatus.expired:
        return Icons.schedule;
      case OptionGrantStatus.cancelled:
      case OptionGrantStatus.forfeited:
        return Icons.cancel;
    }
  }

  void _showGrantDialog(
    BuildContext context,
    CoreCapTableProvider coreProvider,
    EsopProvider esopProvider,
    ValuationsProvider valuationsProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => GrantOptionsDialog(
        coreProvider: coreProvider,
        esopProvider: esopProvider,
        valuationsProvider: valuationsProvider,
      ),
    );
  }

  void _showGrantDetails(
    BuildContext context,
    CoreCapTableProvider coreProvider,
    EsopProvider esopProvider,
    OptionGrant grant,
  ) {
    showDialog(
      context: context,
      builder: (context) => GrantDetailsDialog(
        grant: grant,
        coreProvider: coreProvider,
        esopProvider: esopProvider,
      ),
    );
  }
}

/// Compact dialog for granting/editing options
class GrantOptionsDialog extends StatefulWidget {
  final CoreCapTableProvider coreProvider;
  final EsopProvider esopProvider;
  final ValuationsProvider valuationsProvider;
  final OptionGrant? grant; // If provided, we're editing

  const GrantOptionsDialog({
    super.key,
    required this.coreProvider,
    required this.esopProvider,
    required this.valuationsProvider,
    this.grant,
  });

  // Compatibility getter - gradually migrate to use coreProvider/esopProvider directly
  CoreCapTableProvider get provider => coreProvider;

  @override
  State<GrantOptionsDialog> createState() => _GrantOptionsDialogState();
}

class _GrantOptionsDialogState extends State<GrantOptionsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _optionsController = TextEditingController();
  final _strikePriceController = TextEditingController();

  String? _selectedInvestorId;
  String? _selectedShareClassId;
  DateTime _grantDate = DateTime.now();
  DateTime _expiryDate = DateTime.now().add(
    const Duration(days: 3650),
  ); // 10 years
  bool _hasVesting = true;
  int _vestingMonths = 48;
  int _cliffMonths = 12;
  String? _strikePriceSourceText;

  bool get isEditing => widget.grant != null;

  @override
  void initState() {
    super.initState();

    if (widget.grant != null) {
      // Editing existing grant
      final g = widget.grant!;
      _selectedInvestorId = g.investorId;
      _selectedShareClassId = g.shareClassId;
      _optionsController.text = g.numberOfOptions.toString();
      _strikePriceController.text = g.strikePrice.toStringAsFixed(2);
      _grantDate = g.grantDate;
      _expiryDate = g.expiryDate;
      _hasVesting = g.vestingScheduleId != null;
      if (_hasVesting && g.vestingScheduleId != null) {
        final vesting = widget.provider.getVestingScheduleById(
          g.vestingScheduleId!,
        );
        if (vesting != null) {
          _vestingMonths = vesting.vestingPeriodMonths;
          _cliffMonths = vesting.cliffMonths;
        }
      }
    } else {
      // Try to calculate strike price from latest valuation
      final latestValuation = widget.valuationsProvider
          .getLatestValuationBeforeDate(DateTime.now());
      final totalShares = widget.provider.totalIssuedShares;

      if (latestValuation != null && totalShares > 0) {
        final impliedPrice = latestValuation.preMoneyValue / totalShares;
        _strikePriceController.text = impliedPrice.toStringAsFixed(2);
        _strikePriceSourceText =
            'Strike price from ${DateFormat.yMMMd().format(latestValuation.date)} valuation';
      } else {
        // Fallback to existing share price
        _strikePriceController.text = widget.provider.latestSharePrice
            .toStringAsFixed(2);
      }

      // Default to ESOP share class only if pool exists and has available shares
      final hasEsopPool = widget.provider.esopPoolChanges.isNotEmpty;
      final unallocatedEsop = widget.provider.unallocatedEsopShares;
      if (hasEsopPool && unallocatedEsop > 0) {
        final esopClass = widget.provider.shareClasses
            .where((s) => s.type == ShareClassType.esop)
            .firstOrNull;
        _selectedShareClassId = esopClass?.id;
      }

      // Show snackbar after dialog opens if we pre-filled from valuation
      if (_strikePriceSourceText != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_strikePriceSourceText!),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _optionsController.dispose();
    _strikePriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Allow all investors to receive options
    final investors = widget.provider.investors.toList();

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      title: Text(isEditing ? 'Edit Option Grant' : 'Grant Options'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipient (locked when editing)
                if (isEditing) ...[
                  _buildLockedInvestorTile(
                    widget.provider.getInvestorById(_selectedInvestorId!),
                  ),
                ] else ...[
                  AppDropdownField<String>(
                    value: _selectedInvestorId,
                    labelText: 'Recipient',
                    items: investors.map((i) {
                      return DropdownMenuItem(value: i.id, child: Text(i.name));
                    }).toList(),
                    validator: (v) => v == null ? 'Select recipient' : null,
                    onChanged: (v) => setState(() => _selectedInvestorId = v),
                  ),
                ],
                const SizedBox(height: 12),

                // Options and Strike Price row
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _optionsController,
                        labelText: 'Options',
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (int.tryParse(v) == null) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _strikePriceController,
                        labelText: 'Strike Price',
                        prefixText: '\$ ',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        suffix: ValuationWizardButton(
                          currentValuation: double.tryParse(
                            _strikePriceController.text,
                          ),
                          onValuationSelected: (value) {
                            final totalShares =
                                widget.provider.totalIssuedShares;
                            if (totalShares > 0) {
                              final impliedPrice = value / totalShares;
                              setState(() {
                                _strikePriceController.text = impliedPrice
                                    .toStringAsFixed(2);
                              });
                            }
                          },
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (double.tryParse(v) == null) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Share class
                _buildShareClassDropdown(),
                const SizedBox(height: 12),

                // Dates row
                Row(
                  children: [
                    Expanded(
                      child: AppDateField(
                        value: _grantDate,
                        labelText: 'Grant Date',
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        onChanged: (date) => setState(() => _grantDate = date),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppDateField(
                        value: _expiryDate,
                        labelText: 'Expiry Date',
                        firstDate: _grantDate,
                        lastDate: DateTime(2100),
                        onChanged: (date) => setState(() => _expiryDate = date),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Vesting toggle
                AppSwitchField(
                  value: _hasVesting,
                  title: 'Add Vesting Schedule',
                  onChanged: (v) => setState(() => _hasVesting = v),
                ),

                if (_hasVesting) ...[
                  Row(
                    children: [
                      Expanded(
                        child: AppDropdownField<int>(
                          value: _vestingMonths,
                          labelText: 'Vesting Period',
                          items: [24, 36, 48, 60].map((m) {
                            return DropdownMenuItem(
                              value: m,
                              child: Text('${m ~/ 12} years'),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _vestingMonths = v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppDropdownField<int>(
                          value: _cliffMonths,
                          labelText: 'Cliff',
                          items: [0, 6, 12, 18, 24].map((m) {
                            return DropdownMenuItem(
                              value: m,
                              child: Text(m == 0 ? 'None' : '$m months'),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _cliffMonths = v!),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        const DialogCancelButton(),
        DialogPrimaryButton(
          onPressed: _save,
          label: isEditing ? 'Save' : 'Grant',
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedInvestorId == null || _selectedShareClassId == null) return;

    // Safety check: prevent ESOP grant if no pool exists
    final selectedClass = widget.provider.getShareClassById(
      _selectedShareClassId!,
    );
    if (selectedClass?.type == ShareClassType.esop) {
      final hasEsopPool = widget.provider.esopPoolChanges.isNotEmpty;
      if (!hasEsopPool) {
        showErrorSnackbar(
          context,
          'Cannot grant options: ESOP pool has not been created',
        );
        return;
      }
    }

    final options = int.parse(_optionsController.text);
    final strikePrice = double.parse(_strikePriceController.text);

    if (isEditing) {
      // Update existing grant
      final existingGrant = widget.grant!;

      // Update vesting if needed
      String? vestingId = existingGrant.vestingScheduleId;
      if (_hasVesting && vestingId != null) {
        final existingVesting = widget.provider.getVestingScheduleById(
          vestingId,
        );
        if (existingVesting != null) {
          await widget.provider.updateVestingSchedule(
            VestingSchedule(
              id: vestingId,
              transactionId: existingVesting.transactionId,
              startDate: _grantDate,
              vestingPeriodMonths: _vestingMonths,
              cliffMonths: _cliffMonths,
            ),
          );
        }
      } else if (_hasVesting && vestingId == null) {
        // Create new vesting
        final vesting = VestingSchedule(
          transactionId: '',
          startDate: _grantDate,
          vestingPeriodMonths: _vestingMonths,
          cliffMonths: _cliffMonths,
        );
        await widget.provider.addVestingSchedule(vesting);
        vestingId = vesting.id;
      } else if (!_hasVesting && vestingId != null) {
        // Remove vesting
        await widget.provider.deleteVestingSchedule(vestingId);
        vestingId = null;
      }

      final updatedGrant = existingGrant.copyWith(
        investorId: _selectedInvestorId,
        shareClassId: _selectedShareClassId,
        numberOfOptions: options,
        strikePrice: strikePrice,
        grantDate: _grantDate,
        expiryDate: _expiryDate,
        vestingScheduleId: vestingId,
      );

      await widget.esopProvider.updateOptionGrant(updatedGrant);

      if (mounted) {
        Navigator.pop(context);
        showSuccessSnackbar(context, 'Option grant updated');
      }
    } else {
      // Create new grant
      String? vestingId;
      if (_hasVesting) {
        final vesting = VestingSchedule(
          transactionId: '', // Will be linked later if needed
          startDate: _grantDate,
          vestingPeriodMonths: _vestingMonths,
          cliffMonths: _cliffMonths,
        );
        await widget.provider.addVestingSchedule(vesting);
        vestingId = vesting.id;
      }

      // Create the option grant
      final grant = OptionGrant(
        investorId: _selectedInvestorId!,
        shareClassId: _selectedShareClassId!,
        numberOfOptions: options,
        strikePrice: strikePrice,
        grantDate: _grantDate,
        expiryDate: _expiryDate,
        vestingScheduleId: vestingId,
      );

      await widget.esopProvider.addOptionGrant(grant);

      if (mounted) {
        Navigator.pop(context);
        showSuccessSnackbar(
          context,
          'Granted ${Formatters.number(options)} options',
        );
      }
    }
  }

  Widget _buildShareClassDropdown() {
    final unallocatedEsop = widget.provider.unallocatedEsopShares;
    final hasEsopPool = widget.provider.esopPoolChanges.isNotEmpty;
    final requestedOptions = int.tryParse(_optionsController.text) ?? 0;

    // Calculate available ESOP for this grant (in edit mode, add back current grant)
    int availableForGrant = unallocatedEsop;
    if (isEditing && widget.grant != null) {
      final currentGrant = widget.grant!;
      final currentShareClass = widget.provider.getShareClassById(
        currentGrant.shareClassId,
      );
      if (currentShareClass?.type == ShareClassType.esop) {
        availableForGrant += currentGrant.numberOfOptions;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppDropdownField<String>(
          value: _selectedShareClassId,
          labelText: 'Share Class',
          items: widget.provider.shareClasses.map((s) {
            final isEsop = s.type == ShareClassType.esop;
            final isDisabled =
                isEsop && (!hasEsopPool || availableForGrant <= 0);

            return DropdownMenuItem(
              value: s.id,
              enabled: !isDisabled,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      s.name,
                      style: isDisabled
                          ? TextStyle(color: Colors.grey.shade400)
                          : null,
                    ),
                  ),
                  if (isEsop && hasEsopPool)
                    Text(
                      '(${Formatters.number(availableForGrant)} available)',
                      style: TextStyle(
                        fontSize: 12,
                        color: availableForGrant > 0
                            ? Colors.grey.shade600
                            : Colors.red.shade400,
                      ),
                    ),
                  if (isEsop && !hasEsopPool)
                    Text(
                      '(no pool)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade400,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
          validator: (v) {
            if (v == null) return 'Select share class';
            // Check if ESOP selected and validate pool
            final selectedClass = widget.provider.getShareClassById(v);
            if (selectedClass?.type == ShareClassType.esop) {
              if (!hasEsopPool) {
                return 'ESOP pool has not been created';
              }
              if (requestedOptions > availableForGrant) {
                return 'Insufficient ESOP pool (${Formatters.number(availableForGrant)} available)';
              }
            }
            return null;
          },
          onChanged: (v) {
            final selectedClass = v != null
                ? widget.provider.getShareClassById(v)
                : null;
            // Show warning if selecting ESOP with insufficient pool
            if (selectedClass?.type == ShareClassType.esop) {
              if (!hasEsopPool) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Please create an ESOP pool first before granting options',
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
                return; // Don't update selection
              }
            }
            setState(() => _selectedShareClassId = v);
          },
        ),
        // Show warning if ESOP selected with insufficient pool
        if (_selectedShareClassId != null) ...[
          Builder(
            builder: (context) {
              final selectedClass = widget.provider.getShareClassById(
                _selectedShareClassId!,
              );
              if (selectedClass?.type == ShareClassType.esop) {
                if (requestedOptions > availableForGrant &&
                    requestedOptions > 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: InfoBox.warning(
                      text:
                          'Requested options (${Formatters.number(requestedOptions)}) exceed available ESOP pool (${Formatters.number(availableForGrant)}). Please reduce the number or top up the pool.',
                      compact: true,
                    ),
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ],
    );
  }

  Widget _buildLockedInvestorTile(Investor? investor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          InvestorAvatar(
            name: investor?.name ?? '?',
            type: investor?.type,
            radius: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  investor?.name ?? 'Unknown',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Recipient',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact dialog for viewing grant details
class GrantDetailsDialog extends StatelessWidget {
  final OptionGrant grant;
  final CoreCapTableProvider coreProvider;
  final EsopProvider esopProvider;

  const GrantDetailsDialog({
    super.key,
    required this.grant,
    required this.coreProvider,
    required this.esopProvider,
  });

  // Compatibility getter
  CoreCapTableProvider get provider => coreProvider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final investor = provider.getInvestorById(grant.investorId);
    final shareClass = provider.getShareClassById(grant.shareClassId);
    final vesting = grant.vestingScheduleId != null
        ? provider.getVestingScheduleById(grant.vestingScheduleId!)
        : null;
    final currentPrice = provider.latestSharePrice;
    final inTheMoney = currentPrice > grant.strikePrice;

    // Use provider methods for consistent vesting calculations
    final vestedPercent = provider.getOptionVestingPercent(grant);
    final vestedOptions = provider.getVestedOptionsForGrant(grant);
    final exercisableOptions = provider.getExercisableOptionsForGrant(grant);
    final vestedIntrinsicValue = provider.getVestedIntrinsicValueForGrant(
      grant,
    );
    final canExercise = grant.canExercise && exercisableOptions > 0;

    // Get linked transaction if any
    final exerciseTransaction = grant.exerciseTransactionId != null
        ? provider.getTransactionById(grant.exerciseTransactionId!)
        : null;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      title: const Text('Option Grant Details'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grant info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InvestorAvatar(
                          name: investor?.name ?? '?',
                          type: investor?.type,
                          radius: 14,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          investor?.name ?? 'Unknown',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: grant.status.color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            grant.statusDisplayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DetailRow(
                      label: 'Options Granted',
                      value: Formatters.number(grant.numberOfOptions),
                    ),
                    DetailRow(
                      label: 'Strike Price',
                      value: Formatters.currency(grant.strikePrice),
                    ),
                    DetailRow(
                      label: 'Share Class',
                      value: shareClass?.name ?? 'Unknown',
                    ),
                    DetailRow(
                      label: 'Grant Date',
                      value: Formatters.date(grant.grantDate),
                    ),
                    DetailRow(
                      label: 'Expiry Date',
                      value: Formatters.date(grant.expiryDate),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Status breakdown
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (vesting != null)
                      DetailRow(
                        label: 'Vested',
                        value:
                            '${vestedPercent.toStringAsFixed(0)}% (${Formatters.number(vestedOptions)} options)',
                      ),
                    DetailRow(
                      label: 'Exercised',
                      value: Formatters.number(grant.exercisedCount),
                    ),
                    DetailRow(
                      label: 'Exercisable',
                      value: Formatters.number(exercisableOptions),
                    ),
                    DetailRow(
                      label: 'Cancelled/Forfeited',
                      value: Formatters.number(grant.cancelledCount),
                    ),
                    DetailRow(
                      label: 'Remaining',
                      value: Formatters.number(grant.remainingOptions),
                    ),
                    if (vesting != null) ...[
                      const Divider(height: 16),
                      DetailRow(
                        label: 'Vesting',
                        value:
                            '${vesting.vestingPeriodMonths ~/ 12}yr / ${vesting.cliffMonths}mo cliff',
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Value
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: inTheMoney
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: inTheMoney
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      inTheMoney ? Icons.trending_up : Icons.trending_flat,
                      color: inTheMoney ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inTheMoney ? 'In The Money' : 'Out of Money',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: inTheMoney ? Colors.green : Colors.grey,
                            ),
                          ),
                          Text(
                            'Vested intrinsic value: ${Formatters.currency(vestedIntrinsicValue)}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Linked transactions
              if (exerciseTransaction != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Linked Transactions',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTransactionTile(context, exerciseTransaction),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        // Show Exercise button if there are exercisable options
        if (canExercise)
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => ExerciseOptionsDialog(
                  grant: grant,
                  coreProvider: coreProvider,
                  esopProvider: esopProvider,
                  maxExercisable: exercisableOptions,
                ),
              );
            },
            icon: const Icon(Icons.check_circle, size: 18),
            label: const Text('Exercise'),
          ),
        TextButton.icon(
          onPressed: (exerciseTransaction == null && grant.exercisedCount == 0)
              ? () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (ctx) => GrantOptionsDialog(
                      coreProvider: coreProvider,
                      esopProvider: esopProvider,
                      valuationsProvider: context.read<ValuationsProvider>(),
                      grant: grant,
                    ),
                  );
                }
              : null,
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('Edit'),
        ),
        DialogDeleteButton(
          onPressed: () async {
            final navigator = Navigator.of(context);
            final confirmed = await showConfirmDialog(
              context: context,
              title: 'Delete Grant',
              message: 'Are you sure you want to delete this option grant?',
            );
            if (confirmed && context.mounted) {
              await esopProvider.deleteOptionGrant(grant.id);
              navigator.pop();
              if (context.mounted) {
                showSuccessSnackbar(context, 'Option grant deleted');
              }
            }
          },
        ),
        const DialogCancelButton(label: 'Close'),
      ],
    );
  }

  Widget _buildTransactionTile(BuildContext context, Transaction txn) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (ctx) => _EditExerciseTransactionDialog(
            transaction: txn,
            grant: grant,
            coreProvider: coreProvider,
            esopProvider: esopProvider,
          ),
        );
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Exercise - ${Formatters.number(txn.numberOfShares)} shares',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    Formatters.date(txn.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit, size: 16, color: theme.colorScheme.outline),
          ],
        ),
      ),
    );
  }
}

/// Compact dialog for exercising options
class ExerciseOptionsDialog extends StatefulWidget {
  final OptionGrant grant;
  final CoreCapTableProvider coreProvider;
  final EsopProvider esopProvider;
  final int maxExercisable;

  // Compatibility getter
  CoreCapTableProvider get provider => coreProvider;

  const ExerciseOptionsDialog({
    super.key,
    required this.grant,
    required this.coreProvider,
    required this.esopProvider,
    required this.maxExercisable,
  });

  @override
  State<ExerciseOptionsDialog> createState() => _ExerciseOptionsDialogState();
}

class _ExerciseOptionsDialogState extends State<ExerciseOptionsDialog> {
  final _optionsController = TextEditingController();
  DateTime _exerciseDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _optionsController.text = widget.maxExercisable.toString();
  }

  @override
  void dispose() {
    _optionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final investor = widget.provider.getInvestorById(widget.grant.investorId);
    final options = int.tryParse(_optionsController.text) ?? 0;
    final totalCost = options * widget.grant.strikePrice;
    final currentValue = options * widget.provider.latestSharePrice;
    final gain = currentValue - totalCost;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      title: const Text('Exercise Options'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Grant info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InvestorAvatar(
                        name: investor?.name ?? '?',
                        type: investor?.type,
                        radius: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        investor?.name ?? 'Unknown',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Strike Price: ${Formatters.currency(widget.grant.strikePrice)}',
                  ),
                  Text(
                    'Exercisable: ${Formatters.number(widget.maxExercisable)} options',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Options to exercise
            AppTextField(
              controller: _optionsController,
              labelText: 'Options to Exercise',
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              suffix: TextButton(
                onPressed: () {
                  _optionsController.text = widget.maxExercisable.toString();
                  setState(() {});
                },
                child: const Text('All'),
              ),
            ),
            const SizedBox(height: 12),

            // Exercise date
            AppDateField(
              value: _exerciseDate,
              labelText: 'Exercise Date',
              firstDate: widget.grant.grantDate,
              lastDate: widget.grant.expiryDate,
              onChanged: (date) => setState(() => _exerciseDate = date),
            ),
            const SizedBox(height: 12),

            // Cost summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: gain > 0
                    ? Colors.green.withValues(alpha: 0.1)
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  DetailRow(
                    label: 'Exercise Cost',
                    value: Formatters.currency(totalCost),
                  ),
                  DetailRow(
                    label: 'Current Value',
                    value: Formatters.currency(currentValue),
                  ),
                  const Divider(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Gain/Loss',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${gain >= 0 ? '+' : ''}${Formatters.currency(gain)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: gain >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        const DialogCancelButton(),
        DialogPrimaryButton(
          onPressed: _exercise,
          label: 'Exercise',
          icon: Icons.check_circle,
        ),
      ],
    );
  }

  Future<void> _exercise() async {
    final options = int.tryParse(_optionsController.text) ?? 0;
    if (options <= 0 || options > widget.maxExercisable) {
      showErrorSnackbar(context, 'Invalid number of options');
      return;
    }

    final success = await widget.esopProvider.exerciseOptions(
      grantId: widget.grant.id,
      numberOfOptions: options,
      exerciseDate: _exerciseDate,
    );

    if (success && mounted) {
      Navigator.pop(context);
      showSuccessSnackbar(
        context,
        'Exercised ${Formatters.number(options)} options',
      );
    }
  }
}

/// Dialog for editing/deleting an exercise transaction
class _EditExerciseTransactionDialog extends StatefulWidget {
  final Transaction transaction;
  final OptionGrant grant;
  final CoreCapTableProvider coreProvider;
  final EsopProvider esopProvider;

  // Compatibility getter
  CoreCapTableProvider get provider => coreProvider;

  const _EditExerciseTransactionDialog({
    required this.transaction,
    required this.grant,
    required this.coreProvider,
    required this.esopProvider,
  });

  @override
  State<_EditExerciseTransactionDialog> createState() =>
      _EditExerciseTransactionDialogState();
}

class _EditExerciseTransactionDialogState
    extends State<_EditExerciseTransactionDialog> {
  late TextEditingController _sharesController;
  late DateTime _exerciseDate;

  @override
  void initState() {
    super.initState();
    _sharesController = TextEditingController(
      text: widget.transaction.numberOfShares.toString(),
    );
    _exerciseDate = widget.transaction.date;
  }

  @override
  void dispose() {
    _sharesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final investor = widget.provider.getInvestorById(widget.grant.investorId);
    final shares = int.tryParse(_sharesController.text) ?? 0;
    final totalCost = shares * widget.grant.strikePrice;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      title: const Text('Edit Exercise Transaction'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Grant info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InvestorAvatar(
                        name: investor?.name ?? '?',
                        type: investor?.type,
                        radius: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        investor?.name ?? 'Unknown',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Strike Price: ${Formatters.currency(widget.grant.strikePrice)}',
                  ),
                  Text(
                    'Original Grant: ${Formatters.number(widget.grant.numberOfOptions)} options',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Shares exercised
            AppTextField(
              controller: _sharesController,
              labelText: 'Shares (Options Exercised)',
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // Exercise date
            AppDateField(
              value: _exerciseDate,
              labelText: 'Exercise Date',
              firstDate: widget.grant.grantDate,
              lastDate: DateTime.now(),
              onChanged: (date) => setState(() => _exerciseDate = date),
            ),
            const SizedBox(height: 12),

            // Cost summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  DetailRow(
                    label: 'Exercise Cost',
                    value: Formatters.currency(totalCost),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        DialogDeleteButton(onPressed: _delete),
        const DialogCancelButton(),
        DialogPrimaryButton(onPressed: _save, label: 'Save'),
      ],
    );
  }

  Future<void> _save() async {
    final shares = int.tryParse(_sharesController.text) ?? 0;
    if (shares <= 0) {
      showErrorSnackbar(context, 'Invalid number of shares');
      return;
    }

    // Update the transaction
    final updated = widget.transaction.copyWith(
      numberOfShares: shares,
      date: _exerciseDate,
      totalAmount: shares * widget.grant.strikePrice,
    );

    await widget.provider.updateTransaction(updated);

    // Also update the grant's exercisedCount
    final difference = shares - widget.transaction.numberOfShares;
    if (difference != 0) {
      final updatedGrant = widget.grant.copyWith(
        exercisedCount: widget.grant.exercisedCount + difference,
      );
      await widget.esopProvider.updateOptionGrant(updatedGrant);
    }

    if (mounted) {
      Navigator.pop(context);
      showSuccessSnackbar(context, 'Transaction updated');
    }
  }

  Future<void> _delete() async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete Exercise Transaction',
      message: 'This will undo the exercise and restore the options. Continue?',
    );
    if (!confirmed) return;

    // Remove the transaction
    await widget.provider.deleteTransaction(widget.transaction.id);

    // Restore the options (reduce exercisedCount, change status)
    var newStatus = widget.grant.status;
    if (widget.grant.status == OptionGrantStatus.fullyExercised) {
      newStatus =
          widget.grant.exercisedCount - widget.transaction.numberOfShares > 0
          ? OptionGrantStatus.partiallyExercised
          : OptionGrantStatus.active;
    } else if (widget.grant.status == OptionGrantStatus.partiallyExercised) {
      if (widget.grant.exercisedCount - widget.transaction.numberOfShares <=
          0) {
        newStatus = OptionGrantStatus.active;
      }
    }

    final updatedGrant = widget.grant.copyWith(
      exercisedCount:
          widget.grant.exercisedCount - widget.transaction.numberOfShares,
      status: newStatus,
      exerciseTransactionId: null,
    );
    await widget.esopProvider.updateOptionGrant(updatedGrant);

    if (mounted) {
      Navigator.pop(context);
      showSuccessSnackbar(context, 'Exercise undone');
    }
  }
}

/// Dialog for adding/editing ESOP pool changes
class _PoolChangeDialog extends StatefulWidget {
  final CoreCapTableProvider coreProvider;
  final EsopProvider esopProvider;
  final EsopPoolChange? existingChange; // null = add mode, non-null = edit mode
  final int? suggestedShares;

  const _PoolChangeDialog({
    required this.coreProvider,
    required this.esopProvider,
    this.existingChange,
    this.suggestedShares,
  });

  bool get isEditMode => existingChange != null;

  @override
  State<_PoolChangeDialog> createState() => _PoolChangeDialogState();
}

class _PoolChangeDialogState extends State<_PoolChangeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _sharesController = TextEditingController();
  final _notesController = TextEditingController();
  late DateTime _selectedDate;
  bool _isSubtraction = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditMode) {
      // Edit mode - populate from existing
      final change = widget.existingChange!;
      _sharesController.text = change.absoluteShares.toString();
      _notesController.text = change.notes ?? '';
      _selectedDate = change.date;
      _isSubtraction = change.isReduction;
    } else {
      // Add mode
      _selectedDate = DateTime.now();
      if (widget.suggestedShares != null) {
        _sharesController.text = widget.suggestedShares.toString();
      }
    }
  }

  @override
  void dispose() {
    _sharesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate preview
    final inputShares = int.tryParse(_sharesController.text) ?? 0;
    final sharesDelta = _isSubtraction ? -inputShares : inputShares;
    final currentPool = widget.esopProvider.esopPoolShares;
    final totalShares = widget.coreProvider.totalCurrentShares;
    final isCreatingPool = widget.esopProvider.esopPoolChanges.isEmpty;

    // In edit mode, we need to subtract the old value first
    final oldDelta = widget.existingChange?.sharesDelta ?? 0;
    final netPoolChange = sharesDelta - oldDelta;
    final newPool = currentPool + netPoolChange;
    final newPoolPercent = totalShares > 0
        ? (newPool /
                  (totalShares + (newPool > currentPool ? netPoolChange : 0))) *
              100
        : 0.0;

    // Quick suggestions based on cap table
    final suggestion5pct = (totalShares * 0.05).round();
    final suggestion10pct = (totalShares * 0.10).round();
    final suggestion15pct = (totalShares * 0.15).round();

    // Determine dialog title
    String dialogTitle;
    if (widget.isEditMode) {
      dialogTitle = 'Edit Pool Change';
    } else if (isCreatingPool) {
      dialogTitle = 'Create ESOP Pool';
    } else {
      dialogTitle = 'Add to ESOP Pool';
    }

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      title: Text(dialogTitle),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info card (only show if pool exists)
                if (!isCreatingPool)
                  InfoBox.info(
                    text:
                        'Current pool: ${Formatters.number(currentPool)} shares',
                  ),
                if (!isCreatingPool) const SizedBox(height: 16),

                // Add or Subtract toggle (only show if pool already exists)
                if (!isCreatingPool)
                  AppSegmentedField<bool>(
                    selected: {_isSubtraction},
                    segments: const [
                      ButtonSegment(
                        value: false,
                        label: Text('Add'),
                        icon: Icon(Icons.add, size: 16),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text('Subtract'),
                        icon: Icon(Icons.remove, size: 16),
                      ),
                    ],
                    onSelectionChanged: (value) {
                      setState(() => _isSubtraction = value.first);
                    },
                  ),
                if (!isCreatingPool) const SizedBox(height: 16),

                // Quick suggestions (only for additions when creating or not subtracting)
                if (!_isSubtraction && !widget.isEditMode) ...[
                  QuickValueChips(
                    label: isCreatingPool
                        ? 'Suggested pool size (% of cap table):'
                        : 'Quick add (% of cap table):',
                    values: [
                      QuickValue(
                        '5% (${Formatters.number(suggestion5pct)})',
                        suggestion5pct,
                      ),
                      QuickValue(
                        '10% (${Formatters.number(suggestion10pct)})',
                        suggestion10pct,
                      ),
                      QuickValue(
                        '15% (${Formatters.number(suggestion15pct)})',
                        suggestion15pct,
                      ),
                    ],
                    onSelected: (value) => setState(() {
                      _sharesController.text = value.toString();
                    }),
                  ),
                  const SizedBox(height: 16),
                ],

                // Shares input
                AppTextField(
                  controller: _sharesController,
                  labelText: _isSubtraction
                      ? 'Shares to Remove'
                      : 'Shares to Add',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final shares = int.tryParse(v);
                    if (shares == null || shares <= 0) {
                      return 'Enter a valid number';
                    }
                    if (_isSubtraction &&
                        shares > widget.esopProvider.unallocatedEsopShares) {
                      return 'Cannot exceed unallocated shares (${widget.esopProvider.unallocatedEsopShares})';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date picker
                AppDateField(
                  value: _selectedDate,
                  labelText: 'Date',
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  onChanged: (date) => setState(() => _selectedDate = date),
                ),
                const SizedBox(height: 16),

                // Notes
                AppTextField(
                  controller: _notesController,
                  labelText: 'Notes (optional)',
                  hintText: 'e.g., Series A condition, Board resolution',
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Preview
                if (inputShares > 0)
                  PreviewBox(
                    title: widget.isEditMode ? 'After Update' : 'After Change',
                    color: _isSubtraction ? Colors.orange : Colors.green,
                    rows: [
                      PreviewRow(
                        'Pool',
                        '${Formatters.number(newPool)} shares',
                      ),
                      PreviewRow(
                        'Cap table %',
                        '${newPoolPercent.toStringAsFixed(1)}%',
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        const DialogCancelButton(),
        DialogPrimaryButton(
          onPressed: _save,
          label: widget.isEditMode
              ? 'Update'
              : (widget.esopProvider.esopPoolChanges.isEmpty
                    ? 'Create Pool'
                    : 'Save'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final inputShares = int.parse(_sharesController.text);
    final sharesDelta = _isSubtraction ? -inputShares : inputShares;
    final notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();

    if (widget.isEditMode) {
      // Update existing
      final updated = widget.existingChange!.copyWith(
        date: _selectedDate,
        sharesDelta: sharesDelta,
        notes: notes,
      );
      await widget.esopProvider.updateEsopPoolChange(updated);
    } else {
      // Create new
      final change = EsopPoolChange(
        date: _selectedDate,
        sharesDelta: sharesDelta,
        notes: notes,
      );
      await widget.esopProvider.addEsopPoolChange(change);
    }

    if (mounted) {
      Navigator.pop(context);
      showSuccessSnackbar(
        context,
        widget.isEditMode
            ? 'Pool change updated'
            : '${_isSubtraction ? "Removed" : "Added"} ${Formatters.number(inputShares)} shares ${_isSubtraction ? "from" : "to"} ESOP pool',
      );
    }
  }
}

/// Dialog to edit ESOP pool settings and view change history
class _PoolSettingsDialog extends StatefulWidget {
  final CoreCapTableProvider coreProvider;
  final EsopProvider esopProvider;

  const _PoolSettingsDialog({
    required this.coreProvider,
    required this.esopProvider,
  });

  @override
  State<_PoolSettingsDialog> createState() => _PoolSettingsDialogState();
}

class _PoolSettingsDialogState extends State<_PoolSettingsDialog> {
  late TextEditingController _targetPercentController;
  late EsopDilutionMethod _dilutionMethod;

  @override
  void initState() {
    super.initState();
    _targetPercentController = TextEditingController(
      text: widget.esopProvider.esopPoolPercent.toString(),
    );
    _dilutionMethod = widget.esopProvider.esopDilutionMethod;
  }

  @override
  void dispose() {
    _targetPercentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final changes = widget.esopProvider.esopPoolChanges;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      title: const Text('ESOP Pool Settings'),
      content: SizedBox(
        width: 500,
        height: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pool summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Pool Status',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Total Pool',
                      Formatters.number(widget.esopProvider.esopPoolShares),
                    ),
                    _buildInfoRow(
                      'Allocated (via grants)',
                      Formatters.number(
                        widget.esopProvider.allocatedEsopShares,
                      ),
                    ),
                    _buildInfoRow(
                      'Available',
                      Formatters.number(
                        widget.esopProvider.unallocatedEsopShares,
                      ),
                    ),
                    _buildInfoRow(
                      'Options Exercised',
                      Formatters.number(
                        widget.esopProvider.totalOptionsExercised,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Pool Change History
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pool Change History',
                    style: theme.textTheme.titleSmall,
                  ),
                  TextButton.icon(
                    onPressed: () => _addPoolChange(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (changes.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'No pool changes recorded yet',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: changes.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                    itemBuilder: (context, index) {
                      final change = changes[index];
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          change.isAddition
                              ? Icons.add_circle
                              : Icons.remove_circle,
                          color: change.isAddition
                              ? Colors.green
                              : Colors.orange,
                          size: 20,
                        ),
                        title: Row(
                          children: [
                            Text(
                              '${change.isAddition ? "+" : ""}${Formatters.number(change.sharesDelta)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: change.isAddition
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              Formatters.date(change.date),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                        subtitle:
                            change.notes != null && change.notes!.isNotEmpty
                            ? Text(
                                change.notes!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              tooltip: 'Edit',
                              onPressed: () => _editPoolChange(context, change),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 18),
                              tooltip: 'Delete',
                              onPressed: () =>
                                  _deletePoolChange(context, change),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),

              // Target percentage
              AppTextField(
                controller: _targetPercentController,
                labelText: 'Target Pool Percentage',
                suffixText: '%',
                hintText: 'Recommended: 10-15% for most startups',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 16),

              // Dilution method
              Text(
                'Dilution Calculation Method',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...EsopDilutionMethod.values.map((method) {
                return RadioListTile<EsopDilutionMethod>(
                  title: Text(_getMethodTitle(method)),
                  subtitle: Text(
                    _getMethodDescription(method),
                    style: theme.textTheme.bodySmall,
                  ),
                  value: method,
                  groupValue: _dilutionMethod,
                  onChanged: (v) => setState(() => _dilutionMethod = v!),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                );
              }),
            ],
          ),
        ),
      ),
      actions: [
        const DialogCancelButton(label: 'Close'),
        DialogPrimaryButton(onPressed: _save, label: 'Save Settings'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _addPoolChange(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) => _PoolChangeDialog(
        coreProvider: widget.coreProvider,
        esopProvider: widget.esopProvider,
      ),
    );
    if (mounted) setState(() {}); // Refresh the list
  }

  void _editPoolChange(BuildContext context, EsopPoolChange change) async {
    await showDialog(
      context: context,
      builder: (ctx) => _PoolChangeDialog(
        coreProvider: widget.coreProvider,
        esopProvider: widget.esopProvider,
        existingChange: change,
      ),
    );
    if (mounted) setState(() {}); // Refresh the list
  }

  void _deletePoolChange(BuildContext context, EsopPoolChange change) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete Pool Change?',
      message:
          'Remove ${change.isAddition ? "+" : ""}${Formatters.number(change.sharesDelta)} shares from ${Formatters.date(change.date)}?\n\n'
          'This will affect the total pool size.',
    );

    if (confirmed) {
      await widget.esopProvider.deleteEsopPoolChange(change.id);
      if (mounted && context.mounted) {
        setState(() {});
        showSuccessSnackbar(context, 'Pool change deleted');
      }
    }
  }

  String _getMethodTitle(EsopDilutionMethod method) {
    switch (method) {
      case EsopDilutionMethod.preRoundCap:
        return 'Pre-Round Cap (AU-style)';
      case EsopDilutionMethod.postRoundCap:
        return 'Post-Round Cap (US-style)';
      case EsopDilutionMethod.fixedShares:
        return 'Fixed Shares';
    }
  }

  String _getMethodDescription(EsopDilutionMethod method) {
    switch (method) {
      case EsopDilutionMethod.preRoundCap:
        return 'ESOP % based on pre-money cap table';
      case EsopDilutionMethod.postRoundCap:
        return 'ESOP % based on post-money cap table';
      case EsopDilutionMethod.fixedShares:
        return 'Fixed number of shares, no percentage';
    }
  }

  Future<void> _save() async {
    final targetPercent = double.tryParse(_targetPercentController.text) ?? 10;

    await widget.esopProvider.updateEsopSettings(
      targetPercent: targetPercent,
      dilutionMethod: _dilutionMethod,
    );

    if (mounted) {
      Navigator.pop(context);
      showSuccessSnackbar(context, 'ESOP settings updated');
    }
  }
}

class _VestingListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final Color color;
  final bool isTerminated;

  const _VestingListTile({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.color,
    this.isTerminated = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = isTerminated ? Colors.grey : color;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isTerminated
                              ? theme.colorScheme.outline
                              : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: effectiveColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: effectiveColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(effectiveColor),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
