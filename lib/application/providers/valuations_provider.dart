import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../infrastructure/database/database.dart';
import 'rounds_provider.dart';
import 'projection_adapters.dart';

part 'valuations_provider.g.dart';

/// Represents the effective current valuation of the company.
///
/// This combines information from both manual valuations and funding rounds
/// to determine the most relevant current valuation.
class EffectiveValuation {
  /// The valuation amount.
  final double value;

  /// The date this valuation is based on.
  final DateTime date;

  /// The source of this valuation.
  final ValuationSource source;

  /// If from a round, the round name.
  final String? roundName;

  /// If from a round, whether it's pre or post money.
  final bool? isPostMoney;

  /// The original valuation record (if from manual valuation).
  final Valuation? valuation;

  /// The original round record (if from a round).
  final Round? round;

  const EffectiveValuation({
    required this.value,
    required this.date,
    required this.source,
    this.roundName,
    this.isPostMoney,
    this.valuation,
    this.round,
  });

  /// Human-readable description of the valuation source.
  String get sourceDescription {
    switch (source) {
      case ValuationSource.manualValuation:
        return 'Manual valuation';
      case ValuationSource.roundPreMoney:
        return '${roundName ?? 'Round'} (pre-money)';
      case ValuationSource.roundPostMoney:
        return '${roundName ?? 'Round'} (post-money)';
    }
  }
}

/// Source of an effective valuation.
enum ValuationSource { manualValuation, roundPreMoney, roundPostMoney }

/// Stream of all valuations for the current company.
/// Uses event sourcing when active, falls back to direct DB otherwise.
@riverpod
Stream<List<Valuation>> valuationsStream(ValuationsStreamRef ref) {
  return ref.watch(unifiedValuationsStreamProvider.stream);
}

/// Gets the latest valuation for the company.
@riverpod
Future<Valuation?> latestValuation(LatestValuationRef ref) async {
  final valuations = await ref.watch(valuationsStreamProvider.future);
  if (valuations.isEmpty) return null;
  return valuations.first; // Already sorted by date desc
}

/// Gets the effective current valuation.
///
/// This compares:
/// 1. The latest manual valuation from the valuations table
/// 2. The most recent funding round's valuation:
///    - Pre-money if the round is still draft
///    - Post-money (pre-money + amount raised) if the round is closed
///
/// Returns whichever has the most recent date.
@riverpod
Future<EffectiveValuation?> effectiveValuation(
  EffectiveValuationRef ref,
) async {
  final valuations = await ref.watch(valuationsStreamProvider.future);
  final rounds = await ref.watch(roundsStreamProvider.future);

  EffectiveValuation? fromManual;
  EffectiveValuation? fromRound;

  // Get latest manual valuation
  if (valuations.isNotEmpty) {
    final latest = valuations.first;
    fromManual = EffectiveValuation(
      value: latest.preMoneyValue,
      date: latest.date,
      source: ValuationSource.manualValuation,
      valuation: latest,
    );
  }

  // Get latest round with a valuation
  // Include rounds that have either:
  // 1. preMoneyValuation > 0, OR
  // 2. Are closed with amountRaised > 0 (post-money valuation)
  final roundsWithValuation = rounds.where((r) {
    final hasPreMoney = r.preMoneyValuation != null && r.preMoneyValuation! > 0;
    final hasPostMoney = r.status == 'closed' && r.amountRaised > 0;
    return hasPreMoney || hasPostMoney;
  }).toList();

  if (roundsWithValuation.isNotEmpty) {
    // Sort by date descending to get most recent
    // For same date, post-money (closed) rounds are more recent than pre-money
    roundsWithValuation.sort((a, b) {
      final dateCompare = b.date.compareTo(a.date);
      if (dateCompare != 0) return dateCompare;
      // Same date: closed (post-money) > draft (pre-money)
      final aIsClosed = a.status == 'closed' ? 1 : 0;
      final bIsClosed = b.status == 'closed' ? 1 : 0;
      return bIsClosed.compareTo(aIsClosed);
    });
    final latestRound = roundsWithValuation.first;

    final isClosed = latestRound.status == 'closed';
    final preMoneyVal = latestRound.preMoneyValuation ?? 0;
    final amountRaised = latestRound.amountRaised;

    // Post-money = pre-money + amount raised
    final effectiveValue = isClosed ? preMoneyVal + amountRaised : preMoneyVal;

    // Only create fromRound if we have a meaningful value
    if (effectiveValue > 0) {
      fromRound = EffectiveValuation(
        value: effectiveValue,
        date: latestRound.date,
        source: isClosed
            ? ValuationSource.roundPostMoney
            : ValuationSource.roundPreMoney,
        roundName: latestRound.name,
        isPostMoney: isClosed,
        round: latestRound,
      );
    }
  }

  // Return whichever is more recent
  if (fromManual == null && fromRound == null) return null;
  if (fromManual == null) return fromRound;
  if (fromRound == null) return fromManual;

  // Compare dates and return the more recent one
  // If same date, post-money valuation (from closed round) wins
  if (fromManual.date.isAfter(fromRound.date)) return fromManual;
  if (fromRound.date.isAfter(fromManual.date)) return fromRound;
  // Same date: post-money (closed round) takes precedence
  return (fromRound.isPostMoney == true) ? fromRound : fromManual;
}

/// Summary of valuations for dashboard.
class ValuationsSummary {
  final double? currentValue;
  final double? previousValue;
  final double? changePercent;
  final int valuationCount;
  final DateTime? latestDate;

  const ValuationsSummary({
    this.currentValue,
    this.previousValue,
    this.changePercent,
    required this.valuationCount,
    this.latestDate,
  });

  factory ValuationsSummary.empty() =>
      const ValuationsSummary(valuationCount: 0);
}

@riverpod
Future<ValuationsSummary> valuationsSummary(ValuationsSummaryRef ref) async {
  final valuations = await ref.watch(valuationsStreamProvider.future);

  if (valuations.isEmpty) return ValuationsSummary.empty();

  final current = valuations.first;
  final previous = valuations.length > 1 ? valuations[1] : null;

  double? changePercent;
  if (previous != null && previous.preMoneyValue > 0) {
    changePercent =
        ((current.preMoneyValue - previous.preMoneyValue) /
            previous.preMoneyValue) *
        100;
  }

  return ValuationsSummary(
    currentValue: current.preMoneyValue,
    previousValue: previous?.preMoneyValue,
    changePercent: changePercent,
    valuationCount: valuations.length,
    latestDate: current.date,
  );
}

/// Valuation methods enum.
class ValuationMethod {
  static const String manual = 'manual';
  static const String roundImplied = 'round_implied';
  static const String dcf = 'dcf';
  static const String comparables = 'comparables';
  static const String fourNineA = '409a';

  static const List<String> all = [
    manual,
    roundImplied,
    dcf,
    comparables,
    fourNineA,
  ];

  static String displayName(String method) {
    switch (method) {
      case manual:
        return 'Manual Entry';
      case roundImplied:
        return 'Round Implied';
      case dcf:
        return 'DCF';
      case comparables:
        return 'Comparables';
      case fourNineA:
        return '409A Valuation';
      default:
        return method;
    }
  }
}
