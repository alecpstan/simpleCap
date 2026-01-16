import 'package:freezed_annotation/freezed_annotation.dart';

part 'round.freezed.dart';
part 'round.g.dart';

/// Types of financing rounds.
enum RoundType {
  incorporation,
  seed,
  seriesA,
  seriesB,
  seriesC,
  seriesD,
  bridge,
  convertibleRound,
  esopPool,
  secondary,
  custom;

  String get displayName => switch (this) {
    incorporation => 'Incorporation',
    seed => 'Seed',
    seriesA => 'Series A',
    seriesB => 'Series B',
    seriesC => 'Series C',
    seriesD => 'Series D',
    bridge => 'Bridge',
    convertibleRound => 'Convertible',
    esopPool => 'ESOP Pool',
    secondary => 'Secondary',
    custom => 'Custom',
  };

  /// Whether this is an equity round (vs convertible or pool).
  bool get isEquityRound => switch (this) {
    incorporation ||
    seed ||
    seriesA ||
    seriesB ||
    seriesC ||
    seriesD ||
    bridge ||
    secondary ||
    custom => true,
    convertibleRound || esopPool => false,
  };
}

/// Status of a financing round.
enum RoundStatus {
  /// Round is being set up, changes don't affect cap table.
  draft,

  /// Round is finalized, all transactions are committed.
  closed;

  String get displayName => switch (this) {
    draft => 'Draft',
    closed => 'Closed',
  };
}

/// A financing round representing a capital raise event.
///
/// Rounds can be in draft or closed status:
/// - Draft: Being configured, doesn't affect ownership calculations
/// - Closed: Finalized, all share issuances are committed
@freezed
class Round with _$Round {
  const Round._();

  const factory Round({
    required String id,
    required String companyId,
    required String name,
    required RoundType type,
    @Default(RoundStatus.draft) RoundStatus status,
    required DateTime date,

    /// Pre-money valuation in AUD.
    double? preMoneyValuation,

    /// Price per share for this round.
    double? pricePerShare,

    /// Total amount raised in this round.
    @Default(0) double amountRaised,

    /// Lead investor stakeholder ID (if any).
    String? leadInvestorId,

    /// Display order for chronological sorting.
    required int displayOrder,

    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Round;

  factory Round.fromJson(Map<String, dynamic> json) => _$RoundFromJson(json);

  /// Post-money valuation (pre-money + amount raised).
  double? get postMoneyValuation {
    if (preMoneyValuation == null) return null;
    return preMoneyValuation! + amountRaised;
  }

  /// Whether this round is still editable.
  bool get isDraft => status == RoundStatus.draft;

  /// Whether this round's transactions affect the cap table.
  bool get isCommitted => status == RoundStatus.closed;
}
