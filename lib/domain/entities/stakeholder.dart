import 'package:freezed_annotation/freezed_annotation.dart';

part 'stakeholder.freezed.dart';
part 'stakeholder.g.dart';

/// Types of stakeholders who can hold securities.
enum StakeholderType {
  founder,
  angel,
  vcFund,
  employee,
  advisor,
  institution,
  other;

  String get displayName => switch (this) {
    founder => 'Founder',
    angel => 'Angel Investor',
    vcFund => 'VC Fund',
    employee => 'Employee',
    advisor => 'Advisor',
    institution => 'Institution',
    other => 'Other',
  };
}

/// A party who can hold securities in the company.
///
/// This includes founders, investors, employees, advisors, and institutions.
/// The term "stakeholder" is used instead of "investor" because many
/// shareholders (founders, employees) are not technically investors.
@freezed
class Stakeholder with _$Stakeholder {
  const Stakeholder._();

  const factory Stakeholder({
    required String id,
    required String companyId,
    required String name,
    required StakeholderType type,
    String? email,
    String? phone,
    String? company,
    @Default(false) bool hasProRataRights,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Stakeholder;

  factory Stakeholder.fromJson(Map<String, dynamic> json) =>
      _$StakeholderFromJson(json);

  /// First initial for avatar display.
  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  /// Full initials (up to 2 characters) for avatar display.
  String get initials {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
