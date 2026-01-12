import 'package:uuid/uuid.dart';

enum VestingType { timeBased, milestoneBased, reverse }

enum VestingFrequency { monthly, quarterly, annually }

enum LeaverStatus { active, goodLeaver, badLeaver }

class VestingSchedule {
  final String id;
  String shareholdingId; // Links to a specific shareholding
  VestingType type;
  DateTime startDate;
  int vestingPeriodMonths; // Total vesting period (e.g., 48 for 4 years)
  int cliffMonths; // Cliff period (e.g., 12 for 1 year)
  VestingFrequency frequency;
  double accelerationPercent; // % to accelerate on liquidity event (0-100)
  LeaverStatus leaverStatus;
  DateTime? terminationDate; // If employee left
  String? notes;

  VestingSchedule({
    String? id,
    required this.shareholdingId,
    this.type = VestingType.timeBased,
    required this.startDate,
    this.vestingPeriodMonths = 48,
    this.cliffMonths = 12,
    this.frequency = VestingFrequency.monthly,
    this.accelerationPercent = 0,
    this.leaverStatus = LeaverStatus.active,
    this.terminationDate,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  /// Calculate the cliff date
  DateTime get cliffDate =>
      DateTime(startDate.year, startDate.month + cliffMonths, startDate.day);

  /// Calculate the full vesting end date
  DateTime get endDate => DateTime(
    startDate.year,
    startDate.month + vestingPeriodMonths,
    startDate.day,
  );

  /// Check if cliff has passed
  bool get cliffPassed {
    final now = terminationDate ?? DateTime.now();
    return now.isAfter(cliffDate) || now.isAtSameMomentAs(cliffDate);
  }

  /// Calculate months elapsed since start (capped at termination if applicable)
  int get monthsElapsed {
    final endPoint = terminationDate ?? DateTime.now();
    if (endPoint.isBefore(startDate)) return 0;

    int months =
        (endPoint.year - startDate.year) * 12 +
        (endPoint.month - startDate.month);

    // Adjust for day of month
    if (endPoint.day < startDate.day) months--;

    return months.clamp(0, vestingPeriodMonths);
  }

  /// Calculate vesting percentage (0-100)
  double get vestingPercentage {
    if (leaverStatus == LeaverStatus.badLeaver) return 0;
    if (!cliffPassed) return 0;

    final elapsed = monthsElapsed;
    if (elapsed >= vestingPeriodMonths) return 100;

    // Calculate based on frequency
    int vestedPeriods;
    int periodsPerCycle;

    switch (frequency) {
      case VestingFrequency.monthly:
        periodsPerCycle = 1;
        break;
      case VestingFrequency.quarterly:
        periodsPerCycle = 3;
        break;
      case VestingFrequency.annually:
        periodsPerCycle = 12;
        break;
    }

    // First, cliff vesting (typically 25% at 12 months for 4-year schedule)
    final cliffPercent = (cliffMonths / vestingPeriodMonths) * 100;

    // Then periodic vesting for remaining months
    final monthsAfterCliff = elapsed - cliffMonths;
    if (monthsAfterCliff <= 0) return cliffPercent;

    final remainingMonths = vestingPeriodMonths - cliffMonths;
    final remainingPercent = 100 - cliffPercent;

    // Calculate vested periods after cliff
    vestedPeriods = monthsAfterCliff ~/ periodsPerCycle;
    final totalPeriods = remainingMonths ~/ periodsPerCycle;

    if (totalPeriods == 0) return cliffPercent;

    final additionalPercent = (vestedPeriods / totalPeriods) * remainingPercent;

    return (cliffPercent + additionalPercent).clamp(0, 100);
  }

  /// Get next vesting date
  DateTime? get nextVestingDate {
    if (vestingPercentage >= 100) return null;
    if (leaverStatus != LeaverStatus.active) return null;

    final now = DateTime.now();

    // If before cliff, next vesting is cliff date
    if (!cliffPassed) return cliffDate;

    // Calculate next vesting based on frequency
    int periodsPerCycle;
    switch (frequency) {
      case VestingFrequency.monthly:
        periodsPerCycle = 1;
        break;
      case VestingFrequency.quarterly:
        periodsPerCycle = 3;
        break;
      case VestingFrequency.annually:
        periodsPerCycle = 12;
        break;
    }

    // Find next vesting date after cliff
    var nextDate = cliffDate;
    while (nextDate.isBefore(now) || nextDate.isAtSameMomentAs(now)) {
      nextDate = DateTime(
        nextDate.year,
        nextDate.month + periodsPerCycle,
        nextDate.day,
      );
      if (nextDate.isAfter(endDate)) return null;
    }

    return nextDate;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'shareholdingId': shareholdingId,
    'type': type.index,
    'startDate': startDate.toIso8601String(),
    'vestingPeriodMonths': vestingPeriodMonths,
    'cliffMonths': cliffMonths,
    'frequency': frequency.index,
    'accelerationPercent': accelerationPercent,
    'leaverStatus': leaverStatus.index,
    'terminationDate': terminationDate?.toIso8601String(),
    'notes': notes,
  };

  factory VestingSchedule.fromJson(Map<String, dynamic> json) =>
      VestingSchedule(
        id: json['id'],
        shareholdingId: json['shareholdingId'],
        type: VestingType.values[json['type'] ?? 0],
        startDate: DateTime.parse(json['startDate']),
        vestingPeriodMonths: json['vestingPeriodMonths'] ?? 48,
        cliffMonths: json['cliffMonths'] ?? 12,
        frequency: VestingFrequency.values[json['frequency'] ?? 0],
        accelerationPercent: (json['accelerationPercent'] ?? 0).toDouble(),
        leaverStatus: LeaverStatus.values[json['leaverStatus'] ?? 0],
        terminationDate: json['terminationDate'] != null
            ? DateTime.parse(json['terminationDate'])
            : null,
        notes: json['notes'],
      );

  VestingSchedule copyWith({
    String? shareholdingId,
    VestingType? type,
    DateTime? startDate,
    int? vestingPeriodMonths,
    int? cliffMonths,
    VestingFrequency? frequency,
    double? accelerationPercent,
    LeaverStatus? leaverStatus,
    DateTime? terminationDate,
    String? notes,
  }) {
    return VestingSchedule(
      id: id,
      shareholdingId: shareholdingId ?? this.shareholdingId,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      vestingPeriodMonths: vestingPeriodMonths ?? this.vestingPeriodMonths,
      cliffMonths: cliffMonths ?? this.cliffMonths,
      frequency: frequency ?? this.frequency,
      accelerationPercent: accelerationPercent ?? this.accelerationPercent,
      leaverStatus: leaverStatus ?? this.leaverStatus,
      terminationDate: terminationDate ?? this.terminationDate,
      notes: notes ?? this.notes,
    );
  }
}
