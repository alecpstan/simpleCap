import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/providers.dart';
import '../../infrastructure/database/database.dart';
import '../../shared/formatters.dart';
import '../components/components.dart';

/// Page for managing share transfers (secondary sales).
class TransfersPage extends ConsumerWidget {
  const TransfersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyId = ref.watch(currentCompanyIdProvider);
    final transfersAsync = ref.watch(transfersStreamProvider);
    final summaryAsync = ref.watch(transfersSummaryProvider);
    final stakeholdersAsync = ref.watch(stakeholdersStreamProvider);
    final shareClassesAsync = ref.watch(shareClassesStreamProvider);

    if (companyId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Transfers'),
          leading: const BackButton(),
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
        title: const Text('Share Transfers'),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          _buildHeader(context, summaryAsync),
          Expanded(
            child: transfersAsync.when(
              data: (transfers) {
                if (transfers.isEmpty) {
                  return EmptyState.noItems(
                    itemType: 'transfer',
                    onAdd: () => _showAddDialog(
                      context,
                      ref,
                      companyId,
                      stakeholdersAsync.valueOrNull ?? [],
                      shareClassesAsync.valueOrNull ?? [],
                    ),
                  );
                }
                return _buildTransfersList(
                  context,
                  ref,
                  transfers,
                  stakeholdersAsync.valueOrNull ?? [],
                  shareClassesAsync.valueOrNull ?? [],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState.error(
                message: e.toString(),
                onRetry: () => ref.invalidate(transfersStreamProvider),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(
          context,
          ref,
          companyId,
          stakeholdersAsync.valueOrNull ?? [],
          shareClassesAsync.valueOrNull ?? [],
        ),
        icon: const Icon(Icons.swap_horiz),
        label: const Text('New Transfer'),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TransfersSummary summary) {
    final cards = <Widget>[
      SummaryCard(
        label: 'Total Transfers',
        value: summary.totalTransfers.toString(),
        icon: Icons.swap_horiz,
        color: Colors.blue,
      ),
      SummaryCard(
        label: 'Pending',
        value: summary.pendingTransfers.toString(),
        icon: Icons.pending_actions,
        color: Colors.orange,
      ),
      SummaryCard(
        label: 'Completed',
        value: summary.completedTransfers.toString(),
        icon: Icons.check_circle,
        color: Colors.green,
      ),
      SummaryCard(
        label: 'Total Value',
        value: Formatters.compactCurrency(summary.totalValue),
        icon: Icons.attach_money,
        color: Colors.teal,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Secondary Sales & Transfers',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final spacing = 8.0;
              // Max 2 cards per row
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

  Widget _buildTransfersList(
    BuildContext context,
    WidgetRef ref,
    List<Transfer> transfers,
    List<Stakeholder> stakeholders,
    List<ShareClassesData> shareClasses,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: transfers.length,
      itemBuilder: (context, index) {
        final transfer = transfers[index];
        return _buildTransferCard(
          context,
          ref,
          transfer,
          stakeholders,
          shareClasses,
        );
      },
    );
  }

  Widget _buildTransferCard(
    BuildContext context,
    WidgetRef ref,
    Transfer transfer,
    List<Stakeholder> stakeholders,
    List<ShareClassesData> shareClasses,
  ) {
    final seller = stakeholders.firstWhere(
      (s) => s.id == transfer.sellerStakeholderId,
      orElse: () => Stakeholder(
        id: transfer.sellerStakeholderId,
        companyId: transfer.companyId,
        name: 'Unknown',
        type: 'investor',
        hasProRataRights: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    final buyer = stakeholders.firstWhere(
      (s) => s.id == transfer.buyerStakeholderId,
      orElse: () => Stakeholder(
        id: transfer.buyerStakeholderId,
        companyId: transfer.companyId,
        name: 'Unknown',
        type: 'investor',
        hasProRataRights: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    final shareClass = shareClasses.firstWhere(
      (sc) => sc.id == transfer.shareClassId,
      orElse: () => ShareClassesData(
        id: transfer.shareClassId,
        companyId: transfer.companyId,
        name: 'Unknown',
        type: 'common',
        votingMultiplier: 1.0,
        liquidationPreference: 1.0,
        isParticipating: false,
        dividendRate: 0,
        seniority: 0,
        antiDilutionType: 'none',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    final totalValue = transfer.shareCount * transfer.pricePerShare;
    final statusColor = _getStatusColor(transfer.status);
    final typeLabel = _getTypeLabel(transfer.type);

    return ExpandableCard(
      leading: CircleAvatar(
        backgroundColor: statusColor.withValues(alpha: 0.2),
        child: Icon(_getTypeIcon(transfer.type), color: statusColor, size: 20),
      ),
      title: '${seller.name} → ${buyer.name}',
      subtitle:
          '${Formatters.number(transfer.shareCount)} ${shareClass.name} shares',
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            Formatters.currency(totalValue),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          StatusBadge(label: transfer.status.toUpperCase(), color: statusColor),
        ],
      ),
      expandedContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          _buildDetailRow('Type', typeLabel),
          _buildDetailRow('Share Class', shareClass.name),
          _buildDetailRow('Shares', Formatters.number(transfer.shareCount)),
          _buildDetailRow(
            'Price/Share',
            Formatters.currency(transfer.pricePerShare),
          ),
          _buildDetailRow('Total Value', Formatters.currency(totalValue)),
          if (transfer.fairMarketValue != null)
            _buildDetailRow(
              'FMV at Transfer',
              Formatters.currency(transfer.fairMarketValue!),
            ),
          _buildDetailRow('Date', Formatters.date(transfer.transactionDate)),
          if (transfer.rofrWaived) _buildDetailRow('ROFR', 'Waived'),
          if (transfer.notes != null && transfer.notes!.isNotEmpty)
            _buildDetailRow('Notes', transfer.notes!),
          const SizedBox(height: 12),
          _buildActionButtons(context, ref, transfer),
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
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    Transfer transfer,
  ) {
    if (transfer.status == 'completed') {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (transfer.status == 'pending') ...[
          if (!transfer.rofrWaived)
            OutlinedButton.icon(
              onPressed: () => _waiveRofr(context, ref, transfer),
              icon: const Icon(Icons.verified_user, size: 18),
              label: const Text('Waive ROFR'),
            ),
          FilledButton.icon(
            onPressed: () => _executeTransfer(context, ref, transfer),
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Execute'),
          ),
        ],
        TextButton.icon(
          onPressed: () => _deleteTransfer(context, ref, transfer),
          icon: Icon(
            Icons.delete,
            size: 18,
            color: Theme.of(context).colorScheme.error,
          ),
          label: Text(
            'Cancel',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'secondary':
        return Icons.swap_horiz;
      case 'tender_offer':
        return Icons.storefront;
      case 'rofr':
        return Icons.gavel;
      case 'gift':
        return Icons.card_giftcard;
      default:
        return Icons.swap_horiz;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'secondary':
        return 'Secondary Sale';
      case 'tender_offer':
        return 'Tender Offer';
      case 'rofr':
        return 'ROFR Exercise';
      case 'gift':
        return 'Gift / Estate';
      default:
        return type;
    }
  }

  Future<void> _waiveRofr(
    BuildContext context,
    WidgetRef ref,
    Transfer transfer,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Waive Right of First Refusal?',
      message:
          'This will allow the transfer to proceed without exercising ROFR.',
      confirmLabel: 'Waive ROFR',
    );

    if (!confirmed) return;

    try {
      await ref
          .read(transferCommandsProvider.notifier)
          .waiveRofr(transferId: transfer.id);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ROFR waived')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _executeTransfer(
    BuildContext context,
    WidgetRef ref,
    Transfer transfer,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Execute Transfer?',
      message:
          'This will transfer ${Formatters.number(transfer.shareCount)} shares. This action cannot be undone.',
      confirmLabel: 'Execute',
    );

    if (!confirmed) return;

    try {
      await ref
          .read(transferCommandsProvider.notifier)
          .executeTransfer(transferId: transfer.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transfer executed successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _deleteTransfer(
    BuildContext context,
    WidgetRef ref,
    Transfer transfer,
  ) async {
    final confirmed = await ConfirmDialog.showDelete(
      context: context,
      itemName: 'transfer',
    );

    if (!confirmed) return;

    try {
      await ref
          .read(transferCommandsProvider.notifier)
          .cancelTransfer(transferId: transfer.id);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Transfer cancelled')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showAddDialog(
    BuildContext context,
    WidgetRef ref,
    String companyId,
    List<Stakeholder> stakeholders,
    List<ShareClassesData> shareClasses,
  ) {
    if (stakeholders.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You need at least 2 stakeholders to create a transfer',
          ),
        ),
      );
      return;
    }

    if (shareClasses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need at least one share class first'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _TransferForm(
        companyId: companyId,
        stakeholders: stakeholders,
        shareClasses: shareClasses,
      ),
    );
  }
}

/// Form for creating a new transfer.
class _TransferForm extends ConsumerStatefulWidget {
  final String companyId;
  final List<Stakeholder> stakeholders;
  final List<ShareClassesData> shareClasses;

  const _TransferForm({
    required this.companyId,
    required this.stakeholders,
    required this.shareClasses,
  });

  @override
  ConsumerState<_TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends ConsumerState<_TransferForm> {
  final _formKey = GlobalKey<FormState>();

  String? _sellerId;
  String? _buyerId;
  String? _shareClassId;
  final _sharesController = TextEditingController();
  final _priceController = TextEditingController();
  final _fmvController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _transactionDate = DateTime.now();
  String _type = 'secondary';

  bool _isLoading = false;

  final _types = [
    ('secondary', 'Secondary Sale'),
    ('tender_offer', 'Tender Offer'),
    ('rofr', 'ROFR Exercise'),
    ('gift', 'Gift / Estate'),
  ];

  @override
  void dispose() {
    _sharesController.dispose();
    _priceController.dispose();
    _fmvController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'New Share Transfer',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),

                // Transfer Type
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(
                    labelText: 'Transfer Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _types.map((t) {
                    return DropdownMenuItem(value: t.$1, child: Text(t.$2));
                  }).toList(),
                  onChanged: (v) => setState(() => _type = v ?? 'secondary'),
                ),
                const SizedBox(height: 16),

                // Seller
                DropdownButtonFormField<String>(
                  value: _sellerId,
                  decoration: const InputDecoration(
                    labelText: 'Seller',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.stakeholders
                      .where((s) => s.id != _buyerId)
                      .map(
                        (s) =>
                            DropdownMenuItem(value: s.id, child: Text(s.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _sellerId = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Buyer
                DropdownButtonFormField<String>(
                  value: _buyerId,
                  decoration: const InputDecoration(
                    labelText: 'Buyer',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.stakeholders
                      .where((s) => s.id != _sellerId)
                      .map(
                        (s) =>
                            DropdownMenuItem(value: s.id, child: Text(s.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _buyerId = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Share Class
                DropdownButtonFormField<String>(
                  value: _shareClassId,
                  decoration: const InputDecoration(
                    labelText: 'Share Class',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.shareClasses
                      .map(
                        (sc) => DropdownMenuItem(
                          value: sc.id,
                          child: Text(sc.name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _shareClassId = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Number of Shares
                TextFormField(
                  controller: _sharesController,
                  decoration: const InputDecoration(
                    labelText: 'Number of Shares',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (int.tryParse(v) == null) return 'Must be a number';
                    if (int.parse(v) <= 0) return 'Must be positive';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Price Per Share
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price Per Share',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (double.tryParse(v) == null) return 'Must be a number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Fair Market Value (optional)
                TextFormField(
                  controller: _fmvController,
                  decoration: const InputDecoration(
                    labelText: 'Fair Market Value (optional)',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                    helperText: 'FMV at time of transfer for tax purposes',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 16),

                // Transaction Date
                ListTile(
                  title: const Text('Transaction Date'),
                  subtitle: Text(Formatters.date(_transactionDate)),
                  trailing: const Icon(Icons.calendar_today),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: theme.colorScheme.outline),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _transactionDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => _transactionDate = date);
                    }
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
                const SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create Transfer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final fmv = _fmvController.text.isNotEmpty
          ? double.parse(_fmvController.text)
          : null;

      await ref
          .read(transferCommandsProvider.notifier)
          .createTransfer(
            sellerStakeholderId: _sellerId!,
            buyerStakeholderId: _buyerId!,
            shareClassId: _shareClassId!,
            shareCount: int.parse(_sharesController.text),
            pricePerShare: double.parse(_priceController.text),
            transactionDate: _transactionDate,
            transferType: _type,
            fairMarketValue: fmv,
            notes: _notesController.text.isNotEmpty
                ? _notesController.text
                : null,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Transfer created')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
