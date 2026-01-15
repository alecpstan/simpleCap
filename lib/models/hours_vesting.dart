import 'dart:math' as math;
import 'package:uuid/uuid.dart';

// Helper function for power calculation
double _dartPow(double base, double exponent) =>
    math.pow(base, exponent).toDouble();

/// Curve type for hours-based vesting
enum HoursVestingCurve {
  /// Linear: equity vests proportionally to hours worked
  linear,

  /// Cliff: no vesting until cliff hours reached, then linear
  cliff,

  /// Progressive: increasing marginal return (rewards longevity)
  progressive,

  /// Front-loaded: higher vesting rate early, decreasing over time
  frontLoaded,
}

/// A bonus milestone within hours vesting (e.g., bonus at 500 hours)
class HoursBonusMilestone {
  final int hoursRequired;
  final double bonusPercent;
  final String? description;
  bool isAchieved;
  DateTime? achievedDate;

  HoursBonusMilestone({
    required this.hoursRequired,
    required this.bonusPercent,
    this.description,
    this.isAchieved = false,
    this.achievedDate,
  });

  Map<String, dynamic> toJson() => {
    'hoursRequired': hoursRequired,
    'bonusPercent': bonusPercent,
    'description': description,
    'isAchieved': isAchieved,
    'achievedDate': achievedDate?.toIso8601String(),
  };

  factory HoursBonusMilestone.fromJson(Map<String, dynamic> json) =>
      HoursBonusMilestone(
        hoursRequired: json['hoursRequired'],
        bonusPercent: (json['bonusPercent'] ?? 0).toDouble(),
        description: json['description'],
        isAchieved: json['isAchieved'] ?? false,
        achievedDate: json['achievedDate'] != null
            ? DateTime.parse(json['achievedDate'])
            : null,
      );
}

/// Represents an hours-based vesting schedule
/// Perfect for part-time founders or pre-formation equity splits
class HoursVestingSchedule {
  final String id;

  /// The transaction this vesting applies to
  final String transactionId;

  /// The investor this applies to
  final String investorId;

  /// Total equity percentage available through this schedule
  final double totalEquityPercent;

  /// Total hours commitment required for full vesting
  final int totalHoursCommitment;

  /// Hours worked so far
  double hoursLogged;

  /// Type of vesting curve
  final HoursVestingCurve curveType;

  /// For cliff curve: hours before any vesting begins
  final int? cliffHours;

  /// For progressive curve: acceleration factor (> 1 means faster later)
  final double? accelerationFactor;

  /// Bonus milestones (e.g., bonus equity at certain hour marks)
  final List<HoursBonusMilestone> bonusMilestones;

  /// Start date for tracking
  final DateTime startDate;

  /// End date (optional deadline)
  final DateTime? endDate;

  /// Hourly log entries for audit trail
  final List<HoursLogEntry> logEntries;

  /// Notes
  final String? notes;

  HoursVestingSchedule({
    String? id,
    required this.transactionId,
    required this.investorId,
    required this.totalEquityPercent,
    required this.totalHoursCommitment,
    this.hoursLogged = 0,
    this.curveType = HoursVestingCurve.linear,
    this.cliffHours,
    this.accelerationFactor,
    List<HoursBonusMilestone>? bonusMilestones,
    required this.startDate,
    this.endDate,
    List<HoursLogEntry>? logEntries,
    this.notes,
  }) : id = id ?? const Uuid().v4(),
       bonusMilestones = bonusMilestones ?? [],
       logEntries = logEntries ?? [];

  /// Calculate vested percentage based on curve type
  double get vestedPercent {
    if (totalHoursCommitment <= 0) return 0;

    final baseRatio = (hoursLogged / totalHoursCommitment).clamp(0.0, 1.0);

    switch (curveType) {
      case HoursVestingCurve.linear:
        return baseRatio * totalEquityPercent;

      case HoursVestingCurve.cliff:
        if (cliffHours != null && hoursLogged < cliffHours!) {
          return 0;
        }
        return baseRatio * totalEquityPercent;

      case HoursVestingCurve.progressive:
        // Quadratic curve - slower early, faster later
        final factor = accelerationFactor ?? 2.0;
        final adjustedRatio = _pow(baseRatio, 1 / factor);
        return adjustedRatio * totalEquityPercent;

      case HoursVestingCurve.frontLoaded:
        // Inverse - faster early, slower later
        final factor = accelerationFactor ?? 2.0;
        final adjustedRatio = _pow(baseRatio, factor);
        return adjustedRatio * totalEquityPercent;
    }
  }

