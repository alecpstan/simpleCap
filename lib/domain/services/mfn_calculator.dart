import '../../infrastructure/database/database.dart';

/// Represents a detected MFN upgrade opportunity.
///
/// When a convertible with MFN clause finds another convertible
/// with better terms, this class captures what would change.
class MfnUpgradeOpportunity {
  /// The convertible that has MFN and could be upgraded
  final Convertible target;

  /// The convertible with better terms (the source of the upgrade)
  final Convertible source;

  /// New discount percent if upgrading (null if no improvement)
  final double? newDiscountPercent;

  /// New valuation cap if upgrading (null if no improvement)
  final double? newValuationCap;

  /// Whether pro-rata rights would be added
  final bool addsProRata;

  const MfnUpgradeOpportunity({
    required this.target,
    required this.source,
    this.newDiscountPercent,
    this.newValuationCap,
    this.addsProRata = false,
  });

  /// Whether this upgrade would change anything
  bool get hasUpgrade =>
      newDiscountPercent != null || newValuationCap != null || addsProRata;

  /// Description of what would change
  String get upgradeDescription {
    final parts = <String>[];
    if (newDiscountPercent != null) {
      final oldDiscount = (target.discountPercent ?? 0) * 100;
      final newDiscount = newDiscountPercent! * 100;
      parts.add(
        'Discount: ${oldDiscount.toStringAsFixed(0)}% → ${newDiscount.toStringAsFixed(0)}%',
      );
    }
    if (newValuationCap != null) {
      final oldCap = target.valuationCap;
      final oldCapStr = oldCap != null ? _formatCurrency(oldCap) : 'none';
      parts.add('Cap: $oldCapStr → ${_formatCurrency(newValuationCap!)}');
    }
    if (addsProRata) {
      parts.add('Adds Pro-Rata Rights');
    }
    return parts.join(', ');
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(0)}K';
    }
    return '\$${value.toStringAsFixed(0)}';
  }
}

/// Pure calculation functions for MFN (Most Favored Nation) upgrades.
///
/// MFN clauses allow early investors to receive better terms if later
/// investors get better terms on their convertibles.
abstract class MfnCalculator {
  /// Detect all pending MFN upgrades for outstanding convertibles.
  ///
  /// Returns a list of upgrade opportunities where:
  /// - Target has MFN clause and is outstanding
  /// - Source was issued AFTER target
  /// - Source has better terms (higher discount, lower cap, or pro-rata)
  static List<MfnUpgradeOpportunity> detectUpgrades(
    List<Convertible> convertibles,
    List<MfnUpgrade> existingUpgrades,
  ) {
    final upgrades = <MfnUpgradeOpportunity>[];

    // Get convertibles with MFN that are still outstanding and haven't been upgraded
    // from a particular source yet
    final mfnEligible = convertibles
        .where((c) => c.status == 'outstanding' && c.hasMfn)
        .toList();

    // Get all outstanding convertibles (potential sources of better terms)
    final allOutstanding = convertibles
        .where((c) => c.status == 'outstanding')
        .toList();

    // Build a set of (target, source) pairs that already have upgrades
    final existingPairs = existingUpgrades
        .map((u) => '${u.targetConvertibleId}:${u.sourceConvertibleId}')
        .toSet();

    for (final target in mfnEligible) {
      MfnUpgradeOpportunity? bestUpgrade;

      for (final source in allOutstanding) {
        // Skip self-comparison
        if (source.id == target.id) continue;

        // MFN typically applies to instruments issued AFTER the MFN holder
        if (!source.issueDate.isAfter(target.issueDate)) continue;

        // Skip if already upgraded from this source
        if (existingPairs.contains('${target.id}:${source.id}')) continue;

        // Check for better terms
        final upgrade = _compareTerms(target, source);
        if (upgrade != null && upgrade.hasUpgrade) {
          // Keep the most favorable upgrade (most improvements)
          if (bestUpgrade == null || _isBetterUpgrade(upgrade, bestUpgrade)) {
            bestUpgrade = upgrade;
          }
        }
      }

      if (bestUpgrade != null) {
        upgrades.add(bestUpgrade);
      }
    }

    return upgrades;
  }

