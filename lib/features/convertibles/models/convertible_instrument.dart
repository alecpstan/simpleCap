import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

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

  /// Converted to equity in a round
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
    this.status = ConvertibleStatus.outstanding,
    this.conversionRoundId,
    this.conversionShares,
    this.conversionPricePerShare,
    this.conversionDate,
    this.includeInFD = true,
    this.notes,
  }) : id = id ?? const Uuid().v4();

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
    'status': status.index,
    'conversionRoundId': conversionRoundId,
    'conversionShares': conversionShares,
    'conversionPricePerShare': conversionPricePerShare,
    'conversionDate': conversionDate?.toIso8601String(),
    'includeInFD': includeInFD,
    'notes': notes,
  };

  factory ConvertibleInstrument.fromJson(Map<String, dynamic> json) =>
      ConvertibleInstrument(
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
