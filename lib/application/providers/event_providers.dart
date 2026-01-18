import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/events/cap_table_event.dart';
import '../../domain/projections/cap_table_state.dart';
import '../../infrastructure/persistence/drift/event_repository.dart';
import 'projection_providers.dart';
import 'database_provider.dart';
import 'company_provider.dart';

part 'event_providers.g.dart';

/// Entity types for cascade delete operations.
enum EntityType {
  stakeholder,
  shareClass,
  round,
  esopPool,
  optionGrant,
  warrant,
  convertible,
  holding,
  vestingSchedule,
}

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

  /// Permanently delete all events related to an entity by ID.
  /// This searches the event JSON for the entity ID and removes matching events.
  /// Also clears snapshots to force a rebuild of projected state.
  Future<void> permanentDeleteEntity(String entityId) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('Cannot delete events without a current company');
    }

    final repo = ref.read(eventRepositoryProvider);
    await repo.deleteEventsByEntityId(companyId, entityId);
    await repo.deleteAllSnapshots(companyId);

    // Signal subscribers that events were modified
    _appendController.add(null);

    // Force providers to re-fetch from database
    ref.invalidate(eventsStreamProvider);
  }

  /// Cascade delete an entity and all related entities.
  /// Returns a list of entity IDs that were deleted.
  Future<List<String>> cascadeDeleteEntity({
    required String entityId,
    required EntityType entityType,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('Cannot delete events without a current company');
    }

    // Get current state to find related entities
    final state = await ref.read(capTableStateProvider.future);
    if (state == null) {
      // No state means no events to delete
      return [entityId];
    }

    final deletedIds = <String>[entityId];

    // Find all entities to cascade delete based on type
    switch (entityType) {
      case EntityType.stakeholder:
        // Delete all holdings, options, warrants, convertibles for this stakeholder
        for (final holding in state.holdings.values) {
          if (holding.stakeholderId == entityId) {
            deletedIds.add(holding.id);
          }
        }
        for (final option in state.optionGrants.values) {
          if (option.stakeholderId == entityId) {
            deletedIds.add(option.id);
            // Also delete holdings from exercised options
            for (final h in state.holdings.values) {
              if (h.sourceOptionGrantId == option.id) {
                deletedIds.add(h.id);
              }
            }
          }
        }
        for (final warrant in state.warrants.values) {
          if (warrant.stakeholderId == entityId) {
            deletedIds.add(warrant.id);
            // Also delete holdings from exercised warrants
            for (final h in state.holdings.values) {
              if (h.sourceWarrantId == warrant.id) {
                deletedIds.add(h.id);
              }
            }
          }
        }
        for (final conv in state.convertibles.values) {
          if (conv.stakeholderId == entityId) {
            deletedIds.add(conv.id);
          }
        }

      case EntityType.shareClass:
        // Delete all holdings, options, warrants, esop pools using this share class
        for (final holding in state.holdings.values) {
          if (holding.shareClassId == entityId) {
            deletedIds.add(holding.id);
          }
        }
        for (final option in state.optionGrants.values) {
          if (option.shareClassId == entityId) {
            deletedIds.add(option.id);
          }
        }
        for (final warrant in state.warrants.values) {
          if (warrant.shareClassId == entityId) {
            deletedIds.add(warrant.id);
          }
        }
        // ESOP pools are not tied to share classes (options define their own share class)

      case EntityType.round:
        // Delete entities CREATED in this round (not exercised in this round)
        for (final holding in state.holdings.values) {
          if (holding.roundId == entityId) {
            // Only delete if not from option/warrant exercise
            if (holding.sourceOptionGrantId == null &&
                holding.sourceWarrantId == null) {
              deletedIds.add(holding.id);
            }
          }
        }
        for (final option in state.optionGrants.values) {
          if (option.roundId == entityId) {
            deletedIds.add(option.id);
            // Delete holdings from exercising these options
            for (final h in state.holdings.values) {
              if (h.sourceOptionGrantId == option.id) {
                deletedIds.add(h.id);
              }
            }
          }
        }
        for (final warrant in state.warrants.values) {
          if (warrant.roundId == entityId) {
            deletedIds.add(warrant.id);
            // Delete holdings from exercising these warrants
            for (final h in state.holdings.values) {
              if (h.sourceWarrantId == warrant.id) {
                deletedIds.add(h.id);
              }
            }
          }
        }
        for (final conv in state.convertibles.values) {
          if (conv.roundId == entityId) {
            deletedIds.add(conv.id);
          }
        }

      case EntityType.esopPool:
        deletedIds.addAll(await _getEsopPoolCascadeIds(state, entityId));

      case EntityType.optionGrant:
        // Delete holdings from exercising this option
        for (final h in state.holdings.values) {
          if (h.sourceOptionGrantId == entityId) {
            deletedIds.add(h.id);
          }
        }

      case EntityType.warrant:
        // Delete holdings from exercising this warrant
        for (final h in state.holdings.values) {
          if (h.sourceWarrantId == entityId) {
            deletedIds.add(h.id);
          }
        }

      case EntityType.convertible:
        // Convertibles may have warrants issued from them
        for (final warrant in state.warrants.values) {
          if (warrant.sourceConvertibleId == entityId) {
            deletedIds.add(warrant.id);
            // Also delete holdings from exercised warrants
            for (final h in state.holdings.values) {
              if (h.sourceWarrantId == warrant.id) {
                deletedIds.add(h.id);
              }
            }
          }
        }
        // Delete MFN upgrades where this convertible is the source or target
        // MFN upgrades are events, so we collect their IDs for event deletion
        final db = ref.read(databaseProvider);
        final mfnUpgradesFromSource = await db.getMfnUpgradesFromSource(
          entityId,
        );
        for (final upgrade in mfnUpgradesFromSource) {
          deletedIds.add(upgrade.id);
        }
        final mfnUpgradesForTarget = await db.getMfnUpgradesForTarget(entityId);
        for (final upgrade in mfnUpgradesForTarget) {
          deletedIds.add(upgrade.id);
        }

      case EntityType.holding:
        // Holdings don't cascade (they're leaf entities)
        break;

      case EntityType.vestingSchedule:
        // Vesting schedules don't cascade delete - just nullify references
        break;
    }

    // Remove duplicates
    final uniqueIds = deletedIds.toSet().toList();

    // Delete events for all entities (including MFN upgrades which are event-sourced)
    final repo = ref.read(eventRepositoryProvider);
    for (final id in uniqueIds) {
      await repo.deleteEventsByEntityId(companyId, id);
    }
    await repo.deleteAllSnapshots(companyId);

    // Signal subscribers that events were modified
    _appendController.add(null);

    // Force providers to re-fetch from database
    ref.invalidate(eventsStreamProvider);

    return uniqueIds;
  }

  /// Get cascade delete IDs for an ESOP pool
  Future<List<String>> _getEsopPoolCascadeIds(
    CapTableState state,
    String poolId,
  ) async {
    final ids = <String>[poolId];
    for (final option in state.optionGrants.values) {
      if (option.esopPoolId == poolId) {
        ids.add(option.id);
        // Delete holdings from exercising these options
        for (final h in state.holdings.values) {
          if (h.sourceOptionGrantId == option.id) {
            ids.add(h.id);
          }
        }
      }
    }
    return ids;
  }

  /// Preview cascade delete - returns entity counts that would be deleted.
  /// Useful for confirmation dialogs.
  Future<Map<EntityType, int>> previewCascadeDelete({
    required String entityId,
    required EntityType entityType,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      return {};
    }

    final state = await ref.read(capTableStateProvider.future);
    if (state == null) {
      return {};
    }

    final counts = <EntityType, int>{};

    switch (entityType) {
      case EntityType.stakeholder:
        int holdings = 0, options = 0, warrants = 0, convertibles = 0;
        for (final h in state.holdings.values) {
          if (h.stakeholderId == entityId) holdings++;
        }
        for (final o in state.optionGrants.values) {
          if (o.stakeholderId == entityId) {
            options++;
            // Count holdings from exercised options
            for (final h in state.holdings.values) {
              if (h.sourceOptionGrantId == o.id) holdings++;
            }
          }
        }
        for (final w in state.warrants.values) {
          if (w.stakeholderId == entityId) {
            warrants++;
            // Count holdings from exercised warrants
            for (final h in state.holdings.values) {
              if (h.sourceWarrantId == w.id) holdings++;
            }
          }
        }
        for (final c in state.convertibles.values) {
          if (c.stakeholderId == entityId) convertibles++;
        }
        if (holdings > 0) counts[EntityType.holding] = holdings;
        if (options > 0) counts[EntityType.optionGrant] = options;
        if (warrants > 0) counts[EntityType.warrant] = warrants;
        if (convertibles > 0) counts[EntityType.convertible] = convertibles;

      case EntityType.shareClass:
        int holdings = 0, options = 0, warrants = 0;
        for (final h in state.holdings.values) {
          if (h.shareClassId == entityId) holdings++;
        }
        for (final o in state.optionGrants.values) {
          if (o.shareClassId == entityId) options++;
        }
        for (final w in state.warrants.values) {
          if (w.shareClassId == entityId) warrants++;
        }
        // ESOP pools are not tied to share classes (options define their own share class)
        if (holdings > 0) counts[EntityType.holding] = holdings;
        if (options > 0) counts[EntityType.optionGrant] = options;
        if (warrants > 0) counts[EntityType.warrant] = warrants;

      case EntityType.round:
        int holdings = 0, options = 0, warrants = 0, convertibles = 0;
        for (final h in state.holdings.values) {
          if (h.roundId == entityId &&
              h.sourceOptionGrantId == null &&
              h.sourceWarrantId == null) {
            holdings++;
          }
        }
        for (final o in state.optionGrants.values) {
          if (o.roundId == entityId) {
            options++;
            for (final h in state.holdings.values) {
              if (h.sourceOptionGrantId == o.id) holdings++;
            }
          }
        }
        for (final w in state.warrants.values) {
          if (w.roundId == entityId) {
            warrants++;
            for (final h in state.holdings.values) {
              if (h.sourceWarrantId == w.id) holdings++;
            }
          }
        }
        for (final c in state.convertibles.values) {
          if (c.roundId == entityId) convertibles++;
        }
        if (holdings > 0) counts[EntityType.holding] = holdings;
        if (options > 0) counts[EntityType.optionGrant] = options;
        if (warrants > 0) counts[EntityType.warrant] = warrants;
        if (convertibles > 0) counts[EntityType.convertible] = convertibles;

      case EntityType.esopPool:
        int options = 0, holdings = 0;
        for (final o in state.optionGrants.values) {
          if (o.esopPoolId == entityId) {
            options++;
            for (final h in state.holdings.values) {
              if (h.sourceOptionGrantId == o.id) holdings++;
            }
          }
        }
        if (options > 0) counts[EntityType.optionGrant] = options;
        if (holdings > 0) counts[EntityType.holding] = holdings;

      case EntityType.optionGrant:
        int holdings = 0;
        for (final h in state.holdings.values) {
          if (h.sourceOptionGrantId == entityId) holdings++;
        }
        if (holdings > 0) counts[EntityType.holding] = holdings;

      case EntityType.warrant:
        int holdings = 0;
        for (final h in state.holdings.values) {
          if (h.sourceWarrantId == entityId) holdings++;
        }
        if (holdings > 0) counts[EntityType.holding] = holdings;

      case EntityType.convertible:
        int warrants = 0, holdings = 0;
        for (final w in state.warrants.values) {
          if (w.sourceConvertibleId == entityId) {
            warrants++;
            for (final h in state.holdings.values) {
              if (h.sourceWarrantId == w.id) holdings++;
            }
          }
        }
        if (warrants > 0) counts[EntityType.warrant] = warrants;
        if (holdings > 0) counts[EntityType.holding] = holdings;

      case EntityType.holding:
      case EntityType.vestingSchedule:
        // No cascades
        break;
    }

    return counts;
  }
}

/// Provides the current event count for debugging/display.
@riverpod
Future<int> eventCount(EventCountRef ref) async {
  final events = await ref.watch(eventsStreamProvider.future);
  return events.length;
}
