import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/events/cap_table_event.dart';
import '../../database/database.dart';

/// Abstract repository interface for event storage.
///
/// This abstraction allows swapping between local (Drift) and
/// remote (Supabase) implementations without affecting the rest of the app.
abstract class EventRepository {
  /// Append events to the event log.
  Future<void> appendEvents(String companyId, List<CapTableEvent> events);

  /// Watch all events for a company, ordered by sequence.
  Stream<List<CapTableEvent>> watchEvents(String companyId);

  /// Get all events for a company.
  Future<List<CapTableEvent>> getEvents(String companyId);

  /// Get events after a specific sequence number.
  Future<List<CapTableEvent>> getEventsAfter(
    String companyId,
    int afterSequence,
  );

  /// Save a snapshot of projected state.
  Future<void> saveSnapshot(String companyId, String stateJson, int atSequence);

  /// Get the latest snapshot for a company.
  Future<(String stateJson, int atSequence)?> getLatestSnapshot(
    String companyId,
  );

  /// Permanently delete all events related to an entity by ID.
  /// This searches the event JSON for the entity ID and removes matching events.
  Future<void> deleteEventsByEntityId(String companyId, String entityId);

  /// Delete all snapshots for a company (to force rebuild after permanent delete).
  Future<void> deleteAllSnapshots(String companyId);
}

