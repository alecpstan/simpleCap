import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Status of a warrant
enum WarrantStatus {
  /// Warrant issued but round is still draft - not yet active
  pending,

  /// Warrant is active and can be exercised
  active,

  /// Pending exercise - exercise recorded but round is still draft/open
  /// Will become exercised when the round is closed
  pendingExercise,

  partiallyExercised,
  fullyExercised,
  expired,
  cancelled,
}

/// Extension for status colors and display
extension WarrantStatusExtension on WarrantStatus {
  Color get color {
    switch (this) {
      case WarrantStatus.pending:
        return Colors.amber;
      case WarrantStatus.active:
        return Colors.blue;
      case WarrantStatus.pendingExercise:
        return Colors.orange;
      case WarrantStatus.partiallyExercised:
        return Colors.teal;
      case WarrantStatus.fullyExercised:
        return Colors.green;
      case WarrantStatus.expired:
        return Colors.grey;
      case WarrantStatus.cancelled:
        return Colors.red;
    }
  }

  String get displayName {
    switch (this) {
      case WarrantStatus.pending:
        return 'Pending (Draft)';
      case WarrantStatus.active:
        return 'Active';
      case WarrantStatus.pendingExercise:
        return 'Pending Exercise';
      case WarrantStatus.partiallyExercised:
        return 'Partially Exercised';
      case WarrantStatus.fullyExercised:
        return 'Fully Exercised';
      case WarrantStatus.expired:
        return 'Expired';
      case WarrantStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Represents an investor warrant - the right to purchase shares at a fixed price.
/// Similar to options but issued to investors rather than employees.
/// Often attached as "warrant coverage" to convertible notes or SAFEs.
class Warrant {
  final String id;

  /// The investor holding this warrant
  final String investorId;

  /// Round this warrant was issued in (if any)
  final String? roundId;

  /// Number of shares the warrant allows purchasing
  final int numberOfWarrants;

  /// Strike/exercise price per share
  final double strikePrice;

  /// Date warrant was issued
  final DateTime issueDate;

  /// Expiry date (typically 5-10 years for warrants)
  final DateTime expiryDate;

  /// Number already exercised
  int exercisedCount;

  /// Number cancelled/forfeited
  int cancelledCount;

  /// Link to exercise transaction (if any)
  String? exerciseTransactionId;

  /// Current status
  WarrantStatus status;

  /// Source: If this warrant came from warrant coverage on a convertible
  final String? sourceConvertibleId;

  /// Coverage percent (if from a convertible, e.g., 10% = 0.10)
  final double? coveragePercent;

  /// Share class for exercised shares
  final String? shareClassId;

  /// Optional notes
  String? notes;

  Warrant({
    String? id,
    required this.investorId,
    this.roundId,
    required this.numberOfWarrants,
    required this.strikePrice,
    required this.issueDate,
    required this.expiryDate,
    this.exercisedCount = 0,
    this.cancelledCount = 0,
    this.exerciseTransactionId,
    this.status = WarrantStatus.active,
    this.sourceConvertibleId,
    this.coveragePercent,
    this.shareClassId,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  /// Remaining warrants that can be exercised
  int get remainingWarrants =>
      numberOfWarrants - exercisedCount - cancelledCount;

  /// Whether the warrant can be exercised
  bool get canExercise =>
      status == WarrantStatus.active ||
      status == WarrantStatus.partiallyExercised;

  /// Whether the warrant is expired
  bool get isExpired => DateTime.now().isAfter(expiryDate);

  /// Intrinsic value = (current price - strike price) * remaining warrants
  /// Returns 0 if out of the money
  double intrinsicValue(double currentPrice) {
    if (currentPrice <= strikePrice) return 0;
    return (currentPrice - strikePrice) * remainingWarrants;
  }

  /// Check if in the money
  bool isInTheMoney(double currentPrice) => currentPrice > strikePrice;

  /// Calculate warrant coverage shares from an investment amount
  static int calculateCoverageShares({
    required double investmentAmount,
    required double coveragePercent,
    required double strikePrice,
  }) {
    if (strikePrice <= 0) return 0;
    final coverageValue = investmentAmount * coveragePercent;
    return (coverageValue / strikePrice).floor();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'investorId': investorId,
        'roundId': roundId,
        'numberOfWarrants': numberOfWarrants,
        'strikePrice': strikePrice,
        'issueDate': issueDate.toIso8601String(),
        'expiryDate': expiryDate.toIso8601String(),
        'exercisedCount': exercisedCount,
        'cancelledCount': cancelledCount,
        'exerciseTransactionId': exerciseTransactionId,
        'status': status.name,
        'sourceConvertibleId': sourceConvertibleId,
        'coveragePercent': coveragePercent,
        'shareClassId': shareClassId,
        'notes': notes,
      };

  factory Warrant.fromJson(Map<String, dynamic> json) {
    // Handle both old index-based and new name-based status serialization
    WarrantStatus status;
    final statusValue = json['status'];
    if (statusValue is int) {
      // Legacy: migrate old index-based status
      // Old indices: 0=active, 1=pendingExercise, 2=partiallyExercised, etc.
      // New indices: 0=pending, 1=active, 2=pendingExercise, etc.
      // Map old indices to correct status
      const oldIndexMap = {
        0: WarrantStatus.active,
        1: WarrantStatus.pendingExercise,
        2: WarrantStatus.partiallyExercised,
        3: WarrantStatus.fullyExercised,
        4: WarrantStatus.expired,
        5: WarrantStatus.cancelled,
      };
      status = oldIndexMap[statusValue] ?? WarrantStatus.active;
    } else if (statusValue is String) {
      status = WarrantStatus.values.firstWhere(
        (e) => e.name == statusValue,
        orElse: () => WarrantStatus.active,
      );
    } else {
      status = WarrantStatus.active;
    }

    return Warrant(
      id: json['id'],
      investorId: json['investorId'],
      roundId: json['roundId'],
      numberOfWarrants: json['numberOfWarrants'] ?? 0,
      strikePrice: (json['strikePrice'] ?? 0).toDouble(),
      issueDate: DateTime.parse(json['issueDate']),
      expiryDate: DateTime.parse(json['expiryDate']),
      exercisedCount: json['exercisedCount'] ?? 0,
      cancelledCount: json['cancelledCount'] ?? 0,
      exerciseTransactionId: json['exerciseTransactionId'],
      status: status,
      sourceConvertibleId: json['sourceConvertibleId'],
      coveragePercent: json['coveragePercent']?.toDouble(),
      shareClassId: json['shareClassId'],
      notes: json['notes'],
    );
  }

  Warrant copyWith({
    String? investorId,
    String? roundId,
    int? numberOfWarrants,
    double? strikePrice,
    DateTime? issueDate,
    DateTime? expiryDate,
    int? exercisedCount,
    int? cancelledCount,
    String? exerciseTransactionId,
    WarrantStatus? status,
    String? sourceConvertibleId,
    double? coveragePercent,
    String? shareClassId,
    String? notes,
  }) {
    return Warrant(
      id: id,
      investorId: investorId ?? this.investorId,
      roundId: roundId ?? this.roundId,
      numberOfWarrants: numberOfWarrants ?? this.numberOfWarrants,
      strikePrice: strikePrice ?? this.strikePrice,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      exercisedCount: exercisedCount ?? this.exercisedCount,
      cancelledCount: cancelledCount ?? this.cancelledCount,
      exerciseTransactionId:
          exerciseTransactionId ?? this.exerciseTransactionId,
      status: status ?? this.status,
      sourceConvertibleId: sourceConvertibleId ?? this.sourceConvertibleId,
      coveragePercent: coveragePercent ?? this.coveragePercent,
      shareClassId: shareClassId ?? this.shareClassId,
      notes: notes ?? this.notes,
    );
  }
}
