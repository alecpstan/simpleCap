import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/providers/core_cap_table_provider.dart';
import '../providers/valuations_provider.dart';
import '../models/valuation.dart';
import '../widgets/valuation_wizard_screen.dart';
import '../../../shared/utils/helpers.dart';
import '../../../shared/widgets/expandable_card.dart';
import '../../../shared/widgets/info_widgets.dart';

/// Page displaying chronological list of valuations and investment rounds.
/// Allows adding new valuations via manual entry or wizard.
class ValuationsPage extends StatelessWidget {
  const ValuationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CoreCapTableProvider, ValuationsProvider>(
      builder: (context, coreProvider, valuationsProvider, child) {
        if (coreProvider.isLoading || !valuationsProvider.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Valuations'),
          ),
          body: _ValuationsBody(
            coreProvider: coreProvider,
            valuationsProvider: valuationsProvider,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddOptions(context, valuationsProvider),
            icon: const Icon(Icons.add),
            label: const Text('Add Valuation'),
          ),
        );
      },
    );
  }

  void _showAddOptions(BuildContext context, ValuationsProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Enter manually'),
              subtitle: const Text('Input a valuation amount directly'),
              onTap: () {
                Navigator.pop(context);
                _showManualEntryDialog(context, provider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('Use wizard'),
              subtitle: const Text('Calculate using valuation methods'),
              onTap: () {
                Navigator.pop(context);
                _openWizard(context, provider);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showManualEntryDialog(
    BuildContext context,
    ValuationsProvider provider, [
    Valuation? existingValuation,
  ]) {
    showDialog(
      context: context,
      builder: (context) => _ManualEntryDialog(
        provider: provider,
        existingValuation: existingValuation,
      ),
    );
  }

  void _openWizard(BuildContext context, ValuationsProvider provider, [Valuation? existingValuation]) async {
    final result = await ValuationWizardScreen.show(
      context,
      existingValuation: existingValuation,
    );

    if (result != null) {
      if (existingValuation != null) {
        await provider.updateValuation(result);
      } else {
        await provider.addValuation(result);
      }
    }
  }
}

class _ValuationsBody extends StatelessWidget {
  final CoreCapTableProvider coreProvider;
  final ValuationsProvider valuationsProvider;

  const _ValuationsBody({
    required this.coreProvider,
    required this.valuationsProvider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Build interleaved timeline of valuations and rounds
    final timelineItems = _buildTimelineItems();

    if (timelineItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assessment_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No valuations yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a valuation to track your company\'s value over time',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          _buildSummaryCards(context),
          const SizedBox(height: 24),

          // Timeline header
          Text(
            'TIMELINE',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          // Timeline items
          ...timelineItems.map((item) => _buildTimelineCard(context, item)),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    final theme = Theme.of(context);
    final latestValuation = valuationsProvider.latestValuation;
    final valuationCount = valuationsProvider.valuations.length;
    final roundCount = coreProvider.rounds.length;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SummaryCard(
          label: 'Latest Valuation',
          value: latestValuation != null
              ? Formatters.compactCurrency(latestValuation.preMoneyValue)
              : '-',
          icon: Icons.trending_up,
          color: theme.colorScheme.primary,
        ),
        SummaryCard(
          label: 'Valuations',
          value: valuationCount.toString(),
          icon: Icons.assessment,
          color: Colors.blue,
        ),
        SummaryCard(
          label: 'Rounds',
          value: roundCount.toString(),
          icon: Icons.rocket_launch,
          color: Colors.green,
        ),
      ],
    );
  }

  List<_TimelineItem> _buildTimelineItems() {
    final items = <_TimelineItem>[];

    // Add valuations
    for (final valuation in valuationsProvider.valuations) {
      items.add(_TimelineItem(
        date: valuation.date,
        type: _TimelineItemType.valuation,
        valuation: valuation,
      ));
    }

    // Add rounds
    for (final round in coreProvider.rounds) {
      final amountRaised = coreProvider.getAmountRaisedByRound(round.id);
      items.add(_TimelineItem(
        date: round.date,
        type: _TimelineItemType.round,
        round: round,
        amountRaised: amountRaised,
      ));
    }

    // Sort by date (newest first)
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  Widget _buildTimelineCard(BuildContext context, _TimelineItem item) {
    if (item.type == _TimelineItemType.valuation) {
      return _ValuationCard(
        valuation: item.valuation!,
        valuationsProvider: valuationsProvider,
      );
    } else {
      return _RoundCard(
        round: item.round!,
        amountRaised: item.amountRaised ?? 0,
      );
    }
  }
}

enum _TimelineItemType { valuation, round }

class _TimelineItem {
  final DateTime date;
  final _TimelineItemType type;
  final Valuation? valuation;
  final dynamic round; // InvestmentRound
  final double? amountRaised;

  _TimelineItem({
    required this.date,
    required this.type,
    this.valuation,
    this.round,
    this.amountRaised,
  });
}

class _ValuationCard extends StatelessWidget {
  final Valuation valuation;
  final ValuationsProvider valuationsProvider;

  const _ValuationCard({
    required this.valuation,
    required this.valuationsProvider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();

    return ExpandableCard(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        child: Icon(
          Icons.assessment,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Formatters.currency(valuation.preMoneyValue),
      subtitle: dateFormat.format(valuation.date),
      accentColor: theme.colorScheme.primary,
      chips: [
        InfoTag(
          label: 'PRE-MONEY',
          color: theme.colorScheme.primary,
        ),
        InfoTag(
          label: valuation.method.displayName,
          icon: valuation.isWizardCreated ? Icons.auto_awesome : null,
          color: Colors.grey,
        ),
      ],
      expandedContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailRow(
            label: 'Valuation Method',
            value: valuation.method.displayName,
          ),
          DetailRow(
            label: 'Date',
            value: dateFormat.format(valuation.date),
          ),
          if (valuation.notes != null && valuation.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Notes',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              valuation.notes!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: () => _editValuation(context),
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('Edit'),
        ),
        TextButton.icon(
          onPressed: () => _deleteValuation(context),
          icon: Icon(Icons.delete, size: 16, color: theme.colorScheme.error),
          label: Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
        ),
      ],
    );
  }

  void _editValuation(BuildContext context) async {
    if (valuation.isWizardCreated) {
      final result = await ValuationWizardScreen.show(
        context,
        existingValuation: valuation,
      );
      if (result != null) {
        await valuationsProvider.updateValuation(result);
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => _ManualEntryDialog(
          provider: valuationsProvider,
          existingValuation: valuation,
        ),
      );
    }
  }

  void _deleteValuation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Valuation'),
        content: const Text('Are you sure you want to delete this valuation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              valuationsProvider.deleteValuation(valuation.id);
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundCard extends StatelessWidget {
  final dynamic round; // InvestmentRound
  final double amountRaised;

  const _RoundCard({
    required this.round,
    required this.amountRaised,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();

    return ExpandableCard(
      leading: CircleAvatar(
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        child: const Icon(
          Icons.rocket_launch,
          color: Colors.green,
          size: 20,
        ),
      ),
      title: round.name,
      subtitle: dateFormat.format(round.date),
      trailing: Text(
        Formatters.compactCurrency(amountRaised),
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
      accentColor: Colors.green,
      chips: [
        InfoTag(
          label: 'ROUND',
          color: Colors.green,
        ),
      ],
      expandedContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailRow(
            label: 'Pre-Money Valuation',
            value: Formatters.compactCurrency(round.preMoneyValuation),
          ),
          DetailRow(
            label: 'Amount Raised',
            value: Formatters.compactCurrency(amountRaised),
            highlight: true,
          ),
          DetailRow(
            label: 'Post-Money Valuation',
            value: Formatters.compactCurrency(
              round.preMoneyValuation + amountRaised,
            ),
          ),
        ],
      ),
      showExpandIcon: true,
    );
  }
}

class _ManualEntryDialog extends StatefulWidget {
  final ValuationsProvider provider;
  final Valuation? existingValuation;

  const _ManualEntryDialog({
    required this.provider,
    this.existingValuation,
  });

  @override
  State<_ManualEntryDialog> createState() => _ManualEntryDialogState();
}

class _ManualEntryDialogState extends State<_ManualEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _valueController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;

  bool get isEditing => widget.existingValuation != null;

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController(
      text: widget.existingValuation?.preMoneyValue.toStringAsFixed(0) ?? '',
    );
    _notesController = TextEditingController(
      text: widget.existingValuation?.notes ?? '',
    );
    _selectedDate = widget.existingValuation?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Edit Valuation' : 'Add Valuation'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Date picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(DateFormat.yMMMd().format(_selectedDate)),
              subtitle: const Text('Valuation date'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
            ),
            const SizedBox(height: 16),
            // Value input
            TextFormField(
              controller: _valueController,
              decoration: const InputDecoration(
                labelText: 'Pre-Money Valuation',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valuation';
                }
                if (double.tryParse(value.replaceAll(',', '')) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
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
          onPressed: _save,
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final value = double.parse(_valueController.text.replaceAll(',', ''));
    final notes = _notesController.text.isEmpty ? null : _notesController.text;

    if (isEditing) {
      widget.provider.updateValuation(
        widget.existingValuation!.copyWith(
          date: _selectedDate,
          preMoneyValue: value,
          notes: notes,
        ),
      );
    } else {
      widget.provider.addValuation(
        Valuation(
          date: _selectedDate,
          preMoneyValue: value,
          method: ValuationMethod.manual,
          notes: notes,
        ),
      );
    }

    Navigator.pop(context);
  }
}