/// Local SQLite implementation of EventRepository using Drift.
class DriftEventRepository implements EventRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  DriftEventRepository(this._db);

  @override
  Future<void> appendEvents(
    String companyId,
    List<CapTableEvent> events,
  ) async {
    final companions = events.map((event) {
      return CapitalizationEventsCompanion(
        id: Value(_uuid.v4()),
        companyId: Value(companyId),
        sequenceNumber: const Value(0), // Will be set by appendEvents
        eventType: Value(_getEventType(event)),
        eventDataJson: Value(jsonEncode(event.toJson())),
        timestamp: Value(_getEventTimestamp(event)),
        actorId: Value(_getEventActorId(event)),
      );
    }).toList();

    await _db.appendEvents(companyId, companions);
  }

  @override
  Stream<List<CapTableEvent>> watchEvents(String companyId) {
    return _db.watchEvents(companyId).map(_parseEvents);
  }

  @override
  Future<List<CapTableEvent>> getEvents(String companyId) async {
    final rows = await _db.getEvents(companyId);
    return _parseEvents(rows);
  }

  @override
  Future<List<CapTableEvent>> getEventsAfter(
    String companyId,
    int afterSequence,
  ) async {
    final rows = await _db.getEventsAfter(companyId, afterSequence);
    return _parseEvents(rows);
  }

  @override
  Future<void> saveSnapshot(
    String companyId,
    String stateJson,
    int atSequence,
  ) async {
    await _db.saveSnapshot(
      SnapshotsCompanion(
        id: Value(_uuid.v4()),
        companyId: Value(companyId),
        atSequenceNumber: Value(atSequence),
        stateJson: Value(stateJson),
        createdAt: Value(DateTime.now()),
      ),
    );
    // Keep only last 3 snapshots
    await _db.pruneSnapshots(companyId);
  }

  @override
  Future<(String, int)?> getLatestSnapshot(String companyId) async {
    final snapshot = await _db.getLatestSnapshot(companyId);
    if (snapshot == null) return null;
    return (snapshot.stateJson, snapshot.atSequenceNumber);
  }

  @override
  Future<void> deleteEventsByEntityId(String companyId, String entityId) async {
    // Get all events for the company
    final events = await _db.getEvents(companyId);

    // Find events that reference this entity ID in their JSON
    final eventsToDelete = events.where((e) {
      return e.eventDataJson.contains('"$entityId"');
    }).toList();

    // Delete matching events
    for (final event in eventsToDelete) {
      await (_db.delete(
        _db.capitalizationEvents,
      )..where((e) => e.id.equals(event.id))).go();
    }
  }

  @override
  Future<void> deleteAllSnapshots(String companyId) async {
    await (_db.delete(
      _db.snapshots,
    )..where((s) => s.companyId.equals(companyId))).go();
  }

  // ============================================================
  // Private helpers
  // ============================================================

  List<CapTableEvent> _parseEvents(List<CapitalizationEvent> rows) {
    return rows.map((row) {
      final json = jsonDecode(row.eventDataJson) as Map<String, dynamic>;
      // Migrate old event format using the stored eventType column
      final migratedJson = _migrateEventJson(json, row.eventType);
      return CapTableEvent.fromJson(migratedJson);
    }).toList();
  }

  /// Migrate old event JSON format to new format.
  ///
  /// Old events stored 'type' for things like stakeholder type, share class type, etc.
  /// This conflicts with Freezed's union discriminator which also uses 'type'.
  /// We renamed these fields to stakeholderType, shareClassType, etc.
  ///
  /// The [storedEventType] comes from the database column and is the correct event type.
  Map<String, dynamic> _migrateEventJson(
    Map<String, dynamic> json,
    String storedEventType,
  ) {
    // Create a mutable copy
    final migrated = Map<String, dynamic>.from(json);

    // Get the current type value in JSON
    final jsonType = migrated['type'] as String?;

    // If the JSON type doesn't match the stored event type, we have old data
    // where the domain type overwrote the event discriminator
    if (jsonType != storedEventType) {
      // Move the domain value to the correct field name based on event type
      switch (storedEventType) {
        case 'stakeholderAdded':
        case 'stakeholderUpdated':
          if (jsonType != null && !migrated.containsKey('stakeholderType')) {
            migrated['stakeholderType'] = jsonType;
          }
          break;
        case 'shareClassCreated':
        case 'shareClassUpdated':
          if (jsonType != null && !migrated.containsKey('shareClassType')) {
            migrated['shareClassType'] = jsonType;
          }
          break;
        case 'roundOpened':
        case 'roundAmended':
          if (jsonType != null && !migrated.containsKey('roundType')) {
            migrated['roundType'] = jsonType;
          }
          break;
        case 'convertibleIssued':
          if (jsonType != null && !migrated.containsKey('convertibleType')) {
            migrated['convertibleType'] = jsonType;
          }
          break;
        case 'vestingScheduleCreated':
        case 'vestingScheduleUpdated':
          if (jsonType != null && !migrated.containsKey('scheduleType')) {
            migrated['scheduleType'] = jsonType;
          }
          break;
        case 'scenarioSaved':
          if (jsonType != null && !migrated.containsKey('scenarioType')) {
            migrated['scenarioType'] = jsonType;
          }
          break;
      }

      // Restore the correct event discriminator
      migrated['type'] = storedEventType;
    }

    return migrated;
  }

  /// Extract event type from the Freezed union.
  String _getEventType(CapTableEvent event) {
    return event.map(
      companyCreated: (_) => 'companyCreated',
      companyRenamed: (_) => 'companyRenamed',
      stakeholderAdded: (_) => 'stakeholderAdded',
      stakeholderUpdated: (_) => 'stakeholderUpdated',
      stakeholderRemoved: (_) => 'stakeholderRemoved',
      shareClassCreated: (_) => 'shareClassCreated',
      shareClassUpdated: (_) => 'shareClassUpdated',
      roundOpened: (_) => 'roundOpened',
      roundClosed: (_) => 'roundClosed',
      roundAmended: (_) => 'roundAmended',
      roundReopened: (_) => 'roundReopened',
      roundDeleted: (_) => 'roundDeleted',
      sharesIssued: (_) => 'sharesIssued',
      sharesTransferred: (_) => 'sharesTransferred',
      sharesRepurchased: (_) => 'sharesRepurchased',
      holdingDeleted: (_) => 'holdingDeleted',
      holdingUpdated: (_) => 'holdingUpdated',
      holdingVestingUpdated: (_) => 'holdingVestingUpdated',
      convertibleIssued: (_) => 'convertibleIssued',
      mfnUpgradeApplied: (_) => 'mfnUpgradeApplied',
      convertibleConverted: (_) => 'convertibleConverted',
      convertibleCancelled: (_) => 'convertibleCancelled',
      convertibleUpdated: (_) => 'convertibleUpdated',
      esopPoolCreated: (_) => 'esopPoolCreated',
      esopPoolExpanded: (_) => 'esopPoolExpanded',
      esopPoolActivated: (_) => 'esopPoolActivated',
      esopPoolUpdated: (_) => 'esopPoolUpdated',
      esopPoolDeleted: (_) => 'esopPoolDeleted',
      esopPoolExpansionReverted: (_) => 'esopPoolExpansionReverted',
      optionGranted: (_) => 'optionGranted',
      optionsVested: (_) => 'optionsVested',
      optionsExercised: (_) => 'optionsExercised',
      optionsCancelled: (_) => 'optionsCancelled',
      optionGrantStatusChanged: (_) => 'optionGrantStatusChanged',
      optionGrantUpdated: (_) => 'optionGrantUpdated',
      warrantIssued: (_) => 'warrantIssued',
      warrantExercised: (_) => 'warrantExercised',
      warrantCancelled: (_) => 'warrantCancelled',
      warrantUpdated: (_) => 'warrantUpdated',
      warrantUnexercised: (_) => 'warrantUnexercised',
      warrantStatusChanged: (_) => 'warrantStatusChanged',
      vestingScheduleCreated: (_) => 'vestingScheduleCreated',
      vestingScheduleUpdated: (_) => 'vestingScheduleUpdated',
      vestingScheduleDeleted: (_) => 'vestingScheduleDeleted',
      valuationRecorded: (_) => 'valuationRecorded',
      valuationDeleted: (_) => 'valuationDeleted',
      transferInitiated: (_) => 'transferInitiated',
      transferRofrWaived: (_) => 'transferRofrWaived',
      transferExecuted: (_) => 'transferExecuted',
      transferCancelled: (_) => 'transferCancelled',
      mfnUpgradeReverted: (_) => 'mfnUpgradeReverted',
      scenarioSaved: (_) => 'scenarioSaved',
      scenarioDeleted: (_) => 'scenarioDeleted',
    );
  }

  /// Extract timestamp from event.
  DateTime _getEventTimestamp(CapTableEvent event) {
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
      optionsVested: (e) => e.timestamp,
      optionsExercised: (e) => e.timestamp,
      optionsCancelled: (e) => e.timestamp,
      optionGrantStatusChanged: (e) => e.timestamp,
      optionGrantUpdated: (e) => e.timestamp,
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

  /// Extract actorId from event.
  String? _getEventActorId(CapTableEvent event) {
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
      optionsVested: (e) => e.actorId,
      optionsExercised: (e) => e.actorId,
      optionsCancelled: (e) => e.actorId,
      optionGrantStatusChanged: (e) => e.actorId,
      optionGrantUpdated: (e) => e.actorId,
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
}
