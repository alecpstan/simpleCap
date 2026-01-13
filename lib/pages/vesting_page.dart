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
import '../widgets/avatars.dart';
import '../widgets/info_widgets.dart';
import '../widgets/help_icon.dart';
import '../utils/helpers.dart';

class VestingPage extends StatefulWidget {
  const VestingPage({super.key});

  @override
  State<VestingPage> createState() => _VestingPageState();
}

class _VestingPageState extends State<VestingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CapTableProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                icon: const Icon(Icons.schedule),
                text: 'Time-based (${provider.vestingSchedules.length})',
              ),
              Tab(
                icon: const Icon(Icons.flag),
                text: 'Milestones (${provider.milestones.length})',
              ),
              Tab(
                icon: const Icon(Icons.access_time),
                text: 'Hours (${provider.hoursVestingSchedules.length})',
              ),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _TimeBasedVestingTab(provider: provider),
              _MilestoneVestingTab(provider: provider),
              _HoursVestingTab(provider: provider),
            ],
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
}

// Time-based vesting tab (original content)
class _TimeBasedVestingTab extends StatelessWidget {
  final CapTableProvider provider;

  const _TimeBasedVestingTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final vestingSchedules = provider.vestingSchedules;

    if (vestingSchedules.isEmpty) {
      return const EmptyState(
        icon: Icons.schedule_outlined,
        title: 'No time-based vesting',
        subtitle: 'Add schedules to track cliff + linear vesting',
      );
    }

    // Group vesting by status
    final active = vestingSchedules
        .where((v) => v.leaverStatus == LeaverStatus.active)
        .toList();
    final fullyVested = active
        .where((v) => v.vestingPercentage >= 100)
        .toList();
    final vesting = active.where((v) => v.vestingPercentage < 100).toList();
    final terminated = vestingSchedules
        .where((v) => v.leaverStatus != LeaverStatus.active)
        .toList();

    vesting.sort((a, b) => a.vestingPercentage.compareTo(b.vestingPercentage));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Stats
          _VestingSummaryCard(
            vestingSchedules: vestingSchedules,
            provider: provider,
          ),
          const SizedBox(height: 24),

          // Currently Vesting
          if (vesting.isNotEmpty) ...[
            _buildSectionHeader(context, 'Currently Vesting', vesting.length),
            const SizedBox(height: 8),
            ...vesting.map(
              (v) => _VestingCard(schedule: v, provider: provider),
            ),
            const SizedBox(height: 24),
          ],

          // Fully Vested
          if (fullyVested.isNotEmpty) ...[
            _buildSectionHeader(context, 'Fully Vested', fullyVested.length),
            const SizedBox(height: 8),
            ...fullyVested.map(
              (v) => _VestingCard(schedule: v, provider: provider),
            ),
            const SizedBox(height: 24),
          ],

          // Terminated
          if (terminated.isNotEmpty) ...[
            _buildSectionHeader(context, 'Terminated', terminated.length),
            const SizedBox(height: 8),
            ...terminated.map(
              (v) => _VestingCard(schedule: v, provider: provider),
            ),
          ],

          // Space for FAB
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}

// Milestone vesting tab
class _MilestoneVestingTab extends StatelessWidget {
  final CapTableProvider provider;

  const _MilestoneVestingTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final milestones = provider.milestones;

    if (milestones.isEmpty) {
      return const EmptyState(
        icon: Icons.flag_outlined,
        title: 'No milestone vesting',
        subtitle: 'Add milestones to award equity on goal achievement',
      );
    }

    final pending = milestones
        .where((m) => !m.isCompleted && !m.isLapsed)
        .toList();
    final completed = milestones.where((m) => m.isCompleted).toList();
    final lapsed = milestones.where((m) => m.isLapsed).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Stats
          _MilestoneSummaryCard(milestones: milestones, provider: provider),
          const SizedBox(height: 24),

          // Pending milestones
          if (pending.isNotEmpty) ...[
            _buildSectionHeader(context, 'Pending', pending.length),
            const SizedBox(height: 8),
            ...pending.map(
              (m) => _MilestoneCard(milestone: m, provider: provider),
            ),
            const SizedBox(height: 24),
          ],

