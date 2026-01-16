import 'package:flutter/material.dart';

/// Semantic color definitions for the application.
///
/// These map business concepts to colors, providing consistency
/// and making it easy to adjust the color language globally.
class AppColors {
  AppColors._();

  // === Status Colors ===

  /// Active, open, in-progress states
  static const Color active = Colors.blue;

  /// Pending, draft, awaiting action
  static const Color pending = Colors.amber;

  /// Success, closed, completed, exercised
  static const Color success = Colors.green;

  /// Partial completion states
  static const Color partial = Colors.teal;

  /// Expired, inactive, exited
  static const Color inactive = Colors.grey;

  /// Cancelled, errors, destructive actions
  static const Color error = Colors.red;

  /// Warnings, caution needed
  static const Color warning = Colors.orange;

  // === Domain Colors ===

  /// Financial values, valuations
  static const Color financial = Colors.blue;

  /// Scenarios, projections, modeling
  static const Color scenarios = Colors.purple;

  /// ESOP, options, equity compensation
  static const Color esop = Colors.orange;

  /// Convertibles, SAFEs, notes
  static const Color convertibles = Colors.teal;

  /// Rounds, funding events
  static const Color rounds = Colors.indigo;

  // === Stakeholder Type Colors ===

  static const Color founder = Colors.purple;
  static const Color angel = Color(0xFFFFA000); // amber.shade700
  static const Color vcFund = Colors.blue;
  static const Color employee = Colors.green;
  static const Color advisor = Colors.teal;
  static const Color institution = Colors.indigo;
  static const Color other = Colors.grey;

  // === Round Type Colors ===

  static const Color incorporation = Colors.grey;
  static const Color seed = Colors.green;
  static const Color seriesA = Colors.blue;
  static const Color seriesB = Colors.purple;
  static const Color seriesC = Colors.orange;
  static const Color seriesD = Colors.red;
  static const Color bridge = Colors.amber;
  static const Color convertibleRound = Colors.teal;
  static const Color esopPool = Colors.indigo;
  static const Color secondary = Colors.brown;
  static const Color custom = Colors.blueGrey;

  // === Chart Colors ===

  static const List<Color> chartPalette = [
    Color(0xFF2196F3), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFF44336), // Red
    Color(0xFFFF9800), // Orange
    Color(0xFF9C27B0), // Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFFEB3B), // Yellow
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
    Color(0xFFE91E63), // Pink
  ];
}
