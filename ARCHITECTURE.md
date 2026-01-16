# Simple Cap - Architecture & Rebuild Plan

> **Master Document** — This is the source of truth for the Simple Cap rebuild.
> Update this document when making significant architectural decisions or discovering issues.

**Last Updated:** 16 January 2026

---

## 1. Project Overview

**Simple Cap** is a cap table management app for Australian Pty Ltd companies. It tracks ownership, funding rounds, convertible instruments, employee equity, and provides scenario modeling tools.

### Key Decisions

| Decision              | Choice                   | Rationale                                            |
| --------------------- | ------------------------ | ---------------------------------------------------- |
| State Management      | **Riverpod**             | Modular, testable, industry standard                 |
| Persistence           | **SQLite (Drift)**       | Relational data, complex queries, Supabase sync path |
| Future Backend        | **Supabase**             | Keep schema compatible for eventual sync             |
| Primary Test Platform | **iOS**                  | User preference; all platforms supported             |
| Architecture          | **Domain-Driven Design** | Clean separation, testable business logic            |

### Terminology

| Old Term        | New Term         | Notes                                                       |
| --------------- | ---------------- | ----------------------------------------------------------- |
| Investors       | **Stakeholders** | Includes founders, employees, advisors — not just investors |
| Cap Table (tab) | **Ownership**    | Clearer purpose                                             |
| Rounds          | **Rounds**       | Kept as-is                                                  |

---

## 2. Project Structure

```
lib/
├── main.dart                      # Entry point
├── app.dart                       # MaterialApp + Riverpod setup
│
├── core/                          # Cross-cutting concerns
│   ├── theme/                     # Visual design system
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   └── spacing.dart
│   ├── extensions/                # Dart extension methods
│   └── errors/                    # Error types and handling
│
├── domain/                        # Pure business logic (no Flutter)
│   ├── entities/                  # ARCHIVED - Freezed entities (unused)
│   │   └── ...                    # Kept for reference, not imported
│   │
│   ├── constants/                 # Type-safe string constants
│   │   ├── constants.dart         # Barrel export
│   │   └── type_constants.dart    # StakeholderType, RoundStatus, etc.
│   │
│   └── services/                  # Pure calculation functions
│       ├── services.dart          # Barrel export
│       ├── conversion_calculator.dart  # SAFE/Note conversion math
│       ├── option_calculator.dart      # Option/warrant value calcs
│       ├── round_calculator.dart       # Round & holding helpers
│       └── vesting_calculator.dart     # Vesting schedule math
│
├── application/                   # Use cases / orchestration
│   └── providers/                 # Riverpod providers (see naming below)
│       ├── providers.dart         # Barrel export
│       ├── database_provider.dart
│       ├── company_provider.dart
│       ├── stakeholders_provider.dart
│       ├── share_classes_provider.dart
│       ├── rounds_provider.dart
│       ├── holdings_provider.dart
│       ├── convertibles_provider.dart
│       ├── options_provider.dart
│       ├── warrants_provider.dart
│       ├── valuations_provider.dart
│       ├── vesting_provider.dart
│       ├── transfers_provider.dart
│       └── scenarios_provider.dart
│
├── infrastructure/                # External systems
│   └── database/
│       ├── database.dart          # Drift database + CRUD operations
│       ├── database.g.dart        # Generated code
│       ├── tables.dart            # Table definitions
│       └── database_exports.dart  # Re-exports for UI
│
├── ui/                            # Presentation layer
│   ├── shell/                     # App navigation structure
│   │   └── app_shell.dart
│   │
│   ├── pages/                     # Full-screen pages
│   │   ├── overview/
│   │   ├── stakeholders/
│   │   ├── rounds/
│   │   ├── value/
│   │   ├── ownership/
│   │   ├── convertibles/
│   │   ├── options/
│   │   └── scenarios/
│   │
│   ├── components/                # Reusable UI components
│   │   ├── cards/
│   │   ├── inputs/
│   │   ├── feedback/
│   │   ├── dialogs/
│   │   └── avatars/
│   │
│   └── layouts/                   # Layout helpers
│       ├── responsive_grid.dart
│       └── sliver_page.dart
│
└── shared/                        # Shared utilities
    ├── formatters.dart
    └── validators.dart

_archive/                          # Old codebase for reference
├── lib/
└── assets/
```

