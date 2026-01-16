import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/providers.dart';
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

  Widget _buildGroupedList(BuildContext context, List<Stakeholder> stakeholders) {
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
      children.addAll(typeStakeholders.map((s) => _buildStakeholderCard(context, s)));
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
          Icon(
            _getTypeIcon(type),
            size: 20,
            color: _getTypeColor(type),
          ),
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
                icon: Icon(
                  _groupByType ? Icons.view_agenda : Icons.view_list,
                ),
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
                  const PopupMenuItem(
                    value: 'vcFund',
                    child: Text('VC Funds'),
                  ),
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
                  const PopupMenuItem(
                    value: 'other',
                    child: Text('Other'),
                  ),
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
          _buildHoldingsSection(context, holdingsAsync, shareClassesAsync),
          _buildOptionsSection(
            context,
            stakeholder.id,
            optionsAsync,
            shareClassesAsync,
          ),
          _buildConvertiblesSection(context, stakeholder.id, convertiblesAsync),
          _buildWarrantsSection(
            context,
            stakeholder.id,
            warrantsAsync,
            shareClassesAsync,
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
              (h) => _buildHoldingRow(context, h, shareClassesAsync),
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
  ) {
    final shareClassName = shareClassesAsync.whenOrNull(
      data: (classes) =>
          classes.where((c) => c.id == holding.shareClassId).firstOrNull?.name,
    );
    final roundsAsync = ref.watch(roundsStreamProvider);
    final roundName = roundsAsync.whenOrNull(
      data: (rounds) =>
          rounds.where((r) => r.id == holding.roundId).firstOrNull?.name,
    );
    final hasVesting = holding.vestingScheduleId != null;

    return HoldingItem(
      shareCount: holding.shareCount,
      vestedCount: holding.vestedCount ?? holding.shareCount,
      shareClassName: shareClassName ?? 'Unknown',
      costBasis: holding.costBasis,
      acquiredDate: holding.acquiredDate,
      roundName: roundName,
      hasVesting: hasVesting,
      onTap: () => HoldingDetailDialog.show(
        context: context,
        holding: holding,
        shareClassName: shareClassName,
        roundName: roundName,
        onDelete: () => _confirmDeleteHolding(context, holding),
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
      await ref.read(holdingMutationsProvider.notifier).delete(holding.id);
    }
  }

  Widget _buildOptionsSection(
    BuildContext context,
    String stakeholderId,
    AsyncValue<List<OptionGrant>> optionsAsync,
    AsyncValue<List<ShareClassesData>> shareClassesAsync,
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
              (o) => _buildOptionRow(context, o, shareClassesAsync),
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
  ) {
    final shareClassName = shareClassesAsync.whenOrNull(
      data: (classes) =>
          classes.where((c) => c.id == option.shareClassId).firstOrNull?.name,
    );

    return OptionItem(
      quantity: option.quantity,
      exercisedCount: option.exercisedCount,
      cancelledCount: option.cancelledCount,
      strikePrice: option.strikePrice,
      shareClassName: shareClassName ?? 'Unknown',
      status: option.status,
      onTap: () => OptionDetailDialog.show(
        context: context,
        option: option,
        shareClassName: shareClassName,
        onEdit: () => _showOptionEditDialog(context, option),
        onExercise: () => _showOptionExerciseDialog(context, option),
        onDelete: () => _confirmDeleteOption(context, option),
      ),
    );
  }

  Future<void> _confirmDeleteOption(
    BuildContext context,
    OptionGrant option,
  ) async {
    final confirmed = await ConfirmDialog.showDelete(
      context: context,
      itemName: 'option grant',
    );

    if (confirmed && mounted) {
      await ref.read(optionGrantMutationsProvider.notifier).delete(option.id);
    }
  }

  void _showOptionEditDialog(BuildContext context, OptionGrant option) {
    // TODO: Implement option edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Option editing coming soon')),
    );
  }

  void _showOptionExerciseDialog(BuildContext context, OptionGrant option) {
    // TODO: Implement option exercise dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Option exercise coming soon')),
    );
  }

  Widget _buildConvertiblesSection(
    BuildContext context,
    String stakeholderId,
    AsyncValue<List<Convertible>> convertiblesAsync,
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
            ...convertibles.map((c) => _buildConvertibleRow(context, c)),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildConvertibleRow(BuildContext context, Convertible convertible) {
    final isConverted = convertible.status == 'converted';

    return ConvertibleItem(
      type: convertible.type,
      principal: convertible.principal,
      valuationCap: convertible.valuationCap,
      discountPercent: convertible.discountPercent,
      interestRate: convertible.interestRate,
      status: convertible.status,
      onTap: () => ConvertibleDetailDialog.show(
        context: context,
        convertible: convertible,
        onEdit: isConverted ? null : () => _showConvertibleEditDialog(context, convertible),
        onConvert: isConverted ? null : () => _showConvertibleConvertDialog(context, convertible),
        onRevert: isConverted ? () => _revertConvertible(context, convertible) : null,
        onDelete: () => _confirmDeleteConvertible(context, convertible),
      ),
    );
  }

  Future<void> _confirmDeleteConvertible(
    BuildContext context,
    Convertible convertible,
  ) async {
    final confirmed = await ConfirmDialog.showDelete(
      context: context,
      itemName: 'convertible',
    );

    if (confirmed && mounted) {
      await ref.read(convertibleMutationsProvider.notifier).delete(convertible.id);
    }
  }

  void _showConvertibleEditDialog(BuildContext context, Convertible convertible) {
    // TODO: Implement convertible edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Convertible editing coming soon')),
    );
  }

  void _showConvertibleConvertDialog(BuildContext context, Convertible convertible) {
    // TODO: Implement convertible conversion dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Convertible conversion coming soon')),
    );
  }

  Future<void> _revertConvertible(BuildContext context, Convertible convertible) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Revert Conversion?',
      message: 'This will change the convertible status back to outstanding.',
      confirmLabel: 'Revert',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      await ref.read(convertibleMutationsProvider.notifier).updateConvertible(
        id: convertible.id,
        status: 'outstanding',
      );
    }
  }

  Widget _buildWarrantsSection(
    BuildContext context,
    String stakeholderId,
    AsyncValue<List<Warrant>> warrantsAsync,
    AsyncValue<List<ShareClassesData>> shareClassesAsync,
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
              (w) => _buildWarrantRow(context, w, shareClassesAsync),
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
  ) {
    final shareClassName = shareClassesAsync.whenOrNull(
      data: (classes) =>
          classes.where((c) => c.id == warrant.shareClassId).firstOrNull?.name,
    );
    final isActive = warrant.status == 'active';
    final remaining = warrant.quantity - warrant.exercisedCount - warrant.cancelledCount;

    return WarrantItem(
      quantity: warrant.quantity,
      exercisedCount: warrant.exercisedCount,
      cancelledCount: warrant.cancelledCount,
      strikePrice: warrant.strikePrice,
      shareClassName: shareClassName,
      status: warrant.status,
      expiryDate: warrant.expiryDate,
      onTap: () => WarrantDetailDialog.show(
        context: context,
        warrant: warrant,
        shareClassName: shareClassName,
        onEdit: () => _showWarrantEditDialog(context, warrant),
        onExercise: (isActive && remaining > 0) ? () => _showWarrantExerciseDialog(context, warrant) : null,
        onDelete: () => _confirmDeleteWarrant(context, warrant),
      ),
    );
  }

  Future<void> _confirmDeleteWarrant(
    BuildContext context,
    Warrant warrant,
  ) async {
    final confirmed = await ConfirmDialog.showDelete(
      context: context,
      itemName: 'warrant',
    );

    if (confirmed && mounted) {
      await ref.read(warrantMutationsProvider.notifier).delete(warrant.id);
    }
  }

  void _showWarrantEditDialog(BuildContext context, Warrant warrant) {
    // TODO: Implement warrant edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Warrant editing coming soon')),
    );
  }

  void _showWarrantExerciseDialog(BuildContext context, Warrant warrant) {
    // TODO: Implement warrant exercise dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Warrant exercise coming soon')),
    );
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
                    DropdownMenuItem(value: 'employee', child: Text('Employee')),
                    DropdownMenuItem(value: 'investor', child: Text('Investor')),
                    DropdownMenuItem(value: 'angel', child: Text('Angel Investor')),
                    DropdownMenuItem(value: 'vcFund', child: Text('VC Fund')),
                    DropdownMenuItem(value: 'institution', child: Text('Institution')),
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

                final mutations = ref.read(
                  stakeholderMutationsProvider.notifier,
                );

                if (isEditing) {
                  await mutations.updateStakeholder(
                    id: stakeholder.id,
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
                  await mutations.create(
                    companyId: companyId!,
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
          .read(stakeholderMutationsProvider.notifier)
          .delete(stakeholder.id);
    }
  }
}
