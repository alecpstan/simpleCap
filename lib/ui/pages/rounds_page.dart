import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/providers.dart';
import '../../infrastructure/database/database.dart';
import '../../shared/formatters.dart';
import '../components/components.dart';
import 'round_builder_page.dart';

/// Page displaying all funding rounds.
class RoundsPage extends ConsumerStatefulWidget {
  const RoundsPage({super.key});

  @override
  ConsumerState<RoundsPage> createState() => _RoundsPageState();
}

class _RoundsPageState extends ConsumerState<RoundsPage> {
  @override
  Widget build(BuildContext context) {
    final roundsAsync = ref.watch(roundsStreamProvider);
    final roundsSummaryAsync = ref.watch(roundsSummaryProvider);
    final companyId = ref.watch(currentCompanyIdProvider);

    if (companyId == null) {
      return const EmptyState(
        icon: Icons.business,
        title: 'No company selected',
        message: 'Please create or select a company first.',
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, roundsSummaryAsync)),
          roundsAsync.when(
            data: (rounds) {
              if (rounds.isEmpty) {
                return SliverFillRemaining(
                  child: EmptyState.noItems(
                    itemType: 'round',
                    onAdd: () => RoundBuilderPage.show(context),
                  ),
                );
              }
              final hasDraft = rounds.any((r) => r.status == 'draft');

              // Calculate which round can be reopened
              final closedRounds = rounds
                  .where((r) => r.status == 'closed')
                  .toList();
              closedRounds.sort((a, b) => b.date.compareTo(a.date));
              final mostRecentClosed = closedRounds.isNotEmpty
                  ? closedRounds.first
                  : null;
              final hasDraftMoreRecent =
                  mostRecentClosed != null &&
                  rounds.any(
                    (r) =>
                        r.status == 'draft' &&
                        r.date.isAfter(mostRecentClosed.date),
                  );
              final reopenableId =
                  (mostRecentClosed != null && !hasDraftMoreRecent)
                  ? mostRecentClosed.id
                  : null;

              return SliverList(
                delegate: SliverChildListDelegate([
                  if (hasDraft) _buildDraftNotice(context),
                  ...rounds.map(
                    (round) => _buildRoundCard(
                      context,
                      round,
                      canReopen: round.id == reopenableId,
                      key: ValueKey(round.id),
                    ),
                  ),
                  const SizedBox(height: 80),
                ]),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: EmptyState.error(
                message: e.toString(),
                onRetry: () => ref.invalidate(roundsStreamProvider),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: roundsAsync.whenOrNull(
        data: (rounds) {
          final hasDraft = rounds.any((r) => r.status == 'draft');
          if (hasDraft) return null;
          return FloatingActionButton.extended(
            onPressed: () => RoundBuilderPage.show(context),
            icon: const Icon(Icons.add),
            label: const Text('Build Round'),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AsyncValue<RoundsSummary> summaryAsync,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Funding Rounds',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          summaryAsync.when(
            data: (summary) {
              final cards = [
                SummaryCard(
                  label: 'Total Raised',
                  value: Formatters.compactCurrency(summary.totalRaised),
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
                SummaryCard(
                  label: 'Rounds',
                  value: summary.totalRounds.toString(),
                  icon: Icons.trending_up,
                  color: Colors.blue,
                ),
                if (summary.closedRounds > 0)
                  SummaryCard(
                    label: 'Closed',
                    value: summary.closedRounds.toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
              ];
              return LayoutBuilder(
                builder: (context, constraints) {
                  final cardsPerRow = cards.length == 1 ? 1 : 2;
                  final spacing = 12.0;
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
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (error, stackTrace) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundCard(
    BuildContext context,
    Round round, {
    required bool canReopen,
    Key? key,
  }) {
    final theme = Theme.of(context);

    return ExpandableCard(
      key: key,
      leading: CircleAvatar(
        backgroundColor: _getStatusColor(round.status).withValues(alpha: 0.2),
        child: Icon(
          _getRoundIcon(round.type),
          color: _getStatusColor(round.status),
        ),
      ),
      title: round.name,
      subtitle: _formatRoundType(round.type),
      trailing: Text(
        Formatters.date(round.date),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.outline,
        ),
      ),
      cornerBadge: StatusBadge(
        label: _formatStatus(round.status),
        color: _getStatusColor(round.status),
      ),
      chips: [
        if (round.amountRaised > 0)
          MetricChip(
            label: 'Raised',
            value: Formatters.compactCurrency(round.amountRaised),
            color: Colors.green,
          ),
        if (round.preMoneyValuation != null)
          MetricChip(
            label: 'Pre-money',
            value: Formatters.compactCurrency(round.preMoneyValuation!),
            color: Colors.blue,
          ),
      ],
      expandedContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailRow(label: 'Type', value: _formatRoundType(round.type)),
          DetailRow(label: 'Date', value: Formatters.date(round.date)),
          if (round.amountRaised > 0)
            DetailRow(
              label: 'Raised',
              value: Formatters.currency(round.amountRaised),
              highlight: true,
            ),
          if (round.preMoneyValuation != null)
            DetailRow(
              label: 'Pre-money',
              value: Formatters.currency(round.preMoneyValuation!),
            ),
          if (round.preMoneyValuation != null && round.amountRaised > 0)
            DetailRow(
              label: 'Post-money',
              value: Formatters.currency(
                round.preMoneyValuation! + round.amountRaised,
              ),
              valueColor: Colors.green,
            ),
          if (round.pricePerShare != null)
            DetailRow(
              label: 'Price/Share',
              value: Formatters.currency(round.pricePerShare!),
            ),
          // Holdings in this round
          _buildRoundHoldingsSection(
            context,
            round.id,
            isDraft: round.status == 'draft',
          ),
          // Warrants issued in this round
          _buildRoundWarrantsSection(context, round.id),
          // Convertibles converted in this round
          _buildRoundConvertiblesSection(context, round.id),
          if (round.notes != null && round.notes!.isNotEmpty) ...[
            const Divider(height: 24),
            Text(
              'Notes',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(round.notes!),
          ],
        ],
      ),
      actions: [
        if (round.status == 'draft')
          TextButton.icon(
            onPressed: () => _closeRound(context, round),
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Close'),
          ),
        if (canReopen)
          TextButton.icon(
            onPressed: () => _reopenRound(context, round),
            icon: const Icon(Icons.undo, size: 18),
            label: const Text('Reopen'),
          ),
        TextButton.icon(
          onPressed: () => _showEditDialog(context, round),
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('Edit'),
        ),
        TextButton.icon(
          onPressed: () => _confirmDelete(context, round),
          icon: const Icon(Icons.delete, size: 18),
          label: const Text('Delete'),
          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
        ),
      ],
    );
  }

  IconData _getRoundIcon(String type) {
    switch (type) {
      case 'founding':
        return Icons.flag;
      case 'seed':
        return Icons.eco;
      case 'seriesA':
      case 'seriesB':
      case 'seriesC':
        return Icons.trending_up;
      case 'bridge':
        return Icons.swap_horiz;
      case 'secondary':
        return Icons.swap_horizontal_circle;
      default:
        return Icons.monetization_on;
    }
  }

  String _formatRoundType(String type) {
    switch (type) {
      case 'founding':
        return 'Founding Round';
      case 'seed':
        return 'Seed Round';
      case 'seriesA':
        return 'Series A';
      case 'seriesB':
        return 'Series B';
      case 'seriesC':
        return 'Series C';
      case 'bridge':
        return 'Bridge Round';
      case 'secondary':
        return 'Secondary';
      default:
        return type;
    }
  }

  String _formatStatus(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.orange;
      case 'closed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDraftNotice(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Close the current draft round before creating a new one.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.orange.shade900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundHoldingsSection(
    BuildContext context,
    String roundId, {
    bool isDraft = false,
  }) {
    final holdingsAsync = ref.watch(holdingsStreamProvider);
    final stakeholdersAsync = ref.watch(stakeholdersStreamProvider);
    final shareClassesAsync = ref.watch(shareClassesStreamProvider);

    return holdingsAsync.when(
      data: (allHoldings) {
        final holdings = allHoldings
            .where((h) => h.roundId == roundId)
            .toList();
        if (holdings.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 24),
            Text(
              'Investments',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...holdings.map((h) {
              final stakeholderName = stakeholdersAsync.whenOrNull(
                data: (s) =>
                    s.where((x) => x.id == h.stakeholderId).firstOrNull?.name,
              );
              final shareClassName = shareClassesAsync.whenOrNull(
                data: (c) =>
                    c.where((x) => x.id == h.shareClassId).firstOrNull?.name,
              );

              return HoldingItem(
                shareCount: h.shareCount,
                vestedCount: h.vestedCount ?? h.shareCount,
                shareClassName: shareClassName ?? 'Unknown',
                costBasis: h.costBasis,
                acquiredDate: h.acquiredDate,
                roundName:
                    stakeholderName, // Show investor name in round context
                hasVesting: h.vestingScheduleId != null,
                isDraft: isDraft,
                onTap: () => HoldingDetailDialog.show(
                  context: context,
                  holding: h,
                  shareClassName: shareClassName,
                  onDelete: () async {
                    final confirmed = await ConfirmDialog.showDelete(
                      context: context,
                      itemName: 'holding',
                    );
                    if (confirmed && mounted) {
                      await ref
                          .read(holdingMutationsProvider.notifier)
                          .delete(h.id);
                    }
                  },
                ),
              );
            }),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildRoundWarrantsSection(BuildContext context, String roundId) {
    final warrantsAsync = ref.watch(warrantsStreamProvider);
    final stakeholdersAsync = ref.watch(stakeholdersStreamProvider);

    return warrantsAsync.when(
      data: (allWarrants) {
        // Show warrants that were issued in this round
        final roundWarrants = allWarrants
            .where((w) => w.roundId == roundId)
            .toList();
        if (roundWarrants.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 24),
            Text(
              'Warrants Issued',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...roundWarrants.map((w) {
              final stakeholderName = stakeholdersAsync.whenOrNull(
                data: (s) =>
                    s.where((x) => x.id == w.stakeholderId).firstOrNull?.name,
              );

              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.receipt,
                    color: Colors.indigo,
                    size: 20,
                  ),
                ),
                title: Text(
                  '${Formatters.number(w.quantity)} warrants',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  '${stakeholderName ?? "Unknown"} • Strike: ${Formatters.currency(w.strikePrice)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: StatusBadge(
                  label: w.status[0].toUpperCase() + w.status.substring(1),
                  color: w.status == 'active' ? Colors.green : Colors.orange,
                ),
              );
            }),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildRoundConvertiblesSection(BuildContext context, String roundId) {
    final convertiblesAsync = ref.watch(convertiblesStreamProvider);
    final stakeholdersAsync = ref.watch(stakeholdersStreamProvider);

    return convertiblesAsync.when(
      data: (allConvertibles) {
        // Show convertibles that were converted in this round
        final convertibles = allConvertibles
            .where(
              (c) => c.conversionEventId == roundId && c.status == 'converted',
            )
            .toList();
        if (convertibles.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 24),
            Text(
              'Converted Instruments',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...convertibles.map((c) {
              final stakeholderName = stakeholdersAsync.whenOrNull(
                data: (s) =>
                    s.where((x) => x.id == c.stakeholderId).firstOrNull?.name,
              );

              return ConvertibleItem(
                type: c.type,
                principal: c.principal,
                valuationCap: c.valuationCap,
                discountPercent: c.discountPercent,
                interestRate: c.interestRate,
                status: c.status,
                onTap: () => ConvertibleDetailDialog.show(
                  context: context,
                  convertible: c,
                  stakeholderName: stakeholderName,
                ),
              );
            }),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Future<void> _closeRound(BuildContext context, Round round) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Close Round?',
      message:
          'Closing the round will finalize all share issuances. '
          'You can reopen it later if needed.',
      confirmLabel: 'Close Round',
    );

    if (!confirmed) return;

    try {
      await ref.read(roundMutationsProvider.notifier).closeRound(round.id);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Round closed')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _reopenRound(BuildContext context, Round round) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Reopen Round?',
      message:
          'This will revert any converted SAFEs/Notes back to outstanding.\n\n'
          'Investments will be preserved.',
      confirmLabel: 'Reopen Round',
      isDestructive: false,
    );

    if (!confirmed) return;

    try {
      await ref.read(roundMutationsProvider.notifier).reopenRound(round.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Round reopened - securities reversed')),
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

  void _showEditDialog(BuildContext context, Round round) {
    RoundBuilderPage.show(context, existingRound: round);
  }

  Future<void> _confirmDelete(BuildContext context, Round round) async {
    final confirmed = await ConfirmDialog.showDelete(
      context: context,
      itemName: round.name,
      additionalMessage: round.status == 'closed'
          ? 'Warning: This round has been closed and may have associated shares.'
          : null,
    );

    if (confirmed && mounted) {
      try {
        await ref.read(roundMutationsProvider.notifier).delete(round.id);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${round.name} deleted')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting round: $e')));
        }
      }
    }
  }
}
