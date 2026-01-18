import 'package:freezed_annotation/freezed_annotation.dart';

part 'esop_pool.freezed.dart';
part 'esop_pool.g.dart';

/// Status of an ESOP pool.
enum EsopPoolStatus {
  /// Pool created but not yet active.
  draft,

  /// Pool is active and accepting grants.
  active,

  /// Pool is fully allocated.
  fullyAllocated,

  /// Pool has been closed/terminated.
  closed;

  String get displayName => switch (this) {
    draft => 'Draft',
    active => 'Active',
    fullyAllocated => 'Fully Allocated',
    closed => 'Closed',
  };

  /// Whether new grants can be made from this pool.
  bool get canGrant => this == active;
}

/// An Employee Stock Ownership Plan (ESOP) pool.
///
/// The ESOP pool reserves a portion of the company's equity for
/// employee incentive grants (options, performance rights, etc.).
///
/// Key concepts:
/// - Pool size: Total shares reserved for ESOP
/// - Allocated: Shares granted to employees (as options)
/// - Available: Pool size minus allocated (remaining for future grants)
/// - Exercised: Options that have been converted to actual shares
@freezed
class EsopPool with _$EsopPool {
  const EsopPool._();

  const factory EsopPool({
    required String id,
    required String companyId,

    /// Name of the pool (e.g., "2024 ESOP", "Employee Option Pool").
    required String name,

    /// Current status of the pool.
    @Default(EsopPoolStatus.draft) EsopPoolStatus status,

    /// Total number of shares/options reserved in this pool.
    required int poolSize,

    /// Target percentage of fully diluted capital (for reference).
    /// Used for planning; actual % varies with cap table changes.
    double? targetPercentage,

    /// Date the pool was established.
    required DateTime establishedDate,

    /// Board/shareholder resolution reference.
    String? resolutionReference,

    /// Associated round (if pool was created as part of a round).
    String? roundId,

    /// Default vesting schedule for grants from this pool.
    String? defaultVestingScheduleId,

    /// Default strike price method.
    /// 'fmv' = Fair Market Value at grant, 'fixed' = use defaultStrikePrice
    @Default('fmv') String strikePriceMethod,

    /// Fixed strike price (if strikePriceMethod is 'fixed').
    double? defaultStrikePrice,

    /// Default expiry period in years from grant date.
    @Default(10) int defaultExpiryYears,

    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _EsopPool;

  factory EsopPool.fromJson(Map<String, dynamic> json) =>
      _$EsopPoolFromJson(json);

  /// Calculates allocated shares from a list of option grants.
  int allocatedFrom(List<dynamic> optionGrants) {
    int allocated = 0;
    for (final grant in optionGrants) {
      // Support both domain entity and DB row
      if (grant is Map) {
        allocated += (grant['quantity'] as int? ?? 0);
      } else {
        // Assume it has a quantity property
        allocated += (grant.quantity as int? ?? 0);
      }
    }
    return allocated;
  }

  /// Available shares = pool size minus allocated.
  int availableFrom(List<dynamic> optionGrants) =>
      poolSize - allocatedFrom(optionGrants);

  /// Whether the pool has capacity for a grant of given size.
  bool canGrantFrom(int quantity, List<dynamic> optionGrants) =>
      status.canGrant && quantity <= availableFrom(optionGrants);
}

/// Data for ESOP pool creation events.
@freezed
class EsopPoolCreationData with _$EsopPoolCreationData {
  const factory EsopPoolCreationData({
    required String poolId,
    required int poolSize,
    double? targetPercentage,
    String? resolutionReference,
  }) = _EsopPoolCreationData;

  factory EsopPoolCreationData.fromJson(Map<String, dynamic> json) =>
      _$EsopPoolCreationDataFromJson(json);
}

/// Data for ESOP pool expansion events.
@freezed
class EsopPoolExpansionData with _$EsopPoolExpansionData {
  const factory EsopPoolExpansionData({
    required String poolId,
    required int previousSize,
    required int newSize,
    required int addedShares,
    String? resolutionReference,
  }) = _EsopPoolExpansionData;

  factory EsopPoolExpansionData.fromJson(Map<String, dynamic> json) =>
      _$EsopPoolExpansionDataFromJson(json);
}

/// Data for option grant events (references ESOP pool).
@freezed
class OptionGrantData with _$OptionGrantData {
  const factory OptionGrantData({
    required String grantId,
    required String poolId,
    required String stakeholderId,
    required int quantity,
    required double strikePrice,
    String? vestingScheduleId,
  }) = _OptionGrantData;

  factory OptionGrantData.fromJson(Map<String, dynamic> json) =>
      _$OptionGrantDataFromJson(json);
}
