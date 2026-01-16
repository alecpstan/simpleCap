import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// ─── MFN Upgrade History ──────────────────────────────────────────────────────

/// Record of a single MFN upgrade event.
/// Tracks when and why terms were upgraded, enabling proper reversal.
class MfnUpgradeRecord {
  final String id;
  final DateTime upgradeDate;

  /// The convertible that triggered this MFN upgrade
  final String sourceConvertibleId;

  /// Terms BEFORE this upgrade was applied
  final double? previousDiscountPercent;
  final double? previousValuationCap;
  final bool previousHasProRata;

  /// Terms AFTER this upgrade was applied
  final double? newDiscountPercent;
  final double? newValuationCap;
  final bool newHasProRata;

  const MfnUpgradeRecord({
    required this.id,
    required this.upgradeDate,
    required this.sourceConvertibleId,
    this.previousDiscountPercent,
    this.previousValuationCap,
    this.previousHasProRata = false,
    this.newDiscountPercent,
    this.newValuationCap,
    this.newHasProRata = false,
  });

  /// Description of what changed in this upgrade
  String get upgradeDescription {
    final parts = <String>[];
    if (newDiscountPercent != null &&
        newDiscountPercent != previousDiscountPercent) {
      final oldPct = previousDiscountPercent != null
          ? '${(previousDiscountPercent! * 100).toStringAsFixed(0)}%'
          : 'none';
      final newPct = '${(newDiscountPercent! * 100).toStringAsFixed(0)}%';
      parts.add('Discount: $oldPct → $newPct');
    }
    if (newValuationCap != null && newValuationCap != previousValuationCap) {
      final oldCap = previousValuationCap != null
          ? '\$${(previousValuationCap! / 1000000).toStringAsFixed(1)}M'
          : 'none';
      final newCap = '\$${(newValuationCap! / 1000000).toStringAsFixed(1)}M';
      parts.add('Cap: $oldCap → $newCap');
    }
    if (newHasProRata && !previousHasProRata) {
      parts.add('Added pro-rata rights');
    }
    return parts.isEmpty ? 'No changes' : parts.join(', ');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'upgradeDate': upgradeDate.toIso8601String(),
        'sourceConvertibleId': sourceConvertibleId,
        'previousDiscountPercent': previousDiscountPercent,
        'previousValuationCap': previousValuationCap,
        'previousHasProRata': previousHasProRata,
        'newDiscountPercent': newDiscountPercent,
        'newValuationCap': newValuationCap,
        'newHasProRata': newHasProRata,
      };

  factory MfnUpgradeRecord.fromJson(Map<String, dynamic> json) =>
      MfnUpgradeRecord(
        id: json['id'] ?? const Uuid().v4(),
        upgradeDate: DateTime.parse(json['upgradeDate']),
        sourceConvertibleId: json['sourceConvertibleId'],
        previousDiscountPercent: json['previousDiscountPercent']?.toDouble(),
        previousValuationCap: json['previousValuationCap']?.toDouble(),
        previousHasProRata: json['previousHasProRata'] ?? false,
        newDiscountPercent: json['newDiscountPercent']?.toDouble(),
        newValuationCap: json['newValuationCap']?.toDouble(),
        newHasProRata: json['newHasProRata'] ?? false,
      );
}

/// Type of convertible instrument
enum ConvertibleType {
  /// Convertible Note - Australia's default, includes interest
  convertibleNote,

  /// SAFE - Simple Agreement for Future Equity (adapted from US)
  safe,
}

/// Status of the convertible instrument
enum ConvertibleStatus {
  /// Active and not yet converted
  outstanding,

  /// Pending conversion - conversion recorded but round is still draft/open
  /// Will become 'converted' when the round is closed
  pendingConversion,

  /// Converted to equity in a round (round is closed)
  converted,

  /// Repaid (notes only, if not converted at maturity)
  repaid,

  /// Cancelled/terminated
  cancelled,
}

/// Extension for status colors
extension ConvertibleStatusColor on ConvertibleStatus {
  Color get color {
    switch (this) {
      case ConvertibleStatus.outstanding:
        return Colors.blue;
      case ConvertibleStatus.pendingConversion:
        return Colors.orange;
      case ConvertibleStatus.converted:
        return Colors.green;
      case ConvertibleStatus.repaid:
        return Colors.teal;
      case ConvertibleStatus.cancelled:
        return Colors.red;
    }
  }
}

/// Represents a SAFE or Convertible Note instrument
/// These are tracked separately until conversion, then become transactions
class ConvertibleInstrument {
  final String id;

  /// The investor holding this instrument
  final String investorId;

  /// Type: SAFE or Convertible Note
  final ConvertibleType type;

  /// Principal amount invested
  final double principalAmount;

  /// Interest rate (annual, for notes only) - e.g., 0.08 for 8%
  final double? interestRate;

  /// Discount percentage - e.g., 0.20 for 20% discount
  final double? discountPercent;

  /// Valuation cap (if any)
  final double? valuationCap;

  /// Maturity date (required for notes)
  final DateTime? maturityDate;

