import 'package:uuid/uuid.dart';

/// Types of vesting schedules
enum VestingType {
  /// Standard time-based vesting
  timeBased,

  /// Milestone-based vesting
  milestoneBased,

  /// Reverse vesting (founder buyback)
  reverse,

  /// Hybrid: combination of time + milestones + hours
  hybrid,
}

enum VestingFrequency { monthly, quarterly, annually }

enum LeaverStatus { active, goodLeaver, badLeaver }

/// Lapse rules for unvested shares (Task 2.6)
enum LapseRule {
  /// Unvested shares lapse immediately on termination
  immediate,

  /// Shares lapse after a grace period
  gracePeriod,

  /// Pro-rata accelerated vesting on good leaver exit
  proRataAcceleration,

  /// Discretionary - board decides
  boardDiscretion,

  /// Never lapse (e.g., for founders)
  neverLapse,
}

class VestingSchedule {
  final String id;
  String transactionId; // Links to a specific transaction
  VestingType type;
  DateTime startDate;
  int vestingPeriodMonths; // Total vesting period (e.g., 48 for 4 years)
  int cliffMonths; // Cliff period (e.g., 12 for 1 year)
  VestingFrequency frequency;
  double accelerationPercent; // % to accelerate on liquidity event (0-100)
  LeaverStatus leaverStatus;
  DateTime? terminationDate; // If employee left
  String? notes;

  // === Hybrid vesting fields (Task 1.4) ===

  /// Weight for time-based component in hybrid (0-100, default 100)
  double timeWeight;

  /// Weight for milestone-based component in hybrid (0-100)
  double milestonesWeight;

  /// Weight for hours-based component in hybrid (0-100)
  double hoursWeight;

  /// Linked milestone IDs for milestone-based or hybrid vesting
  List<String> linkedMilestoneIds;

  /// Linked hours vesting schedule ID for reverse/hybrid vesting (Task 1.5)
  String? hoursVestingScheduleId;

  // === Enhanced lapsing rules (Task 2.6) ===

  /// What happens to unvested shares on termination
  LapseRule lapseRule;

  /// Grace period in days (for LapseRule.gracePeriod)
  int gracePeriodDays;

  /// Accelerated vesting percentage on good leaver exit
  double goodLeaverAccelerationPercent;

  /// Date when unvested shares will lapse
  DateTime? lapseDate;

  VestingSchedule({
    String? id,
    required this.transactionId,
    this.type = VestingType.timeBased,
    required this.startDate,
    this.vestingPeriodMonths = 48,
    this.cliffMonths = 12,
    this.frequency = VestingFrequency.monthly,
    this.accelerationPercent = 0,
    this.leaverStatus = LeaverStatus.active,
    this.terminationDate,
    this.notes,
    // Hybrid vesting fields
    this.timeWeight = 100,
    this.milestonesWeight = 0,
    this.hoursWeight = 0,
    List<String>? linkedMilestoneIds,
    this.hoursVestingScheduleId,
    // Lapsing fields
    this.lapseRule = LapseRule.immediate,
    this.gracePeriodDays = 0,
    this.goodLeaverAccelerationPercent = 0,
    this.lapseDate,
  }) : id = id ?? const Uuid().v4(),
       linkedMilestoneIds = linkedMilestoneIds ?? [];

  /// Whether this is a hybrid schedule (multiple components)
  bool get isHybrid =>
      type == VestingType.hybrid ||
      (timeWeight < 100 && (milestonesWeight > 0 || hoursWeight > 0));

  /// Total weight across all components (should equal 100)
  double get totalWeight => timeWeight + milestonesWeight + hoursWeight;

  /// Validates that weights sum to 100
  bool get hasValidWeights => (totalWeight - 100).abs() < 0.01;

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

