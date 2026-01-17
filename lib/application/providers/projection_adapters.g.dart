// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projection_adapters.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unifiedStakeholdersStreamHash() =>
    r'f0844a9a408d5961af07f4d6014d60d95c478cf1';

/// Stakeholders provider using event-sourced projections.
///
/// Copied from [unifiedStakeholdersStream].
@ProviderFor(unifiedStakeholdersStream)
final unifiedStakeholdersStreamProvider =
    AutoDisposeStreamProvider<List<Stakeholder>>.internal(
      unifiedStakeholdersStream,
      name: r'unifiedStakeholdersStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$unifiedStakeholdersStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnifiedStakeholdersStreamRef =
    AutoDisposeStreamProviderRef<List<Stakeholder>>;
String _$unifiedRoundsStreamHash() =>
    r'570fdeaef113e2a54faab397e6ad0790576383dc';

/// Rounds provider using event-sourced projections.
///
/// Copied from [unifiedRoundsStream].
@ProviderFor(unifiedRoundsStream)
final unifiedRoundsStreamProvider =
    AutoDisposeStreamProvider<List<Round>>.internal(
      unifiedRoundsStream,
      name: r'unifiedRoundsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$unifiedRoundsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnifiedRoundsStreamRef = AutoDisposeStreamProviderRef<List<Round>>;
String _$unifiedHoldingsStreamHash() =>
    r'0a83b3c37726c0ad999864ff29f84ae08d1d318f';

/// Holdings provider using event-sourced projections.
///
/// Copied from [unifiedHoldingsStream].
@ProviderFor(unifiedHoldingsStream)
final unifiedHoldingsStreamProvider =
    AutoDisposeStreamProvider<List<Holding>>.internal(
      unifiedHoldingsStream,
      name: r'unifiedHoldingsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$unifiedHoldingsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnifiedHoldingsStreamRef = AutoDisposeStreamProviderRef<List<Holding>>;
String _$unifiedStakeholderHoldingsHash() =>
    r'174341497c459bb6d2c610da43d074bdd191bfbb';

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

/// Stakeholder holdings provider using event-sourced projections.
///
/// Copied from [unifiedStakeholderHoldings].
@ProviderFor(unifiedStakeholderHoldings)
const unifiedStakeholderHoldingsProvider = UnifiedStakeholderHoldingsFamily();

/// Stakeholder holdings provider using event-sourced projections.
///
/// Copied from [unifiedStakeholderHoldings].
class UnifiedStakeholderHoldingsFamily
    extends Family<AsyncValue<List<Holding>>> {
  /// Stakeholder holdings provider using event-sourced projections.
  ///
  /// Copied from [unifiedStakeholderHoldings].
  const UnifiedStakeholderHoldingsFamily();

  /// Stakeholder holdings provider using event-sourced projections.
  ///
  /// Copied from [unifiedStakeholderHoldings].
  UnifiedStakeholderHoldingsProvider call(String stakeholderId) {
    return UnifiedStakeholderHoldingsProvider(stakeholderId);
  }

  @override
  UnifiedStakeholderHoldingsProvider getProviderOverride(
    covariant UnifiedStakeholderHoldingsProvider provider,
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
  String? get name => r'unifiedStakeholderHoldingsProvider';
}

/// Stakeholder holdings provider using event-sourced projections.
///
/// Copied from [unifiedStakeholderHoldings].
class UnifiedStakeholderHoldingsProvider
    extends AutoDisposeStreamProvider<List<Holding>> {
  /// Stakeholder holdings provider using event-sourced projections.
  ///
  /// Copied from [unifiedStakeholderHoldings].
  UnifiedStakeholderHoldingsProvider(String stakeholderId)
    : this._internal(
        (ref) => unifiedStakeholderHoldings(
          ref as UnifiedStakeholderHoldingsRef,
          stakeholderId,
        ),
        from: unifiedStakeholderHoldingsProvider,
        name: r'unifiedStakeholderHoldingsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$unifiedStakeholderHoldingsHash,
        dependencies: UnifiedStakeholderHoldingsFamily._dependencies,
        allTransitiveDependencies:
            UnifiedStakeholderHoldingsFamily._allTransitiveDependencies,
        stakeholderId: stakeholderId,
      );

  UnifiedStakeholderHoldingsProvider._internal(
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
    Stream<List<Holding>> Function(UnifiedStakeholderHoldingsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UnifiedStakeholderHoldingsProvider._internal(
        (ref) => create(ref as UnifiedStakeholderHoldingsRef),
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
    return _UnifiedStakeholderHoldingsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UnifiedStakeholderHoldingsProvider &&
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
mixin UnifiedStakeholderHoldingsRef
    on AutoDisposeStreamProviderRef<List<Holding>> {
  /// The parameter `stakeholderId` of this provider.
  String get stakeholderId;
}

class _UnifiedStakeholderHoldingsProviderElement
    extends AutoDisposeStreamProviderElement<List<Holding>>
    with UnifiedStakeholderHoldingsRef {
  _UnifiedStakeholderHoldingsProviderElement(super.provider);

  @override
  String get stakeholderId =>
      (origin as UnifiedStakeholderHoldingsProvider).stakeholderId;
}

String _$unifiedShareClassesStreamHash() =>
    r'1b66b24acf9313c8ca0a4c540036fd5f9e56fc4a';

/// Share classes provider using event-sourced projections.
///
/// Copied from [unifiedShareClassesStream].
@ProviderFor(unifiedShareClassesStream)
final unifiedShareClassesStreamProvider =
    AutoDisposeStreamProvider<List<ShareClassesData>>.internal(
      unifiedShareClassesStream,
      name: r'unifiedShareClassesStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$unifiedShareClassesStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnifiedShareClassesStreamRef =
    AutoDisposeStreamProviderRef<List<ShareClassesData>>;
String _$unifiedConvertiblesStreamHash() =>
    r'7b645e9a202b1a0b8bfeaa58f699667e0208ba98';

/// Convertibles provider using event-sourced projections.
///
/// Copied from [unifiedConvertiblesStream].
@ProviderFor(unifiedConvertiblesStream)
final unifiedConvertiblesStreamProvider =
    AutoDisposeStreamProvider<List<Convertible>>.internal(
      unifiedConvertiblesStream,
      name: r'unifiedConvertiblesStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$unifiedConvertiblesStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnifiedConvertiblesStreamRef =
    AutoDisposeStreamProviderRef<List<Convertible>>;
String _$unifiedEsopPoolsStreamHash() =>
    r'fb4fbc6810f0f6e6532c96e99fcb94cae1682180';

/// ESOP pools provider using event-sourced projections.
///
/// Copied from [unifiedEsopPoolsStream].
@ProviderFor(unifiedEsopPoolsStream)
final unifiedEsopPoolsStreamProvider =
    AutoDisposeStreamProvider<List<EsopPool>>.internal(
      unifiedEsopPoolsStream,
      name: r'unifiedEsopPoolsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$unifiedEsopPoolsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnifiedEsopPoolsStreamRef =
    AutoDisposeStreamProviderRef<List<EsopPool>>;
String _$unifiedOptionGrantsStreamHash() =>
    r'38850635167030928910008eb777badf07c2fb26';

/// Option grants provider using event-sourced projections.
///
/// Copied from [unifiedOptionGrantsStream].
@ProviderFor(unifiedOptionGrantsStream)
final unifiedOptionGrantsStreamProvider =
    AutoDisposeStreamProvider<List<OptionGrant>>.internal(
      unifiedOptionGrantsStream,
      name: r'unifiedOptionGrantsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$unifiedOptionGrantsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnifiedOptionGrantsStreamRef =
    AutoDisposeStreamProviderRef<List<OptionGrant>>;
String _$unifiedWarrantsStreamHash() =>
    r'385ddade88eb94cd409d16d036181f16215b056e';

/// Warrants provider using event-sourced projections.
///
/// Copied from [unifiedWarrantsStream].
@ProviderFor(unifiedWarrantsStream)
final unifiedWarrantsStreamProvider =
    AutoDisposeStreamProvider<List<Warrant>>.internal(
      unifiedWarrantsStream,
      name: r'unifiedWarrantsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$unifiedWarrantsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnifiedWarrantsStreamRef = AutoDisposeStreamProviderRef<List<Warrant>>;
String _$unifiedVestingSchedulesStreamHash() =>
    r'2d7166e1a9043bdfebc6bc1c1139bf391cc49802';

/// Vesting schedules provider using event-sourced projections.
///
/// Copied from [unifiedVestingSchedulesStream].
@ProviderFor(unifiedVestingSchedulesStream)
final unifiedVestingSchedulesStreamProvider =
    AutoDisposeStreamProvider<List<VestingSchedule>>.internal(
      unifiedVestingSchedulesStream,
      name: r'unifiedVestingSchedulesStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$unifiedVestingSchedulesStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnifiedVestingSchedulesStreamRef =
    AutoDisposeStreamProviderRef<List<VestingSchedule>>;
String _$unifiedValuationsStreamHash() =>
    r'ccece61f7cd8490f33a9199c4fa008b136ed17cb';

/// Valuations provider using event-sourced projections.
///
/// Copied from [unifiedValuationsStream].
@ProviderFor(unifiedValuationsStream)
final unifiedValuationsStreamProvider =
    AutoDisposeStreamProvider<List<Valuation>>.internal(
      unifiedValuationsStream,
      name: r'unifiedValuationsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$unifiedValuationsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnifiedValuationsStreamRef =
    AutoDisposeStreamProviderRef<List<Valuation>>;
String _$unifiedTransfersStreamHash() =>
    r'499b3c0dcbb23831be9d119c35eec47428600353';

/// Transfers provider using event-sourced projections.
///
/// Copied from [unifiedTransfersStream].
@ProviderFor(unifiedTransfersStream)
final unifiedTransfersStreamProvider =
    AutoDisposeStreamProvider<List<Transfer>>.internal(
      unifiedTransfersStream,
      name: r'unifiedTransfersStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$unifiedTransfersStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnifiedTransfersStreamRef =
    AutoDisposeStreamProviderRef<List<Transfer>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