          // Completed milestones
          if (completed.isNotEmpty) ...[
            _buildSectionHeader(context, 'Completed', completed.length),
            const SizedBox(height: 8),
            ...completed.map(
              (m) => _MilestoneCard(milestone: m, provider: provider),
            ),
            const SizedBox(height: 24),
          ],

          // Lapsed milestones
          if (lapsed.isNotEmpty) ...[
            _buildSectionHeader(context, 'Lapsed', lapsed.length),
            const SizedBox(height: 8),
            ...lapsed.map(
              (m) => _MilestoneCard(milestone: m, provider: provider),
            ),
          ],

          // Space for FAB
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}

class _MilestoneSummaryCard extends StatelessWidget {
  final List<Milestone> milestones;
  final CapTableProvider provider;

  const _MilestoneSummaryCard({
    required this.milestones,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final pendingCount = milestones
        .where((m) => !m.isCompleted && !m.isLapsed)
        .length;
    final completedCount = milestones.where((m) => m.isCompleted).length;

    final totalEquity = milestones.fold<double>(
      0,
      (sum, m) => sum + m.equityPercent,
    );
    final earnedEquity = milestones
        .where((m) => m.isCompleted)
        .fold<double>(0, (sum, m) => sum + m.earnedEquityPercent);
    final pendingEquity = milestones
        .where((m) => !m.isCompleted && !m.isLapsed)
        .fold<double>(0, (sum, m) => sum + m.equityPercent);

    return SectionCard(
      title: 'Milestone Summary',
      icon: Icons.flag,
      helpKey: 'vesting.milestones',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: MiniStat(
                  label: 'Total Milestones',
                  value: milestones.length.toString(),
                ),
              ),
              Expanded(
                child: MiniStat(
                  label: 'Pending',
                  value: pendingCount.toString(),
                ),
              ),
              Expanded(
                child: MiniStat(
                  label: 'Completed',
                  value: completedCount.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: MiniStat(
                  label: 'Total Equity',
                  value: '${totalEquity.toStringAsFixed(2)}%',
                ),
              ),
              Expanded(
                child: MiniStat(
                  label: 'Earned',
                  value: '${earnedEquity.toStringAsFixed(2)}%',
                ),
              ),
              Expanded(
                child: MiniStat(
                  label: 'Pending',
                  value: '${pendingEquity.toStringAsFixed(2)}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  final Milestone milestone;
  final CapTableProvider provider;

  const _MilestoneCard({required this.milestone, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final investor = provider.getInvestorById(milestone.investorId ?? '');

    // Status color
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

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.2),
          child: Icon(
            milestone.isCompleted
                ? Icons.check
                : milestone.isLapsed
                ? Icons.close
                : Icons.flag,
            color: statusColor,
          ),
        ),
        title: Text(
          milestone.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            // Progress indicator for graded milestones
            if (milestone.triggerType == MilestoneTriggerType.graded)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: milestone.progress,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        color: statusColor,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${(milestone.progress * 100).toStringAsFixed(0)}% complete',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: Text(
                  '${milestone.equityPercent.toStringAsFixed(2)}% equity',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            const SizedBox(width: 12),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Milestone info
                Row(
                  children: [
                    Expanded(
                      child: ResultChip(
                        label: 'Equity',
                        value: '${milestone.equityPercent.toStringAsFixed(2)}%',
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ResultChip(
                        label: 'Trigger',
                        value: milestone.triggerTypeDisplayName,
                        color: Colors.blue,
                      ),
                    ),
                    if (milestone.isCompleted) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: ResultChip(
                          label: 'Earned',
                          value:
                              '${milestone.earnedEquityPercent.toStringAsFixed(2)}%',
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                // Details
                if (investor != null)
                  _buildDetailRow(context, 'Assignee', investor.name),
                if (milestone.description != null)
                  _buildDetailRow(
                    context,
                    'Description',
                    milestone.description!,
                  ),
                if (milestone.deadline != null)
                  _buildDetailRow(
                    context,
                    'Deadline',
                    Formatters.date(milestone.deadline!),
                  ),
                if (milestone.completedDate != null)
                  _buildDetailRow(
                    context,
                    'Completed',
                    Formatters.date(milestone.completedDate!),
                  ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!milestone.isCompleted && !milestone.isLapsed)
                      TextButton.icon(
                        onPressed: () => _showCompleteMilestone(context),
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Complete'),
                      ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _showEditMilestone(context),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _showDeleteMilestone(context),
                      icon: Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.error,
                      ),
                      label: Text(
                        'Delete',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
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

  void _showCompleteMilestone(BuildContext context) {
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

  void _showEditMilestone(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          _MilestoneDialog(provider: provider, milestone: milestone),
    );
  }

  void _showDeleteMilestone(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Milestone'),
        content: Text(
          'Are you sure you want to delete "${milestone.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              provider.deleteMilestone(milestone.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Hours-based vesting tab
class _HoursVestingTab extends StatelessWidget {
  final CapTableProvider provider;

  const _HoursVestingTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final schedules = provider.hoursVestingSchedules;

    if (schedules.isEmpty) {
      return const EmptyState(
        icon: Icons.access_time,
        title: 'No hours-based vesting',
        subtitle: 'Track equity vesting based on hours worked',
      );
    }

    // Group by status
    final active = schedules.where((s) => s.progress < 1.0).toList();
    final fullyVested = schedules.where((s) => s.progress >= 1.0).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Stats
          _HoursSummaryCard(schedules: schedules, provider: provider),
          const SizedBox(height: 24),

          // Currently Vesting
          if (active.isNotEmpty) ...[
            _buildSectionHeader(context, 'Currently Vesting', active.length),
            const SizedBox(height: 8),
            ...active.map(
              (s) => _HoursVestingCard(schedule: s, provider: provider),
            ),
            const SizedBox(height: 24),
          ],

          // Fully Vested
          if (fullyVested.isNotEmpty) ...[
            _buildSectionHeader(context, 'Fully Vested', fullyVested.length),
            const SizedBox(height: 8),
            ...fullyVested.map(
              (s) => _HoursVestingCard(schedule: s, provider: provider),
            ),
          ],

          // Space for FAB
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}

class _HoursSummaryCard extends StatelessWidget {
  final List<HoursVestingSchedule> schedules;
  final CapTableProvider provider;

  const _HoursSummaryCard({required this.schedules, required this.provider});

  @override
  Widget build(BuildContext context) {
    final totalHoursLogged = schedules.fold<double>(
      0,
      (sum, s) => sum + s.hoursLogged,
    );
    final totalHoursCommitted = schedules.fold<double>(
      0,
      (sum, s) => sum + s.totalHoursCommitment,
    );
    final vestedEquity = schedules.fold<double>(
      0,
      (sum, s) => sum + (s.totalEquityPercent * s.progress),
    );

    final activeCount = schedules.where((s) => s.progress < 1.0).length;
    final vestedCount = schedules.where((s) => s.progress >= 1.0).length;

    return SectionCard(
      title: 'Hours Summary',
      icon: Icons.access_time,
      helpKey: 'vesting.hours',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: MiniStat(
                  label: 'Total Schedules',
                  value: schedules.length.toString(),
                ),
              ),
              Expanded(
                child: MiniStat(label: 'Active', value: activeCount.toString()),
              ),
              Expanded(
                child: MiniStat(
                  label: 'Complete',
                  value: vestedCount.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: MiniStat(
                  label: 'Hours Logged',
                  value: totalHoursLogged.toStringAsFixed(1),
                ),
              ),
              Expanded(
                child: MiniStat(
                  label: 'Committed',
                  value: totalHoursCommitted.toStringAsFixed(0),
                ),
              ),
              Expanded(
                child: MiniStat(
                  label: 'Equity Vested',
                  value: '${vestedEquity.toStringAsFixed(2)}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HoursVestingCard extends StatelessWidget {
  final HoursVestingSchedule schedule;
  final CapTableProvider provider;

  const _HoursVestingCard({required this.schedule, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final investor = provider.getInvestorById(schedule.investorId);

    // Status color
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

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: InvestorAvatar(
          name: investor?.name ?? '?',
          type: investor?.type,
        ),
        title: Text(
          investor?.name ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            // Progress indicator
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: schedule.progress,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      color: statusColor,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${schedule.hoursLogged.toStringAsFixed(1)} / ${schedule.totalHoursCommitment} hours',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: ResultChip(
                        label: 'Curve',
                        value: schedule.curveTypeDisplayName,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Details
                _buildDetailRow(
                  context,
                  'Start Date',
                  Formatters.date(schedule.startDate),
                ),
                if (schedule.cliffHours != null)
                  _buildDetailRow(
                    context,
                    'Cliff Hours',
                    '${schedule.cliffHours} hours',
                  ),
                if (schedule.bonusMilestones.isNotEmpty)
                  _buildDetailRow(
                    context,
                    'Bonus Milestones',
                    '${schedule.bonusMilestones.length} bonus${schedule.bonusMilestones.length > 1 ? 'es' : ''}',
                  ),

                // Recent activity
                if (schedule.logEntries.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Recent Activity',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...schedule.logEntries
                      .take(5)
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                Formatters.date(e.date),
                                style: theme.textTheme.bodySmall,
                              ),
                              Text(
                                '+${e.hours.toStringAsFixed(1)}h',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ],

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showLogHoursDialog(context),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Log Hours'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _showDeleteDialog(context),
                      icon: Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.error,
                      ),
                      label: Text(
                        'Delete',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

  void _showLogHoursDialog(BuildContext context) {
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
                    if (picked != null) {
                      setState(() => date = picked);
                    }
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

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: const Text(
          'Are you sure you want to delete this hours vesting schedule? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              provider.deleteHoursVestingSchedule(schedule.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
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
  String? _shareholdingId;
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
      _shareholdingId = s.shareholdingId;
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
                _shareholdingId = null;
              }),
            ),
            if (investorTransactions.isNotEmpty) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _shareholdingId,
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
                onChanged: (v) => setState(() => _shareholdingId = v),
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
        _shareholdingId != null &&
        _equityController.text.isNotEmpty &&
        _hoursController.text.isNotEmpty;
  }

  void _save() {
    final schedule = HoursVestingSchedule(
      id: widget.schedule?.id,
      investorId: _investorId!,
      shareholdingId: _shareholdingId!,
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

class _VestingSummaryCard extends StatelessWidget {
  final List<VestingSchedule> vestingSchedules;
  final CapTableProvider provider;

  const _VestingSummaryCard({
    required this.vestingSchedules,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate totals
    int totalSharesUnderVesting = 0;
    int totalVestedShares = 0;
    int totalUnvestedShares = 0;

    for (final schedule in vestingSchedules) {
      try {
        final transaction = provider.transactions.firstWhere(
          (t) => t.id == schedule.shareholdingId,
        );
        totalSharesUnderVesting += transaction.numberOfShares;
        final vested =
            (transaction.numberOfShares * schedule.vestingPercentage / 100)
                .round();
        totalVestedShares += vested;
        totalUnvestedShares += transaction.numberOfShares - vested;
      } catch (_) {
        // Transaction not found
      }
    }

    final activeCount = vestingSchedules
        .where((v) => v.leaverStatus == LeaverStatus.active)
        .length;
    final vestedCount = vestingSchedules
        .where((v) => v.vestingPercentage >= 100)
        .length;

    return SectionCard(
      title: 'Vesting Summary',
      icon: Icons.schedule,
      helpKey: 'vesting.vesting',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: MiniStat(
                  label: 'Total Schedules',
                  value: vestingSchedules.length.toString(),
                ),
              ),
              Expanded(
                child: MiniStat(label: 'Active', value: activeCount.toString()),
              ),
              Expanded(
                child: MiniStat(
                  label: 'Fully Vested',
                  value: vestedCount.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: MiniStat(
                  label: 'Shares Under Vesting',
                  value: Formatters.number(totalSharesUnderVesting),
                ),
              ),
              Expanded(
                child: MiniStat(
                  label: 'Vested',
                  value: Formatters.number(totalVestedShares),
                ),
              ),
              Expanded(
                child: MiniStat(
                  label: 'Unvested',
                  value: Formatters.number(totalUnvestedShares),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VestingCard extends StatelessWidget {
  final VestingSchedule schedule;
  final CapTableProvider provider;

  const _VestingCard({required this.schedule, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get related data
    Transaction? transaction;
    Investor? investor;
    try {
      transaction = provider.transactions.firstWhere(
        (t) => t.id == schedule.shareholdingId,
      );
      investor = provider.getInvestorById(transaction.investorId);
    } catch (_) {}

    if (transaction == null || investor == null) {
      return const SizedBox.shrink();
    }

    final round = provider.getRoundById(transaction.roundId ?? '');
    final vestedShares =
        (transaction.numberOfShares * schedule.vestingPercentage / 100).round();
    final unvestedShares = transaction.numberOfShares - vestedShares;

    // Status color
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
        break;
      case LeaverStatus.goodLeaver:
        statusColor = Colors.amber;
        statusText = 'Good Leaver';
        break;
      case LeaverStatus.badLeaver:
        statusColor = Colors.red;
        statusText = 'Bad Leaver';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: InvestorAvatar(name: investor.name, type: investor.type),
        title: Text(
          investor.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            // Progress indicator
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: schedule.vestingPercentage / 100,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      color: statusColor,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${Formatters.percent(schedule.vestingPercentage)} vested',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shares info
                Row(
                  children: [
                    Expanded(
                      child: ResultChip(
                        label: 'Total Shares',
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

                // Schedule details
                _buildDetailRow(context, 'Round', round?.name ?? 'Unknown'),
                _buildDetailRow(
                  context,
                  'Vesting Type',
                  _getVestingTypeLabel(schedule.type),
                ),
                _buildDetailRow(
                  context,
                  'Schedule',
                  '${schedule.vestingPeriodMonths} months with ${schedule.cliffMonths} month cliff',
                ),
                _buildDetailRow(
                  context,
                  'Frequency',
                  _getFrequencyLabel(schedule.frequency),
                ),
                _buildDetailRow(
                  context,
                  'Start Date',
                  Formatters.date(schedule.startDate),
                ),
                _buildDetailRow(
                  context,
                  'Cliff Date',
                  Formatters.date(schedule.cliffDate),
                ),
                _buildDetailRow(
                  context,
                  'End Date',
                  Formatters.date(schedule.endDate),
                ),
                if (schedule.nextVestingDate != null)
                  _buildDetailRow(
                    context,
                    'Next Vesting',
                    Formatters.date(schedule.nextVestingDate!),
                  ),
                if (schedule.accelerationPercent > 0)
                  _buildDetailRow(
                    context,
                    'Acceleration',
                    '${schedule.accelerationPercent.toStringAsFixed(0)}% on liquidity event',
                  ),
                if (schedule.terminationDate != null)
                  _buildDetailRow(
                    context,
                    'Termination Date',
                    Formatters.date(schedule.terminationDate!),
                  ),
                if (schedule.notes != null && schedule.notes!.isNotEmpty)
                  _buildDetailRow(context, 'Notes', schedule.notes!),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (schedule.leaverStatus == LeaverStatus.active) ...[
                      TextButton.icon(
                        onPressed: () => _showTerminateDialog(context),
                        icon: const Icon(Icons.person_off_outlined),
                        label: const Text('Terminate'),
                      ),
                      const SizedBox(width: 8),
                    ],
                    TextButton.icon(
                      onPressed: () => _showEditDialog(context),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _showDeleteDialog(context),
                      icon: Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.error,
                      ),
                      label: Text(
                        'Delete',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => VestingScheduleDialog(
        transactions: provider.transactions
            .where((t) => t.isAcquisition)
            .toList(),
        provider: provider,
        existingSchedule: schedule,
      ),
    );
  }

  void _showTerminateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          _TerminateVestingDialog(schedule: schedule, provider: provider),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vesting Schedule'),
        content: const Text(
          'Are you sure you want to delete this vesting schedule? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              provider.deleteVestingSchedule(schedule.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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

  const VestingScheduleDialog({
    super.key,
    required this.transactions,
    required this.provider,
    this.existingSchedule,
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
        existing?.shareholdingId ??
        (widget.transactions.isNotEmpty ? widget.transactions.first.id : null);
    _vestingType = existing?.type ?? VestingType.timeBased;
    _startDate = existing?.startDate ?? DateTime.now();
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
                      setState(() => _selectedTransactionId = value);
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
      shareholdingId: _selectedTransactionId!,
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
