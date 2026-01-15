import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/esop_pool_change.dart';
import '../models/investor.dart';
import '../models/option_grant.dart';
import '../models/share_class.dart';
import '../models/transaction.dart';
import '../models/vesting_schedule.dart';
import '../providers/cap_table_provider.dart';
import '../utils/helpers.dart';
import '../widgets/empty_state.dart';
import '../widgets/form_fields.dart';
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
    final totalGranted = provider.optionGrants.fold(
      0,
      (sum, g) => sum + g.numberOfOptions,
    );
    final totalExercised = provider.totalOptionsExercised;
    final totalRemaining = provider.totalOptionsGranted;
    final totalVested = provider.totalVestedOptions;

    // Use vested intrinsic value for accurate representation
    final vestedIntrinsicValue = provider.totalVestedIntrinsicValue;

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
          label: 'Vested',
          value: Formatters.compactNumber(totalVested),
          color: Colors.indigo,
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
          label: 'Vested Value',
          value: Formatters.compactCurrency(vestedIntrinsicValue),
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildPoolManagement(BuildContext context, CapTableProvider provider) {
    final theme = Theme.of(context);
    final poolShares = provider.esopPoolShares;
    final hasPool = provider.esopPoolChanges.isNotEmpty;

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
                onPressed: () => _showTopUpDialog(context, provider),
                icon: const Icon(Icons.add),
                label: const Text('Create ESOP Pool'),
              ),
            ],
          ),
        ),
      );
    }

    final allocatedShares = provider.allocatedEsopShares;
    final unallocatedShares = provider.unallocatedEsopShares;
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
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 20),
            tooltip: 'Pool Settings',
            onPressed: () => _showPoolSettingsDialog(context, provider),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            tooltip: 'Add to Pool',
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
    EsopPoolChange? existingChange,
  }) {
    showDialog(
      context: context,
      builder: (context) => _PoolChangeDialog(
        provider: provider,
        suggestedShares: suggestedShares,
        existingChange: existingChange,
      ),
    );
  }

  void _showPoolSettingsDialog(
    BuildContext context,
    CapTableProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => _PoolSettingsDialog(provider: provider),
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

        // Use provider methods for consistent vesting calculations
        final vestedPercent = provider.getOptionVestingPercent(g);
        final vestedOptions = provider.getVestedOptionsForGrant(g);

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

      // Default to ESOP share class only if pool exists and has available shares
      final hasEsopPool = widget.provider.esopPoolChanges.isNotEmpty;
      final unallocatedEsop = widget.provider.unallocatedEsopShares;
      if (hasEsopPool && unallocatedEsop > 0) {
        final esopClass = widget.provider.shareClasses
            .where((s) => s.type == ShareClassType.esop)
            .firstOrNull;
        _selectedShareClassId = esopClass?.id;
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

    // Safety check: prevent ESOP grant if no pool exists
    final selectedClass = widget.provider.getShareClassById(
      _selectedShareClassId!,
    );
    if (selectedClass?.type == ShareClassType.esop) {
      final hasEsopPool = widget.provider.esopPoolChanges.isNotEmpty;
      if (!hasEsopPool) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cannot grant options: ESOP pool has not been created',
            ),
            backgroundColor: Colors.red,
          ),
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

/// Dialog for adding/editing ESOP pool changes
class _PoolChangeDialog extends StatefulWidget {
  final CapTableProvider provider;
  final EsopPoolChange? existingChange; // null = add mode, non-null = edit mode
  final int? suggestedShares;

  const _PoolChangeDialog({
    required this.provider,
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
    final currentPool = widget.provider.esopPoolShares;
    final totalShares = widget.provider.totalCurrentShares;
    final isCreatingPool = widget.provider.esopPoolChanges.isEmpty;

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
                        shares > widget.provider.unallocatedEsopShares) {
                      return 'Cannot exceed unallocated shares (${widget.provider.unallocatedEsopShares})';
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
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(
            widget.isEditMode
                ? 'Update'
                : (widget.provider.esopPoolChanges.isEmpty
                      ? 'Create Pool'
                      : 'Save'),
          ),
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
      await widget.provider.updateEsopPoolChange(updated);
    } else {
      // Create new
      final change = EsopPoolChange(
        date: _selectedDate,
        sharesDelta: sharesDelta,
        notes: notes,
      );
      await widget.provider.addEsopPoolChange(change);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditMode
                ? 'Pool change updated'
                : '${_isSubtraction ? "Removed" : "Added"} ${Formatters.number(inputShares)} shares ${_isSubtraction ? "from" : "to"} ESOP pool',
          ),
        ),
      );
    }
  }
}

/// Dialog to edit ESOP pool settings and view change history
class _PoolSettingsDialog extends StatefulWidget {
  final CapTableProvider provider;

  const _PoolSettingsDialog({required this.provider});

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
      text: widget.provider.esopPoolPercent.toString(),
    );
    _dilutionMethod = widget.provider.esopDilutionMethod;
  }

  @override
  void dispose() {
    _targetPercentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final changes = widget.provider.esopPoolChanges;

    return AlertDialog(
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
                      Formatters.number(widget.provider.esopPoolShares),
                    ),
                    _buildInfoRow(
                      'Allocated (via grants)',
                      Formatters.number(widget.provider.allocatedEsopShares),
                    ),
                    _buildInfoRow(
                      'Available',
                      Formatters.number(widget.provider.unallocatedEsopShares),
                    ),
                    _buildInfoRow(
                      'Options Exercised',
                      Formatters.number(widget.provider.totalOptionsExercised),
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
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save Settings')),
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
      builder: (ctx) => _PoolChangeDialog(provider: widget.provider),
    );
    if (mounted) setState(() {}); // Refresh the list
  }

  void _editPoolChange(BuildContext context, EsopPoolChange change) async {
    await showDialog(
      context: context,
      builder: (ctx) =>
          _PoolChangeDialog(provider: widget.provider, existingChange: change),
    );
    if (mounted) setState(() {}); // Refresh the list
  }

  void _deletePoolChange(BuildContext context, EsopPoolChange change) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Pool Change?'),
        content: Text(
          'Remove ${change.isAddition ? "+" : ""}${Formatters.number(change.sharesDelta)} shares from ${Formatters.date(change.date)}?\n\n'
          'This will affect the total pool size.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.provider.deleteEsopPoolChange(change.id);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Pool change deleted')));
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

    await widget.provider.updateEsopSettings(
      targetPercent: targetPercent,
      dilutionMethod: _dilutionMethod,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ESOP settings updated')));
    }
  }
}
