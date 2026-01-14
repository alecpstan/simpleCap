import 'package:flutter/foundation.dart';
import '../models/vesting_schedule.dart';
import '../models/milestone.dart';
import '../models/hours_vesting.dart';

/// Provider for managing vesting schedules, milestones, and hours-based vesting
/// Works in conjunction with CapTableProvider for transaction data
class VestingProvider extends ChangeNotifier {
  List<VestingSchedule> _vestingSchedules = [];
  List<Milestone> _milestones = [];
  List<HoursVestingSchedule> _hoursVestingSchedules = [];

  VestingProvider();
  List<Milestone> get milestones => List.unmodifiable(_milestones);
  List<HoursVestingSchedule> get hoursVestingSchedules =>
      List.unmodifiable(_hoursVestingSchedules);

  List<Milestone> get pendingMilestones {
    return _milestones.where((m) => !m.isCompleted && !m.isLapsed).toList();
  }

  List<VestingSchedule> get activeVestingSchedules {
    return _vestingSchedules
        .where(
          (v) =>
              v.leaverStatus == LeaverStatus.active &&
              v.vestingPercentage < 100,
        )
        .toList();
  }

  // Initialize from saved data
  void loadFromData({
    required List<VestingSchedule> vestingSchedules,
    required List<Milestone> milestones,
    required List<HoursVestingSchedule> hoursVestingSchedules,
  }) {
    _vestingSchedules = vestingSchedules;
    _milestones = milestones;
    _hoursVestingSchedules = hoursVestingSchedules;
    notifyListeners();
  }

  // Export data for saving
  Map<String, dynamic> exportData() {
    return {
      'vestingSchedules': _vestingSchedules.map((e) => e.toJson()).toList(),
      'milestones': _milestones.map((e) => e.toJson()).toList(),
      'hoursVestingSchedules': _hoursVestingSchedules
          .map((e) => e.toJson())
          .toList(),
    };
  }

  // === Vesting Schedule CRUD ===

  Future<void> addVestingSchedule(
    VestingSchedule schedule, {
    required Future<void> Function() onSave,
  }) async {
    _vestingSchedules.add(schedule);
    await onSave();
    notifyListeners();
  }

  Future<void> updateVestingSchedule(
    VestingSchedule schedule, {
    required Future<void> Function() onSave,
  }) async {
    final index = _vestingSchedules.indexWhere((v) => v.id == schedule.id);
    if (index != -1) {
      _vestingSchedules[index] = schedule;
      await onSave();
      notifyListeners();
    }
  }

  Future<void> deleteVestingSchedule(
    String id, {
    required Future<void> Function() onSave,
  }) async {
    _vestingSchedules.removeWhere((v) => v.id == id);
    await onSave();
    notifyListeners();
  }

  VestingSchedule? getVestingScheduleById(String id) {
    try {
      return _vestingSchedules.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  VestingSchedule? getVestingByTransaction(String transactionId) {
    try {
      return _vestingSchedules.firstWhere(
        (v) => v.transactionId == transactionId,
      );
    } catch (_) {
      return null;
    }
  }

  List<VestingSchedule> getVestingByTransactionIds(Set<String> transactionIds) {
    return _vestingSchedules
        .where((v) => transactionIds.contains(v.transactionId))
        .toList();
  }

  /// Remove vesting schedules for specific transaction IDs
  void removeVestingForTransactions(Set<String> transactionIds) {
    _vestingSchedules.removeWhere(
      (v) => transactionIds.contains(v.transactionId),
    );
  }

  // === Milestone CRUD ===

  Future<void> addMilestone(
    Milestone milestone, {
    required Future<void> Function() onSave,
  }) async {
    _milestones.add(milestone);
    await onSave();
    notifyListeners();
  }

  Future<void> updateMilestone(
    Milestone milestone, {
    required Future<void> Function() onSave,
  }) async {
    final index = _milestones.indexWhere((m) => m.id == milestone.id);
    if (index != -1) {
      _milestones[index] = milestone;
      await onSave();
      notifyListeners();
    }
  }

  Future<void> deleteMilestone(
    String id, {
    required Future<void> Function() onSave,
  }) async {
    _milestones.removeWhere((m) => m.id == id);
    await onSave();
    notifyListeners();
  }

  Milestone? getMilestoneById(String id) {
    try {
      return _milestones.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Milestone> getMilestonesByInvestor(String investorId) {
    return _milestones.where((m) => m.investorId == investorId).toList();
  }

  /// Update progress for a graded milestone
  Future<void> updateMilestoneProgress(
    String milestoneId,
    double newValue, {
    required Future<void> Function() onSave,
  }) async {
    final index = _milestones.indexWhere((m) => m.id == milestoneId);
    if (index == -1) return;

    final milestone = _milestones[index];
    milestone.currentValue = newValue;
    _milestones[index] = milestone;

    await onSave();
    notifyListeners();
  }

  /// Complete a milestone (call before creating award transaction)
  void completeMilestone(String milestoneId) {
    final index = _milestones.indexWhere((m) => m.id == milestoneId);
    if (index == -1) return;

    final milestone = _milestones[index];
    milestone.complete();
    _milestones[index] = milestone;
  }

  // === Hours Vesting Schedule CRUD ===

  Future<void> addHoursVestingSchedule(
    HoursVestingSchedule schedule, {
    required Future<void> Function() onSave,
  }) async {
    _hoursVestingSchedules.add(schedule);
    await onSave();
    notifyListeners();
  }

  Future<void> updateHoursVestingSchedule(
    HoursVestingSchedule schedule, {
    required Future<void> Function() onSave,
  }) async {
    final index = _hoursVestingSchedules.indexWhere((h) => h.id == schedule.id);
    if (index != -1) {
      _hoursVestingSchedules[index] = schedule;
      await onSave();
      notifyListeners();
    }
  }

  Future<void> deleteHoursVestingSchedule(
    String id, {
    required Future<void> Function() onSave,
  }) async {
    _hoursVestingSchedules.removeWhere((h) => h.id == id);
    await onSave();
    notifyListeners();
  }

  HoursVestingSchedule? getHoursVestingById(String id) {
    try {
      return _hoursVestingSchedules.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  List<HoursVestingSchedule> getHoursVestingByInvestor(String investorId) {
    return _hoursVestingSchedules
        .where((h) => h.investorId == investorId)
        .toList();
  }

  /// Log hours for an hours vesting schedule
  Future<void> logHoursForSchedule(
    String scheduleId,
    double hours,
    DateTime date,
    String? description, {
    required Future<void> Function() onSave,
  }) async {
    final index = _hoursVestingSchedules.indexWhere((h) => h.id == scheduleId);
    if (index == -1) return;

    final schedule = _hoursVestingSchedules[index];

    // logHours mutates the schedule in place
    schedule.logHours(hours, description: description, date: date);

    // Trigger save with the mutated schedule
    _hoursVestingSchedules[index] = schedule;

    await onSave();
    notifyListeners();
  }

  // === Vesting Calculations ===

  /// Calculate vested shares for a transaction
  int calculateVestedShares(String transactionId, int totalShares) {
    final vesting = getVestingByTransaction(transactionId);
    if (vesting == null) {
      return totalShares; // No vesting = fully vested
    }
    return (totalShares * vesting.vestingPercentage / 100).round();
  }

  /// Calculate unvested shares for a transaction
  int calculateUnvestedShares(String transactionId, int totalShares) {
    return totalShares - calculateVestedShares(transactionId, totalShares);
  }
}
