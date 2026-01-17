import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/providers.dart';
import '../../domain/services/mfn_calculator.dart';
import '../../infrastructure/database/database.dart';
import '../../shared/formatters.dart';
import '../components/components.dart';

/// Page for managing convertible instruments (SAFEs and Notes).
class ConvertiblesPage extends ConsumerWidget {
  const ConvertiblesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convertiblesAsync = ref.watch(convertiblesStreamProvider);
    final summaryAsync = ref.watch(convertiblesSummaryProvider);
    final companyId = ref.watch(currentCompanyIdProvider);
    final stakeholders = ref.watch(stakeholdersStreamProvider);

    if (companyId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Convertibles'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const EmptyState(
          icon: Icons.business,
          title: 'No company selected',
          message: 'Please create or select a company first.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Convertibles'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(context, summaryAsync),
          Expanded(
            child: convertiblesAsync.when(
              data: (convertibles) {
                if (convertibles.isEmpty) {
                  return EmptyState.noItems(
                    itemType: 'convertible',
                    onAdd: () => _showAddDialog(
                      context,
                      ref,
                      companyId,
                      stakeholders.valueOrNull ?? [],
                    ),
                  );
                }
                return _buildConvertiblesList(
                  context,
                  ref,
                  convertibles,
                  stakeholders.valueOrNull ?? [],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState.error(
                message: e.toString(),
                onRetry: () => ref.invalidate(convertiblesStreamProvider),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(
          context,
          ref,
          companyId,
          stakeholders.valueOrNull ?? [],
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AsyncValue<ConvertiblesSummary> summaryAsync,
  ) {
    return PageHeader(
      title: 'Convertibles',
      child: summaryAsync.when(
        data: (summary) => SummaryCardsRow(
          cards: [
            SummaryCard(
              label: 'Outstanding',
              value: Formatters.compactCurrency(summary.outstandingPrincipal),
              icon: Icons.attach_money,
              color: Colors.orange,
            ),
            if (summary.safeCount > 0)
              SummaryCard(
                label: 'SAFEs',
                value: summary.safeCount.toString(),
                icon: Icons.shield_outlined,
                color: Colors.blue,
              ),
            if (summary.noteCount > 0)
              SummaryCard(
                label: 'Notes',
                value: summary.noteCount.toString(),
                icon: Icons.note_alt_outlined,
                color: Colors.purple,
              ),
            if (summary.convertedPrincipal > 0)
              SummaryCard(
                label: 'Converted',
                value: Formatters.compactCurrency(summary.convertedPrincipal),
                icon: Icons.swap_horiz,
                color: Colors.green,
              ),
          ],
        ),
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildConvertiblesList(
    BuildContext context,
    WidgetRef ref,
    List<Convertible> convertibles,
    List<Stakeholder> stakeholders,
  ) {
    final mfnUpgradesAsync = ref.watch(pendingMfnUpgradesProvider);

    return Column(
      children: [
        // MFN Banner
        mfnUpgradesAsync.when(
          data: (upgrades) {
            if (upgrades.isEmpty) return const SizedBox.shrink();
            return _buildMfnBanner(context, ref, upgrades, stakeholders);
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        // Convertibles list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: convertibles.length,
            itemBuilder: (context, index) {
              final convertible = convertibles[index];
              return _buildConvertibleCard(
                context,
                ref,
                convertible,
                stakeholders,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMfnBanner(
    BuildContext context,
    WidgetRef ref,
    List<MfnUpgradeOpportunity> upgrades,
    List<Stakeholder> stakeholders,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.purple, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${upgrades.length} MFN Upgrade${upgrades.length > 1 ? 's' : ''} Available',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () =>
                    _showMfnUpgradeDialog(context, ref, upgrades, stakeholders),
                icon: const Icon(Icons.upgrade, size: 18),
                label: const Text('Review'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Earlier investors with MFN clauses can upgrade to match better terms from later convertibles.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  void _showMfnUpgradeDialog(
    BuildContext context,
    WidgetRef ref,
    List<MfnUpgradeOpportunity> upgrades,
    List<Stakeholder> stakeholders,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          _MfnUpgradeDialog(upgrades: upgrades, stakeholders: stakeholders),
    );
  }

  Widget _buildConvertibleCard(
    BuildContext context,
    WidgetRef ref,
    Convertible convertible,
    List<Stakeholder> stakeholders,
  ) {
    final stakeholder = stakeholders.firstWhere(
      (s) => s.id == convertible.stakeholderId,
      orElse: () => Stakeholder(
        id: convertible.stakeholderId,
        companyId: convertible.companyId,
        name: 'Unknown',
        type: 'unknown',
        hasProRataRights: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return ExpandableCard(
      leading: EntityAvatar(
        name: stakeholder.name,
        type: EntityAvatarType.person,
        size: 40,
      ),
      title: stakeholder.name,
      subtitle: _formatConvertibleType(convertible.type),
      badges: [
        StatusBadge(
          label: _formatStatus(convertible.status),
          color: _getStatusColor(convertible.status),
        ),
      ],
      chips: [
        MetricChip(
          label: 'Principal',
          value: Formatters.compactCurrency(convertible.principal),
          color: Colors.green,
        ),
        if (convertible.valuationCap != null)
          MetricChip(
            label: 'Cap',
            value: Formatters.compactCurrency(convertible.valuationCap!),
            color: Colors.blue,
          ),
        if (convertible.discountPercent != null)
          MetricChip(
            label: 'Discount',
            value: '${convertible.discountPercent!.toInt()}%',
            color: Colors.purple,
          ),
      ],
      expandedContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Type', _formatConvertibleType(convertible.type)),
          _buildDetailRow(
            'Principal',
            Formatters.currency(convertible.principal),
          ),
          _buildDetailRow('Issue Date', Formatters.date(convertible.issueDate)),
          if (convertible.valuationCap != null)
            _buildDetailRow(
              'Valuation Cap',
              Formatters.currency(convertible.valuationCap!),
            ),
          if (convertible.discountPercent != null)
            _buildDetailRow('Discount', '${convertible.discountPercent}%'),
          if (convertible.interestRate != null)
            _buildDetailRow(
              'Interest Rate',
              '${convertible.interestRate}% p.a.',
            ),
          if (convertible.maturityDate != null)
            _buildDetailRow(
              'Maturity',
              Formatters.date(convertible.maturityDate!),
            ),
          if (convertible.hasMfn) _buildDetailRow('MFN', 'Yes'),
          if (convertible.hasProRata) _buildDetailRow('Pro-rata Rights', 'Yes'),
          if (convertible.notes != null && convertible.notes!.isNotEmpty)
            _buildDetailRow('Notes', convertible.notes!),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () =>
              _showEditDialog(context, ref, convertible, stakeholders),
          tooltip: 'Edit',
        ),
        if (convertible.status == 'outstanding')
          IconButton(
            icon: const Icon(Icons.swap_horiz_outlined),
            onPressed: () => _showConvertDialog(context, ref, convertible),
            tooltip: 'Convert',
          ),
        IconButton(
          icon: Icon(
            Icons.delete_outlined,
            color: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => _confirmDelete(context, ref, convertible),
          tooltip: 'Delete',
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatConvertibleType(String type) {
    switch (type) {
      case 'safe':
        return 'SAFE';
      case 'note':
        return 'Convertible Note';
      default:
        return type.toUpperCase();
    }
  }

  String _formatStatus(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'outstanding':
        return Colors.orange;
      case 'converted':
        return Colors.green;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  void _showAddDialog(
    BuildContext context,
    WidgetRef ref,
    String companyId,
    List<Stakeholder> stakeholders,
  ) {
    _showConvertibleDialog(
      context,
      ref,
      companyId: companyId,
      stakeholders: stakeholders,
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    Convertible convertible,
    List<Stakeholder> stakeholders,
  ) {
    _showConvertibleDialog(
      context,
      ref,
      convertible: convertible,
      stakeholders: stakeholders,
    );
  }

  void _showConvertibleDialog(
    BuildContext context,
    WidgetRef ref, {
    String? companyId,
    Convertible? convertible,
    required List<Stakeholder> stakeholders,
  }) {
    final isEditing = convertible != null;
    final principalController = TextEditingController(
      text: convertible?.principal.toString() ?? '',
    );
    final capController = TextEditingController(
      text: convertible?.valuationCap?.toString() ?? '',
    );
    final discountController = TextEditingController(
      text: convertible?.discountPercent?.toString() ?? '',
    );
    final interestController = TextEditingController(
      text: convertible?.interestRate?.toString() ?? '',
    );
    final notesController = TextEditingController(
      text: convertible?.notes ?? '',
    );

    String selectedType = convertible?.type ?? 'safe';
    String? selectedStakeholderId = convertible?.stakeholderId;
    DateTime issueDate = convertible?.issueDate ?? DateTime.now();
    DateTime? maturityDate = convertible?.maturityDate;
    bool hasMfn = convertible?.hasMfn ?? false;
    bool hasProRata = convertible?.hasProRata ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Convertible' : 'New Convertible'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedStakeholderId,
                  decoration: const InputDecoration(labelText: 'Stakeholder'),
                  items: stakeholders
                      .map(
                        (s) =>
                            DropdownMenuItem(value: s.id, child: Text(s.name)),
                      )
                      .toList(),
                  onChanged: isEditing
                      ? null
                      : (v) => setDialogState(() => selectedStakeholderId = v),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 'safe', child: Text('SAFE')),
                    DropdownMenuItem(
                      value: 'note',
                      child: Text('Convertible Note'),
                    ),
                  ],
                  onChanged: (v) =>
                      setDialogState(() => selectedType = v ?? 'safe'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: principalController,
                  decoration: const InputDecoration(
                    labelText: 'Principal Amount',
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: capController,
                  decoration: const InputDecoration(
                    labelText: 'Valuation Cap (optional)',
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: discountController,
                  decoration: const InputDecoration(
                    labelText: 'Discount % (optional)',
                    suffixText: '%',
                  ),
                  keyboardType: TextInputType.number,
                ),
                if (selectedType == 'note') ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: interestController,
                    decoration: const InputDecoration(
                      labelText: 'Interest Rate % (optional)',
                      suffixText: '% p.a.',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('MFN (Most Favored Nation)'),
                  value: hasMfn,
                  onChanged: (v) => setDialogState(() => hasMfn = v ?? false),
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: const Text('Pro-rata Rights'),
                  value: hasProRata,
                  onChanged: (v) =>
                      setDialogState(() => hasProRata = v ?? false),
                  contentPadding: EdgeInsets.zero,
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
                final principal = double.tryParse(principalController.text);
                if (principal == null || principal <= 0) return;
                if (!isEditing && selectedStakeholderId == null) return;

                final commands = ref.read(convertibleCommandsProvider.notifier);
                final cap = double.tryParse(capController.text);
                final discount = double.tryParse(discountController.text);
                final interest = double.tryParse(interestController.text);

                if (isEditing) {
                  // TODO: Implement updateConvertible in ConvertibleCommands
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit not yet implemented')),
                  );
                } else {
                  await commands.issueConvertible(
                    stakeholderId: selectedStakeholderId!,
                    type: selectedType,
                    principal: principal,
                    issueDate: issueDate,
                    valuationCap: cap,
                    discountPercent: discount,
                    interestRate: interest,
                    maturityDate: maturityDate,
                    hasMfn: hasMfn,
                    hasProRata: hasProRata,
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                  );
                }

                if (context.mounted) Navigator.pop(context);
              },
              child: Text(isEditing ? 'Save' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showConvertDialog(
    BuildContext context,
    WidgetRef ref,
    Convertible convertible,
  ) {
    final sharesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Convert to Shares'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Converting ${Formatters.currency(convertible.principal)} SAFE/Note',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: sharesController,
              decoration: const InputDecoration(labelText: 'Shares to Issue'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            const InfoBox(
              message:
                  'This will mark the convertible as converted and record the shares issued.',
              type: InfoBoxType.info,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final shares = int.tryParse(sharesController.text);
              if (shares == null || shares <= 0) return;

              // TODO: Need share class selection UI for proper conversion
              // await ref
              //     .read(convertibleCommandsProvider.notifier)
              //     .convertConvertible(
              //       convertibleId: convertible.id,
              //       roundId: roundId, // Need round selection
              //       toShareClassId: shareClassId, // Need share class selection
              //       sharesReceived: shares,
              //       conversionPrice: price, // Need to calculate
              //     );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Conversion not yet fully implemented'),
                ),
              );

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Convert'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Convertible convertible,
  ) async {
    final confirmed = await ConfirmDialog.showDelete(
      context: context,
      itemName: 'this convertible',
      additionalMessage: convertible.status == 'converted'
          ? 'Warning: This convertible has already been converted.'
          : null,
    );

    if (confirmed && context.mounted) {
      // TODO: Implement proper deletion with MFN reversion in ConvertibleCommands
      // For now, use cancelConvertible
      await ref
          .read(convertibleCommandsProvider.notifier)
          .cancelConvertible(
            convertibleId: convertible.id,
            reason: 'Deleted by user',
          );
    }
  }
}

/// Dialog for reviewing and applying MFN upgrades.
class _MfnUpgradeDialog extends ConsumerStatefulWidget {
  final List<MfnUpgradeOpportunity> upgrades;
  final List<Stakeholder> stakeholders;

  const _MfnUpgradeDialog({required this.upgrades, required this.stakeholders});

  @override
  ConsumerState<_MfnUpgradeDialog> createState() => _MfnUpgradeDialogState();
}

class _MfnUpgradeDialogState extends ConsumerState<_MfnUpgradeDialog> {
  final Set<int> _selectedIndices = {};
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    // Select all by default
    _selectedIndices.addAll(List.generate(widget.upgrades.length, (i) => i));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.purple),
          const SizedBox(width: 8),
          const Text('MFN Upgrades'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The following convertibles have MFN clauses and can be upgraded to match better terms from later investors:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.upgrades.length,
                itemBuilder: (context, index) {
                  final upgrade = widget.upgrades[index];
                  final stakeholder = widget.stakeholders.firstWhere(
                    (s) => s.id == upgrade.target.stakeholderId,
                    orElse: () => Stakeholder(
                      id: '',
                      companyId: '',
                      name: 'Unknown',
                      type: 'unknown',
                      hasProRataRights: false,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ),
                  );
                  final isSelected = _selectedIndices.contains(index);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: CheckboxListTile(
                      value: isSelected,
                      onChanged: _isApplying
                          ? null
                          : (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedIndices.add(index);
                                } else {
                                  _selectedIndices.remove(index);
                                }
                              });
                            },
                      title: Text(
                        stakeholder.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${Formatters.compactCurrency(upgrade.target.principal)} ${upgrade.target.type.toUpperCase()}',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              upgrade.upgradeDescription,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.purple,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isApplying ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isApplying || _selectedIndices.isEmpty
              ? null
              : () => _applySelected(),
          icon: _isApplying
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check, size: 18),
          label: Text(
            _isApplying
                ? 'Applying...'
                : 'Apply ${_selectedIndices.length} Upgrade${_selectedIndices.length > 1 ? 's' : ''}',
          ),
          style: FilledButton.styleFrom(backgroundColor: Colors.purple),
        ),
      ],
    );
  }

  Future<void> _applySelected() async {
    setState(() => _isApplying = true);

    try {
      // TODO: Wire up MFN upgrade using ConvertibleCommands.applyMfnUpgrade
      // The method exists but requires mapping from MfnUpgradeOpportunity to the command params
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('MFN upgrade not yet implemented'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error applying upgrades: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isApplying = false);
      }
    }
  }
}
