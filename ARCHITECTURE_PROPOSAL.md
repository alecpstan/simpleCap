# Fresh Architecture Proposal: Simple Cap v2

## Executive Summary

Your current implementation is solid but could be transformed into a **truly auditable, cloud-ready system** by adopting **Event Sourcing as the core pattern**. This fundamentally changes how you think about data—instead of storing "current state," you store "what happened" and derive state from events.

---

## Implementation Approach

### Phase 1: Local Event Sourcing Only (No Supabase)

We build and prove the architecture locally first. Supabase sync comes later.

**What we build:**

```
lib/
├── domain/
│   └── events/
│       └── cap_table_event.dart      # Sealed event classes
│
├── infrastructure/
│   └── persistence/
│       └── drift/
│           ├── database.dart         # Keep existing + add events table
│           ├── tables.dart           # Add CapTableEvents table
│           └── event_repository.dart # Append/watch events
│
└── application/
    └── providers/
        ├── event_providers.dart      # Ledger, streams
        ├── projection_providers.dart # Derived state
        └── command_providers.dart    # Write operations
```

### Why UI Stays Intact

Your UI is already decoupled from the database via **Riverpod providers**. The UI doesn't call `db.watchStakeholders()` directly — it does:

```dart
final stakeholders = ref.watch(stakeholdersStreamProvider);
```

Providers are your abstraction boundary. The UI doesn't care _how_ data is produced, only _what shape_ it has.

### No New "View" Types Needed

You already have Freezed entities (`Stakeholder`, `Holding`, `Round`, etc.) that are separate from your Drift tables. Your providers already transform Drift rows into these domain entities. You'd just populate them from projections instead of Drift queries—same types, different source.

```dart
// Current provider (simplified)
@riverpod
Stream<List<Holding>> holdingsStream(Ref ref) {
  final db = ref.watch(databaseProvider);
  return db.watchHoldings().map((rows) => rows.map(Holding.fromDb).toList());
}

// After migration - same return type
@riverpod
Stream<List<Holding>> holdingsStream(Ref ref) {
  final projections = ref.watch(projectionsProvider);
  return projections.ownershipStream.map((p) => p.allHoldings);
}
```

The UI sees `List<Holding>` either way.

---

## Friction Points & Solutions

### 1. Streams from Events

Drift gives you reactive streams via `watch()`. Event projections don't naturally emit streams. Solution:

```dart
@Riverpod(keepAlive: true)
class EventLedger extends _$EventLedger {
  final _controller = StreamController<void>.broadcast();

  @override
  List<CapTableEvent> build() => [];

  Future<void> append(List<CapTableEvent> events) async {
    await _persistEvents(events);
    state = [...state, ...events];
    _controller.add(null); // Signal subscribers
  }

  Stream<void> get onAppend => _controller.stream;
}

// Projections rebuild on signal
@riverpod
Stream<OwnershipProjection> ownershipProjection(Ref ref) async* {
  final ledger = ref.watch(eventLedgerProvider.notifier);

  // Initial yield
  yield OwnershipProjection.from(ref.read(eventLedgerProvider));

  // Yield on each append
  await for (final _ in ledger.onAppend) {
    yield OwnershipProjection.from(ref.read(eventLedgerProvider));
  }
}
```

### 2. Mutation Return Values

Current mutations return futures and sometimes the created entity:

```dart
// Current pattern
final newRound = await ref.read(roundMutationsProvider.notifier).create(round);
// UI might use newRound.id immediately
```

**Solution: Generate ID client-side (recommended)**

```dart
Future<String> createRound(RoundData data) async {
  final id = const Uuid().v4(); // Generate before command
  await ref.read(ledgerProvider.notifier).append([
    RoundOpened(id: id, ...data),
  ]);
  return id; // Return immediately
}
```

The ID exists the moment you decide to create — no waiting for DB. This is actually _better_ UX.

### 3. Parameterized Provider Performance

Providers like `stakeholderHoldingsProvider(stakeholderId)` need efficient filtering. For cap table scale (dozens to hundreds, not millions), O(n) filtering is fine. But cache derived maps if needed:

```dart
@riverpod
class OwnershipProjection {
  final List<Holding> allHoldings;
  late final Map<String, List<Holding>> _byStakeholder;

  OwnershipProjection(this.allHoldings) {
    _byStakeholder = groupBy(allHoldings, (h) => h.stakeholderId);
  }

  List<Holding> forStakeholder(String id) => _byStakeholder[id] ?? [];
}
```

One O(n) pass when projection rebuilds, then O(1) lookups.

