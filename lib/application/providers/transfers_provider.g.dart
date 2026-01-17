// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfers_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$transfersStreamHash() => r'dcf1cba45d57a26abf30fd89e0dd6d1f10756197';

/// Watches all transfers for the current company.
/// Uses event sourcing when active, falls back to direct DB otherwise.
///
/// Copied from [transfersStream].
@ProviderFor(transfersStream)
final transfersStreamProvider =
    AutoDisposeStreamProvider<List<Transfer>>.internal(
      transfersStream,
      name: r'transfersStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$transfersStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TransfersStreamRef = AutoDisposeStreamProviderRef<List<Transfer>>;
String _$transfersByStatusHash() => r'e2106eb5cdeb33cec9afbd2a56227b79532358f9';

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

/// Watches transfers filtered by status.
///
/// Copied from [transfersByStatus].
@ProviderFor(transfersByStatus)
const transfersByStatusProvider = TransfersByStatusFamily();

/// Watches transfers filtered by status.
///
/// Copied from [transfersByStatus].
class TransfersByStatusFamily extends Family<AsyncValue<List<Transfer>>> {
  /// Watches transfers filtered by status.
  ///
  /// Copied from [transfersByStatus].
  const TransfersByStatusFamily();

  /// Watches transfers filtered by status.
  ///
  /// Copied from [transfersByStatus].
  TransfersByStatusProvider call(String status) {
    return TransfersByStatusProvider(status);
  }

  @override
  TransfersByStatusProvider getProviderOverride(
    covariant TransfersByStatusProvider provider,
  ) {
    return call(provider.status);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'transfersByStatusProvider';
}

/// Watches transfers filtered by status.
///
/// Copied from [transfersByStatus].
class TransfersByStatusProvider
    extends AutoDisposeStreamProvider<List<Transfer>> {
  /// Watches transfers filtered by status.
  ///
  /// Copied from [transfersByStatus].
  TransfersByStatusProvider(String status)
    : this._internal(
        (ref) => transfersByStatus(ref as TransfersByStatusRef, status),
        from: transfersByStatusProvider,
        name: r'transfersByStatusProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$transfersByStatusHash,
        dependencies: TransfersByStatusFamily._dependencies,
        allTransitiveDependencies:
            TransfersByStatusFamily._allTransitiveDependencies,
        status: status,
      );

  TransfersByStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
  }) : super.internal();

  final String status;

  @override
  Override overrideWith(
    Stream<List<Transfer>> Function(TransfersByStatusRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TransfersByStatusProvider._internal(
        (ref) => create(ref as TransfersByStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Transfer>> createElement() {
    return _TransfersByStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TransfersByStatusProvider && other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TransfersByStatusRef on AutoDisposeStreamProviderRef<List<Transfer>> {
  /// The parameter `status` of this provider.
  String get status;
}

class _TransfersByStatusProviderElement
    extends AutoDisposeStreamProviderElement<List<Transfer>>
    with TransfersByStatusRef {
  _TransfersByStatusProviderElement(super.provider);

  @override
  String get status => (origin as TransfersByStatusProvider).status;
}

String _$transfersSummaryHash() => r'33a7b6fce40ee78ec8132238e2b28b47e880dee5';

/// Provides summary statistics for transfers.
///
/// Copied from [transfersSummary].
@ProviderFor(transfersSummary)
final transfersSummaryProvider = AutoDisposeProvider<TransfersSummary>.internal(
  transfersSummary,
  name: r'transfersSummaryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transfersSummaryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TransfersSummaryRef = AutoDisposeProviderRef<TransfersSummary>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
