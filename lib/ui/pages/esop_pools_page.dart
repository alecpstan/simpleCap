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

    return ListView.builder(
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(pool.status).withOpacity(0.2),
          child: Icon(
            Icons.account_balance_wallet,
            color: _getStatusColor(pool.status),
          ),
        ),
        title: Text(
          pool.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${Formatters.number(pool.poolSize)} shares • ${shareClass?.name ?? 'Unknown class'}',
        ),
        trailing: _buildStatusChip(pool.status),
        children: [
          summaryAsync.when(
            data: (summary) => summary != null
                ? _buildPoolDetails(
                    context,
                    ref,
                    pool,
                    summary,
                    shareClasses,
                    vestingSchedules,
                  )
                : const SizedBox.shrink(),
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: $e'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoolDetails(
    BuildContext context,
    WidgetRef ref,
    EsopPool pool,
    EsopPoolSummary summary,
    List<ShareClassesData> shareClasses,
    List<VestingSchedule> vestingSchedules,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
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
          // Stats grid
          Wrap(
            spacing: 24,
            runSpacing: 8,
            children: [
              _buildStat('Pool Size', Formatters.number(pool.poolSize)),
              _buildStat('Allocated', Formatters.number(summary.allocated)),
              _buildStat('Available', Formatters.number(summary.available)),
              _buildStat('Exercised', Formatters.number(summary.exercised)),
              _buildStat('Active Grants', summary.activeGrants.toString()),
            ],
          ),
          const SizedBox(height: 16),
          // Pool details
          Wrap(
            spacing: 24,
            runSpacing: 8,
            children: [
              _buildStat(
                'Established',
                Formatters.shortDate(pool.establishedDate),
              ),
              _buildStat('Strike Method', _formatStrikeMethod(pool.strikePriceMethod)),
              _buildStat('Default Expiry', '${pool.defaultExpiryYears} years'),
              if (pool.defaultStrikePrice != null)
                _buildStat(
                  'Default Strike',
                  Formatters.currency(pool.defaultStrikePrice!),
                ),
            ],
          ),
          if (pool.notes != null && pool.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              pool.notes!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
          const Divider(height: 24),
          // Actions
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showEditDialog(
                  context,
                  ref,
                  pool,
                  shareClasses,
                  vestingSchedules,
                ),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
              ),
              OutlinedButton.icon(
                onPressed: () => _showExpandDialog(context, ref, pool),
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Expand Pool'),
              ),
              if (summary.allocated == 0)
                OutlinedButton.icon(
                  onPressed: () => _confirmDelete(context, ref, pool),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'active':
        color = Colors.green;
        label = 'Active';
        break;
      case 'frozen':
        color = Colors.blue;
        label = 'Frozen';
        break;
      case 'exhausted':
        color = Colors.orange;
        label = 'Exhausted';
        break;
      case 'draft':
      default:
        color = Colors.grey;
        label = 'Draft';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
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
                  decoration: const InputDecoration(
                    labelText: 'Share Class *',
                  ),
                  items: shareClasses
                      .map((sc) => DropdownMenuItem(
                            value: sc.id,
                            child: Text(sc.name),
                          ))
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
                    DropdownMenuItem(value: 'fmv', child: Text('Fair Market Value (409A)')),
                    DropdownMenuItem(value: 'fixed', child: Text('Fixed Price')),
                    DropdownMenuItem(value: 'discount', child: Text('Discount to FMV')),
                  ],
                  onChanged: (v) => setState(() => strikePriceMethod = v ?? 'fmv'),
                ),
                if (strikePriceMethod == 'fixed') ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: strikePriceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                      const DropdownMenuItem(
                        value: null,
                        child: Text('None'),
                      ),
                      ...vestingSchedules.map((vs) => DropdownMenuItem(
                            value: vs.id,
                            child: Text(vs.name),
                          )),
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
                  await ref.read(createEsopPoolProvider.notifier).call(
                        name: nameController.text,
                        shareClassId: selectedShareClassId!,
                        poolSize: poolSize,
                        targetPercentage:
                            double.tryParse(targetPercentController.text),
                        establishedDate: establishedDate,
                        defaultVestingScheduleId: selectedVestingScheduleId,
                        strikePriceMethod: strikePriceMethod,
                        defaultStrikePrice:
                            double.tryParse(strikePriceController.text),
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
                  decoration: const InputDecoration(
                    labelText: 'Pool Name *',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'draft', child: Text('Draft')),
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'frozen', child: Text('Frozen')),
                    DropdownMenuItem(value: 'exhausted', child: Text('Exhausted')),
                  ],
                  onChanged: (v) => setState(() => status = v ?? 'active'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedShareClassId,
                  decoration: const InputDecoration(
                    labelText: 'Share Class *',
                  ),
                  items: shareClasses
                      .map((sc) => DropdownMenuItem(
                            value: sc.id,
                            child: Text(sc.name),
                          ))
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
                    DropdownMenuItem(value: 'fmv', child: Text('Fair Market Value')),
                    DropdownMenuItem(value: 'fixed', child: Text('Fixed Price')),
                    DropdownMenuItem(value: 'discount', child: Text('Discount to FMV')),
                  ],
                  onChanged: (v) => setState(() => strikePriceMethod = v ?? 'fmv'),
                ),
                if (strikePriceMethod == 'fixed') ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: strikePriceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                      const DropdownMenuItem(
                        value: null,
                        child: Text('None'),
                      ),
                      ...vestingSchedules.map((vs) => DropdownMenuItem(
                            value: vs.id,
                            child: Text(vs.name),
                          )),
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
                  await ref.read(updateEsopPoolProvider.notifier).call(
                        id: pool.id,
                        name: nameController.text,
                        shareClassId: selectedShareClassId,
                        status: status,
                        targetPercentage:
                            double.tryParse(targetPercentController.text),
                        defaultVestingScheduleId: selectedVestingScheduleId,
                        strikePriceMethod: strikePriceMethod,
                        defaultStrikePrice:
                            double.tryParse(strikePriceController.text),
                        defaultExpiryYears:
                            int.tryParse(expiryYearsController.text),
                        notes: notesController.text.isNotEmpty
                            ? notesController.text
                            : null,
                      );

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ESOP pool updated'),
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
              final additional =
                  int.tryParse(additionalSharesController.text);
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
                await ref.read(expandEsopPoolProvider.notifier).call(
                      poolId: pool.id,
                      additionalShares: additional,
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
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              try {
                await ref.read(deleteEsopPoolProvider.notifier).call(pool.id);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ESOP pool deleted'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
