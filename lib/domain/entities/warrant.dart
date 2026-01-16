import 'package:freezed_annotation/freezed_annotation.dart';

part 'warrant.freezed.dart';
part 'warrant.g.dart';

/// Status of a warrant.
enum WarrantStatus {
  /// Warrant created but round still draft.
  pending,

  /// Warrant is active and exercisable.
  active,

  /// Some warrants have been exercised.
  partiallyExercised,

  /// All warrants have been exercised.
  fullyExercised,

  /// Warrants expired.
  expired,

  /// Warrants cancelled.
  cancelled;

  String get displayName => switch (this) {
    pending => 'Pending',
    active => 'Active',
    partiallyExercised => 'Partially Exercised',
    fullyExercised => 'Fully Exercised',
    expired => 'Expired',
    cancelled => 'Cancelled',
  };

  bool get isExercisable => this == active || this == partiallyExercised;
}

/// An investor warrant - the right to purchase shares at a fixed price.
///
/// Similar to options but typically issued to investors as part of
/// a financing (e.g., warrant coverage on a convertible note).
@freezed
class Warrant with _$Warrant {
  const Warrant._();

  const factory Warrant({
    required String id,
    required String companyId,
    required String stakeholderId,
    required String shareClassId,
    @Default(WarrantStatus.pending) WarrantStatus status,

    /// Number of shares the warrant allows purchasing.
    required int quantity,

    /// Strike/exercise price per share.
    required double strikePrice,

    /// Date warrant was issued.
    required DateTime issueDate,

    /// Expiry date (typically 5-10 years).
    required DateTime expiryDate,

    /// Number already exercised.
    @Default(0) int exercisedCount,

    /// Number cancelled.
    @Default(0) int cancelledCount,

    /// If this warrant came from warrant coverage on a convertible.
    String? sourceConvertibleId,

    /// Round ID this warrant is associated with.
    String? roundId,

    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Warrant;

  factory Warrant.fromJson(Map<String, dynamic> json) =>
      _$WarrantFromJson(json);

  /// Warrants remaining (not exercised or cancelled).
  int get remaining => quantity - exercisedCount - cancelledCount;

  /// Whether fully exercised.
  bool get isFullyExercised => remaining == 0 && exercisedCount > 0;

  /// Whether expired.
  bool get isExpired => DateTime.now().isAfter(expiryDate);

  /// Days until expiry.
  int get daysUntilExpiry => expiryDate.difference(DateTime.now()).inDays;

  /// Total cost to exercise all remaining warrants.
  double get totalExerciseCost => remaining * strikePrice;

  /// Intrinsic value at a given current share price.
  double intrinsicValue(double currentSharePrice) {
    final spread = currentSharePrice - strikePrice;
    if (spread <= 0) return 0;
    return spread * remaining;
  }
}
