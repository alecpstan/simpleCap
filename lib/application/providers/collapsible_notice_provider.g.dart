// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collapsible_notice_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$noticeIsCollapsedHash() => r'f0077a7d721e1661c0343128a4ad8cde19e8cc67';

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

/// Convenience provider to get the collapsed state for a specific key.
///
/// Copied from [noticeIsCollapsed].
@ProviderFor(noticeIsCollapsed)
const noticeIsCollapsedProvider = NoticeIsCollapsedFamily();

/// Convenience provider to get the collapsed state for a specific key.
///
/// Copied from [noticeIsCollapsed].
class NoticeIsCollapsedFamily extends Family<bool> {
  /// Convenience provider to get the collapsed state for a specific key.
  ///
  /// Copied from [noticeIsCollapsed].
  const NoticeIsCollapsedFamily();

  /// Convenience provider to get the collapsed state for a specific key.
  ///
  /// Copied from [noticeIsCollapsed].
  NoticeIsCollapsedProvider call(String persistKey) {
    return NoticeIsCollapsedProvider(persistKey);
  }

  @override
  NoticeIsCollapsedProvider getProviderOverride(
    covariant NoticeIsCollapsedProvider provider,
  ) {
    return call(provider.persistKey);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'noticeIsCollapsedProvider';
}

/// Convenience provider to get the collapsed state for a specific key.
///
/// Copied from [noticeIsCollapsed].
class NoticeIsCollapsedProvider extends AutoDisposeProvider<bool> {
  /// Convenience provider to get the collapsed state for a specific key.
  ///
  /// Copied from [noticeIsCollapsed].
  NoticeIsCollapsedProvider(String persistKey)
    : this._internal(
        (ref) => noticeIsCollapsed(ref as NoticeIsCollapsedRef, persistKey),
        from: noticeIsCollapsedProvider,
        name: r'noticeIsCollapsedProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$noticeIsCollapsedHash,
        dependencies: NoticeIsCollapsedFamily._dependencies,
        allTransitiveDependencies:
            NoticeIsCollapsedFamily._allTransitiveDependencies,
        persistKey: persistKey,
      );

  NoticeIsCollapsedProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.persistKey,
  }) : super.internal();

  final String persistKey;

  @override
  Override overrideWith(bool Function(NoticeIsCollapsedRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: NoticeIsCollapsedProvider._internal(
        (ref) => create(ref as NoticeIsCollapsedRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        persistKey: persistKey,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _NoticeIsCollapsedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NoticeIsCollapsedProvider && other.persistKey == persistKey;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, persistKey.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NoticeIsCollapsedRef on AutoDisposeProviderRef<bool> {
  /// The parameter `persistKey` of this provider.
  String get persistKey;
}

class _NoticeIsCollapsedProviderElement extends AutoDisposeProviderElement<bool>
    with NoticeIsCollapsedRef {
  _NoticeIsCollapsedProviderElement(super.provider);

  @override
  String get persistKey => (origin as NoticeIsCollapsedProvider).persistKey;
}

String _$collapsedNoticeStateHash() =>
    r'902357bb0fd1596a0d486af57807e551a60ba6ac';

/// Provider that manages the collapsed state of notices with persist keys.
///
/// This allows the collapsed/expanded state of [CollapsibleNotice] widgets
/// to persist between page changes and app restarts.
///
/// Copied from [CollapsedNoticeState].
@ProviderFor(CollapsedNoticeState)
final collapsedNoticeStateProvider =
    AutoDisposeAsyncNotifierProvider<
      CollapsedNoticeState,
      Map<String, bool>
    >.internal(
      CollapsedNoticeState.new,
      name: r'collapsedNoticeStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$collapsedNoticeStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CollapsedNoticeState = AutoDisposeAsyncNotifier<Map<String, bool>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