  /// Check if unvested shares should lapse (Task 2.6)
  LapseCheckResult checkLapse() {
    // No termination, no lapse
    if (terminationDate == null || leaverStatus == LeaverStatus.active) {
      return LapseCheckResult(shouldLapse: false, reason: 'Active employee');
    }

    // Never lapse rule
    if (lapseRule == LapseRule.neverLapse) {
      return LapseCheckResult(shouldLapse: false, reason: 'Never lapse rule');
    }

    // Board discretion - return pending
    if (lapseRule == LapseRule.boardDiscretion) {
      return LapseCheckResult(
        shouldLapse: false,
        isPending: true,
        reason: 'Board discretion required',
      );
    }

    // Good leaver acceleration
    if (leaverStatus == LeaverStatus.goodLeaver &&
        lapseRule == LapseRule.proRataAcceleration) {
      return LapseCheckResult(
        shouldLapse: false,
        acceleratedPercent: goodLeaverAccelerationPercent,
        reason: 'Good leaver acceleration applied',
      );
    }

    // Bad leaver - immediate lapse
    if (leaverStatus == LeaverStatus.badLeaver) {
      return LapseCheckResult(
        shouldLapse: true,
        lapseDate: terminationDate!,
        reason: 'Bad leaver - immediate lapse',
      );
    }

    // Grace period check
    if (lapseRule == LapseRule.gracePeriod) {
      final effectiveLapseDate = terminationDate!.add(
        Duration(days: gracePeriodDays),
      );
      final shouldLapse = DateTime.now().isAfter(effectiveLapseDate);
      return LapseCheckResult(
        shouldLapse: shouldLapse,
        lapseDate: effectiveLapseDate,
        reason: shouldLapse
            ? 'Grace period expired'
            : 'In grace period until ${effectiveLapseDate.toString().split(' ')[0]}',
      );
    }

    // Default: immediate lapse
    return LapseCheckResult(
      shouldLapse: true,
      lapseDate: terminationDate!,
      reason: 'Immediate lapse on termination',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'transactionId': transactionId,
    'type': type.index,
    'startDate': startDate.toIso8601String(),
    'vestingPeriodMonths': vestingPeriodMonths,
    'cliffMonths': cliffMonths,
    'frequency': frequency.index,
    'accelerationPercent': accelerationPercent,
    'leaverStatus': leaverStatus.index,
    'terminationDate': terminationDate?.toIso8601String(),
    'notes': notes,
    // Hybrid vesting fields
    'timeWeight': timeWeight,
    'milestonesWeight': milestonesWeight,
    'hoursWeight': hoursWeight,
    'linkedMilestoneIds': linkedMilestoneIds,
    'hoursVestingScheduleId': hoursVestingScheduleId,
    // Lapsing fields
    'lapseRule': lapseRule.index,
    'gracePeriodDays': gracePeriodDays,
    'goodLeaverAccelerationPercent': goodLeaverAccelerationPercent,
    'lapseDate': lapseDate?.toIso8601String(),
  };

  factory VestingSchedule.fromJson(Map<String, dynamic> json) =>
      VestingSchedule(
        id: json['id'],
        transactionId: json['transactionId'] ?? json['shareholdingId'],
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
        // Hybrid vesting fields
        timeWeight: (json['timeWeight'] ?? 100).toDouble(),
        milestonesWeight: (json['milestonesWeight'] ?? 0).toDouble(),
        hoursWeight: (json['hoursWeight'] ?? 0).toDouble(),
        linkedMilestoneIds: json['linkedMilestoneIds'] != null
            ? List<String>.from(json['linkedMilestoneIds'])
            : null,
        hoursVestingScheduleId: json['hoursVestingScheduleId'],
        // Lapsing fields
        lapseRule: LapseRule.values[json['lapseRule'] ?? 0],
        gracePeriodDays: json['gracePeriodDays'] ?? 0,
        goodLeaverAccelerationPercent:
            (json['goodLeaverAccelerationPercent'] ?? 0).toDouble(),
        lapseDate: json['lapseDate'] != null
            ? DateTime.parse(json['lapseDate'])
            : null,
      );

  VestingSchedule copyWith({
    String? transactionId,
    VestingType? type,
    DateTime? startDate,
    int? vestingPeriodMonths,
    int? cliffMonths,
    VestingFrequency? frequency,
    double? accelerationPercent,
    LeaverStatus? leaverStatus,
    DateTime? terminationDate,
    bool clearTerminationDate = false,
    String? notes,
    double? timeWeight,
    double? milestonesWeight,
    double? hoursWeight,
    List<String>? linkedMilestoneIds,
    String? hoursVestingScheduleId,
    LapseRule? lapseRule,
    int? gracePeriodDays,
    double? goodLeaverAccelerationPercent,
    DateTime? lapseDate,
  }) {
    return VestingSchedule(
      id: id,
      transactionId: transactionId ?? this.transactionId,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      vestingPeriodMonths: vestingPeriodMonths ?? this.vestingPeriodMonths,
      cliffMonths: cliffMonths ?? this.cliffMonths,
      frequency: frequency ?? this.frequency,
      accelerationPercent: accelerationPercent ?? this.accelerationPercent,
      leaverStatus: leaverStatus ?? this.leaverStatus,
      terminationDate: clearTerminationDate
          ? null
          : (terminationDate ?? this.terminationDate),
      notes: notes ?? this.notes,
      timeWeight: timeWeight ?? this.timeWeight,
      milestonesWeight: milestonesWeight ?? this.milestonesWeight,
      hoursWeight: hoursWeight ?? this.hoursWeight,
      linkedMilestoneIds: linkedMilestoneIds ?? this.linkedMilestoneIds,
      hoursVestingScheduleId:
          hoursVestingScheduleId ?? this.hoursVestingScheduleId,
      lapseRule: lapseRule ?? this.lapseRule,
      gracePeriodDays: gracePeriodDays ?? this.gracePeriodDays,
      goodLeaverAccelerationPercent:
          goodLeaverAccelerationPercent ?? this.goodLeaverAccelerationPercent,
      lapseDate: lapseDate ?? this.lapseDate,
    );
  }
}

/// Result of checking if shares should lapse
class LapseCheckResult {
  final bool shouldLapse;
  final bool isPending;
  final DateTime? lapseDate;
  final double? acceleratedPercent;
  final String reason;

  const LapseCheckResult({
    required this.shouldLapse,
    this.isPending = false,
    this.lapseDate,
    this.acceleratedPercent,
    required this.reason,
  });
}
