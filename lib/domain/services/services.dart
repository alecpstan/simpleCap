/// Domain services - pure business logic functions.
///
/// These services contain calculation and validation logic that operates
/// on Drift database types. They are kept separate from providers to enable:
/// - Unit testing without Riverpod
/// - Reuse across multiple providers
/// - Clear separation of concerns
///
/// ## Usage
///
/// ```dart
/// import 'package:cap_table/domain/services/services.dart';
///
/// // Calculate accrued interest on a convertible
/// final interest = ConversionCalculator.accruedInterest(convertible);
///
/// // Check if options are exercisable
/// if (OptionCalculator.isExercisable(option)) {
///   final value = OptionCalculator.intrinsicValue(option, sharePrice);
/// }
///
/// // Calculate vesting percentage
/// final percent = VestingCalculator.vestingPercentAt(
///   schedule: schedule,
///   startDate: grantDate,
///   asOfDate: DateTime.now(),
/// );
/// ```
library;

export 'conversion_calculator.dart';
export 'mfn_calculator.dart';
export 'option_calculator.dart';
export 'round_calculator.dart';
export 'vesting_calculator.dart';
