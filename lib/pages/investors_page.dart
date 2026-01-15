import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/convertible_instrument.dart';
import '../models/investor.dart';
import '../models/option_grant.dart';
import '../models/transaction.dart';
import '../models/vesting_schedule.dart';
import '../providers/cap_table_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/avatars.dart';
import '../widgets/expandable_card.dart';
import '../widgets/dialogs.dart';
import '../widgets/form_fields.dart';
import '../widgets/transaction_editor.dart';
import 'options_page.dart';
import 'convertibles_page.dart';
import 'vesting_page.dart';

import '../widgets/stat_pill.dart';
import '../widgets/info_widgets.dart';
import '../utils/helpers.dart';

class InvestorsPage extends StatelessWidget {
  const InvestorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CapTableProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          body: provider.investors.isEmpty
              ? const EmptyState(
                  icon: Icons.people_outline,
                  title: 'No investors yet',
                  subtitle: 'Add your first investor to get started',
                )
              : _buildInvestorsList(context, provider),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showInvestorDialog(context, provider),
            icon: const Icon(Icons.person_add),
            label: const Text('Add Investor'),
          ),
        );
      },
    );
  }

  Widget _buildInvestorsList(BuildContext context, CapTableProvider provider) {
    // Sort by ownership percentage descending
    final sortedInvestors = List<Investor>.from(provider.investors)
      ..sort(
        (a, b) => provider
            .getOwnershipPercentage(b.id)
            .compareTo(provider.getOwnershipPercentage(a.id)),
      );

    // Group investors by status
    final active = sortedInvestors
        .where((i) => provider.getCurrentSharesByInvestor(i.id) > 0)
        .toList();
    final exited = sortedInvestors
        .where((i) => provider.hasInvestorExited(i.id))
        .toList();
    final noShares = sortedInvestors
        .where(
          (i) =>
              provider.getCurrentSharesByInvestor(i.id) == 0 &&
              !provider.hasInvestorExited(i.id),
        )
        .toList();

    return CustomScrollView(
      slivers: [
        // Summary header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                StatPill(
                  label: 'Active',
                  value: active.length.toString(),
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                if (exited.isNotEmpty)
                  StatPill(
                    label: 'Exited',
                    value: exited.length.toString(),
                    color: Colors.grey,
                  ),
                if (noShares.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  StatPill(
                    label: 'No Shares',
                    value: noShares.length.toString(),
                    color: Colors.orange,
                  ),
                ],
              ],
            ),
          ),
        ),

        // Active investors
        if (active.isNotEmpty) ...[
          _buildSectionHeader(context, 'Active Shareholders', active.length),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _InvestorCard(
                investor: active[index],
                provider: provider,
                onEdit: () => _showInvestorDialog(
                  context,
                  provider,
                  investor: active[index],
                ),
                onDelete: () =>
                    _confirmDelete(context, provider, active[index]),
                onSellShares: () =>
                    _showSellSharesDialog(context, provider, active[index]),
              ),
              childCount: active.length,
            ),
          ),
        ],

        // Exited investors
        if (exited.isNotEmpty) ...[
          _buildSectionHeader(context, 'Exited', exited.length),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _InvestorCard(
                investor: exited[index],
                provider: provider,
                onEdit: () => _showInvestorDialog(
                  context,
                  provider,
                  investor: exited[index],
                ),
                onDelete: () =>
                    _confirmDelete(context, provider, exited[index]),
              ),
              childCount: exited.length,
            ),
          ),
        ],

        // No shares investors
        if (noShares.isNotEmpty) ...[
          _buildSectionHeader(context, 'No Current Holdings', noShares.length),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _InvestorCard(
                investor: noShares[index],
                provider: provider,
                onEdit: () => _showInvestorDialog(
                  context,
                  provider,
                  investor: noShares[index],
                ),
                onDelete: () =>
                    _confirmDelete(context, provider, noShares[index]),
              ),
              childCount: noShares.length,
            ),
          ),
        ],

        // Bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

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

  Future<void> _showInvestorDialog(
    BuildContext context,
    CapTableProvider provider, {
    Investor? investor,
  }) async {
    final isEditing = investor != null;
    final nameController = TextEditingController(text: investor?.name ?? '');
    final emailController = TextEditingController(text: investor?.email ?? '');
    final phoneController = TextEditingController(text: investor?.phone ?? '');
    final companyController = TextEditingController(
      text: investor?.company ?? '',
    );
    final notesController = TextEditingController(text: investor?.notes ?? '');
    var selectedType = investor?.type ?? InvestorType.angel;
    var hasProRata = investor?.hasProRataRights ?? false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Edit Investor' : 'Add Investor'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width > 600
                  ? 500
                  : double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    controller: nameController,
                    labelText: 'Name *',
                    hintText: 'John Smith',
                    prefixIcon: Icons.person,
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  AppDropdownField<InvestorType>(
                    value: selectedType,
                    labelText: 'Investor Type',
                    helpKey: 'investors.investorType',
                    items: InvestorType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getTypeDisplayName(type)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedType = value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: emailController,
                    labelText: 'Email',
                    hintText: 'john@example.com',
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: phoneController,
                    labelText: 'Phone',
                    hintText: '+61 400 000 000',
                    prefixIcon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: companyController,
                    labelText: 'Company/Fund',
                    hintText: 'Acme Ventures',
                    prefixIcon: Icons.business,
                  ),
                  const SizedBox(height: 16),
                  AppSwitchField(
                    value: hasProRata,
                    title: 'Pro-rata Rights',
                    subtitle: 'Can maintain ownership in future rounds',
                    helpKey: 'investors.proRataRights',
                    onChanged: (value) {
                      setState(() => hasProRata = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: notesController,
                    labelText: 'Notes',
                    hintText: 'Additional information...',
                    prefixIcon: Icons.notes,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      final newInvestor = Investor(
        id: investor?.id,
        name: nameController.text,
        type: selectedType,
        email: emailController.text.isEmpty ? null : emailController.text,
        phone: phoneController.text.isEmpty ? null : phoneController.text,
        company: companyController.text.isEmpty ? null : companyController.text,
        hasProRataRights: hasProRata,
        notes: notesController.text.isEmpty ? null : notesController.text,
        createdAt: investor?.createdAt,
      );

      if (isEditing) {
        await provider.updateInvestor(newInvestor);
      } else {
        await provider.addInvestor(newInvestor);
      }
    }
  }

  String _getTypeDisplayName(InvestorType type) {
    switch (type) {
      case InvestorType.founder:
        return 'Founder';
      case InvestorType.angel:
        return 'Angel Investor';
      case InvestorType.vcFund:
        return 'VC Fund';
      case InvestorType.employee:
        return 'Employee';
      case InvestorType.advisor:
        return 'Advisor';
      case InvestorType.institution:
        return 'Institution';
      case InvestorType.other:
        return 'Other';
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    CapTableProvider provider,
    Investor investor,
  ) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete Investor',
      message:
          'Are you sure you want to delete ${investor.name}? '
          'This will also remove all their shareholdings.',
    );

    if (confirmed) {
      await provider.deleteInvestor(investor.id);
    }
  }

  Future<void> _showSellSharesDialog(
    BuildContext context,
    CapTableProvider provider,
    Investor investor,
  ) async {
    final currentShares = provider.getCurrentSharesByInvestor(investor.id);
    if (currentShares <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This investor has no shares to sell')),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => SellSharesDialog(
        investor: investor,
        provider: provider,
        maxShares: currentShares,
      ),
    );
  }
}

