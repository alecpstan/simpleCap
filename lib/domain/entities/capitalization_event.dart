import 'package:freezed_annotation/freezed_annotation.dart';

part 'capitalization_event.freezed.dart';
part 'capitalization_event.g.dart';

/// Types of capitalization events that can occur.
enum CapEventType {
  // Share movements
  shareIssuance,
  shareTransfer,
  shareCancellation,

  // Convertibles
  convertibleIssuance,
  convertibleConversion,
  convertibleCancellation,

  // Options
  optionGrant,
  optionExercise,
  optionCancellation,
  optionForfeiture,

  // Warrants
  warrantIssuance,
  warrantExercise,
  warrantCancellation,

  // Pool management
  esopPoolCreation,
  esopPoolExpansion,

  // Round lifecycle
  roundOpened,
  roundClosed;

  String get displayName => switch (this) {
    shareIssuance => 'Share Issuance',
    shareTransfer => 'Share Transfer',
    shareCancellation => 'Share Cancellation',
    convertibleIssuance => 'Convertible Issued',
    convertibleConversion => 'Convertible Conversion',
    convertibleCancellation => 'Convertible Cancelled',
    optionGrant => 'Option Grant',
    optionExercise => 'Option Exercise',
    optionCancellation => 'Option Cancellation',
    optionForfeiture => 'Option Forfeiture',
    warrantIssuance => 'Warrant Issued',
    warrantExercise => 'Warrant Exercise',
    warrantCancellation => 'Warrant Cancelled',
    esopPoolCreation => 'ESOP Pool Created',
    esopPoolExpansion => 'ESOP Pool Expanded',
    roundOpened => 'Round Opened',
    roundClosed => 'Round Closed',
  };

  /// Whether this event changes share ownership.
  bool get affectsOwnership => switch (this) {
    shareIssuance ||
    shareTransfer ||
    shareCancellation ||
    convertibleConversion ||
    optionExercise ||
    warrantExercise => true,
    _ => false,
  };
}

/// An immutable record of a capitalization event.
///
/// The cap table state is computed by replaying all events in order.
/// This enables:
/// - Full audit trail
/// - Point-in-time snapshots
/// - Undo/redo capabilities
/// - Conflict resolution for sync
@freezed
class CapitalizationEvent with _$CapitalizationEvent {
  const CapitalizationEvent._();

  const factory CapitalizationEvent({
    required String id,
    required String companyId,
    required CapEventType eventType,

    /// Date when this event takes effect.
    required DateTime effectiveDate,

    /// JSON payload containing event-specific data.
    required String eventDataJson,

    /// Round associated with this event (if any).
    String? roundId,

    /// When this event was recorded.
    required DateTime createdAt,
  }) = _CapitalizationEvent;

  factory CapitalizationEvent.fromJson(Map<String, dynamic> json) =>
      _$CapitalizationEventFromJson(json);
}

// ============================================================================
// Event Data Classes (stored as JSON in eventDataJson)
// ============================================================================

/// Data for share issuance events.
@freezed
class ShareIssuanceData with _$ShareIssuanceData {
  const factory ShareIssuanceData({
    required String stakeholderId,
    required String shareClassId,
    required int shareCount,
    required double pricePerShare,
    required double totalAmount,
    String? vestingScheduleId,
  }) = _ShareIssuanceData;

  factory ShareIssuanceData.fromJson(Map<String, dynamic> json) =>
      _$ShareIssuanceDataFromJson(json);
}

/// Data for share transfer events.
@freezed
class ShareTransferData with _$ShareTransferData {
  const factory ShareTransferData({
    required String fromStakeholderId,
    required String toStakeholderId,
    required String shareClassId,
    required int shareCount,
    required double pricePerShare,
    required double totalAmount,
  }) = _ShareTransferData;

  factory ShareTransferData.fromJson(Map<String, dynamic> json) =>
      _$ShareTransferDataFromJson(json);
}

/// Data for share cancellation events (buyback, forfeiture).
@freezed
class ShareCancellationData with _$ShareCancellationData {
  const factory ShareCancellationData({
    required String stakeholderId,
    required String shareClassId,
    required int shareCount,
    double? repurchasePrice,
    String? reason,
  }) = _ShareCancellationData;

  factory ShareCancellationData.fromJson(Map<String, dynamic> json) =>
      _$ShareCancellationDataFromJson(json);
}

/// Data for option/warrant exercise events.
@freezed
class ExerciseData with _$ExerciseData {
  const factory ExerciseData({
    /// ID of the option grant or warrant being exercised.
    required String instrumentId,
    required String stakeholderId,
    required String shareClassId,
    required int quantity,
    required double strikePrice,
    required double totalCost,
  }) = _ExerciseData;

  factory ExerciseData.fromJson(Map<String, dynamic> json) =>
      _$ExerciseDataFromJson(json);
}

/// Data for convertible conversion events.
@freezed
class ConversionData with _$ConversionData {
  const factory ConversionData({
    required String convertibleId,
    required String stakeholderId,
    required String shareClassId,
    required int sharesIssued,
    required double effectivePrice,
    required double principalConverted,
    required double interestConverted,
  }) = _ConversionData;

  factory ConversionData.fromJson(Map<String, dynamic> json) =>
      _$ConversionDataFromJson(json);
}
