import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Status of an option grant
enum OptionGrantStatus {
  /// Options granted but not yet exercised
  active,

  /// Some options have been exercised
  partiallyExercised,

  /// All options have been exercised
  fullyExercised,

  /// Options expired without being exercised
  expired,

  /// Options cancelled (e.g., employee left as bad leaver)
  cancelled,

  /// Options forfeited (unvested portion on termination)
  forfeited,
}

/// Extension for status colors
extension OptionGrantStatusColor on OptionGrantStatus {
  Color get color {
    switch (this) {
      case OptionGrantStatus.active:
      case OptionGrantStatus.partiallyExercised:
        return Colors.blue;
      case OptionGrantStatus.fullyExercised:
        return Colors.green;
      case OptionGrantStatus.expired:
        return Colors.grey;
      case OptionGrantStatus.cancelled:
      case OptionGrantStatus.forfeited:
        return Colors.red;
    }
  }
}

/// Represents an employee stock option grant (ESOP/ESS)
/// This is separate from Transaction - options exist before exercise
class OptionGrant {
  final String id;

  /// The employee/recipient of the options
  final String investorId;

  /// The share class these options convert to (typically ESOP class)
  final String shareClassId;

  /// Total number of options granted
  final int numberOfOptions;

  /// Strike/exercise price per share
  final double strikePrice;

  /// Date options were granted
  final DateTime grantDate;

  /// Expiry date (typically 10 years from grant, or earlier on termination)
  final DateTime expiryDate;

  /// Current status
  final OptionGrantStatus status;

  /// Number of options already exercised
  final int exercisedCount;

  /// Number of options cancelled/forfeited
  final int cancelledCount;

  /// Link to vesting schedule (options typically vest over time)
  final String? vestingScheduleId;

  /// Transaction ID when options were exercised (if any)
  final String? exerciseTransactionId;

  /// Notes
  final String? notes;

  /// Early exercise allowed (rare in Australia, common in US)
  final bool earlyExerciseAllowed;

  /// For ESS tax treatment in Australia
  final bool essCompliant;

  OptionGrant({
    String? id,
    required this.investorId,
    required this.shareClassId,
    required this.numberOfOptions,
    required this.strikePrice,
    required this.grantDate,
    required this.expiryDate,
    this.status = OptionGrantStatus.active,
    this.exercisedCount = 0,
    this.cancelledCount = 0,
    this.vestingScheduleId,
    this.exerciseTransactionId,
    this.notes,
    this.earlyExerciseAllowed = false,
    this.essCompliant = true,
  }) : id = id ?? const Uuid().v4();

  /// Options remaining that can be exercised
  int get remainingOptions => numberOfOptions - exercisedCount - cancelledCount;

  /// Whether any options remain to exercise
  bool get canExercise =>
      remainingOptions > 0 &&
      status != OptionGrantStatus.expired &&
      status != OptionGrantStatus.cancelled &&
      status != OptionGrantStatus.forfeited;

  /// Whether options have expired
  bool get isExpired => DateTime.now().isAfter(expiryDate);

  /// Total value at strike price
  double get totalStrikeValue => numberOfOptions * strikePrice;

  /// Calculate intrinsic value given current share price (uses all remaining options)
  double intrinsicValue(double currentPrice) {
    if (currentPrice <= strikePrice) return 0;
    return remainingOptions * (currentPrice - strikePrice);
  }

  /// Calculate intrinsic value for vested options only (exercisable value)
  /// This is more accurate as you can only exercise vested options
  double vestedIntrinsicValue(double currentPrice, double vestingPercent) {
    if (currentPrice <= strikePrice) return 0;
    final vestedOptions = (numberOfOptions * vestingPercent / 100).round();
    final exercisableOptions = (vestedOptions - exercisedCount).clamp(
      0,
      remainingOptions,
    );
    return exercisableOptions * (currentPrice - strikePrice);
  }