---

## Realistic Timeline

| Task                                              | Estimate                     |
| ------------------------------------------------- | ---------------------------- |
| Events table, sealed event classes, repository    | 2-3 days                     |
| Projections with stream mechanics                 | 2-3 days                     |
| Update mutation calls (handle return values)      | 4-6 hours                    |
| UI changes (mostly imports, some mutation tweaks) | 1-2 hours                    |
| Testing/debugging (the hard part)                 | 2-3 days                     |
| **Total**                                         | **1.5-2 weeks focused work** |

---

## Snapshot Optimization (Week 2 Problem)

Once you have 1000+ events, you don't want to replay from genesis every app launch:

```dart
// On startup
final (snapshot, atSequence) = await repo.loadLatestSnapshot();
final newEvents = await repo.getEventsAfter(companyId, atSequence);
final state = snapshot.applyEvents(newEvents);

// Periodically save new snapshot
await repo.saveSnapshot(companyId, state, currentSequence);
```

---

## Core Architectural Pillars

### 1. **Event Sourcing First** (Auditability Built-In)

```
┌─────────────────────────────────────────────────────────────┐
│                     EVENT STORE                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ CapTableEvent (immutable, append-only)              │    │
│  │ ─────────────────────────────────────────────────── │    │
│  │ id: uuid                                             │    │
│  │ aggregateId: uuid (companyId)                       │    │
│  │ sequenceNumber: int                                  │    │
│  │ eventType: string                                    │    │
│  │ eventData: JSON                                      │    │
│  │ timestamp: DateTime                                  │    │
│  │ actorId: uuid (user who performed action)           │    │
│  │ signature: string (optional cryptographic hash)     │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   EVENT PROJECTIONS                          │
│  CapTableState = fold(events, initialState, reducer)        │
│  ─────────────────────────────────────────────────────────  │
│  • StakeholderProjection (materialize stakeholders)         │
│  • OwnershipProjection (current share positions)            │
│  • ConvertibleProjection (outstanding instruments)          │
│  • AuditLogProjection (human-readable audit trail)          │
└─────────────────────────────────────────────────────────────┘
```

**Events you'd model:**

```dart
sealed class CapTableEvent {
  // Company lifecycle
  CompanyCreated
  CompanyRenamed

  // Stakeholders
  StakeholderAdded
  StakeholderUpdated
  StakeholderRemoved

  // Share structure
  ShareClassCreated
  ShareClassUpdated

  // Funding rounds
  RoundOpened
  RoundClosed
  RoundAmended

  // Equity transactions
  SharesIssued
  SharesTransferred
  SharesRepurchased

  // Convertibles
  ConvertibleIssued
  MfnUpgradeApplied     // Dedicated event for MFN upgrades
  ConvertibleConverted
  ConvertibleCancelled

  // Options & Warrants
  EsopPoolCreated
  EsopPoolExpanded
  OptionGranted
  OptionsVested
  OptionsExercised
  OptionsCancelled
  WarrantIssued
  WarrantExercised

  // Valuations
  ValuationRecorded
}
```

**Why this matters for audits:**

- Every change is recorded with who did it and when
- You can reconstruct state at any point in time ("as of December 31, 2024")
- Natural audit trail without separate logging
- Cryptographic signatures can prove tampering hasn't occurred

---

### 2. **Layered Architecture with Clear Boundaries**

```
┌─────────────────────────────────────────────────────────────┐
│                         UI LAYER                             │
│  Flutter Widgets + Riverpod Consumers                        │
│  (Maintains your current visual flow exactly)               │
└────────────────────────────┬────────────────────────────────┘
                             │ Watches state, dispatches commands
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                    APPLICATION LAYER                         │
│  ┌─────────────────┐  ┌─────────────────┐                   │
│  │ Command Handlers │  │ Query Handlers  │                   │
│  │ (write path)     │  │ (read path)     │                   │
│  └────────┬─────────┘  └────────┬────────┘                   │
│           │ Emits events        │ Reads projections         │
└───────────┼─────────────────────┼───────────────────────────┘
            │                     │
            ▼                     ▼
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                            │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ Aggregates: Company, Round, Stakeholder, etc.       │    │
│  │ Value Objects: Money, ShareCount, Percentage        │    │
│  │ Domain Events (sealed classes)                      │    │
│  │ Domain Services (pure calculation functions)        │    │
│  │ Policies (business rules enforcement)               │    │
│  └─────────────────────────────────────────────────────┘    │
└────────────────────────────┬────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                  INFRASTRUCTURE LAYER                        │
│  ┌───────────────┐  ┌───────────────┐  ┌─────────────────┐  │
│  │ Local Store   │  │ Supabase Sync │  │ Document Export │  │
│  │ (Drift/SQLite)│  │ (Repository)  │  │ (PDF/CSV)       │  │
│  └───────────────┘  └───────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

### 3. **Value Objects for Financial Precision**

Replace raw `double` and `int` with domain-specific types:

```dart
// Immutable value objects with validation
@freezed
class Money with _$Money {
  const Money._();
  const factory Money({
    required int cents, // Store as cents to avoid floating point issues
    @Default('AUD') String currency,
  }) = _Money;

