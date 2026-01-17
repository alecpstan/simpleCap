import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/events/cap_table_event.dart';
import '../../infrastructure/persistence/drift/event_repository.dart';
import 'database_provider.dart';
import 'company_provider.dart';

part 'event_providers.g.dart';

/// Provides the event repository singleton.
@Riverpod(keepAlive: true)
EventRepository eventRepository(EventRepositoryRef ref) {
  final db = ref.watch(databaseProvider);
  return DriftEventRepository(db);
}

/// Watches all events for the current company, ordered by sequence.
///
/// This is the foundation of event sourcing - all state is derived from this stream.
@riverpod
Stream<List<CapTableEvent>> eventsStream(EventsStreamRef ref) async* {
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) {
    yield [];
    return;
  }

  final repo = ref.watch(eventRepositoryProvider);
  yield* repo.watchEvents(companyId);
}

/// Event ledger for appending new events.
///
/// This is the write-side of event sourcing. Commands go through here
/// to emit events that update the cap table state.
@Riverpod(keepAlive: true)
class EventLedger extends _$EventLedger {
  final _appendController = StreamController<void>.broadcast();

  @override
  void build() {
    ref.onDispose(() => _appendController.close());
  }

  /// Stream that emits whenever events are appended.
  /// Useful for triggering projection rebuilds.
  Stream<void> get onAppend => _appendController.stream;

  /// Append events to the current company's event log.
  ///
  /// Events are assigned sequential sequence numbers atomically.
  /// Returns immediately after persisting - projections will update reactively.
  Future<void> append(List<CapTableEvent> events) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('Cannot append events without a current company');
    }

    final repo = ref.read(eventRepositoryProvider);
    await repo.appendEvents(companyId, events);

    // Signal subscribers that new events were added
    _appendController.add(null);
  }

  /// Append events for a specific company (used when creating a new company).
  Future<void> appendForCompany(
    String companyId,
    List<CapTableEvent> events,
  ) async {
    final repo = ref.read(eventRepositoryProvider);
    await repo.appendEvents(companyId, events);
    _appendController.add(null);
  }
}

/// Provides the current event count for debugging/display.
@riverpod
Future<int> eventCount(EventCountRef ref) async {
  final events = await ref.watch(eventsStreamProvider.future);
  return events.length;
}
