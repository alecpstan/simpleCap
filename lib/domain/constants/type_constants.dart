/// Type constants for stakeholders.
///
/// Use these instead of raw strings for type safety.
abstract class StakeholderType {
  static const String founder = 'founder';
  static const String employee = 'employee';
  static const String advisor = 'advisor';
  static const String investor = 'investor';
  static const String angel = 'angel';
  static const String vcFund = 'vcFund';
  static const String institution = 'institution';
  static const String company = 'company';
  static const String other = 'other';

  static const List<String> all = [
    founder,
    employee,
    advisor,
    investor,
    angel,
    vcFund,
    institution,
    company,
    other,
  ];

  static String displayName(String type) => switch (type) {
    founder => 'Founder',
    employee => 'Employee',
    advisor => 'Advisor',
    investor => 'Investor',
    angel => 'Angel Investor',
    vcFund => 'VC Fund',
    institution => 'Institution',
    company => 'Company',
    _ => 'Other',
  };
}

/// Type constants for share classes.
abstract class ShareClassType {
  static const String ordinary = 'ordinary';
  static const String preferenceA = 'preferenceA';
  static const String preferenceB = 'preferenceB';
  static const String preferenceC = 'preferenceC';
  static const String esop = 'esop';
  static const String options = 'options';
  static const String performanceRights = 'performanceRights';

  static const List<String> all = [
    ordinary,
    preferenceA,
    preferenceB,
    preferenceC,
    esop,
    options,
    performanceRights,
  ];

  static String displayName(String type) => switch (type) {
    ordinary => 'Ordinary',
    preferenceA => 'Preference A',
    preferenceB => 'Preference B',
    preferenceC => 'Preference C',
    esop => 'ESOP',
    options => 'Options',
    performanceRights => 'Performance Rights',
    _ => type, // Fallback to raw type string for unknown types
  };

  static bool isDerivative(String type) =>
      type == options || type == performanceRights;

  static bool isEsop(String type) =>
      type == esop || type == options || type == performanceRights;
}

/// Anti-dilution protection types for preference shares.
///
/// Protects investors when a future round prices below their original price.
abstract class AntiDilutionType {
  /// No anti-dilution protection.
  static const String none = 'none';

  /// Full ratchet: conversion price reset to new lower price.
  /// Most aggressive protection for investors.
  static const String fullRatchet = 'fullRatchet';

  /// Broad-based weighted average: conversion price adjusted by formula
  /// that accounts for all outstanding shares (more founder-friendly).
  static const String broadBasedWeightedAverage = 'broadBasedWeightedAverage';

  /// Narrow-based weighted average: like broad-based but only counts
  /// shares in the same class (less founder-friendly).
  static const String narrowBasedWeightedAverage = 'narrowBasedWeightedAverage';

  static const List<String> all = [
    none,
    fullRatchet,
    broadBasedWeightedAverage,
    narrowBasedWeightedAverage,
  ];

  static String displayName(String type) => switch (type) {
    none => 'None',
    fullRatchet => 'Full Ratchet',
    broadBasedWeightedAverage => 'Broad-Based Weighted Average',
    narrowBasedWeightedAverage => 'Narrow-Based Weighted Average',
    _ => type,
  };

  static String shortName(String type) => switch (type) {
    none => 'None',
    fullRatchet => 'Full Ratchet',
    broadBasedWeightedAverage => 'Broad-Based WA',
    narrowBasedWeightedAverage => 'Narrow-Based WA',
    _ => type,
  };
}

/// Type constants for financing rounds.
abstract class RoundType {
  static const String incorporation = 'incorporation';
  static const String seed = 'seed';
  static const String seriesA = 'seriesA';
  static const String seriesB = 'seriesB';
  static const String seriesC = 'seriesC';
  static const String seriesD = 'seriesD';
  static const String bridge = 'bridge';
  static const String convertibleRound = 'convertibleRound';
  static const String esopPool = 'esopPool';
  static const String secondary = 'secondary';
  static const String custom = 'custom';

