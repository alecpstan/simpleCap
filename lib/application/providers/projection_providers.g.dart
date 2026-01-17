// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projection_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$capTableStateHash() => r'b8e3a751694275bd3938c87c7be28faa28210da1';

/// The main projected state for the current company.
///
/// This is computed by folding over all events. It provides the complete
/// materialized view of the cap table that the UI consumes.
///
/// Copied from [capTableState].
@ProviderFor(capTableState)
final capTableStateProvider =
    AutoDisposeFutureProvider<CapTableState?>.internal(
      capTableState,
      name: r'capTableStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$capTableStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CapTableStateRef = AutoDisposeFutureProviderRef<CapTableState?>;
String _$capTableStateStreamHash() =>
    r'38f995a096f49435b8202f670b325492c01d1cdc';

/// Stream version of cap table state for reactive updates.
///
/// Copied from [capTableStateStream].
@ProviderFor(capTableStateStream)
final capTableStateStreamProvider =
    AutoDisposeStreamProvider<CapTableState?>.internal(
      capTableStateStream,
      name: r'capTableStateStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$capTableStateStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CapTableStateStreamRef = AutoDisposeStreamProviderRef<CapTableState?>;
String _$projectedStakeholdersHash() =>
    r'b2e89b0d756734fe98bce023e4c167f73b0b1d1e';

/// All stakeholders from projected state.
///
/// Copied from [projectedStakeholders].
@ProviderFor(projectedStakeholders)
final projectedStakeholdersProvider =
    AutoDisposeFutureProvider<List<StakeholderState>>.internal(
      projectedStakeholders,
      name: r'projectedStakeholdersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$projectedStakeholdersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProjectedStakeholdersRef =
    AutoDisposeFutureProviderRef<List<StakeholderState>>;
String _$projectedStakeholdersByTypeHash() =>
    r'09b5eb3abb8eae86270fca271a7c0f4ab3d5770a';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Stakeholders filtered by type.
///
/// Copied from [projectedStakeholdersByType].
@ProviderFor(projectedStakeholdersByType)
const projectedStakeholdersByTypeProvider = ProjectedStakeholdersByTypeFamily();

/// Stakeholders filtered by type.
///
/// Copied from [projectedStakeholdersByType].
class ProjectedStakeholdersByTypeFamily
    extends Family<AsyncValue<List<StakeholderState>>> {
  /// Stakeholders filtered by type.
  ///
  /// Copied from [projectedStakeholdersByType].
  const ProjectedStakeholdersByTypeFamily();

  /// Stakeholders filtered by type.
  ///
  /// Copied from [projectedStakeholdersByType].
  ProjectedStakeholdersByTypeProvider call(String type) {
    return ProjectedStakeholdersByTypeProvider(type);
  }

  @override
  ProjectedStakeholdersByTypeProvider getProviderOverride(
    covariant ProjectedStakeholdersByTypeProvider provider,
  ) {
    return call(provider.type);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'projectedStakeholdersByTypeProvider';
}

/// Stakeholders filtered by type.
///
/// Copied from [projectedStakeholdersByType].
class ProjectedStakeholdersByTypeProvider
    extends AutoDisposeFutureProvider<List<StakeholderState>> {
  /// Stakeholders filtered by type.
  ///
  /// Copied from [projectedStakeholdersByType].
  ProjectedStakeholdersByTypeProvider(String type)
    : this._internal(
        (ref) => projectedStakeholdersByType(
          ref as ProjectedStakeholdersByTypeRef,
          type,
        ),
        from: projectedStakeholdersByTypeProvider,
        name: r'projectedStakeholdersByTypeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$projectedStakeholdersByTypeHash,
        dependencies: ProjectedStakeholdersByTypeFamily._dependencies,
        allTransitiveDependencies:
            ProjectedStakeholdersByTypeFamily._allTransitiveDependencies,
        type: type,
      );

  ProjectedStakeholdersByTypeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.type,
  }) : super.internal();

  final String type;

  @override
  Override overrideWith(
    FutureOr<List<StakeholderState>> Function(
      ProjectedStakeholdersByTypeRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProjectedStakeholdersByTypeProvider._internal(
        (ref) => create(ref as ProjectedStakeholdersByTypeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        type: type,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<StakeholderState>> createElement() {
    return _ProjectedStakeholdersByTypeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectedStakeholdersByTypeProvider && other.type == type;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProjectedStakeholdersByTypeRef
    on AutoDisposeFutureProviderRef<List<StakeholderState>> {
  /// The parameter `type` of this provider.
  String get type;
}

class _ProjectedStakeholdersByTypeProviderElement
    extends AutoDisposeFutureProviderElement<List<StakeholderState>>
    with ProjectedStakeholdersByTypeRef {
  _ProjectedStakeholdersByTypeProviderElement(super.provider);

  @override
  String get type => (origin as ProjectedStakeholdersByTypeProvider).type;
}

String _$projectedShareClassesHash() =>
    r'd0a939c1425c4c0073649f1f219e6a4318bfbaf0';

/// All share classes from projected state.
///
/// Copied from [projectedShareClasses].
@ProviderFor(projectedShareClasses)
final projectedShareClassesProvider =
    AutoDisposeFutureProvider<List<ShareClassState>>.internal(
      projectedShareClasses,
      name: r'projectedShareClassesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$projectedShareClassesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProjectedShareClassesRef =
    AutoDisposeFutureProviderRef<List<ShareClassState>>;
String _$projectedRoundsHash() => r'2e452908f0c99dd053fcc0147ae79d88d1fb78fc';

/// All rounds from projected state, sorted by display order.
///
/// Copied from [projectedRounds].
@ProviderFor(projectedRounds)
final projectedRoundsProvider =
    AutoDisposeFutureProvider<List<RoundState>>.internal(
      projectedRounds,
      name: r'projectedRoundsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$projectedRoundsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProjectedRoundsRef = AutoDisposeFutureProviderRef<List<RoundState>>;
String _$projectedRoundsByStatusHash() =>
    r'78caa552addaa4b1173a32d377c73f910148bfeb';

/// Rounds filtered by status.
///
/// Copied from [projectedRoundsByStatus].
@ProviderFor(projectedRoundsByStatus)
const projectedRoundsByStatusProvider = ProjectedRoundsByStatusFamily();

/// Rounds filtered by status.
///
/// Copied from [projectedRoundsByStatus].
class ProjectedRoundsByStatusFamily
    extends Family<AsyncValue<List<RoundState>>> {
  /// Rounds filtered by status.
  ///
  /// Copied from [projectedRoundsByStatus].
  const ProjectedRoundsByStatusFamily();

  /// Rounds filtered by status.
  ///
  /// Copied from [projectedRoundsByStatus].
  ProjectedRoundsByStatusProvider call(String status) {
    return ProjectedRoundsByStatusProvider(status);
  }

  @override
  ProjectedRoundsByStatusProvider getProviderOverride(
    covariant ProjectedRoundsByStatusProvider provider,
  ) {
    return call(provider.status);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'projectedRoundsByStatusProvider';
}

/// Rounds filtered by status.
///
/// Copied from [projectedRoundsByStatus].
class ProjectedRoundsByStatusProvider
    extends AutoDisposeFutureProvider<List<RoundState>> {
  /// Rounds filtered by status.
  ///
  /// Copied from [projectedRoundsByStatus].
  ProjectedRoundsByStatusProvider(String status)
    : this._internal(
        (ref) =>
            projectedRoundsByStatus(ref as ProjectedRoundsByStatusRef, status),
        from: projectedRoundsByStatusProvider,
        name: r'projectedRoundsByStatusProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$projectedRoundsByStatusHash,
        dependencies: ProjectedRoundsByStatusFamily._dependencies,
        allTransitiveDependencies:
            ProjectedRoundsByStatusFamily._allTransitiveDependencies,
        status: status,
      );

  ProjectedRoundsByStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
  }) : super.internal();

  final String status;

  @override
  Override overrideWith(
    FutureOr<List<RoundState>> Function(ProjectedRoundsByStatusRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProjectedRoundsByStatusProvider._internal(
        (ref) => create(ref as ProjectedRoundsByStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<RoundState>> createElement() {
    return _ProjectedRoundsByStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectedRoundsByStatusProvider && other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProjectedRoundsByStatusRef
    on AutoDisposeFutureProviderRef<List<RoundState>> {
  /// The parameter `status` of this provider.
  String get status;
}

class _ProjectedRoundsByStatusProviderElement
    extends AutoDisposeFutureProviderElement<List<RoundState>>
    with ProjectedRoundsByStatusRef {
  _ProjectedRoundsByStatusProviderElement(super.provider);

  @override
  String get status => (origin as ProjectedRoundsByStatusProvider).status;
}

String _$projectedHoldingsHash() => r'6c5ee8e5842da9e74b6f0ce68e62ed1e7b417e96';

/// All holdings from projected state.
///
/// Copied from [projectedHoldings].
@ProviderFor(projectedHoldings)
final projectedHoldingsProvider =
    AutoDisposeFutureProvider<List<HoldingState>>.internal(
      projectedHoldings,
      name: r'projectedHoldingsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$projectedHoldingsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProjectedHoldingsRef = AutoDisposeFutureProviderRef<List<HoldingState>>;
String _$projectedStakeholderHoldingsHash() =>
    r'cc1bb1d334c52107d6ee4982f0b38aceafe3fda4';

/// Holdings for a specific stakeholder.
///
/// Copied from [projectedStakeholderHoldings].
@ProviderFor(projectedStakeholderHoldings)
const projectedStakeholderHoldingsProvider =
    ProjectedStakeholderHoldingsFamily();

/// Holdings for a specific stakeholder.
///
/// Copied from [projectedStakeholderHoldings].
class ProjectedStakeholderHoldingsFamily
    extends Family<AsyncValue<List<HoldingState>>> {
  /// Holdings for a specific stakeholder.
  ///
  /// Copied from [projectedStakeholderHoldings].
  const ProjectedStakeholderHoldingsFamily();

  /// Holdings for a specific stakeholder.
  ///
  /// Copied from [projectedStakeholderHoldings].
  ProjectedStakeholderHoldingsProvider call(String stakeholderId) {
    return ProjectedStakeholderHoldingsProvider(stakeholderId);
  }

  @override
  ProjectedStakeholderHoldingsProvider getProviderOverride(
    covariant ProjectedStakeholderHoldingsProvider provider,
  ) {
    return call(provider.stakeholderId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'projectedStakeholderHoldingsProvider';
}

/// Holdings for a specific stakeholder.
///
/// Copied from [projectedStakeholderHoldings].
class ProjectedStakeholderHoldingsProvider
    extends AutoDisposeFutureProvider<List<HoldingState>> {
  /// Holdings for a specific stakeholder.
  ///
  /// Copied from [projectedStakeholderHoldings].
  ProjectedStakeholderHoldingsProvider(String stakeholderId)
    : this._internal(
        (ref) => projectedStakeholderHoldings(
          ref as ProjectedStakeholderHoldingsRef,
          stakeholderId,
        ),
        from: projectedStakeholderHoldingsProvider,
        name: r'projectedStakeholderHoldingsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$projectedStakeholderHoldingsHash,
        dependencies: ProjectedStakeholderHoldingsFamily._dependencies,
        allTransitiveDependencies:
            ProjectedStakeholderHoldingsFamily._allTransitiveDependencies,
        stakeholderId: stakeholderId,
      );

  ProjectedStakeholderHoldingsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.stakeholderId,
  }) : super.internal();

  final String stakeholderId;

  @override
  Override overrideWith(
    FutureOr<List<HoldingState>> Function(
      ProjectedStakeholderHoldingsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProjectedStakeholderHoldingsProvider._internal(
        (ref) => create(ref as ProjectedStakeholderHoldingsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        stakeholderId: stakeholderId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<HoldingState>> createElement() {
    return _ProjectedStakeholderHoldingsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectedStakeholderHoldingsProvider &&
        other.stakeholderId == stakeholderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, stakeholderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProjectedStakeholderHoldingsRef
    on AutoDisposeFutureProviderRef<List<HoldingState>> {
  /// The parameter `stakeholderId` of this provider.
  String get stakeholderId;
}

class _ProjectedStakeholderHoldingsProviderElement
    extends AutoDisposeFutureProviderElement<List<HoldingState>>
    with ProjectedStakeholderHoldingsRef {
  _ProjectedStakeholderHoldingsProviderElement(super.provider);

  @override
  String get stakeholderId =>
      (origin as ProjectedStakeholderHoldingsProvider).stakeholderId;
}

String _$projectedConvertiblesHash() =>
    r'ebb4f8946bc8e4468986c7d55e53316fa0b3bb3b';

/// All convertibles from projected state.
///
/// Copied from [projectedConvertibles].
@ProviderFor(projectedConvertibles)
final projectedConvertiblesProvider =
    AutoDisposeFutureProvider<List<ConvertibleState>>.internal(
      projectedConvertibles,
      name: r'projectedConvertiblesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$projectedConvertiblesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProjectedConvertiblesRef =
    AutoDisposeFutureProviderRef<List<ConvertibleState>>;
String _$projectedOutstandingConvertiblesHash() =>
    r'ba3729452fbfe81aea34ceaffefe1b5806edf5a4';

/// Outstanding convertibles only.
///
/// Copied from [projectedOutstandingConvertibles].
@ProviderFor(projectedOutstandingConvertibles)
final projectedOutstandingConvertiblesProvider =
    AutoDisposeFutureProvider<List<ConvertibleState>>.internal(
      projectedOutstandingConvertibles,
      name: r'projectedOutstandingConvertiblesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$projectedOutstandingConvertiblesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProjectedOutstandingConvertiblesRef =
    AutoDisposeFutureProviderRef<List<ConvertibleState>>;
String _$projectedEsopPoolsHash() =>
    r'1867af3a5c9fe6de1cb17cb0695595aaf70dab38';

/// All ESOP pools from projected state.
///
/// Copied from [projectedEsopPools].
@ProviderFor(projectedEsopPools)
final projectedEsopPoolsProvider =
    AutoDisposeFutureProvider<List<EsopPoolState>>.internal(
      projectedEsopPools,
      name: r'projectedEsopPoolsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$projectedEsopPoolsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProjectedEsopPoolsRef =
    AutoDisposeFutureProviderRef<List<EsopPoolState>>;
String _$projectedOptionGrantsHash() =>
    r'ff6d6a544b14ba36dfa80230022e46a650a93c46';

/// All option grants from projected state.
///
/// Copied from [projectedOptionGrants].
@ProviderFor(projectedOptionGrants)
final projectedOptionGrantsProvider =
    AutoDisposeFutureProvider<List<OptionGrantState>>.internal(
      projectedOptionGrants,
      name: r'projectedOptionGrantsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$projectedOptionGrantsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProjectedOptionGrantsRef =
    AutoDisposeFutureProviderRef<List<OptionGrantState>>;
String _$projectedWarrantsHash() => r'05314f3b7bf07ce3b1dc74c3e94f800efcfd0f24';

/// All warrants from projected state.
///
/// Copied from [projectedWarrants].
@ProviderFor(projectedWarrants)
final projectedWarrantsProvider =
    AutoDisposeFutureProvider<List<WarrantState>>.internal(
      projectedWarrants,
      name: r'projectedWarrantsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$projectedWarrantsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProjectedWarrantsRef = AutoDisposeFutureProviderRef<List<WarrantState>>;
String _$projectedVestingSchedulesHash() =>
    r'633b0e924d98e6202673ac0d9c9fa4b9439bb47e';

/// All vesting schedules from projected state.
///
/// Copied from [projectedVestingSchedules].
@ProviderFor(projectedVestingSchedules)
final projectedVestingSchedulesProvider =
    AutoDisposeFutureProvider<List<VestingScheduleState>>.internal(
      projectedVestingSchedules,
      name: r'projectedVestingSchedulesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$projectedVestingSchedulesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProjectedVestingSchedulesRef =
    AutoDisposeFutureProviderRef<List<VestingScheduleState>>;
String _$projectedValuationsHash() =>
    r'2836d0ce06d45989cd69ae2c4da01c1efea9c2e6';

/// All valuations from projected state, sorted by date descending.
///
/// Copied from [projectedValuations].
@ProviderFor(projectedValuations)
final projectedValuationsProvider =
    AutoDisposeFutureProvider<List<ValuationState>>.internal(
      projectedValuations,
      name: r'projectedValuationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$projectedValuationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProjectedValuationsRef =
    AutoDisposeFutureProviderRef<List<ValuationState>>;
String _$projectedLatestValuationHash() =>
    r'89cc25ca18f619ae9d90712662bee6a5eeaf8b22';

/// Latest valuation (most recent by date).
///
/// Copied from [projectedLatestValuation].
@ProviderFor(projectedLatestValuation)
final projectedLatestValuationProvider =
    AutoDisposeFutureProvider<ValuationState?>.internal(
      projectedLatestValuation,
      name: r'projectedLatestValuationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$projectedLatestValuationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProjectedLatestValuationRef =
    AutoDisposeFutureProviderRef<ValuationState?>;
String _$projectedTransfersHash() =>
    r'6154507f10f1fded3f27b2a1ecfa05ad61a5865b';

/// All transfers from projected state.
///
/// Copied from [projectedTransfers].
@ProviderFor(projectedTransfers)
final projectedTransfersProvider =
    AutoDisposeFutureProvider<List<TransferState>>.internal(
      projectedTransfers,
      name: r'projectedTransfersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$projectedTransfersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProjectedTransfersRef =
    AutoDisposeFutureProviderRef<List<TransferState>>;
String _$projectedOwnershipSummaryHash() =>
    r'2240dc8150b88f50b21a6a0a05554fb5035bf5ff';

/// Ownership summary computed from projected state.
///
/// Copied from [projectedOwnershipSummary].
@ProviderFor(projectedOwnershipSummary)
final projectedOwnershipSummaryProvider =
    AutoDisposeFutureProvider<ProjectedOwnershipSummary>.internal(
      projectedOwnershipSummary,
      name: r'projectedOwnershipSummaryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$projectedOwnershipSummaryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProjectedOwnershipSummaryRef =
    AutoDisposeFutureProviderRef<ProjectedOwnershipSummary>;
String _$projectedRoundsSummaryHash() =>
    r'363e85caf0baf90c2c13e2db5ae2ea52d93c7282';

/// Rounds summary computed from projected state.
///
/// Copied from [projectedRoundsSummary].
@ProviderFor(projectedRoundsSummary)
final projectedRoundsSummaryProvider =
    AutoDisposeFutureProvider<ProjectedRoundsSummary>.internal(
      projectedRoundsSummary,
      name: r'projectedRoundsSummaryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$projectedRoundsSummaryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProjectedRoundsSummaryRef =
    AutoDisposeFutureProviderRef<ProjectedRoundsSummary>;
String _$projectedConvertiblesSummaryHash() =>
    r'3fe9da92382f704e8e2e072001f7c1b04c1e461c';

/// Convertibles summary computed from projected state.
///
/// Copied from [projectedConvertiblesSummary].
@ProviderFor(projectedConvertiblesSummary)
final projectedConvertiblesSummaryProvider =
    AutoDisposeFutureProvider<ProjectedConvertiblesSummary>.internal(
      projectedConvertiblesSummary,
      name: r'projectedConvertiblesSummaryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$projectedConvertiblesSummaryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProjectedConvertiblesSummaryRef =
    AutoDisposeFutureProviderRef<ProjectedConvertiblesSummary>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
