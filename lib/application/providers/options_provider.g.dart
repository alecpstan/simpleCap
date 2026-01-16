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
String _$optionsSummaryHash() => r'640631d0f4f4efb7df090ced52805ec97e658c93';

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
    r'c33010b0d433dc703d2d6d1f0e8b73d6c875679d';

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