  /// Get number of vested options based on vesting percentage
  int vestedOptionsCount(double vestingPercent) {
    return (numberOfOptions * vestingPercent / 100).round();
  }

  /// Get exercisable options (vested minus already exercised)
  int exercisableOptionsCount(double vestingPercent) {
    final vested = vestedOptionsCount(vestingPercent);
    return (vested - exercisedCount).clamp(0, remainingOptions);
  }

  /// Display name for status
  String get statusDisplayName {
    switch (status) {
      case OptionGrantStatus.active:
        return 'Active';
      case OptionGrantStatus.partiallyExercised:
        return 'Partially Exercised';
      case OptionGrantStatus.fullyExercised:
        return 'Fully Exercised';
      case OptionGrantStatus.expired:
        return 'Expired';
      case OptionGrantStatus.cancelled:
        return 'Cancelled';
      case OptionGrantStatus.forfeited:
        return 'Forfeited';
    }
  }

  OptionGrant copyWith({
    String? investorId,
    String? shareClassId,
    int? numberOfOptions,
    double? strikePrice,
    DateTime? grantDate,
    DateTime? expiryDate,
    OptionGrantStatus? status,
    int? exercisedCount,
    int? cancelledCount,
    String? vestingScheduleId,
    String? exerciseTransactionId,
    String? notes,
    bool? earlyExerciseAllowed,
    bool? essCompliant,
  }) {
    return OptionGrant(
      id: id,
      investorId: investorId ?? this.investorId,
      shareClassId: shareClassId ?? this.shareClassId,
      numberOfOptions: numberOfOptions ?? this.numberOfOptions,
      strikePrice: strikePrice ?? this.strikePrice,
      grantDate: grantDate ?? this.grantDate,
      expiryDate: expiryDate ?? this.expiryDate,
      status: status ?? this.status,
      exercisedCount: exercisedCount ?? this.exercisedCount,
      cancelledCount: cancelledCount ?? this.cancelledCount,
      vestingScheduleId: vestingScheduleId ?? this.vestingScheduleId,
      exerciseTransactionId:
          exerciseTransactionId ?? this.exerciseTransactionId,
      notes: notes ?? this.notes,
      earlyExerciseAllowed: earlyExerciseAllowed ?? this.earlyExerciseAllowed,
      essCompliant: essCompliant ?? this.essCompliant,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'investorId': investorId,
    'shareClassId': shareClassId,
    'numberOfOptions': numberOfOptions,
    'strikePrice': strikePrice,
    'grantDate': grantDate.toIso8601String(),
    'expiryDate': expiryDate.toIso8601String(),
    'status': status.name,
    'exercisedCount': exercisedCount,
    'cancelledCount': cancelledCount,
    'vestingScheduleId': vestingScheduleId,
    'exerciseTransactionId': exerciseTransactionId,
    'notes': notes,
    'earlyExerciseAllowed': earlyExerciseAllowed,
    'essCompliant': essCompliant,
  };

  factory OptionGrant.fromJson(Map<String, dynamic> json) => OptionGrant(
    id: json['id'],
    investorId: json['investorId'],
    shareClassId: json['shareClassId'],
    numberOfOptions: json['numberOfOptions'],
    strikePrice: (json['strikePrice'] as num).toDouble(),
    grantDate: DateTime.parse(json['grantDate']),
    expiryDate: DateTime.parse(json['expiryDate']),
    status: OptionGrantStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => OptionGrantStatus.active,
    ),
    exercisedCount: json['exercisedCount'] ?? 0,
    cancelledCount: json['cancelledCount'] ?? 0,
    vestingScheduleId: json['vestingScheduleId'],
    exerciseTransactionId: json['exerciseTransactionId'],
    notes: json['notes'],
    earlyExerciseAllowed: json['earlyExerciseAllowed'] ?? false,
    essCompliant: json['essCompliant'] ?? true,
  );
}
