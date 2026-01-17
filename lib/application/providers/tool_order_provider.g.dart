// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tool_order_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$toolOrderNotifierHash() => r'2c7187c211779e9db5e82bc262df7a1e65f64243';

/// Provides the user's preferred tool order for the dashboard.
///
/// Persists the order to SharedPreferences.
///
/// Copied from [ToolOrderNotifier].
@ProviderFor(ToolOrderNotifier)
final toolOrderNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ToolOrderNotifier, List<String>>.internal(
      ToolOrderNotifier.new,
      name: r'toolOrderNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$toolOrderNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ToolOrderNotifier = AutoDisposeAsyncNotifier<List<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
