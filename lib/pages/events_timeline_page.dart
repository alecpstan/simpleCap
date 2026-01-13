import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cap_table_provider.dart';
import '../models/transaction.dart';
import '../models/convertible_instrument.dart';
import '../widgets/section_card.dart';
import '../utils/helpers.dart';

/// Event types for the timeline
enum TimelineEventType {
  transaction,
  round,
  milestone,
  vestingEvent,
  convertibleEvent,
}

/// Unified event model for timeline display
class TimelineEvent {
  final String id;
  final DateTime date;
  final TimelineEventType type;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Map<String, dynamic> metadata;

  TimelineEvent({
    required this.id,
    required this.date,
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.metadata = const {},
  });
}

class EventsTimelinePage extends StatefulWidget {
  const EventsTimelinePage({super.key});

  @override
  State<EventsTimelinePage> createState() => _EventsTimelinePageState();
}

class _EventsTimelinePageState extends State<EventsTimelinePage> {
  Set<TimelineEventType> _selectedFilters = TimelineEventType.values.toSet();
  bool _sortDescending = true; // Newest first by default
  String? _selectedInvestorId;

  @override
  Widget build(BuildContext context) {
    return Consumer<CapTableProvider>(
      builder: (context, provider, child) {
        final events = _buildEvents(provider);
        final filteredEvents = _filterEvents(events);
        final sortedEvents = _sortEvents(filteredEvents);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Events Timeline'),
            actions: [
              IconButton(
                icon: Icon(
                  _sortDescending ? Icons.arrow_downward : Icons.arrow_upward,
                ),
                tooltip: _sortDescending ? 'Newest first' : 'Oldest first',
                onPressed: () {
                  setState(() {
                    _sortDescending = !_sortDescending;
                  });
                },
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filter events',
                onSelected: (value) {
                  if (value == 'all') {
                    setState(() {
                      _selectedFilters = TimelineEventType.values.toSet();
                    });
                  } else if (value == 'none') {
                    setState(() {
                      _selectedFilters = {};
                    });
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'all', child: Text('Show All')),
                  const PopupMenuItem(
                    value: 'none',
                    child: Text('Clear Filters'),
                  ),
                  const PopupMenuDivider(),
                  ...TimelineEventType.values.map(
                    (type) => PopupMenuItem(
                      value: type.name,
                      child: Row(
                        children: [
                          Checkbox(
                            value: _selectedFilters.contains(type),
                            onChanged: (checked) {
                              setState(() {
                                if (checked == true) {
                                  _selectedFilters.add(type);
                                } else {
                                  _selectedFilters.remove(type);
                                }
                              });
                              Navigator.pop(context);
                            },
                          ),
                          Text(_getEventTypeName(type)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: sortedEvents.isEmpty
              ? _buildEmptyState()
              : _buildTimeline(sortedEvents, provider),
        );
      },
    );
  }

  List<TimelineEvent> _buildEvents(CapTableProvider provider) {
    final events = <TimelineEvent>[];

    // Add investment rounds (with investments grouped inside)
    for (final round in provider.rounds) {
      final amountRaised = provider.getAmountRaisedByRound(round.id);
      final investments = provider.getInvestmentsByRound(round.id);
      final pps =
          round.pricePerShare ??
          provider.getImpliedPricePerShare(round.id) ??
          0.0;
      final postMoney = round.preMoneyValuation + amountRaised;

      events.add(
        TimelineEvent(
          id: 'round_${round.id}',
          date: round.date,
          type: TimelineEventType.round,
          title: '${round.name} Round',
          description:
              'Raised ${Formatters.currency(amountRaised)} at ${Formatters.currency(postMoney)} post-money'
              ' (${Formatters.currency(pps)}/share)',
          icon: Icons.trending_up,
          color: Colors.green,
          metadata: {
            'roundId': round.id,
            'pricePerShare': pps,
            'valuation': postMoney,
            'amountRaised': amountRaised,
            'investments': investments,
          },
        ),
      );
    }

    // Add non-round transactions (transfers, exercises, sales, etc.)
    for (final transaction in provider.transactions) {
      // Skip purchase transactions that belong to a round (they're grouped under rounds)
      if (transaction.type == TransactionType.purchase &&
          transaction.roundId != null) {
        continue;
      }

      final investor = provider.getInvestorById(transaction.investorId);
      final shareClass = provider.getShareClassById(transaction.shareClassId);

      events.add(
        TimelineEvent(
          id: 'txn_${transaction.id}',
          date: transaction.date,
          type: TimelineEventType.transaction,
          title: transaction.typeDisplayName,
          description:
              '${investor?.name ?? 'Unknown'}: ${Formatters.number(transaction.numberOfShares)} ${shareClass?.name ?? 'shares'}'
              ' @ ${Formatters.currency(transaction.pricePerShare)}/share',
          icon: _getTransactionIcon(transaction.type),
          color: _getTransactionColor(transaction.type),
          metadata: {
            'transactionId': transaction.id,
            'investorId': transaction.investorId,
            'amount': transaction.totalAmount,
          },
        ),
      );
    }

    // Add milestones
    for (final milestone in provider.milestones) {
      // Use deadline if set, otherwise use completed date, fallback to now
      final eventDate =
          milestone.deadline ?? milestone.completedDate ?? DateTime.now();
      events.add(
        TimelineEvent(
          id: 'milestone_${milestone.id}',
          date: eventDate,
          type: TimelineEventType.milestone,
          title: milestone.name,
          description: milestone.description ?? 'Milestone event',
          icon: milestone.isCompleted ? Icons.check_circle : Icons.flag,
          color: milestone.isCompleted ? Colors.green : Colors.orange,
          metadata: {
            'milestoneId': milestone.id,
            'isCompleted': milestone.isCompleted,
            'equityPercent': milestone.equityPercent,
          },
        ),
      );
    }

    // Add vesting events (cliff dates, vesting completion)
    for (final schedule in provider.vestingSchedules) {
      // Add cliff event
      events.add(
        TimelineEvent(
          id: 'cliff_${schedule.id}',
          date: schedule.cliffDate,
          type: TimelineEventType.vestingEvent,
          title: 'Cliff Date',
          description:
              'Vesting cliff reached for schedule starting ${Formatters.date(schedule.startDate)}',
          icon: Icons.access_time,
          color: schedule.cliffPassed ? Colors.blue : Colors.grey,
          metadata: {
            'scheduleId': schedule.id,
            'transactionId': schedule.transactionId,
            'cliffPassed': schedule.cliffPassed,
          },
        ),
      );

      // Add end date
      events.add(
        TimelineEvent(
          id: 'vested_${schedule.id}',
          date: schedule.endDate,
          type: TimelineEventType.vestingEvent,
          title: 'Fully Vested',
          description:
              'Schedule completion for vesting started ${Formatters.date(schedule.startDate)}',
          icon: Icons.celebration,
          color: schedule.vestingPercentage >= 100
              ? Colors.purple
              : Colors.grey,
          metadata: {
            'scheduleId': schedule.id,
            'vestingPercentage': schedule.vestingPercentage,
          },
        ),
      );
    }

    // Add convertible events
    for (final convertible in provider.convertibles) {
      // Issue date
      events.add(
        TimelineEvent(
          id: 'conv_issue_${convertible.id}',
          date: convertible.issueDate,
          type: TimelineEventType.convertibleEvent,
          title:
              '${convertible.type == ConvertibleType.safe ? 'SAFE' : 'Convertible Note'} Issued',
          description:
              '${Formatters.currency(convertible.principalAmount)} from ${provider.getInvestorById(convertible.investorId)?.name ?? 'Unknown'}',
          icon: Icons.receipt_long,
          color: Colors.teal,
          metadata: {
            'convertibleId': convertible.id,
            'type': convertible.type.name,
            'principal': convertible.principalAmount,
          },
        ),
      );

      // Maturity date (for notes)
      if (convertible.maturityDate != null) {
        final isPastDue =
            convertible.maturityDate!.isBefore(DateTime.now()) &&
            convertible.status == ConvertibleStatus.outstanding;
        events.add(
          TimelineEvent(
            id: 'conv_maturity_${convertible.id}',
            date: convertible.maturityDate!,
            type: TimelineEventType.convertibleEvent,
            title: 'Convertible Maturity',
            description:
                'Maturity date for ${Formatters.currency(convertible.principalAmount)} ${convertible.type.name}',
            icon: Icons.event,
            color: isPastDue ? Colors.red : Colors.amber,
            metadata: {
              'convertibleId': convertible.id,
              'status': convertible.status.name,
            },
          ),
        );
      }

      // Conversion date (if converted)
      if (convertible.conversionDate != null) {
        events.add(
          TimelineEvent(
            id: 'conv_convert_${convertible.id}',
            date: convertible.conversionDate!,
            type: TimelineEventType.convertibleEvent,
            title: 'Convertible Converted',
            description:
                '${Formatters.currency(convertible.convertibleAmount)} converted to equity',
            icon: Icons.swap_horiz,
            color: Colors.green,
            metadata: {
              'convertibleId': convertible.id,
              'convertibleAmount': convertible.convertibleAmount,
            },
          ),
        );
      }
    }

    return events;
  }

  List<TimelineEvent> _filterEvents(List<TimelineEvent> events) {
    var filtered = events.where((e) => _selectedFilters.contains(e.type));

    if (_selectedInvestorId != null) {
      filtered = filtered.where(
        (e) => e.metadata['investorId'] == _selectedInvestorId,
      );
    }

    return filtered.toList();
  }

  List<TimelineEvent> _sortEvents(List<TimelineEvent> events) {
    final sorted = List<TimelineEvent>.from(events);
    sorted.sort(
      (a, b) =>
          _sortDescending ? b.date.compareTo(a.date) : a.date.compareTo(b.date),
    );
    return sorted;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timeline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No events to display',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Add transactions, rounds, or milestones to see them here',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(List<TimelineEvent> events, CapTableProvider provider) {
    // Group events by month/year
    final groupedEvents = <String, List<TimelineEvent>>{};
    for (final event in events) {
      final key =
          '${event.date.year}-${event.date.month.toString().padLeft(2, '0')}';
      groupedEvents.putIfAbsent(key, () => []);
      groupedEvents[key]!.add(event);
    }

    final sortedKeys = groupedEvents.keys.toList()
      ..sort((a, b) => _sortDescending ? b.compareTo(a) : a.compareTo(b));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final key = sortedKeys[index];
        final monthEvents = groupedEvents[key]!;
        final date = DateTime(
          int.parse(key.split('-')[0]),
          int.parse(key.split('-')[1]),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _formatMonthYear(date),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            // Events for this month
            ...monthEvents.map((event) => _buildEventCard(event, provider)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildEventCard(TimelineEvent event, CapTableProvider provider) {
    // For rounds, show grouped investments
    final investments = event.metadata['investments'] as List<Transaction>?;
    final hasInvestments =
        event.type == TimelineEventType.round &&
        investments != null &&
        investments.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: hasInvestments
          ? _buildRoundEventCard(event, provider, investments)
          : _buildSimpleEventCard(event, provider),
    );
  }

  Widget _buildSimpleEventCard(TimelineEvent event, CapTableProvider provider) {
    return InkWell(
      onTap: () => _showEventDetails(event, provider),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: _buildEventContent(event),
      ),
    );
  }

  Widget _buildRoundEventCard(
    TimelineEvent event,
    CapTableProvider provider,
    List<Transaction> investments,
  ) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: const EdgeInsets.only(left: 44, right: 12, bottom: 12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: event.color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(event.icon, color: event.color, size: 24),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                event.title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            _buildEventTypeBadge(event.type),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              event.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  Formatters.date(event.date),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${investments.length} investment${investments.length > 1 ? "s" : ""}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        children: investments.map((txn) {
          final investor = provider.getInvestorById(txn.investorId);
          final shareClass = provider.getShareClassById(txn.shareClassId);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  child: Text(
                    investor?.name.substring(0, 1) ?? '?',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        investor?.name ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${Formatters.number(txn.numberOfShares)} ${shareClass?.name ?? 'shares'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  Formatters.currency(txn.totalAmount),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEventContent(TimelineEvent event) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon with timeline connector
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: event.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(event.icon, color: event.color, size: 24),
            ),
          ],
        ),
        const SizedBox(width: 12),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildEventTypeBadge(event.type),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                event.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                Formatters.date(event.date),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventTypeBadge(TimelineEventType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getEventTypeColor(type).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getEventTypeName(type),
        style: TextStyle(
          fontSize: 10,
          color: _getEventTypeColor(type),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showEventDetails(TimelineEvent event, CapTableProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: event.color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(event.icon, color: event.color, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            Formatters.date(event.date),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Description
                SectionCard(title: 'Details', child: Text(event.description)),
                const SizedBox(height: 16),
                // Metadata
                if (event.metadata.isNotEmpty) ...[
                  SectionCard(
                    title: 'Additional Info',
                    child: Column(
                      children: event.metadata.entries
                          .where((e) => e.value != null)
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatMetadataKey(e.key),
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  Text(
                                    _formatMetadataValue(e.value),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.purchase:
        return Icons.add_shopping_cart;
      case TransactionType.secondarySale:
        return Icons.swap_horiz;
      case TransactionType.buyback:
        return Icons.replay;
      case TransactionType.secondaryPurchase:
        return Icons.shopping_bag;
      case TransactionType.grant:
        return Icons.card_giftcard;
      case TransactionType.optionExercise:
        return Icons.fitness_center;
      case TransactionType.conversion:
        return Icons.transform;
      case TransactionType.reequitization:
        return Icons.balance;
    }
  }

  Color _getTransactionColor(TransactionType type) {
    switch (type) {
      case TransactionType.purchase:
        return Colors.green;
      case TransactionType.secondarySale:
        return Colors.orange;
      case TransactionType.buyback:
        return Colors.red;
      case TransactionType.secondaryPurchase:
        return Colors.blue;
      case TransactionType.grant:
        return Colors.purple;
      case TransactionType.optionExercise:
        return Colors.teal;
      case TransactionType.conversion:
        return Colors.indigo;
      case TransactionType.reequitization:
        return Colors.amber;
    }
  }

  String _getEventTypeName(TimelineEventType type) {
    switch (type) {
      case TimelineEventType.transaction:
        return 'Transaction';
      case TimelineEventType.round:
        return 'Round';
      case TimelineEventType.milestone:
        return 'Milestone';
      case TimelineEventType.vestingEvent:
        return 'Vesting';
      case TimelineEventType.convertibleEvent:
        return 'Convertible';
    }
  }

  Color _getEventTypeColor(TimelineEventType type) {
    switch (type) {
      case TimelineEventType.transaction:
        return Colors.blue;
      case TimelineEventType.round:
        return Colors.green;
      case TimelineEventType.milestone:
        return Colors.orange;
      case TimelineEventType.vestingEvent:
        return Colors.purple;
      case TimelineEventType.convertibleEvent:
        return Colors.teal;
    }
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatMetadataKey(String key) {
    // Convert camelCase to Title Case
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatMetadataValue(dynamic value) {
    if (value is double) {
      if (value > 1000) return Formatters.currency(value);
      return value.toStringAsFixed(2);
    }
    if (value is bool) return value ? 'Yes' : 'No';
    if (value is int) return Formatters.number(value);
    return value.toString();
  }
}