  double get dollars => cents / 100;
  Money operator +(Money other) => Money(cents: cents + other.cents);
  String format() => '\$${(cents / 100).toStringAsFixed(2)}';
}

@freezed
class ShareCount with _$ShareCount {
  const ShareCount._();
  const factory ShareCount(int value) = _ShareCount;

  Percentage percentageOf(ShareCount total) =>
    Percentage((value / total.value) * 100);
}

@freezed
class Percentage with _$Percentage {
  const Percentage._();
  const factory Percentage(double value) = _Percentage;

  // Validation: 0-100 or throw
  factory Percentage.validated(double v) {
    assert(v >= 0 && v <= 100);
    return Percentage(v);
  }

  String format() => '${value.toStringAsFixed(2)}%';
}
```

---

### 4. **Repository Pattern for Supabase Readiness**

```dart
// Abstract repository interface
abstract class CapTableRepository {
  // Event store operations
  Future<void> appendEvents(String companyId, List<CapTableEvent> events);
  Stream<List<CapTableEvent>> watchEvents(String companyId);
  Future<List<CapTableEvent>> getEventsAfter(String companyId, int sequence);

  // Snapshot operations (for performance)
  Future<void> saveSnapshot(String companyId, CapTableState state, int atSequence);
  Future<(CapTableState?, int)?> loadLatestSnapshot(String companyId);
}

// Local SQLite implementation
class DriftCapTableRepository implements CapTableRepository {
  final AppDatabase _db;
  // Implementation using Drift
}

// Supabase implementation (future)
class SupabaseCapTableRepository implements CapTableRepository {
  final SupabaseClient _client;
  // Implementation using Supabase Realtime + Edge Functions
}

// Hybrid: local-first with sync
class SyncingCapTableRepository implements CapTableRepository {
  final DriftCapTableRepository _local;
  final SupabaseCapTableRepository _remote;

  // Write locally, sync to remote
  // Conflict resolution via event sequence numbers
}
```

---

### 5. **Document Generation Architecture**

```dart
// Document generation as a separate concern
abstract class DocumentGenerator<T extends DocumentTemplate> {
  Future<Uint8List> generate(T template, CapTableState state);
}

// Templates for different document types
sealed class DocumentTemplate {}

class CapTableSummaryTemplate extends DocumentTemplate {
  final DateTime asOfDate;
  final bool includeConvertibles;
  final bool includeOptions;
}

class ShareCertificateTemplate extends DocumentTemplate {
  final String stakeholderId;
  final String shareClassId;
  final int certificateNumber;
}

class Form409ATemplate extends DocumentTemplate {
  final DateTime valuationDate;
}

class TransferAgreementTemplate extends DocumentTemplate {
  final String transferId;
}

// Implementations
class PdfDocumentGenerator implements DocumentGenerator<DocumentTemplate> {
  // Use pdf package for Flutter
}

class CsvExporter {
  // Export cap table as CSV
}

// Audit-friendly: documents include event sequence number
// So you can prove what state the document was generated from
```

---

### 6. **Simplified Provider Structure**

```dart
// Single source of truth: the event stream
@riverpod
Stream<List<CapTableEvent>> eventStream(Ref ref, String companyId) {
  final repo = ref.watch(repositoryProvider);
  return repo.watchEvents(companyId);
}

// Projected state (computed from events)
@riverpod
Future<CapTableState> capTableState(Ref ref, String companyId) async {
  final events = await ref.watch(eventStreamProvider(companyId).future);
  return CapTableState.fromEvents(events);
}

// Derived views (select from projected state)
@riverpod
List<StakeholderView> stakeholders(Ref ref, String companyId) {
  final state = ref.watch(capTableStateProvider(companyId)).valueOrNull;
  return state?.stakeholders ?? [];
}