  // Helper for power calculation using dart:math
  double _pow(double base, double exponent) {
    if (base <= 0) return 0;
    // Use dart:math pow for proper floating-point exponentiation
    return _dartPow(base, exponent);
  }

  /// Total bonus equity earned from milestones
  double get bonusEquityEarned {
    return bonusMilestones
        .where((m) => m.isAchieved)
        .fold(0.0, (sum, m) => sum + m.bonusPercent);
  }

  /// Total vested equity including bonuses
  double get totalVestedPercent => vestedPercent + bonusEquityEarned;

  /// Remaining hours to full vesting
  int get remainingHours => (totalHoursCommitment - hoursLogged)
      .clamp(0, totalHoursCommitment)
      .toInt();

  /// Progress as a ratio (0-1)
  double get progress => totalHoursCommitment > 0
      ? (hoursLogged / totalHoursCommitment).clamp(0.0, 1.0)
      : 0;

  /// Whether fully vested
  bool get isFullyVested => hoursLogged >= totalHoursCommitment;

  /// Log hours worked
  void logHours(double hours, {String? description, DateTime? date}) {
    hoursLogged += hours;
    logEntries.add(
      HoursLogEntry(
        hours: hours,
        date: date ?? DateTime.now(),
        description: description,
        cumulativeHours: hoursLogged,
      ),
    );

    // Check bonus milestones
    for (final milestone in bonusMilestones) {
      if (!milestone.isAchieved && hoursLogged >= milestone.hoursRequired) {
        milestone.isAchieved = true;
        milestone.achievedDate = date ?? DateTime.now();
      }
    }
  }

  /// Update a log entry and recalculate totals
  void updateLogEntry(
    String entryId, {
    double? hours,
    DateTime? date,
    String? description,
  }) {
    final entryIndex = logEntries.indexWhere((e) => e.id == entryId);
    if (entryIndex == -1) return;

    final oldEntry = logEntries[entryIndex];
    final hoursDiff = (hours ?? oldEntry.hours) - oldEntry.hours;

    // Update hoursLogged with the difference
    hoursLogged += hoursDiff;

    // Create updated entry (entries are immutable, so we replace)
    logEntries[entryIndex] = HoursLogEntry(
      id: entryId,
      hours: hours ?? oldEntry.hours,
      date: date ?? oldEntry.date,
      description: description ?? oldEntry.description,
      cumulativeHours: oldEntry.cumulativeHours + hoursDiff,
    );

    // Recalculate cumulative hours for all entries after this one
    _recalculateCumulativeHours();
    _recheckBonusMilestones();
  }

  /// Delete a log entry and recalculate totals
  void deleteLogEntry(String entryId) {
    final entryIndex = logEntries.indexWhere((e) => e.id == entryId);
    if (entryIndex == -1) return;

    final entry = logEntries[entryIndex];
    hoursLogged -= entry.hours;
    if (hoursLogged < 0) hoursLogged = 0;

    logEntries.removeAt(entryIndex);

    // Recalculate cumulative hours for remaining entries
    _recalculateCumulativeHours();
    _recheckBonusMilestones();
  }

  /// Recalculate cumulative hours for all entries (after edit/delete)
  void _recalculateCumulativeHours() {
    // Sort entries by date
    logEntries.sort((a, b) => a.date.compareTo(b.date));

    double cumulative = 0;
    for (int i = 0; i < logEntries.length; i++) {
      cumulative += logEntries[i].hours;
      // Entries are immutable, so we need to replace
      logEntries[i] = HoursLogEntry(
        id: logEntries[i].id,
        hours: logEntries[i].hours,
        date: logEntries[i].date,
        description: logEntries[i].description,
        cumulativeHours: cumulative,
      );
    }
  }

  /// Recheck bonus milestones after hours change
  void _recheckBonusMilestones() {
    for (final milestone in bonusMilestones) {
      if (hoursLogged >= milestone.hoursRequired) {
        if (!milestone.isAchieved) {
          milestone.isAchieved = true;
          milestone.achievedDate = DateTime.now();
        }
      } else {
        // Unachieve if hours dropped below threshold
        milestone.isAchieved = false;
        milestone.achievedDate = null;
      }
    }
  }

