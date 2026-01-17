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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
