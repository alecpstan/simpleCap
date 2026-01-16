import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/providers.dart';
import '../../infrastructure/database/database.dart';
import '../../shared/formatters.dart';
import '../components/components.dart';

/// Page for managing warrants.
class WarrantsPage extends ConsumerWidget {
  const WarrantsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warrantsAsync = ref.watch(warrantsStreamProvider);
    final summary = ref.watch(warrantsSummaryProvider);
    final companyId = ref.watch(currentCompanyIdProvider);
    final stakeholders = ref.watch(stakeholdersStreamProvider);
    final shareClasses = ref.watch(shareClassesStreamProvider);
    final rounds = ref.watch(roundsStreamProvider);

    if (companyId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Warrants'),
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
        title: const Text('Warrants'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(context, summary),
          Expanded(
            child: warrantsAsync.when(
              data: (warrants) {
                if (warrants.isEmpty) {
                  return EmptyState.noItems(
                    itemType: 'warrant',
                    onAdd: () => _showAddDialog(
                      context,
                      ref,
                      companyId,
                      stakeholders.valueOrNull ?? [],
                      shareClasses.valueOrNull ?? [],
                      rounds.valueOrNull ?? [],
                    ),
                  );
                }
                return _buildWarrantsList(
                  context,
                  ref,
                  warrants,
                  stakeholders.valueOrNull ?? [],
                  shareClasses.valueOrNull ?? [],
                  rounds.valueOrNull ?? [],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState.error(
                message: e.toString(),
                onRetry: () => ref.invalidate(warrantsStreamProvider),
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
          shareClasses.valueOrNull ?? [],
          rounds.valueOrNull ?? [],
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WarrantsSummary summary) {
    final cards = <Widget>[
      SummaryCard(
        label: 'Outstanding',
        value: Formatters.compactNumber(summary.outstandingWarrants),
        icon: Icons.pending_actions,
        color: Colors.blue,
      ),
      SummaryCard(
        label: 'Issued',
        value: Formatters.compactNumber(summary.totalIssued),
        icon: Icons.assignment,
        color: Colors.green,
      ),
      if (summary.totalExercised > 0)
        SummaryCard(
          label: 'Exercised',
          value: Formatters.compactNumber(summary.totalExercised),
          icon: Icons.check_circle_outline,
          color: Colors.teal,
        ),
      SummaryCard(
        label: 'Active',
        value: summary.activeWarrants.toString(),
        icon: Icons.receipt_long,
        color: Colors.orange,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Warrants', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate card width: max 2 per row with 8px spacing
              final spacing = 8.0;
              final cardsPerRow = cards.length == 1 ? 1 : 2;
              final totalSpacing = spacing * (cardsPerRow - 1);
              final cardWidth =
                  (constraints.maxWidth - totalSpacing) / cardsPerRow;
              // Full width for last card if odd number
              final fullWidth = constraints.maxWidth;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: cards.asMap().entries.map((entry) {
                  final index = entry.key;
                  final card = entry.value;
                  // Last card gets full width if odd total
                  final isLastOdd =
                      cards.length.isOdd && index == cards.length - 1;
                  final width = isLastOdd ? fullWidth : cardWidth;
                  return SizedBox(width: width, child: card);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWarrantsList(
    BuildContext context,
    WidgetRef ref,
    List<Warrant> warrants,
    List<Stakeholder> stakeholders,
    List<ShareClassesData> shareClasses,
    List<Round> rounds,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: warrants.length,
      itemBuilder: (context, index) {
        final warrant = warrants[index];
        return _buildWarrantCard(
          context,
          ref,
          warrant,
          stakeholders,
          shareClasses,
          rounds,
        );
      },
    );
  }

  Widget _buildWarrantCard(
    BuildContext context,
    WidgetRef ref,
    Warrant warrant,
    List<Stakeholder> stakeholders,
    List<ShareClassesData> shareClasses,
    List<Round> rounds,
  ) {
    final stakeholder = stakeholders.firstWhere(
      (s) => s.id == warrant.stakeholderId,
      orElse: () => Stakeholder(
        id: warrant.stakeholderId,
        companyId: warrant.companyId,
        name: 'Unknown',
        type: 'unknown',
        hasProRataRights: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    final shareClass = shareClasses.firstWhere(
      (s) => s.id == warrant.shareClassId,
      orElse: () => ShareClassesData(
        id: warrant.shareClassId,
        companyId: warrant.companyId,
        name: 'Unknown',
        type: 'unknown',
        votingMultiplier: 1.0,
        liquidationPreference: 1.0,
        isParticipating: false,
        dividendRate: 0,
        seniority: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    final round = warrant.roundId != null
        ? rounds.firstWhere(
            (r) => r.id == warrant.roundId,
            orElse: () => Round(
              id: '',
              companyId: warrant.companyId,
              name: 'Unknown',
              type: 'unknown',
              status: 'unknown',
              date: DateTime.now(),
              amountRaised: 0,
              displayOrder: 0,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          )
        : null;

    final outstanding =
        warrant.quantity - warrant.exercisedCount - warrant.cancelledCount;

    return ExpandableCard(
      leading: EntityAvatar(
        name: stakeholder.name,
        type: EntityAvatarType.person,
        size: 40,
      ),
      title: stakeholder.name,
      subtitle:
          '${Formatters.number(warrant.quantity)} warrants @ ${Formatters.currency(warrant.strikePrice)}',
      badges: [
        StatusBadge(
          label: _formatStatus(warrant.status),
          color: _getStatusColor(warrant.status),
        ),
      ],
      chips: [
        MetricChip(
          label: 'Outstanding',
          value: Formatters.compactNumber(outstanding),
          color: Colors.blue,
        ),
        if (warrant.exercisedCount > 0)
          MetricChip(
            label: 'Exercised',
            value: Formatters.compactNumber(warrant.exercisedCount),
            color: Colors.green,
          ),
      ],
      expandedContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Holder', stakeholder.name),
          _buildDetailRow('Share Class', shareClass.name),
          _buildDetailRow('Quantity', Formatters.number(warrant.quantity)),
          _buildDetailRow(
            'Strike Price',
            Formatters.currency(warrant.strikePrice),
          ),
          _buildDetailRow('Issue Date', Formatters.date(warrant.issueDate)),
          _buildDetailRow('Expiry Date', Formatters.date(warrant.expiryDate)),
          _buildDetailRow(
            'Exercised',
            Formatters.number(warrant.exercisedCount),
          ),
          _buildDetailRow(
            'Cancelled',
            Formatters.number(warrant.cancelledCount),
          ),
          _buildDetailRow('Outstanding', Formatters.number(outstanding)),
          if (round != null) _buildDetailRow('Round', round.name),
          if (warrant.notes != null && warrant.notes!.isNotEmpty)
            _buildDetailRow('Notes', warrant.notes!),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => _showEditDialog(
            context,
            ref,
            warrant,
            stakeholders,
            shareClasses,
            rounds,
          ),
          tooltip: 'Edit',
        ),
        if (outstanding > 0 && warrant.status == 'active')
          IconButton(
            icon: const Icon(Icons.play_arrow_outlined),
            onPressed: () =>
                _showExerciseDialog(context, ref, warrant, outstanding),
            tooltip: 'Exercise',
          ),
        IconButton(
          icon: Icon(
            Icons.delete_outlined,
            color: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => _confirmDelete(context, ref, warrant),
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

  String _formatStatus(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.grey;
      case 'active':
        return Colors.green;
      case 'exercised':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'expired':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showAddDialog(
    BuildContext context,
    WidgetRef ref,
    String companyId,
    List<Stakeholder> stakeholders,
    List<ShareClassesData> shareClasses,
    List<Round> rounds,
  ) {
    _showWarrantDialog(
      context,
      ref,
      companyId: companyId,
      stakeholders: stakeholders,
      shareClasses: shareClasses,
      rounds: rounds,
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    Warrant warrant,
    List<Stakeholder> stakeholders,
    List<ShareClassesData> shareClasses,
    List<Round> rounds,
  ) {
    _showWarrantDialog(
      context,
      ref,
      warrant: warrant,
      stakeholders: stakeholders,
      shareClasses: shareClasses,
      rounds: rounds,
    );
  }

  void _showWarrantDialog(
    BuildContext context,
    WidgetRef ref, {
    String? companyId,
    Warrant? warrant,
    required List<Stakeholder> stakeholders,
    required List<ShareClassesData> shareClasses,
    required List<Round> rounds,
  }) {
    final isEditing = warrant != null;
    final quantityController = TextEditingController(
      text: warrant?.quantity.toString() ?? '',
    );
    final strikeController = TextEditingController(
      text: warrant?.strikePrice.toString() ?? '',
    );
    final notesController = TextEditingController(text: warrant?.notes ?? '');

    String? selectedStakeholderId = warrant?.stakeholderId;
    String? selectedShareClassId = warrant?.shareClassId;
    String? selectedRoundId = warrant?.roundId;
    DateTime issueDate = warrant?.issueDate ?? DateTime.now();
    DateTime expiryDate =
        warrant?.expiryDate ??
        DateTime.now().add(const Duration(days: 365 * 10));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Warrant' : 'New Warrant'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedStakeholderId,
                  decoration: const InputDecoration(labelText: 'Holder'),
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
                  value: selectedShareClassId,
                  decoration: const InputDecoration(labelText: 'Share Class'),
                  items: shareClasses
                      .map(
                        (s) =>
                            DropdownMenuItem(value: s.id, child: Text(s.name)),
                      )
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => selectedShareClassId = v),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Number of Warrants',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: strikeController,
                  decoration: const InputDecoration(
                    labelText: 'Strike Price',
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  value: selectedRoundId,
                  decoration: const InputDecoration(
                    labelText: 'Associated Round',
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None')),
                    ...rounds.map(
                      (r) => DropdownMenuItem(value: r.id, child: Text(r.name)),
                    ),
                  ],
                  onChanged: (v) => setDialogState(() => selectedRoundId = v),
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
                final quantity = int.tryParse(quantityController.text);
                final strike = double.tryParse(strikeController.text);
                if (quantity == null || quantity <= 0) return;
                if (strike == null || strike <= 0) return;
                if (!isEditing && selectedStakeholderId == null) return;
                if (selectedShareClassId == null) return;

                final mutations = ref.read(warrantMutationsProvider.notifier);

                if (isEditing) {
                  await mutations.updateWarrant(
                    id: warrant.id,
                    shareClassId: selectedShareClassId,
                    quantity: quantity,
                    strikePrice: strike,
                    issueDate: issueDate,
                    expiryDate: expiryDate,
                    roundId: selectedRoundId,
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                  );
                } else {
                  await mutations.create(
                    companyId: companyId!,
                    stakeholderId: selectedStakeholderId!,
                    shareClassId: selectedShareClassId!,
                    quantity: quantity,
                    strikePrice: strike,
                    issueDate: issueDate,
                    expiryDate: expiryDate,
                    roundId: selectedRoundId,
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

  void _showExerciseDialog(
    BuildContext context,
    WidgetRef ref,
    Warrant warrant,
    int maxShares,
  ) {
    final sharesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exercise Warrants'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Up to ${Formatters.number(maxShares)} warrants available',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Strike price: ${Formatters.currency(warrant.strikePrice)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: sharesController,
              decoration: const InputDecoration(
                labelText: 'Warrants to Exercise',
              ),
              keyboardType: TextInputType.number,
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
              if (shares == null || shares <= 0 || shares > maxShares) return;

              await ref
                  .read(warrantMutationsProvider.notifier)
                  .exercise(id: warrant.id, sharesToExercise: shares);

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Exercise'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Warrant warrant,
  ) async {
    final confirmed = await ConfirmDialog.showDelete(
      context: context,
      itemName: 'this warrant',
      additionalMessage: warrant.exercisedCount > 0
          ? 'Warning: ${warrant.exercisedCount} warrants have already been exercised.'
          : null,
    );

    if (confirmed && context.mounted) {
      await ref.read(warrantMutationsProvider.notifier).delete(warrant.id);
    }
  }
}
