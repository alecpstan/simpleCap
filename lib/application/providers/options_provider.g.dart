// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'options_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$optionGrantsStreamHash() =>
    r'f35759cb0f79c294319e5f358ea3d3ac18990123';

/// Watches all option grants for the current company.
///
/// Copied from [optionGrantsStream].
@ProviderFor(optionGrantsStream)
final optionGrantsStreamProvider =
    AutoDisposeStreamProvider<List<OptionGrant>>.internal(
      optionGrantsStream,
      name: r'optionGrantsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$optionGrantsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OptionGrantsStreamRef = AutoDisposeStreamProviderRef<List<OptionGrant>>;
String _$optionsByStatusHash() => r'cecdba3ce4cd5247ebe910fe88ae50fb656aa15c';

/// Groups option grants by status.
///
/// Copied from [optionsByStatus].
@ProviderFor(optionsByStatus)
final optionsByStatusProvider =
    AutoDisposeProvider<Map<String, List<OptionGrant>>>.internal(
      optionsByStatus,
      name: r'optionsByStatusProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$optionsByStatusHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OptionsByStatusRef =
    AutoDisposeProviderRef<Map<String, List<OptionGrant>>>;
String _$optionsSummaryHash() => r'd22dc92185c95a238c48cb2b1204bce61008dde8';

/// Summary of options for dashboard (with real vesting calculations).
///
/// Copied from [optionsSummary].
@ProviderFor(optionsSummary)
final optionsSummaryProvider =
    AutoDisposeFutureProvider<OptionsSummary>.internal(
      optionsSummary,
      name: r'optionsSummaryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$optionsSummaryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OptionsSummaryRef = AutoDisposeFutureProviderRef<OptionsSummary>;
String _$optionGrantMutationsHash() =>
    r'e9e7af7d42d22fc3ec5c6ade8dceae4a8296cfca';

/// Notifier for option grant mutations.
///
/// Copied from [OptionGrantMutations].
@ProviderFor(OptionGrantMutations)
final optionGrantMutationsProvider =
    AutoDisposeAsyncNotifierProvider<OptionGrantMutations, void>.internal(
      OptionGrantMutations.new,
      name: r'optionGrantMutationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$optionGrantMutationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OptionGrantMutations = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
