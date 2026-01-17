// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holdings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$holdingsStreamHash() => r'bf9d9266421735da9136f9f848c0c408c3a5fcae';

/// Watches all holdings for the current company.
/// Uses event sourcing when active, falls back to direct DB otherwise.
///
/// Copied from [holdingsStream].
@ProviderFor(holdingsStream)
final holdingsStreamProvider =
    AutoDisposeStreamProvider<List<Holding>>.internal(
      holdingsStream,
      name: r'holdingsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$holdingsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HoldingsStreamRef = AutoDisposeStreamProviderRef<List<Holding>>;
String _$stakeholderHoldingsHash() =>
    r'1c810671a8db8139890c7793d58185b23b1c03a4';

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

/// Gets holdings for a specific stakeholder.
/// Uses event sourcing when active, falls back to direct DB otherwise.
///
/// Copied from [stakeholderHoldings].
@ProviderFor(stakeholderHoldings)
const stakeholderHoldingsProvider = StakeholderHoldingsFamily();

/// Gets holdings for a specific stakeholder.
/// Uses event sourcing when active, falls back to direct DB otherwise.
///
/// Copied from [stakeholderHoldings].
class StakeholderHoldingsFamily extends Family<AsyncValue<List<Holding>>> {
  /// Gets holdings for a specific stakeholder.
  /// Uses event sourcing when active, falls back to direct DB otherwise.
  ///
  /// Copied from [stakeholderHoldings].
  const StakeholderHoldingsFamily();

  /// Gets holdings for a specific stakeholder.
  /// Uses event sourcing when active, falls back to direct DB otherwise.
  ///
  /// Copied from [stakeholderHoldings].
  StakeholderHoldingsProvider call(String stakeholderId) {
    return StakeholderHoldingsProvider(stakeholderId);
  }

  @override
  StakeholderHoldingsProvider getProviderOverride(
    covariant StakeholderHoldingsProvider provider,
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
  String? get name => r'stakeholderHoldingsProvider';
}

/// Gets holdings for a specific stakeholder.
/// Uses event sourcing when active, falls back to direct DB otherwise.
///
/// Copied from [stakeholderHoldings].
class StakeholderHoldingsProvider
    extends AutoDisposeStreamProvider<List<Holding>> {
  /// Gets holdings for a specific stakeholder.
  /// Uses event sourcing when active, falls back to direct DB otherwise.
  ///
  /// Copied from [stakeholderHoldings].
  StakeholderHoldingsProvider(String stakeholderId)
    : this._internal(
        (ref) =>
            stakeholderHoldings(ref as StakeholderHoldingsRef, stakeholderId),
        from: stakeholderHoldingsProvider,
        name: r'stakeholderHoldingsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$stakeholderHoldingsHash,
        dependencies: StakeholderHoldingsFamily._dependencies,
        allTransitiveDependencies:
            StakeholderHoldingsFamily._allTransitiveDependencies,
        stakeholderId: stakeholderId,
      );

  StakeholderHoldingsProvider._internal(
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
    Stream<List<Holding>> Function(StakeholderHoldingsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StakeholderHoldingsProvider._internal(
        (ref) => create(ref as StakeholderHoldingsRef),
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
  AutoDisposeStreamProviderElement<List<Holding>> createElement() {
    return _StakeholderHoldingsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StakeholderHoldingsProvider &&
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
mixin StakeholderHoldingsRef on AutoDisposeStreamProviderRef<List<Holding>> {
  /// The parameter `stakeholderId` of this provider.
  String get stakeholderId;
}

class _StakeholderHoldingsProviderElement
    extends AutoDisposeStreamProviderElement<List<Holding>>
    with StakeholderHoldingsRef {
  _StakeholderHoldingsProviderElement(super.provider);

  @override
  String get stakeholderId =>
      (origin as StakeholderHoldingsProvider).stakeholderId;
}

String _$ownershipSummaryHash() => r'c3d6da6fe135ba250c12be366d8ee31fbd944dcd';

/// Calculates ownership summary for the cap table.
///
/// Copied from [ownershipSummary].
@ProviderFor(ownershipSummary)
final ownershipSummaryProvider =
    AutoDisposeFutureProvider<OwnershipSummary>.internal(
      ownershipSummary,
      name: r'ownershipSummaryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$ownershipSummaryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OwnershipSummaryRef = AutoDisposeFutureProviderRef<OwnershipSummary>;
String _$draftRoundIdsHash() => r'3363e7b6015e640e94561084728e2955e186e587';

/// Map of roundId to isDraft status for quick lookup.
///
/// Copied from [draftRoundIds].
@ProviderFor(draftRoundIds)
final draftRoundIdsProvider =
    AutoDisposeFutureProvider<Map<String, bool>>.internal(
      draftRoundIds,
      name: r'draftRoundIdsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$draftRoundIdsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DraftRoundIdsRef = AutoDisposeFutureProviderRef<Map<String, bool>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
