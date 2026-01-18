import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/providers/providers.dart';
import '../../domain/events/cap_table_event.dart';
import '../components/feedback/info_box.dart';

/// A timeline view of all events, sorted by date and grouped by month.
class TimelinePage extends ConsumerStatefulWidget {
  const TimelinePage({super.key});

  @override
  ConsumerState<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends ConsumerState<TimelinePage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _sortNewestFirst = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventsAsync = ref.watch(eventsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline'),
        actions: [
          IconButton(
            icon: Icon(
              _sortNewestFirst ? Icons.arrow_downward : Icons.arrow_upward,
            ),
            tooltip: _sortNewestFirst ? 'Newest first' : 'Oldest first',
            onPressed: () =>
                setState(() => _sortNewestFirst = !_sortNewestFirst),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) =>
                  setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          // Events list
          Expanded(
            child: eventsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: InfoBox.error(message: 'Failed to load events: $e'),
              ),
              data: (events) {
                if (events.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No events yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Events will appear here as you make changes',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Filter events
                final filteredEvents = _searchQuery.isEmpty
                    ? events
                    : events.where((e) => _matchesSearch(e)).toList();

                // Sort events
                final sortedEvents = List<CapTableEvent>.from(filteredEvents);
                sortedEvents.sort((a, b) {
                  final aTime = _getTimestamp(a);
                  final bTime = _getTimestamp(b);
                  return _sortNewestFirst
                      ? bTime.compareTo(aTime)
                      : aTime.compareTo(bTime);
                });

                // Group by month
                final groupedEvents = _groupByMonth(sortedEvents);

                if (filteredEvents.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No matching events',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: groupedEvents.length,
                  itemBuilder: (context, index) {
                    final entry = groupedEvents.entries.elementAt(index);
                    return _MonthSection(
                      monthLabel: entry.key,
                      events: entry.value,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _matchesSearch(CapTableEvent event) {
    final searchLower = _searchQuery.toLowerCase();
    final eventType = _getEventTypeLabel(event).toLowerCase();
    final description = _getEventDescription(event).toLowerCase();
    final actor = _getActorId(event)?.toLowerCase() ?? '';

    return eventType.contains(searchLower) ||
        description.contains(searchLower) ||
        actor.contains(searchLower);
  }

  Map<String, List<CapTableEvent>> _groupByMonth(List<CapTableEvent> events) {
    final grouped = <String, List<CapTableEvent>>{};
    final monthFormat = DateFormat('MMMM yyyy');

    for (final event in events) {
      final timestamp = _getTimestamp(event);
      final monthKey = monthFormat.format(timestamp);

      grouped.putIfAbsent(monthKey, () => []).add(event);
    }

    return grouped;
  }
}

/// A section showing events for a specific month.
class _MonthSection extends StatelessWidget {
  final String monthLabel;
  final List<CapTableEvent> events;

  const _MonthSection({required this.monthLabel, required this.events});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            monthLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...events.map(
          (event) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _EventCard(event: event),
          ),
        ),
      ],
    );
  }
}

/// A card showing a single event.
class _EventCard extends StatelessWidget {
  final CapTableEvent event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = _getEventCategory(event);
    final color = _getCategoryColor(category);
    final icon = _getCategoryIcon(category);
    final typeLabel = _getEventTypeLabel(event);
    final description = _getEventDescription(event);
    final timestamp = _getTimestamp(event);
    final actor = _getActorId(event);
    final timeFormat = DateFormat('MMM d, yyyy • h:mm a');
    final isDraft = _isDraftEvent(event);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      typeLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeFormat.format(timestamp),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    if (actor != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'by $actor',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (isDraft)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Draft',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Helper functions
// ===========================================================================

/// Returns true if the event represents creating or entering a draft/pending state.
bool _isDraftEvent(CapTableEvent event) {
  return event.map(
    // Rounds start as draft when opened, and return to draft when reopened
    roundOpened: (_) => true,
    roundReopened: (_) => true,
    // ESOP pools are draft only when created via round builder (with roundId)
    esopPoolCreated: (e) => e.roundId != null,
    // Transfers start as pending when initiated
    transferInitiated: (_) => true,
    // Warrants start as pending when issued
    warrantIssued: (_) => true,
    // All other events are not draft states
    companyCreated: (_) => false,
    companyRenamed: (_) => false,
    stakeholderAdded: (_) => false,
    stakeholderUpdated: (_) => false,
    stakeholderRemoved: (_) => false,
    shareClassCreated: (_) => false,
    shareClassUpdated: (_) => false,
    roundClosed: (_) => false,
    roundAmended: (_) => false,
    roundDeleted: (_) => false,
    sharesIssued: (_) => false,
    sharesTransferred: (_) => false,
    sharesRepurchased: (_) => false,
    holdingDeleted: (_) => false,
    holdingUpdated: (_) => false,
    holdingVestingUpdated: (_) => false,
    convertibleIssued: (_) => false,
    mfnUpgradeApplied: (_) => false,
    convertibleConverted: (_) => false,
    convertibleCancelled: (_) => false,
    convertibleUpdated: (_) => false,
    esopPoolExpanded: (_) => false,
    esopPoolActivated: (_) => false,
    esopPoolUpdated: (_) => false,
    esopPoolDeleted: (_) => false,
    esopPoolExpansionReverted: (_) => false,
    optionGranted: (_) => false,
    optionGrantUpdated: (_) => false,
    optionsVested: (_) => false,
    optionsExercised: (_) => false,
    optionsCancelled: (_) => false,
    optionGrantStatusChanged: (_) => false,
    warrantExercised: (_) => false,
    warrantCancelled: (_) => false,
    warrantUpdated: (_) => false,
    warrantUnexercised: (_) => false,
    warrantStatusChanged: (_) => false,
    vestingScheduleCreated: (_) => false,
    vestingScheduleUpdated: (_) => false,
    vestingScheduleDeleted: (_) => false,
    valuationRecorded: (_) => false,
    valuationDeleted: (_) => false,
    transferRofrWaived: (_) => false,
    transferExecuted: (_) => false,
    transferCancelled: (_) => false,
    mfnUpgradeReverted: (_) => false,
    scenarioSaved: (_) => false,
    scenarioDeleted: (_) => false,
  );
}

/// Event category for color coding.
enum _EventCategory {
  company,
  stakeholder,
  shareClass,
  round,
  holding,
  convertible,
  esop,
  option,
  warrant,
  vesting,
  valuation,
  transfer,
  scenario,
}

_EventCategory _getEventCategory(CapTableEvent event) {
  return event.map(
    companyCreated: (_) => _EventCategory.company,
    companyRenamed: (_) => _EventCategory.company,
    stakeholderAdded: (_) => _EventCategory.stakeholder,
    stakeholderUpdated: (_) => _EventCategory.stakeholder,
    stakeholderRemoved: (_) => _EventCategory.stakeholder,
    shareClassCreated: (_) => _EventCategory.shareClass,
    shareClassUpdated: (_) => _EventCategory.shareClass,
    roundOpened: (_) => _EventCategory.round,
    roundClosed: (_) => _EventCategory.round,
    roundAmended: (_) => _EventCategory.round,
    roundReopened: (_) => _EventCategory.round,
    roundDeleted: (_) => _EventCategory.round,
    sharesIssued: (_) => _EventCategory.holding,
    sharesTransferred: (_) => _EventCategory.holding,
    sharesRepurchased: (_) => _EventCategory.holding,
    holdingDeleted: (_) => _EventCategory.holding,
    holdingUpdated: (_) => _EventCategory.holding,
    holdingVestingUpdated: (_) => _EventCategory.holding,
    convertibleIssued: (_) => _EventCategory.convertible,
    mfnUpgradeApplied: (_) => _EventCategory.convertible,
    convertibleConverted: (_) => _EventCategory.convertible,
    convertibleCancelled: (_) => _EventCategory.convertible,
    convertibleUpdated: (_) => _EventCategory.convertible,
    esopPoolCreated: (_) => _EventCategory.esop,
    esopPoolExpanded: (_) => _EventCategory.esop,
    esopPoolActivated: (_) => _EventCategory.esop,
    esopPoolUpdated: (_) => _EventCategory.esop,
    esopPoolDeleted: (_) => _EventCategory.esop,
    esopPoolExpansionReverted: (_) => _EventCategory.esop,
    optionGranted: (_) => _EventCategory.option,
    optionGrantUpdated: (_) => _EventCategory.option,
    optionsVested: (_) => _EventCategory.option,
    optionsExercised: (_) => _EventCategory.option,
    optionsCancelled: (_) => _EventCategory.option,
    optionGrantStatusChanged: (_) => _EventCategory.option,
    warrantIssued: (_) => _EventCategory.warrant,
    warrantExercised: (_) => _EventCategory.warrant,
    warrantCancelled: (_) => _EventCategory.warrant,
    warrantUpdated: (_) => _EventCategory.warrant,
    warrantUnexercised: (_) => _EventCategory.warrant,
    warrantStatusChanged: (_) => _EventCategory.warrant,
    vestingScheduleCreated: (_) => _EventCategory.vesting,
    vestingScheduleUpdated: (_) => _EventCategory.vesting,
    vestingScheduleDeleted: (_) => _EventCategory.vesting,
    valuationRecorded: (_) => _EventCategory.valuation,
    valuationDeleted: (_) => _EventCategory.valuation,
    transferInitiated: (_) => _EventCategory.transfer,
    transferRofrWaived: (_) => _EventCategory.transfer,
    transferExecuted: (_) => _EventCategory.transfer,
    transferCancelled: (_) => _EventCategory.transfer,
    mfnUpgradeReverted: (_) => _EventCategory.convertible,
    scenarioSaved: (_) => _EventCategory.scenario,
    scenarioDeleted: (_) => _EventCategory.scenario,
  );
}

Color _getCategoryColor(_EventCategory category) {
  switch (category) {
    case _EventCategory.company:
      return Colors.blue;
    case _EventCategory.stakeholder:
      return Colors.green;
    case _EventCategory.shareClass:
      return Colors.purple;
    case _EventCategory.round:
      return Colors.amber;
    case _EventCategory.holding:
      return Colors.teal;
    case _EventCategory.convertible:
      return Colors.deepOrange;
    case _EventCategory.esop:
      return Colors.indigo;
    case _EventCategory.option:
      return Colors.orange;
    case _EventCategory.warrant:
      return Colors.cyan;
    case _EventCategory.vesting:
      return Colors.pink;
    case _EventCategory.valuation:
      return Colors.blueGrey;
    case _EventCategory.transfer:
      return Colors.lime;
    case _EventCategory.scenario:
      return Colors.deepPurple;
  }
}

IconData _getCategoryIcon(_EventCategory category) {
  switch (category) {
    case _EventCategory.company:
      return Icons.business;
    case _EventCategory.stakeholder:
      return Icons.people;
    case _EventCategory.shareClass:
      return Icons.category;
    case _EventCategory.round:
      return Icons.attach_money;
    case _EventCategory.holding:
      return Icons.inventory;
    case _EventCategory.convertible:
      return Icons.receipt_long;
    case _EventCategory.esop:
      return Icons.account_balance_wallet;
    case _EventCategory.option:
      return Icons.card_giftcard;
    case _EventCategory.warrant:
      return Icons.receipt;
    case _EventCategory.vesting:
      return Icons.schedule;
    case _EventCategory.valuation:
      return Icons.assessment;
    case _EventCategory.transfer:
      return Icons.swap_horiz;
    case _EventCategory.scenario:
      return Icons.calculate;
  }
}

String _getEventTypeLabel(CapTableEvent event) {
  return event.map(
    companyCreated: (_) => 'Company Created',
    companyRenamed: (_) => 'Company Renamed',
    stakeholderAdded: (_) => 'Stakeholder Added',
    stakeholderUpdated: (_) => 'Stakeholder Updated',
    stakeholderRemoved: (_) => 'Stakeholder Removed',
    shareClassCreated: (_) => 'Share Class Created',
    shareClassUpdated: (_) => 'Share Class Updated',
    roundOpened: (_) => 'Round Opened',
    roundClosed: (_) => 'Round Closed',
    roundAmended: (_) => 'Round Amended',
    roundReopened: (_) => 'Round Reopened',
    roundDeleted: (_) => 'Round Deleted',
    sharesIssued: (_) => 'Shares Issued',
    sharesTransferred: (_) => 'Shares Transferred',
    sharesRepurchased: (_) => 'Shares Repurchased',
    holdingDeleted: (_) => 'Holding Deleted',
    holdingUpdated: (_) => 'Holding Updated',
    holdingVestingUpdated: (_) => 'Vesting Updated',
    convertibleIssued: (_) => 'Convertible Issued',
    mfnUpgradeApplied: (_) => 'MFN Upgrade Applied',
    convertibleConverted: (_) => 'Convertible Converted',
    convertibleCancelled: (_) => 'Convertible Cancelled',
    convertibleUpdated: (_) => 'Convertible Updated',
    esopPoolCreated: (_) => 'ESOP Pool Created',
    esopPoolExpanded: (_) => 'ESOP Pool Expanded',
    esopPoolActivated: (_) => 'ESOP Pool Activated',
    esopPoolUpdated: (_) => 'ESOP Pool Updated',
    esopPoolDeleted: (_) => 'ESOP Pool Deleted',
    esopPoolExpansionReverted: (_) => 'Pool Expansion Reverted',
    optionGranted: (_) => 'Option Granted',
    optionGrantUpdated: (_) => 'Option Grant Updated',
    optionsVested: (_) => 'Options Vested',
    optionsExercised: (_) => 'Options Exercised',
    optionsCancelled: (_) => 'Options Cancelled',
    optionGrantStatusChanged: (_) => 'Grant Status Changed',
    warrantIssued: (_) => 'Warrant Issued',
    warrantExercised: (_) => 'Warrant Exercised',
    warrantCancelled: (_) => 'Warrant Cancelled',
    warrantUpdated: (_) => 'Warrant Updated',
    warrantUnexercised: (_) => 'Warrant Unexercised',
    warrantStatusChanged: (_) => 'Warrant Status Changed',
    vestingScheduleCreated: (_) => 'Vesting Schedule Created',
    vestingScheduleUpdated: (_) => 'Vesting Schedule Updated',
    vestingScheduleDeleted: (_) => 'Vesting Schedule Deleted',
    valuationRecorded: (_) => 'Valuation Recorded',
    valuationDeleted: (_) => 'Valuation Deleted',
    transferInitiated: (_) => 'Transfer Initiated',
    transferRofrWaived: (_) => 'ROFR Waived',
    transferExecuted: (_) => 'Transfer Executed',
    transferCancelled: (_) => 'Transfer Cancelled',
    mfnUpgradeReverted: (_) => 'MFN Upgrade Reverted',
    scenarioSaved: (_) => 'Scenario Saved',
    scenarioDeleted: (_) => 'Scenario Deleted',
  );
}

String _getEventDescription(CapTableEvent event) {
  return event.map(
    companyCreated: (e) => 'Created company "${e.name}"',
    companyRenamed: (e) => 'Renamed from "${e.previousName}" to "${e.newName}"',
    stakeholderAdded: (e) =>
        'Added stakeholder "${e.name}" (${e.stakeholderType})',
    stakeholderUpdated: (e) =>
        'Updated stakeholder${e.name != null ? ' "${e.name}"' : ''}',
    stakeholderRemoved: (e) => 'Removed stakeholder',
    shareClassCreated: (e) =>
        'Created share class "${e.name}" (${e.shareClassType})',
    shareClassUpdated: (e) =>
        'Updated share class${e.name != null ? ' "${e.name}"' : ''}',
    roundOpened: (e) => 'Opened round "${e.name}" (${e.roundType})',
    roundClosed: (e) =>
        'Closed round with \$${_formatNumber(e.amountRaised)} raised',
    roundAmended: (e) => 'Amended round${e.name != null ? ' "${e.name}"' : ''}',
    roundReopened: (e) => 'Reopened round',
    roundDeleted: (e) => 'Deleted round',
    sharesIssued: (e) =>
        'Issued ${_formatNumber(e.shareCount.toDouble())} shares',
    sharesTransferred: (e) =>
        'Transferred ${_formatNumber(e.shareCount.toDouble())} shares',
    sharesRepurchased: (e) =>
        'Repurchased ${_formatNumber(e.shareCount.toDouble())} shares',
    holdingDeleted: (e) => 'Deleted holding',
    holdingUpdated: (e) => 'Updated holding',
    holdingVestingUpdated: (e) =>
        'Updated vesting to ${_formatNumber(e.vestedCount.toDouble())} vested',
    convertibleIssued: (e) =>
        'Issued ${e.convertibleType} for \$${_formatNumber(e.principal)}',
    mfnUpgradeApplied: (e) => 'Applied MFN upgrade',
    convertibleConverted: (e) =>
        'Converted to ${_formatNumber(e.sharesReceived.toDouble())} shares',
    convertibleCancelled: (e) =>
        'Cancelled convertible${e.reason != null ? ': ${e.reason}' : ''}',
    convertibleUpdated: (e) => 'Updated convertible terms',
    esopPoolCreated: (e) =>
        'Created pool "${e.name}" with ${_formatNumber(e.poolSize.toDouble())} shares',
    esopPoolExpanded: (e) =>
        'Expanded pool by ${_formatNumber(e.sharesAdded.toDouble())} shares',
    esopPoolActivated: (e) => 'Activated ESOP pool',
    esopPoolUpdated: (e) =>
        'Updated ESOP pool${e.name != null ? ' "${e.name}"' : ''}',
    esopPoolDeleted: (e) => 'Deleted ESOP pool',
    esopPoolExpansionReverted: (e) =>
        'Reverted expansion, removed ${_formatNumber(e.sharesRemoved.toDouble())} shares',
    optionGranted: (e) =>
        'Granted ${_formatNumber(e.quantity.toDouble())} options at \$${e.strikePrice}',
    optionGrantUpdated: (e) => 'Updated option grant',
    optionsVested: (e) =>
        'Vested ${_formatNumber(e.vestedCount.toDouble())} options',
    optionsExercised: (e) =>
        'Exercised ${_formatNumber(e.exercisedCount.toDouble())} options',
    optionsCancelled: (e) =>
        'Cancelled ${_formatNumber(e.cancelledCount.toDouble())} options',
    optionGrantStatusChanged: (e) =>
        'Status changed: ${e.previousStatus} → ${e.newStatus}',
    warrantIssued: (e) =>
        'Issued ${_formatNumber(e.quantity.toDouble())} warrants at \$${e.strikePrice}',
    warrantExercised: (e) =>
        'Exercised ${_formatNumber(e.exercisedCount.toDouble())} warrants',
    warrantCancelled: (e) =>
        'Cancelled ${_formatNumber(e.cancelledCount.toDouble())} warrants',
    warrantUpdated: (e) => 'Updated warrant',
    warrantUnexercised: (e) =>
        'Unexercised ${_formatNumber(e.unexercisedCount.toDouble())} warrants',
    warrantStatusChanged: (e) =>
        'Status changed: ${e.previousStatus} → ${e.newStatus}',
    vestingScheduleCreated: (e) => 'Created vesting schedule "${e.name}"',
    vestingScheduleUpdated: (e) =>
        'Updated vesting schedule${e.name != null ? ' "${e.name}"' : ''}',
    vestingScheduleDeleted: (e) => 'Deleted vesting schedule',
    valuationRecorded: (e) =>
        'Recorded ${e.method} valuation at \$${_formatNumber(e.preMoneyValue)}',
    valuationDeleted: (e) => 'Deleted valuation',
    transferInitiated: (e) =>
        'Initiated transfer of ${_formatNumber(e.shareCount.toDouble())} shares',
    transferRofrWaived: (e) =>
        'ROFR waived${e.waivedBy != null ? ' by ${e.waivedBy}' : ''}',
    transferExecuted: (e) => 'Transfer executed',
    transferCancelled: (e) =>
        'Transfer cancelled${e.reason != null ? ': ${e.reason}' : ''}',
    mfnUpgradeReverted: (e) => 'Reverted MFN upgrade',
    scenarioSaved: (e) => 'Saved scenario "${e.name}"',
    scenarioDeleted: (e) => 'Deleted scenario',
  );
}

DateTime _getTimestamp(CapTableEvent event) {
  return event.map(
    companyCreated: (e) => e.timestamp,
    companyRenamed: (e) => e.timestamp,
    stakeholderAdded: (e) => e.timestamp,
    stakeholderUpdated: (e) => e.timestamp,
    stakeholderRemoved: (e) => e.timestamp,
    shareClassCreated: (e) => e.timestamp,
    shareClassUpdated: (e) => e.timestamp,
    roundOpened: (e) => e.timestamp,
    roundClosed: (e) => e.timestamp,
    roundAmended: (e) => e.timestamp,
    roundReopened: (e) => e.timestamp,
    roundDeleted: (e) => e.timestamp,
    sharesIssued: (e) => e.timestamp,
    sharesTransferred: (e) => e.timestamp,
    sharesRepurchased: (e) => e.timestamp,
    holdingDeleted: (e) => e.timestamp,
    holdingUpdated: (e) => e.timestamp,
    holdingVestingUpdated: (e) => e.timestamp,
    convertibleIssued: (e) => e.timestamp,
    mfnUpgradeApplied: (e) => e.timestamp,
    convertibleConverted: (e) => e.timestamp,
    convertibleCancelled: (e) => e.timestamp,
    convertibleUpdated: (e) => e.timestamp,
    esopPoolCreated: (e) => e.timestamp,
    esopPoolExpanded: (e) => e.timestamp,
    esopPoolActivated: (e) => e.timestamp,
    esopPoolUpdated: (e) => e.timestamp,
    esopPoolDeleted: (e) => e.timestamp,
    esopPoolExpansionReverted: (e) => e.timestamp,
    optionGranted: (e) => e.timestamp,
    optionGrantUpdated: (e) => e.timestamp,
    optionsVested: (e) => e.timestamp,
    optionsExercised: (e) => e.timestamp,
    optionsCancelled: (e) => e.timestamp,
    optionGrantStatusChanged: (e) => e.timestamp,
    warrantIssued: (e) => e.timestamp,
    warrantExercised: (e) => e.timestamp,
    warrantCancelled: (e) => e.timestamp,
    warrantUpdated: (e) => e.timestamp,
    warrantUnexercised: (e) => e.timestamp,
    warrantStatusChanged: (e) => e.timestamp,
    vestingScheduleCreated: (e) => e.timestamp,
    vestingScheduleUpdated: (e) => e.timestamp,
    vestingScheduleDeleted: (e) => e.timestamp,
    valuationRecorded: (e) => e.timestamp,
    valuationDeleted: (e) => e.timestamp,
    transferInitiated: (e) => e.timestamp,
    transferRofrWaived: (e) => e.timestamp,
    transferExecuted: (e) => e.timestamp,
    transferCancelled: (e) => e.timestamp,
    mfnUpgradeReverted: (e) => e.timestamp,
    scenarioSaved: (e) => e.timestamp,
    scenarioDeleted: (e) => e.timestamp,
  );
}

String? _getActorId(CapTableEvent event) {
  return event.map(
    companyCreated: (e) => e.actorId,
    companyRenamed: (e) => e.actorId,
    stakeholderAdded: (e) => e.actorId,
    stakeholderUpdated: (e) => e.actorId,
    stakeholderRemoved: (e) => e.actorId,
    shareClassCreated: (e) => e.actorId,
    shareClassUpdated: (e) => e.actorId,
    roundOpened: (e) => e.actorId,
    roundClosed: (e) => e.actorId,
    roundAmended: (e) => e.actorId,
    roundReopened: (e) => e.actorId,
    roundDeleted: (e) => e.actorId,
    sharesIssued: (e) => e.actorId,
    sharesTransferred: (e) => e.actorId,
    sharesRepurchased: (e) => e.actorId,
    holdingDeleted: (e) => e.actorId,
    holdingUpdated: (e) => e.actorId,
    holdingVestingUpdated: (e) => e.actorId,
    convertibleIssued: (e) => e.actorId,
    mfnUpgradeApplied: (e) => e.actorId,
    convertibleConverted: (e) => e.actorId,
    convertibleCancelled: (e) => e.actorId,
    convertibleUpdated: (e) => e.actorId,
    esopPoolCreated: (e) => e.actorId,
    esopPoolExpanded: (e) => e.actorId,
    esopPoolActivated: (e) => e.actorId,
    esopPoolUpdated: (e) => e.actorId,
    esopPoolDeleted: (e) => e.actorId,
    esopPoolExpansionReverted: (e) => e.actorId,
    optionGranted: (e) => e.actorId,
    optionGrantUpdated: (e) => e.actorId,
    optionsVested: (e) => e.actorId,
    optionsExercised: (e) => e.actorId,
    optionsCancelled: (e) => e.actorId,
    optionGrantStatusChanged: (e) => e.actorId,
    warrantIssued: (e) => e.actorId,
    warrantExercised: (e) => e.actorId,
    warrantCancelled: (e) => e.actorId,
    warrantUpdated: (e) => e.actorId,
    warrantUnexercised: (e) => e.actorId,
    warrantStatusChanged: (e) => e.actorId,
    vestingScheduleCreated: (e) => e.actorId,
    vestingScheduleUpdated: (e) => e.actorId,
    vestingScheduleDeleted: (e) => e.actorId,
    valuationRecorded: (e) => e.actorId,
    valuationDeleted: (e) => e.actorId,
    transferInitiated: (e) => e.actorId,
    transferRofrWaived: (e) => e.actorId,
    transferExecuted: (e) => e.actorId,
    transferCancelled: (e) => e.actorId,
    mfnUpgradeReverted: (e) => e.actorId,
    scenarioSaved: (e) => e.actorId,
    scenarioDeleted: (e) => e.actorId,
  );
}

String _formatNumber(double value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  } else if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}K';
  }
  return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
}
