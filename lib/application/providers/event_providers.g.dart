// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$eventRepositoryHash() => r'7724e74a4c140d355ec373adf1f30fe694ab80cb';

/// Provides the event repository singleton.
///
/// Copied from [eventRepository].
@ProviderFor(eventRepository)
final eventRepositoryProvider = Provider<EventRepository>.internal(
  eventRepository,
  name: r'eventRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$eventRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EventRepositoryRef = ProviderRef<EventRepository>;
String _$eventsStreamHash() => r'2ff8df61295e62aa47b89c568de05541acd99272';

/// Watches all events for the current company, ordered by sequence.
///
/// This is the foundation of event sourcing - all state is derived from this stream.
///
/// Copied from [eventsStream].
@ProviderFor(eventsStream)
final eventsStreamProvider =
    AutoDisposeStreamProvider<List<CapTableEvent>>.internal(
      eventsStream,
      name: r'eventsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$eventsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EventsStreamRef = AutoDisposeStreamProviderRef<List<CapTableEvent>>;
String _$eventCountHash() => r'2bc6ea2cea7da6f8fa6b3e87da07d49b2176f1f5';

/// Provides the current event count for debugging/display.
///
/// Copied from [eventCount].
@ProviderFor(eventCount)
final eventCountProvider = AutoDisposeFutureProvider<int>.internal(
  eventCount,
  name: r'eventCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$eventCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EventCountRef = AutoDisposeFutureProviderRef<int>;
String _$eventLedgerHash() => r'27d0e52e8a2c7a6a729aa4d69fa59b749bcfcacb';

/// Event ledger for appending new events.
///
/// This is the write-side of event sourcing. Commands go through here
/// to emit events that update the cap table state.
///
/// Copied from [EventLedger].
@ProviderFor(EventLedger)
final eventLedgerProvider = NotifierProvider<EventLedger, void>.internal(
  EventLedger.new,
  name: r'eventLedgerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$eventLedgerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$EventLedger = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
