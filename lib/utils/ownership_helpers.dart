// Ownership and dilution calculation helpers
// Pure functions for calculating ownership percentages and dilution impact

/// Calculate ownership percentage for a given share count
double calculateOwnershipPercentage({
  required int shares,
  required int totalShares,
}) {
  if (totalShares <= 0) return 0;
  return (shares / totalShares) * 100;
}

/// Calculate dilution from issuing new shares
/// Returns the percentage point decrease in ownership
double calculateDilutionPercent({
  required int currentShares,
  required int totalSharesBefore,
  required int newSharesIssued,
}) {
  if (totalSharesBefore <= 0) return 0;

  final ownershipBefore = (currentShares / totalSharesBefore) * 100;
  final totalSharesAfter = totalSharesBefore + newSharesIssued;
  final ownershipAfter = (currentShares / totalSharesAfter) * 100;

  return ownershipBefore - ownershipAfter;
}

/// Calculate new ownership after dilution
double calculateOwnershipAfterDilution({
  required int currentShares,
  required int totalSharesBefore,
  required int newSharesIssued,
}) {
  final totalSharesAfter = totalSharesBefore + newSharesIssued;
  if (totalSharesAfter <= 0) return 0;
  return (currentShares / totalSharesAfter) * 100;
}

/// Calculate shares needed for target ownership percentage
int calculateSharesForTargetOwnership({
  required double targetPercent,
  required int existingShares,
}) {
  if (targetPercent <= 0 || targetPercent >= 100) return 0;

  // newShares = existingShares * targetPercent / (1 - targetPercent)
  return (existingShares * (targetPercent / 100) / (1 - targetPercent / 100))
      .round();
}

/// Calculate pro-rata allocation for an investor in a new round
double calculateProRataAllocation({
  required double ownershipPercent,
  required double roundSize,
}) {
  return roundSize * (ownershipPercent / 100);
}

/// Calculate implied price per share from valuation
double calculatePricePerShare({
  required double valuation,
  required int totalShares,
}) {
  if (totalShares <= 0) return 0;
  return valuation / totalShares;
}

/// Calculate implied valuation from price per share
double calculateValuationFromPrice({
  required double pricePerShare,
  required int totalShares,
}) {
  return pricePerShare * totalShares;
}

/// Calculate post-money valuation
double calculatePostMoneyValuation({
  required double preMoneyValuation,
  required double amountRaised,
}) {
  return preMoneyValuation + amountRaised;
}

/// Calculate pre-money valuation from post-money and amount raised
double calculatePreMoneyValuation({
  required double postMoneyValuation,
  required double amountRaised,
}) {
  return postMoneyValuation - amountRaised;
}

/// Calculate new investor ownership from round terms
double calculateNewInvestorOwnership({
  required double amountInvested,
  required double preMoneyValuation,
}) {
  final postMoney = preMoneyValuation + amountInvested;
  if (postMoney <= 0) return 0;
  return (amountInvested / postMoney) * 100;
}

/// Calculate voting power with multiplier
double calculateVotingPower({
  required int shares,
  required double votingMultiplier,
}) {
  return shares * votingMultiplier;
}

/// Calculate voting percentage
double calculateVotingPercentage({
  required double votingPower,
  required double totalVotingPower,
}) {
  if (totalVotingPower <= 0) return 0;
  return (votingPower / totalVotingPower) * 100;
}

/// Calculate accrued dividends (simple interest)
double calculateAccruedDividends({
  required double investedAmount,
  required double dividendRate,
  required double yearsHeld,
}) {
  if (dividendRate <= 0 || yearsHeld <= 0) return 0;
  return investedAmount * (dividendRate / 100) * yearsHeld;
}

/// Calculate realized profit from share sales
double calculateRealizedProfit({
  required double saleProceeds,
  required double costBasis,
}) {
  return saleProceeds - costBasis;
}

/// Calculate cost basis per share using weighted average
double calculateWeightedAverageCostBasis({
  required List<ShareAcquisition> acquisitions,
}) {
  if (acquisitions.isEmpty) return 0;

  int totalShares = 0;
  double totalCost = 0;

  for (final acq in acquisitions) {
    totalShares += acq.shares;
    totalCost += acq.totalCost;
  }

  if (totalShares <= 0) return 0;
  return totalCost / totalShares;
}

/// Helper class for cost basis calculation
class ShareAcquisition {
  final int shares;
  final double totalCost;

  const ShareAcquisition({required this.shares, required this.totalCost});

  double get pricePerShare => shares > 0 ? totalCost / shares : 0;
}
