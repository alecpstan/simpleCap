import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../application/providers/providers.dart';
import '../../infrastructure/database/database.dart';
import '../../shared/formatters.dart';
import '../components/components.dart';

/// Page for managing and viewing all company valuations.
///
/// Shows both manual valuations and valuations derived from funding rounds
/// (pre-money and post-money).
class ValuationsPage extends ConsumerWidget {
  const ValuationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final valuationsAsync = ref.watch(valuationsStreamProvider);
    final roundsAsync = ref.watch(roundsStreamProvider);
    final companyId = ref.watch(currentCompanyIdProvider);
    final effectiveValuationAsync = ref.watch(effectiveValuationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Valuations')),
      body: SafeArea(
        child: valuationsAsync.when(
          data: (valuations) => roundsAsync.when(
            data: (rounds) => effectiveValuationAsync.when(
              data: (effectiveValuation) => _buildContent(
                context,
                ref,
                valuations,
                rounds,
                effectiveValuation,
                companyId,
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
      ),
      floatingActionButton: companyId != null
          ? FloatingActionButton(
              onPressed: () => _showAddValuationDialog(context, ref, companyId),
              tooltip: 'Add Manual Valuation',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<Valuation> valuations,
    List<Round> rounds,
    EffectiveValuation? effectiveValuation,
    String? companyId,
  ) {
    // Build a combined list of valuation entries
    final entries = <_ValuationEntry>[];

    // Add manual valuations
    for (final v in valuations) {
      entries.add(
        _ValuationEntry(
          type: _ValuationType.manual,
          date: v.date,
          value: v.preMoneyValue,
          method: v.method,
          valuation: v,
        ),
      );
    }

    // Add round-derived valuations
    for (final r in rounds) {
      if (r.status == 'closed') {
        // Add pre-money valuation
        if (r.preMoneyValuation != null && r.preMoneyValuation! > 0) {
          entries.add(
            _ValuationEntry(
              type: _ValuationType.roundPreMoney,
              date: r.date,
              value: r.preMoneyValuation!,
              roundName: r.name,
              round: r,
            ),
          );
        }
        // Add post-money valuation (pre-money + amount raised)
        final postMoney = (r.preMoneyValuation ?? 0) + r.amountRaised;
        if (postMoney > 0) {
          entries.add(
            _ValuationEntry(
              type: _ValuationType.roundPostMoney,
              date: r.date,
              value: postMoney,
              roundName: r.name,
              round: r,
            ),
          );
        }
      }
    }

    // Sort by date descending
    entries.sort((a, b) => b.date.compareTo(a.date));

    if (entries.isEmpty) {
      return EmptyState(
        icon: Icons.trending_up,
        title: 'No Valuations Yet',
        message:
            'Add a manual valuation or close a funding round to track company value over time.',
        actionLabel: companyId != null ? 'Add Valuation' : null,
        onAction: companyId != null
            ? () => _showAddValuationDialog(context, ref, companyId)
            : null,
      );
    }

    return CustomScrollView(
      slivers: [
        // Current valuation header
        if (effectiveValuation != null)
          SliverToBoxAdapter(
            child: _buildCurrentValuationCard(context, effectiveValuation),
          ),
        // Valuation history
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Text(
              'VALUATION HISTORY',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildValuationEntryCard(
                context,
                ref,
                entries[index],
                isLatest: index == 0,
              ),
              childCount: entries.length,
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
      ],
    );
  }

  Widget _buildCurrentValuationCard(
    BuildContext context,
    EffectiveValuation effectiveValuation,
  ) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Current Valuation',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            Formatters.currency(effectiveValuation.value),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${effectiveValuation.sourceDescription} • ${Formatters.date(effectiveValuation.date)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withValues(
                alpha: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValuationEntryCard(
    BuildContext context,
    WidgetRef ref,
    _ValuationEntry entry, {
    bool isLatest = false,
  }) {
    final theme = Theme.of(context);

    IconData icon;
    Color color;
    String subtitle;

    switch (entry.type) {
      case _ValuationType.manual:
        icon = Icons.edit_note;
        color = Colors.blue;
        subtitle = ValuationMethod.displayName(entry.method ?? 'manual');
      case _ValuationType.roundPreMoney:
        icon = Icons.arrow_upward;
        color = Colors.orange;
        subtitle = '${entry.roundName} • Pre-Money';
      case _ValuationType.roundPostMoney:
        icon = Icons.arrow_downward;
        color = Colors.green;
        subtitle = '${entry.roundName} • Post-Money';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          Formatters.currency(entry.value),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${Formatters.date(entry.date)} • $subtitle',
          style: theme.textTheme.bodySmall,
        ),
        trailing: entry.type == _ValuationType.manual
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _showEditValuationDialog(
                      context,
                      ref,
                      entry.valuation!,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outlined,
                      size: 20,
                      color: theme.colorScheme.error,
                    ),
                    onPressed: () =>
                        _confirmDeleteValuation(context, ref, entry.valuation!),
                  ),
                ],
              )
            : Tooltip(
                message: 'From ${entry.roundName} round',
                child: Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: theme.colorScheme.outline,
                ),
              ),
      ),
    );
  }

  void _showAddValuationDialog(
    BuildContext context,
    WidgetRef ref,
    String companyId,
  ) {
    _showValuationDialog(context, ref, companyId: companyId);
  }

  void _showEditValuationDialog(
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
      text: valuation != null ? valuation.preMoneyValue.toStringAsFixed(0) : '',
    );
    var selectedMethod = valuation?.method ?? ValuationMethod.all.first;
    var selectedDate = valuation?.date ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Edit Valuation' : 'Add Valuation'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: valueController,
                  decoration: const InputDecoration(
                    labelText: 'Valuation Amount',
                    prefixText: '\$ ',
                  ),
                  keyboardType: TextInputType.number,
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
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedMethod = value);
                    }
                  },
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
                      setState(() => selectedDate = date);
                    }
                  },
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
                if (value == null || value <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid amount'),
                    ),
                  );
                  return;
                }

                final db = ref.read(databaseProvider);
                if (isEditing) {
                  await db.upsertValuation(
                    ValuationsCompanion(
                      id: Value(valuation.id),
                      companyId: Value(valuation.companyId),
                      preMoneyValue: Value(value),
                      method: Value(selectedMethod),
                      date: Value(selectedDate),
                      createdAt: Value(valuation.createdAt),
                    ),
                  );
                } else {
                  await db.upsertValuation(
                    ValuationsCompanion(
                      id: Value(
                        DateTime.now().millisecondsSinceEpoch.toString(),
                      ),
                      companyId: Value(companyId!),
                      preMoneyValue: Value(value),
                      method: Value(selectedMethod),
                      date: Value(selectedDate),
                      createdAt: Value(DateTime.now()),
                    ),
                  );
                }

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteValuation(
    BuildContext context,
    WidgetRef ref,
    Valuation valuation,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Valuation'),
        content: Text(
          'Are you sure you want to delete the ${Formatters.currency(valuation.preMoneyValue)} valuation from ${Formatters.date(valuation.date)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              final db = ref.read(databaseProvider);
              await db.deleteValuation(valuation.id);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Internal enum for valuation entry types.
enum _ValuationType { manual, roundPreMoney, roundPostMoney }

/// Internal class to hold combined valuation data.
class _ValuationEntry {
  final _ValuationType type;
  final DateTime date;
  final double value;
  final String? method;
  final String? roundName;
  final Valuation? valuation;
  final Round? round;

  _ValuationEntry({
    required this.type,
    required this.date,
    required this.value,
    this.method,
    this.roundName,
    this.valuation,
    this.round,
  });
}
