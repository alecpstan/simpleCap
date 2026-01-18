// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permanent_delete_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deleteEnabledHash() => r'b97bef07482a5a0d1a7653956ff147a21663b35b';

/// Provides the "Enable Delete" toggle.
///
/// When enabled, delete buttons are shown in the UI allowing permanent removal
/// of records and all their downstream events. When disabled, only cancel
/// operations are available (where applicable).
///
/// Copied from [DeleteEnabled].
@ProviderFor(DeleteEnabled)
final deleteEnabledProvider =
    AutoDisposeAsyncNotifierProvider<DeleteEnabled, bool>.internal(
      DeleteEnabled.new,
      name: r'deleteEnabledProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deleteEnabledHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DeleteEnabled = AutoDisposeAsyncNotifier<bool>;
String _$showDraftHash() => r'207fa6987f76fab4cac194b174e54d435e6474e7';

/// Provides the "Show Draft" toggle.
///
/// When enabled, draft items (linked to draft rounds) are shown in the UI
/// and included in ownership/value calculations. When disabled, draft items
/// are hidden and excluded from calculations.
///
/// Copied from [ShowDraft].
@ProviderFor(ShowDraft)
final showDraftProvider =
    AutoDisposeAsyncNotifierProvider<ShowDraft, bool>.internal(
      ShowDraft.new,
      name: r'showDraftProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$showDraftHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ShowDraft = AutoDisposeAsyncNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