  /// Compare terms between MFN holder and a later instrument.
  /// Returns an MfnUpgradeOpportunity if source has any better terms.
  static MfnUpgradeOpportunity? _compareTerms(
    Convertible target,
    Convertible source,
  ) {
    double? newDiscount;
    double? newCap;
    bool addsProRata = false;

    // Check discount: higher discount is better for investor
    final targetDiscount = target.discountPercent ?? 0;
    final sourceDiscount = source.discountPercent ?? 0;
    if (sourceDiscount > targetDiscount) {
      newDiscount = sourceDiscount;
    }

    // Check cap: lower cap is better for investor
    final targetCap = target.valuationCap;
    final sourceCap = source.valuationCap;
    if (sourceCap != null) {
      if (targetCap == null || sourceCap < targetCap) {
        newCap = sourceCap;
      }
    }

    // Check pro-rata: gaining rights is better
    if (source.hasProRata && !target.hasProRata) {
      addsProRata = true;
    }

    // Only return upgrade if there's something to improve
    if (newDiscount != null || newCap != null || addsProRata) {
      return MfnUpgradeOpportunity(
        target: target,
        source: source,
        newDiscountPercent: newDiscount,
        newValuationCap: newCap,
        addsProRata: addsProRata,
      );
    }

    return null;
  }

  /// Determine if upgrade A is better than upgrade B (more improvements).
  static bool _isBetterUpgrade(
    MfnUpgradeOpportunity a,
    MfnUpgradeOpportunity b,
  ) {
    int scoreA = 0;
    int scoreB = 0;

    if (a.newDiscountPercent != null) scoreA++;
    if (b.newDiscountPercent != null) scoreB++;
    if (a.newValuationCap != null) scoreA++;
    if (b.newValuationCap != null) scoreB++;
    if (a.addsProRata) scoreA++;
    if (b.addsProRata) scoreB++;

    if (scoreA != scoreB) return scoreA > scoreB;

    // If same number of improvements, prefer higher discount
    final discountA = a.newDiscountPercent ?? 0;
    final discountB = b.newDiscountPercent ?? 0;
    if (discountA != discountB) return discountA > discountB;

    // Then prefer lower cap
    final capA = a.newValuationCap ?? double.infinity;
    final capB = b.newValuationCap ?? double.infinity;
    return capA < capB;
  }

  /// Check if a convertible's terms still trigger MFN upgrades after being edited.
  ///
  /// Returns true if the source still has better terms than all targets
  /// it previously upgraded.
  static bool sourceStillTriggersMfn(
    Convertible editedSource,
    Convertible originalTarget,
    MfnUpgrade existingUpgrade,
  ) {
    // Check if the edited source still has better terms than the original
    // (pre-upgrade) target terms

    // Check discount
    final originalDiscount = existingUpgrade.previousDiscountPercent ?? 0;
    final sourceDiscount = editedSource.discountPercent ?? 0;
    final discountStillBetter = sourceDiscount > originalDiscount;

    // Check cap
    final originalCap = existingUpgrade.previousValuationCap;
    final sourceCap = editedSource.valuationCap;
    bool capStillBetter = false;
    if (sourceCap != null) {
      if (originalCap == null || sourceCap < originalCap) {
        capStillBetter = true;
      }
    }

    // Check pro-rata
    final originalHadProRata = existingUpgrade.previousHasProRata;
    final proRataStillBetter = editedSource.hasProRata && !originalHadProRata;

    // If any term is still better, the MFN should remain
    return discountStillBetter || capStillBetter || proRataStillBetter;
  }
}