  String get curveTypeDisplayName {
    switch (curveType) {
      case HoursVestingCurve.linear:
        return 'Linear';
      case HoursVestingCurve.cliff:
        return 'Cliff';
      case HoursVestingCurve.progressive:
        return 'Progressive';
      case HoursVestingCurve.frontLoaded:
        return 'Front-Loaded';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'transactionId': transactionId,
    'investorId': investorId,
    'totalEquityPercent': totalEquityPercent,
    'totalHoursCommitment': totalHoursCommitment,
    'hoursLogged': hoursLogged,
    'curveType': curveType.index,
    'cliffHours': cliffHours,
    'accelerationFactor': accelerationFactor,
    'bonusMilestones': bonusMilestones.map((m) => m.toJson()).toList(),
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'logEntries': logEntries.map((e) => e.toJson()).toList(),
    'notes': notes,
  };

  factory HoursVestingSchedule.fromJson(Map<String, dynamic> json) =>
      HoursVestingSchedule(
        id: json['id'],
        transactionId: json['transactionId'] ?? json['shareholdingId'],
        investorId: json['investorId'],
        totalEquityPercent: (json['totalEquityPercent'] ?? 0).toDouble(),
        totalHoursCommitment: json['totalHoursCommitment'] ?? 0,
        hoursLogged: (json['hoursLogged'] ?? 0).toDouble(),
        curveType: HoursVestingCurve.values[json['curveType'] ?? 0],
        cliffHours: json['cliffHours'],
        accelerationFactor: json['accelerationFactor']?.toDouble(),
        bonusMilestones:
            (json['bonusMilestones'] as List?)
                ?.map((m) => HoursBonusMilestone.fromJson(m))
                .toList() ??
            [],
        startDate: DateTime.parse(json['startDate']),
        endDate: json['endDate'] != null
            ? DateTime.parse(json['endDate'])
            : null,
        logEntries:
            (json['logEntries'] as List?)
                ?.map((e) => HoursLogEntry.fromJson(e))
                .toList() ??
            [],
        notes: json['notes'],
      );

  HoursVestingSchedule copyWith({
    String? transactionId,
    String? investorId,
    double? totalEquityPercent,
    int? totalHoursCommitment,
    double? hoursLogged,
    HoursVestingCurve? curveType,
    int? cliffHours,
    double? accelerationFactor,
    List<HoursBonusMilestone>? bonusMilestones,
    DateTime? startDate,
    DateTime? endDate,
    List<HoursLogEntry>? logEntries,
    String? notes,
  }) {
    return HoursVestingSchedule(
      id: id,
      transactionId: transactionId ?? this.transactionId,
      investorId: investorId ?? this.investorId,
      totalEquityPercent: totalEquityPercent ?? this.totalEquityPercent,
      totalHoursCommitment: totalHoursCommitment ?? this.totalHoursCommitment,
      hoursLogged: hoursLogged ?? this.hoursLogged,
      curveType: curveType ?? this.curveType,
      cliffHours: cliffHours ?? this.cliffHours,
      accelerationFactor: accelerationFactor ?? this.accelerationFactor,
      bonusMilestones: bonusMilestones ?? this.bonusMilestones,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      logEntries: logEntries ?? this.logEntries,
      notes: notes ?? this.notes,
    );
  }
}

/// Individual hours log entry for audit trail
class HoursLogEntry {
  final String id;
  final double hours;
  final DateTime date;
  final String? description;
  final double cumulativeHours;

  HoursLogEntry({
    String? id,
    required this.hours,
    required this.date,
    this.description,
    required this.cumulativeHours,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'hours': hours,
    'date': date.toIso8601String(),
    'description': description,
    'cumulativeHours': cumulativeHours,
  };

  factory HoursLogEntry.fromJson(Map<String, dynamic> json) => HoursLogEntry(
    id: json['id'],
    hours: (json['hours'] ?? 0).toDouble(),
    date: DateTime.parse(json['date']),
    description: json['description'],
    cumulativeHours: (json['cumulativeHours'] ?? 0).toDouble(),
  );
}
