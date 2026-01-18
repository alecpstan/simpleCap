import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/providers.dart';
import '../../domain/constants/type_constants.dart';
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
    final deleteEnabled = ref.watch(deleteEnabledProvider).valueOrNull ?? false;

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
                  deleteEnabled,
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
    bool deleteEnabled,
  ) {
    final mfnUpgradesAsync = ref.watch(pendingMfnUpgradesProvider);

    return Column(
      children: [
        // MFN Notice using CollapsibleNotice
        mfnUpgradesAsync.when(
          data: (upgrades) {
            if (upgrades.isEmpty) return const SizedBox.shrink();
            return CollapsibleNotice.warning(
              persistKey: 'convertibles_mfn_upgrades_notice',
              title: 'MFN Upgrades Available',
              count: upgrades.length,
              message:
                  'Earlier investors with MFN clauses can upgrade to match better terms from later convertibles. '
                  'Tap "Review Upgrades" to see details and apply upgrades.',
              action: FilledButton.icon(
                onPressed: () =>
                    _showMfnUpgradeDialog(context, ref, upgrades, stakeholders),
                icon: const Icon(Icons.upgrade, size: 18),
                label: const Text('Review Upgrades'),
                style: FilledButton.styleFrom(backgroundColor: Colors.orange),
              ),
            );
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
                deleteEnabled,
              );
            },
          ),
        ),
      ],
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
    bool deleteEnabled,
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
      expandedContent: _ConvertibleExpandedContent(
        convertible: convertible,
        stakeholders: stakeholders,
        deleteEnabled: deleteEnabled,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () =>
              _showEditDialog(context, ref, convertible, stakeholders),
          tooltip: 'Edit',
        ),
        // Only show convert button if voluntary conversion is allowed
        if (convertible.status == 'outstanding' &&
            convertible.allowsVoluntaryConversion)
          IconButton(
            icon: const Icon(Icons.swap_horiz_outlined),
            onPressed: () => _showConvertDialog(context, ref, convertible),
            tooltip: 'Convert',
          ),
        if (convertible.status == 'outstanding')
          IconButton(
            icon: Icon(
              Icons.cancel_outlined,
              color: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => _confirmCancel(context, ref, convertible),
            tooltip: 'Cancel',
          ),
        if (deleteEnabled)
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
    final qualifiedThresholdController = TextEditingController(
      text: convertible?.qualifiedFinancingThreshold?.toString() ?? '',
    );
    final liquidityMultipleController = TextEditingController(
      text: convertible?.liquidityPayoutMultiple?.toString() ?? '',
    );

    String selectedType = convertible?.type ?? 'safe';
    String? selectedStakeholderId = convertible?.stakeholderId;
    DateTime issueDate = convertible?.issueDate ?? DateTime.now();
    DateTime? maturityDate = convertible?.maturityDate;
    bool hasMfn = convertible?.hasMfn ?? false;
    bool hasProRata = convertible?.hasProRata ?? false;

    // Advanced terms state
    String? maturityBehavior = convertible?.maturityBehavior;
    bool allowsVoluntaryConversion =
        convertible?.allowsVoluntaryConversion ?? false;
    String? liquidityEventBehavior = convertible?.liquidityEventBehavior;
    String? dissolutionBehavior = convertible?.dissolutionBehavior;
    String? preferredShareClassId = convertible?.preferredShareClassId;

    // Get share classes for dropdown
    final shareClasses = ref.read(shareClassesStreamProvider).valueOrNull ?? [];

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

                // Advanced Terms Expandable Section
                const SizedBox(height: 16),
                ExpansionTile(
                  title: const Text('Advanced Terms'),
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(top: 8),
                  initiallyExpanded:
                      maturityBehavior != null ||
                      allowsVoluntaryConversion ||
                      liquidityEventBehavior != null ||
                      dissolutionBehavior != null,
                  children: [
                    // Qualified Financing Threshold
                    TextField(
                      controller: qualifiedThresholdController,
                      decoration: const InputDecoration(
                        labelText: 'Qualified Financing Threshold',
                        prefixText: '\$',
                        helperText: 'Minimum round size to trigger conversion',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Maturity Behavior
                    DropdownButtonFormField<String>(
                      value: maturityBehavior,
                      decoration: const InputDecoration(
                        labelText: 'At Maturity',
                        helperText: 'What happens when the instrument matures',
                      ),
                      items: MaturityBehavior.all
                          .map(
                            (b) => DropdownMenuItem(
                              value: b,
                              child: Text(MaturityBehavior.displayName(b)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setDialogState(() => maturityBehavior = v),
                    ),
                    const SizedBox(height: 16),

                    // Voluntary Conversion
                    CheckboxListTile(
                      title: const Text('Allows Voluntary Conversion'),
                      subtitle: const Text(
                        'Holder can elect to convert anytime',
                      ),
                      value: allowsVoluntaryConversion,
                      onChanged: (v) => setDialogState(
                        () => allowsVoluntaryConversion = v ?? false,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),

                    // Liquidity Event Behavior
                    DropdownButtonFormField<String>(
                      value: liquidityEventBehavior,
                      decoration: const InputDecoration(
                        labelText: 'On Liquidity Event',
                        helperText: 'M&A, IPO, or change of control',
                      ),
                      items: LiquidityEventBehavior.all
                          .map(
                            (b) => DropdownMenuItem(
                              value: b,
                              child: Text(
                                LiquidityEventBehavior.displayName(b),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setDialogState(() => liquidityEventBehavior = v),
                    ),
                    if (liquidityEventBehavior ==
                        LiquidityEventBehavior.cashPayout) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: liquidityMultipleController,
                        decoration: const InputDecoration(
                          labelText: 'Payout Multiple',
                          suffixText: 'x',
                          helperText: 'e.g. 2.0 = 2x principal',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Dissolution Behavior
                    DropdownButtonFormField<String>(
                      value: dissolutionBehavior,
                      decoration: const InputDecoration(
                        labelText: 'On Dissolution',
                        helperText: 'Company wind-down or bankruptcy',
                      ),
                      items: DissolutionBehavior.all
                          .map(
                            (b) => DropdownMenuItem(
                              value: b,
                              child: Text(DissolutionBehavior.displayName(b)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setDialogState(() => dissolutionBehavior = v),
                    ),
                    const SizedBox(height: 16),

                    // Preferred Share Class for Conversion
                    DropdownButtonFormField<String?>(
                      value: preferredShareClassId,
                      decoration: const InputDecoration(
                        labelText: 'Convert to Share Class',
                        helperText: 'Preferred class for standalone conversion',
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Same as round (default)'),
                        ),
                        ...shareClasses.map(
                          (sc) => DropdownMenuItem(
                            value: sc.id,
                            child: Text(sc.name),
                          ),
                        ),
                      ],
                      onChanged: (v) =>
                          setDialogState(() => preferredShareClassId = v),
                    ),
                  ],
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
                final qualifiedThreshold = double.tryParse(
                  qualifiedThresholdController.text,
                );
                final liquidityMultiple = double.tryParse(
                  liquidityMultipleController.text,
                );
                final discount = double.tryParse(discountController.text);
                final interest = double.tryParse(interestController.text);

                if (isEditing) {
                  await commands.updateConvertible(
                    convertibleId: convertible!.id,
                    principal: principal,
                    valuationCap: cap,
                    discountPercent: discount,
                    interestRate: interest,
                    issueDate: issueDate,
                    maturityDate: maturityDate,
                    hasMfn: hasMfn,
                    hasProRata: hasProRata,
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                    maturityBehavior: maturityBehavior,
                    allowsVoluntaryConversion: allowsVoluntaryConversion,
                    liquidityEventBehavior: liquidityEventBehavior,
                    liquidityPayoutMultiple: liquidityMultiple,
                    dissolutionBehavior: dissolutionBehavior,
                    preferredShareClassId: preferredShareClassId,
                    qualifiedFinancingThreshold: qualifiedThreshold,
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
                    maturityBehavior: maturityBehavior,
                    allowsVoluntaryConversion: allowsVoluntaryConversion,
                    liquidityEventBehavior: liquidityEventBehavior,
                    liquidityPayoutMultiple: liquidityMultiple,
                    dissolutionBehavior: dissolutionBehavior,
                    preferredShareClassId: preferredShareClassId,
                    qualifiedFinancingThreshold: qualifiedThreshold,
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

  Future<void> _showConvertDialog(
    BuildContext context,
    WidgetRef ref,
    Convertible convertible,
  ) async {
    // Get stakeholder name
    final stakeholders = ref.read(stakeholdersStreamProvider).valueOrNull ?? [];
    final stakeholder = stakeholders
        .where((s) => s.id == convertible.stakeholderId)
        .firstOrNull;

    await ConvertConvertibleDialog.show(
      context: context,
      convertible: convertible,
      stakeholderName: stakeholder?.name,
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    WidgetRef ref,
    Convertible convertible,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Cancel Convertible',
      message:
          'Are you sure you want to cancel this ${_formatConvertibleType(convertible.type)}? This will record a cancellation event.',
      confirmLabel: 'Cancel Convertible',
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      await ref
          .read(convertibleCommandsProvider.notifier)
          .cancelConvertible(
            convertibleId: convertible.id,
            reason: 'Cancelled by user',
          );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Convertible convertible,
  ) async {
    // Preview cascade impact
    final cascadeImpact = await ref
        .read(eventLedgerProvider.notifier)
        .previewCascadeDelete(
          entityId: convertible.id,
          entityType: EntityType.convertible,
        );

    final impactLines = <String>[];
    cascadeImpact.forEach((type, count) {
      if (count > 0) {
        impactLines.add('• $count ${type.name}(s)');
      }
    });

    String message;
    if (impactLines.isEmpty) {
      message = convertible.status == 'converted'
          ? 'Warning: This convertible has already been converted. This cannot be undone.'
          : 'Are you sure you want to permanently delete this convertible? This cannot be undone.';
    } else {
      message = 'This will permanently delete:\n${impactLines.join('\n')}\n\n';
      if (convertible.status == 'converted') {
        message += 'Warning: This convertible has already been converted.\n';
      }
      message += 'This cannot be undone.';
    }

    final confirmed = await ConfirmDialog.showDelete(
      context: context,
      itemName: 'convertible',
      customMessage: message,
    );

    if (confirmed && context.mounted) {
      await ref
          .read(convertibleCommandsProvider.notifier)
          .deleteConvertible(convertibleId: convertible.id);
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
      final commands = ref.read(convertibleCommandsProvider.notifier);

      for (final index in _selectedIndices) {
        final upgrade = widget.upgrades[index];
        await commands.applyMfnUpgrade(
          targetConvertibleId: upgrade.target.id,
          sourceConvertibleId: upgrade.source.id,
          previousDiscountPercent: upgrade.target.discountPercent,
          previousValuationCap: upgrade.target.valuationCap,
          previousHasProRata: upgrade.target.hasProRata,
          newDiscountPercent: upgrade.newDiscountPercent,
          newValuationCap: upgrade.newValuationCap,
          newHasProRata: upgrade.addsProRata,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Applied ${_selectedIndices.length} MFN upgrade${_selectedIndices.length > 1 ? 's' : ''} successfully',
            ),
            backgroundColor: Colors.green,
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

// =============================================================================
// Convertible Expanded Content Widget
// =============================================================================

/// Expanded content for a convertible card, showing details and MFN upgrades.
class _ConvertibleExpandedContent extends ConsumerWidget {
  final Convertible convertible;
  final List<Stakeholder> stakeholders;
  final bool deleteEnabled;

  const _ConvertibleExpandedContent({
    required this.convertible,
    required this.stakeholders,
    required this.deleteEnabled,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mfnUpgradesAsync = ref.watch(
      mfnUpgradesForTargetProvider(convertible.id),
    );
    final convertiblesAsync = ref.watch(convertiblesStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Basic details
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
          _buildDetailRow('Interest Rate', '${convertible.interestRate}% p.a.'),
        if (convertible.maturityDate != null)
          _buildDetailRow(
            'Maturity',
            Formatters.date(convertible.maturityDate!),
          ),
        if (convertible.hasMfn) _buildDetailRow('MFN', 'Yes'),
        if (convertible.hasProRata) _buildDetailRow('Pro-rata Rights', 'Yes'),
        if (convertible.notes != null && convertible.notes!.isNotEmpty)
          _buildDetailRow('Notes', convertible.notes!),

        // Advanced Terms section (if any are set)
        if (_hasAdvancedTerms(convertible)) ...[
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Advanced Terms',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (convertible.qualifiedFinancingThreshold != null)
            _buildDetailRow(
              'Qualified Financing',
              '≥ ${Formatters.currency(convertible.qualifiedFinancingThreshold!)}',
            ),
          if (convertible.maturityBehavior != null)
            _buildDetailRow(
              'At Maturity',
              MaturityBehavior.displayName(convertible.maturityBehavior!),
            ),
          if (convertible.allowsVoluntaryConversion)
            _buildDetailRow('Voluntary Conversion', 'Allowed'),
          if (convertible.liquidityEventBehavior != null)
            _buildDetailRow(
              'On Liquidity Event',
              LiquidityEventBehavior.displayName(
                convertible.liquidityEventBehavior!,
              ),
            ),
          if (convertible.liquidityPayoutMultiple != null)
            _buildDetailRow(
              'Payout Multiple',
              '${convertible.liquidityPayoutMultiple}x',
            ),
          if (convertible.dissolutionBehavior != null)
            _buildDetailRow(
              'On Dissolution',
              DissolutionBehavior.displayName(convertible.dissolutionBehavior!),
            ),
          if (convertible.preferredShareClassId != null)
            _buildPreferredShareClassRow(context, ref),
        ],

        // MFN Upgrades section
        mfnUpgradesAsync.when(
          data: (upgrades) {
            if (upgrades.isEmpty) return const SizedBox.shrink();

            final allConvertibles = convertiblesAsync.valueOrNull ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Applied MFN Upgrades',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...upgrades.map(
                  (upgrade) => _buildMfnUpgradeBox(
                    context,
                    ref,
                    upgrade,
                    allConvertibles,
                  ),
                ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
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

  bool _hasAdvancedTerms(Convertible conv) {
    return conv.maturityBehavior != null ||
        conv.allowsVoluntaryConversion ||
        conv.liquidityEventBehavior != null ||
        conv.dissolutionBehavior != null ||
        conv.preferredShareClassId != null ||
        conv.qualifiedFinancingThreshold != null;
  }

  Widget _buildPreferredShareClassRow(BuildContext context, WidgetRef ref) {
    final shareClasses =
        ref.watch(shareClassesStreamProvider).valueOrNull ?? [];
    final shareClass = shareClasses
        .where((sc) => sc.id == convertible.preferredShareClassId)
        .firstOrNull;
    return _buildDetailRow('Converts to', shareClass?.name ?? 'Unknown class');
  }

  Widget _buildMfnUpgradeBox(
    BuildContext context,
    WidgetRef ref,
    MfnUpgrade upgrade,
    List<Convertible> allConvertibles,
  ) {
    final sourceConvertible = allConvertibles
        .where((c) => c.id == upgrade.sourceConvertibleId)
        .firstOrNull;
    final sourceStakeholder = sourceConvertible != null
        ? stakeholders
              .where((s) => s.id == sourceConvertible.stakeholderId)
              .firstOrNull
        : null;

    // Build description of what changed
    final changes = <String>[];
    if (upgrade.newDiscountPercent != null) {
      changes.add(
        'Discount → ${(upgrade.newDiscountPercent! * 100).toStringAsFixed(0)}%',
      );
    }
    if (upgrade.newValuationCap != null) {
      changes.add(
        'Cap → ${Formatters.compactCurrency(upgrade.newValuationCap!)}',
      );
    }
    if (upgrade.newHasProRata && !upgrade.previousHasProRata) {
      changes.add('Pro-rata added');
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showMfnUpgradeDetail(
          context,
          ref,
          upgrade,
          sourceConvertible,
          sourceStakeholder,
        ),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.upgrade, color: Colors.purple.shade400, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      changes.join(' • '),
                      style: TextStyle(
                        color: Colors.purple.shade700,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'From ${sourceStakeholder?.name ?? 'Unknown'} • ${Formatters.date(upgrade.upgradeDate)}',
                      style: TextStyle(
                        color: Colors.purple.shade400,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.purple.shade400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMfnUpgradeDetail(
    BuildContext context,
    WidgetRef ref,
    MfnUpgrade upgrade,
    Convertible? sourceConvertible,
    Stakeholder? sourceStakeholder,
  ) {
    MfnUpgradeDetailDialog.show(
      context: context,
      upgrade: upgrade,
      sourceConvertible: sourceConvertible,
      sourceStakeholder: sourceStakeholder,
      showDeleteButton: deleteEnabled,
      onDelete: deleteEnabled
          ? () => _confirmDeleteUpgrade(context, ref, upgrade)
          : null,
    );
  }

  void _confirmDeleteUpgrade(
    BuildContext context,
    WidgetRef ref,
    MfnUpgrade upgrade,
  ) async {
    final confirmed = await ConfirmDialog.showDelete(
      context: context,
      itemName: 'MFN Upgrade',
      customMessage:
          'Are you sure you want to delete this MFN upgrade? This will remove the upgrade record but will not revert the convertible terms.',
    );

    if (confirmed && context.mounted) {
      try {
        await ref
            .read(eventLedgerProvider.notifier)
            .permanentDeleteEntity(upgrade.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('MFN upgrade deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting upgrade: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
