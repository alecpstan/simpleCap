import 'package:freezed_annotation/freezed_annotation.dart';

part 'option_grant.freezed.dart';
part 'option_grant.g.dart';

/// Status of an option grant.
enum OptionGrantStatus {
  /// Grant created but round still draft.
  pending,

  /// Options granted and active.
  active,

  /// Some options have been exercised.
  partiallyExercised,

  /// All options have been exercised.
  fullyExercised,

  /// Options expired without exercise.
  expired,

  /// Options cancelled (e.g., bad leaver).
  cancelled,

  /// Unvested options forfeited.
  forfeited;

  String get displayName => switch (this) {
    pending => 'Pending',
    active => 'Active',
    partiallyExercised => 'Partially Exercised',
    fullyExercised => 'Fully Exercised',
    expired => 'Expired',
    cancelled => 'Cancelled',
    forfeited => 'Forfeited',
  };

  /// Whether options can still be exercised.
  bool get isExercisable => this == active || this == partiallyExercised;
}

/// An employee stock option grant.
///
/// Options give the holder the right (but not obligation) to purchase
/// shares at a fixed strike price within a specified time window.
@freezed
class OptionGrant with _$OptionGrant {
  const OptionGrant._();

  const factory OptionGrant({
    required String id,
    required String companyId,
    required String stakeholderId,
    required String shareClassId,

    /// ESOP pool this grant draws from (if applicable).
    String? esopPoolId,

    @Default(OptionGrantStatus.pending) OptionGrantStatus status,

    /// Total number of options granted.
    required int quantity,

    /// Strike price (exercise price) per share.
    required double strikePrice,

    /// Date options were granted.
    required DateTime grantDate,

    /// Expiry date (typically 10 years from grant).
    required DateTime expiryDate,

    /// Number of options already exercised.
    @Default(0) int exercisedCount,

    /// Number of options cancelled/forfeited.
    @Default(0) int cancelledCount,

    /// Vesting schedule ID.
    String? vestingScheduleId,

    /// Round ID this grant is associated with.
    String? roundId,

    /// Whether early exercise is allowed.
    @Default(false) bool allowsEarlyExercise,

    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _OptionGrant;

  factory OptionGrant.fromJson(Map<String, dynamic> json) =>
      _$OptionGrantFromJson(json);

  /// Options remaining (not exercised or cancelled).
  int get remaining => quantity - exercisedCount - cancelledCount;

  /// Whether the grant is fully exercised.
  bool get isFullyExercised => remaining == 0 && exercisedCount > 0;

  /// Whether options have expired.
  bool get isExpired => DateTime.now().isAfter(expiryDate);

  /// Days until expiry.
  int get daysUntilExpiry => expiryDate.difference(DateTime.now()).inDays;

  /// Total cost to exercise all remaining options.
  double get totalExerciseCost => remaining * strikePrice;

  /// Intrinsic value at a given current share price.
  double intrinsicValue(double currentSharePrice) {
    final spread = currentSharePrice - strikePrice;
    if (spread <= 0) return 0;
    return spread * remaining;
  }

  /// Whether options are "in the money" at given price.
  bool isInTheMoney(double currentSharePrice) =>
      currentSharePrice > strikePrice;
}