---

## 3. Domain Model

### 3.1 Core Entities

```
┌─────────────────────────────────────────────────────────────────┐
│                         CAP TABLE                                │
│  (Event-sourced aggregate - single source of truth)             │
├─────────────────────────────────────────────────────────────────┤
│  Events: IssuanceEvent, TransferEvent, ConversionEvent, etc.    │
│  State:  Map<StakeholderId, List<Holding>>                      │
└─────────────────────────────────────────────────────────────────┘
            │
            │ produces
            ▼
┌─────────────────────────────────────────────────────────────────┐
│                      OWNERSHIP SNAPSHOT                          │
│  (Point-in-time view of who owns what)                          │
├─────────────────────────────────────────────────────────────────┤
│  totalIssuedShares, fullyDilutedShares                          │
│  positions: Map<StakeholderId, Position>                        │
│  byShareClass: Map<ShareClassId, ClassSummary>                  │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 Entity Relationships

```
Stakeholder ──────┬───── Holding ───── ShareClass
                  │
                  ├───── OptionGrant ── VestingSchedule
                  │         │
                  │         └───────── EsopPool
                  │
                  ├───── Warrant
                  │
                  └───── Convertible

EsopPool ─────────┬───── OptionGrant (multiple grants from pool)
                  │
                  └───── ShareClass (what options convert to)

Round ────────────┬───── Commitment (who invested what)
                  │
                  └───── ShareIssuance (resulting shares)
