import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/providers.dart';
import '../../infrastructure/database/database.dart';
import '../../shared/formatters.dart';
import '../components/components.dart';

/// Page for managing ESOP pools (Employee Stock Ownership Plan pools).
class EsopPoolsPage extends ConsumerWidget {
  const EsopPoolsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poolsAsync = ref.watch(esopPoolsStreamProvider);
    final summaryAsync = ref.watch(allEsopPoolsSummaryProvider);
    final companyId = ref.watch(currentCompanyIdProvider);
    final shareClasses = ref.watch(shareClassesStreamProvider);
    final vestingSchedules = ref.watch(vestingSchedulesStreamProvider);

    if (companyId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('ESOP Pools'),
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
        title: const Text('ESOP Pools'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(context, summaryAsync),
          Expanded(
            child: poolsAsync.when(
              data: (pools) {
                if (pools.isEmpty) {
                  return EmptyState.noItems(
                    itemType: 'ESOP pool',
                    onAdd: () => _showAddDialog(
                      context,
                      ref,
                      companyId,
                      shareClasses.valueOrNull ?? [],
                      vestingSchedules.valueOrNull ?? [],
                    ),
                  );
                }
                return _buildPoolsList(
                  context,
                  ref,
                  pools,
                  shareClasses.valueOrNull ?? [],
                  vestingSchedules.valueOrNull ?? [],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState.error(
                message: e.toString(),
                onRetry: () => ref.invalidate(esopPoolsStreamProvider),
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
          shareClasses.valueOrNull ?? [],
          vestingSchedules.valueOrNull ?? [],
        ),
        icon: const Icon(Icons.add),
        label: const Text('New Pool'),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AsyncValue<AllPoolsSummary> summaryAsync,
  ) {
    return PageHeader(
      title: 'Option Pools',
      subtitle: 'Manage ESOP pools and track allocation',
      child: summaryAsync.when(
        data: (summary) => SummaryCardsRow(
          cards: [
            SummaryCard(
              label: 'Total Pool Size',
              value: Formatters.compactNumber(summary.totalPoolSize),
              icon: Icons.pool,
              color: Colors.blue,
            ),
            SummaryCard(
              label: 'Available',
              value: Formatters.compactNumber(summary.totalAvailable),
              icon: Icons.inventory_2,
              color: Colors.green,
            ),
            SummaryCard(
              label: 'Allocated',
              value: Formatters.compactNumber(summary.totalAllocated),
              icon: Icons.assignment_ind,
              color: Colors.orange,
            ),
          ],
        ),
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildPoolsList(
    BuildContext context,
    WidgetRef ref,
    List<EsopPool> pools,
    List<ShareClassesData> shareClasses,
    List<VestingSchedule> vestingSchedules,
  ) {
    final shareClassMap = {for (final sc in shareClasses) sc.id: sc};
    final expansionNeededAsync = ref.watch(poolsNeedingExpansionProvider);

    return Column(
      children: [
        // Expansion needed banner
        expansionNeededAsync.when(
          data: (expansionsNeeded) {
            if (expansionsNeeded.isEmpty) return const SizedBox.shrink();
            return _buildExpansionBanner(context, ref, expansionsNeeded);
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        // Pools list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: pools.length,
            itemBuilder: (context, index) {
              final pool = pools[index];
              return _buildPoolCard(
                context,
                ref,
                pool,
                shareClassMap,
                shareClasses,
                vestingSchedules,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExpansionBanner(
    BuildContext context,
    WidgetRef ref,
    List<PoolExpansionNeeded> expansionsNeeded,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${expansionsNeeded.length} Pool${expansionsNeeded.length > 1 ? 's' : ''} Below Target',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () =>
                    _showExpansionDialog(context, ref, expansionsNeeded),
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Review'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange,
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
            'These pools are below their target percentage of the company and may need to be expanded.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  void _showExpansionDialog(
    BuildContext context,
    WidgetRef ref,
    List<PoolExpansionNeeded> expansionsNeeded,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          _PoolExpansionDialog(expansionsNeeded: expansionsNeeded),
    );
  }

  Widget _buildPoolCard(
    BuildContext context,
    WidgetRef ref,
    EsopPool pool,
    Map<String, ShareClassesData> shareClassMap,
    List<ShareClassesData> shareClasses,
    List<VestingSchedule> vestingSchedules,
  ) {
    final shareClass = shareClassMap[pool.shareClassId];
    final summaryAsync = ref.watch(esopPoolSummaryProvider(pool.id));

    return summaryAsync.when(
      data: (summary) {
        if (summary == null) return const SizedBox.shrink();
        return ExpandableCard(
          leading: EntityAvatar(
            name: pool.name,
            type: EntityAvatarType.company,
            size: 40,
          ),
          title: pool.name,
          subtitle:
              '${Formatters.number(pool.poolSize)} shares • ${shareClass?.name ?? 'Unknown class'}',
          badges: [
            StatusBadge(
              label: _formatStatus(pool.status),
              color: _getStatusColor(pool.status),
            ),
          ],
          chips: [
            MetricChip(
              label: 'Available',
              value: Formatters.compactNumber(summary.available),
              color: Colors.green,
            ),
            MetricChip(
              label: 'Allocated',
              value: Formatters.compactNumber(summary.allocated),
              color: Colors.orange,
            ),
            MetricChip(
              label: 'Utilization',
              value: '${summary.utilizationPercent.toStringAsFixed(0)}%',
              color: summary.utilizationPercent > 90
                  ? Colors.red
                  : summary.utilizationPercent > 70
                  ? Colors.orange
                  : Colors.blue,
            ),
          ],
          expandedContent: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Utilization bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Pool Utilization'),
                      Text(
                        '${summary.utilizationPercent.toStringAsFixed(1)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: summary.utilizationPercent / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(
                        summary.utilizationPercent > 90
                            ? Colors.red
                            : summary.utilizationPercent > 70
                            ? Colors.orange
                            : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Stats
              _buildDetailRow('Pool Size', Formatters.number(pool.poolSize)),
              _buildDetailRow(
                'Allocated',
                Formatters.number(summary.allocated),
              ),
              _buildDetailRow(
                'Available',
                Formatters.number(summary.available),
              ),
              _buildDetailRow(
                'Exercised',
                Formatters.number(summary.exercised),
              ),
              _buildDetailRow('Active Grants', summary.activeGrants.toString()),
              const Divider(height: 24),
              _buildDetailRow(
                'Established',
                Formatters.shortDate(pool.establishedDate),
              ),
              _buildDetailRow(
                'Strike Method',
                _formatStrikeMethod(pool.strikePriceMethod),
              ),
              _buildDetailRow(
                'Default Expiry',
                '${pool.defaultExpiryYears} years',
              ),
              if (pool.defaultStrikePrice != null)
                _buildDetailRow(
                  'Default Strike',
                  Formatters.currency(pool.defaultStrikePrice!),
                ),
              if (pool.notes != null && pool.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  pool.notes!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _showEditDialog(
                context,
                ref,
                pool,
                shareClasses,
                vestingSchedules,
              ),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _showExpandDialog(context, ref, pool),
              tooltip: 'Expand Pool',
            ),
            if (summary.allocated == 0)
              IconButton(
                icon: Icon(
                  Icons.delete_outlined,
                  color: Theme.of(context).colorScheme.error,
                ),
                onPressed: () => _confirmDelete(context, ref, pool),
                tooltip: 'Delete',
              ),
          ],
        );
      },
      loading: () => const Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error: $e'),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'frozen':
        return Colors.blue;
      case 'exhausted':
        return Colors.orange;
      case 'draft':
      default:
        return Colors.grey;
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'frozen':
        return 'Frozen';
      case 'exhausted':
        return 'Exhausted';
      case 'draft':
        return 'Draft';
      default:
        return status[0].toUpperCase() + status.substring(1);
    }
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

  String _formatStrikeMethod(String method) {
    switch (method) {
      case 'fmv':
        return 'Fair Market Value';
      case 'fixed':
        return 'Fixed Price';
      case 'discount':
        return 'Discount to FMV';
      default:
        return method;
    }
  }

  void _showAddDialog(
    BuildContext context,
    WidgetRef ref,
    String companyId,
    List<ShareClassesData> shareClasses,
    List<VestingSchedule> vestingSchedules,
  ) {
    if (shareClasses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create a share class first'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final nameController = TextEditingController();
    final poolSizeController = TextEditingController();
    final targetPercentController = TextEditingController();
    final strikePriceController = TextEditingController();
    final expiryYearsController = TextEditingController(text: '10');
    final notesController = TextEditingController();

    String? selectedShareClassId = shareClasses.first.id;
    String? selectedVestingScheduleId;
    DateTime establishedDate = DateTime.now();
    String strikePriceMethod = 'fmv';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create ESOP Pool'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Pool Name *',
                    hintText: 'e.g., 2024 Employee Option Pool',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedShareClassId,
                  decoration: const InputDecoration(labelText: 'Share Class *'),
                  items: shareClasses
                      .map(
                        (sc) => DropdownMenuItem(
                          value: sc.id,
                          child: Text(sc.name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selectedShareClassId = v),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: poolSizeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Pool Size (shares) *',
                    hintText: 'Total shares reserved for pool',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: targetPercentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Target % of Company',
                    hintText: 'Optional - e.g., 10',
                    suffixText: '%',
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Established Date'),
                  subtitle: Text(Formatters.shortDate(establishedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: establishedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => establishedDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: strikePriceMethod,
                  decoration: const InputDecoration(
                    labelText: 'Strike Price Method',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'fmv',
                      child: Text('Fair Market Value (409A)'),
                    ),
                    DropdownMenuItem(
                      value: 'fixed',
                      child: Text('Fixed Price'),
                    ),
                    DropdownMenuItem(
                      value: 'discount',
                      child: Text('Discount to FMV'),
                    ),
                  ],
                  onChanged: (v) =>
                      setState(() => strikePriceMethod = v ?? 'fmv'),
                ),
                if (strikePriceMethod == 'fixed') ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: strikePriceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Default Strike Price',
                      prefixText: '\$ ',
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: expiryYearsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Default Expiry (years)',
                    hintText: 'Typically 10 years',
                  ),
                ),
                const SizedBox(height: 16),
                if (vestingSchedules.isNotEmpty)
                  DropdownButtonFormField<String?>(
                    value: selectedVestingScheduleId,
                    decoration: const InputDecoration(
                      labelText: 'Default Vesting Schedule',
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('None')),
                      ...vestingSchedules.map(
                        (vs) => DropdownMenuItem(
                          value: vs.id,
                          child: Text(vs.name),
                        ),
                      ),
                    ],
                    onChanged: (v) =>
                        setState(() => selectedVestingScheduleId = v),
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Board resolution, terms, etc.',
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
            FilledButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    selectedShareClassId == null ||
                    poolSizeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in required fields'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                final poolSize = int.tryParse(poolSizeController.text);
                if (poolSize == null || poolSize <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid pool size'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                try {
                  await ref
                      .read(esopPoolCommandsProvider.notifier)
                      .createPool(
                        name: nameController.text,
                        shareClassId: selectedShareClassId!,
                        poolSize: poolSize,
                        targetPercentage: double.tryParse(
                          targetPercentController.text,
                        ),
                        establishedDate: establishedDate,
                        defaultVestingScheduleId: selectedVestingScheduleId,
                        strikePriceMethod: strikePriceMethod,
                        defaultStrikePrice: double.tryParse(
                          strikePriceController.text,
                        ),
                        defaultExpiryYears:
                            int.tryParse(expiryYearsController.text) ?? 10,
                        notes: notesController.text.isNotEmpty
                            ? notesController.text
                            : null,
                      );

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ESOP pool created'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    EsopPool pool,
    List<ShareClassesData> shareClasses,
    List<VestingSchedule> vestingSchedules,
  ) {
    final nameController = TextEditingController(text: pool.name);
    final targetPercentController = TextEditingController(
      text: pool.targetPercentage?.toString() ?? '',
    );
    final strikePriceController = TextEditingController(
      text: pool.defaultStrikePrice?.toString() ?? '',
    );
    final expiryYearsController = TextEditingController(
      text: pool.defaultExpiryYears.toString(),
    );
    final notesController = TextEditingController(text: pool.notes ?? '');

    String? selectedShareClassId = pool.shareClassId;
    String? selectedVestingScheduleId = pool.defaultVestingScheduleId;
    String status = pool.status;
    String strikePriceMethod = pool.strikePriceMethod;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit ESOP Pool'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Pool Name *'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'draft', child: Text('Draft')),
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'frozen', child: Text('Frozen')),
                    DropdownMenuItem(
                      value: 'exhausted',
                      child: Text('Exhausted'),
                    ),
                  ],
                  onChanged: (v) => setState(() => status = v ?? 'active'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedShareClassId,
                  decoration: const InputDecoration(labelText: 'Share Class *'),
                  items: shareClasses
                      .map(
                        (sc) => DropdownMenuItem(
                          value: sc.id,
                          child: Text(sc.name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selectedShareClassId = v),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: targetPercentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Target % of Company',
                    suffixText: '%',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: strikePriceMethod,
                  decoration: const InputDecoration(
                    labelText: 'Strike Price Method',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'fmv',
                      child: Text('Fair Market Value'),
                    ),
                    DropdownMenuItem(
                      value: 'fixed',
                      child: Text('Fixed Price'),
                    ),
                    DropdownMenuItem(
                      value: 'discount',
                      child: Text('Discount to FMV'),
                    ),
                  ],
                  onChanged: (v) =>
                      setState(() => strikePriceMethod = v ?? 'fmv'),
                ),
                if (strikePriceMethod == 'fixed') ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: strikePriceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Default Strike Price',
                      prefixText: '\$ ',
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: expiryYearsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Default Expiry (years)',
                  ),
                ),
                const SizedBox(height: 16),
                if (vestingSchedules.isNotEmpty)
                  DropdownButtonFormField<String?>(
                    value: selectedVestingScheduleId,
                    decoration: const InputDecoration(
                      labelText: 'Default Vesting Schedule',
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('None')),
                      ...vestingSchedules.map(
                        (vs) => DropdownMenuItem(
                          value: vs.id,
                          child: Text(vs.name),
                        ),
                      ),
                    ],
                    onChanged: (v) =>
                        setState(() => selectedVestingScheduleId = v),
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Notes'),
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
                if (nameController.text.isEmpty ||
                    selectedShareClassId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in required fields'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                try {
                  // TODO: Implement updatePool in EsopPoolCommands
                  // This operation is not yet supported in the event-sourcing architecture.
                  // The current commands only support createPool and expandPool.
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pool update not yet implemented'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showExpandDialog(BuildContext context, WidgetRef ref, EsopPool pool) {
    final additionalSharesController = TextEditingController();
    final resolutionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Expand Pool'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current pool size: ${Formatters.number(pool.poolSize)} shares',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: additionalSharesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Additional Shares *',
                hintText: 'Number of shares to add',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resolutionController,
              decoration: const InputDecoration(
                labelText: 'Board Resolution Reference',
                hintText: 'Optional',
              ),
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
              final additional = int.tryParse(additionalSharesController.text);
              if (additional == null || additional <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid number of shares'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              try {
                // Use event-sourced expansion command
                await ref
                    .read(esopPoolCommandsProvider.notifier)
                    .expandPool(
                      poolId: pool.id,
                      previousSize: pool.poolSize,
                      newSize: pool.poolSize + additional,
                      sharesAdded: additional,
                      reason: 'manual',
                      resolutionReference: resolutionController.text.isNotEmpty
                          ? resolutionController.text
                          : null,
                    );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Pool expanded to ${Formatters.number(pool.poolSize + additional)} shares',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Expand'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, EsopPool pool) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete ESOP Pool?'),
        content: Text(
          'Are you sure you want to delete "${pool.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              // TODO: Implement deletePool in EsopPoolCommands
              // This operation is not yet supported in the event-sourcing architecture.
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pool delete not yet implemented'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Dialog for reviewing and applying pool expansions.
class _PoolExpansionDialog extends ConsumerStatefulWidget {
  final List<PoolExpansionNeeded> expansionsNeeded;

  const _PoolExpansionDialog({required this.expansionsNeeded});

  @override
  ConsumerState<_PoolExpansionDialog> createState() =>
      _PoolExpansionDialogState();
}

class _PoolExpansionDialogState extends ConsumerState<_PoolExpansionDialog> {
  final Set<int> _selectedIndices = {};
  bool _isApplying = false;
  final _resolutionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Select all by default
    _selectedIndices.addAll(
      List.generate(widget.expansionsNeeded.length, (i) => i),
    );
  }

  @override
  void dispose() {
    _resolutionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.trending_up, color: Colors.orange),
          const SizedBox(width: 8),
          const Text('Pool Expansions'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The following pools are below their target percentage and can be expanded to meet the target:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.expansionsNeeded.length,
                itemBuilder: (context, index) {
                  final expansion = widget.expansionsNeeded[index];
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
                        expansion.pool.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${Formatters.number(expansion.currentSize)} shares',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '+${Formatters.number(expansion.sharesToAdd)} shares to reach ${expansion.targetPercent.toStringAsFixed(1)}%',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Currently ${expansion.currentPercent.toStringAsFixed(1)}% of company',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
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
            const SizedBox(height: 16),
            TextField(
              controller: _resolutionController,
              decoration: const InputDecoration(
                labelText: 'Board Resolution Reference',
                hintText: 'Optional - e.g., BR-2024-001',
                border: OutlineInputBorder(),
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
              : const Icon(Icons.add_circle_outline, size: 18),
          label: Text(
            _isApplying
                ? 'Applying...'
                : 'Expand ${_selectedIndices.length} Pool${_selectedIndices.length > 1 ? 's' : ''}',
          ),
          style: FilledButton.styleFrom(backgroundColor: Colors.orange),
        ),
      ],
    );
  }

  Future<void> _applySelected() async {
    setState(() => _isApplying = true);

    try {
      final commands = ref.read(esopPoolCommandsProvider.notifier);
      int appliedCount = 0;

      for (final index in _selectedIndices.toList()..sort()) {
        final expansion = widget.expansionsNeeded[index];
        await commands.expandPool(
          poolId: expansion.pool.id,
          previousSize: expansion.pool.poolSize,
          newSize: expansion.pool.poolSize + expansion.sharesToAdd,
          sharesAdded: expansion.sharesToAdd,
          reason: 'target_percentage',
          resolutionReference: _resolutionController.text.isNotEmpty
              ? _resolutionController.text
              : null,
          notes:
              'Expanded to meet target of ${expansion.targetPercent.toStringAsFixed(1)}%',
        );
        appliedCount++;
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Expanded $appliedCount pool${appliedCount > 1 ? 's' : ''}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error expanding pools: $e'),
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