/// Expandable investor card with transaction list
class _InvestorCard extends StatefulWidget {
  final Investor investor;
  final CapTableProvider provider;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onSellShares;

  const _InvestorCard({
    required this.investor,
    required this.provider,
    required this.onEdit,
    required this.onDelete,
    this.onSellShares,
  });

  @override
  State<_InvestorCard> createState() => _InvestorCardState();
}

class _InvestorCardState extends State<_InvestorCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = widget.provider;
    final investor = widget.investor;
    final currentShares = provider.getCurrentSharesByInvestor(investor.id);
    final originalShares = provider.getSharesByInvestor(investor.id);
    final ownership = provider.getOwnershipPercentage(investor.id);
    final invested = provider.getInvestmentByInvestor(investor.id);
    final value = provider.getShareValueByInvestor(investor.id);
    final hasExited = provider.hasInvestorExited(investor.id);
    final hasSoldSome = currentShares < originalShares && currentShares > 0;
    final transactions = provider.getTransactionsByInvestor(investor.id);
    final optionGrants = provider.getOptionGrantsByInvestor(investor.id);
    final convertibles = provider.getConvertiblesByInvestor(investor.id);

    // Get vesting schedules for this investor's transactions
    final investorTransactionIds = transactions.map((t) => t.id).toSet();
    final vestingSchedules = provider.vestingSchedules
        .where((v) => investorTransactionIds.contains(v.transactionId))
        .toList();
    final hasActiveVesting = vestingSchedules.any(
      (v) => v.leaverStatus == LeaverStatus.active && v.vestingPercentage < 100,
    );
    final hasActiveOptions = optionGrants.any(
      (g) =>
          g.status == OptionGrantStatus.active ||
          g.status == OptionGrantStatus.partiallyExercised,
    );
    final hasActiveConvertibles = convertibles.any(
      (c) => c.status == ConvertibleStatus.outstanding,
    );

    // Status tag
    Widget? statusTag;
    if (hasExited) {
      statusTag = InfoTag(label: 'Exited', color: Colors.grey);
    } else if (hasSoldSome) {
      statusTag = InfoTag(label: 'Partial Sale', color: Colors.orange);
    }

    return ExpandableCard(
      leading: InvestorAvatar(
        name: investor.name,
        type: investor.type,
        radius: 20,
      ),
      title: investor.name,
      subtitle: investor.typeDisplayName,
      trailing: hasExited
          ? Icon(Icons.exit_to_app, color: theme.colorScheme.outline)
          : Text(
              Formatters.percent(ownership),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
      chips: [
        // Row 1: Shares and Invested info
        if (currentShares > 0)
          InfoTag(
            label: 'Shares',
            value: Formatters.compactNumber(currentShares),
            icon: Icons.pie_chart_outline,
          ),
        if (invested > 0)
          InfoTag(
            label: 'Invested',
            value: Formatters.compactCurrency(invested),
            icon: Icons.attach_money,
            color: Colors.blue,
          ),
      ],
      badges: [
        // Row 2: Status badges (always below)
        if (investor.hasProRataRights)
          InfoTag(label: 'Pro-rata', icon: Icons.verified, color: Colors.green),
        if (hasActiveVesting)
          InfoTag(label: 'Vesting', icon: Icons.schedule, color: Colors.indigo),
        if (hasActiveOptions)
          InfoTag(
            label: 'Options',
            icon: Icons.workspace_premium,
            color: Colors.orange,
          ),
        if (hasActiveConvertibles)
          InfoTag(
            label: 'Convertibles',
            icon: Icons.sync_alt,
            color: Colors.purple,
          ),
        if (statusTag != null) statusTag,
      ],
      expandedContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (currentShares > 0) ...[
            DetailRow(
              label: 'Current Shares',
              value: Formatters.number(currentShares),
            ),
            // Show vested/unvested breakdown if investor has vesting schedules
            if (hasActiveVesting) ...[
              Builder(
                builder: (context) {
                  final vestedShares = provider.getVestedSharesByInvestor(
                    investor.id,
                  );
                  final unvestedShares = provider.getUnvestedSharesByInvestor(
                    investor.id,
                  );
                  final vestedValue = provider.getVestedValueByInvestor(
                    investor.id,
                  );
                  final unvestedValue = provider.getUnvestedValueByInvestor(
                    investor.id,
                  );

                  return Column(
                    children: [
                      DetailRow(
                        label: '  └ Vested',
                        value: Formatters.number(vestedShares),
                      ),
                      DetailRow(
                        label: '  └ Unvested',
                        value: Formatters.number(unvestedShares),
                      ),
                      DetailRow(
                        label: 'Ownership',
                        value: Formatters.percent(ownership),
                        highlight: true,
                      ),
                      DetailRow(
                        label: 'Total Value',
                        value: Formatters.currency(value),
                      ),
                      DetailRow(
                        label: '  └ Vested Value',
                        value: Formatters.currency(vestedValue),
                      ),
                      DetailRow(
                        label: '  └ Unvested Value',
                        value: Formatters.currency(unvestedValue),
                      ),
                    ],
                  );
                },
              ),
            ] else ...[
              DetailRow(
                label: 'Ownership',
                value: Formatters.percent(ownership),
                highlight: true,
              ),
              DetailRow(
                label: 'Current Value',
                value: Formatters.currency(value),
              ),
            ],
          ],
          if (invested > 0)
            DetailRow(
              label: 'Total Invested',
              value: Formatters.currency(invested),
            ),
          if (originalShares != currentShares && originalShares > 0)
            DetailRow(
              label: 'Original Shares',
              value: Formatters.number(originalShares),
            ),

          // Contact info
          if (investor.email != null || investor.phone != null) ...[
            const Divider(height: 24),
            if (investor.email != null)
              DetailRow(label: 'Email', value: investor.email!),
            if (investor.phone != null)
              DetailRow(label: 'Phone', value: investor.phone!),
          ],
          if (investor.company != null)
            DetailRow(label: 'Company', value: investor.company!),

          // Vesting Schedules section
          if (vestingSchedules.isNotEmpty) ...[
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vesting Schedules',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${vestingSchedules.length} schedules',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...vestingSchedules.map(
              (schedule) => _buildVestingItem(schedule, provider, context),
            ),
          ],

          // Option Grants section
          if (optionGrants.isNotEmpty) ...[
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Option Grants',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${optionGrants.length} grants',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...optionGrants.map(
              (grant) => _buildOptionGrantItem(grant, provider, context),
            ),
          ],

          // Convertibles section
          if (convertibles.isNotEmpty) ...[
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Convertibles',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${convertibles.length} instruments',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...convertibles.map(
              (conv) => _buildConvertibleItem(conv, provider, context),
            ),
          ],

          // Transaction history section
          if (transactions.isNotEmpty) ...[
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction History',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${transactions.length} transactions',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...transactions.map((txn) => _buildTransactionItem(txn, provider)),
          ],
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: widget.onEdit,
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Edit'),
        ),
        if (widget.onSellShares != null)
          TextButton.icon(
            onPressed: widget.onSellShares,
            icon: const Icon(Icons.sell_outlined, size: 18),
            label: const Text('Sell'),
          ),
        TextButton.icon(
          onPressed: widget.onDelete,
          icon: Icon(
            Icons.delete_outline,
            size: 18,
            color: theme.colorScheme.error,
          ),
          label: Text(
            'Delete',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
      ],
    );
  }

  Widget _buildVestingItem(
    VestingSchedule schedule,
    CapTableProvider provider,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final transaction = provider.getTransactionById(schedule.transactionId);
    final round = transaction?.roundId != null
        ? provider.getRoundById(transaction!.roundId!)
        : null;

    final isActive = schedule.leaverStatus == LeaverStatus.active;
    final isFullyVested = schedule.vestingPercentage >= 100;
    final color = isFullyVested
        ? Colors.green
        : isActive
        ? Colors.indigo
        : Colors.grey;

    final vestedShares = transaction != null
        ? (transaction.numberOfShares * schedule.vestingPercentage / 100)
              .round()
        : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => showDialog(
          context: context,
          builder: (context) =>
              TimeBasedDetailDialog(schedule: schedule, provider: provider),
        ),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.schedule, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${Formatters.number(vestedShares)} / ${Formatters.number(transaction?.numberOfShares ?? 0)} Shares',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isFullyVested
                                ? 'Vested'
                                : '${schedule.vestingPercentage.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${round?.name ?? 'Unknown Round'} • ${schedule.vestingPeriodMonths ~/ 12}yr ${schedule.cliffMonths}mo cliff • ${schedule.type.name}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionGrantItem(
    OptionGrant grant,
    CapTableProvider provider,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final shareClass = provider.getShareClassById(grant.shareClassId);

    // Use provider methods for consistent vesting calculations
    final vestedPercent = provider.getOptionVestingPercent(grant);

    final isActive =
        grant.status == OptionGrantStatus.active ||
        grant.status == OptionGrantStatus.partiallyExercised;
    final color = isActive ? Colors.blue : Colors.grey;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => _showOptionGrantDetails(context, provider, grant),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.card_giftcard, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${Formatters.number(grant.numberOfOptions)} Options',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            grant.statusDisplayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${shareClass?.name ?? 'Unknown'} @ ${Formatters.currency(grant.strikePrice)} • ${vestedPercent.toStringAsFixed(0)}% vested',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConvertibleItem(
    ConvertibleInstrument conv,
    CapTableProvider provider,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final isSafe = conv.type == ConvertibleType.safe;
    final isOutstanding = conv.status == ConvertibleStatus.outstanding;
    final color = isOutstanding
        ? (isSafe ? Colors.purple : Colors.teal)
        : Colors.grey;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => _showConvertibleDetails(context, provider, conv),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  isSafe ? Icons.flash_on : Icons.description,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${conv.typeDisplayName} • ${Formatters.currency(conv.principalAmount)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            conv.statusDisplayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _buildConvertibleTermsSummary(conv),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }

  String _buildConvertibleTermsSummary(ConvertibleInstrument conv) {
    final parts = <String>[];
    if (conv.valuationCap != null) {
      parts.add('Cap: ${Formatters.compactCurrency(conv.valuationCap!)}');
    }
    if (conv.discountPercent != null) {
      parts.add('${(conv.discountPercent! * 100).toStringAsFixed(0)}% disc');
    }
    if (conv.interestRate != null) {
      parts.add('${(conv.interestRate! * 100).toStringAsFixed(1)}% int');
    }
    return parts.isEmpty ? 'No terms specified' : parts.join(' • ');
  }

  void _showOptionGrantDetails(
    BuildContext context,
    CapTableProvider provider,
    OptionGrant grant,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => GrantDetailsDialog(grant: grant, provider: provider),
    );
  }

  void _showConvertibleDetails(
    BuildContext context,
    CapTableProvider provider,
    ConvertibleInstrument convertible,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => ConvertibleDetailsDialog(
        convertible: convertible,
        provider: provider,
      ),
    );
  }

  Widget _buildTransactionItem(Transaction txn, CapTableProvider provider) {
    final theme = Theme.of(context);
    final shareClass = provider.getShareClassById(txn.shareClassId);
    final round = txn.roundId != null
        ? provider.getRoundById(txn.roundId!)
        : null;
    final hasVesting = provider.getVestingByTransaction(txn.id) != null;

    // Determine color based on transaction type
    final isAcquisition = txn.isAcquisition;
    final color = isAcquisition ? Colors.green : Colors.red;
    final sign = isAcquisition ? '+' : '-';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => _editTransaction(txn),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Transaction type icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  isAcquisition
                      ? Icons.add_circle_outline
                      : Icons.remove_circle_outline,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              // Transaction details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              txn.typeDisplayName,
                              style: theme.textTheme.bodySmall?.copyWith(
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
                          Formatters.date(txn.date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '$sign${Formatters.number(txn.numberOfShares)}',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          shareClass?.name ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                            fontSize: 11,
                          ),
                        ),
                        if (round != null) ...[
                          Text(
                            ' • ',
                            style: TextStyle(
                              color: theme.colorScheme.outline,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            round.name,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                              fontSize: 11,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          Formatters.compactCurrency(txn.totalAmount),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Edit indicator
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editTransaction(Transaction transaction) async {
    final result = await TransactionEditor.edit(
      context: context,
      transaction: transaction,
      provider: widget.provider,
    );

    if (result) {
      setState(() {}); // Refresh the card
    }
  }
}

/// Dialog showing investor's holdings summary and transaction history
class _HoldingsAndTransactionsDialog extends StatefulWidget {
  final Investor investor;
  final CapTableProvider provider;

  const _HoldingsAndTransactionsDialog({
    required this.investor,
    required this.provider,
  });

  @override
  State<_HoldingsAndTransactionsDialog> createState() =>
      _HoldingsAndTransactionsDialogState();
}

class _HoldingsAndTransactionsDialogState
    extends State<_HoldingsAndTransactionsDialog> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = widget.provider;
    final investor = widget.investor;

    // Get current holdings summary
    final currentShares = provider.getCurrentSharesByInvestor(investor.id);
    final totalAcquired = provider.getSharesByInvestor(investor.id);
    final sharesSold = provider.getSharesSoldByInvestor(investor.id);
    final invested = provider.getInvestmentByInvestor(investor.id);
    final currentValue = currentShares * provider.latestSharePrice;
    final ownership = provider.getOwnershipPercentage(investor.id);

    // Get all transactions sorted by date (oldest first)
    final transactions = provider.getTransactionsByInvestor(investor.id);

    return AlertDialog(
      title: Row(
        children: [
          InvestorAvatar(name: investor.name, type: investor.type, radius: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(investor.name),
                Text(
                  'Holdings & Transactions',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width > 600 ? 550 : double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Holdings Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryItem(
                          label: 'Current Shares',
                          value: Formatters.number(currentShares),
                          valueColor: theme.colorScheme.primary,
                        ),
                      ),
                      Expanded(
                        child: _SummaryItem(
                          label: 'Ownership',
                          value: Formatters.percent(ownership),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryItem(
                          label: 'Total Invested',
                          value: Formatters.currency(invested),
                        ),
                      ),
                      Expanded(
                        child: _SummaryItem(
                          label: 'Current Value',
                          value: Formatters.currency(currentValue),
                          valueColor: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  if (sharesSold > 0) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryItem(
                            label: 'Total Acquired',
                            value: Formatters.number(totalAcquired),
                          ),
                        ),
                        Expanded(
                          child: _SummaryItem(
                            label: 'Shares Sold',
                            value: Formatters.number(sharesSold),
                            valueColor: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Transaction History Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction History',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${transactions.length} transactions',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Transaction List
            Expanded(
              child: transactions.isEmpty
                  ? Center(
                      child: Text(
                        'No transactions yet',
                        style: TextStyle(color: theme.colorScheme.outline),
                      ),
                    )
                  : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return _TransactionListItem(
                          transaction: transaction,
                          provider: provider,
                          onEdit: () => _editTransaction(transaction),
                          onDelete: () => _deleteTransaction(transaction),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Future<void> _editTransaction(Transaction transaction) async {
    final result = await TransactionEditor.edit(
      context: context,
      transaction: transaction,
      provider: widget.provider,
    );

    if (result) {
      setState(() {}); // Refresh the dialog
    }
  }

  Future<void> _deleteTransaction(Transaction transaction) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete Transaction',
      message:
          'Are you sure you want to delete this ${transaction.typeDisplayName.toLowerCase()}? '
          'This cannot be undone.',
    );

    if (confirmed) {
      await widget.provider.deleteTransaction(transaction.id);
      setState(() {}); // Refresh the dialog
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Transaction deleted')));
      }
    }
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

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
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final CapTableProvider provider;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TransactionListItem({
    required this.transaction,
    required this.provider,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shareClass = provider.getShareClassById(transaction.shareClassId);
    final round = transaction.roundId != null
        ? provider.getRoundById(transaction.roundId!)
        : null;

    // Determine icon and color based on transaction type
    IconData icon;
    Color color;
    String sign;

    if (transaction.isAcquisition) {
      icon = Icons.add_circle_outline;
      color = Colors.green;
      sign = '+';
    } else {
      icon = Icons.remove_circle_outline;
      color = Colors.red;
      sign = '-';
    }

    // Get counterparty name for secondary transactions
    String? counterpartyName;
    if (transaction.counterpartyInvestorId != null) {
      final counterparty = provider.getInvestorById(
        transaction.counterpartyInvestorId!,
      );
      counterpartyName = counterparty?.name;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),

            // Transaction details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          transaction.typeDisplayName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Formatters.date(transaction.date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$sign${Formatters.number(transaction.numberOfShares)} shares @ ${Formatters.currency(transaction.pricePerShare)}',
                    style: TextStyle(color: color, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${shareClass?.name ?? 'Unknown Class'}${round != null ? ' • ${round.name}' : ''}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  if (counterpartyName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      transaction.isAcquisition
                          ? 'From: $counterpartyName'
                          : 'To: $counterpartyName',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (transaction.notes != null &&
                      transaction.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      transaction.notes!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Actions
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: theme.colorScheme.outline,
                size: 20,
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_outlined, color: Colors.red),
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
