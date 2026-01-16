// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$companiesStreamHash() => r'e50b97d85eb85d70bc2a3250de647a91485adf5d';

/// Watches all companies in the database.
///
/// Copied from [companiesStream].
@ProviderFor(companiesStream)
final companiesStreamProvider =
    AutoDisposeStreamProvider<List<Company>>.internal(
      companiesStream,
      name: r'companiesStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$companiesStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CompaniesStreamRef = AutoDisposeStreamProviderRef<List<Company>>;
String _$currentCompanyHash() => r'f9fcb5ff9d1bb2c62521cb2629a8e3924fa9d060';

/// Gets the current company data.
///
/// Copied from [currentCompany].
@ProviderFor(currentCompany)
final currentCompanyProvider = AutoDisposeFutureProvider<Company?>.internal(
  currentCompany,
  name: r'currentCompanyProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentCompanyHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentCompanyRef = AutoDisposeFutureProviderRef<Company?>;
String _$currentCompanyIdHash() => r'8a5195c43d58eee9738f5022128be1a0b15bd5b0';

/// The currently selected company ID.
///
/// Persists the selection to SharedPreferences and auto-selects
/// the last used company on app startup.
///
/// Copied from [CurrentCompanyId].
@ProviderFor(CurrentCompanyId)
final currentCompanyIdProvider =
    NotifierProvider<CurrentCompanyId, String?>.internal(
      CurrentCompanyId.new,
      name: r'currentCompanyIdProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentCompanyIdHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurrentCompanyId = Notifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