  static const List<String> all = [
    incorporation,
    seed,
    seriesA,
    seriesB,
    seriesC,
    seriesD,
    bridge,
    convertibleRound,
    esopPool,
    secondary,
    custom,
  ];

  static String displayName(String type) => switch (type) {
    incorporation => 'Incorporation',
    seed => 'Seed',
    seriesA => 'Series A',
    seriesB => 'Series B',
    seriesC => 'Series C',
    seriesD => 'Series D',
    bridge => 'Bridge',
    convertibleRound => 'Convertible',
    esopPool => 'ESOP Pool',
    secondary => 'Secondary',
    _ => 'Custom',
  };

  static bool isEquityRound(String type) => switch (type) {
    convertibleRound || esopPool => false,
    _ => true,
  };
}

/// Status constants for financing rounds.
abstract class RoundStatus {
  static const String draft = 'draft';
  static const String closed = 'closed';

  static const List<String> all = [draft, closed];

  static String displayName(String status) => switch (status) {
    draft => 'Draft',
    closed => 'Closed',
    _ => status,
  };
}

/// Type constants for convertible instruments.
abstract class ConvertibleType {
  static const String safe = 'safe';
  static const String convertibleNote = 'convertibleNote';

  static const List<String> all = [safe, convertibleNote];

  static String displayName(String type) => switch (type) {
    safe => 'SAFE',
    convertibleNote => 'Convertible Note',
    _ => type,
  };
}

/// Status constants for convertible instruments.
abstract class ConvertibleStatus {
  /// Draft: Part of a draft round, not yet committed. No audit trail.
  static const String draft = 'draft';

  /// Outstanding: Formally issued and active.
  static const String outstanding = 'outstanding';
  static const String converted = 'converted';
  static const String cancelled = 'cancelled';

  static const List<String> all = [draft, outstanding, converted, cancelled];

  static String displayName(String status) => switch (status) {
    draft => 'Draft',
    outstanding => 'Outstanding',
    converted => 'Converted',
    cancelled => 'Cancelled',
    _ => status,
  };

  /// Returns true if the status is a formal, committed state (not draft).
  static bool isCommitted(String status) => status != draft;
}

/// Conversion trigger types for convertibles.
///
/// These define what events can trigger the conversion of a SAFE or note.
abstract class ConversionTrigger {
  /// Qualified/priced financing round (most common trigger).
  static const String qualifiedFinancing = 'qualifiedFinancing';

  /// Maturity date reached (for notes).
  static const String maturity = 'maturity';

  /// Liquidity event (acquisition, sale, IPO).
  static const String liquidityEvent = 'liquidityEvent';

  /// Company dissolution/wind-down.
  static const String dissolution = 'dissolution';

  /// Voluntary conversion by board/investor agreement.
  static const String voluntary = 'voluntary';

  static const List<String> all = [
    qualifiedFinancing,
    maturity,
    liquidityEvent,
    dissolution,
    voluntary,
  ];

  static String displayName(String trigger) => switch (trigger) {
    qualifiedFinancing => 'Qualified Financing',
    maturity => 'Maturity',
    liquidityEvent => 'Liquidity Event',
    dissolution => 'Dissolution',
    voluntary => 'Voluntary',
    _ => trigger,
  };
}

/// Maturity behavior - what happens when a convertible note matures.
abstract class MaturityBehavior {
  /// Automatically convert at the valuation cap.
  static const String convertAtCap = 'convertAtCap';

  /// Automatically convert at the discount rate.
  static const String convertAtDiscount = 'convertAtDiscount';

  /// Repay principal plus accrued interest.
  static const String repay = 'repay';

  /// Extend the maturity date (requires negotiation).
  static const String extend = 'extend';

  /// Requires negotiation - no automatic behavior.
  static const String negotiate = 'negotiate';

