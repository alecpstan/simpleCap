import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/providers.dart';
import '../../domain/events/cap_table_event.dart';
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
    final stakeholders = ref.watch(stakeholdersStreamProvider);
    final deleteEnabled = ref.watch(deleteEnabledProvider).valueOrNull ?? false;

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
                  stakeholders.valueOrNull ?? [],
                  deleteEnabled,
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
    List<Stakeholder> stakeholders,
    bool deleteEnabled,
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
                stakeholders,
                deleteEnabled,
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
    List<Stakeholder> stakeholders,
    bool deleteEnabled,
  ) {
    final summaryAsync = ref.watch(esopPoolSummaryProvider(pool.id));
    final poolGrantsAsync = ref.watch(poolOptionGrantsStreamProvider(pool.id));
    final esopPools = ref.watch(esopPoolsStreamProvider).valueOrNull ?? [];

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
          subtitle: '${Formatters.number(pool.poolSize)} shares reserved',
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
              // Pool History Section
              const Divider(height: 24),
              _buildPoolHistorySection(context, ref, pool),
              // Option Grants from this Pool
              const Divider(height: 24),
              _buildPoolGrantsSection(
                context,
                ref,
                pool,
                poolGrantsAsync,
                shareClassMap,
                stakeholders,
              ),
            ],
          ),
          actions: [
            if (summary.available > 0)
              IconButton(
                icon: const Icon(Icons.card_giftcard_outlined),
                onPressed: () => _showGrantOptionsDialog(
                  context,
                  ref,
                  pool,
                  stakeholders,
                  shareClasses,
                  vestingSchedules,
                  esopPools,
                ),
                tooltip: 'Grant Options',
              ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _showEditDialog(
                context,
                ref,
                pool,
                vestingSchedules,
              ),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _showExpandDialog(context, ref, pool),
              tooltip: 'Expand Pool',
            ),
            if (deleteEnabled)
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

  Widget _buildPoolHistorySection(
    BuildContext context,
    WidgetRef ref,
    EsopPool pool,
  ) {
    final eventsAsync = ref.watch(eventsStreamProvider);
    final stakeholdersAsync = ref.watch(stakeholdersStreamProvider);

    return eventsAsync.when(
      data: (events) {
        // Filter events related to this pool
        final poolEvents = events.where((e) {
          return e.maybeMap(
            esopPoolCreated: (e) => e.poolId == pool.id,
            esopPoolExpanded: (e) => e.poolId == pool.id,
            esopPoolActivated: (e) => e.poolId == pool.id,
            esopPoolUpdated: (e) => e.poolId == pool.id,
            esopPoolExpansionReverted: (e) => e.poolId == pool.id,
            optionGranted: (e) => e.esopPoolId == pool.id,
            optionsExercised: (e) {
              // Check if this grant belongs to this pool
              final grant = ref
                  .read(optionGrantsStreamProvider)
                  .valueOrNull
                  ?.firstWhere(
                    (g) => g.id == e.grantId,
                    orElse: () => OptionGrant(
                      id: '',
                      companyId: '',
                      stakeholderId: '',
                      shareClassId: '',
                      status: '',
                      quantity: 0,
                      strikePrice: 0,
                      grantDate: DateTime.now(),
                      expiryDate: DateTime.now(),
                      exercisedCount: 0,
                      cancelledCount: 0,
                      allowsEarlyExercise: false,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ),
                  );
              return grant?.esopPoolId == pool.id;
            },
            orElse: () => false,
          );
        }).toList();

        // Sort by timestamp descending (newest first)
        poolEvents.sort((a, b) {
          final aTime = _getEventTimestamp(a);
          final bTime = _getEventTimestamp(b);
          return bTime.compareTo(aTime);
        });

        if (poolEvents.isEmpty) {
          return Text(
            'No history events',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          );
        }

        final stakeholders = stakeholdersAsync.valueOrNull ?? [];
        final stakeholderMap = {for (final s in stakeholders) s.id: s.name};

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pool History',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...poolEvents
                .take(10)
                .map(
                  (event) =>
                      _buildEventRow(context, ref, event, stakeholderMap),
                ),
            if (poolEvents.length > 10)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '+ ${poolEvents.length - 10} more events',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildEventRow(
    BuildContext context,
    WidgetRef ref,
    CapTableEvent event,
    Map<String, String> stakeholderMap,
  ) {
    final timestamp = _getEventTimestamp(event);
    final description = _getEventDescription(event, stakeholderMap);
    final icon = _getEventIcon(event);
    final color = _getEventColor(event);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(description, style: Theme.of(context).textTheme.bodySmall),
                Text(
                  Formatters.shortDate(timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (event is EsopPoolExpanded)
            IconButton(
              icon: const Icon(Icons.undo, size: 16),
              onPressed: () => _confirmRevertExpansion(context, ref, event),
              tooltip: 'Revert Expansion',
              iconSize: 16,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }

  DateTime _getEventTimestamp(CapTableEvent event) {
    return event.maybeMap(
      esopPoolCreated: (e) => e.timestamp,
      esopPoolExpanded: (e) => e.timestamp,
      esopPoolActivated: (e) => e.timestamp,
      esopPoolUpdated: (e) => e.timestamp,
      esopPoolExpansionReverted: (e) => e.timestamp,
      optionGranted: (e) => e.timestamp,
      optionsExercised: (e) => e.timestamp,
      orElse: () => DateTime.now(),
    );
  }

  String _getEventDescription(
    CapTableEvent event,
    Map<String, String> stakeholderMap,
  ) {
    return event.maybeMap(
      esopPoolCreated: (e) =>
          'Pool created with ${Formatters.number(e.poolSize)} shares',
      esopPoolExpanded: (e) =>
          'Expanded by ${Formatters.number(e.sharesAdded)} shares (${e.reason})',
      esopPoolActivated: (e) => 'Pool activated',
      esopPoolUpdated: (e) => 'Pool settings updated',
      esopPoolExpansionReverted: (e) =>
          'Expansion reverted, removed ${Formatters.number(e.sharesRemoved)} shares',
      optionGranted: (e) {
        final name = stakeholderMap[e.stakeholderId] ?? 'Unknown';
        return 'Granted ${Formatters.number(e.quantity)} options to $name';
      },
      optionsExercised: (e) =>
          'Exercised ${Formatters.number(e.exercisedCount)} options',
      orElse: () => 'Unknown event',
    );
  }

  IconData _getEventIcon(CapTableEvent event) {
    return event.maybeMap(
      esopPoolCreated: (_) => Icons.add_circle_outline,
      esopPoolExpanded: (_) => Icons.trending_up,
      esopPoolActivated: (_) => Icons.check_circle_outline,
      esopPoolUpdated: (_) => Icons.edit_outlined,
      esopPoolExpansionReverted: (_) => Icons.undo,
      optionGranted: (_) => Icons.card_giftcard,
      optionsExercised: (_) => Icons.play_arrow,
      orElse: () => Icons.event,
    );
  }

  Color _getEventColor(CapTableEvent event) {
    return event.maybeMap(
      esopPoolCreated: (_) => Colors.green,
      esopPoolExpanded: (_) => Colors.blue,
      esopPoolActivated: (_) => Colors.teal,
      esopPoolUpdated: (_) => Colors.orange,
      esopPoolExpansionReverted: (_) => Colors.red,
      optionGranted: (_) => Colors.purple,
      optionsExercised: (_) => Colors.indigo,
      orElse: () => Colors.grey,
    );
  }

  void _confirmRevertExpansion(
    BuildContext context,
    WidgetRef ref,
    EsopPoolExpanded expansion,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revert Pool Expansion?'),
        content: Text(
          'This will remove ${Formatters.number(expansion.sharesAdded)} shares '
          'from the pool. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              try {
                await ref
                    .read(esopPoolCommandsProvider.notifier)
                    .revertExpansion(
                      expansionId: expansion.expansionId,
                      poolId: expansion.poolId,
                      previousSize: expansion.newSize,
                      sharesRemoved: expansion.sharesAdded,
                    );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Expansion reverted successfully'),
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
            child: const Text('Revert'),
          ),
        ],
      ),
    );
  }

  Widget _buildPoolGrantsSection(
    BuildContext context,
    WidgetRef ref,
    EsopPool pool,
    AsyncValue<List<OptionGrant>> poolGrantsAsync,
    Map<String, ShareClassesData> shareClassMap,
    List<Stakeholder> stakeholders,
  ) {
    final stakeholderMap = {for (final s in stakeholders) s.id: s};
    final vestingSchedulesAsync = ref.watch(vestingSchedulesStreamProvider);
    final vestingScheduleMap = {
      for (final v in vestingSchedulesAsync.valueOrNull ?? []) v.id: v,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Option Grants from Pool',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        poolGrantsAsync.when(
          data: (grants) {
            if (grants.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No option grants from this pool yet',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
            }
            return Column(
              children: grants.map((grant) {
                final shareClass = shareClassMap[grant.shareClassId];
                final stakeholder = stakeholderMap[grant.stakeholderId];
                final vestingSchedule = grant.vestingScheduleId != null
                    ? vestingScheduleMap[grant.vestingScheduleId]
                    : null;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OptionItem(
                    quantity: grant.quantity,
                    exercisedCount: grant.exercisedCount,
                    cancelledCount: grant.cancelledCount,
                    strikePrice: grant.strikePrice,
                    shareClassName: shareClass?.name ?? 'Unknown',
                    status: grant.status,
                    vestingScheduleName: vestingSchedule?.name,
                    onTap: () => _showGrantDetail(
                      context,
                      ref,
                      grant,
                      stakeholder,
                      shareClass,
                      vestingSchedule,
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => Text('Error: $e'),
        ),
      ],
    );
  }

  void _showGrantDetail(
    BuildContext context,
    WidgetRef ref,
    OptionGrant grant,
    Stakeholder? stakeholder,
    ShareClassesData? shareClass,
    VestingSchedule? vestingSchedule,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                EntityAvatar(
                  name: stakeholder?.name ?? 'Unknown',
                  type: EntityAvatarType.person,
                  size: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stakeholder?.name ?? 'Unknown Grantee',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${Formatters.number(grant.quantity)} options @ \$${grant.strikePrice.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow('Share Class', shareClass?.name ?? 'Unknown'),
            _buildDetailRow(
              'Grant Date',
              Formatters.shortDate(grant.grantDate),
            ),
            _buildDetailRow(
              'Expiry Date',
              Formatters.shortDate(grant.expiryDate),
            ),
            _buildDetailRow('Status', _formatGrantStatus(grant.status)),
            if (vestingSchedule != null)
              _buildDetailRow('Vesting', vestingSchedule.name),
            _buildDetailRow(
              'Exercised',
              Formatters.number(grant.exercisedCount),
            ),
            _buildDetailRow(
              'Cancelled',
              Formatters.number(grant.cancelledCount),
            ),
            _buildDetailRow(
              'Outstanding',
              Formatters.number(
                grant.quantity - grant.exercisedCount - grant.cancelledCount,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatGrantStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'active':
        return 'Active';
      case 'partially_exercised':
        return 'Partially Exercised';
      case 'fully_exercised':
        return 'Fully Exercised';
      case 'cancelled':
        return 'Cancelled';
      case 'expired':
        return 'Expired';
      default:
        return status;
    }
  }

  void _showGrantOptionsDialog(
    BuildContext context,
    WidgetRef ref,
    EsopPool pool,
    List<Stakeholder> stakeholders,
    List<ShareClassesData> shareClasses,
    List<VestingSchedule> vestingSchedules,
    List<EsopPool> esopPools,
  ) {
    final quantityController = TextEditingController();
    final strikeController = TextEditingController(
      text: pool.defaultStrikePrice?.toString() ?? '',
    );
    final notesController = TextEditingController();

    String? selectedStakeholderId;
    String? selectedShareClassId = shareClasses.isNotEmpty ? shareClasses.first.id : null;
    String? selectedVestingScheduleId;
    DateTime grantDate = DateTime.now();
    DateTime expiryDate = DateTime.now().add(
      Duration(days: 365 * pool.defaultExpiryYears),
    );
    bool allowsEarlyExercise = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Grant Options from ${pool.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedStakeholderId,
                  decoration: const InputDecoration(labelText: 'Grantee'),
                  items: stakeholders
                      .map(
                        (s) =>
                            DropdownMenuItem(value: s.id, child: Text(s.name)),
                      )
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => selectedStakeholderId = v),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedShareClassId,
                  decoration: const InputDecoration(labelText: 'Share Class'),
                  items: shareClasses
                      .map(
                        (sc) => DropdownMenuItem(
                          value: sc.id,
                          child: Text(sc.name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setDialogState(() => selectedShareClassId = v);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: strikeController,
                  decoration: const InputDecoration(
                    labelText: 'Strike Price',
                    prefixText: '\$',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  value: selectedVestingScheduleId,
                  decoration: const InputDecoration(
                    labelText: 'Vesting Schedule (Optional)',
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('No Vesting'),
                    ),
                    ...vestingSchedules.map(
                      (v) => DropdownMenuItem(value: v.id, child: Text(v.name)),
                    ),
                  ],
                  onChanged: (v) =>
                      setDialogState(() => selectedVestingScheduleId = v),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: grantDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setDialogState(() {
                        grantDate = date;
                        if (expiryDate.isBefore(grantDate)) {
                          expiryDate = grantDate.add(
                            Duration(days: 365 * pool.defaultExpiryYears),
                          );
                        }
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Grant Date',
                      suffixIcon: Icon(Icons.calendar_today, size: 18),
                    ),
                    child: Text(Formatters.date(grantDate)),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: expiryDate,
                      firstDate: grantDate,
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setDialogState(() => expiryDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Expiry Date',
                      suffixIcon: Icon(Icons.calendar_today, size: 18),
                    ),
                    child: Text(Formatters.date(expiryDate)),
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Allow Early Exercise'),
                  value: allowsEarlyExercise,
                  onChanged: (v) =>
                      setDialogState(() => allowsEarlyExercise = v ?? false),
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
                final quantity = int.tryParse(quantityController.text);
                final strike = double.tryParse(strikeController.text);
                if (quantity == null || quantity <= 0) return;
                if (strike == null || strike <= 0) return;
                if (selectedStakeholderId == null) return;
                if (selectedShareClassId == null) return;

                final commands = ref.read(optionGrantCommandsProvider.notifier);
                await commands.grantOptions(
                  stakeholderId: selectedStakeholderId!,
                  shareClassId: selectedShareClassId!,
                  vestingScheduleId: selectedVestingScheduleId,
                  esopPoolId: pool.id,
                  quantity: quantity,
                  strikePrice: strike,
                  grantDate: grantDate,
                  expiryDate: expiryDate,
                  allowsEarlyExercise: allowsEarlyExercise,
                  notes: notesController.text.trim().isEmpty
                      ? null
                      : notesController.text.trim(),
                );

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Grant'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(
    BuildContext context,
    WidgetRef ref,
    String companyId,
    List<VestingSchedule> vestingSchedules,
  ) {
    final nameController = TextEditingController();
    final poolSizeController = TextEditingController();
    final targetPercentController = TextEditingController();
    final strikePriceController = TextEditingController();
    final expiryYearsController = TextEditingController(text: '10');
    final notesController = TextEditingController();

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
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in required fields'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                try {
                  final targetPercent = double.tryParse(
                    targetPercentController.text,
                  );
                  final strikePrice = double.tryParse(
                    strikePriceController.text,
                  );
                  final expiryYears =
                      int.tryParse(expiryYearsController.text) ?? 10;

                  await ref
                      .read(esopPoolCommandsProvider.notifier)
                      .updatePool(
                        poolId: pool.id,
                        name: nameController.text != pool.name
                            ? nameController.text
                            : null,
                        targetPercentage: targetPercent != pool.targetPercentage
                            ? targetPercent
                            : null,
                        strikePriceMethod:
                            strikePriceMethod != pool.strikePriceMethod
                            ? strikePriceMethod
                            : null,
                        defaultStrikePrice:
                            strikePrice != pool.defaultStrikePrice
                            ? strikePrice
                            : null,
                        defaultExpiryYears:
                            expiryYears != pool.defaultExpiryYears
                            ? expiryYears
                            : null,
                        defaultVestingScheduleId:
                            selectedVestingScheduleId !=
                                pool.defaultVestingScheduleId
                            ? selectedVestingScheduleId
                            : null,
                        notes: notesController.text != (pool.notes ?? '')
                            ? notesController.text.isNotEmpty
                                  ? notesController.text
                                  : null
                            : null,
                      );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pool updated successfully'),
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

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    EsopPool pool,
  ) async {
    // Preview cascade impact
    final cascadeImpact = await ref
        .read(eventLedgerProvider.notifier)
        .previewCascadeDelete(
          entityId: pool.id,
          entityType: EntityType.esopPool,
        );

    final impactLines = <String>[];
    cascadeImpact.forEach((type, count) {
      if (count > 0) {
        impactLines.add('• $count ${type.name}(s)');
      }
    });

    final message = impactLines.isEmpty
        ? 'Are you sure you want to permanently delete "${pool.name}"? This cannot be undone.'
        : 'This will permanently delete:\n${impactLines.join('\n')}\n\nThis cannot be undone.';

    final confirmed = await ConfirmDialog.showDelete(
      context: context,
      itemName: pool.name,
      customMessage: message,
    );

    if (confirmed && context.mounted) {
      try {
        await ref
            .read(esopPoolCommandsProvider.notifier)
            .deletePool(poolId: pool.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pool deleted successfully'),
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
    }
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
