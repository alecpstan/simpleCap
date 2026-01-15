import 'package:uuid/uuid.dart';

/// Represents a change to the ESOP pool (addition or subtraction)
/// Used for tracking pool history and audit trail
class EsopPoolChange {
  final String id;

  /// Date of the pool change (e.g., board resolution date)
  final DateTime date;

  /// Number of shares added (positive) or removed (negative)
  final int sharesDelta;

  /// Optional notes (e.g., "Series A condition", "Board resolution 2024-03")
  final String? notes;

  /// Timestamp when this record was created
  final DateTime createdAt;

  EsopPoolChange({
    String? id,
    required this.date,
    required this.sharesDelta,
    this.notes,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  /// Whether this is an addition to the pool
  bool get isAddition => sharesDelta > 0;

  /// Whether this is a reduction from the pool
  bool get isReduction => sharesDelta < 0;

  /// Absolute value of shares changed
  int get absoluteShares => sharesDelta.abs();

  EsopPoolChange copyWith({DateTime? date, int? sharesDelta, String? notes}) {
    return EsopPoolChange(
      id: id,
      date: date ?? this.date,
      sharesDelta: sharesDelta ?? this.sharesDelta,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'sharesDelta': sharesDelta,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };

  factory EsopPoolChange.fromJson(Map<String, dynamic> json) => EsopPoolChange(
    id: json['id'],
    date: DateTime.parse(json['date']),
    sharesDelta: json['sharesDelta'],
    notes: json['notes'],
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
  );
}
