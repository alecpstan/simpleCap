// ESOP (Employee Stock Ownership Plan) helper enums and calculations
// Pure functions for ESOP pool sizing based on different dilution methods

/// ESOP dilution calculation methods
enum EsopDilutionMethod {
  /// Post-round cap table (US-style): new shares = (pool % * post-money shares) / (1 - pool %)
  postRoundCap,

  /// Pre-round cap table (AU-style): new shares = pool % * pre-round shares
  preRoundCap,

  /// Fixed number of shares (no percentage calculation)
  fixedShares,
}

extension EsopDilutionMethodExtension on EsopDilutionMethod {
  String get displayName {
    switch (this) {
      case EsopDilutionMethod.postRoundCap:
        return 'Post-Round (US-style)';
      case EsopDilutionMethod.preRoundCap:
        return 'Pre-Round (AU-style)';
      case EsopDilutionMethod.fixedShares:
        return 'Fixed Shares';
    }
  }

  String get description {
    switch (this) {
      case EsopDilutionMethod.postRoundCap:
        return 'Pool % of post-money shares. Dilutes all shareholders equally.';
      case EsopDilutionMethod.preRoundCap:
        return 'Pool % of pre-round shares. Only existing shareholders are diluted.';
      case EsopDilutionMethod.fixedShares:
        return 'Fixed number of shares, no percentage calculation.';
    }
  }
}

/// Calculate ESOP pool size based on dilution method
///
/// [method] - The dilution calculation method to use
/// [targetPercent] - Target pool percentage (e.g., 10.0 for 10%)
/// [currentShares] - Current issued shares before any new round
/// [additionalNewShares] - Shares being issued in new round (optional)
/// [currentUnallocatedPool] - Current unallocated pool shares (for fixedShares method)
int calculateEsopPoolSize({
  required EsopDilutionMethod method,
  required double targetPercent,
  required int currentShares,
  int additionalNewShares = 0,
  int currentUnallocatedPool = 0,
}) {
  switch (method) {
    case EsopDilutionMethod.postRoundCap:
      // US-style: pool is % of post-money
      // poolShares = (targetPercent * postMoneyShares) / (1 - targetPercent)
      final postMoney = currentShares + additionalNewShares;
      return ((targetPercent / 100) * postMoney / (1 - targetPercent / 100))
          .round();

    case EsopDilutionMethod.preRoundCap:
      // AU-style: pool is % of pre-round shares
      return ((targetPercent / 100) * currentShares).round();

    case EsopDilutionMethod.fixedShares:
      // Just return current unallocated pool
      return currentUnallocatedPool;
  }
}

/// Calculate the percentage of the cap table the ESOP pool represents
double calculateEsopPoolPercentage({
  required int poolShares,
  required int totalShares,
}) {
  if (totalShares <= 0) return 0;
  return (poolShares / totalShares) * 100;
}

/// Calculate how many new ESOP shares are needed to reach target percentage
int calculateEsopTopUpNeeded({
  required double targetPercent,
  required int currentPoolShares,
  required int totalShares,
}) {
  if (totalShares <= 0) return 0;

  // Target shares = targetPercent * (totalShares + targetShares)
  // Solving: targetShares = (targetPercent * totalShares) / (1 - targetPercent)
  final targetShares =
      ((targetPercent / 100) * totalShares / (1 - targetPercent / 100)).round();

  final needed = targetShares - currentPoolShares;
  return needed > 0 ? needed : 0;
}
