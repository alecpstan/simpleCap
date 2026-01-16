import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/providers.dart';
import '../../infrastructure/database/database.dart';
import '../components/components.dart';

/// Page displaying ownership as a spreadsheet-style cap table.
class OwnershipPage extends ConsumerStatefulWidget {
  const OwnershipPage({super.key});

  @override
  ConsumerState<OwnershipPage> createState() => _OwnershipPageState();
}

class _OwnershipPageState extends ConsumerState<OwnershipPage> {
  bool _showFullyDiluted = false;

  @override
  Widget build(BuildContext context) {
    final companyId = ref.watch(currentCompanyIdProvider);
    final ownershipAsync = ref.watch(ownershipSummaryProvider);
    final stakeholdersAsync = ref.watch(stakeholdersStreamProvider);
    final holdingsAsync = ref.watch(holdingsStreamProvider);
    final shareClassesAsync = ref.watch(shareClassesStreamProvider);
    final draftRoundIdsAsync = ref.watch(draftRoundIdsProvider);

    if (companyId == null) {
      return const EmptyState(
        icon: Icons.business,
        title: 'No company selected',
        message: 'Please create or select a company first.',
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(ownershipSummaryProvider);
          ref.invalidate(stakeholdersStreamProvider);
          ref.invalidate(holdingsStreamProvider);
          ref.invalidate(shareClassesStreamProvider);
          ref.invalidate(draftRoundIdsProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildCapTable(
                    context,
                    companyId,
                    stakeholdersAsync,
                    holdingsAsync,
                    shareClassesAsync,
                    ownershipAsync,
                    draftRoundIdsAsync,
                  ),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cap Table',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Drag column edges to resize',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Issued')),
            ButtonSegment(value: true, label: Text('Fully Diluted')),
          ],
          selected: {_showFullyDiluted},
          onSelectionChanged: (value) {
            setState(() => _showFullyDiluted = value.first);
          },
          style: const ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Widget _buildCapTable(
    BuildContext context,
    String companyId,
    AsyncValue<List<Stakeholder>> stakeholdersAsync,
    AsyncValue<List<Holding>> holdingsAsync,
    AsyncValue<List<ShareClassesData>> shareClassesAsync,
    AsyncValue<OwnershipSummary> ownershipAsync,
    AsyncValue<Map<String, bool>> draftRoundIdsAsync,
  ) {
    return stakeholdersAsync.when(
      data: (stakeholders) => holdingsAsync.when(
        data: (holdings) => shareClassesAsync.when(
          data: (shareClasses) => ownershipAsync.when(
            data: (ownership) => draftRoundIdsAsync.when(
              data: (draftRoundIds) {
                if (stakeholders.isEmpty || holdings.isEmpty) {
                  return const EmptyState(
                    icon: Icons.table_chart,
                    title: 'No holdings yet',
                    message:
                        'Add stakeholders and issue shares to see the cap table.',
                  );
                }

                return _buildCapTableGrid(
                  companyId,
                  stakeholders,
                  holdings,
                  shareClasses,
                  ownership,
                  draftRoundIds,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => InfoBox.error(message: e.toString()),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => InfoBox.error(message: e.toString()),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => InfoBox.error(message: e.toString()),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => InfoBox.error(message: e.toString()),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => InfoBox.error(message: e.toString()),
    );
  }

  Widget _buildCapTableGrid(
    String companyId,
    List<Stakeholder> stakeholders,
    List<Holding> holdings,
    List<ShareClassesData> shareClasses,
    OwnershipSummary ownership,
    Map<String, bool> draftRoundIds,
  ) {
    // Helper to check if a holding is from a draft round
    bool isPending(Holding h) {
      if (h.roundId == null) return false;
      return draftRoundIds[h.roundId] ?? false;
    }

    // Build data maps: stakeholderId -> (shareClassId -> shares)
    // Separate confirmed (closed round) from pending (draft round)
    final confirmedData = <String, Map<String, int>>{};
    final pendingData = <String, Map<String, int>>{};

    for (final h in holdings) {
      if (isPending(h)) {
        pendingData.putIfAbsent(h.stakeholderId, () => {});
        pendingData[h.stakeholderId]!.update(
          h.shareClassId,
          (v) => v + h.shareCount,
          ifAbsent: () => h.shareCount,
        );
      } else {
        confirmedData.putIfAbsent(h.stakeholderId, () => {});
        confirmedData[h.stakeholderId]!.update(
          h.shareClassId,
          (v) => v + h.shareCount,
          ifAbsent: () => h.shareCount,
        );
      }
    }

    // Build combined data for totals and sorting
    final allData = <String, Map<String, int>>{};
    for (final h in holdings) {
      allData.putIfAbsent(h.stakeholderId, () => {});
      allData[h.stakeholderId]!.update(
        h.shareClassId,
        (v) => v + h.shareCount,
        ifAbsent: () => h.shareCount,
      );
    }

    // Get active stakeholders sorted by total shares
    final activeStakeholderIds = allData.keys.toList();
    final stakeholderTotals = <String, int>{};
    final stakeholderPendingTotals = <String, int>{};
    for (final sid in activeStakeholderIds) {
      stakeholderTotals[sid] = (confirmedData[sid]?.values ?? []).fold(
        0,
        (a, b) => a + b,
      );
      stakeholderPendingTotals[sid] = (pendingData[sid]?.values ?? []).fold(
        0,
        (a, b) => a + b,
      );
    }
    activeStakeholderIds.sort((a, b) {
      final totalA = stakeholderTotals[a]! + stakeholderPendingTotals[a]!;
      final totalB = stakeholderTotals[b]! + stakeholderPendingTotals[b]!;
      return totalB.compareTo(totalA);
    });

    // Get active share classes
    final activeShareClassIds = <String>{};
    for (final row in allData.values) {
      activeShareClassIds.addAll(row.keys);
    }

    final sortedShareClasses =
        shareClasses.where((sc) => activeShareClassIds.contains(sc.id)).toList()
          ..sort((a, b) {
            if (a.type == b.type) return a.name.compareTo(b.name);
            if (a.type == 'common') return -1;
            if (b.type == 'common') return 1;
            return a.name.compareTo(b.name);
          });

    // Calculate totals (confirmed and pending separately)
    final columnTotals = <String, int>{};
    final pendingColumnTotals = <String, int>{};
    for (final sc in sortedShareClasses) {
      columnTotals[sc.id] = 0;
      pendingColumnTotals[sc.id] = 0;
      for (final sid in activeStakeholderIds) {
        columnTotals[sc.id] =
            columnTotals[sc.id]! + (confirmedData[sid]?[sc.id] ?? 0);
        pendingColumnTotals[sc.id] =
            pendingColumnTotals[sc.id]! + (pendingData[sid]?[sc.id] ?? 0);
      }
    }

    final confirmedTotal = columnTotals.values.fold(0, (a, b) => a + b);
    final pendingTotal = pendingColumnTotals.values.fold(0, (a, b) => a + b);
    final totalShares = confirmedTotal + pendingTotal;

    // Build columns
    final columns = sortedShareClasses
        .map(
          (sc) => CapTableColumn(
            id: sc.id,
            name: sc.name,
            subtitle: _formatType(sc.type),
          ),
        )
        .toList();

    // Build rows
    final rows = activeStakeholderIds.map((stakeholderId) {
      final stakeholder = stakeholders.firstWhere(
        (s) => s.id == stakeholderId,
        orElse: () => Stakeholder(
          id: stakeholderId,
          companyId: '',
          name: 'Unknown',
          type: 'unknown',
          hasProRataRights: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      final rowConfirmed = confirmedData[stakeholderId] ?? {};
      final rowPending = pendingData[stakeholderId] ?? {};
      final rowTotal = stakeholderTotals[stakeholderId] ?? 0;
      final rowPendingTotal = stakeholderPendingTotals[stakeholderId] ?? 0;
      final percentage = totalShares > 0
          ? ((rowTotal + rowPendingTotal) / totalShares) * 100
          : 0.0;

      return CapTableRow(
        id: stakeholder.id,
        name: stakeholder.name,
        subtitle: _formatType(stakeholder.type),
        valuesByColumn: rowConfirmed,
        pendingByColumn: rowPending,
        total: rowTotal,
        pendingTotal: rowPendingTotal,
        percentage: percentage,
      );
    }).toList();

    return CapTableGrid(
      tableId: 'ownership_$companyId',
      columns: columns,
      rows: rows,
      columnTotals: columnTotals,
      pendingColumnTotals: pendingColumnTotals,
      grandTotal: confirmedTotal,
      pendingGrandTotal: pendingTotal,
      nameColumnHeader: 'Stakeholder',
    );
  }

  String _formatType(String type) {
    switch (type) {
      case 'common':
        return 'Common';
      case 'preferred':
        return 'Preferred';
      case 'founder':
        return 'Founder';
      case 'investor':
        return 'Investor';
      case 'employee':
        return 'Employee';
      case 'advisor':
        return 'Advisor';
      default:
        return type.isNotEmpty
            ? type[0].toUpperCase() + type.substring(1)
            : type;
    }
  }
}
