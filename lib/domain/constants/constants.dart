/// Domain constants - type-safe string constants for database values.
///
/// These constants replace enums for database string fields, providing:
/// - Type safety via named constants instead of raw strings
/// - Display name mappings for UI
/// - Helper methods (isExercisable, isEquityRound, etc.)
///
/// ## Usage
///
/// ```dart
/// import 'package:cap_table/domain/constants/constants.dart';
///
/// // Instead of: if (round.status == 'draft')
/// // Use:
/// if (round.status == RoundStatus.draft) { ... }
///
/// // Get display name for UI:
/// Text(StakeholderType.displayName(stakeholder.type))
///
/// // Check properties:
/// if (OptionGrantStatus.isExercisable(option.status)) { ... }
/// ```
library;

export 'type_constants.dart';
