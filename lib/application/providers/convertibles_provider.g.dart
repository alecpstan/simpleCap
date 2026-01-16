// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'convertibles_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$convertiblesStreamHash() =>
    r'1426bf0cad7b12e7078f58d62be36eaef2cb9b45';

/// Watches all convertibles for the current company.
///
/// Copied from [convertiblesStream].
@ProviderFor(convertiblesStream)
final convertiblesStreamProvider =
    AutoDisposeStreamProvider<List<Convertible>>.internal(
      convertiblesStream,
      name: r'convertiblesStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$convertiblesStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConvertiblesStreamRef = AutoDisposeStreamProviderRef<List<Convertible>>;
String _$convertiblesByStatusHash() =>
    r'ef7d49be528a134f8aeae7ecf32690503ae53be6';

/// Groups convertibles by status.
///
/// Copied from [convertiblesByStatus].
@ProviderFor(convertiblesByStatus)
final convertiblesByStatusProvider =
    AutoDisposeProvider<Map<String, List<Convertible>>>.internal(
      convertiblesByStatus,
      name: r'convertiblesByStatusProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$convertiblesByStatusHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConvertiblesByStatusRef =
    AutoDisposeProviderRef<Map<String, List<Convertible>>>;
String _$convertiblesSummaryHash() =>
    r'5307b3285fc393ff543398dde4b68460956b84a3';

/// Summary of convertibles for dashboard.
///
/// Copied from [convertiblesSummary].
@ProviderFor(convertiblesSummary)
final convertiblesSummaryProvider =
    AutoDisposeFutureProvider<ConvertiblesSummary>.internal(
      convertiblesSummary,
      name: r'convertiblesSummaryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$convertiblesSummaryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConvertiblesSummaryRef =
    AutoDisposeFutureProviderRef<ConvertiblesSummary>;
String _$convertibleMutationsHash() =>
    r'015bd6d78dc4c759a27e6440f180ac7e937ac585';

/// Notifier for convertible mutations.
///
/// Copied from [ConvertibleMutations].
@ProviderFor(ConvertibleMutations)
final convertibleMutationsProvider =
    AutoDisposeAsyncNotifierProvider<ConvertibleMutations, void>.internal(
      ConvertibleMutations.new,
      name: r'convertibleMutationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$convertibleMutationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ConvertibleMutations = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
