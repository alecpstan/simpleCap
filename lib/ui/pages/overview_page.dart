import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/providers.dart';
import '../../infrastructure/database/database.dart';
import '../../shared/formatters.dart';
import '../components/components.dart';
import 'convertibles_page.dart';
import 'esop_pools_page.dart';
import 'options_page.dart';
import 'scenarios_page.dart';
import 'timeline_page.dart';
import 'transfers_page.dart';
import 'valuations_page.dart';
import 'vesting_management_page.dart';
import 'warrants_page.dart';

/// The main dashboard/overview page.
///
/// Shows key metrics, quick access tools, ownership chart, and summaries.
class OverviewPage extends ConsumerStatefulWidget {
  const OverviewPage({super.key});

  @override
  ConsumerState<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends ConsumerState<OverviewPage> {
  bool _showByShareClass = false;

  @override
  Widget build(BuildContext context) {
    final companyId = ref.watch(currentCompanyIdProvider);

    if (companyId == null) {
      return _buildNoCompanyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(stakeholdersStreamProvider);
        ref.invalidate(roundsStreamProvider);
        ref.invalidate(holdingsStreamProvider);
        ref.invalidate(optionsSummaryProvider);
        ref.invalidate(convertiblesSummaryProvider);
      },
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildWelcomeHeader(context),
                const SizedBox(height: 16),
                _buildKeyMetrics(context),
                const SizedBox(height: 24),
                _buildToolsSection(context),
                const SizedBox(height: 24),
                _buildOwnershipChart(context),
                const SizedBox(height: 24),
                _buildOptionsSummary(context),
                const SizedBox(height: 24),
                _buildConvertiblesSummary(context),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoCompanyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.business,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to Simple Cap',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Get started by creating your company',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _showCreateCompanyDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Company'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    final companyAsync = ref.watch(currentCompanyProvider);
    final effectiveValuationAsync = ref.watch(effectiveValuationProvider);

    return companyAsync.when(
      data: (company) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            company?.name ?? 'Your Company',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          effectiveValuationAsync.when(
            data: (effectiveValuation) {
              if (effectiveValuation == null) {
                return Text(
                  'Cap Table Overview',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                );
              }
              return Row(
                children: [
                  Text(
                    'Valuation: ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  Text(
                    Formatters.compactCurrency(effectiveValuation.value),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${effectiveValuation.sourceDescription})',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      loading: () => const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text('Error: $e'),
    );
  }

  Widget _buildKeyMetrics(BuildContext context) {
    final ownershipAsync = ref.watch(ownershipSummaryProvider);
    final roundsAsync = ref.watch(roundsSummaryProvider);

    return ownershipAsync.when(
      data: (ownership) => roundsAsync.when(
        data: (rounds) => StatsGrid(
          stats: [
            StatCard(
              title: 'Stakeholders',
              value: Formatters.number(ownership.stakeholderCount),
              icon: Icons.people,
              color: Colors.blue,
            ),
            StatCard(
              title: 'Total Shares',
              value: Formatters.compactNumber(ownership.totalIssuedShares),
              icon: Icons.pie_chart,
              color: Colors.green,
            ),
            StatCard(
              title: 'Rounds',
              value: rounds.totalRounds.toString(),
              icon: Icons.trending_up,
              color: Colors.orange,
              subtitle: '${rounds.closedRounds} closed',
            ),
            StatCard(
              title: 'Total Raised',
              value: Formatters.compactCurrency(rounds.totalRaised),
              icon: Icons.attach_money,
              color: Colors.purple,
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => InfoBox.error(message: e.toString()),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => InfoBox.error(message: e.toString()),
    );
  }

  Widget _buildToolsSection(BuildContext context) {
    final theme = Theme.of(context);
    final optionsSummaryAsync = ref.watch(optionsSummaryProvider);
    final convertiblesSummaryAsync = ref.watch(convertiblesSummaryProvider);
    final toolOrderAsync = ref.watch(toolOrderNotifierProvider);

    // Watch premium feature locks
    final valuationsLocked = ref.watch(
      isFeatureLockedProvider(PremiumFeature.valuations),
    );
    final scenariosLocked = ref.watch(
      isFeatureLockedProvider(PremiumFeature.scenarios),
    );
    final optionsLocked = ref.watch(
      isFeatureLockedProvider(PremiumFeature.options),
    );
    final esopPoolsLocked = ref.watch(
      isFeatureLockedProvider(PremiumFeature.esopPools),
    );
    final warrantsLocked = ref.watch(
      isFeatureLockedProvider(PremiumFeature.warrants),
    );
    final convertiblesLocked = ref.watch(
      isFeatureLockedProvider(PremiumFeature.convertibles),
    );

    // Build tool data with dynamic subtitles
    final optionsSummary = optionsSummaryAsync.valueOrNull;
    final convertiblesSummary = convertiblesSummaryAsync.valueOrNull;

    final tools = <ToolCardData>[
      ToolCardData(
        id: 'valuations',
        icon: Icons.assessment,
        label: 'Valuations',
        subtitle: 'Track value',
        color: Colors.blue,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ValuationsPage()),
        ),
      ),
      ToolCardData(
        id: 'scenarios',
        icon: Icons.calculate,
        label: 'Scenarios',
        subtitle: 'Model exits',
        color: Colors.purple,
        isLocked: scenariosLocked,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ScenariosPage()),
        ),
      ),
      ToolCardData(
        id: 'options',
        icon: Icons.card_giftcard,
        label: 'Options',
        subtitle: optionsSummary != null && optionsSummary.totalGrants > 0
            ? '${optionsSummary.activeGrants} active'
            : 'Equity plans',
        color: Colors.orange,
        isLocked: optionsLocked,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OptionsPage()),
        ),
      ),
      ToolCardData(
        id: 'esop_pools',
        icon: Icons.account_balance_wallet,
        label: 'ESOP Pools',
        subtitle: 'Manage pools',
        color: Colors.deepOrange,
        isLocked: esopPoolsLocked,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EsopPoolsPage()),
        ),
      ),
      ToolCardData(
        id: 'vesting',
        icon: Icons.schedule,
        label: 'Vesting',
        subtitle: 'Manage vesting',
        color: Colors.indigo,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VestingManagementPage()),
        ),
      ),
      ToolCardData(
        id: 'convertibles',
        icon: Icons.receipt_long,
        label: 'Convertibles',
        subtitle:
            convertiblesSummary != null && convertiblesSummary.totalCount > 0
            ? '${convertiblesSummary.outstandingCount} outstanding'
            : 'SAFEs & notes',
        color: Colors.teal,
        isLocked: convertiblesLocked,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ConvertiblesPage()),
        ),
      ),
      ToolCardData(
        id: 'warrants',
        icon: Icons.receipt,
        label: 'Warrants',
        subtitle: 'View warrants',
        color: Colors.indigo,
        isLocked: warrantsLocked,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WarrantsPage()),
        ),
      ),
      ToolCardData(
        id: 'transfers',
        icon: Icons.swap_horiz,
        label: 'Transfers',
        subtitle: 'Share transfers',
        color: Colors.cyan,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TransfersPage()),
        ),
      ),
      ToolCardData(
        id: 'timeline',
        icon: Icons.history,
        label: 'Timeline',
        subtitle: 'Event history',
        color: Colors.blueGrey,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TimelinePage()),
        ),
      ),
    ];

    final order = toolOrderAsync.valueOrNull ?? defaultToolOrder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Text(
                'TOOLS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Text(
                'Hold & drag to reorder',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        ReorderableQuickAccessGrid(
          tools: tools,
          order: order,
          onReorder: (oldIndex, newIndex) {
            ref
                .read(toolOrderNotifierProvider.notifier)
                .reorder(oldIndex, newIndex);
          },
        ),
      ],
    );
  }

  Widget _buildOwnershipChart(BuildContext context) {
    final ownershipAsync = ref.watch(ownershipSummaryProvider);
    final stakeholdersAsync = ref.watch(stakeholdersStreamProvider);
    final shareClassesAsync = ref.watch(shareClassesStreamProvider);
    final holdingsAsync = ref.watch(holdingsStreamProvider);

    return ownershipAsync.when(
      data: (ownership) {
        if (ownership.stakeholderCount == 0) {
          return const SizedBox.shrink();
        }

        return SectionCard(
          title: 'Ownership',
          trailing: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false,
                label: Text('Investor'),
                icon: Icon(Icons.person, size: 16),
              ),
              ButtonSegment(
                value: true,
                label: Text('Class'),
                icon: Icon(Icons.category, size: 16),
              ),
            ],
            selected: {_showByShareClass},
            onSelectionChanged: (value) {
              setState(() {
                _showByShareClass = value.first;
              });
            },
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          child: _showByShareClass
              ? _buildByShareClassChart(shareClassesAsync, holdingsAsync)
              : _buildByStakeholderChart(stakeholdersAsync, ownership),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildByStakeholderChart(
    AsyncValue<List<Stakeholder>> stakeholdersAsync,
    OwnershipSummary ownership,
  ) {
    return stakeholdersAsync.when(
      data: (stakeholders) {
        final slices = <OwnershipSlice>[];
        var colorIndex = 0;

        for (final entry in ownership.sharesByStakeholder.entries) {
          final stakeholder = stakeholders.firstWhere(
            (s) => s.id == entry.key,
            orElse: () => Stakeholder(
              id: entry.key,
              companyId: '',
              name: 'Unknown',
              type: 'unknown',
              hasProRataRights: false,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
          slices.add(
            OwnershipSlice(
              id: entry.key,
              name: stakeholder.name,
              shares: entry.value,
              color: ChartColors.getColor(colorIndex++),
            ),
          );
        }

        slices.sort((a, b) => b.shares.compareTo(a.shares));

        return OwnershipPieChart(slices: slices, size: 220);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
    );
  }

  Widget _buildByShareClassChart(
    AsyncValue<List<ShareClassesData>> shareClassesAsync,
    AsyncValue<List<Holding>> holdingsAsync,
  ) {
    final ownershipAsync = ref.watch(ownershipSummaryProvider);

    return shareClassesAsync.when(
      data: (shareClasses) => holdingsAsync.when(
        data: (holdings) => ownershipAsync.when(
          data: (ownership) {
            final byClass = <String, int>{};
            for (final h in holdings) {
              byClass.update(
                h.shareClassId,
                (v) => v + h.shareCount,
                ifAbsent: () => h.shareCount,
              );
            }

            final slices = <OwnershipSlice>[];
            var colorIndex = 0;

            for (final entry in byClass.entries) {
              final shareClass = shareClasses
                  .where((sc) => sc.id == entry.key)
                  .firstOrNull;
              slices.add(
                OwnershipSlice(
                  id: entry.key,
                  name: shareClass?.name ?? 'Unknown',
                  shares: entry.value,
                  color: ChartColors.getColor(colorIndex++),
                ),
              );
            }

            // Add ESOP reserved shares as a separate slice
            if (ownership.esopReservedShares > 0) {
              slices.add(
                OwnershipSlice(
                  id: 'esop',
                  name: 'ESOP',
                  shares: ownership.esopReservedShares,
                  color: Colors.deepOrange,
                ),
              );
            }

            slices.sort((a, b) => b.shares.compareTo(a.shares));

            return OwnershipPieChart(slices: slices, size: 220);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Error: $e'),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
    );
  }

  Widget _buildOptionsSummary(BuildContext context) {
    // Hide if options feature is locked
    final optionsLocked = ref.watch(
      isFeatureLockedProvider(PremiumFeature.options),
    );
    if (optionsLocked) return const SizedBox.shrink();

    final optionsSummaryAsync = ref.watch(optionsSummaryProvider);

    return optionsSummaryAsync.when(
      data: (summary) {
        if (summary.totalGrants == 0) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);

        return SectionCard(
          title: 'Stock Options',
          trailing: Text(
            '${summary.activeGrants} active',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ResultChip(
                label: 'Total Granted',
                value: Formatters.compactNumber(summary.totalGranted),
                color: Colors.blue,
              ),
              ResultChip(
                label: 'Vested',
                value: Formatters.compactNumber(summary.totalVested),
                color: Colors.indigo,
              ),
              ResultChip(
                label: 'Exercised',
                value: Formatters.compactNumber(summary.totalExercised),
                color: Colors.green,
              ),
              if (summary.totalUnvested > 0)
                ResultChip(
                  label: 'Unvested',
                  value: Formatters.compactNumber(summary.totalUnvested),
                  color: Colors.orange,
                ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildConvertiblesSummary(BuildContext context) {
    // Hide if convertibles feature is locked
    final convertiblesLocked = ref.watch(
      isFeatureLockedProvider(PremiumFeature.convertibles),
    );
    if (convertiblesLocked) return const SizedBox.shrink();

    final convertiblesSummaryAsync = ref.watch(convertiblesSummaryProvider);

    return convertiblesSummaryAsync.when(
      data: (summary) {
        if (summary.totalCount == 0) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);

        return SectionCard(
          title: 'Convertibles',
          trailing: Text(
            '${summary.outstandingCount} outstanding',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ResultChip(
                label: 'Outstanding',
                value: Formatters.compactCurrency(summary.outstandingPrincipal),
                color: Colors.teal,
              ),
              if (summary.convertedPrincipal > 0)
                ResultChip(
                  label: 'Converted',
                  value: Formatters.compactCurrency(summary.convertedPrincipal),
                  color: Colors.green,
                ),
              ResultChip(
                label: 'SAFEs',
                value: summary.safeCount.toString(),
                color: Colors.blue,
              ),
              if (summary.noteCount > 0)
                ResultChip(
                  label: 'Notes',
                  value: summary.noteCount.toString(),
                  color: Colors.purple,
                ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _showCreateCompanyDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create Company'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Company Name',
            hintText: 'e.g. Acme Pty Ltd',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              try {
                // Create company using the command pattern
                final companyId = await ref
                    .read(companyCommandsProvider.notifier)
                    .createCompany(name: name);

                // Initialize default share classes and vesting schedules
                await ref
                    .read(companyCommandsProvider.notifier)
                    .initializeCompanyDefaults(companyId: companyId);

                // Select the newly created company
                await ref
                    .read(currentCompanyIdProvider.notifier)
                    .setCompany(companyId);

                if (dialogContext.mounted) Navigator.pop(dialogContext);
              } catch (e) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text('Error creating company: $e')),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
