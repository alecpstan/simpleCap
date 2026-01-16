import 'package:drift/drift.dart' show Value;
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
import 'transfers_page.dart';
import 'valuations_page.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'TOOLS',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        QuickAccessGrid(
          cards: [
            QuickAccessCard(
              icon: Icons.assessment,
              label: 'Valuations',
              subtitle: 'Track value',
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ValuationsPage()),
              ),
            ),
            QuickAccessCard(
              icon: Icons.calculate,
              label: 'Scenarios',
              subtitle: 'Model exits',
              color: Colors.purple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScenariosPage()),
              ),
            ),
            optionsSummaryAsync.when(
              data: (summary) => QuickAccessCard(
                icon: Icons.card_giftcard,
                label: 'Options',
                subtitle: summary.totalGrants > 0
                    ? '${summary.activeGrants} active'
                    : 'Equity plans',
                color: Colors.orange,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OptionsPage()),
                ),
              ),
              loading: () => QuickAccessCard(
                icon: Icons.card_giftcard,
                label: 'Options',
                subtitle: 'Equity plans',
                color: Colors.orange,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OptionsPage()),
                ),
              ),
              error: (_, __) => QuickAccessCard(
                icon: Icons.card_giftcard,
                label: 'Options',
                subtitle: 'Equity plans',
                color: Colors.orange,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OptionsPage()),
                ),
              ),
            ),
            QuickAccessCard(
              icon: Icons.account_balance_wallet,
              label: 'ESOP Pools',
              subtitle: 'Manage pools',
              color: Colors.deepOrange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EsopPoolsPage()),
              ),
            ),
            convertiblesSummaryAsync.when(
              data: (summary) => QuickAccessCard(
                icon: Icons.receipt_long,
                label: 'Convertibles',
                subtitle: summary.totalCount > 0
                    ? '${summary.outstandingCount} outstanding'
                    : 'SAFEs & notes',
                color: Colors.teal,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ConvertiblesPage()),
                ),
              ),
              loading: () => QuickAccessCard(
                icon: Icons.receipt_long,
                label: 'Convertibles',
                subtitle: 'SAFEs & notes',
                color: Colors.teal,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ConvertiblesPage()),
                ),
              ),
              error: (_, __) => QuickAccessCard(
                icon: Icons.receipt_long,
                label: 'Convertibles',
                subtitle: 'SAFEs & notes',
                color: Colors.teal,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ConvertiblesPage()),
                ),
              ),
            ),
            QuickAccessCard(
              icon: Icons.receipt,
              label: 'Warrants',
              subtitle: 'View warrants',
              color: Colors.indigo,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WarrantsPage()),
              ),
            ),
            QuickAccessCard(
              icon: Icons.swap_horiz,
              label: 'Transfers',
              subtitle: 'Share transfers',
              color: Colors.cyan,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TransfersPage()),
              ),
            ),
          ],
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
    return shareClassesAsync.when(
      data: (shareClasses) => holdingsAsync.when(
        data: (holdings) {
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

          slices.sort((a, b) => b.shares.compareTo(a.shares));

          return OwnershipPieChart(slices: slices, size: 220);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Error: $e'),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
    );
  }

  Widget _buildOptionsSummary(BuildContext context) {
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
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              final db = ref.read(databaseProvider);
              final id = DateTime.now().millisecondsSinceEpoch.toString();
              final now = DateTime.now();

              await db.upsertCompany(
                CompaniesCompanion.insert(
                  id: id,
                  name: name,
                  createdAt: now,
                  updatedAt: now,
                ),
              );

              // Create default share classes
              await db.upsertShareClass(
                ShareClassesCompanion.insert(
                  id: '${id}_common',
                  companyId: id,
                  name: 'Common',
                  type: 'common',
                  createdAt: now,
                  updatedAt: now,
                ),
              );
              await db.upsertShareClass(
                ShareClassesCompanion.insert(
                  id: '${id}_preferred_a',
                  companyId: id,
                  name: 'Series A Preferred',
                  type: 'preferred',
                  seniority: const Value(1),
                  liquidationPreference: const Value(1.0),
                  createdAt: now,
                  updatedAt: now,
                ),
              );

              ref.read(currentCompanyIdProvider.notifier).setCompany(id);

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
