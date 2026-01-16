import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/providers.dart';
import '../../infrastructure/database/database.dart';
import '../../shared/formatters.dart';
import '../components/components.dart';

/// Page showing the equity value each stakeholder holds.
class ValuePage extends ConsumerStatefulWidget {
  const ValuePage({super.key});

  @override
  ConsumerState<ValuePage> createState() => _ValuePageState();
}

class _ValuePageState extends ConsumerState<ValuePage> {
  bool _vestedOnly = false;
  bool _excludeDraft = false;

  @override
  Widget build(BuildContext context) {
    final companyId = ref.watch(currentCompanyIdProvider);

    if (companyId == null) {
      return const EmptyState(
        icon: Icons.business,
        title: 'No company selected',
        message: 'Please create or select a company first.',
      );
    }

    final holdingsAsync = ref.watch(holdingsStreamProvider);
    final stakeholdersAsync = ref.watch(stakeholdersStreamProvider);
    final effectiveValuationAsync = ref.watch(effectiveValuationProvider);
    final ownershipAsync = ref.watch(ownershipSummaryProvider);
    final optionsAsync = ref.watch(optionGrantsStreamProvider);
    final roundsAsync = ref.watch(roundsStreamProvider);
    final shareClassesAsync = ref.watch(shareClassesStreamProvider);

    return Scaffold(
      body: holdingsAsync.when(
        data: (holdings) => stakeholdersAsync.when(
          data: (stakeholders) => effectiveValuationAsync.when(
            data: (effectiveValuation) => ownershipAsync.when(
              data: (ownership) => optionsAsync.when(
                data: (options) => roundsAsync.when(
                  data: (rounds) => shareClassesAsync.when(
                    data: (shareClasses) => _buildContent(
                      context,
                      holdings,
                      stakeholders,
                      options,
                      rounds,
                      shareClasses,
                      effectiveValuation,
                      ownership,
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => EmptyState.error(message: e.toString()),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => EmptyState.error(message: e.toString()),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => EmptyState.error(message: e.toString()),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState.error(message: e.toString()),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => EmptyState.error(message: e.toString()),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => EmptyState.error(message: e.toString()),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState.error(message: e.toString()),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<Holding> holdings,
    List<Stakeholder> stakeholders,
    List<OptionGrant> options,
    List<Round> rounds,
    List<ShareClassesData> shareClasses,
    EffectiveValuation? effectiveValuation,
    OwnershipSummary ownership,
  ) {
    if (effectiveValuation == null) {
      return const EmptyState(
        icon: Icons.analytics,
        title: 'No Valuation Set',
        message:
            'Add a company valuation or funding round to see equity values.',
      );
    }

    // Calculate price per share from valuation
    final totalShares = ownership.totalIssuedShares;
    if (totalShares == 0) {
      return const EmptyState(
        icon: Icons.pie_chart,
        title: 'No Shares Issued',
        message: 'Issue shares to stakeholders to see their equity values.',
      );
    }

    final pricePerShare = effectiveValuation.value / totalShares;

    // Build lookup maps
    final stakeholderMap = {for (final s in stakeholders) s.id: s};
    final draftRoundIds = {
      for (final r in rounds)
        if (r.status == 'draft') r.id,
    };
    final shareClassNames = {for (final sc in shareClasses) sc.id: sc.name};
    final roundNames = {for (final r in rounds) r.id: r.name};

    // Build stakeholder value data
    final stakeholderValues = _calculateStakeholderValues(
      holdings,
      options,
      stakeholderMap,
      draftRoundIds,
      shareClassNames,
      roundNames,
      pricePerShare,
    );

    // Sort by value descending
    stakeholderValues.sort((a, b) => b.totalValue.compareTo(a.totalValue));

    final totalValue = stakeholderValues.fold<double>(
      0,
      (sum, sv) => sum + (_vestedOnly ? sv.vestedValue : sv.totalValue),
    );

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildHeader(
            context,
            effectiveValuation,
            pricePerShare,
            totalValue,
            totalShares,
          ),
        ),
        if (stakeholderValues.isEmpty)
          const SliverFillRemaining(
            child: EmptyState(
              icon: Icons.people,
              title: 'No Stakeholders',
              message: 'Add stakeholders with equity holdings.',
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == stakeholderValues.length) {
                  return const SizedBox(height: 80);
                }
                return _buildStakeholderCard(context, stakeholderValues[index]);
              },
              childCount: stakeholderValues.length + 1,
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    EffectiveValuation effectiveValuation,
    double pricePerShare,
    double totalValue,
    int totalShares,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Equity Value',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Based on ${Formatters.compactCurrency(effectiveValuation.value)} valuation (${effectiveValuation.sourceDescription})',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final cards = [
                SummaryCard(
                  label: _vestedOnly ? 'Vested Value' : 'Total Value',
                  value: Formatters.compactCurrency(totalValue),
                  icon: Icons.account_balance_wallet,
                  color: Colors.green,
                ),
                SummaryCard(
                  label: 'Price/Share',
                  value: Formatters.currency(pricePerShare),
                  icon: Icons.paid,
                  color: Colors.blue,
                ),
                SummaryCard(
                  label: 'Total Shares',
                  value: Formatters.number(totalShares),
                  icon: Icons.pie_chart,
                  color: Colors.purple,
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Vested only',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: _vestedOnly,
                        onChanged: (v) => setState(() => _vestedOnly = v),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Exclude draft',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: _excludeDraft,
                        onChanged: (v) => setState(() => _excludeDraft = v),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStakeholderCard(BuildContext context, _StakeholderValue sv) {
    final displayValue = _vestedOnly ? sv.vestedValue : sv.totalValue;
    final displayShares = _vestedOnly ? sv.vestedShares : sv.totalShares;

    return ExpandableCard(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          sv.stakeholder.name.isNotEmpty
              ? sv.stakeholder.name[0].toUpperCase()
              : '?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: sv.stakeholder.name,
      titleBadge: StatusBadge(
        label: sv.stakeholder.type,
        color: _getTypeColor(sv.stakeholder.type),
      ),
      subtitle: Formatters.compactCurrency(displayValue),
      trailing: sv.hasDraftEquity
          ? StatusBadge(label: 'Draft', color: Colors.orange)
          : null,
      chips: [
        MetricChip(
          label: 'Shares',
          value: Formatters.number(displayShares),
          color: Colors.blue,
        ),
        MetricChip(
          label: 'Ownership',
          value: '${sv.ownershipPercent.toStringAsFixed(2)}%',
          color: Colors.purple,
        ),
      ],
      expandedContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Holdings section with colorful info boxes
          if (sv.holdings.isNotEmpty) ...[
            Text(
              'Holdings',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...sv.holdings.map((h) => HoldingItem(
              shareCount: h.holding.shareCount,
              vestedCount: h.holding.vestedCount ?? h.holding.shareCount,
              shareClassName: h.shareClassName,
              costBasis: h.holding.costBasis,
              acquiredDate: h.holding.acquiredDate,
              roundName: h.roundName,
              hasVesting: h.holding.vestingScheduleId != null,
              isDraft: h.isDraft,
            )),
            const Divider(height: 24),
          ],
          _buildDetailRow('Total Shares', Formatters.number(sv.totalShares)),
          if (sv.vestedShares != sv.totalShares) ...[
            _buildDetailRow(
              'Vested Shares',
              Formatters.number(sv.vestedShares),
            ),
            _buildDetailRow(
              'Unvested Shares',
              Formatters.number(sv.totalShares - sv.vestedShares),
            ),
          ],
          if (sv.hasDraftEquity) ...[
            _buildDetailRow(
              'Draft Shares',
              Formatters.number(sv.draftShares),
            ),
          ],
          const Divider(),
          _buildDetailRow('Total Value', Formatters.currency(sv.totalValue)),
          if (sv.vestedValue != sv.totalValue) ...[
            _buildDetailRow(
              'Vested Value',
              Formatters.currency(sv.vestedValue),
            ),
            _buildDetailRow(
              'Unvested Value',
              Formatters.currency(sv.totalValue - sv.vestedValue),
            ),
          ],
          if (sv.hasDraftEquity) ...[
            _buildDetailRow(
              'Draft Value',
              Formatters.currency(sv.draftValue),
            ),
          ],
          if (sv.optionShares > 0) ...[
            const Divider(),
            _buildDetailRow(
              'Unexercised Options',
              Formatters.number(sv.optionShares),
            ),
            _buildDetailRow(
              'Option Value (if exercised)',
              Formatters.currency(sv.optionValue),
            ),
          ],
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
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'founder':
        return Colors.purple;
      case 'employee':
        return Colors.blue;
      case 'investor':
        return Colors.green;
      case 'advisor':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  List<_StakeholderValue> _calculateStakeholderValues(
    List<Holding> holdings,
    List<OptionGrant> options,
    Map<String, Stakeholder> stakeholderMap,
    Set<String> draftRoundIds,
    Map<String, String> shareClassNames,
    Map<String, String> roundNames,
    double pricePerShare,
  ) {
    final valueMap = <String, _StakeholderValue>{};

    // Process holdings (actual shares)
    for (final holding in holdings) {
      final stakeholder = stakeholderMap[holding.stakeholderId];
      if (stakeholder == null) continue;

      final isDraft =
          holding.roundId != null && draftRoundIds.contains(holding.roundId);

      // Skip draft holdings if excluding drafts
      if (_excludeDraft && isDraft) continue;

      valueMap.putIfAbsent(
        stakeholder.id,
        () => _StakeholderValue(stakeholder: stakeholder),
      );

      final sv = valueMap[stakeholder.id]!;
      sv.totalShares += holding.shareCount;
      // For holdings, assume all are vested (non-option shares)
      sv.vestedShares += holding.shareCount;

      // Track draft shares separately
      if (isDraft) {
        sv.draftShares += holding.shareCount;
      }

      // Store holding info for display
      sv.holdings.add(_HoldingInfo(
        holding: holding,
        shareClassName: shareClassNames[holding.shareClassId] ?? 'Unknown',
        roundName: holding.roundId != null ? roundNames[holding.roundId] : null,
        isDraft: isDraft,
      ));
    }

    // Process options (add option value potential)
    for (final option in options) {
      if (option.status != 'active' && option.status != 'pending') continue;

      final stakeholder = stakeholderMap[option.stakeholderId];
      if (stakeholder == null) continue;

      valueMap.putIfAbsent(
        stakeholder.id,
        () => _StakeholderValue(stakeholder: stakeholder),
      );

      final sv = valueMap[stakeholder.id]!;
      final outstanding =
          option.quantity - option.exercisedCount - option.cancelledCount;

      sv.optionShares += outstanding;
      // Option value = (share price - strike price) * shares
      final spreadValue = (pricePerShare - option.strikePrice) * outstanding;
      if (spreadValue > 0) {
        sv.optionValue += spreadValue;
      }
    }

    // Calculate values
    int totalAllShares = 0;
    for (final sv in valueMap.values) {
      totalAllShares += sv.totalShares;
    }

    for (final sv in valueMap.values) {
      sv.totalValue = sv.totalShares * pricePerShare;
      sv.vestedValue = sv.vestedShares * pricePerShare;
      sv.draftValue = sv.draftShares * pricePerShare;
      sv.ownershipPercent =
          totalAllShares > 0 ? (sv.totalShares / totalAllShares) * 100 : 0;
    }

    return valueMap.values.toList();
  }
}

/// Internal class to hold stakeholder value calculation data.
class _StakeholderValue {
  final Stakeholder stakeholder;
  int totalShares = 0;
  int vestedShares = 0;
  int optionShares = 0;
  int draftShares = 0;
  double totalValue = 0;
  double vestedValue = 0;
  double optionValue = 0;
  double draftValue = 0;
  double ownershipPercent = 0;

  /// Holdings contributing to this stakeholder's value.
  final List<_HoldingInfo> holdings = [];

  /// Whether this stakeholder has any draft equity.
  bool get hasDraftEquity => draftShares > 0;

  _StakeholderValue({required this.stakeholder});
}

/// Holding info for display in expanded card.
class _HoldingInfo {
  final Holding holding;
  final String shareClassName;
  final String? roundName;
  final bool isDraft;

  _HoldingInfo({
    required this.holding,
    required this.shareClassName,
    this.roundName,
    this.isDraft = false,
  });
}
