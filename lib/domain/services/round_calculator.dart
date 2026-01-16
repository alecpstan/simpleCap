import '../../infrastructure/database/database.dart';

/// Pure calculation functions for round and valuation metrics.
abstract class RoundCalculator {
  /// Post-money valuation (pre-money + amount raised).
  static double? postMoneyValuation(Round round) {
    if (round.preMoneyValuation == null) return null;
    return round.preMoneyValuation! + round.amountRaised;
  }

  /// Whether this round is still editable.
  static bool isDraft(Round round) => round.status == 'draft';

  /// Whether this round's transactions affect the cap table.
  static bool isCommitted(Round round) => round.status == 'closed';

  /// Whether this is an equity round (vs convertible or pool).
  static bool isEquityRound(Round round) => switch (round.type) {
    'convertibleRound' || 'esopPool' => false,
    _ => true,
  };
}

/// Pure calculation functions for holdings.
abstract class HoldingCalculator {
  /// Price per share at acquisition.
  static double pricePerShare(Holding holding) {
    if (holding.shareCount == 0) return 0;
    return holding.costBasis / holding.shareCount;
  }

  /// Number of vested shares.
  static int vested(Holding holding) =>
      holding.vestedCount ?? holding.shareCount;

  /// Number of unvested shares.
  static int unvested(Holding holding) => holding.shareCount - vested(holding);

  /// Whether all shares are vested.
  static bool isFullyVested(Holding holding) => unvested(holding) == 0;

  /// Whether shares are subject to vesting.
  static bool hasVesting(Holding holding) => holding.vestingScheduleId != null;

  /// Vesting percentage (0-100).
  static double vestingPercent(Holding holding) {
    if (holding.shareCount == 0) return 100;
    return (vested(holding) / holding.shareCount) * 100;
  }

  /// Current value at a given price per share.
  static double currentValue(Holding holding, double pricePerShare) =>
      holding.shareCount * pricePerShare;

  /// Vested value at a given price per share.
  static double vestedValue(Holding holding, double pricePerShare) =>
      vested(holding) * pricePerShare;
}

/// Pure calculation functions for share class rights.
abstract class ShareClassCalculator {
  /// Human-readable summary of the class rights.
  static String rightsSummary(ShareClassesData shareClass) {
    final parts = <String>[];

    if (shareClass.votingMultiplier == 0) {
      parts.add('Non-voting');
    } else if (shareClass.votingMultiplier != 1.0) {
      parts.add('${shareClass.votingMultiplier}x voting');
    }

    if (shareClass.liquidationPreference != 1.0) {
      parts.add('${shareClass.liquidationPreference}x liquidation');
    }

    if (shareClass.isParticipating) {
      parts.add('Participating');
    }

    if (shareClass.dividendRate > 0) {
      parts.add('${shareClass.dividendRate}% dividend');
    }

    return parts.isEmpty ? 'Standard rights' : parts.join(', ');
  }

  /// Whether this class represents potential (not yet issued) shares.
  static bool isDerivative(ShareClassesData shareClass) =>
      shareClass.type == 'options' || shareClass.type == 'performanceRights';

  /// Whether this is an ESOP-related class.
  static bool isEsop(ShareClassesData shareClass) =>
      shareClass.type == 'esop' ||
      shareClass.type == 'options' ||
      shareClass.type == 'performanceRights';
}
