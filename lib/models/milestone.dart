import 'package:uuid/uuid.dart';

/// How the milestone triggers vesting
enum MilestoneTriggerType {
  /// All or nothing - milestone is either complete or not
  binary,

  /// Partial completion awards partial equity (e.g., % of target revenue)
  graded,
}

/// How valuation is anchored for the milestone equity
enum ValuationAnchor {
  /// Use the current round/share price at time of completion
  current,

  /// Fixed valuation set when milestone was created
  fixed,

  /// Valuation band (min-max range)
  band,
}

/// Represents a milestone that triggers equity vesting
class Milestone {
  final String id;

  /// Name of the milestone (e.g., "MVP Complete", "First Customer")
  final String name;

  /// Detailed description of what constitutes completion
  final String? description;

  /// Percentage of equity that vests on completion
  final double equityPercent;

  /// How completion is determined
  final MilestoneTriggerType triggerType;

  /// For graded milestones: the target value (e.g., $250,000 ARR)
  final double? targetValue;

  /// For graded milestones: current progress value
  double currentValue;

  /// Deadline for completing the milestone (optional)
  final DateTime? deadline;

  /// Whether the milestone has been completed
  bool isCompleted;

  /// Date of completion
  DateTime? completedDate;

  /// If deadline is missed, does the equity opportunity lapse?
  final bool lapseOnMiss;

  /// Has this milestone lapsed (deadline missed)?
  bool isLapsed;

  /// How valuation is anchored
  final ValuationAnchor valuationAnchor;

  /// For fixed valuation anchor: the locked valuation
  final double? fixedValuation;

  /// For band anchor: minimum valuation
  final double? minValuation;

  /// For band anchor: maximum valuation
  final double? maxValuation;

  /// The investor/shareholder this milestone applies to
  final String? investorId;

  /// The shareholding/transaction this milestone is linked to
  final String? shareholdingId;

  /// Order for display/priority
  final int order;

  /// Notes about the milestone
  final String? notes;

  Milestone({
    String? id,
    required this.name,
    this.description,
    required this.equityPercent,
    this.triggerType = MilestoneTriggerType.binary,
    this.targetValue,
    this.currentValue = 0,
    this.deadline,
    this.isCompleted = false,
    this.completedDate,
    this.lapseOnMiss = false,
    this.isLapsed = false,
    this.valuationAnchor = ValuationAnchor.current,
    this.fixedValuation,
    this.minValuation,
    this.maxValuation,
    this.investorId,
    this.shareholdingId,
    this.order = 0,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  /// Progress as a percentage (0-1) for graded milestones
  double get progress {
    if (isCompleted) return 1.0;
    if (isLapsed) return 0.0;
    if (triggerType == MilestoneTriggerType.binary) {
      return isCompleted ? 1.0 : 0.0;
    }
    if (targetValue == null || targetValue! <= 0) return 0.0;
    return (currentValue / targetValue!).clamp(0.0, 1.0);
  }

  /// Equity earned so far (for graded, this can be partial)
  double get earnedEquityPercent {
    if (triggerType == MilestoneTriggerType.binary) {
      return isCompleted ? equityPercent : 0.0;
    }
    return equityPercent * progress;
  }

  /// Whether the deadline has passed
  bool get isPastDeadline {
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline!);
  }

  /// Check and update lapse status
  void checkLapse() {
    if (!isCompleted && lapseOnMiss && isPastDeadline) {
      isLapsed = true;
    }
  }

  /// Mark the milestone as complete
  void complete({DateTime? date}) {
    isCompleted = true;
    completedDate = date ?? DateTime.now();
    if (triggerType == MilestoneTriggerType.graded && targetValue != null) {
      currentValue = targetValue!;
    }
  }

  String get statusDisplayName {
    if (isCompleted) return 'Completed';
    if (isLapsed) return 'Lapsed';
    if (isPastDeadline) return 'Overdue';
    return 'Pending';
  }

  String get triggerTypeDisplayName {
    switch (triggerType) {
      case MilestoneTriggerType.binary:
        return 'Binary';
      case MilestoneTriggerType.graded:
        return 'Graded';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'equityPercent': equityPercent,
    'triggerType': triggerType.index,
    'targetValue': targetValue,
    'currentValue': currentValue,
    'deadline': deadline?.toIso8601String(),
    'isCompleted': isCompleted,
    'completedDate': completedDate?.toIso8601String(),
    'lapseOnMiss': lapseOnMiss,
    'isLapsed': isLapsed,
    'valuationAnchor': valuationAnchor.index,
    'fixedValuation': fixedValuation,
    'minValuation': minValuation,
    'maxValuation': maxValuation,
    'investorId': investorId,
    'shareholdingId': shareholdingId,
    'order': order,
    'notes': notes,
  };

  factory Milestone.fromJson(Map<String, dynamic> json) => Milestone(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    equityPercent: (json['equityPercent'] ?? 0).toDouble(),
    triggerType: MilestoneTriggerType.values[json['triggerType'] ?? 0],
    targetValue: json['targetValue']?.toDouble(),
    currentValue: (json['currentValue'] ?? 0).toDouble(),
    deadline: json['deadline'] != null
        ? DateTime.parse(json['deadline'])
        : null,
    isCompleted: json['isCompleted'] ?? false,
    completedDate: json['completedDate'] != null
        ? DateTime.parse(json['completedDate'])
        : null,
    lapseOnMiss: json['lapseOnMiss'] ?? false,
    isLapsed: json['isLapsed'] ?? false,
    valuationAnchor: ValuationAnchor.values[json['valuationAnchor'] ?? 0],
    fixedValuation: json['fixedValuation']?.toDouble(),
    minValuation: json['minValuation']?.toDouble(),
    maxValuation: json['maxValuation']?.toDouble(),
    investorId: json['investorId'],
    shareholdingId: json['shareholdingId'],
    order: json['order'] ?? 0,
    notes: json['notes'],
  );

  Milestone copyWith({
    String? name,
    String? description,
    double? equityPercent,
    MilestoneTriggerType? triggerType,
    double? targetValue,
    double? currentValue,
    DateTime? deadline,
    bool? isCompleted,
    DateTime? completedDate,
    bool? lapseOnMiss,
    bool? isLapsed,
    ValuationAnchor? valuationAnchor,
    double? fixedValuation,
    double? minValuation,
    double? maxValuation,
    String? investorId,
    String? shareholdingId,
    int? order,
    String? notes,
  }) {
    return Milestone(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      equityPercent: equityPercent ?? this.equityPercent,
      triggerType: triggerType ?? this.triggerType,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate ?? this.completedDate,
      lapseOnMiss: lapseOnMiss ?? this.lapseOnMiss,
      isLapsed: isLapsed ?? this.isLapsed,
      valuationAnchor: valuationAnchor ?? this.valuationAnchor,
      fixedValuation: fixedValuation ?? this.fixedValuation,
      minValuation: minValuation ?? this.minValuation,
      maxValuation: maxValuation ?? this.maxValuation,
      investorId: investorId ?? this.investorId,
      shareholdingId: shareholdingId ?? this.shareholdingId,
      order: order ?? this.order,
      notes: notes ?? this.notes,
    );
  }
}