```

### 3.3 ESOP Pool Model

The ESOP (Employee Stock Ownership Plan) is modeled as:

| Concept     | Description                                               |
| ----------- | --------------------------------------------------------- |
| `EsopPool`  | Reserved shares for employee incentives                   |
| `poolSize`  | Total shares reserved in the pool                         |
| `allocated` | Shares granted as options (computed from OptionGrants)    |
| `available` | Remaining shares for future grants (poolSize - allocated) |
| `exercised` | Options converted to actual shares                        |

**Key relationships:**

- Each `EsopPool` references a `ShareClass` (what options convert to)
- Each `OptionGrant` can reference an `EsopPool` via `esopPoolId`
- Pool utilization is computed from associated grants

### 3.4 Capitalization Events (Event Sourcing)

All state changes are recorded as events:

| Event Type              | Description                               |
| ----------------------- | ----------------------------------------- |
| `ShareIssuance`         | New shares created (funding round, grant) |
| `ShareTransfer`         | Shares move between stakeholders          |
| `ShareCancellation`     | Shares cancelled (buyback, forfeiture)    |
| `ConvertibleIssuance`   | SAFE/Note issued                          |
| `ConvertibleConversion` | SAFE/Note converts to equity              |
| `OptionGrant`           | Options granted to stakeholder            |
| `OptionExercise`        | Options converted to shares               |
| `OptionCancellation`    | Options cancelled/forfeited               |
| `WarrantIssuance`       | Warrant issued                            |
| `WarrantExercise`       | Warrant converted to shares               |
| `RoundOpen`             | Financing round opened (draft)            |
| `RoundClose`            | Financing round finalized                 |

---

## 4. Database Schema (Drift/SQLite)

### 4.1 Core Tables

```sql
-- Legal entity being tracked
CREATE TABLE companies (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Anyone who can hold securities
CREATE TABLE stakeholders (
  id TEXT PRIMARY KEY,
  company_id TEXT NOT NULL REFERENCES companies(id),
  name TEXT NOT NULL,
  type TEXT NOT NULL,  -- founder, angel, vc_fund, employee, advisor, institution, other
  email TEXT,
  notes TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Types of shares with their rights
CREATE TABLE share_classes (
  id TEXT PRIMARY KEY,
  company_id TEXT NOT NULL REFERENCES companies(id),
  name TEXT NOT NULL,
  type TEXT NOT NULL,  -- ordinary, preference_a, preference_b, esop, etc.
  voting_multiplier REAL NOT NULL DEFAULT 1.0,
  liquidation_preference REAL NOT NULL DEFAULT 1.0,
  is_participating INTEGER NOT NULL DEFAULT 0,
  dividend_rate REAL NOT NULL DEFAULT 0,
  seniority INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Financing rounds
CREATE TABLE rounds (
  id TEXT PRIMARY KEY,
  company_id TEXT NOT NULL REFERENCES companies(id),
  name TEXT NOT NULL,
  type TEXT NOT NULL,  -- incorporation, seed, series_a, etc.
  status TEXT NOT NULL DEFAULT 'draft',  -- draft, closed
  date INTEGER NOT NULL,
  pre_money_valuation REAL,
  price_per_share REAL,
  lead_investor_id TEXT REFERENCES stakeholders(id),
  notes TEXT,
  display_order INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- The event log (event sourcing)
CREATE TABLE capitalization_events (
  id TEXT PRIMARY KEY,
  company_id TEXT NOT NULL REFERENCES companies(id),
  event_type TEXT NOT NULL,
  event_data TEXT NOT NULL,  -- JSON payload
  effective_date INTEGER NOT NULL,
  round_id TEXT REFERENCES rounds(id),
  created_at INTEGER NOT NULL
);

-- Materialized holdings (computed from events, can be rebuilt)
CREATE TABLE holdings (
  id TEXT PRIMARY KEY,
  company_id TEXT NOT NULL REFERENCES companies(id),
  stakeholder_id TEXT NOT NULL REFERENCES stakeholders(id),
  share_class_id TEXT NOT NULL REFERENCES share_classes(id),
  share_count INTEGER NOT NULL,
  cost_basis REAL NOT NULL,
  acquired_date INTEGER NOT NULL,
  vesting_schedule_id TEXT,
  updated_at INTEGER NOT NULL
);

-- Convertible instruments
CREATE TABLE convertibles (
  id TEXT PRIMARY KEY,
  company_id TEXT NOT NULL REFERENCES companies(id),
  stakeholder_id TEXT NOT NULL REFERENCES stakeholders(id),
  type TEXT NOT NULL,  -- safe, convertible_note
  status TEXT NOT NULL DEFAULT 'outstanding',  -- outstanding, converted, cancelled
  principal REAL NOT NULL,
  valuation_cap REAL,
  discount_percent REAL,
  interest_rate REAL,
  maturity_date INTEGER,
  issue_date INTEGER NOT NULL,
  has_mfn INTEGER NOT NULL DEFAULT 0,
  has_pro_rata INTEGER NOT NULL DEFAULT 0,
  notes TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Option grants
CREATE TABLE option_grants (
  id TEXT PRIMARY KEY,
  company_id TEXT NOT NULL REFERENCES companies(id),
  stakeholder_id TEXT NOT NULL REFERENCES stakeholders(id),
  share_class_id TEXT NOT NULL REFERENCES share_classes(id),
  status TEXT NOT NULL DEFAULT 'active',
  quantity INTEGER NOT NULL,
  strike_price REAL NOT NULL,
  grant_date INTEGER NOT NULL,
  expiry_date INTEGER NOT NULL,
  exercised_count INTEGER NOT NULL DEFAULT 0,
  cancelled_count INTEGER NOT NULL DEFAULT 0,
  vesting_schedule_id TEXT,
  notes TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Warrants
CREATE TABLE warrants (
  id TEXT PRIMARY KEY,
  company_id TEXT NOT NULL REFERENCES companies(id),
  stakeholder_id TEXT NOT NULL REFERENCES stakeholders(id),
  share_class_id TEXT NOT NULL REFERENCES share_classes(id),
  status TEXT NOT NULL DEFAULT 'active',
  quantity INTEGER NOT NULL,
  strike_price REAL NOT NULL,
  issue_date INTEGER NOT NULL,
  expiry_date INTEGER NOT NULL,
  exercised_count INTEGER NOT NULL DEFAULT 0,
  source_convertible_id TEXT REFERENCES convertibles(id),
  notes TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Vesting schedules (reusable templates)
CREATE TABLE vesting_schedules (
  id TEXT PRIMARY KEY,
  company_id TEXT NOT NULL REFERENCES companies(id),
  name TEXT NOT NULL,
  type TEXT NOT NULL,  -- time_based, milestone, hours
  total_months INTEGER,
  cliff_months INTEGER,
  vesting_frequency TEXT,  -- monthly, quarterly, annually
  schedule_data TEXT,  -- JSON for complex schedules
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Valuations (historical record)
CREATE TABLE valuations (
  id TEXT PRIMARY KEY,
  company_id TEXT NOT NULL REFERENCES companies(id),
  date INTEGER NOT NULL,
  pre_money_value REAL NOT NULL,
  method TEXT NOT NULL,
  method_params TEXT,  -- JSON
  notes TEXT,
  created_at INTEGER NOT NULL
);

-- Saved scenarios
CREATE TABLE saved_scenarios (
  id TEXT PRIMARY KEY,
  company_id TEXT NOT NULL REFERENCES companies(id),
  name TEXT NOT NULL,
  type TEXT NOT NULL,  -- dilution, exit_waterfall, new_round
  parameters TEXT NOT NULL,  -- JSON
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
```

### 4.2 Supabase Sync Considerations

- All tables have `id` as TEXT (UUID) for cross-device sync
- All tables have `created_at` and `updated_at` timestamps
- `company_id` on all tables for multi-tenancy
- Event log enables conflict resolution via event replay
- Consider adding `synced_at` and `local_only` columns later

---

## 5. Build Phases

### Phase 1: Foundation ✅

- [x] Archive old code
- [x] Fresh project structure
- [x] Theme system (colors, spacing)
- [x] App shell with navigation
- [x] Formatters utility
- [x] Add Riverpod dependency
- [x] Add Drift dependency
- [x] Database setup with 12 tables
- [x] Entity classes (10 Freezed models)

### Phase 2: Core Cap Table ✅

- [x] Stakeholder entity + repository
- [x] ShareClass entity + repository
- [x] Round entity + repository
- [x] Holdings computation (OwnershipSummary)
- [x] Riverpod providers (6 provider files)
- [x] Stakeholders page (list, add, edit, delete)
- [x] Rounds page (list, add, edit, delete, status workflow)
- [x] Ownership page (cap table view with breakdown)
- [x] Overview page (dashboard with metrics)
- [ ] CapitalizationEvent system (deferred - using direct CRUD for now)

### Phase 3: Convertibles ✅

- [x] Convertible provider with CRUD operations
- [x] SAFE modeling (cap, discount, MFN)
- [x] Convertible Note modeling (interest, maturity)
- [x] Conversion logic (round triggers)
- [x] Convertibles page (list, add, edit, convert, delete)
- [x] Navigation from Overview page

### Phase 4: ESOP ✅

- [x] OptionGrant provider with CRUD operations
- [x] Warrant provider with CRUD operations
- [x] Exercise logic (in options/warrants providers)
- [x] Options page (list, add, edit, exercise, delete)
- [x] Warrants page (list, add, edit, exercise, delete)
- [x] Navigation from Overview page
- [x] VestingSchedule entity + repository
- [x] Vesting engine (cliff, monthly, etc.)
- [x] Vesting provider with CRUD and calculations
- [x] Vesting visualization (VestingProgressBar, VestingChip)
- [x] Vesting schedule picker in option grant dialogs

### Phase 5: Valuations ✅

- [x] Valuations provider with CRUD operations
- [x] Value page (list, add, edit, delete)
- [x] Multiple valuation methods (manual, round-implied, DCF, 409A)
- [ ] Valuation history chart (deferred - nice to have)
- [ ] Link valuations to rounds (deferred - nice to have)

### Phase 6: Scenarios & Analytics ✅

- [x] Dilution calculator (scenarios_provider.dart)
- [x] Exit waterfall calculator (scenarios_provider.dart)
- [x] New round simulator (integrated in dilution calculator)
- [x] Saved scenarios persistence (SavedScenarios table + mutations)
- [x] Scenarios page with tabs (Dilution, Waterfall, Saved)
- [ ] Overview dashboard widgets (deferred)

### Phase 7: Polish & Export ⏳

- [x] Settings drawer (company details, preferences, data, about)
- [x] Help dialog (basic help in settings drawer)
- [ ] PDF/CSV export (UI scaffolded, implementation pending)
- [ ] Data import from CSV
- [ ] Example scenario loading (UI scaffolded, asset loading pending)
- [ ] Company switcher (UI in place, list companies pending)

### Phase 8: Monetization

Lock advanced features behind a premium tier. Initially controlled via settings toggle; later integrate payment provider.

**Free Tier (Core Cap Table):**

- Stakeholders management
- Share classes (Ordinary only)
- Rounds (up to 3)
- Basic ownership view
- Single valuation method (Manual)

**Premium Tier (Advanced Instruments):**

- Convertibles (SAFEs, Convertible Notes)
- Options & ESOP
- Warrants
- Multiple share class types (Preference A, B, etc.)
- All valuation methods (DCF, 409A, Round-implied)
- Scenarios (Dilution, Exit Waterfall)
- Unlimited rounds
- Export (PDF/CSV)

**Implementation Tasks:**

- [ ] `Feature` enum in `domain/value_objects/feature.dart`
- [ ] `FeatureGate` provider in `application/providers/`
- [ ] Premium toggle in Settings drawer (initial implementation)
- [ ] `FeatureGateWidget` component (shows locked state or upgrade prompt)
- [ ] Soft gates on Convertibles/Options/Warrants (view existing, can't add new)
- [ ] Hard gates on Scenarios/Export (full upgrade prompt)
- [ ] Lock indicators in navigation for premium tabs
- [ ] Entitlements table for persistence
- [ ] RevenueCat/App Store integration (future)
- [ ] Restore purchases flow (future)

**Gate Types:**

| Feature             | Gate | Behavior                               |
| ------------------- | ---- | -------------------------------------- |
| Convertibles        | Soft | Can view existing, can't add new       |
| Options             | Soft | Can view existing, can't grant new     |
| Warrants            | Soft | Can view existing, can't issue new     |
| Advanced Valuations | Soft | Show "Premium" badge, methods disabled |
| Scenarios           | Hard | Full upgrade prompt                    |
| Export              | Hard | Upgrade prompt on tap                  |
| Preference Shares   | Soft | Ordinary only, others show locked      |
| Unlimited Rounds    | Soft | Allow 3, then show limit reached       |

### Phase 9: Sync (Future)

- [ ] Supabase project setup
- [ ] Auth integration
- [ ] Sync service
- [ ] Conflict resolution
- [ ] Offline-first handling

---

## 6. UI Component Library

Rebuild these components fresh (reference `_archive/lib/shared/widgets/`):

| Component        | Status | Notes                                           |
| ---------------- | ------ | ----------------------------------------------- |
| `SectionCard`    | ✅     | Titled container with optional icon/trailing    |
| `StatCard`       | ✅     | Metric display with icon and color              |
| `SummaryCard`    | ✅     | Inline colored pill for page headers            |
| `ExpandableCard` | ✅     | List item with expand/collapse                  |
| `EmptyState`     | ✅     | No data placeholder                             |
| `InfoBox`        | ✅     | Contextual message (info/warning/error/success) |
| `AppTextField`   | ✅     | Consistent text input                           |
| `AppDropdown`    | ✅     | Consistent dropdown                             |
| `AppDatePicker`  | ✅     | Date selection field                            |
| `CurrencyField`  | ✅     | Money input with formatting                     |
| `PercentField`   | ⏳     | Percentage input                                |
| `EntityAvatar`   | ✅     | Colored circle with initial                     |
| `ConfirmDialog`  | ✅     | Yes/No confirmation                             |
| `DialogButtons`  | ✅     | Cancel, Primary, Delete, Warning                |
| `Snackbars`      | ✅     | Success, Error, Info helpers                    |
| `StatsGrid`      | ✅     | Grid layout for stat cards                      |
| `StatusBadge`    | ✅     | Colored status indicator                        |
| `MetricChip`     | ✅     | Small metric display chip                       |

---

## 7. Key Architectural Principles

1. **Domain Layer is Pure Dart**

   - No Flutter imports in `domain/`
   - All business logic testable without widgets

2. **Event Sourcing for Cap Table**

   - All ownership changes are events
   - Current state computed from event replay
   - Enables time-travel, audit trail, undo

3. **Repository Pattern**

   - Domain defines interfaces
   - Infrastructure implements with Drift
   - Easy to swap for Supabase later

4. **Commands vs Queries**

   - Commands: Write operations, validate, emit events
   - Queries: Read-only, computed views

5. **Draft vs Committed**

   - Rounds have `draft` and `closed` status
   - Draft round changes don't affect ownership
   - Closing a round commits all transactions

6. **Single Company Scope**

   - V1 supports one company per install
   - Schema ready for multi-company (Supabase)

7. **Drift Types as Single Source of Truth**
   - Database types (from `database.dart`) are used throughout the app
   - No separate domain entity classes (archived, not used)
   - Business logic extracted to `domain/services/` as pure functions
   - Type safety via `domain/constants/` string constants

---

## 8. Naming Equivalences

Our implementation uses different names than classic DDD/Clean Architecture, but the concepts map directly:

| Classic DDD Term    | Our Implementation               | Location                                  |
| ------------------- | -------------------------------- | ----------------------------------------- |
| **Commands**        | `*Mutations` notifiers           | `application/providers/*_provider.dart`   |
| **Queries**         | Computed providers (`@riverpod`) | `application/providers/*_provider.dart`   |
| **Repositories**    | `database.dart` CRUD methods     | `infrastructure/database/database.dart`   |
| **Domain Entities** | Drift-generated types            | `infrastructure/database/database.g.dart` |
| **Value Objects**   | String constants                 | `domain/constants/type_constants.dart`    |
| **Domain Services** | Calculator classes               | `domain/services/*.dart`                  |
| **Aggregates**      | N/A (deferred)                   | Event sourcing not implemented            |

### Provider Naming Convention

Each provider file typically contains:

```dart
// QUERIES (read operations)
@riverpod
Stream<List<Stakeholder>> stakeholdersStream(...);  // Watch all

@riverpod
Future<Stakeholder?> stakeholder(..., String id);   // Get one

@riverpod
Future<StakeholdersSummary> stakeholdersSummary(...);  // Computed

// COMMANDS (write operations)
@riverpod
class StakeholderMutations extends _$StakeholderMutations {
  Future<void> create({...});
  Future<void> update({...});
  Future<void> delete(String id);
}
```

---

## 9. Type Safety Without Enums

Since we use Drift-generated types (which use strings), we provide type safety via constants:

```dart
// ❌ Raw strings (error-prone)
if (round.status == 'draft') { ... }

// ✅ Constants (type-safe, autocomplete)
import 'package:cap_table/domain/constants/constants.dart';
if (round.status == RoundStatus.draft) { ... }

// ✅ Display names for UI
Text(StakeholderType.displayName(stakeholder.type))

// ✅ Helper methods
if (OptionGrantStatus.isExercisable(option.status)) { ... }
```

Available constant classes:

- `StakeholderType` - founder, employee, investor, etc.
- `ShareClassType` - ordinary, preferenceA, esop, etc.
- `RoundType` - seed, seriesA, bridge, etc.
- `RoundStatus` - draft, closed
- `ConvertibleType` - safe, convertibleNote
- `ConvertibleStatus` - outstanding, converted, cancelled
- `OptionGrantStatus` - pending, active, exercised, etc.
- `WarrantStatus` - pending, active, exercised, etc.
- `VestingType` - timeBased, milestone, immediate
- `VestingFrequency` - monthly, quarterly, annually
- `TransferStatus` - pending, approved, completed, cancelled

---

## 10. Domain Services

Pure calculation functions extracted for testability:

### ConversionCalculator

```dart
ConversionCalculator.accruedInterest(convertible);
ConversionCalculator.totalValue(convertible);
ConversionCalculator.effectivePrice(convertible: c, roundPricePerShare: p, preMoneyShares: s);
ConversionCalculator.sharesToReceive(...);
```

### OptionCalculator / WarrantCalculator

```dart
OptionCalculator.remaining(option);
OptionCalculator.intrinsicValue(option, currentPrice);
OptionCalculator.isExercisable(option);
OptionCalculator.isInTheMoney(option, currentPrice);
```

### VestingCalculator

```dart
VestingCalculator.vestingPercentAt(schedule: s, startDate: d, asOfDate: now);
VestingCalculator.unitsVestedAt(...);
VestingCalculator.isFullyVested(...);
VestingCalculator.monthsUntilCliff(...);
```

### RoundCalculator / HoldingCalculator / ShareClassCalculator

```dart
RoundCalculator.postMoneyValuation(round);
RoundCalculator.isDraft(round);
HoldingCalculator.pricePerShare(holding);
HoldingCalculator.vestingPercent(holding);
ShareClassCalculator.rightsSummary(shareClass);
```

---

## 11. Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Database
  drift: ^2.18.0
  sqlite3_flutter_libs: ^0.5.21
  path_provider: ^2.1.4
  path: ^1.9.0

  # Utilities
  uuid: ^4.5.1
  intl: ^0.20.2
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0

  # Charts
  fl_chart: ^1.1.1

  # File handling
  file_picker: ^8.0.0+1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

  # Code generation
  build_runner: ^2.4.9
  riverpod_generator: ^2.4.0
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  drift_dev: ^2.18.0
```

---

## 12. Change Log

| Date       | Change                            | Reason                                              |
| ---------- | --------------------------------- | --------------------------------------------------- |
| 2026-01-16 | Initial architecture document     | Project rebuild kickoff                             |
| 2026-01-16 | Chose Riverpod over Provider      | Modularity, testability                             |
| 2026-01-16 | Chose Drift/SQLite over JSON      | Supabase sync path, complex queries                 |
| 2026-01-16 | Renamed Investors → Stakeholders  | Accuracy (founders/employees aren't investors)      |
| 2026-01-16 | Renamed Cap Table tab → Ownership | Clearer purpose                                     |
| 2026-01-16 | Created domain entities           | 10 Freezed entity classes with business logic       |
| 2026-01-16 | Created database layer            | 12 Drift tables with CRUD operations                |
| 2026-01-16 | Created UI component library      | Cards, inputs, feedback, dialogs, badges            |
| 2026-01-16 | Ran code generation               | Freezed + Drift .g.dart files generated             |
| 2026-01-16 | Created Riverpod providers        | 13 provider files for state management              |
| 2026-01-16 | Built core pages                  | Overview, Stakeholders, Rounds, Ownership           |
| 2026-01-16 | Fixed schema mismatches           | Aligned providers with database column names        |
| 2026-01-16 | Cleaned up warnings               | Reduced from 31 to 18 (all info level)              |
| 2026-01-16 | Phase 1 & 2 complete              | Core cap table functionality working                |
| 2026-01-16 | Phase 3: Convertibles complete    | Added convertibles_provider + page                  |
| 2026-01-16 | Phase 4: ESOP complete            | Options + Warrants providers and pages              |
| 2026-01-16 | Phase 5: Valuations complete      | Added valuations_provider + value_page              |
| 2026-01-16 | Navigation added to Overview      | Quick actions link to Convertibles/Options/Warrants |
| 2026-01-16 | Phase 6: Scenarios complete       | Dilution + waterfall calculators, saved scenarios   |
| 2026-01-16 | Phase 7: Settings drawer          | Company details, preferences, data mgmt, help       |
| 2026-01-16 | iOS build successful              | flutter build ios completed without errors          |
| 2026-01-16 | Phase 4: Vesting complete         | VestingSchedule entity, provider, UI integration    |
| 2026-01-16 | Architecture cleanup              | Drift-only types, domain services, constants        |
| 2026-01-16 | Created domain/constants/         | Type-safe string constants for database values      |
| 2026-01-16 | Created domain/services/          | Pure calculation functions extracted from entities  |
| 2026-01-16 | Documented naming equivalences    | Commands=Mutations, Queries=Providers, etc.         |
| 2026-01-16 | Archived domain/entities/         | Freezed entities unused, Drift types are canonical  |

---

## 13. Open Questions

- [x] Should valuations be events or standalone records? → Standalone records
- [x] Drift types vs Domain entities? → Drift-only with services for logic
- [ ] How to handle ESOP pool expansion (event type)?
- [ ] Pro-rata rights tracking — on stakeholder or per-round?
- [ ] Australia-specific tax rules — domain or separate module?

---

## 14. Reference

- **Old codebase:** `_archive/lib/` and `_archive/assets/`
- **Design patterns:** See `_archive/lib/shared/widgets/` for UI patterns
- **Help content:** See `_archive/assets/help_content.json` for terminology
