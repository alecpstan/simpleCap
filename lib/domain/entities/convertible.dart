import 'package:freezed_annotation/freezed_annotation.dart';

part 'convertible.freezed.dart';
part 'convertible.g.dart';

/// Types of convertible instruments.
enum ConvertibleType {
  /// Simple Agreement for Future Equity.
  safe,

  /// Traditional convertible note with interest and maturity.
  convertibleNote;

  String get displayName => switch (this) {
    safe => 'SAFE',
    convertibleNote => 'Convertible Note',
  };
}

/// Status of a convertible instrument.
enum ConvertibleStatus {
  /// Active and not yet converted.
  outstanding,

  /// Converted to equity.
  converted,

  /// Cancelled or repaid.
  cancelled;

  String get displayName => switch (this) {
    outstanding => 'Outstanding',
    converted => 'Converted',
    cancelled => 'Cancelled',
  };
}

/// A convertible instrument (SAFE or Convertible Note).
///
/// Convertibles are debt-like instruments that convert to equity
/// upon a qualifying financing event (typically the next priced round).
@freezed
class Convertible with _$Convertible {
  const Convertible._();

  const factory Convertible({
    required String id,
    required String companyId,
    required String stakeholderId,
    required ConvertibleType type,
    @Default(ConvertibleStatus.outstanding) ConvertibleStatus status,

    /// Principal amount invested.
    required double principal,

    /// Valuation cap (if any).
    double? valuationCap,

    /// Discount percentage (0-100).
    double? discountPercent,

    /// Interest rate for notes (annual, 0-100).
    double? interestRate,

    /// Maturity date for notes.
    DateTime? maturityDate,

    /// Date instrument was issued.
    required DateTime issueDate,

    /// Whether this has Most Favored Nation clause.
    @Default(false) bool hasMfn,

    /// Whether holder has pro-rata rights in future rounds.
    @Default(false) bool hasProRata,

    /// Transaction ID when converted (if converted).
    String? conversionEventId,

    /// Share class ID received on conversion.
    String? convertedToShareClassId,

    /// Number of shares received on conversion.
    int? sharesReceived,

    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Convertible;

  factory Convertible.fromJson(Map<String, dynamic> json) =>
      _$ConvertibleFromJson(json);

  /// Whether this is a note (has interest and maturity).
  bool get isNote => type == ConvertibleType.convertibleNote;

  /// Whether this is a SAFE.
  bool get isSafe => type == ConvertibleType.safe;

  /// Whether this instrument is still outstanding.
  bool get isOutstanding => status == ConvertibleStatus.outstanding;

  /// Whether this has been converted.
  bool get isConverted => status == ConvertibleStatus.converted;

  /// Accrued interest for notes (simple interest calculation).
  double get accruedInterest {
    if (!isNote || interestRate == null) return 0;

    final years = DateTime.now().difference(issueDate).inDays / 365;
    return principal * (interestRate! / 100) * years;
  }

  /// Total value including accrued interest.
  double get totalValue => principal + accruedInterest;

  /// Calculate effective price per share at a given valuation.
  double? effectivePrice({
    required double roundPricePerShare,
    required int preMoneyShares,
  }) {
    double? capPrice;
    double? discountPrice;

    // Cap-based price
    if (valuationCap != null && valuationCap! > 0 && preMoneyShares > 0) {
      capPrice = valuationCap! / preMoneyShares;
    }

    // Discount-based price
    if (discountPercent != null && discountPercent! > 0) {
      discountPrice = roundPricePerShare * (1 - discountPercent! / 100);
    }

    // Return the lower of cap or discount price (better for investor)
    if (capPrice != null && discountPrice != null) {
      return capPrice < discountPrice ? capPrice : discountPrice;
    }
    return capPrice ?? discountPrice ?? roundPricePerShare;
  }

  /// Calculate shares received at conversion.
  int sharesToReceive({
    required double roundPricePerShare,
    required int preMoneyShares,
  }) {
    final price = effectivePrice(
      roundPricePerShare: roundPricePerShare,
      preMoneyShares: preMoneyShares,
    );
    if (price == null || price <= 0) return 0;
    return (totalValue / price).floor();
  }
}