@riverpod
OwnershipSummary ownershipSummary(Ref ref, String companyId) {
  final state = ref.watch(capTableStateProvider(companyId)).valueOrNull;
  return OwnershipSummary.fromState(state);
}

// Command dispatcher (for writes)
@riverpod
class CapTableCommands extends _$CapTableCommands {
  @override
  void build() {}

  Future<void> addStakeholder(AddStakeholderCommand cmd) async {
    final repo = ref.read(repositoryProvider);
    final events = cmd.toEvents(); // Validate and convert to events
    await repo.appendEvents(cmd.companyId, events);
  }

  Future<void> closeRound(CloseRoundCommand cmd) async {
    // May emit multiple events atomically
  }
}
```

---

### 7. **Folder Structure**

```
lib/
├── main.dart
├── app.dart
│
├── core/                          # Cross-cutting concerns
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── colors.dart
│   │   └── spacing.dart
│   ├── extensions/               # Dart extensions
│   └── errors/                   # Error types
│
├── domain/                        # Pure Dart, no Flutter
│   ├── events/                   # Event definitions
│   │   ├── cap_table_event.dart  # Sealed class
│   │   └── event.freezed.dart
│   │
│   ├── aggregates/               # Rich domain models
│   │   ├── company.dart
│   │   ├── round.dart
│   │   └── stakeholder.dart
│   │
│   ├── value_objects/            # Money, ShareCount, etc.
│   │   ├── money.dart
│   │   ├── share_count.dart
│   │   └── percentage.dart
│   │
│   ├── projections/              # State derived from events
│   │   ├── cap_table_state.dart
│   │   ├── ownership_projection.dart
│   │   └── audit_log_projection.dart
│   │
│   ├── services/                 # Pure calculation functions
│   │   ├── conversion_calculator.dart
│   │   ├── vesting_calculator.dart
│   │   └── waterfall_calculator.dart
│   │
│   └── policies/                 # Business rule enforcement
│       ├── round_policy.dart     # Can round close? Validations
│       └── transfer_policy.dart
│
├── application/                   # Use cases & state management
│   ├── commands/                 # Write operations
│   │   ├── stakeholder_commands.dart
│   │   ├── round_commands.dart
│   │   └── convertible_commands.dart
│   │
│   ├── queries/                  # Read operations
│   │   ├── ownership_query.dart
│   │   └── valuation_query.dart
│   │
│   └── providers/                # Riverpod providers
│       ├── event_providers.dart
│       ├── state_providers.dart
│       ├── command_providers.dart
│       └── sync_providers.dart
│
├── infrastructure/                # External dependencies
│   ├── persistence/
│   │   ├── drift/
│   │   │   ├── database.dart
│   │   │   ├── tables.dart
│   │   │   └── drift_repository.dart
│   │   │
│   │   └── supabase/
│   │       ├── supabase_repository.dart
│   │       └── sync_service.dart
│   │
│   ├── documents/                # Document generation
│   │   ├── pdf_generator.dart
│   │   ├── csv_exporter.dart
│   │   └── templates/
│   │
│   └── crypto/                   # Cryptographic signing
│       └── event_signer.dart
│
├── shared/                        # Shared utilities
│   ├── formatters.dart
│   └── validators.dart
│
└── ui/                            # Presentation layer
    ├── shell/
    │   └── app_shell.dart        # Navigation structure
    │
    ├── pages/                    # Full-screen pages
    │   ├── overview/
    │   │   ├── overview_page.dart
    │   │   └── widgets/          # Page-specific widgets
    │   │
    │   ├── stakeholders/
    │   ├── rounds/
    │   │   ├── rounds_page.dart
    │   │   └── round_builder/    # Wizard broken into files
    │   │       ├── round_builder_page.dart
    │   │       ├── step_details.dart
    │   │       ├── step_valuation.dart
    │   │       ├── step_investments.dart
    │   │       ├── step_convertibles.dart
    │   │       ├── step_warrants.dart
    │   │       └── step_summary.dart
    │   │
    │   ├── value/
    │   ├── ownership/
    │   ├── options/
    │   ├── convertibles/
    │   ├── warrants/
    │   ├── scenarios/
    │   └── audit/                # New: audit trail viewer
    │       └── audit_log_page.dart
    │
    └── components/               # Reusable widgets
        ├── cards/
        ├── charts/
        ├── dialogs/
        ├── inputs/
        └── tables/
