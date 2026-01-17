import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/providers.dart';
import '../../infrastructure/database/database.dart';
import '../../shared/formatters.dart';
import '../components/components.dart';
import 'share_classes_page.dart';

/// Page for managing stock holdings directly (founder shares, direct issuances).
class HoldingsPage extends ConsumerWidget {
  const HoldingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyId = ref.watch(currentCompanyIdProvider);
    final holdingsAsync = ref.watch(holdingsStreamProvider);
    final ownershipAsync = ref.watch(ownershipSummaryProvider);
    final stakeholdersAsync = ref.watch(stakeholdersStreamProvider);
    final shareClassesAsync = ref.watch(shareClassesStreamProvider);

    if (companyId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Holdings'),
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
        title: const Text('Stock Holdings'),
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            tooltip: 'Manage Share Classes',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ShareClassesPage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(context, ownershipAsync),
          Expanded(
            child: holdingsAsync.when(
              data: (holdings) {
                if (holdings.isEmpty) {
                  return EmptyState.noItems(
                    itemType: 'holding',
                    onAdd: () => _showAddDialog(
                      context,
                      ref,
                      companyId,
                      stakeholdersAsync.valueOrNull ?? [],
                      shareClassesAsync.valueOrNull ?? [],
                    ),
                  );
                }
                return _buildHoldingsList(
                  context,
                  ref,
                  holdings,
                  stakeholdersAsync.valueOrNull ?? [],
                  shareClassesAsync.valueOrNull ?? [],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState.error(
                message: e.toString(),
                onRetry: () => ref.invalidate(holdingsStreamProvider),
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
        icon: const Icon(Icons.add),
        label: const Text('Issue Stock'),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AsyncValue<OwnershipSummary> ownershipAsync,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Direct Stock Issuances',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Founder shares, grants, and direct issuances',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 12),
          ownershipAsync.when(
            data: (summary) {
              final cards = [
                SummaryCard(
                  label: 'Total Shares',
                  value: Formatters.compactNumber(summary.totalIssuedShares),
                  icon: Icons.pie_chart,
                  color: Colors.blue,
                ),
                SummaryCard(
                  label: 'Stakeholders',
                  value: summary.stakeholderCount.toString(),
                  icon: Icons.people,
                  color: Colors.green,
                ),
              ];

              return LayoutBuilder(
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
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingsList(
    BuildContext context,
    WidgetRef ref,
    List<Holding> holdings,
    List<Stakeholder> stakeholders,
    List<ShareClassesData> shareClasses,
  ) {
    // Group by stakeholder
    final grouped = <String, List<Holding>>{};
    for (final h in holdings) {
      grouped.putIfAbsent(h.stakeholderId, () => []).add(h);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final stakeholderId = grouped.keys.elementAt(index);
        final stakeholderHoldings = grouped[stakeholderId]!;
        final stakeholder = stakeholders.firstWhere(
          (s) => s.id == stakeholderId,
          orElse: () => Stakeholder(
            id: stakeholderId,
            companyId: '',
            name: 'Unknown',
            type: 'investor',
            hasProRataRights: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        return _buildStakeholderHoldingsCard(
          context,
          ref,
          stakeholder,
          stakeholderHoldings,
          shareClasses,
        );
      },
    );
  }

  Widget _buildStakeholderHoldingsCard(
    BuildContext context,
    WidgetRef ref,
    Stakeholder stakeholder,
    List<Holding> holdings,
    List<ShareClassesData> shareClasses,
  ) {
    final totalShares = holdings.fold<int>(0, (sum, h) => sum + h.shareCount);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: EntityAvatar(name: stakeholder.name, size: 40),
        title: Text(
          stakeholder.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${Formatters.number(totalShares)} total shares',
          style: theme.textTheme.bodySmall,
        ),
        children: holdings.map((holding) {
          final shareClass = shareClasses.firstWhere(
            (sc) => sc.id == holding.shareClassId,
            orElse: () => ShareClassesData(
              id: holding.shareClassId,
              companyId: holding.companyId,
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

          return ListTile(
            leading: Icon(
              shareClass.type == 'preferred' ? Icons.star : Icons.circle,
              color: shareClass.type == 'preferred'
                  ? Colors.amber
                  : Colors.blue,
              size: 20,
            ),
            title: Text(shareClass.name),
            subtitle: Text(
              'Acquired ${Formatters.date(holding.acquiredDate)} · '
              'Cost basis: ${Formatters.currency(holding.costBasis)}/share',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatters.number(holding.shareCount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('shares', style: theme.textTheme.bodySmall),
              ],
            ),
            onTap: () => _showHoldingDetails(
              context,
              ref,
              holding,
              stakeholder,
              shareClass,
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showHoldingDetails(
    BuildContext context,
    WidgetRef ref,
    Holding holding,
    Stakeholder stakeholder,
    ShareClassesData shareClass,
  ) {
    final theme = Theme.of(context);
    final totalValue = holding.shareCount * holding.costBasis;

    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                EntityAvatar(name: stakeholder.name, size: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stakeholder.name, style: theme.textTheme.titleLarge),
                      Text(
                        '${shareClass.name} · ${Formatters.number(holding.shareCount)} shares',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildDetailRow('Share Class', shareClass.name),
            _buildDetailRow(
              'Share Count',
              Formatters.number(holding.shareCount),
            ),
            _buildDetailRow(
              'Acquired Date',
              Formatters.date(holding.acquiredDate),
            ),
            _buildDetailRow(
              'Cost Basis',
              '${Formatters.currency(holding.costBasis)}/share',
            ),
            _buildDetailRow('Total Cost', Formatters.currency(totalValue)),
            if (holding.vestedCount != null)
              _buildDetailRow(
                'Vested',
                '${Formatters.number(holding.vestedCount!)} shares',
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _confirmDelete(context, ref, holding);
                  },
                  icon: Icon(Icons.delete, color: theme.colorScheme.error),
                  label: Text(
                    'Delete',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Holding holding,
  ) async {
    final confirmed = await ConfirmDialog.showDelete(
      context: context,
      itemName: 'holding',
      additionalMessage:
          'This will remove ${Formatters.number(holding.shareCount)} shares from the cap table.',
    );

    if (!confirmed) return;

    try {
      // TODO: Implement deleteHolding in HoldingCommands
      // This operation is not yet supported in the event-sourcing architecture.
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Delete not yet implemented')),
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

  void _showAddDialog(
    BuildContext context,
    WidgetRef ref,
    String companyId,
    List<Stakeholder> stakeholders,
    List<ShareClassesData> shareClasses,
  ) {
    if (stakeholders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a stakeholder first before issuing shares'),
        ),
      );
      return;
    }

    if (shareClasses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Create a share class first (tap the icon in the app bar)',
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _IssueStockForm(
        companyId: companyId,
        stakeholders: stakeholders,
        shareClasses: shareClasses,
      ),
    );
  }
}

/// Form for issuing new stock.
class _IssueStockForm extends ConsumerStatefulWidget {
  final String companyId;
  final List<Stakeholder> stakeholders;
  final List<ShareClassesData> shareClasses;

  const _IssueStockForm({
    required this.companyId,
    required this.stakeholders,
    required this.shareClasses,
  });

  @override
  ConsumerState<_IssueStockForm> createState() => _IssueStockFormState();
}

class _IssueStockFormState extends ConsumerState<_IssueStockForm> {
  final _formKey = GlobalKey<FormState>();

  String? _stakeholderId;
  String? _shareClassId;
  final _sharesController = TextEditingController();
  final _costBasisController = TextEditingController(text: '0.0001');
  DateTime _acquiredDate = DateTime.now();

  bool _isLoading = false;

  @override
  void dispose() {
    _sharesController.dispose();
    _costBasisController.dispose();
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
                Text('Issue Stock', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Issue shares directly to a stakeholder (founder shares, grants, etc.)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 24),

                // Stakeholder
                DropdownButtonFormField<String>(
                  value: _stakeholderId,
                  decoration: const InputDecoration(
                    labelText: 'Stakeholder',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  items: widget.stakeholders
                      .map(
                        (s) =>
                            DropdownMenuItem(value: s.id, child: Text(s.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _stakeholderId = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Share Class
                DropdownButtonFormField<String>(
                  value: _shareClassId,
                  decoration: const InputDecoration(
                    labelText: 'Share Class',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
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
                    prefixIcon: Icon(Icons.numbers),
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

                // Cost Basis
                TextFormField(
                  controller: _costBasisController,
                  decoration: const InputDecoration(
                    labelText: 'Cost Basis (per share)',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                    helperText:
                        'What was paid per share (use 0.0001 for par value)',
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

                // Acquired Date
                ListTile(
                  title: const Text('Acquired Date'),
                  subtitle: Text(Formatters.date(_acquiredDate)),
                  trailing: const Icon(Icons.calendar_today),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: theme.colorScheme.outline),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _acquiredDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => _acquiredDate = date);
                    }
                  },
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
                          : const Text('Issue Shares'),
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
      await ref
          .read(holdingCommandsProvider.notifier)
          .issueShares(
            stakeholderId: _stakeholderId!,
            shareClassId: _shareClassId!,
            shareCount: int.parse(_sharesController.text),
            costBasis: double.parse(_costBasisController.text),
            acquiredDate: _acquiredDate,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shares issued successfully')),
        );
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
