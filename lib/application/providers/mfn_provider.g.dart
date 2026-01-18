// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mfn_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mfnUpgradesStreamHash() => r'd3c1d2440e981556ce2abd66a5ff40f2ae8e72b5';

/// Watches all MFN upgrade records for the current company.
///
/// Copied from [mfnUpgradesStream].
@ProviderFor(mfnUpgradesStream)
final mfnUpgradesStreamProvider =
    AutoDisposeStreamProvider<List<MfnUpgrade>>.internal(
      mfnUpgradesStream,
      name: r'mfnUpgradesStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$mfnUpgradesStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MfnUpgradesStreamRef = AutoDisposeStreamProviderRef<List<MfnUpgrade>>;
String _$pendingMfnUpgradesHash() =>
    r'f9d25fe5d69ff6aab9d08e54cad02003c55f61b3';

/// Detects pending MFN upgrade opportunities.
///
/// Returns a list of upgrade opportunities for convertibles with MFN clauses
/// that could be upgraded based on later convertibles with better terms.
///
/// Copied from [pendingMfnUpgrades].
@ProviderFor(pendingMfnUpgrades)
final pendingMfnUpgradesProvider =
    AutoDisposeFutureProvider<List<MfnUpgradeOpportunity>>.internal(
      pendingMfnUpgrades,
      name: r'pendingMfnUpgradesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pendingMfnUpgradesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingMfnUpgradesRef =
    AutoDisposeFutureProviderRef<List<MfnUpgradeOpportunity>>;
String _$hasPendingMfnUpgradesHash() =>
    r'292dba98d06aeb6a061b1241b7680bf4b7965c24';

/// Whether there are pending MFN upgrades available.
///
/// Copied from [hasPendingMfnUpgrades].
@ProviderFor(hasPendingMfnUpgrades)
final hasPendingMfnUpgradesProvider = AutoDisposeFutureProvider<bool>.internal(
  hasPendingMfnUpgrades,
  name: r'hasPendingMfnUpgradesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasPendingMfnUpgradesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasPendingMfnUpgradesRef = AutoDisposeFutureProviderRef<bool>;
String _$pendingMfnUpgradeCountHash() =>
    r'7b53211d9de0473dec68aba0219c4019b50b979f';

/// Count of pending MFN upgrades.
///
/// Copied from [pendingMfnUpgradeCount].
@ProviderFor(pendingMfnUpgradeCount)
final pendingMfnUpgradeCountProvider = AutoDisposeFutureProvider<int>.internal(
  pendingMfnUpgradeCount,
  name: r'pendingMfnUpgradeCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingMfnUpgradeCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingMfnUpgradeCountRef = AutoDisposeFutureProviderRef<int>;
String _$mfnUpgradesForTargetHash() =>
    r'e1c548ff81ace86fe83bdb41c47fa7db56c80091';

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

/// Watches MFN upgrades for a specific target convertible.
///
/// Copied from [mfnUpgradesForTarget].
@ProviderFor(mfnUpgradesForTarget)
const mfnUpgradesForTargetProvider = MfnUpgradesForTargetFamily();

/// Watches MFN upgrades for a specific target convertible.
///
/// Copied from [mfnUpgradesForTarget].
class MfnUpgradesForTargetFamily extends Family<AsyncValue<List<MfnUpgrade>>> {
  /// Watches MFN upgrades for a specific target convertible.
  ///
  /// Copied from [mfnUpgradesForTarget].
  const MfnUpgradesForTargetFamily();

  /// Watches MFN upgrades for a specific target convertible.
  ///
  /// Copied from [mfnUpgradesForTarget].
  MfnUpgradesForTargetProvider call(String targetConvertibleId) {
    return MfnUpgradesForTargetProvider(targetConvertibleId);
  }

  @override
  MfnUpgradesForTargetProvider getProviderOverride(
    covariant MfnUpgradesForTargetProvider provider,
  ) {
    return call(provider.targetConvertibleId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'mfnUpgradesForTargetProvider';
}

/// Watches MFN upgrades for a specific target convertible.
///
/// Copied from [mfnUpgradesForTarget].
class MfnUpgradesForTargetProvider
    extends AutoDisposeStreamProvider<List<MfnUpgrade>> {
  /// Watches MFN upgrades for a specific target convertible.
  ///
  /// Copied from [mfnUpgradesForTarget].
  MfnUpgradesForTargetProvider(String targetConvertibleId)
    : this._internal(
        (ref) => mfnUpgradesForTarget(
          ref as MfnUpgradesForTargetRef,
          targetConvertibleId,
        ),
        from: mfnUpgradesForTargetProvider,
        name: r'mfnUpgradesForTargetProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$mfnUpgradesForTargetHash,
        dependencies: MfnUpgradesForTargetFamily._dependencies,
        allTransitiveDependencies:
            MfnUpgradesForTargetFamily._allTransitiveDependencies,
        targetConvertibleId: targetConvertibleId,
      );

  MfnUpgradesForTargetProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.targetConvertibleId,
  }) : super.internal();

  final String targetConvertibleId;

  @override
  Override overrideWith(
    Stream<List<MfnUpgrade>> Function(MfnUpgradesForTargetRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MfnUpgradesForTargetProvider._internal(
        (ref) => create(ref as MfnUpgradesForTargetRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        targetConvertibleId: targetConvertibleId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<MfnUpgrade>> createElement() {
    return _MfnUpgradesForTargetProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MfnUpgradesForTargetProvider &&
        other.targetConvertibleId == targetConvertibleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, targetConvertibleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MfnUpgradesForTargetRef
    on AutoDisposeStreamProviderRef<List<MfnUpgrade>> {
  /// The parameter `targetConvertibleId` of this provider.
  String get targetConvertibleId;
}

class _MfnUpgradesForTargetProviderElement
    extends AutoDisposeStreamProviderElement<List<MfnUpgrade>>
    with MfnUpgradesForTargetRef {
  _MfnUpgradesForTargetProviderElement(super.provider);

  @override
  String get targetConvertibleId =>
      (origin as MfnUpgradesForTargetProvider).targetConvertibleId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
