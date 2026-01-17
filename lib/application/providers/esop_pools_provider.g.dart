// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'esop_pools_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$esopPoolsStreamHash() => r'2caed8a9b9dbc06023a658fc21002d0330715009';

/// Watches all ESOP pools for the current company.
/// Uses event sourcing when active, falls back to direct DB otherwise.
///
/// Copied from [esopPoolsStream].
@ProviderFor(esopPoolsStream)
final esopPoolsStreamProvider =
    AutoDisposeStreamProvider<List<EsopPool>>.internal(
      esopPoolsStream,
      name: r'esopPoolsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$esopPoolsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EsopPoolsStreamRef = AutoDisposeStreamProviderRef<List<EsopPool>>;
String _$esopPoolsHash() => r'c27d4b451ef7ed410c4b20a86d7f11d0e71af86b';

/// Gets the list of ESOP pools synchronously from the stream.
///
/// Copied from [esopPools].
@ProviderFor(esopPools)
final esopPoolsProvider = AutoDisposeProvider<List<EsopPool>>.internal(
  esopPools,
  name: r'esopPoolsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$esopPoolsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EsopPoolsRef = AutoDisposeProviderRef<List<EsopPool>>;
String _$esopPoolByIdHash() => r'9c16baffb56ec80d202dc340ab79555922ca3d42';

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

/// Gets a specific ESOP pool by ID.
///
/// Copied from [esopPoolById].
@ProviderFor(esopPoolById)
const esopPoolByIdProvider = EsopPoolByIdFamily();

/// Gets a specific ESOP pool by ID.
///
/// Copied from [esopPoolById].
class EsopPoolByIdFamily extends Family<AsyncValue<EsopPool?>> {
  /// Gets a specific ESOP pool by ID.
  ///
  /// Copied from [esopPoolById].
  const EsopPoolByIdFamily();

  /// Gets a specific ESOP pool by ID.
  ///
  /// Copied from [esopPoolById].
  EsopPoolByIdProvider call(String poolId) {
    return EsopPoolByIdProvider(poolId);
  }

  @override
  EsopPoolByIdProvider getProviderOverride(
    covariant EsopPoolByIdProvider provider,
  ) {
    return call(provider.poolId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'esopPoolByIdProvider';
}

/// Gets a specific ESOP pool by ID.
///
/// Copied from [esopPoolById].
class EsopPoolByIdProvider extends AutoDisposeFutureProvider<EsopPool?> {
  /// Gets a specific ESOP pool by ID.
  ///
  /// Copied from [esopPoolById].
  EsopPoolByIdProvider(String poolId)
    : this._internal(
        (ref) => esopPoolById(ref as EsopPoolByIdRef, poolId),
        from: esopPoolByIdProvider,
        name: r'esopPoolByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$esopPoolByIdHash,
        dependencies: EsopPoolByIdFamily._dependencies,
        allTransitiveDependencies:
            EsopPoolByIdFamily._allTransitiveDependencies,
        poolId: poolId,
      );

  EsopPoolByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.poolId,
  }) : super.internal();

  final String poolId;

  @override
  Override overrideWith(
    FutureOr<EsopPool?> Function(EsopPoolByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EsopPoolByIdProvider._internal(
        (ref) => create(ref as EsopPoolByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        poolId: poolId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<EsopPool?> createElement() {
    return _EsopPoolByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EsopPoolByIdProvider && other.poolId == poolId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, poolId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EsopPoolByIdRef on AutoDisposeFutureProviderRef<EsopPool?> {
  /// The parameter `poolId` of this provider.
  String get poolId;
}

class _EsopPoolByIdProviderElement
    extends AutoDisposeFutureProviderElement<EsopPool?>
    with EsopPoolByIdRef {
  _EsopPoolByIdProviderElement(super.provider);

  @override
  String get poolId => (origin as EsopPoolByIdProvider).poolId;
}

String _$poolOptionGrantsStreamHash() =>
    r'78edd0e5f73862999780b97dd92862174b24f969';

/// Watches option grants for a specific ESOP pool.
///
/// Copied from [poolOptionGrantsStream].
@ProviderFor(poolOptionGrantsStream)
const poolOptionGrantsStreamProvider = PoolOptionGrantsStreamFamily();

/// Watches option grants for a specific ESOP pool.
///
/// Copied from [poolOptionGrantsStream].
class PoolOptionGrantsStreamFamily
    extends Family<AsyncValue<List<OptionGrant>>> {
  /// Watches option grants for a specific ESOP pool.
  ///
  /// Copied from [poolOptionGrantsStream].
  const PoolOptionGrantsStreamFamily();

  /// Watches option grants for a specific ESOP pool.
  ///
  /// Copied from [poolOptionGrantsStream].
  PoolOptionGrantsStreamProvider call(String poolId) {
    return PoolOptionGrantsStreamProvider(poolId);
  }

  @override
  PoolOptionGrantsStreamProvider getProviderOverride(
    covariant PoolOptionGrantsStreamProvider provider,
  ) {
    return call(provider.poolId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'poolOptionGrantsStreamProvider';
}

/// Watches option grants for a specific ESOP pool.
///
/// Copied from [poolOptionGrantsStream].
class PoolOptionGrantsStreamProvider
    extends AutoDisposeStreamProvider<List<OptionGrant>> {
  /// Watches option grants for a specific ESOP pool.
  ///
  /// Copied from [poolOptionGrantsStream].
  PoolOptionGrantsStreamProvider(String poolId)
    : this._internal(
        (ref) =>
            poolOptionGrantsStream(ref as PoolOptionGrantsStreamRef, poolId),
        from: poolOptionGrantsStreamProvider,
        name: r'poolOptionGrantsStreamProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$poolOptionGrantsStreamHash,
        dependencies: PoolOptionGrantsStreamFamily._dependencies,
        allTransitiveDependencies:
            PoolOptionGrantsStreamFamily._allTransitiveDependencies,
        poolId: poolId,
      );

  PoolOptionGrantsStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.poolId,
  }) : super.internal();

  final String poolId;

  @override
  Override overrideWith(
    Stream<List<OptionGrant>> Function(PoolOptionGrantsStreamRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PoolOptionGrantsStreamProvider._internal(
        (ref) => create(ref as PoolOptionGrantsStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        poolId: poolId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<OptionGrant>> createElement() {
    return _PoolOptionGrantsStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PoolOptionGrantsStreamProvider && other.poolId == poolId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, poolId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PoolOptionGrantsStreamRef
    on AutoDisposeStreamProviderRef<List<OptionGrant>> {
  /// The parameter `poolId` of this provider.
  String get poolId;
}

class _PoolOptionGrantsStreamProviderElement
    extends AutoDisposeStreamProviderElement<List<OptionGrant>>
    with PoolOptionGrantsStreamRef {
  _PoolOptionGrantsStreamProviderElement(super.provider);

  @override
  String get poolId => (origin as PoolOptionGrantsStreamProvider).poolId;
}

String _$esopPoolSummaryHash() => r'3365b9601d6b8c3066177a101e89c517d3b1c327';

/// Provides detailed summary for an ESOP pool.
///
/// Copied from [esopPoolSummary].
@ProviderFor(esopPoolSummary)
const esopPoolSummaryProvider = EsopPoolSummaryFamily();

/// Provides detailed summary for an ESOP pool.
///
/// Copied from [esopPoolSummary].
class EsopPoolSummaryFamily extends Family<AsyncValue<EsopPoolSummary?>> {
  /// Provides detailed summary for an ESOP pool.
  ///
  /// Copied from [esopPoolSummary].
  const EsopPoolSummaryFamily();

  /// Provides detailed summary for an ESOP pool.
  ///
  /// Copied from [esopPoolSummary].
  EsopPoolSummaryProvider call(String poolId) {
    return EsopPoolSummaryProvider(poolId);
  }

  @override
  EsopPoolSummaryProvider getProviderOverride(
    covariant EsopPoolSummaryProvider provider,
  ) {
    return call(provider.poolId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'esopPoolSummaryProvider';
}

/// Provides detailed summary for an ESOP pool.
///
/// Copied from [esopPoolSummary].
class EsopPoolSummaryProvider
    extends AutoDisposeFutureProvider<EsopPoolSummary?> {
  /// Provides detailed summary for an ESOP pool.
  ///
  /// Copied from [esopPoolSummary].
  EsopPoolSummaryProvider(String poolId)
    : this._internal(
        (ref) => esopPoolSummary(ref as EsopPoolSummaryRef, poolId),
        from: esopPoolSummaryProvider,
        name: r'esopPoolSummaryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$esopPoolSummaryHash,
        dependencies: EsopPoolSummaryFamily._dependencies,
        allTransitiveDependencies:
            EsopPoolSummaryFamily._allTransitiveDependencies,
        poolId: poolId,
      );

  EsopPoolSummaryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.poolId,
  }) : super.internal();

  final String poolId;

  @override
  Override overrideWith(
    FutureOr<EsopPoolSummary?> Function(EsopPoolSummaryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EsopPoolSummaryProvider._internal(
        (ref) => create(ref as EsopPoolSummaryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        poolId: poolId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<EsopPoolSummary?> createElement() {
    return _EsopPoolSummaryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EsopPoolSummaryProvider && other.poolId == poolId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, poolId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EsopPoolSummaryRef on AutoDisposeFutureProviderRef<EsopPoolSummary?> {
  /// The parameter `poolId` of this provider.
  String get poolId;
}

class _EsopPoolSummaryProviderElement
    extends AutoDisposeFutureProviderElement<EsopPoolSummary?>
    with EsopPoolSummaryRef {
  _EsopPoolSummaryProviderElement(super.provider);

  @override
  String get poolId => (origin as EsopPoolSummaryProvider).poolId;
}

String _$allEsopPoolsSummaryHash() =>
    r'1db9c4d932eacd44d7d5289a04ebaad3531de352';

/// Aggregated summary across all ESOP pools.
///
/// Copied from [allEsopPoolsSummary].
@ProviderFor(allEsopPoolsSummary)
final allEsopPoolsSummaryProvider =
    AutoDisposeFutureProvider<AllPoolsSummary>.internal(
      allEsopPoolsSummary,
      name: r'allEsopPoolsSummaryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allEsopPoolsSummaryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllEsopPoolsSummaryRef = AutoDisposeFutureProviderRef<AllPoolsSummary>;
String _$canGrantFromPoolHash() => r'98c00f5b4bbe0f0e08e74e6d4f1e509842d720bd';

/// Checks if a grant can be made from a specific pool.
///
/// Copied from [canGrantFromPool].
@ProviderFor(canGrantFromPool)
const canGrantFromPoolProvider = CanGrantFromPoolFamily();

/// Checks if a grant can be made from a specific pool.
///
/// Copied from [canGrantFromPool].
class CanGrantFromPoolFamily extends Family<AsyncValue<bool>> {
  /// Checks if a grant can be made from a specific pool.
  ///
  /// Copied from [canGrantFromPool].
  const CanGrantFromPoolFamily();

  /// Checks if a grant can be made from a specific pool.
  ///
  /// Copied from [canGrantFromPool].
  CanGrantFromPoolProvider call({
    required String poolId,
    required int quantity,
  }) {
    return CanGrantFromPoolProvider(poolId: poolId, quantity: quantity);
  }

  @override
  CanGrantFromPoolProvider getProviderOverride(
    covariant CanGrantFromPoolProvider provider,
  ) {
    return call(poolId: provider.poolId, quantity: provider.quantity);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'canGrantFromPoolProvider';
}

/// Checks if a grant can be made from a specific pool.
///
/// Copied from [canGrantFromPool].
class CanGrantFromPoolProvider extends AutoDisposeFutureProvider<bool> {
  /// Checks if a grant can be made from a specific pool.
  ///
  /// Copied from [canGrantFromPool].
  CanGrantFromPoolProvider({required String poolId, required int quantity})
    : this._internal(
        (ref) => canGrantFromPool(
          ref as CanGrantFromPoolRef,
          poolId: poolId,
          quantity: quantity,
        ),
        from: canGrantFromPoolProvider,
        name: r'canGrantFromPoolProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$canGrantFromPoolHash,
        dependencies: CanGrantFromPoolFamily._dependencies,
        allTransitiveDependencies:
            CanGrantFromPoolFamily._allTransitiveDependencies,
        poolId: poolId,
        quantity: quantity,
      );

  CanGrantFromPoolProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.poolId,
    required this.quantity,
  }) : super.internal();

  final String poolId;
  final int quantity;

  @override
  Override overrideWith(
    FutureOr<bool> Function(CanGrantFromPoolRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CanGrantFromPoolProvider._internal(
        (ref) => create(ref as CanGrantFromPoolRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        poolId: poolId,
        quantity: quantity,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _CanGrantFromPoolProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CanGrantFromPoolProvider &&
        other.poolId == poolId &&
        other.quantity == quantity;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, poolId.hashCode);
    hash = _SystemHash.combine(hash, quantity.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CanGrantFromPoolRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `poolId` of this provider.
  String get poolId;

  /// The parameter `quantity` of this provider.
  int get quantity;
}

class _CanGrantFromPoolProviderElement
    extends AutoDisposeFutureProviderElement<bool>
    with CanGrantFromPoolRef {
  _CanGrantFromPoolProviderElement(super.provider);

  @override
  String get poolId => (origin as CanGrantFromPoolProvider).poolId;
  @override
  int get quantity => (origin as CanGrantFromPoolProvider).quantity;
}

String _$poolsNeedingExpansionHash() =>
    r'0ba4b791333bf6de4162252af48b13fd90a84d4d';

/// Detects pools that need expansion to meet their target percentage.
///
/// Copied from [poolsNeedingExpansion].
@ProviderFor(poolsNeedingExpansion)
final poolsNeedingExpansionProvider =
    AutoDisposeFutureProvider<List<PoolExpansionNeeded>>.internal(
      poolsNeedingExpansion,
      name: r'poolsNeedingExpansionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$poolsNeedingExpansionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PoolsNeedingExpansionRef =
    AutoDisposeFutureProviderRef<List<PoolExpansionNeeded>>;
String _$poolExpansionsStreamHash() =>
    r'585ac2df677a6d81f232c978a2ca5cd4a8679143';

/// Watches all pool expansions for the current company.
///
/// Copied from [poolExpansionsStream].
@ProviderFor(poolExpansionsStream)
final poolExpansionsStreamProvider =
    AutoDisposeStreamProvider<List<EsopPoolExpansion>>.internal(
      poolExpansionsStream,
      name: r'poolExpansionsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$poolExpansionsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PoolExpansionsStreamRef =
    AutoDisposeStreamProviderRef<List<EsopPoolExpansion>>;
String _$poolExpansionHistoryStreamHash() =>
    r'4cb86eef805a92cc505f197858932fb0d3f47702';

/// Watches expansions for a specific pool.
///
/// Copied from [poolExpansionHistoryStream].
@ProviderFor(poolExpansionHistoryStream)
const poolExpansionHistoryStreamProvider = PoolExpansionHistoryStreamFamily();

/// Watches expansions for a specific pool.
///
/// Copied from [poolExpansionHistoryStream].
class PoolExpansionHistoryStreamFamily
    extends Family<AsyncValue<List<EsopPoolExpansion>>> {
  /// Watches expansions for a specific pool.
  ///
  /// Copied from [poolExpansionHistoryStream].
  const PoolExpansionHistoryStreamFamily();

  /// Watches expansions for a specific pool.
  ///
  /// Copied from [poolExpansionHistoryStream].
  PoolExpansionHistoryStreamProvider call(String poolId) {
    return PoolExpansionHistoryStreamProvider(poolId);
  }

  @override
  PoolExpansionHistoryStreamProvider getProviderOverride(
    covariant PoolExpansionHistoryStreamProvider provider,
  ) {
    return call(provider.poolId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'poolExpansionHistoryStreamProvider';
}

/// Watches expansions for a specific pool.
///
/// Copied from [poolExpansionHistoryStream].
class PoolExpansionHistoryStreamProvider
    extends AutoDisposeStreamProvider<List<EsopPoolExpansion>> {
  /// Watches expansions for a specific pool.
  ///
  /// Copied from [poolExpansionHistoryStream].
  PoolExpansionHistoryStreamProvider(String poolId)
    : this._internal(
        (ref) => poolExpansionHistoryStream(
          ref as PoolExpansionHistoryStreamRef,
          poolId,
        ),
        from: poolExpansionHistoryStreamProvider,
        name: r'poolExpansionHistoryStreamProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$poolExpansionHistoryStreamHash,
        dependencies: PoolExpansionHistoryStreamFamily._dependencies,
        allTransitiveDependencies:
            PoolExpansionHistoryStreamFamily._allTransitiveDependencies,
        poolId: poolId,
      );

  PoolExpansionHistoryStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.poolId,
  }) : super.internal();

  final String poolId;

  @override
  Override overrideWith(
    Stream<List<EsopPoolExpansion>> Function(
      PoolExpansionHistoryStreamRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PoolExpansionHistoryStreamProvider._internal(
        (ref) => create(ref as PoolExpansionHistoryStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        poolId: poolId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<EsopPoolExpansion>> createElement() {
    return _PoolExpansionHistoryStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PoolExpansionHistoryStreamProvider &&
        other.poolId == poolId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, poolId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PoolExpansionHistoryStreamRef
    on AutoDisposeStreamProviderRef<List<EsopPoolExpansion>> {
  /// The parameter `poolId` of this provider.
  String get poolId;
}

class _PoolExpansionHistoryStreamProviderElement
    extends AutoDisposeStreamProviderElement<List<EsopPoolExpansion>>
    with PoolExpansionHistoryStreamRef {
  _PoolExpansionHistoryStreamProviderElement(super.provider);

  @override
  String get poolId => (origin as PoolExpansionHistoryStreamProvider).poolId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