  static const List<String> all = [
    convertAtCap,
    convertAtDiscount,
    repay,
    extend,
    negotiate,
  ];

  static String displayName(String behavior) => switch (behavior) {
    convertAtCap => 'Convert at Cap',
    convertAtDiscount => 'Convert at Discount',
    repay => 'Repay Principal + Interest',
    extend => 'Extend Maturity',
    negotiate => 'Requires Negotiation',
    _ => behavior,
  };

  /// Whether this behavior allows standalone conversion (outside a round).
  static bool allowsStandaloneConversion(String behavior) =>
      behavior == convertAtCap || behavior == convertAtDiscount;
}

/// Liquidity event behavior - what happens on exit/IPO.
abstract class LiquidityEventBehavior {
  /// Convert at valuation cap before distribution.
  static const String convertAtCap = 'convertAtCap';

  /// Receive cash payout (principal multiplied by a factor).
  static const String cashPayout = 'cashPayout';

  /// Greater of conversion value or cash payout.
  static const String greaterOf = 'greaterOf';

  /// Requires negotiation.
  static const String negotiate = 'negotiate';

  static const List<String> all = [
    convertAtCap,
    cashPayout,
    greaterOf,
    negotiate,
  ];

  static String displayName(String behavior) => switch (behavior) {
    convertAtCap => 'Convert at Cap',
    cashPayout => 'Cash Payout',
    greaterOf => 'Greater of Convert or Cash',
    negotiate => 'Requires Negotiation',
    _ => behavior,
  };
}

/// Dissolution behavior - what happens if company winds down.
abstract class DissolutionBehavior {
  /// Pari passu with common shareholders.
  static const String pariPassu = 'pariPassu';

  /// Priority return of principal.
  static const String principalFirst = 'principalFirst';

  /// Full amount plus accrued interest.
  static const String fullAmount = 'fullAmount';

  /// Nothing (SAFE-style, no debt).
  static const String nothing = 'nothing';

  static const List<String> all = [
    pariPassu,
    principalFirst,
    fullAmount,
    nothing,
  ];

  static String displayName(String behavior) => switch (behavior) {
    pariPassu => 'Pari Passu with Common',
    principalFirst => 'Principal Returned First',
    fullAmount => 'Full Amount + Interest',
    nothing => 'No Return (SAFE-style)',
    _ => behavior,
  };
}

/// Status constants for option grants.
abstract class OptionGrantStatus {
  /// Draft: Part of a draft round, not yet committed. No audit trail.
  static const String draft = 'draft';

  /// Pending: Formally granted but cliff not yet met.
  static const String pending = 'pending';
  static const String active = 'active';
  static const String partiallyExercised = 'partiallyExercised';
  static const String fullyExercised = 'fullyExercised';
  static const String expired = 'expired';
  static const String cancelled = 'cancelled';
  static const String forfeited = 'forfeited';

  static const List<String> all = [
    draft,
    pending,
    active,
    partiallyExercised,
    fullyExercised,
    expired,
    cancelled,
    forfeited,
  ];

  static String displayName(String status) => switch (status) {
    draft => 'Draft',
    pending => 'Pending',
    active => 'Active',
    partiallyExercised => 'Partially Exercised',
    fullyExercised => 'Fully Exercised',
    expired => 'Expired',
    cancelled => 'Cancelled',
    forfeited => 'Forfeited',
    _ => status,
  };

  static bool isExercisable(String status) =>
      status == active || status == partiallyExercised;

  /// Returns true if the status is a formal, committed state (not draft).
  static bool isCommitted(String status) => status != draft;
}

/// Status constants for warrants.
abstract class WarrantStatus {
  /// Draft: Part of a draft round, not yet committed. No audit trail.
  static const String draft = 'draft';

  /// Pending: Formally issued but not yet active.
  static const String pending = 'pending';
  static const String active = 'active';
  static const String partiallyExercised = 'partiallyExercised';
  static const String fullyExercised = 'fullyExercised';
  static const String expired = 'expired';
  static const String cancelled = 'cancelled';

