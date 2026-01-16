import 'package:freezed_annotation/freezed_annotation.dart';

part 'holding.freezed.dart';
part 'holding.g.dart';

/// A stakeholder's position in a specific share class.
///
/// Holdings represent the current ownership state computed from
/// capitalization events. They can be fully or partially vested.
@freezed
class Holding with _$Holding {
  const Holding._();

  const factory Holding({
    required String id,
    required String companyId,
    required String stakeholderId,
    required String shareClassId,

    /// Number of shares held.
    required int shareCount,

    /// Total cost basis (amount paid for these shares).
    required double costBasis,

    /// Date shares were acquired.
    required DateTime acquiredDate,

    /// Vesting schedule ID (if shares are subject to vesting).
    String? vestingScheduleId,

    /// Number of shares currently vested (null = all vested).
    int? vestedCount,

    required DateTime updatedAt,
  }) = _Holding;

  factory Holding.fromJson(Map<String, dynamic> json) =>
      _$HoldingFromJson(json);

  /// Price per share at acquisition.
  double get pricePerShare {
    if (shareCount == 0) return 0;
    return costBasis / shareCount;
  }

  /// Number of vested shares.
  int get vested => vestedCount ?? shareCount;

  /// Number of unvested shares.
  int get unvested => shareCount - vested;

  /// Whether all shares are vested.
  bool get isFullyVested => unvested == 0;

  /// Whether shares are subject to vesting.
  bool get hasVesting => vestingScheduleId != null;

  /// Vesting percentage (0-100).
  double get vestingPercent {
    if (shareCount == 0) return 100;
    return (vested / shareCount) * 100;
  }
}
