import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../infrastructure/database/database.dart';
import 'database_provider.dart';
import 'company_provider.dart';
import 'rounds_provider.dart';

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
@riverpod
Stream<List<Valuation>> valuationsStream(ValuationsStreamRef ref) {
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) return Stream.value([]);

  final db = ref.watch(databaseProvider);
  return db.watchValuations(companyId);
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
  // Rounds are sorted by displayOrder, but we want the most recent by date
  final roundsWithValuation = rounds
      .where((r) => r.preMoneyValuation != null && r.preMoneyValuation! > 0)
      .toList();

  if (roundsWithValuation.isNotEmpty) {
    // Sort by date descending to get most recent
    roundsWithValuation.sort((a, b) => b.date.compareTo(a.date));
    final latestRound = roundsWithValuation.first;

    final isClosed = latestRound.status == 'closed';
    final preMoneyVal = latestRound.preMoneyValuation!;
    final amountRaised = latestRound.amountRaised;

    // Post-money = pre-money + amount raised
    final effectiveValue = isClosed ? preMoneyVal + amountRaised : preMoneyVal;

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

  // Return whichever is more recent
  if (fromManual == null && fromRound == null) return null;
  if (fromManual == null) return fromRound;
  if (fromRound == null) return fromManual;

  // Compare dates and return the more recent one
  return fromManual.date.isAfter(fromRound.date) ? fromManual : fromRound;
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

/// Notifier for valuation mutations.
@riverpod
class ValuationMutations extends _$ValuationMutations {
  @override
  FutureOr<void> build() {}

  /// Create a new valuation.
  Future<String> create({
    required String companyId,
    required DateTime date,
    required double preMoneyValue,
    required String method,
    String? methodParamsJson,
    String? notes,
  }) async {
    final db = ref.read(databaseProvider);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();

    await db
        .into(db.valuations)
        .insert(
          ValuationsCompanion.insert(
            id: id,
            companyId: companyId,
            date: date,
            preMoneyValue: preMoneyValue,
            method: method,
            methodParamsJson: Value(methodParamsJson),
            notes: Value(notes),
            createdAt: now,
          ),
        );

    return id;
  }

  /// Update an existing valuation.
  Future<void> updateValuation({
    required String id,
    DateTime? date,
    double? preMoneyValue,
    String? method,
    String? methodParamsJson,
    String? notes,
  }) async {
    final db = ref.read(databaseProvider);

    await (db.update(db.valuations)..where((v) => v.id.equals(id))).write(
      ValuationsCompanion(
        date: date != null ? Value(date) : const Value.absent(),
        preMoneyValue: preMoneyValue != null
            ? Value(preMoneyValue)
            : const Value.absent(),
        method: method != null ? Value(method) : const Value.absent(),
        methodParamsJson: methodParamsJson != null
            ? Value(methodParamsJson)
            : const Value.absent(),
        notes: notes != null ? Value(notes) : const Value.absent(),
      ),
    );
  }

  /// Delete a valuation.
  Future<void> delete(String id) async {
    final db = ref.read(databaseProvider);
    await (db.delete(db.valuations)..where((v) => v.id.equals(id))).go();
  }
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
