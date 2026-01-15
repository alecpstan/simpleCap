import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cap_table_provider.dart';
import '../models/vesting_schedule.dart';
import '../models/transaction.dart';
import '../models/investor.dart';
import '../models/milestone.dart';
import '../models/hours_vesting.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_card.dart';
import '../widgets/info_widgets.dart';
import '../widgets/help_icon.dart';
import '../utils/helpers.dart';

class VestingPage extends StatefulWidget {
  const VestingPage({super.key});

  @override
  State<VestingPage> createState() => _VestingPageState();
}

class _VestingPageState extends State<VestingPage> {
  // Track which sections are expanded
  bool _activeExpanded = true;
  bool _completedExpanded = false;
  bool _terminatedExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<CapTableProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Combine all vesting types into unified lists by status
        final allItems = _buildVestingItems(provider);
        final activeItems = allItems
            .where((i) => i.status == _VestingStatus.active)
            .toList();
        final completedItems = allItems
            .where((i) => i.status == _VestingStatus.completed)
            .toList();
        final terminatedItems = allItems
            .where((i) => i.status == _VestingStatus.terminated)
            .toList();

        final hasAny = allItems.isNotEmpty;

        return Scaffold(
          body: hasAny
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Card
                      _UnifiedSummaryCard(
                        activeCount: activeItems.length,
                        completedCount: completedItems.length,
                        terminatedCount: terminatedItems.length,
                        provider: provider,
                      ),
                      const SizedBox(height: 16),

                      // Active/Vesting Section
                      if (activeItems.isNotEmpty)
                        _buildCollapsibleSection(
                          context,
                          title: 'Active',
                          count: activeItems.length,
                          color: Colors.blue,
                          icon: Icons.trending_up,
                          isExpanded: _activeExpanded,
                          onToggle: () => setState(
                            () => _activeExpanded = !_activeExpanded,
                          ),
                          children: activeItems,
                          provider: provider,
                        ),

                      // Completed Section
                      if (completedItems.isNotEmpty)
                        _buildCollapsibleSection(
                          context,
                          title: 'Completed',
                          count: completedItems.length,
                          color: Colors.green,
                          icon: Icons.check_circle,
                          isExpanded: _completedExpanded,
                          onToggle: () => setState(
                            () => _completedExpanded = !_completedExpanded,
                          ),
                          children: completedItems,
                          provider: provider,
                        ),

                      // Terminated Section
                      if (terminatedItems.isNotEmpty)
                        _buildCollapsibleSection(
                          context,
                          title: 'Terminated',
                          count: terminatedItems.length,
                          color: Colors.grey,
                          icon: Icons.person_off,
                          isExpanded: _terminatedExpanded,
                          onToggle: () => setState(
                            () => _terminatedExpanded = !_terminatedExpanded,
                          ),
                          children: terminatedItems,
                          provider: provider,
                        ),

                      const SizedBox(height: 80), // FAB space
                    ],
                  ),
                )
              : const EmptyState(
                  icon: Icons.schedule_outlined,
                  title: 'No vesting schedules',
                  subtitle: 'Add time-based, milestone, or hours vesting',
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddMenu(context, provider),
            icon: const Icon(Icons.add),
            label: const Text('Add Vesting'),
          ),
        );
      },
    );
  }

  Widget _buildCollapsibleSection(
    BuildContext context, {
    required String title,
    required int count,
    required Color color,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<_VestingItem> children,
    required CapTableProvider provider,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.outline,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Column(
                children: children
                    .map(
                      (item) =>
                          _UnifiedVestingCard(item: item, provider: provider),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  List<_VestingItem> _buildVestingItems(CapTableProvider provider) {
    final items = <_VestingItem>[];

    // Time-based vesting
    for (final schedule in provider.vestingSchedules) {
      final transaction = provider.transactions.cast<Transaction?>().firstWhere(
        (t) => t?.id == schedule.transactionId,
        orElse: () => null,
      );
      final investor = transaction != null
          ? provider.getInvestorById(transaction.investorId)
          : null;

      _VestingStatus status;
      if (schedule.leaverStatus != LeaverStatus.active) {
        status = _VestingStatus.terminated;
      } else if (schedule.vestingPercentage >= 100) {
        status = _VestingStatus.completed;
      } else {
        status = _VestingStatus.active;
      }

      items.add(
        _VestingItem(
          type: _VestingType.timeBased,
          id: schedule.id,
          investorName: investor?.name ?? 'Unknown',
          investorType: investor?.type,
          progress: schedule.vestingPercentage / 100,
          subtitle:
              '${schedule.vestingPeriodMonths}mo with ${schedule.cliffMonths}mo cliff',
          status: status,
          schedule: schedule,
        ),
      );
    }

    // Milestone vesting
    for (final milestone in provider.milestones) {
      final investor = provider.getInvestorById(milestone.investorId ?? '');

      _VestingStatus status;
      if (milestone.isLapsed) {
        status = _VestingStatus.terminated;
      } else if (milestone.isCompleted) {
        status = _VestingStatus.completed;
      } else {
        status = _VestingStatus.active;
      }

      items.add(
        _VestingItem(
          type: _VestingType.milestone,
          id: milestone.id,
          investorName: investor?.name ?? 'Unknown',
          investorType: investor?.type,
          progress: milestone.progress,
          subtitle: milestone.name,
          status: status,
          milestone: milestone,
        ),
      );
    }

    // Hours-based vesting
    for (final hours in provider.hoursVestingSchedules) {
      final investor = provider.getInvestorById(hours.investorId);

      _VestingStatus status;
      if (hours.progress >= 1.0) {
        status = _VestingStatus.completed;
      } else {
        status = _VestingStatus.active;
      }

      items.add(
        _VestingItem(
          type: _VestingType.hours,
          id: hours.id,
          investorName: investor?.name ?? 'Unknown',
          investorType: investor?.type,
          progress: hours.progress,
          subtitle:
              '${hours.hoursLogged.toStringAsFixed(0)}/${hours.totalHoursCommitment}h',
          status: status,
          hoursSchedule: hours,
        ),
      );
    }

    return items;
  }

  void _showAddMenu(BuildContext context, CapTableProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Time-based Vesting'),
              subtitle: const Text('Standard cliff + linear vesting'),
              onTap: () {
                Navigator.pop(context);
                _showAddTimeBasedVesting(context, provider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.replay),
              title: const Text('Reverse Vesting'),
              subtitle: const Text('Founder buyback / company repurchase'),
              onTap: () {
                Navigator.pop(context);
                _showAddReverseVesting(context, provider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Milestone Vesting'),
              subtitle: const Text('Vest on achievement of goals'),
              onTap: () {
                Navigator.pop(context);
                _showAddMilestone(context, provider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Hours-based Vesting'),
              subtitle: const Text('Vest based on hours worked'),
              onTap: () {
                Navigator.pop(context);
                _showAddHoursVesting(context, provider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.merge_type),
              title: const Text('Hybrid Vesting'),
              subtitle: const Text('Combine time + milestones + hours'),
              onTap: () {
                Navigator.pop(context);
                _showAddHybridVesting(context, provider);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTimeBasedVesting(
    BuildContext context,
    CapTableProvider provider,
  ) {
    final allAcquisitions = provider.transactions
        .where((t) => t.isAcquisition)
        .toList();
    final transactionsWithoutVesting = allAcquisitions.where((t) {
      return provider.getVestingByTransaction(t.id) == null;
    }).toList();

    if (transactionsWithoutVesting.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All investments already have vesting schedules'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => VestingScheduleDialog(
        transactions: transactionsWithoutVesting,
        provider: provider,
      ),
    );
  }

  void _showAddMilestone(BuildContext context, CapTableProvider provider) {
    showDialog(
      context: context,
      builder: (context) => _MilestoneDialog(provider: provider),
    );
  }

  void _showAddHoursVesting(BuildContext context, CapTableProvider provider) {
    showDialog(
      context: context,
      builder: (context) => _HoursVestingDialog(provider: provider),
    );
  }

  void _showAddReverseVesting(BuildContext context, CapTableProvider provider) {
    final allAcquisitions = provider.transactions
        .where((t) => t.isAcquisition)
        .toList();
    final transactionsWithoutVesting = allAcquisitions.where((t) {
      return provider.getVestingByTransaction(t.id) == null;
    }).toList();

    if (transactionsWithoutVesting.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All investments already have vesting schedules'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => VestingScheduleDialog(
        transactions: transactionsWithoutVesting,
        provider: provider,
        initialVestingType: VestingType.reverse,
      ),
    );
  }

  void _showAddHybridVesting(BuildContext context, CapTableProvider provider) {
    final allAcquisitions = provider.transactions
        .where((t) => t.isAcquisition)
        .toList();
    final transactionsWithoutVesting = allAcquisitions.where((t) {
      return provider.getVestingByTransaction(t.id) == null;
    }).toList();

    if (transactionsWithoutVesting.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All investments already have vesting schedules'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => VestingScheduleDialog(
        transactions: transactionsWithoutVesting,
        provider: provider,
        initialVestingType: VestingType.hybrid,
      ),
    );
  }
}

// ============ Helper Types ============

enum _VestingType { timeBased, milestone, hours }

enum _VestingStatus { active, completed, terminated }

class _VestingItem {
  final _VestingType type;
  final String id;
  final String investorName;
  final InvestorType? investorType;
  final double progress;
  final String subtitle;
  final _VestingStatus status;
  final VestingSchedule? schedule;
  final Milestone? milestone;
  final HoursVestingSchedule? hoursSchedule;

  _VestingItem({
    required this.type,
    required this.id,
    required this.investorName,
    this.investorType,
    required this.progress,
    required this.subtitle,
    required this.status,
    this.schedule,
    this.milestone,
    this.hoursSchedule,
  });

  IconData get typeIcon {
    switch (type) {
      case _VestingType.timeBased:
        return Icons.schedule;
      case _VestingType.milestone:
        return Icons.flag;
      case _VestingType.hours:
        return Icons.access_time;
    }
  }

  Color get typeColor {
    switch (type) {
      case _VestingType.timeBased:
        return Colors.indigo;
      case _VestingType.milestone:
        return Colors.orange;
      case _VestingType.hours:
        return Colors.teal;
    }
  }

  String get typeName {
    switch (type) {
      case _VestingType.timeBased:
        return 'Time';
      case _VestingType.milestone:
        return 'Milestone';
      case _VestingType.hours:
        return 'Hours';
    }
  }
}

// ============ Unified Summary Card ============

class _UnifiedSummaryCard extends StatelessWidget {
  final int activeCount;
  final int completedCount;
  final int terminatedCount;
  final CapTableProvider provider;

  const _UnifiedSummaryCard({
    required this.activeCount,
    required this.completedCount,
    required this.terminatedCount,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Vesting Overview',
      icon: Icons.pie_chart,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: MiniStat(label: 'Active', value: activeCount.toString()),
              ),
              Expanded(
                child: MiniStat(
                  label: 'Completed',
                  value: completedCount.toString(),
                ),
              ),
              Expanded(
                child: MiniStat(
                  label: 'Terminated',
                  value: terminatedCount.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _TypeIndicator(
                Icons.schedule,
                'Time',
                Colors.indigo,
                provider.vestingSchedules.length,
              ),
              const SizedBox(width: 12),
              _TypeIndicator(
                Icons.flag,
                'Milestone',
                Colors.orange,
                provider.milestones.length,
              ),
              const SizedBox(width: 12),
              _TypeIndicator(
                Icons.access_time,
                'Hours',
                Colors.teal,
                provider.hoursVestingSchedules.length,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeIndicator extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final int count;

  const _TypeIndicator(this.icon, this.label, this.color, this.count);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ============ Unified Vesting Card ============

class _UnifiedVestingCard extends StatelessWidget {
  final _VestingItem item;
  final CapTableProvider provider;

  const _UnifiedVestingCard({required this.item, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color statusColor;
    switch (item.status) {
      case _VestingStatus.active:
        statusColor = Colors.blue;
      case _VestingStatus.completed:
        statusColor = Colors.green;
      case _VestingStatus.terminated:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => _showDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Type indicator
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: item.typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.typeIcon, size: 18, color: item.typeColor),
              ),
              const SizedBox(width: 12),
              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.investorName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              // Progress
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(item.progress * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 60,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: item.progress.clamp(0, 1),
                        backgroundColor: statusColor.withValues(alpha: 0.1),
                        color: statusColor,
                        minHeight: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    switch (item.type) {
      case _VestingType.timeBased:
        if (item.schedule != null) {
          _showTimeBasedDetails(context, item.schedule!);
        }
      case _VestingType.milestone:
        if (item.milestone != null) {
          _showMilestoneDetails(context, item.milestone!);
        }
      case _VestingType.hours:
        if (item.hoursSchedule != null) {
          _showHoursDetails(context, item.hoursSchedule!);
        }
    }
  }

  void _showTimeBasedDetails(BuildContext context, VestingSchedule schedule) {
    showDialog(
      context: context,
      builder: (context) =>
          TimeBasedDetailDialog(schedule: schedule, provider: provider),
    );
  }

  void _showMilestoneDetails(BuildContext context, Milestone milestone) {
    showDialog(
      context: context,
      builder: (context) =>
          _MilestoneDetailDialog(milestone: milestone, provider: provider),
    );
  }

  void _showHoursDetails(BuildContext context, HoursVestingSchedule schedule) {
    showDialog(
      context: context,
      builder: (context) =>
          _HoursDetailDialog(schedule: schedule, provider: provider),
    );
  }
}

// ============ Detail Dialogs ============

class TimeBasedDetailDialog extends StatelessWidget {
  final VestingSchedule schedule;
  final CapTableProvider provider;

  const TimeBasedDetailDialog({
    super.key,
    required this.schedule,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transaction = provider.transactions.cast<Transaction?>().firstWhere(
      (t) => t?.id == schedule.transactionId,
      orElse: () => null,
    );
    final investor = transaction != null
        ? provider.getInvestorById(transaction.investorId)
        : null;
    final round = provider.getRoundById(transaction?.roundId ?? '');

    final vestedShares = transaction != null
        ? (transaction.numberOfShares * schedule.vestingPercentage / 100)
              .round()
        : 0;
    final unvestedShares = transaction != null
        ? transaction.numberOfShares - vestedShares
        : 0;

    Color statusColor;
    String statusText;
    switch (schedule.leaverStatus) {
      case LeaverStatus.active:
        if (schedule.vestingPercentage >= 100) {
          statusColor = Colors.green;
          statusText = 'Fully Vested';
        } else if (!schedule.cliffPassed) {
          statusColor = Colors.orange;
          statusText = 'In Cliff';
        } else {
          statusColor = Colors.blue;
          statusText = 'Vesting';
        }
      case LeaverStatus.goodLeaver:
        statusColor = Colors.amber;
        statusText = 'Good Leaver';
      case LeaverStatus.badLeaver:
        statusColor = Colors.red;
        statusText = 'Bad Leaver';
    }

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.schedule, color: Colors.indigo),
          const SizedBox(width: 8),
          Expanded(child: Text(investor?.name ?? 'Time-based Vesting')),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Progress
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${Formatters.percent(schedule.vestingPercentage)} vested',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: schedule.vestingPercentage / 100,
                            backgroundColor: statusColor.withValues(alpha: 0.1),
                            color: statusColor,
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Share info
              if (transaction != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: ResultChip(
                        label: 'Total',
                        value: Formatters.number(transaction.numberOfShares),
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ResultChip(
                        label: 'Vested',
                        value: Formatters.number(vestedShares),
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ResultChip(
                        label: 'Unvested',
                        value: Formatters.number(unvestedShares),
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Details
              _DetailRow(label: 'Round', value: round?.name ?? 'Unknown'),
              _DetailRow(
                label: 'Schedule',
                value:
                    '${schedule.vestingPeriodMonths}mo with ${schedule.cliffMonths}mo cliff',
              ),
              _DetailRow(
                label: 'Start',
                value: Formatters.date(schedule.startDate),
              ),
              _DetailRow(
                label: 'Cliff Date',
                value: Formatters.date(schedule.cliffDate),
              ),
              _DetailRow(
                label: 'End Date',
                value: Formatters.date(schedule.endDate),
              ),
              if (schedule.nextVestingDate != null)
                _DetailRow(
                  label: 'Next Vesting',
                  value: Formatters.date(schedule.nextVestingDate!),
                ),
              if (schedule.terminationDate != null)
                _DetailRow(
                  label: 'Terminated',
                  value: Formatters.date(schedule.terminationDate!),
                ),
            ],
          ),
        ),
      ),
      actions: [
        if (schedule.leaverStatus != LeaverStatus.active)
          TextButton.icon(
            onPressed: () {
              final updated = schedule.copyWith(
                leaverStatus: LeaverStatus.active,
                clearTerminationDate: true,
              );
              provider.updateVestingSchedule(updated);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.person_add_outlined),
            label: const Text('Reinstate'),
          ),
        // Only show terminate if active AND not fully vested
        if (schedule.leaverStatus == LeaverStatus.active &&
            schedule.vestingPercentage < 100)
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (ctx) => _TerminateVestingDialog(
                  schedule: schedule,
                  provider: provider,
                ),
              );
            },
            icon: const Icon(Icons.person_off_outlined),
            label: const Text('Terminate'),
          ),
        TextButton.icon(
          onPressed: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (ctx) => VestingScheduleDialog(
                transactions: provider.transactions
                    .where((t) => t.isAcquisition)
                    .toList(),
                provider: provider,
                existingSchedule: schedule,
              ),
            );
          },
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit'),
        ),
        TextButton.icon(
          onPressed: () {
            provider.deleteVestingSchedule(schedule.id);
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Delete'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _MilestoneDetailDialog extends StatelessWidget {
  final Milestone milestone;
  final CapTableProvider provider;

  const _MilestoneDetailDialog({
    required this.milestone,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final investor = provider.getInvestorById(milestone.investorId ?? '');

    Color statusColor;
    String statusText;
    if (milestone.isCompleted) {
      statusColor = Colors.green;
      statusText = 'Completed';
    } else if (milestone.isLapsed) {
      statusColor = Colors.grey;
      statusText = 'Lapsed';
    } else {
      statusColor = Colors.orange;
      statusText = 'Pending';
    }

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.flag, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(child: Text(milestone.name)),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Progress for graded
              if (milestone.triggerType == MilestoneTriggerType.graded) ...[
                Text(
                  '${(milestone.progress * 100).toStringAsFixed(0)}% complete',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: milestone.progress,
                    backgroundColor: statusColor.withValues(alpha: 0.1),
                    color: statusColor,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Details
              _DetailRow(
                label: 'Assignee',
                value: investor?.name ?? 'Unassigned',
              ),
              _DetailRow(
                label: 'Equity',
                value: '${milestone.equityPercent.toStringAsFixed(2)}%',
              ),
              _DetailRow(
                label: 'Type',
                value: milestone.triggerType == MilestoneTriggerType.binary
                    ? 'Binary'
                    : 'Graded',
              ),
              if (milestone.description != null)
                _DetailRow(label: 'Description', value: milestone.description!),
              if (milestone.deadline != null)
                _DetailRow(
                  label: 'Deadline',
                  value: Formatters.date(milestone.deadline!),
                ),
              if (milestone.completedDate != null)
                _DetailRow(
                  label: 'Completed',
                  value: Formatters.date(milestone.completedDate!),
                ),
            ],
          ),
        ),
      ),
      actions: [
        if (!milestone.isCompleted && !milestone.isLapsed)
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showCompleteMilestone(context, milestone);
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Complete'),
          ),
        TextButton.icon(
          onPressed: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (ctx) =>
                  _MilestoneDialog(provider: provider, milestone: milestone),
            );
          },
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit'),
        ),
        TextButton.icon(
          onPressed: () {
            provider.deleteMilestone(milestone.id);
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Delete'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  void _showCompleteMilestone(BuildContext context, Milestone milestone) {
    final isGraded = milestone.triggerType == MilestoneTriggerType.graded;

    // For graded milestones, we add progress. For binary, we complete.
    if (isGraded && milestone.progress < 1.0) {
      _showAddProgressDialog(context, milestone);
    } else {
      _showAwardEquityDialog(context, milestone);
    }
  }

  void _showAddProgressDialog(BuildContext context, Milestone milestone) {
    final progressController = TextEditingController(
      text: milestone.currentValue.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final newValue =
              double.tryParse(progressController.text) ??
              milestone.currentValue;
          final newProgress =
              milestone.targetValue != null && milestone.targetValue! > 0
              ? (newValue / milestone.targetValue!).clamp(0.0, 1.0)
              : 0.0;
          final willComplete = newProgress >= 1.0;

          return AlertDialog(
            title: const Text('Update Progress'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Milestone: ${milestone.name}'),
                Text(
                  'Target: ${milestone.targetValue?.toStringAsFixed(0) ?? "N/A"}',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: progressController,
                  decoration: InputDecoration(
                    labelText: 'Current Progress Value',
                    border: const OutlineInputBorder(),
                    helperText:
                        'Progress: ${(newProgress * 100).toStringAsFixed(1)}%',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: newProgress,
                  backgroundColor: Colors.grey.shade200,
                ),
                const SizedBox(height: 8),
                if (willComplete)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This will complete the milestone!',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              if (willComplete)
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Update progress first, then show award dialog
                    provider.updateMilestoneProgress(milestone.id, newValue);
                    _showAwardEquityDialog(context, milestone);
                  },
                  child: const Text('Complete & Award'),
                )
              else
                FilledButton(
                  onPressed: () {
                    provider.updateMilestoneProgress(milestone.id, newValue);
                    Navigator.pop(context);
                  },
                  child: const Text('Update Progress'),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showAwardEquityDialog(BuildContext context, Milestone milestone) {
    String? shareClassId;
    final priceController = TextEditingController(
      text: provider.latestSharePrice.toStringAsFixed(4),
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Complete Milestone'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Milestone: ${milestone.name}'),
              Text(
                'Equity to award: ${milestone.earnedEquityPercent.toStringAsFixed(2)}%',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: shareClassId,
                decoration: const InputDecoration(
                  labelText: 'Share Class',
                  border: OutlineInputBorder(),
                ),
                items: provider.shareClasses.map((sc) {
                  return DropdownMenuItem(value: sc.id, child: Text(sc.name));
                }).toList(),
                onChanged: (v) => setState(() => shareClassId = v),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Price per Share',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: shareClassId != null
                  ? () {
                      final pps = double.tryParse(priceController.text) ?? 0;
                      provider.completeMilestone(
                        milestone.id,
                        shareClassId!,
                        pps,
                      );
                      Navigator.pop(context);
                    }
                  : null,
              child: const Text('Award Equity'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoursDetailDialog extends StatelessWidget {
  final HoursVestingSchedule schedule;
  final CapTableProvider provider;

  const _HoursDetailDialog({required this.schedule, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final investor = provider.getInvestorById(schedule.investorId);

    Color statusColor;
    String statusText;
    if (schedule.progress >= 1.0) {
      statusColor = Colors.green;
      statusText = 'Fully Vested';
    } else if (schedule.cliffHours != null &&
        schedule.hoursLogged < schedule.cliffHours!) {
      statusColor = Colors.orange;
      statusText = 'In Cliff';
    } else {
      statusColor = Colors.blue;
      statusText = 'Vesting';
    }

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.access_time, color: Colors.teal),
          const SizedBox(width: 8),
          Expanded(child: Text(investor?.name ?? 'Hours Vesting')),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Progress
              Text(
                '${schedule.hoursLogged.toStringAsFixed(1)} / ${schedule.totalHoursCommitment} hours',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: schedule.progress,
                  backgroundColor: statusColor.withValues(alpha: 0.1),
                  color: statusColor,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 16),

              // Stats
              Row(
                children: [
                  Expanded(
                    child: ResultChip(
                      label: 'Total Equity',
                      value: '${schedule.totalEquityPercent}%',
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ResultChip(
                      label: 'Vested',
                      value:
                          '${schedule.totalVestedPercent.toStringAsFixed(2)}%',
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Details
              _DetailRow(
                label: 'Start Date',
                value: Formatters.date(schedule.startDate),
              ),
              _DetailRow(label: 'Curve', value: schedule.curveTypeDisplayName),
              if (schedule.cliffHours != null)
                _DetailRow(
                  label: 'Cliff Hours',
                  value: '${schedule.cliffHours} hours',
                ),

              // Recent log entries
              if (schedule.logEntries.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Recent Activity',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                ...schedule.logEntries
                    .take(5)
                    .map(
                      (e) => InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _showEditLogEntry(context, e);
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 4,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Formatters.date(e.date),
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    if (e.description != null &&
                                        e.description!.isNotEmpty)
                                      Text(
                                        e.description!,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme.colorScheme.outline,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '+${e.hours.toStringAsFixed(1)}h',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 14,
                                    color: theme.colorScheme.outline,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            Navigator.pop(context);
            _showLogHours(context);
          },
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Log Hours'),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (context) =>
                  _HoursVestingDialog(provider: provider, schedule: schedule),
            );
          },
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit'),
        ),
        TextButton.icon(
          onPressed: () {
            provider.deleteHoursVestingSchedule(schedule.id);
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Delete'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  void _showLogHours(BuildContext context) {
    final hoursController = TextEditingController();
    final notesController = TextEditingController();
    DateTime date = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Log Hours'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: hoursController,
                decoration: const InputDecoration(
                  labelText: 'Hours',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                trailing: TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: schedule.startDate,
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => date = picked);
                  },
                  child: Text(Formatters.date(date)),
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
              onPressed: () {
                final hours = double.tryParse(hoursController.text);
                if (hours != null && hours > 0) {
                  provider.logHoursForSchedule(
                    schedule.id,
                    hours,
                    date,
                    notesController.text.isEmpty ? null : notesController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Log'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditLogEntry(BuildContext context, HoursLogEntry entry) {
    final hoursController = TextEditingController(
      text: entry.hours.toStringAsFixed(1),
    );
    final notesController = TextEditingController(
      text: entry.description ?? '',
    );
    DateTime date = entry.date;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Log Entry'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: hoursController,
                decoration: const InputDecoration(
                  labelText: 'Hours',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                trailing: TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: schedule.startDate,
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => date = picked);
                  },
                  child: Text(Formatters.date(date)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _confirmDeleteLogEntry(context, entry);
              },
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final hours = double.tryParse(hoursController.text);
                if (hours != null && hours > 0) {
                  provider.updateLogEntry(
                    schedule.id,
                    entry.id,
                    hours: hours,
                    date: date,
                    description: notesController.text.isEmpty
                        ? null
                        : notesController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteLogEntry(BuildContext context, HoursLogEntry entry) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Log Entry'),
        content: Text(
          'Are you sure you want to delete this log entry?\n\n'
          '${Formatters.date(entry.date)} - ${entry.hours.toStringAsFixed(1)} hours\n\n'
          'This will reduce the total logged hours.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              provider.deleteLogEntry(schedule.id, entry.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

// Milestone dialog
class _MilestoneDialog extends StatefulWidget {
  final CapTableProvider provider;
  final Milestone? milestone;

  const _MilestoneDialog({required this.provider, this.milestone});

  @override
  State<_MilestoneDialog> createState() => _MilestoneDialogState();
}

class _MilestoneDialogState extends State<_MilestoneDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _equityController = TextEditingController();
  final _targetController = TextEditingController();
  String? _investorId;
  MilestoneTriggerType _triggerType = MilestoneTriggerType.binary;
  DateTime? _deadline;
  bool _lapseOnMiss = false;

  bool get isEditing => widget.milestone != null;

  @override
  void initState() {
    super.initState();
    if (widget.milestone != null) {
      final m = widget.milestone!;
      _nameController.text = m.name;
      _descriptionController.text = m.description ?? '';
      _equityController.text = m.equityPercent.toString();
      _targetController.text = m.targetValue?.toString() ?? '';
      _investorId = m.investorId;
      _triggerType = m.triggerType;
      _deadline = m.deadline;
      _lapseOnMiss = m.lapseOnMiss;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Edit Milestone' : 'Add Milestone'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Milestone Name',
                hintText: 'e.g., MVP Complete',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _investorId,
              decoration: const InputDecoration(
                labelText: 'Investor',
                border: OutlineInputBorder(),
              ),
              items: widget.provider.investors.map((inv) {
                return DropdownMenuItem(value: inv.id, child: Text(inv.name));
              }).toList(),
              onChanged: (v) => setState(() => _investorId = v),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _equityController,
              decoration: const InputDecoration(
                labelText: 'Equity %',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SegmentedButton<MilestoneTriggerType>(
              segments: const [
                ButtonSegment(
                  value: MilestoneTriggerType.binary,
                  label: Text('Binary'),
                ),
                ButtonSegment(
                  value: MilestoneTriggerType.graded,
                  label: Text('Graded'),
                ),
              ],
              selected: {_triggerType},
              onSelectionChanged: (v) => setState(() => _triggerType = v.first),
            ),
            if (_triggerType == MilestoneTriggerType.graded) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _targetController,
                decoration: const InputDecoration(
                  labelText: 'Target Value',
                  hintText: 'e.g., 250000 for \$250k ARR',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Deadline'),
              trailing: TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate:
                        _deadline ??
                        DateTime.now().add(const Duration(days: 365)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _deadline = picked);
                  }
                },
                child: Text(
                  _deadline != null ? Formatters.date(_deadline!) : 'None',
                ),
              ),
            ),
            if (_deadline != null)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Lapse if missed'),
                value: _lapseOnMiss,
                onChanged: (v) => setState(() => _lapseOnMiss = v ?? false),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (isEditing)
          TextButton(
            onPressed: () {
              widget.provider.deleteMilestone(widget.milestone!.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        FilledButton(
          onPressed: _canSave() ? _save : null,
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  bool _canSave() {
    return _nameController.text.isNotEmpty &&
        _investorId != null &&
        _equityController.text.isNotEmpty;
  }

  void _save() {
    final milestone = Milestone(
      id: widget.milestone?.id,
      name: _nameController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      investorId: _investorId,
      equityPercent: double.parse(_equityController.text),
      triggerType: _triggerType,
      targetValue:
          _triggerType == MilestoneTriggerType.graded &&
              _targetController.text.isNotEmpty
          ? double.parse(_targetController.text)
          : null,
      deadline: _deadline,
      lapseOnMiss: _lapseOnMiss,
      isCompleted: widget.milestone?.isCompleted ?? false,
      completedDate: widget.milestone?.completedDate,
      isLapsed: widget.milestone?.isLapsed ?? false,
    );

    if (isEditing) {
      widget.provider.updateMilestone(milestone);
    } else {
      widget.provider.addMilestone(milestone);
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _equityController.dispose();
    _targetController.dispose();
    super.dispose();
  }
}

// Hours vesting dialog
class _HoursVestingDialog extends StatefulWidget {
  final CapTableProvider provider;
  final HoursVestingSchedule? schedule;

  // ignore: unused_element_parameter - schedule is for future edit functionality
  const _HoursVestingDialog({required this.provider, this.schedule});

  @override
  State<_HoursVestingDialog> createState() => _HoursVestingDialogState();
}

class _HoursVestingDialogState extends State<_HoursVestingDialog> {
  String? _investorId;
  String? _transactionId;
  final _equityController = TextEditingController();
  final _hoursController = TextEditingController();
  final _cliffController = TextEditingController();
  HoursVestingCurve _curveType = HoursVestingCurve.linear;
  DateTime _startDate = DateTime.now();

  bool get isEditing => widget.schedule != null;

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      final s = widget.schedule!;
      _investorId = s.investorId;
      _transactionId = s.transactionId;
      _equityController.text = s.totalEquityPercent.toString();
      _hoursController.text = s.totalHoursCommitment.toString();
      _cliffController.text = s.cliffHours?.toString() ?? '';
      _curveType = s.curveType;
      _startDate = s.startDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get transactions for selected investor
    final investorTransactions = _investorId != null
        ? widget.provider.transactions
              .where((t) => t.investorId == _investorId && t.isAcquisition)
              .toList()
        : <Transaction>[];

    return AlertDialog(
      title: Text(isEditing ? 'Edit Hours Schedule' : 'Add Hours Schedule'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _investorId,
              decoration: const InputDecoration(
                labelText: 'Investor',
                border: OutlineInputBorder(),
              ),
              items: widget.provider.investors.map((inv) {
                return DropdownMenuItem(value: inv.id, child: Text(inv.name));
              }).toList(),
              onChanged: (v) => setState(() {
                _investorId = v;
                _transactionId = null;
              }),
            ),
            if (investorTransactions.isNotEmpty) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _transactionId,
                decoration: const InputDecoration(
                  labelText: 'Shareholding',
                  border: OutlineInputBorder(),
                ),
                items: investorTransactions.map((t) {
                  return DropdownMenuItem(
                    value: t.id,
                    child: Text(
                      '${Formatters.number(t.numberOfShares)} shares (${Formatters.date(t.date)})',
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) {
                    final transaction = investorTransactions.firstWhere(
                      (t) => t.id == v,
                    );
                    setState(() {
                      _transactionId = v;
                      // Auto-update start date to match transaction date
                      _startDate = transaction.date;
                    });
                  }
                },
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _equityController,
                    decoration: const InputDecoration(
                      labelText: 'Equity %',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _hoursController,
                    decoration: const InputDecoration(
                      labelText: 'Total Hours',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<HoursVestingCurve>(
              initialValue: _curveType,
              decoration: const InputDecoration(
                labelText: 'Vesting Curve',
                border: OutlineInputBorder(),
              ),
              items: HoursVestingCurve.values.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(_getCurveName(c)),
                );
              }).toList(),
              onChanged: (v) => setState(() => _curveType = v!),
            ),
            if (_curveType == HoursVestingCurve.cliff) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _cliffController,
                decoration: const InputDecoration(
                  labelText: 'Cliff Hours',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Start Date'),
              trailing: TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _startDate = picked);
                  }
                },
                child: Text(Formatters.date(_startDate)),
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
        if (isEditing)
          TextButton(
            onPressed: () {
              widget.provider.deleteHoursVestingSchedule(widget.schedule!.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        FilledButton(
          onPressed: _canSave() ? _save : null,
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  String _getCurveName(HoursVestingCurve curve) {
    switch (curve) {
      case HoursVestingCurve.linear:
        return 'Linear';
      case HoursVestingCurve.cliff:
        return 'Cliff';
      case HoursVestingCurve.progressive:
        return 'Progressive (faster later)';
      case HoursVestingCurve.frontLoaded:
        return 'Front-loaded (faster early)';
    }
  }

  bool _canSave() {
    return _investorId != null &&
        _transactionId != null &&
        _equityController.text.isNotEmpty &&
        _hoursController.text.isNotEmpty;
  }

  void _save() {
    final schedule = HoursVestingSchedule(
      id: widget.schedule?.id,
      investorId: _investorId!,
      transactionId: _transactionId!,
      totalEquityPercent: double.parse(_equityController.text),
      totalHoursCommitment: int.parse(_hoursController.text),
      hoursLogged: widget.schedule?.hoursLogged ?? 0,
      curveType: _curveType,
      cliffHours:
          _curveType == HoursVestingCurve.cliff &&
              _cliffController.text.isNotEmpty
          ? int.parse(_cliffController.text)
          : null,
      startDate: _startDate,
      logEntries: widget.schedule?.logEntries ?? [],
      bonusMilestones: widget.schedule?.bonusMilestones ?? [],
    );

    if (isEditing) {
      widget.provider.updateHoursVestingSchedule(schedule);
    } else {
      widget.provider.addHoursVestingSchedule(schedule);
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _equityController.dispose();
    _hoursController.dispose();
    _cliffController.dispose();
    super.dispose();
  }
}

class _TerminateVestingDialog extends StatefulWidget {
  final VestingSchedule schedule;
  final CapTableProvider provider;

  const _TerminateVestingDialog({
    required this.schedule,
    required this.provider,
  });

  @override
  State<_TerminateVestingDialog> createState() =>
      _TerminateVestingDialogState();
}

class _TerminateVestingDialogState extends State<_TerminateVestingDialog> {
  late DateTime _terminationDate;
  LeaverStatus _leaverStatus = LeaverStatus.goodLeaver;

  @override
  void initState() {
    super.initState();
    _terminationDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Terminate Vesting'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select the termination date and leaver status. Good leavers keep their vested shares, bad leavers forfeit all shares.',
          ),
          const SizedBox(height: 24),

          // Termination Date
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Termination Date'),
            subtitle: Text(Formatters.date(_terminationDate)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _terminationDate,
                firstDate: widget.schedule.startDate,
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _terminationDate = date);
              }
            },
          ),

          const SizedBox(height: 16),

          // Leaver Status
          const Text('Leaver Status'),
          const SizedBox(height: 8),
          SegmentedButton<LeaverStatus>(
            segments: const [
              ButtonSegment(
                value: LeaverStatus.goodLeaver,
                label: Text('Good'),
                icon: Icon(Icons.thumb_up_outlined),
              ),
              ButtonSegment(
                value: LeaverStatus.badLeaver,
                label: Text('Bad'),
                icon: Icon(Icons.thumb_down_outlined),
              ),
            ],
            selected: {_leaverStatus},
            onSelectionChanged: (set) {
              setState(() => _leaverStatus = set.first);
            },
          ),

          const SizedBox(height: 16),

          // Preview
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _leaverStatus == LeaverStatus.goodLeaver
                  ? Colors.amber.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _leaverStatus == LeaverStatus.goodLeaver
                      ? 'Good Leaver: Keeps vested shares'
                      : 'Bad Leaver: Forfeits all shares',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _leaverStatus == LeaverStatus.goodLeaver
                        ? Colors.amber.shade700
                        : Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _leaverStatus == LeaverStatus.goodLeaver
                      ? 'Vested: ${widget.schedule.vestingPercentage.toStringAsFixed(1)}%'
                      : 'All shares returned to pool',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
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
          onPressed: () {
            final updated = widget.schedule.copyWith(
              leaverStatus: _leaverStatus,
              terminationDate: _terminationDate,
            );
            widget.provider.updateVestingSchedule(updated);
            Navigator.pop(context);
          },
          child: const Text('Terminate'),
        ),
      ],
    );
  }
}

class VestingScheduleDialog extends StatefulWidget {
  final List<Transaction> transactions;
  final CapTableProvider provider;
  final VestingSchedule? existingSchedule;
  final VestingType? initialVestingType;

  const VestingScheduleDialog({
    super.key,
    required this.transactions,
    required this.provider,
    this.existingSchedule,
    this.initialVestingType,
  });

  @override
  State<VestingScheduleDialog> createState() => _VestingScheduleDialogState();
}

class _VestingScheduleDialogState extends State<VestingScheduleDialog> {
  late String? _selectedTransactionId;
  late VestingType _vestingType;
  late DateTime _startDate;
  late int _vestingPeriodMonths;
  late int _cliffMonths;
  late VestingFrequency _frequency;
  late double _accelerationPercent;
  late String _notes;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final existing = widget.existingSchedule;
    _selectedTransactionId =
        existing?.transactionId ??
        (widget.transactions.isNotEmpty ? widget.transactions.first.id : null);
    _vestingType =
        existing?.type ?? widget.initialVestingType ?? VestingType.timeBased;

    // For new schedules, get start date from selected transaction
    if (existing != null) {
      _startDate = existing.startDate;
    } else if (_selectedTransactionId != null) {
      final transaction = widget.transactions.firstWhere(
        (t) => t.id == _selectedTransactionId,
        orElse: () => widget.transactions.first,
      );
      _startDate = transaction.date;
    } else {
      _startDate = DateTime.now();
    }

    _vestingPeriodMonths = existing?.vestingPeriodMonths ?? 48;
    _cliffMonths = existing?.cliffMonths ?? 12;
    _frequency = existing?.frequency ?? VestingFrequency.monthly;
    _accelerationPercent = existing?.accelerationPercent ?? 0;
    _notes = existing?.notes ?? '';
  }

  bool get isEditing => widget.existingSchedule != null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Edit Vesting Schedule' : 'Add Vesting Schedule'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Investment selection (only for new)
                if (!isEditing) ...[
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Investment',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedTransactionId,
                    items: widget.transactions.map((t) {
                      final investor = widget.provider.getInvestorById(
                        t.investorId,
                      );
                      final round = widget.provider.getRoundById(
                        t.roundId ?? '',
                      );
                      return DropdownMenuItem(
                        value: t.id,
                        child: Text(
                          '${investor?.name ?? 'Unknown'} - ${round?.name ?? 'Unknown'} (${Formatters.number(t.numberOfShares)} shares)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        final transaction = widget.transactions.firstWhere(
                          (t) => t.id == value,
                        );
                        setState(() {
                          _selectedTransactionId = value;
                          // Auto-update start date to match transaction date
                          _startDate = transaction.date;
                        });
                      }
                    },
                    validator: (value) =>
                        value == null ? 'Please select an investment' : null,
                  ),
                  const SizedBox(height: 16),
                ],

                // Vesting Type
                DropdownButtonFormField<VestingType>(
                  decoration: InputDecoration(
                    labelText: 'Vesting Type',
                    border: const OutlineInputBorder(),
                    suffixIcon: const HelpIcon(helpKey: 'vesting.vesting'),
                  ),
                  initialValue: _vestingType,
                  items: VestingType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getVestingTypeLabel(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _vestingType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Start Date
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Start Date'),
                  subtitle: Text(Formatters.date(_startDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() => _startDate = date);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Vesting Period
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: 'Vesting Period',
                          border: const OutlineInputBorder(),
                          suffixIcon: const HelpIcon(
                            helpKey: 'fields.vestingMonths',
                          ),
                        ),
                        initialValue: _vestingPeriodMonths,
                        items: [12, 24, 36, 48, 60].map((months) {
                          return DropdownMenuItem(
                            value: months,
                            child: Text('${months ~/ 12} years'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _vestingPeriodMonths = value;
                              // Ensure cliff doesn't exceed vesting period
                              if (_cliffMonths > value) {
                                _cliffMonths = value ~/ 4;
                              }
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: 'Cliff Period',
                          border: const OutlineInputBorder(),
                          suffixIcon: const HelpIcon(helpKey: 'vesting.cliff'),
                        ),
                        initialValue: _cliffMonths,
                        items: [0, 3, 6, 9, 12, 18, 24]
                            .where((m) => m <= _vestingPeriodMonths)
                            .map((months) {
                              return DropdownMenuItem(
                                value: months,
                                child: Text(
                                  months == 0 ? 'No cliff' : '$months months',
                                ),
                              );
                            })
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _cliffMonths = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Frequency
                DropdownButtonFormField<VestingFrequency>(
                  decoration: const InputDecoration(
                    labelText: 'Vesting Frequency',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _frequency,
                  items: VestingFrequency.values.map((freq) {
                    return DropdownMenuItem(
                      value: freq,
                      child: Text(_getFrequencyLabel(freq)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _frequency = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Acceleration
                DropdownButtonFormField<double>(
                  decoration: InputDecoration(
                    labelText: 'Acceleration on Liquidity Event',
                    border: const OutlineInputBorder(),
                    suffixIcon: const HelpIcon(helpKey: 'vesting.acceleration'),
                  ),
                  initialValue: _accelerationPercent,
                  items: [0.0, 25.0, 50.0, 100.0].map((percent) {
                    return DropdownMenuItem(
                      value: percent,
                      child: Text(
                        percent == 0
                            ? 'None'
                            : '${percent.toInt()}% acceleration',
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _accelerationPercent = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Notes
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _notes,
                  maxLines: 2,
                  onChanged: (value) => _notes = value,
                ),

                const SizedBox(height: 16),

                // Preview
                _buildPreview(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: Text(isEditing ? 'Save' : 'Add')),
      ],
    );
  }

  Widget _buildPreview() {
    final cliffDate = DateTime(
      _startDate.year,
      _startDate.month + _cliffMonths,
      _startDate.day,
    );
    final endDate = DateTime(
      _startDate.year,
      _startDate.month + _vestingPeriodMonths,
      _startDate.day,
    );
    final cliffPercent = (_cliffMonths / _vestingPeriodMonths * 100)
        .toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule Preview',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '• Cliff: ${Formatters.date(cliffDate)} ($cliffPercent% vests)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            '• End: ${Formatters.date(endDate)} (100% vested)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            '• Vests ${_getFrequencyLabel(_frequency).toLowerCase()} after cliff',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _getVestingTypeLabel(VestingType type) {
    switch (type) {
      case VestingType.timeBased:
        return 'Time-based';
      case VestingType.milestoneBased:
        return 'Milestone-based';
      case VestingType.reverse:
        return 'Reverse vesting';
      case VestingType.hybrid:
        return 'Hybrid';
    }
  }

  String _getFrequencyLabel(VestingFrequency frequency) {
    switch (frequency) {
      case VestingFrequency.monthly:
        return 'Monthly';
      case VestingFrequency.quarterly:
        return 'Quarterly';
      case VestingFrequency.annually:
        return 'Annually';
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTransactionId == null) return;

    final schedule = VestingSchedule(
      id: widget.existingSchedule?.id,
      transactionId: _selectedTransactionId!,
      type: _vestingType,
      startDate: _startDate,
      vestingPeriodMonths: _vestingPeriodMonths,
      cliffMonths: _cliffMonths,
      frequency: _frequency,
      accelerationPercent: _accelerationPercent,
      leaverStatus:
          widget.existingSchedule?.leaverStatus ?? LeaverStatus.active,
      terminationDate: widget.existingSchedule?.terminationDate,
      notes: _notes.isEmpty ? null : _notes,
    );

    if (isEditing) {
      widget.provider.updateVestingSchedule(schedule);
    } else {
      widget.provider.addVestingSchedule(schedule);
    }

    Navigator.pop(context);
  }
}
