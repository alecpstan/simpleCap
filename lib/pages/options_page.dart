import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/investor.dart';
import '../models/option_grant.dart';
import '../models/share_class.dart';
import '../models/transaction.dart';
import '../models/vesting_schedule.dart';
import '../providers/cap_table_provider.dart';
import '../utils/helpers.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_card.dart';
import '../widgets/info_widgets.dart';
import '../widgets/avatars.dart';
import '../widgets/dialogs.dart';
import '../widgets/expandable_card.dart';

class OptionsPage extends StatelessWidget {
  const OptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CapTableProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Check for expired grants
        WidgetsBinding.instance.addPostFrameCallback((_) {
          provider.updateExpiredOptionGrants();
        });

        final grants = provider.optionGrants;
        final activeGrants = provider.activeOptionGrants;

        return Scaffold(
          appBar: AppBar(title: const Text('Options & ESOP')),
          body: grants.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const EmptyState(
                      icon: Icons.card_giftcard,
                      title: 'No Option Grants',
                      subtitle:
                          'Grant stock options to employees, advisors, or contractors.',
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _showGrantDialog(context, provider),
                      icon: const Icon(Icons.add),
                      label: const Text('Grant Options'),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ESOP Pool Management
                      _buildPoolManagement(context, provider),
                      const SizedBox(height: 16),

                      // Summary stats
                      _buildSummaryCards(context, provider),
                      const SizedBox(height: 24),

                      // Active grants
                      if (activeGrants.isNotEmpty) ...[
                        SectionCard(
                          title: 'Active Grants',
                          trailing: Text(
                            '${activeGrants.length} active',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          child: _buildGrantsList(
                            context,
                            provider,
                            activeGrants,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Exercised/cancelled/expired
                      _buildHistorySection(context, provider, grants),
                    ],
                  ),
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showGrantDialog(context, provider),
            icon: const Icon(Icons.add),
            label: const Text('Grant Options'),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(BuildContext context, CapTableProvider provider) {
    final activeGrants = provider.activeOptionGrants;
    final totalGranted = provider.optionGrants.fold(
      0,
      (sum, g) => sum + g.numberOfOptions,
    );
    final totalExercised = provider.totalOptionsExercised;
    final totalRemaining = provider.totalOptionsGranted;

    // Calculate total intrinsic value
    final currentPrice = provider.latestSharePrice;
    final totalIntrinsicValue = activeGrants.fold(
      0.0,
      (sum, g) => sum + g.intrinsicValue(currentPrice),
    );

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ResultChip(
          label: 'Total Granted',
          value: Formatters.compactNumber(totalGranted),
          color: Colors.blue,
        ),
        ResultChip(
          label: 'Exercised',
          value: Formatters.compactNumber(totalExercised),
          color: Colors.green,
        ),
        ResultChip(
          label: 'Outstanding',
          value: Formatters.compactNumber(totalRemaining),
          color: Colors.orange,
        ),
        ResultChip(
          label: 'Intrinsic Value',
          value: Formatters.compactCurrency(totalIntrinsicValue),
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildPoolManagement(BuildContext context, CapTableProvider provider) {
    final theme = Theme.of(context);
    final poolShares = provider.esopPoolShares;
    final unallocatedShares = provider.unallocatedEsopShares;
    final allocatedShares = poolShares - unallocatedShares;
    final totalShares = provider.totalCurrentShares;

    // Calculate percentages
    final poolPercent = totalShares > 0
        ? (poolShares / totalShares) * 100
        : 0.0;
    final allocatedPercent = poolShares > 0
        ? (allocatedShares / poolShares) * 100
        : 0.0;
    final targetPercent = provider.esopPoolPercent;

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
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            tooltip: 'Top Up Pool',
            onPressed: () => _showTopUpDialog(context, provider),
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
                    flex: unallocatedShares > 0 ? unallocatedShares : 0,
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
                  // Empty space if pool is small
                  if (poolShares == 0)
                    Expanded(
                      child: Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: Text(
                          'No pool created',
                          style: theme.textTheme.labelSmall,
                        ),
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
                      provider,
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
    CapTableProvider provider, {
    int? suggestedShares,
  }) {
    showDialog(
      context: context,
      builder: (context) => _TopUpPoolDialog(
        provider: provider,
        suggestedShares: suggestedShares,
      ),
    );
  }

  Widget _buildGrantsList(
    BuildContext context,
    CapTableProvider provider,
    List<OptionGrant> grants,
  ) {
    return Column(
      children: grants.map((g) {
        final investor = provider.getInvestorById(g.investorId);
        final shareClass = provider.getShareClassById(g.shareClassId);
        final vesting = g.vestingScheduleId != null
            ? provider.getVestingScheduleById(g.vestingScheduleId!)
            : null;

        // Calculate vested options
        final vestedPercent = vesting != null
            ? _calculateVestedPercent(vesting, g.numberOfOptions)
            : 100.0;
        final vestedOptions = (g.numberOfOptions * vestedPercent / 100).round();

        return _OptionGrantTile(
          grant: g,
          investorName: investor?.name ?? 'Unknown',
          investorType: investor?.type,
          shareClassName: shareClass?.name ?? 'Unknown',
          vestedOptions: vestedOptions,
          vestedPercent: vestedPercent,
          currentPrice: provider.latestSharePrice,
          onTap: () => _showGrantDetails(context, provider, g),
        );
      }).toList(),
    );
  }

  double _calculateVestedPercent(VestingSchedule vesting, int totalOptions) {
    final now = DateTime.now();
    final monthsElapsed = (now.difference(vesting.startDate).inDays / 30.44)
        .floor();

    // Check cliff
    if (monthsElapsed < vesting.cliffMonths) return 0;

    // Calculate vested portion
    final vestedMonths = monthsElapsed.clamp(0, vesting.vestingPeriodMonths);
    return (vestedMonths / vesting.vestingPeriodMonths * 100)
        .clamp(0, 100)
        .toDouble();
  }

  Widget _buildHistorySection(
    BuildContext context,
    CapTableProvider provider,
    List<OptionGrant> allGrants,
  ) {
    final inactiveGrants = allGrants.where((g) {
      return g.status == OptionGrantStatus.fullyExercised ||
          g.status == OptionGrantStatus.expired ||
          g.status == OptionGrantStatus.cancelled ||
          g.status == OptionGrantStatus.forfeited;
    }).toList();

    if (inactiveGrants.isEmpty) return const SizedBox.shrink();

    return SectionCard(
      title: 'History',
      trailing: Text(
        '${inactiveGrants.length} closed',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      child: Column(
        children: inactiveGrants.map((g) {
          final investor = provider.getInvestorById(g.investorId);
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: g.status.color.withValues(alpha: 0.2),
              child: Icon(
                _getStatusIcon(g.status),
                color: g.status.color,
                size: 20,
              ),
            ),
            title: Text(investor?.name ?? 'Unknown'),
            subtitle: Text(
              '${Formatters.number(g.numberOfOptions)} options • ${g.statusDisplayName}',
            ),
            trailing: Text(
              Formatters.date(g.grantDate),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onTap: () => _showGrantDetails(context, provider, g),
          );
        }).toList(),
      ),
    );
  }

  IconData _getStatusIcon(OptionGrantStatus status) {
    switch (status) {
      case OptionGrantStatus.active:
        return Icons.card_giftcard;
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

  void _showGrantDialog(BuildContext context, CapTableProvider provider) {
    showDialog(
      context: context,
      builder: (context) => GrantOptionsDialog(provider: provider),
    );
  }

  void _showGrantDetails(
    BuildContext context,
    CapTableProvider provider,
    OptionGrant grant,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          GrantDetailsDialog(grant: grant, provider: provider),
    );
  }
}

/// Compact tile for displaying an option grant
class _OptionGrantTile extends StatelessWidget {
  final OptionGrant grant;
  final String investorName;
  final InvestorType? investorType;
  final String shareClassName;
  final int vestedOptions;
  final double vestedPercent;
  final double currentPrice;
  final VoidCallback onTap;

  const _OptionGrantTile({
    required this.grant,
    required this.investorName,
    required this.investorType,
    required this.shareClassName,
    required this.vestedOptions,
    required this.vestedPercent,
    required this.currentPrice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final intrinsicValue = grant.intrinsicValue(currentPrice);
    final inTheMoney = currentPrice > grant.strikePrice;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.3,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                InvestorAvatar(
                  name: investorName,
                  type: investorType,
                  radius: 16,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        investorName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${Formatters.number(grant.numberOfOptions)} options @ ${Formatters.currency(grant.strikePrice)}',
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
            const SizedBox(height: 8),
            // Stats row
            Row(
              children: [
                _StatChip(
                  label: 'Vested',
                  value: '${vestedPercent.toStringAsFixed(0)}%',
                  color: vestedPercent >= 100 ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  label: 'Exercised',
                  value: Formatters.compactNumber(grant.exercisedCount),
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  label: 'Value',
                  value: Formatters.compactCurrency(intrinsicValue),
                  color: inTheMoney ? Colors.green : Colors.grey,
                ),
                const Spacer(),
                Text(
                  'Exp: ${Formatters.date(grant.expiryDate)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact dialog for granting/editing options
class GrantOptionsDialog extends StatefulWidget {
  final CapTableProvider provider;
  final OptionGrant? grant; // If provided, we're editing

  const GrantOptionsDialog({super.key, required this.provider, this.grant});

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
      // Default strike price to current valuation
      _strikePriceController.text = widget.provider.latestSharePrice
          .toStringAsFixed(2);

      // Default to ESOP share class if exists
      final esopClass = widget.provider.shareClasses
          .where((s) => s.type == ShareClassType.esop)
          .firstOrNull;
      _selectedShareClassId = esopClass?.id;
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
    final theme = Theme.of(context);
    // Allow all investors to receive options
    final investors = widget.provider.investors.toList();

    return AlertDialog(
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
                  DropdownButtonFormField<String>(
                    initialValue: _selectedInvestorId,
                    decoration: const InputDecoration(
                      labelText: 'Recipient',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
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
                      child: TextFormField(
                        controller: _optionsController,
                        decoration: const InputDecoration(
                          labelText: 'Options',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
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
                      child: TextFormField(
                        controller: _strikePriceController,
                        decoration: const InputDecoration(
                          labelText: 'Strike Price',
                          prefixText: '\$ ',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
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
                DropdownButtonFormField<String>(
                  initialValue: _selectedShareClassId,
                  decoration: const InputDecoration(
                    labelText: 'Share Class',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: widget.provider.shareClasses.map((s) {
                    return DropdownMenuItem(value: s.id, child: Text(s.name));
                  }).toList(),
                  validator: (v) => v == null ? 'Select share class' : null,
                  onChanged: (v) => setState(() => _selectedShareClassId = v),
                ),
                const SizedBox(height: 12),

                // Dates row
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _grantDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) setState(() => _grantDate = date);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Grant Date',
                            border: OutlineInputBorder(),
                            isDense: true,
                            suffixIcon: Icon(Icons.calendar_today, size: 18),
                          ),
                          child: Text(
                            Formatters.date(_grantDate),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _expiryDate,
                            firstDate: _grantDate,
                            lastDate: DateTime(2100),
                          );
                          if (date != null) setState(() => _expiryDate = date);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Expiry Date',
                            border: OutlineInputBorder(),
                            isDense: true,
                            suffixIcon: Icon(Icons.calendar_today, size: 18),
                          ),
                          child: Text(
                            Formatters.date(_expiryDate),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Vesting toggle
                SwitchListTile(
                  title: const Text('Add Vesting Schedule'),
                  value: _hasVesting,
                  onChanged: (v) => setState(() => _hasVesting = v),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),

                if (_hasVesting) ...[
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _vestingMonths,
                          decoration: const InputDecoration(
                            labelText: 'Vesting Period',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
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
                        child: DropdownButtonFormField<int>(
                          initialValue: _cliffMonths,
                          decoration: const InputDecoration(
                            labelText: 'Cliff',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
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
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(isEditing ? 'Save' : 'Grant'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedInvestorId == null || _selectedShareClassId == null) return;

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

      await widget.provider.updateOptionGrant(updatedGrant);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Option grant updated')));
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

      await widget.provider.addOptionGrant(grant);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Granted ${Formatters.number(options)} options'),
          ),
        );
      }
    }
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
  final CapTableProvider provider;

  const GrantDetailsDialog({
    super.key,
    required this.grant,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final investor = provider.getInvestorById(grant.investorId);
    final shareClass = provider.getShareClassById(grant.shareClassId);
    final vesting = grant.vestingScheduleId != null
        ? provider.getVestingScheduleById(grant.vestingScheduleId!)
        : null;
    final currentPrice = provider.latestSharePrice;
    final intrinsicValue = grant.intrinsicValue(currentPrice);
    final inTheMoney = currentPrice > grant.strikePrice;

    // Calculate vested options
    final vestedPercent = vesting != null
        ? _calculateVestedPercent(vesting, grant.numberOfOptions)
        : 100.0;
    final vestedOptions = (grant.numberOfOptions * vestedPercent / 100).round();
    final exercisableOptions = vestedOptions - grant.exercisedCount;
    final canExercise = grant.canExercise && exercisableOptions > 0;

    // Get linked transaction if any
    final exerciseTransaction = grant.exerciseTransactionId != null
        ? provider.getTransactionById(grant.exerciseTransactionId!)
        : null;

    return AlertDialog(
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
                            'Intrinsic value: ${Formatters.currency(intrinsicValue)}',
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
                      _buildTransactionTile(
                        context,
                        exerciseTransaction,
                        provider,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        // Show Undo Exercise if already exercised, otherwise show Exercise
        if (grant.exercisedCount > 0) ...[
          FilledButton.icon(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final confirmed = await showConfirmDialog(
                context: context,
                title: 'Undo Exercise',
                message:
                    'This will remove the exercise transaction and restore the options to their original state. Are you sure?',
              );
              if (confirmed && context.mounted) {
                final success = await provider.undoOptionExercise(
                  grantId: grant.id,
                );
                if (success) {
                  navigator.pop();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Exercise undone')),
                    );
                  }
                }
              }
            },
            icon: const Icon(Icons.undo, size: 18),
            label: const Text('Undo Exercise'),
          ),
        ] else ...[
          FilledButton.icon(
            onPressed: canExercise
                ? () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => ExerciseOptionsDialog(
                        grant: grant,
                        provider: provider,
                        maxExercisable: exercisableOptions,
                      ),
                    );
                  }
                : null,
            icon: const Icon(Icons.check_circle, size: 18),
            label: const Text('Exercise'),
          ),
        ],
        TextButton.icon(
          onPressed: (exerciseTransaction == null && grant.exercisedCount == 0)
              ? () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) =>
                        GrantOptionsDialog(provider: provider, grant: grant),
                  );
                }
              : null,
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('Edit'),
        ),
        TextButton(
          onPressed: () async {
            final navigator = Navigator.of(context);
            final confirmed = await showConfirmDialog(
              context: context,
              title: 'Delete Grant',
              message: 'Are you sure you want to delete this option grant?',
            );
            if (confirmed && context.mounted) {
              await provider.deleteOptionGrant(grant.id);
              navigator.pop();
            }
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  double _calculateVestedPercent(VestingSchedule vesting, int totalOptions) {
    final now = DateTime.now();
    final monthsElapsed = (now.difference(vesting.startDate).inDays / 30.44)
        .floor();

    if (monthsElapsed < vesting.cliffMonths) return 0;

    final vestedMonths = monthsElapsed.clamp(0, vesting.vestingPeriodMonths);
    return (vestedMonths / vesting.vestingPeriodMonths * 100)
        .clamp(0, 100)
        .toDouble();
  }

  Widget _buildTransactionTile(
    BuildContext context,
    Transaction txn,
    CapTableProvider provider,
  ) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (ctx) => _EditExerciseTransactionDialog(
            transaction: txn,
            grant: grant,
            provider: provider,
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
  final CapTableProvider provider;
  final int maxExercisable;

  const ExerciseOptionsDialog({
    super.key,
    required this.grant,
    required this.provider,
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
            TextFormField(
              controller: _optionsController,
              decoration: InputDecoration(
                labelText: 'Options to Exercise',
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: TextButton(
                  onPressed: () {
                    _optionsController.text = widget.maxExercisable.toString();
                    setState(() {});
                  },
                  child: const Text('All'),
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // Exercise date
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _exerciseDate,
                  firstDate: widget.grant.grantDate,
                  lastDate: widget.grant.expiryDate,
                );
                if (date != null) setState(() => _exerciseDate = date);
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Exercise Date',
                  border: OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: Icon(Icons.calendar_today, size: 18),
                ),
                child: Text(Formatters.date(_exerciseDate)),
              ),
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
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _exercise,
          icon: const Icon(Icons.check_circle),
          label: const Text('Exercise'),
        ),
      ],
    );
  }

  Future<void> _exercise() async {
    final options = int.tryParse(_optionsController.text) ?? 0;
    if (options <= 0 || options > widget.maxExercisable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid number of options')),
      );
      return;
    }

    final success = await widget.provider.exerciseOptions(
      grantId: widget.grant.id,
      numberOfOptions: options,
      exerciseDate: _exerciseDate,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exercised ${Formatters.number(options)} options'),
        ),
      );
    }
  }
}

/// Dialog for editing/deleting an exercise transaction
class _EditExerciseTransactionDialog extends StatefulWidget {
  final Transaction transaction;
  final OptionGrant grant;
  final CapTableProvider provider;

  const _EditExerciseTransactionDialog({
    required this.transaction,
    required this.grant,
    required this.provider,
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
            TextFormField(
              controller: _sharesController,
              decoration: const InputDecoration(
                labelText: 'Shares (Options Exercised)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // Exercise date
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _exerciseDate,
                  firstDate: widget.grant.grantDate,
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _exerciseDate = date);
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Exercise Date',
                  border: OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: Icon(Icons.calendar_today, size: 18),
                ),
                child: Text(Formatters.date(_exerciseDate)),
              ),
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
        TextButton(
          onPressed: _delete,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  Future<void> _save() async {
    final shares = int.tryParse(_sharesController.text) ?? 0;
    if (shares <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid number of shares')));
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
      await widget.provider.updateOptionGrant(updatedGrant);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Transaction updated')));
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
    await widget.provider.updateOptionGrant(updatedGrant);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Exercise undone')));
    }
  }
}

/// Dialog for topping up the ESOP pool
class _TopUpPoolDialog extends StatefulWidget {
  final CapTableProvider provider;
  final int? suggestedShares;

  const _TopUpPoolDialog({required this.provider, this.suggestedShares});

  @override
  State<_TopUpPoolDialog> createState() => _TopUpPoolDialogState();
}

class _TopUpPoolDialogState extends State<_TopUpPoolDialog> {
  final _formKey = GlobalKey<FormState>();
  final _sharesController = TextEditingController();
  String? _selectedShareClassId;
  String? _selectedPoolHolderId;
  late DateTime _grantDate;

  @override
  void initState() {
    super.initState();
    _grantDate = DateTime.now();

    // Pre-fill suggested shares
    if (widget.suggestedShares != null) {
      _sharesController.text = widget.suggestedShares.toString();
    }

    // Find existing ESOP share class
    final esopClasses = widget.provider.shareClasses
        .where((s) => s.type == ShareClassType.esop)
        .toList();
    if (esopClasses.isNotEmpty) {
      _selectedShareClassId = esopClasses.first.id;
    }

    // Find ESOP pool holder
    final poolHolders = widget.provider.investors
        .where(
          (i) =>
              i.type == InvestorType.institution ||
              i.name.toLowerCase().contains('esop') ||
              i.name.toLowerCase().contains('pool'),
        )
        .toList();
    if (poolHolders.isNotEmpty) {
      _selectedPoolHolderId = poolHolders.first.id;
    }
  }

  @override
  void dispose() {
    _sharesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shareClasses = widget.provider.shareClasses;
    final investors = widget.provider.investors;

    // Calculate preview
    final newShares = int.tryParse(_sharesController.text) ?? 0;
    final currentPool = widget.provider.esopPoolShares;
    final totalShares = widget.provider.totalCurrentShares;
    final newPoolPercent = totalShares > 0
        ? ((currentPool + newShares) / (totalShares + newShares)) * 100
        : 0.0;

    return AlertDialog(
      title: const Text('Top Up ESOP Pool'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Current pool: ${Formatters.number(currentPool)} shares',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Shares to add
              TextFormField(
                controller: _sharesController,
                decoration: const InputDecoration(
                  labelText: 'Shares to Add',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (int.tryParse(v) == null || int.parse(v) <= 0) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Share class
              DropdownButtonFormField<String>(
                key: ValueKey('shareclass_$_selectedShareClassId'),
                initialValue: _selectedShareClassId,
                decoration: const InputDecoration(
                  labelText: 'Share Class',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: shareClasses.map((s) {
                  return DropdownMenuItem(value: s.id, child: Text(s.name));
                }).toList(),
                onChanged: (v) => setState(() => _selectedShareClassId = v),
                validator: (v) => v == null ? 'Select share class' : null,
              ),
              const SizedBox(height: 12),

              // Pool holder
              DropdownButtonFormField<String>(
                key: ValueKey('poolholder_$_selectedPoolHolderId'),
                initialValue: _selectedPoolHolderId,
                decoration: const InputDecoration(
                  labelText: 'Pool Holder',
                  border: OutlineInputBorder(),
                  isDense: true,
                  helperText: 'Usually "ESOP Pool" or company institution',
                ),
                items: investors.map((i) {
                  return DropdownMenuItem(value: i.id, child: Text(i.name));
                }).toList(),
                onChanged: (v) => setState(() => _selectedPoolHolderId = v),
                validator: (v) => v == null ? 'Select pool holder' : null,
              ),
              const SizedBox(height: 16),

              // Preview
              if (newShares > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'After Top-Up',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pool: ${Formatters.number(currentPool + newShares)} shares',
                      ),
                      Text(
                        'Cap table %: ${newPoolPercent.toStringAsFixed(1)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Add Shares')),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedShareClassId == null || _selectedPoolHolderId == null) return;

    final shares = int.parse(_sharesController.text);

    // Create a grant transaction to the pool
    final transaction = Transaction(
      investorId: _selectedPoolHolderId!,
      shareClassId: _selectedShareClassId!,
      type: TransactionType.grant,
      numberOfShares: shares,
      pricePerShare: 0, // Pool shares are issued at $0
      date: _grantDate,
      notes: 'ESOP pool top-up',
    );

    await widget.provider.addTransaction(transaction);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added ${Formatters.number(shares)} shares to ESOP pool',
          ),
        ),
      );
    }
  }
}
