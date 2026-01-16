import 'package:freezed_annotation/freezed_annotation.dart';

part 'share_class.freezed.dart';
part 'share_class.g.dart';

/// Types of share classes.
enum ShareClassType {
  ordinary,
  preferenceA,
  preferenceB,
  preferenceC,
  esop,
  options,
  performanceRights,
  custom;

  String get displayName => switch (this) {
    ordinary => 'Ordinary',
    preferenceA => 'Preference A',
    preferenceB => 'Preference B',
    preferenceC => 'Preference C',
    esop => 'ESOP',
    options => 'Options',
    performanceRights => 'Performance Rights',
    custom => 'Custom',
  };

  /// Whether this class represents potential (not yet issued) shares.
  bool get isDerivative => this == options || this == performanceRights;

  /// Whether this is an ESOP-related class.
  bool get isEsop =>
      this == esop || this == options || this == performanceRights;
}

/// A class of shares with specific rights and preferences.
///
/// Different share classes have different:
/// - Voting rights (may be super-voting or non-voting)
/// - Liquidation preferences (paid first in exit)
/// - Participation rights (double-dip or not)
/// - Dividend preferences
@freezed
class ShareClass with _$ShareClass {
  const ShareClass._();

  const factory ShareClass({
    required String id,
    required String companyId,
    required String name,
    required ShareClassType type,

    /// Voting power multiplier (1.0 = normal, 0 = non-voting, 10 = 10x).
    @Default(1.0) double votingMultiplier,

    /// Liquidation preference multiplier (1.0 = 1x, 2.0 = 2x participating).
    @Default(1.0) double liquidationPreference,

    /// Whether holders participate in remaining proceeds after preference.
    @Default(false) bool isParticipating,

    /// Annual dividend rate as a percentage (0-100).
    @Default(0.0) double dividendRate,

    /// Payment priority in liquidation (higher = paid first).
    @Default(0) int seniority,

    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ShareClass;

  factory ShareClass.fromJson(Map<String, dynamic> json) =>
      _$ShareClassFromJson(json);

  /// Human-readable summary of the class rights.
  String get rightsSummary {
    final parts = <String>[];

    if (votingMultiplier == 0) {
      parts.add('Non-voting');
    } else if (votingMultiplier != 1.0) {
      parts.add('${votingMultiplier}x voting');
    }

    if (liquidationPreference != 1.0) {
      parts.add('${liquidationPreference}x liq pref');
    }

    if (isParticipating) {
      parts.add('Participating');
    }

    if (dividendRate > 0) {
      parts.add('$dividendRate% dividend');
    }

    return parts.isEmpty ? 'Standard rights' : parts.join(' • ');
  }
}