  /// Date the instrument was issued
  final DateTime issueDate;

  /// Most Favored Nation clause (SAFEs)
  final bool hasMFN;

  /// Pro-rata rights for future rounds
  final bool hasProRata;

  // ─── MFN Tracking Fields ───────────────────────────────────────────────────

  /// History of all MFN upgrades applied to this instrument.
  /// Most recent upgrade is last in the list.
  /// Enables proper reversal when a triggering convertible is deleted.
  final List<MfnUpgradeRecord> mfnUpgradeHistory;

  /// Whether MFN has been applied to this instrument
  bool get mfnWasApplied => mfnUpgradeHistory.isNotEmpty;

  /// The most recent MFN upgrade (if any)
  MfnUpgradeRecord? get latestMfnUpgrade =>
      mfnUpgradeHistory.isNotEmpty ? mfnUpgradeHistory.last : null;

  /// Get the original terms (before any MFN upgrades)
  double? get originalDiscountPercent => mfnUpgradeHistory.isNotEmpty
      ? mfnUpgradeHistory.first.previousDiscountPercent
      : null;

  double? get originalValuationCap => mfnUpgradeHistory.isNotEmpty
      ? mfnUpgradeHistory.first.previousValuationCap
      : null;

  bool get originalHasProRata => mfnUpgradeHistory.isNotEmpty
      ? mfnUpgradeHistory.first.previousHasProRata
      : hasProRata;

  /// Current status
  ConvertibleStatus status;

  /// The round this converted into (if converted)
  final String? conversionRoundId;

  /// Number of shares received on conversion
  final int? conversionShares;

  /// Price per share at conversion
  final double? conversionPricePerShare;

  /// Date of conversion
  final DateTime? conversionDate;

  /// Include in Fully Diluted calculations
  final bool includeInFD;

  /// Optional notes
  final String? notes;

  ConvertibleInstrument({
    String? id,
    required this.investorId,
    required this.type,
    required this.principalAmount,
    this.interestRate,
    this.discountPercent,
    this.valuationCap,
    this.maturityDate,
    required this.issueDate,
    this.hasMFN = false,
    this.hasProRata = false,
    List<MfnUpgradeRecord>? mfnUpgradeHistory,
    this.status = ConvertibleStatus.outstanding,
    this.conversionRoundId,
    this.conversionShares,
    this.conversionPricePerShare,
    this.conversionDate,
    this.includeInFD = true,
    this.notes,
  })  : id = id ?? const Uuid().v4(),
        mfnUpgradeHistory = mfnUpgradeHistory ?? [];

  /// Calculate accrued interest (for convertible notes)
  double get accruedInterest {
    if (type != ConvertibleType.convertibleNote || interestRate == null) {
      return 0;
    }
    final endDate = conversionDate ?? DateTime.now();
    final days = endDate.difference(issueDate).inDays;
    final years = days / 365.0;
    return principalAmount * interestRate! * years;
  }

  /// Total convertible amount (principal + accrued interest)
  double get convertibleAmount => principalAmount + accruedInterest;

  /// Calculate conversion price per share given a round's pre-money valuation and issued shares
  /// Returns the lower of: cap-based price or discounted price
  double? calculateConversionPPS({
    required double roundPreMoney,
    required int issuedSharesBeforeRound,
  }) {
    if (issuedSharesBeforeRound <= 0) return null;

    final roundPPS = roundPreMoney / issuedSharesBeforeRound;

    // Discounted price
    final discountedPPS = discountPercent != null
        ? roundPPS * (1 - discountPercent!)
        : roundPPS;

    // Cap-based price
    final capPPS = valuationCap != null
        ? valuationCap! / issuedSharesBeforeRound
        : double.infinity;

    // Use the lower (more favorable to investor)
    return discountedPPS < capPPS ? discountedPPS : capPPS;
  }

  /// Calculate shares on conversion
  int calculateConversionShares({
    required double roundPreMoney,
    required int issuedSharesBeforeRound,
  }) {
    final pps = calculateConversionPPS(
      roundPreMoney: roundPreMoney,
      issuedSharesBeforeRound: issuedSharesBeforeRound,
    );
    if (pps == null || pps <= 0) return 0;
    return (convertibleAmount / pps).floor();
  }

  /// Estimated shares for FD calculation (before conversion)
  /// Uses valuation cap if available, otherwise cannot estimate
  int? get estimatedFDShares {
    if (!includeInFD) return null;
    if (status != ConvertibleStatus.outstanding) return null;
    if (valuationCap == null) return null;
    // This is a rough estimate - actual conversion depends on round terms
    // For FD purposes, we estimate based on cap
    return null; // Will be calculated by provider with context
  }

