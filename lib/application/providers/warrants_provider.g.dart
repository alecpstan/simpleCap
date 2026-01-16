// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warrants_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$warrantsStreamHash() => r'3f4a15dc8c76bcc228bc25bc16f35c86def4bdbe';

/// Stream of all warrants for the current company.
///
/// Copied from [warrantsStream].
@ProviderFor(warrantsStream)
final warrantsStreamProvider =
    AutoDisposeStreamProvider<List<Warrant>>.internal(
      warrantsStream,
      name: r'warrantsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$warrantsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WarrantsStreamRef = AutoDisposeStreamProviderRef<List<Warrant>>;
String _$warrantsByStatusHash() => r'339a1e32a7c3f3f3ce6302c89189749050e5fdda';

/// Warrants grouped by status.
///
/// Copied from [warrantsByStatus].
@ProviderFor(warrantsByStatus)
final warrantsByStatusProvider =
    AutoDisposeProvider<Map<String, List<Warrant>>>.internal(
      warrantsByStatus,
      name: r'warrantsByStatusProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$warrantsByStatusHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WarrantsByStatusRef =
    AutoDisposeProviderRef<Map<String, List<Warrant>>>;
String _$warrantsSummaryHash() => r'632a6a173155480efc8aee1583bf7f1d6fc2ca51';

/// See also [warrantsSummary].
@ProviderFor(warrantsSummary)
final warrantsSummaryProvider = AutoDisposeProvider<WarrantsSummary>.internal(
  warrantsSummary,
  name: r'warrantsSummaryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$warrantsSummaryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WarrantsSummaryRef = AutoDisposeProviderRef<WarrantsSummary>;
String _$warrantMutationsHash() => r'18cd7a6ac7bbb6dfd13f8b055d4bb4e1a4a601d3';

/// Mutations for warrants.
///
/// Copied from [WarrantMutations].
@ProviderFor(WarrantMutations)
final warrantMutationsProvider =
    AutoDisposeAsyncNotifierProvider<WarrantMutations, void>.internal(
      WarrantMutations.new,
      name: r'warrantMutationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$warrantMutationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WarrantMutations = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
