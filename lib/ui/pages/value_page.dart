import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/providers.dart';
import '../../infrastructure/database/database.dart';
import '../../shared/formatters.dart';
import '../components/components.dart';

/// Page showing the equity value each stakeholder holds.
class ValuePage extends ConsumerStatefulWidget {
  const ValuePage({super.key});

  @override
  ConsumerState<ValuePage> createState() => _ValuePageState();
}

class _ValuePageState extends ConsumerState<ValuePage> {
  bool _vestedOnly = false;

  @override
  Widget build(BuildContext context) {
    final companyId = ref.watch(currentCompanyIdProvider);

    if (companyId == null) {
      return const EmptyState(
        icon: Icons.business,
        title: 'No company selected',
        message: 'Please create or select a company first.',
      );
    }

    final holdingsAsync = ref.watch(holdingsStreamProvider);
    final stakeholdersAsync = ref.watch(stakeholdersStreamProvider);
    final effectiveValuationAsync = ref.watch(effectiveValuationProvider);
    final ownershipAsync = ref.watch(ownershipSummaryProvider);
    final optionsAsync = ref.watch(optionGrantsStreamProvider);

    return Scaffold(
      body: holdingsAsync.when(
        data: (holdings) => stakeholdersAsync.when(
          data: (stakeholders) => effectiveValuationAsync.when(
            data: (effectiveValuation) => ownershipAsync.when(
              data: (ownership) => optionsAsync.when(
                data: (options) => _buildContent(
                  context,
                  holdings,
                  stakeholders,
                  options,
                  effectiveValuation,
                  ownership,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => EmptyState.error(message: e.toString()),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState.error(message: e.toString()),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => EmptyState.error(message: e.toString()),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => EmptyState.error(message: e.toString()),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState.error(message: e.toString()),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<Holding> holdings,
    List<Stakeholder> stakeholders,
    List<OptionGrant> options,
    EffectiveValuation? effectiveValuation,
    OwnershipSummary ownership,
  ) {
    if (effectiveValuation == null) {
      return EmptyState(
        icon: Icons.analytics,
        title: 'No Valuation Set',
        message:
            'Add a company valuation or funding round to see equity values.',
        actionLabel: 'Add Valuation',
        onAction: () => _showValuationDialog(context),
      );
    }

    // Calculate price per share from valuation
    final totalShares = ownership.totalIssuedShares;
    if (totalShares == 0) {
      return const EmptyState(
        icon: Icons.pie_chart,
        title: 'No Shares Issued',
        message: 'Issue shares to stakeholders to see their equity values.',
      );
    }

    final pricePerShare = effectiveValuation.value / totalShares;

    // Build stakeholder value data
    final stakeholderMap = {for (final s in stakeholders) s.id: s};
    final stakeholderValues = _calculateStakeholderValues(
      holdings,
      options,
      stakeholderMap,
      pricePerShare,
    );

    // Sort by value descending
    stakeholderValues.sort((a, b) => b.totalValue.compareTo(a.totalValue));

    final totalValue = stakeholderValues.fold<double>(
      0,
      (sum, sv) => sum + (_vestedOnly ? sv.vestedValue : sv.totalValue),
    );

    return Column(
      children: [
        _buildHeader(
          context,
          effectiveValuation,
          pricePerShare,
          totalValue,
          totalShares,
        ),
        Expanded(
          child: stakeholderValues.isEmpty
              ? const EmptyState(
                  icon: Icons.people,
                  title: 'No Stakeholders',
                  message: 'Add stakeholders with equity holdings.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: stakeholderValues.length,
                  itemBuilder: (context, index) =>
                      _buildStakeholderCard(context, stakeholderValues[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    EffectiveValuation effectiveValuation,
    double pricePerShare,
    double totalValue,
    int totalShares,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Equity Value',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => _showValuationDialog(context),
                tooltip: 'Manage Valuations',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Based on ${Formatters.compactCurrency(effectiveValuation.value)} valuation (${effectiveValuation.sourceDescription})',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final cards = [
                SummaryCard(
                  label: _vestedOnly ? 'Vested Value' : 'Total Value',
                  value: Formatters.compactCurrency(totalValue),
                  icon: Icons.account_balance_wallet,
                  color: Colors.green,
                ),
                SummaryCard(
                  label: 'Price/Share',
                  value: Formatters.currency(pricePerShare),
                  icon: Icons.paid,
                  color: Colors.blue,
                ),
                SummaryCard(
                  label: 'Total Shares',
                  value: Formatters.number(totalShares),
                  icon: Icons.pie_chart,
                  color: Colors.purple,
                ),
              ];
              final cardsPerRow = cards.length == 1 ? 1 : 2;
              final spacing = 8.0;
              final fullWidth = constraints.maxWidth;
              final cardWidth =
                  (fullWidth - (cardsPerRow - 1) * spacing) / cardsPerRow;
              return Wrap(
                spacing: spacing,
                runSpacing: 8,
                children: cards.asMap().entries.map((entry) {
                  final index = entry.key;
                  final card = entry.value;
                  final isLastOdd =
                      cards.length.isOdd && index == cards.length - 1;
                  final width = isLastOdd ? fullWidth : cardWidth;
                  return SizedBox(width: width, child: card);
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Show vested equity only'),
              const SizedBox(width: 8),
              Switch(
                value: _vestedOnly,
                onChanged: (v) => setState(() => _vestedOnly = v),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStakeholderCard(BuildContext context, _StakeholderValue sv) {
    final displayValue = _vestedOnly ? sv.vestedValue : sv.totalValue;
    final displayShares = _vestedOnly ? sv.vestedShares : sv.totalShares;

    return ExpandableCard(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          sv.stakeholder.name.isNotEmpty
              ? sv.stakeholder.name[0].toUpperCase()
              : '?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: sv.stakeholder.name,
      titleBadge: StatusBadge(
        label: sv.stakeholder.type,
        color: _getTypeColor(sv.stakeholder.type),
      ),
      subtitle: Formatters.compactCurrency(displayValue),
      chips: [
        MetricChip(
          label: 'Shares',
          value: Formatters.number(displayShares),
          color: Colors.blue,
        ),
        MetricChip(
          label: 'Ownership',
          value: '${sv.ownershipPercent.toStringAsFixed(2)}%',
          color: Colors.purple,
        ),
      ],
      expandedContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Total Shares', Formatters.number(sv.totalShares)),
          if (sv.vestedShares != sv.totalShares) ...[
            _buildDetailRow(
              'Vested Shares',
              Formatters.number(sv.vestedShares),
            ),
            _buildDetailRow(
              'Unvested Shares',
              Formatters.number(sv.totalShares - sv.vestedShares),
            ),
          ],
          const Divider(),
          _buildDetailRow('Total Value', Formatters.currency(sv.totalValue)),
          if (sv.vestedValue != sv.totalValue) ...[
            _buildDetailRow(
              'Vested Value',
              Formatters.currency(sv.vestedValue),
            ),
            _buildDetailRow(
              'Unvested Value',
              Formatters.currency(sv.totalValue - sv.vestedValue),
            ),
          ],
          if (sv.optionShares > 0) ...[
            const Divider(),
            _buildDetailRow(
              'Unexercised Options',
              Formatters.number(sv.optionShares),
            ),
            _buildDetailRow(
              'Option Value (if exercised)',
              Formatters.currency(sv.optionValue),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'founder':
        return Colors.purple;
      case 'employee':
        return Colors.blue;
      case 'investor':
        return Colors.green;
      case 'advisor':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  List<_StakeholderValue> _calculateStakeholderValues(
    List<Holding> holdings,
    List<OptionGrant> options,
    Map<String, Stakeholder> stakeholderMap,
    double pricePerShare,
  ) {
    final valueMap = <String, _StakeholderValue>{};

    // Process holdings (actual shares)
    for (final holding in holdings) {
      final stakeholder = stakeholderMap[holding.stakeholderId];
      if (stakeholder == null) continue;

      valueMap.putIfAbsent(
        stakeholder.id,
        () => _StakeholderValue(stakeholder: stakeholder),
      );

      final sv = valueMap[stakeholder.id]!;
      sv.totalShares += holding.shareCount;
      // For holdings, assume all are vested (non-option shares)
      sv.vestedShares += holding.shareCount;
    }

    // Process options (add option value potential)
    for (final option in options) {
      if (option.status != 'active' && option.status != 'pending') continue;

      final stakeholder = stakeholderMap[option.stakeholderId];
      if (stakeholder == null) continue;

      valueMap.putIfAbsent(
        stakeholder.id,
        () => _StakeholderValue(stakeholder: stakeholder),
      );

      final sv = valueMap[stakeholder.id]!;
      final outstanding =
          option.quantity - option.exercisedCount - option.cancelledCount;

      sv.optionShares += outstanding;
      // Option value = (share price - strike price) * shares
      final spreadValue = (pricePerShare - option.strikePrice) * outstanding;
      if (spreadValue > 0) {
        sv.optionValue += spreadValue;
      }
    }

    // Calculate values
    int totalAllShares = 0;
    for (final sv in valueMap.values) {
      totalAllShares += sv.totalShares;
    }

    for (final sv in valueMap.values) {
      sv.totalValue = sv.totalShares * pricePerShare;
      sv.vestedValue = sv.vestedShares * pricePerShare;
      sv.ownershipPercent = totalAllShares > 0
          ? (sv.totalShares / totalAllShares) * 100
          : 0;
    }

    return valueMap.values.toList();
  }

  void _showValuationDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _ValuationsManagementPage()),
    );
  }
}

/// Internal class to hold stakeholder value calculation data.
class _StakeholderValue {
  final Stakeholder stakeholder;
  int totalShares = 0;
  int vestedShares = 0;
  int optionShares = 0;
  double totalValue = 0;
  double vestedValue = 0;
  double optionValue = 0;
  double ownershipPercent = 0;

  _StakeholderValue({required this.stakeholder});
}

/// Sub-page for managing company valuations.
class _ValuationsManagementPage extends ConsumerWidget {
  const _ValuationsManagementPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final valuationsAsync = ref.watch(valuationsStreamProvider);
    final companyId = ref.watch(currentCompanyIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Company Valuations')),
      body: valuationsAsync.when(
        data: (valuations) {
          if (valuations.isEmpty) {
            return EmptyState.noItems(
              itemType: 'valuation',
              onAdd: () => _showAddDialog(context, ref, companyId!),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: valuations.length,
            itemBuilder: (context, index) {
              final valuation = valuations[index];
              final isLatest = index == 0;
              return _buildValuationCard(context, ref, valuation, isLatest);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState.error(message: e.toString()),
      ),
      floatingActionButton: companyId != null
          ? FloatingActionButton(
              onPressed: () => _showAddDialog(context, ref, companyId),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildValuationCard(
    BuildContext context,
    WidgetRef ref,
    Valuation valuation,
    bool isLatest,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isLatest ? Colors.green : Colors.grey.shade300,
          child: Icon(
            Icons.show_chart,
            color: isLatest ? Colors.white : Colors.grey.shade600,
          ),
        ),
        title: Text(Formatters.currency(valuation.preMoneyValue)),
        subtitle: Text(
          '${Formatters.date(valuation.date)} • ${ValuationMethod.displayName(valuation.method)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLatest)
              const Chip(
                label: Text('Current'),
                backgroundColor: Colors.green,
                labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _showEditDialog(context, ref, valuation),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outlined,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => _confirmDelete(context, ref, valuation),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref, String companyId) {
    _showValuationDialog(context, ref, companyId: companyId);
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    Valuation valuation,
  ) {
    _showValuationDialog(context, ref, valuation: valuation);
  }

  void _showValuationDialog(
    BuildContext context,
    WidgetRef ref, {
    String? companyId,
    Valuation? valuation,
  }) {
    final isEditing = valuation != null;
    final valueController = TextEditingController(
      text: valuation?.preMoneyValue.toString() ?? '',
    );
    final notesController = TextEditingController(text: valuation?.notes ?? '');

    DateTime selectedDate = valuation?.date ?? DateTime.now();
    String selectedMethod = valuation?.method ?? ValuationMethod.manual;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Valuation' : 'Add Valuation'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: valueController,
                  decoration: const InputDecoration(
                    labelText: 'Pre-Money Valuation',
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date'),
                  subtitle: Text(Formatters.date(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDate = date);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedMethod,
                  decoration: const InputDecoration(labelText: 'Method'),
                  items: ValuationMethod.all
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text(ValuationMethod.displayName(m)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setDialogState(
                    () => selectedMethod = v ?? ValuationMethod.manual,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final value = double.tryParse(valueController.text);
                if (value == null || value <= 0) return;

                final mutations = ref.read(valuationMutationsProvider.notifier);

                if (isEditing) {
                  await mutations.updateValuation(
                    id: valuation.id,
                    date: selectedDate,
                    preMoneyValue: value,
                    method: selectedMethod,
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                  );
                } else {
                  await mutations.create(
                    companyId: companyId!,
                    date: selectedDate,
                    preMoneyValue: value,
                    method: selectedMethod,
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                  );
                }

                if (context.mounted) Navigator.pop(context);
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Valuation valuation,
  ) async {
    final confirmed = await ConfirmDialog.showDelete(
      context: context,
      itemName: 'this valuation',
    );

    if (confirmed && context.mounted) {
      await ref.read(valuationMutationsProvider.notifier).delete(valuation.id);
    }
  }
}