```

---

### 8. **Key Dependencies (Phase 1 - No Supabase)**

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Immutable Models
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0

  # Local Database
  drift: ^2.18.0
  sqlite3_flutter_libs: ^0.5.21
  path_provider: ^2.1.4

  # Document Generation
  pdf: ^3.10.0
  printing: ^5.11.0
  csv: ^5.0.2

  # Crypto (for audit signatures)
  crypto: ^3.0.3

  # UI
  fl_chart: ^1.1.1
  intl: ^0.20.2
  uuid: ^4.5.1

  # File Operations
  file_picker: ^8.0.0
  share_plus: ^7.0.0

  # Supabase - ADD LATER IN PHASE 2
  # supabase_flutter: ^2.0.0
```

---

### 9. **Supabase Schema (Phase 2 - Future)**

```sql
-- Event store table (append-only)
CREATE TABLE cap_table_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES companies(id),
  sequence_number INTEGER NOT NULL,
  event_type TEXT NOT NULL,
  event_data JSONB NOT NULL,
  timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  actor_id UUID REFERENCES auth.users(id),
  signature TEXT,

  UNIQUE(company_id, sequence_number)
);

-- Enable row-level security
ALTER TABLE cap_table_events ENABLE ROW LEVEL SECURITY;

-- Policy: users can only see events for companies they have access to
CREATE POLICY select_events ON cap_table_events
  FOR SELECT USING (
    company_id IN (
      SELECT company_id FROM company_members WHERE user_id = auth.uid()
    )
  );

-- Materialized view for quick access (rebuilt on-demand)
CREATE MATERIALIZED VIEW current_holdings AS
  SELECT ...
  -- Computed from events
;

-- Realtime enabled for sync
ALTER PUBLICATION supabase_realtime ADD TABLE cap_table_events;
```

---

### 10. **Audit Document Generation**

```dart
class AuditReportGenerator {
  Future<Uint8List> generateCapTableAsOf({
    required String companyId,
    required DateTime asOfDate,
    required List<CapTableEvent> events,
  }) async {
    // 1. Filter events up to asOfDate
    final relevantEvents = events
        .where((e) => e.timestamp.isBefore(asOfDate))
        .toList();

    // 2. Project state
    final state = CapTableState.fromEvents(relevantEvents);

    // 3. Generate PDF with:
    //    - Cap table summary
    //    - All events that contributed
    //    - Cryptographic hash of event chain
    //    - Timestamp and generator info

    final pdf = pw.Document();
    // ... build PDF

    return pdf.save();
  }
}
```

---

## Design Decisions

### Clean Slate Approach

- No legacy data migration required
- No existing users or companies to preserve
- Fresh entity design without constraints from archived Freezed entities

### Event Granularity

- **MFN upgrades**: Use dedicated `MfnUpgradeApplied` event (not generic `ConvertibleAmended`)
  - References the triggering convertible
  - Captures before/after terms explicitly
  - Better audit trail for this specific business action

### Composite Operations

- **Round closing emits multiple events atomically**:
  ```dart
  // When a round closes, emit all related events together
  await ledger.append([
    RoundClosed(roundId: id, closedAt: now),
    SharesIssued(stakeholderId: a, shareClassId: x, count: 1000, roundId: id),
    SharesIssued(stakeholderId: b, shareClassId: x, count: 500, roundId: id),
    ConvertibleConverted(convertibleId: c, toShares: 2000, roundId: id),
    // ... all in one atomic batch
  ]);
  ```
- Events share the same sequence number batch for atomicity
- Projections see consistent state (no partial round closures)

### Document Generation (Phase 2)

Deferred but planned:

- Cap table summary PDF
- Share certificates
- Transfer agreements
- 409A valuation support

---

## Summary: Why This Approach?

| Concern                 | Current Approach                | Proposed Approach                      |
| ----------------------- | ------------------------------- | -------------------------------------- |
| **Auditability**        | Not implemented                 | Built-in via event sourcing            |
| **Data Model**          | Mutable CRUD tables             | Immutable event log + projections      |
| **Supabase Sync**       | Would require custom sync logic | Events sync naturally (append-only)    |
| **Time Travel**         | Impossible                      | "As of date" queries trivial           |
| **Document Proof**      | None                            | Hash chain proves authenticity         |
| **Conflict Resolution** | Complex                         | Sequence numbers make it deterministic |
| **Testing**             | Harder (mutable state)          | Easy (pure functions on events)        |
| **File Size**           | 3000+ line files                | Small, focused modules                 |

This architecture turns auditability from an afterthought into the foundation. Every action is recorded, timestamped, and attributable. Documents can prove they were generated from a specific, verifiable state. And the event log syncs to Supabase naturally since it's append-only.