  static const List<String> all = [
    draft,
    pending,
    active,
    partiallyExercised,
    fullyExercised,
    expired,
    cancelled,
  ];

  static String displayName(String status) => switch (status) {
    draft => 'Draft',
    pending => 'Pending',
    active => 'Active',
    partiallyExercised => 'Partially Exercised',
    fullyExercised => 'Fully Exercised',
    expired => 'Expired',
    cancelled => 'Cancelled',
    _ => status,
  };

  static bool isExercisable(String status) =>
      status == active || status == partiallyExercised;

  /// Returns true if the status is a formal, committed state (not draft).
  static bool isCommitted(String status) => status != draft;
}

/// Exercise type constants for options and warrants.
///
/// Tracks how the exercise was performed:
/// - Cash: Holder pays full strike price in cash, receives all shares
/// - Cashless: Shares sold at market to cover strike price, net shares received
/// - Net: Shares withheld to cover strike price, net shares received
abstract class ExerciseType {
  /// Standard cash exercise - pay strike price in cash.
  static const String cash = 'cash';

  /// Cashless (same-day sale) - sell enough shares to cover strike + taxes.
  /// Common at IPO/M&A. Holder receives cash proceeds minus costs.
  static const String cashless = 'cashless';

  /// Net exercise - shares withheld to cover strike price.
  /// No cash changes hands, holder receives net shares.
  static const String net = 'net';

  /// Net exercise with tax withholding - shares withheld for strike + taxes.
  static const String netWithTax = 'netWithTax';

  static const List<String> all = [cash, cashless, net, netWithTax];

  static String displayName(String type) => switch (type) {
    cash => 'Cash Exercise',
    cashless => 'Cashless (Same-Day Sale)',
    net => 'Net Exercise',
    netWithTax => 'Net Exercise (with Tax)',
    _ => type,
  };

  static String description(String type) => switch (type) {
    cash => 'Pay strike price in cash, receive all shares',
    cashless => 'Sell shares at market to cover costs, receive cash',
    net => 'Shares withheld to cover strike, receive net shares',
    netWithTax => 'Shares withheld for strike + taxes, receive net shares',
    _ => '',
  };

  /// Returns true if this exercise type results in shares being withheld.
  static bool withholdsShares(String type) => type == net || type == netWithTax;

  /// Returns true if this exercise type involves a same-day sale.
  static bool involvesSale(String type) => type == cashless;
}

/// Type constants for vesting schedules.
abstract class VestingType {
  static const String timeBased = 'timeBased';
  static const String milestone = 'milestone';
  static const String hours = 'hours';
  static const String immediate = 'immediate';

  static const List<String> all = [timeBased, milestone, hours, immediate];

  static String displayName(String type) => switch (type) {
    timeBased => 'Time-Based',
    milestone => 'Milestone',
    hours => 'Hours-Based',
    immediate => 'Immediate',
    _ => type,
  };
}

/// Frequency constants for vesting.
abstract class VestingFrequency {
  static const String monthly = 'monthly';
  static const String quarterly = 'quarterly';
  static const String annually = 'annually';

  static const List<String> all = [monthly, quarterly, annually];

  static String displayName(String frequency) => switch (frequency) {
    monthly => 'Monthly',
    quarterly => 'Quarterly',
    annually => 'Annually',
    _ => frequency,
  };

  static int monthsPerTranche(String frequency) => switch (frequency) {
    monthly => 1,
    quarterly => 3,
    annually => 12,
    _ => 1,
  };
}

/// Transfer status constants.
abstract class TransferStatus {
  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';

  static const List<String> all = [pending, approved, completed, cancelled];

  static String displayName(String status) => switch (status) {
    pending => 'Pending',
    approved => 'Approved',
    completed => 'Completed',
    cancelled => 'Cancelled',
    _ => status,
  };
}