  String get typeDisplayName {
    switch (type) {
      case ConvertibleType.convertibleNote:
        return 'Convertible Note';
      case ConvertibleType.safe:
        return 'SAFE';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case ConvertibleStatus.outstanding:
        return 'Outstanding';
      case ConvertibleStatus.pendingConversion:
        return 'Pending Conversion';
      case ConvertibleStatus.converted:
        return 'Converted';
      case ConvertibleStatus.repaid:
        return 'Repaid';
      case ConvertibleStatus.cancelled:
        return 'Cancelled';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'investorId': investorId,
    'type': type.index,
    'principalAmount': principalAmount,
    'interestRate': interestRate,
    'discountPercent': discountPercent,
    'valuationCap': valuationCap,
    'maturityDate': maturityDate?.toIso8601String(),
    'issueDate': issueDate.toIso8601String(),
    'hasMFN': hasMFN,
    'hasProRata': hasProRata,
    'mfnUpgradeHistory': mfnUpgradeHistory.map((r) => r.toJson()).toList(),
    'status': status.index,
    'conversionRoundId': conversionRoundId,
    'conversionShares': conversionShares,
    'conversionPricePerShare': conversionPricePerShare,
    'conversionDate': conversionDate?.toIso8601String(),
    'includeInFD': includeInFD,
    'notes': notes,
  };

  factory ConvertibleInstrument.fromJson(Map<String, dynamic> json) {
    // Handle MFN upgrade history - new format or migrate from legacy
    List<MfnUpgradeRecord> mfnHistory = [];

    if (json['mfnUpgradeHistory'] != null) {
      // New format: list of upgrade records
      mfnHistory = (json['mfnUpgradeHistory'] as List)
          .map((r) => MfnUpgradeRecord.fromJson(r as Map<String, dynamic>))
          .toList();
    } else if (json['mfnAppliedDate'] != null) {
      // Legacy format: single MFN application - migrate to history
      mfnHistory = [
        MfnUpgradeRecord(
          id: const Uuid().v4(),
          upgradeDate: DateTime.parse(json['mfnAppliedDate']),
          sourceConvertibleId: json['mfnSourceId'] ?? 'unknown',
          previousDiscountPercent: json['originalDiscountPercent']?.toDouble(),
          previousValuationCap: json['originalValuationCap']?.toDouble(),
          previousHasProRata: false, // Legacy didn't track this
          newDiscountPercent: json['discountPercent']?.toDouble(),
          newValuationCap: json['valuationCap']?.toDouble(),
          newHasProRata: json['hasProRata'] ?? false,
        ),
      ];
    }

    return ConvertibleInstrument(
      id: json['id'],
      investorId: json['investorId'],
      type: ConvertibleType.values[json['type']],
      principalAmount: (json['principalAmount'] ?? 0).toDouble(),
      interestRate: json['interestRate']?.toDouble(),
      discountPercent: json['discountPercent']?.toDouble(),
      valuationCap: json['valuationCap']?.toDouble(),
      maturityDate: json['maturityDate'] != null
          ? DateTime.parse(json['maturityDate'])
          : null,
      issueDate: DateTime.parse(json['issueDate']),
      hasMFN: json['hasMFN'] ?? false,
      hasProRata: json['hasProRata'] ?? false,
      mfnUpgradeHistory: mfnHistory,
      status: ConvertibleStatus.values[json['status'] ?? 0],
      conversionRoundId: json['conversionRoundId'],
      conversionShares: json['conversionShares'],
      conversionPricePerShare: json['conversionPricePerShare']?.toDouble(),
      conversionDate: json['conversionDate'] != null
          ? DateTime.parse(json['conversionDate'])
          : null,
      includeInFD: json['includeInFD'] ?? true,
      notes: json['notes'],
    );
  }

  ConvertibleInstrument copyWith({
    String? investorId,
    ConvertibleType? type,
    double? principalAmount,
    double? interestRate,
    double? discountPercent,
    double? valuationCap,
    DateTime? maturityDate,
    DateTime? issueDate,
    bool? hasMFN,
    bool? hasProRata,
    List<MfnUpgradeRecord>? mfnUpgradeHistory,
    ConvertibleStatus? status,
    String? conversionRoundId,
    int? conversionShares,
    double? conversionPricePerShare,
    DateTime? conversionDate,
    bool? includeInFD,
    String? notes,
  }) {
    return ConvertibleInstrument(
      id: id,
      investorId: investorId ?? this.investorId,
      type: type ?? this.type,
      principalAmount: principalAmount ?? this.principalAmount,
      interestRate: interestRate ?? this.interestRate,
      discountPercent: discountPercent ?? this.discountPercent,
      valuationCap: valuationCap ?? this.valuationCap,
      maturityDate: maturityDate ?? this.maturityDate,
      issueDate: issueDate ?? this.issueDate,
      hasMFN: hasMFN ?? this.hasMFN,
      hasProRata: hasProRata ?? this.hasProRata,
      mfnUpgradeHistory: mfnUpgradeHistory ?? this.mfnUpgradeHistory,
      status: status ?? this.status,
      conversionRoundId: conversionRoundId ?? this.conversionRoundId,
      conversionShares: conversionShares ?? this.conversionShares,
      conversionPricePerShare:
          conversionPricePerShare ?? this.conversionPricePerShare,
      conversionDate: conversionDate ?? this.conversionDate,
      includeInFD: includeInFD ?? this.includeInFD,
      notes: notes ?? this.notes,
    );
  }
}
