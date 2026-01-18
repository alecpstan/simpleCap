import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/providers.dart';
import '../../domain/constants/type_constants.dart';
import '../../infrastructure/database/database.dart';
import '../../shared/formatters.dart';
import '../components/components.dart';

/// Page displaying all stakeholders.
///
/// Shows a filterable list of stakeholders with expandable details,
/// including holdings, options, and ownership percentages.
class StakeholdersPage extends ConsumerStatefulWidget {
  const StakeholdersPage({super.key});

  @override
  ConsumerState<StakeholdersPage> createState() => _StakeholdersPageState();
}

class _StakeholdersPageState extends ConsumerState<StakeholdersPage> {
  String? _selectedType;
  String _searchQuery = '';
  bool _groupByType = true;

  // Define the display order for stakeholder types
  static const _typeOrder = [
    'founder',
    'employee',
    'investor',
    'angel',
    'vcFund',
    'institution',
    'advisor',
    'company',
    'other',
  ];

  @override
  Widget build(BuildContext context) {
    final stakeholdersAsync = ref.watch(stakeholdersStreamProvider);
    final companyId = ref.watch(currentCompanyIdProvider);

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
          ref.invalidate(stakeholdersStreamProvider);
          ref.invalidate(ownershipSummaryProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildSummaryCards(context)),
            stakeholdersAsync.when(
              data: (stakeholders) {
                final filtered = _filterStakeholders(stakeholders);
                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    child: EmptyState.noItems(
                      itemType: 'stakeholder',
                      onAdd: () => _showAddDialog(context, companyId),
                    ),
                  );
                }
                if (_groupByType && _selectedType == null) {
                  return _buildGroupedList(context, filtered);
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index == filtered.length) {
                      return const SizedBox(height: 80);
                    }
                    return _buildStakeholderCard(context, filtered[index]);
                  }, childCount: filtered.length + 1),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: EmptyState.error(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(stakeholdersStreamProvider),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, companyId),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGroupedList(
    BuildContext context,
    List<Stakeholder> stakeholders,
  ) {
    // Group stakeholders by type
    final grouped = <String, List<Stakeholder>>{};
    for (final s in stakeholders) {
      grouped.putIfAbsent(s.type, () => []).add(s);
    }

    // Sort groups by defined order
    final sortedTypes = grouped.keys.toList()
      ..sort((a, b) {
        final aIndex = _typeOrder.indexOf(a);
        final bIndex = _typeOrder.indexOf(b);
        // Put unknown types at the end
        final aOrder = aIndex == -1 ? 999 : aIndex;
        final bOrder = bIndex == -1 ? 999 : bIndex;
        return aOrder.compareTo(bOrder);
      });

    // Build list of widgets with headers
    final List<Widget> children = [];
    for (final type in sortedTypes) {
      final typeStakeholders = grouped[type]!;
      children.add(_buildGroupHeader(context, type, typeStakeholders.length));
      children.addAll(
        typeStakeholders.map((s) => _buildStakeholderCard(context, s)),
      );
    }
    children.add(const SizedBox(height: 80));

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => children[index],
        childCount: children.length,
      ),
    );
  }

  Widget _buildGroupHeader(BuildContext context, String type, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(_getTypeIcon(type), size: 20, color: _getTypeColor(type)),
          const SizedBox(width: 8),
          Text(
            _formatTypeForHeader(type),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: _getTypeColor(type),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getTypeColor(type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: _getTypeColor(type),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'founder':
        return Icons.star;
      case 'employee':
        return Icons.badge;
      case 'investor':
      case 'angel':
        return Icons.account_balance;
      case 'vcFund':
        return Icons.business_center;
      case 'institution':
        return Icons.apartment;
      case 'advisor':
        return Icons.lightbulb;
      case 'company':
        return Icons.business;
      default:
        return Icons.person;
    }
  }

  String _formatTypeForHeader(String type) {
    switch (type) {
      case 'founder':
        return 'Founders';
      case 'employee':
        return 'Employees';
      case 'investor':
        return 'Investors';
      case 'angel':
        return 'Angel Investors';
      case 'vcFund':
        return 'VC Funds';
      case 'institution':
        return 'Institutions';
      case 'advisor':
        return 'Advisors';
      case 'company':
        return 'Companies';
      default:
        return 'Other';
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stakeholders',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search stakeholders...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(_groupByType ? Icons.view_agenda : Icons.view_list),
                tooltip: _groupByType ? 'Show flat list' : 'Group by type',
                onPressed: () => setState(() => _groupByType = !_groupByType),
              ),
              PopupMenuButton<String?>(
                icon: Badge(
                  isLabelVisible: _selectedType != null,
                  child: const Icon(Icons.filter_list),
                ),
                onSelected: (type) => setState(() => _selectedType = type),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: null, child: Text('All types')),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'founder',
                    child: Text('Founders'),
                  ),
                  const PopupMenuItem(
                    value: 'employee',
                    child: Text('Employees'),
                  ),
                  const PopupMenuItem(
                    value: 'investor',
                    child: Text('Investors'),
                  ),
                  const PopupMenuItem(
                    value: 'angel',
                    child: Text('Angel Investors'),
                  ),
                  const PopupMenuItem(value: 'vcFund', child: Text('VC Funds')),
                  const PopupMenuItem(
                    value: 'institution',
                    child: Text('Institutions'),
                  ),
                  const PopupMenuItem(
                    value: 'advisor',
                    child: Text('Advisors'),
                  ),
                  const PopupMenuItem(
                    value: 'company',
                    child: Text('Companies'),
                  ),
                  const PopupMenuItem(value: 'other', child: Text('Other')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    final stakeholdersAsync = ref.watch(stakeholdersStreamProvider);

    return stakeholdersAsync.when(
      data: (stakeholders) {
        if (stakeholders.isEmpty) return const SizedBox.shrink();

        final founders = stakeholders.where((s) => s.type == 'founder').length;
        final investors = stakeholders
            .where((s) => s.type == 'investor')
            .length;
        final employees = stakeholders
            .where((s) => s.type == 'employee')
            .length;
        final advisors = stakeholders.where((s) => s.type == 'advisor').length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cards = <Widget>[
                SummaryCard(
                  label: 'Total',
                  value: stakeholders.length.toString(),
                  icon: Icons.people,
                  color: Colors.blue,
                ),
                if (founders > 0)
                  SummaryCard(
                    label: 'Founders',
                    value: founders.toString(),
                    icon: Icons.star,
                    color: Colors.indigo,
                  ),
                if (investors > 0)
                  SummaryCard(
                    label: 'Investors',
                    value: investors.toString(),
                    icon: Icons.account_balance,
                    color: Colors.green,
                  ),
                if (employees > 0)
                  SummaryCard(
                    label: 'Employees',
                    value: employees.toString(),
                    icon: Icons.badge,
                    color: Colors.teal,
                  ),
                if (advisors > 0)
                  SummaryCard(
                    label: 'Advisors',
                    value: advisors.toString(),
                    icon: Icons.lightbulb,
                    color: Colors.orange,
                  ),
              ];
              final cardsPerRow = cards.length == 1 ? 1 : 2;
              final spacing = 8.0;
              final fullWidth = constraints.maxWidth;
              final cardWidth =
                  (fullWidth - (cardsPerRow - 1) * spacing) / cardsPerRow;
              return Wrap(
                spacing: spacing,
                runSpacing: 8,
                children: cards.asMap().entries.map((entry) {
                  final index = entry.key;
                  final card = entry.value;
                  final isLastOdd =
                      cards.length.isOdd && index == cards.length - 1;
                  final width = isLastOdd ? fullWidth : cardWidth;
                  return SizedBox(width: width, child: card);
                }).toList(),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  List<Stakeholder> _filterStakeholders(List<Stakeholder> stakeholders) {
    return stakeholders.where((s) {
      if (_selectedType != null && s.type != _selectedType) return false;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!s.name.toLowerCase().contains(query) &&
            !(s.email?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Widget _buildStakeholderCard(BuildContext context, Stakeholder stakeholder) {
    final holdingsAsync = ref.watch(
      stakeholderHoldingsProvider(stakeholder.id),
    );
    final ownershipAsync = ref.watch(ownershipSummaryProvider);
    final shareClassesAsync = ref.watch(shareClassesStreamProvider);
    final optionsAsync = ref.watch(optionGrantsStreamProvider);
    final convertiblesAsync = ref.watch(convertiblesStreamProvider);
    final warrantsAsync = ref.watch(warrantsStreamProvider);
    final roundsAsync = ref.watch(roundsStreamProvider);
    final deleteEnabled = ref.watch(deleteEnabledProvider).valueOrNull ?? false;

    // Calculate ownership percentage
    final ownershipPercent = ownershipAsync.whenOrNull(
      data: (summary) => summary.getOwnershipPercent(stakeholder.id),
    );

    // Get stakeholder's total shares
    final totalShares = holdingsAsync.whenOrNull(
      data: (holdings) => holdings.fold(0, (sum, h) => sum + h.shareCount),
    );

    // Get stakeholder's options count
    final optionsCount = optionsAsync.whenOrNull(
      data: (options) {
        final stakeholderOptions = options
            .where((o) => o.stakeholderId == stakeholder.id)
            .toList();
        return stakeholderOptions.fold(
          0,
          (sum, o) => sum + o.quantity - o.exercisedCount - o.cancelledCount,
        );
      },
    );

    // Get stakeholder's convertibles total
    final convertiblesTotal = convertiblesAsync.whenOrNull(
      data: (convertibles) {
        final stakeholderConvertibles = convertibles
            .where(
              (c) =>
                  c.stakeholderId == stakeholder.id &&
                  c.status == 'outstanding',
            )
            .toList();
        return stakeholderConvertibles.fold(0.0, (sum, c) => sum + c.principal);
      },
    );

    // Get stakeholder's warrants count
    final warrantsCount = warrantsAsync.whenOrNull(
      data: (warrants) {
        final stakeholderWarrants = warrants
            .where((w) => w.stakeholderId == stakeholder.id)
            .toList();
        return stakeholderWarrants.fold(
          0,
          (sum, w) => sum + w.quantity - w.exercisedCount - w.cancelledCount,
        );
      },
    );

    // Check if stakeholder has any draft holdings
    final hasDraftEquity =
        holdingsAsync.whenOrNull(
          data: (holdings) {
            final draftRoundIds = roundsAsync.whenOrNull(
              data: (rounds) => {
                for (final r in rounds)
                  if (r.status == 'draft') r.id,
              },
            );
            if (draftRoundIds == null) return false;
            return holdings.any(
              (h) => h.roundId != null && draftRoundIds.contains(h.roundId),
            );
          },
        ) ??
        false;

    return ExpandableCard(
      leading: EntityAvatar(
        name: stakeholder.name,
        type: _getAvatarType(stakeholder.type),
      ),
      title: stakeholder.name,
      titleBadge: StatusBadge(
        label: _formatType(stakeholder.type),
        color: _getTypeColor(stakeholder.type),
      ),
      subtitle: stakeholder.email,
      trailing: ownershipPercent != null && ownershipPercent > 0
          ? Text(
              '${ownershipPercent.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : null,
      chips: [
        if (totalShares != null && totalShares > 0)
          MetricChip(
            label: 'Shares',
            value: Formatters.compactNumber(totalShares),
            color: Colors.blue,
          ),
        if (optionsCount != null && optionsCount > 0)
          MetricChip(
            label: 'Options',
            value: Formatters.compactNumber(optionsCount),
            color: Colors.orange,
          ),
        if (convertiblesTotal != null && convertiblesTotal > 0)
          MetricChip(
            label: 'Convertibles',
            value: Formatters.compactCurrency(convertiblesTotal),
            color: Colors.purple,
          ),
        if (warrantsCount != null && warrantsCount > 0)
          MetricChip(
            label: 'Warrants',
            value: Formatters.compactNumber(warrantsCount),
            color: Colors.teal,
          ),
      ],
      cornerBadge: hasDraftEquity ? StatusBadge.draft() : null,
      expandedContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (stakeholder.notes != null && stakeholder.notes!.isNotEmpty) ...[
            Text(
              stakeholder.notes!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Divider(height: 24),
          ],
          _buildHoldingsSection(
            context,
            holdingsAsync,
            shareClassesAsync,
            deleteEnabled,
          ),
          _buildOptionsSection(
            context,
            stakeholder.id,
            optionsAsync,
            shareClassesAsync,
            deleteEnabled,
          ),
          _buildConvertiblesSection(
            context,
            stakeholder.id,
            convertiblesAsync,
            deleteEnabled,
          ),
          _buildWarrantsSection(
            context,
            stakeholder.id,
            warrantsAsync,
            shareClassesAsync,
            deleteEnabled,
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: () => _showEditDialog(context, stakeholder),
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('Edit'),
        ),
        TextButton.icon(
          onPressed: () => _confirmDelete(context, stakeholder),
          icon: const Icon(Icons.delete, size: 18),
          label: const Text('Delete'),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    );
  }

  Widget _buildHoldingsSection(
    BuildContext context,
    AsyncValue<List<Holding>> holdingsAsync,
    AsyncValue<List<ShareClassesData>> shareClassesAsync,
    bool deleteEnabled,
  ) {
    return holdingsAsync.when(
      data: (holdings) {
        if (holdings.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'No shares held',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Holdings',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...holdings.map(
              (h) => _buildHoldingRow(
                context,
                h,
                shareClassesAsync,
                deleteEnabled,
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(8),
        child: CircularProgressIndicator(),
      ),
      error: (e, _) => Text('Error: $e'),
    );
  }

  Widget _buildHoldingRow(
    BuildContext context,
    Holding holding,
    AsyncValue<List<ShareClassesData>> shareClassesAsync,
    bool deleteEnabled,
  ) {
    final shareClassName = shareClassesAsync.whenOrNull(
      data: (classes) =>
          classes.where((c) => c.id == holding.shareClassId).firstOrNull?.name,
    );
    final roundsAsync = ref.watch(roundsStreamProvider);
    final round = roundsAsync.whenOrNull(
      data: (rounds) =>
          rounds.where((r) => r.id == holding.roundId).firstOrNull,
    );
    final roundName = round?.name;
    final isDraft = round?.status == 'draft';
    final hasVesting = holding.vestingScheduleId != null;

    // Get the vesting schedule if applicable
    final vestingSchedule = hasVesting
        ? ref.watch(vestingScheduleProvider(holding.vestingScheduleId))
        : null;

    return HoldingItem(
      shareCount: holding.shareCount,
      vestedCount: holding.vestedCount ?? holding.shareCount,
      shareClassName: shareClassName ?? 'Unknown',
      costBasis: holding.costBasis,
      acquiredDate: holding.acquiredDate,
      roundName: roundName,
      hasVesting: hasVesting,
      isDraft: isDraft,
      vestingScheduleName: vestingSchedule?.name,
      vestingScheduleTerms: vestingSchedule != null
          ? _buildVestingTerms(vestingSchedule)
          : null,
      onTap: () => HoldingDetailDialog.show(
        context: context,
        holding: holding,
        shareClassName: shareClassName,
        roundName: roundName,
        vestingSchedule: vestingSchedule,
        onEdit: () => _showEditHoldingDialog(context, holding),
        onDelete: () => _confirmDeleteHolding(context, holding),
        showDeleteButton: deleteEnabled,
        isDraft: isDraft,
      ),
    );
  }

  void _showEditHoldingDialog(BuildContext context, Holding holding) {
    final shareClassesAsync = ref.read(shareClassesStreamProvider);
    final vestingSchedulesAsync = ref.read(vestingSchedulesStreamProvider);
    final shareClasses = shareClassesAsync.valueOrNull ?? [];
    final vestingSchedules = vestingSchedulesAsync.valueOrNull ?? [];

    final shareCountController = TextEditingController(
      text: holding.shareCount.toString(),
    );
    final costBasisController = TextEditingController(
      text: holding.costBasis.toStringAsFixed(4),
    );
    String selectedShareClassId = holding.shareClassId;
    String? selectedVestingScheduleId = holding.vestingScheduleId;
    DateTime acquiredDate = holding.acquiredDate;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Edit Holding'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: shareCountController,
                  decoration: const InputDecoration(labelText: 'Share Count'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: costBasisController,
                  decoration: const InputDecoration(
                    labelText: 'Cost Basis (per share)',
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
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
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedShareClassId = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  value: selectedVestingScheduleId,
                  decoration: const InputDecoration(
                    labelText: 'Vesting Schedule',
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('No vesting'),
                    ),
                    ...vestingSchedules.map(
                      (vs) =>
                          DropdownMenuItem(value: vs.id, child: Text(vs.name)),
                    ),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => selectedVestingScheduleId = value),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Acquired Date'),
                  subtitle: Text(Formatters.date(acquiredDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: dialogContext,
                      initialDate: acquiredDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setDialogState(() => acquiredDate = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final shareCount = int.tryParse(shareCountController.text);
                final costBasis = double.tryParse(costBasisController.text);
                if (shareCount == null || shareCount <= 0) return;

                try {
                  await ref
                      .read(holdingCommandsProvider.notifier)
                      .updateHolding(
                        holdingId: holding.id,
                        shareCount: shareCount,
                        costBasis: costBasis,
                        acquiredDate: acquiredDate,
                        shareClassId: selectedShareClassId,
                        vestingScheduleId: selectedVestingScheduleId,
                      );

                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(
                      dialogContext,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
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

  Future<void> _confirmDeleteHolding(
    BuildContext context,
    Holding holding,
  ) async {
    final confirmed = await ConfirmDialog.showDelete(
      context: context,
      itemName: 'holding',
    );

    if (confirmed && mounted) {
      try {
        await ref
            .read(holdingCommandsProvider.notifier)
            .deleteHolding(holdingId: holding.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Holding deleted'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting holding: $e'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Widget _buildOptionsSection(
    BuildContext context,
    String stakeholderId,
    AsyncValue<List<OptionGrant>> optionsAsync,
    AsyncValue<List<ShareClassesData>> shareClassesAsync,
    bool deleteEnabled,
  ) {
    return optionsAsync.when(
      data: (allOptions) {
        final options = allOptions
            .where((o) => o.stakeholderId == stakeholderId)
            .toList();
        if (options.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 24),
            Text(
              'Stock Options',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...options.map(
              (o) =>
                  _buildOptionRow(context, o, shareClassesAsync, deleteEnabled),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildOptionRow(
    BuildContext context,
    OptionGrant option,
    AsyncValue<List<ShareClassesData>> shareClassesAsync,
    bool deleteEnabled,
  ) {
    final roundsAsync = ref.watch(roundsStreamProvider);
    final shareClassName = shareClassesAsync.whenOrNull(
      data: (classes) =>
          classes.where((c) => c.id == option.shareClassId).firstOrNull?.name,
    );

    // Determine if this option is part of a draft round
    final round = roundsAsync.whenOrNull(
      data: (rounds) => rounds.where((r) => r.id == option.roundId).firstOrNull,
    );
    final isDraft = round?.status == 'draft';

    // Get the vesting schedule if applicable
    final hasVesting = option.vestingScheduleId != null;
    final vestingSchedule = hasVesting
        ? ref.watch(vestingScheduleProvider(option.vestingScheduleId))
        : null;

    // Calculate vesting status
    final vestingStatus = hasVesting && vestingSchedule != null
        ? ref.watch(
            calculateVestingStatusProvider(
              totalQuantity: option.quantity,
              grantDate: option.grantDate,
              vestingScheduleId: option.vestingScheduleId,
            ),
          )
        : null;

    return OptionItem(
      quantity: option.quantity,
      exercisedCount: option.exercisedCount,
      cancelledCount: option.cancelledCount,
      strikePrice: option.strikePrice,
      shareClassName: shareClassName ?? 'Unknown',
      status: option.status,
      vestingPercent: vestingStatus?.vestingPercent,
      vestingScheduleName: vestingSchedule?.name,
      vestingScheduleTerms: vestingSchedule != null
          ? _buildVestingTerms(vestingSchedule)
          : null,
      vestedCount: vestingStatus?.vestedQuantity,
      isDraft: isDraft,
      onTap: () => OptionDetailDialog.show(
        context: context,
        option: option,
        shareClassName: shareClassName,
        vestingPercent: vestingStatus?.vestingPercent,
        vestingSchedule: vestingSchedule,
        onEdit: () => _showOptionEditDialog(context, option),
        onExercise: isDraft
            ? null
            : () => _showOptionExerciseDialog(context, option),
        onCancel: isDraft ? null : () => _confirmCancelOption(context, option),
        onDelete: () => _confirmDeleteOption(context, option),
        showDeleteButton: deleteEnabled,
        isDraft: isDraft,
      ),
    );
  }

  /// Cancel outstanding options (soft cancel - creates event)
  Future<void> _confirmCancelOption(
    BuildContext context,
    OptionGrant option,
  ) async {
    final remainingCount =
        option.quantity - option.exercisedCount - option.cancelledCount;
    if (remainingCount <= 0) return;

    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Cancel Options?',
      message:
          'This will cancel $remainingCount outstanding options. This action will be recorded.',
      confirmLabel: 'Cancel Options',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      try {
        await ref
            .read(optionGrantCommandsProvider.notifier)
            .cancelOptions(
              grantId: option.id,
              cancelledCount: remainingCount,
              reason: 'Cancelled via UI',
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Options cancelled'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error cancelling options: $e'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  /// Permanently delete option grant (cascade delete - removes events)
  Future<void> _confirmDeleteOption(
    BuildContext context,
    OptionGrant option,
  ) async {
    // Preview cascade impact
    final cascadeImpact = await ref
        .read(eventLedgerProvider.notifier)
        .previewCascadeDelete(
          entityId: option.id,
          entityType: EntityType.optionGrant,
        );

    final holdingsCount = cascadeImpact[EntityType.holding] ?? 0;
    String message = 'This will permanently delete this option grant.';
    if (holdingsCount > 0) {
      message +=
          ' This will also delete $holdingsCount holding(s) created from exercising these options.';
    }
    message += ' This cannot be undone.';

    final confirmed = await ConfirmDialog.showDelete(
      context: context,
      itemName: 'option grant',
      customMessage: message,
    );

    if (confirmed && mounted) {
      try {
        await ref
            .read(optionGrantCommandsProvider.notifier)
            .deleteOptionGrant(grantId: option.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Option grant deleted'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting option grant: $e'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _showOptionEditDialog(BuildContext context, OptionGrant option) {
    // TODO: Implement option edit dialog
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Option editing coming soon')));
  }

  Future<void> _showOptionExerciseDialog(
    BuildContext context,
    OptionGrant option,
  ) async {
    // Calculate vesting to get exercisable amount
    final vestingStatus = option.vestingScheduleId != null
        ? ref.read(
            calculateVestingStatusProvider(
              totalQuantity: option.quantity,
              grantDate: option.grantDate,
              vestingScheduleId: option.vestingScheduleId,
            ),
          )
        : null;

    // Calculate max exercisable - if no vesting, all outstanding are exercisable
    final outstanding =
        option.quantity - option.exercisedCount - option.cancelledCount;
    final maxExercisable = vestingStatus != null
        ? vestingStatus.vestedQuantity - option.exercisedCount
        : outstanding;

    if (maxExercisable <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No vested options available to exercise'),
        ),
      );
      return;
    }

    // Get stakeholder name
    final stakeholders = ref.read(stakeholdersStreamProvider).valueOrNull ?? [];
    final stakeholder = stakeholders
        .where((s) => s.id == option.stakeholderId)
        .firstOrNull;

    final result = await ExerciseOptionsDialog.show(
      context: context,
      option: option,
      maxExercisable: maxExercisable,
      stakeholderName: stakeholder?.name,
    );

    if (result == true && mounted) {
      // Close the detail dialog
      Navigator.of(context).pop();
    }
  }

  Widget _buildConvertiblesSection(
    BuildContext context,
    String stakeholderId,
    AsyncValue<List<Convertible>> convertiblesAsync,
    bool deleteEnabled,
  ) {
    return convertiblesAsync.when(
      data: (allConvertibles) {
        final convertibles = allConvertibles
            .where((c) => c.stakeholderId == stakeholderId)
            .toList();
        if (convertibles.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 24),
            Text(
              'Convertibles',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...convertibles.map(
              (c) => _buildConvertibleRow(context, c, deleteEnabled),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildConvertibleRow(
    BuildContext context,
    Convertible convertible,
    bool deleteEnabled,
  ) {
    final roundsAsync = ref.watch(roundsStreamProvider);
    final isConverted = convertible.status == 'converted';
    final isCancelled = convertible.status == 'cancelled';

    // Check if conversion is draft (convertible converted in a draft round)
    // or if this is a new convertible issued as part of a draft round
    bool isDraftConversion = false;
    if (isConverted && convertible.conversionEventId != null) {
      final conversionRound = roundsAsync.whenOrNull(
        data: (rounds) => rounds
            .where((r) => r.id == convertible.conversionEventId)
            .firstOrNull,
      );
      isDraftConversion = conversionRound?.status == 'draft';
    }

    // Determine display status for draft conversion
    final displayStatus = isDraftConversion
        ? 'draft_conversion'
        : convertible.status;

    return ConvertibleItem(
      type: convertible.type,
      principal: convertible.principal,
      valuationCap: convertible.valuationCap,
      discountPercent: convertible.discountPercent,
      interestRate: convertible.interestRate,
      status: displayStatus,
      isDraft: isDraftConversion,
      onTap: () => ConvertibleDetailDialog.show(
        context: context,
        convertible: convertible,
        onEdit: isConverted || isCancelled
            ? null
            : () => _showConvertibleEditDialog(context, convertible),
        // Disable convert action if already converted (even draft)
        onConvert: isConverted || isCancelled
            ? null
            : () => _showConvertibleConvertDialog(context, convertible),
        // Allow revert for both real and draft conversions
        onRevert: isConverted
            ? () => _revertConvertible(context, convertible)
            : null,
        // Hide cancel for draft conversions (use revert instead)
        onCancel: isConverted || isCancelled
            ? null
            : () => _confirmCancelConvertible(context, convertible),
        onDelete: () => _confirmDeleteConvertible(context, convertible),
        showDeleteButton: deleteEnabled,
        isDraft: isDraftConversion,
      ),
    );
  }

  Future<void> _confirmCancelConvertible(
    BuildContext context,
    Convertible convertible,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Cancel Convertible',
      message:
          'Are you sure you want to cancel this ${convertible.type}? This will record a cancellation event.',
      confirmLabel: 'Cancel Convertible',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      await ref
          .read(convertibleCommandsProvider.notifier)
          .cancelConvertible(
            convertibleId: convertible.id,
            reason: 'Cancelled via UI',
          );
      if (mounted) {
        Navigator.of(context).pop(); // Close the dialog
      }
    }
  }

  Future<void> _confirmDeleteConvertible(
    BuildContext context,
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

    final message = impactLines.isEmpty
        ? 'Are you sure you want to permanently delete this ${convertible.type}? This cannot be undone.'
        : 'This will permanently delete:\n${impactLines.join('\n')}\n\nThis cannot be undone.';

    final confirmed = await ConfirmDialog.showDelete(
      context: context,
      itemName: convertible.type,
      customMessage: message,
    );

    if (confirmed && mounted) {
      await ref
          .read(convertibleCommandsProvider.notifier)
          .deleteConvertible(convertibleId: convertible.id);
      if (mounted) {
        Navigator.of(context).pop(); // Close the dialog
      }
    }
  }

  void _showConvertibleEditDialog(
    BuildContext context,
    Convertible convertible,
  ) {
    // Get share classes for dropdown
    final shareClasses = ref.read(shareClassesStreamProvider).valueOrNull ?? [];

    final principalController = TextEditingController(
      text: convertible.principal.toString(),
    );
    final capController = TextEditingController(
      text: convertible.valuationCap?.toString() ?? '',
    );
    final discountController = TextEditingController(
      text: convertible.discountPercent?.toString() ?? '',
    );
    final interestController = TextEditingController(
      text: convertible.interestRate?.toString() ?? '',
    );
    final notesController = TextEditingController(
      text: convertible.notes ?? '',
    );
    final qualifiedThresholdController = TextEditingController(
      text: convertible.qualifiedFinancingThreshold?.toString() ?? '',
    );
    final liquidityMultipleController = TextEditingController(
      text: convertible.liquidityPayoutMultiple?.toString() ?? '',
    );

    String selectedType = convertible.type;
    DateTime issueDate = convertible.issueDate;
    DateTime? maturityDate = convertible.maturityDate;
    bool hasMfn = convertible.hasMfn;
    bool hasProRata = convertible.hasProRata;

    // Advanced terms state
    String? maturityBehavior = convertible.maturityBehavior;
    bool allowsVoluntaryConversion = convertible.allowsVoluntaryConversion;
    String? liquidityEventBehavior = convertible.liquidityEventBehavior;
    String? dissolutionBehavior = convertible.dissolutionBehavior;
    String? preferredShareClassId = convertible.preferredShareClassId;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Edit Convertible'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final principal = double.tryParse(principalController.text);
                if (principal == null || principal <= 0) return;

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

                await commands.updateConvertible(
                  convertibleId: convertible.id,
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

                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showConvertibleConvertDialog(
    BuildContext context,
    Convertible convertible,
  ) async {
    // Get stakeholder name
    final stakeholders = ref.read(stakeholdersStreamProvider).valueOrNull ?? [];
    final stakeholder = stakeholders
        .where((s) => s.id == convertible.stakeholderId)
        .firstOrNull;

    final result = await ConvertConvertibleDialog.show(
      context: context,
      convertible: convertible,
      stakeholderName: stakeholder?.name,
    );

    if (result == true && mounted) {
      // Close the detail dialog
      Navigator.of(context).pop();
    }
  }

  Future<void> _revertConvertible(
    BuildContext context,
    Convertible convertible,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Revert Conversion?',
      message: 'This will change the convertible status back to outstanding.',
      confirmLabel: 'Revert',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      // TODO: Implement revertConversion in ConvertibleCommands
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revert not yet implemented')),
      );
    }
  }

  Widget _buildWarrantsSection(
    BuildContext context,
    String stakeholderId,
    AsyncValue<List<Warrant>> warrantsAsync,
    AsyncValue<List<ShareClassesData>> shareClassesAsync,
    bool deleteEnabled,
  ) {
    return warrantsAsync.when(
      data: (allWarrants) {
        final warrants = allWarrants
            .where((w) => w.stakeholderId == stakeholderId)
            .toList();
        if (warrants.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 24),
            Text(
              'Warrants',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...warrants.map(
              (w) => _buildWarrantRow(
                context,
                w,
                shareClassesAsync,
                deleteEnabled,
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildWarrantRow(
    BuildContext context,
    Warrant warrant,
    AsyncValue<List<ShareClassesData>> shareClassesAsync,
    bool deleteEnabled,
  ) {
    final roundsAsync = ref.watch(roundsStreamProvider);
    final shareClassName = shareClassesAsync.whenOrNull(
      data: (classes) =>
          classes.where((c) => c.id == warrant.shareClassId).firstOrNull?.name,
    );

    // Determine if this warrant is part of a draft round
    final round = roundsAsync.whenOrNull(
      data: (rounds) =>
          rounds.where((r) => r.id == warrant.roundId).firstOrNull,
    );
    final isDraft = round?.status == 'draft';

    final isActive = warrant.status == 'active';
    final remaining =
        warrant.quantity - warrant.exercisedCount - warrant.cancelledCount;
    final isCancelled = remaining <= 0 && warrant.cancelledCount > 0;

    return WarrantItem(
      quantity: warrant.quantity,
      exercisedCount: warrant.exercisedCount,
      cancelledCount: warrant.cancelledCount,
      strikePrice: warrant.strikePrice,
      shareClassName: shareClassName,
      status: warrant.status,
      expiryDate: warrant.expiryDate,
      isDraft: isDraft,
      onTap: () => WarrantDetailDialog.show(
        context: context,
        warrant: warrant,
        shareClassName: shareClassName,
        onEdit: () => _showWarrantEditDialog(context, warrant),
        onExercise: (isActive && remaining > 0 && !isDraft)
            ? () => _showWarrantExerciseDialog(context, warrant)
            : null,
        onCancel: (isActive && remaining > 0 && !isCancelled && !isDraft)
            ? () => _confirmCancelWarrant(context, warrant)
            : null,
        onDelete: () => _confirmDeleteWarrant(context, warrant),
        showDeleteButton: deleteEnabled,
        isDraft: isDraft,
      ),
    );
  }

  Future<void> _confirmCancelWarrant(
    BuildContext context,
    Warrant warrant,
  ) async {
    final remaining =
        warrant.quantity - warrant.exercisedCount - warrant.cancelledCount;

    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Cancel Warrant',
      message:
          'Are you sure you want to cancel the remaining $remaining warrant(s)? This will record a cancellation event.',
      confirmLabel: 'Cancel Warrant',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      await ref
          .read(warrantCommandsProvider.notifier)
          .cancelWarrants(
            warrantId: warrant.id,
            cancelledCount: remaining,
            reason: 'Cancelled via UI',
          );
      if (mounted) {
        Navigator.of(context).pop(); // Close the dialog
      }
    }
  }

  Future<void> _confirmDeleteWarrant(
    BuildContext context,
    Warrant warrant,
  ) async {
    // Preview cascade impact
    final cascadeImpact = await ref
        .read(eventLedgerProvider.notifier)
        .previewCascadeDelete(
          entityId: warrant.id,
          entityType: EntityType.warrant,
        );

    final impactLines = <String>[];
    cascadeImpact.forEach((type, count) {
      if (count > 0) {
        impactLines.add('• $count ${type.name}(s)');
      }
    });

    final message = impactLines.isEmpty
        ? 'Are you sure you want to permanently delete this warrant? This cannot be undone.'
        : 'This will permanently delete:\n${impactLines.join('\n')}\n\nThis cannot be undone.';

    final confirmed = await ConfirmDialog.showDelete(
      context: context,
      itemName: 'warrant',
      customMessage: message,
    );

    if (confirmed && mounted) {
      await ref
          .read(warrantCommandsProvider.notifier)
          .deleteWarrant(warrantId: warrant.id);
      if (mounted) {
        Navigator.of(context).pop(); // Close the dialog
      }
    }
  }

  void _showWarrantEditDialog(BuildContext context, Warrant warrant) {
    // TODO: Implement warrant edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Warrant editing coming soon')),
    );
  }

  Future<void> _showWarrantExerciseDialog(
    BuildContext context,
    Warrant warrant,
  ) async {
    final maxExercisable =
        warrant.quantity - warrant.exercisedCount - warrant.cancelledCount;

    if (maxExercisable <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No warrants available to exercise')),
      );
      return;
    }

    // Get stakeholder name
    final stakeholders = ref.read(stakeholdersStreamProvider).valueOrNull ?? [];
    final stakeholder = stakeholders
        .where((s) => s.id == warrant.stakeholderId)
        .firstOrNull;

    final result = await ExerciseWarrantsDialog.show(
      context: context,
      warrant: warrant,
      maxExercisable: maxExercisable,
      stakeholderName: stakeholder?.name,
    );

    if (result == true && mounted) {
      // Close the detail dialog
      Navigator.of(context).pop();
    }
  }

  EntityAvatarType _getAvatarType(String type) {
    switch (type) {
      case 'company':
        return EntityAvatarType.company;
      default:
        return EntityAvatarType.person;
    }
  }

  String _formatType(String type) {
    switch (type) {
      case 'founder':
        return 'Founder';
      case 'employee':
        return 'Employee';
      case 'investor':
        return 'Investor';
      case 'angel':
        return 'Angel';
      case 'vcFund':
        return 'VC Fund';
      case 'institution':
        return 'Institution';
      case 'advisor':
        return 'Advisor';
      case 'company':
        return 'Company';
      default:
        return 'Other';
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'founder':
        return Colors.indigo;
      case 'employee':
        return Colors.teal;
      case 'investor':
      case 'angel':
        return Colors.green;
      case 'vcFund':
        return Colors.blue;
      case 'institution':
        return Colors.deepPurple;
      case 'advisor':
        return Colors.orange;
      case 'company':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  void _showAddDialog(BuildContext context, String companyId) {
    _showStakeholderDialog(context, companyId: companyId);
  }

  void _showEditDialog(BuildContext context, Stakeholder stakeholder) {
    _showStakeholderDialog(context, stakeholder: stakeholder);
  }

  void _showStakeholderDialog(
    BuildContext context, {
    String? companyId,
    Stakeholder? stakeholder,
  }) {
    final isEditing = stakeholder != null;
    final nameController = TextEditingController(text: stakeholder?.name);
    final emailController = TextEditingController(text: stakeholder?.email);
    final notesController = TextEditingController(text: stakeholder?.notes);
    String selectedType = stakeholder?.type ?? 'founder';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Stakeholder' : 'Add Stakeholder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: !isEditing,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 'founder', child: Text('Founder')),
                    DropdownMenuItem(
                      value: 'employee',
                      child: Text('Employee'),
                    ),
                    DropdownMenuItem(
                      value: 'investor',
                      child: Text('Investor'),
                    ),
                    DropdownMenuItem(
                      value: 'angel',
                      child: Text('Angel Investor'),
                    ),
                    DropdownMenuItem(value: 'vcFund', child: Text('VC Fund')),
                    DropdownMenuItem(
                      value: 'institution',
                      child: Text('Institution'),
                    ),
                    DropdownMenuItem(value: 'advisor', child: Text('Advisor')),
                    DropdownMenuItem(value: 'company', child: Text('Company')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (v) =>
                      setDialogState(() => selectedType = v ?? 'founder'),
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
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                final commands = ref.read(stakeholderCommandsProvider.notifier);

                if (isEditing) {
                  await commands.updateStakeholder(
                    stakeholderId: stakeholder.id,
                    name: name,
                    type: selectedType,
                    email: emailController.text.trim().isEmpty
                        ? null
                        : emailController.text.trim(),
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                  );
                } else {
                  await commands.addStakeholder(
                    name: name,
                    type: selectedType,
                    email: emailController.text.trim().isEmpty
                        ? null
                        : emailController.text.trim(),
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                  );
                }

                if (context.mounted) Navigator.pop(context);
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Stakeholder stakeholder,
  ) async {
    final confirmed = await ConfirmDialog.showDelete(
      context: context,
      itemName: stakeholder.name,
    );

    if (confirmed && mounted) {
      await ref
          .read(stakeholderCommandsProvider.notifier)
          .removeStakeholder(stakeholderId: stakeholder.id);
    }
  }

  /// Builds a human-readable description of vesting terms.
  String _buildVestingTerms(VestingSchedule schedule) {
    final total = schedule.totalMonths ?? 0;
    final years = total ~/ 12;
    final remainingMonths = total % 12;
    final cliffMonths = schedule.cliffMonths;

    final parts = <String>[];

    if (years > 0) {
      parts.add('$years yr${years > 1 ? 's' : ''}');
    }
    if (remainingMonths > 0) {
      parts.add('$remainingMonths mo');
    }

    if (cliffMonths > 0) {
      final cliffYears = cliffMonths ~/ 12;
      final cliffRemaining = cliffMonths % 12;
      if (cliffYears > 0) {
        parts.add('$cliffYears yr cliff');
      } else {
        parts.add('$cliffRemaining mo cliff');
      }
    }

    return parts.isEmpty ? schedule.name : parts.join(' / ');
  }
}
