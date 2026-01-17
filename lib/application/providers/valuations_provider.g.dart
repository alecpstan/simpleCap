// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'valuations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$valuationsStreamHash() => r'a0d8eb73254ac2c1ad53e36e25d43086476d4a03';

/// Stream of all valuations for the current company.
///
/// Copied from [valuationsStream].
@ProviderFor(valuationsStream)
final valuationsStreamProvider =
    AutoDisposeStreamProvider<List<Valuation>>.internal(
      valuationsStream,
      name: r'valuationsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$valuationsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ValuationsStreamRef = AutoDisposeStreamProviderRef<List<Valuation>>;
String _$latestValuationHash() => r'b4a4b841b00e3c8f2342ce8d9407b1fdb65226f5';

/// Gets the latest valuation for the company.
///
/// Copied from [latestValuation].
@ProviderFor(latestValuation)
final latestValuationProvider = AutoDisposeFutureProvider<Valuation?>.internal(
  latestValuation,
  name: r'latestValuationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$latestValuationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LatestValuationRef = AutoDisposeFutureProviderRef<Valuation?>;
String _$effectiveValuationHash() =>
    r'ffa1e3adb0c269be40262d645522b7387be824ac';

/// Gets the effective current valuation.
///
/// This compares:
/// 1. The latest manual valuation from the valuations table
/// 2. The most recent funding round's valuation:
///    - Pre-money if the round is still draft
///    - Post-money (pre-money + amount raised) if the round is closed
///
/// Returns whichever has the most recent date.
///
/// Copied from [effectiveValuation].
@ProviderFor(effectiveValuation)
final effectiveValuationProvider =
    AutoDisposeFutureProvider<EffectiveValuation?>.internal(
      effectiveValuation,
      name: r'effectiveValuationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$effectiveValuationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EffectiveValuationRef =
    AutoDisposeFutureProviderRef<EffectiveValuation?>;
String _$valuationsSummaryHash() => r'0271e4d5b4d7191ae5c302b817393552cdc54bf9';

/// See also [valuationsSummary].
@ProviderFor(valuationsSummary)
final valuationsSummaryProvider =
    AutoDisposeFutureProvider<ValuationsSummary>.internal(
      valuationsSummary,
      name: r'valuationsSummaryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$valuationsSummaryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ValuationsSummaryRef = AutoDisposeFutureProviderRef<ValuationsSummary>;
String _$valuationMutationsHash() =>
    r'c1375a2fe45e64bef999023fb315fca8e7b8b482';

/// Notifier for valuation mutations.
///
/// Copied from [ValuationMutations].
@ProviderFor(ValuationMutations)
final valuationMutationsProvider =
    AutoDisposeAsyncNotifierProvider<ValuationMutations, void>.internal(
      ValuationMutations.new,
      name: r'valuationMutationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$valuationMutationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ValuationMutations = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
