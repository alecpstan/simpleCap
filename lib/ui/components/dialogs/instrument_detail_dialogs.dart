import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/spacing.dart';
import '../../../domain/constants/constants.dart';
import '../../../infrastructure/database/database.dart';
import '../../../shared/formatters.dart';
import '../cards/detail_row.dart';

// =============================================================================
// HOLDING DETAIL DIALOG
// =============================================================================

/// Detail dialog for viewing/editing a holding.
class HoldingDetailDialog extends ConsumerWidget {
  final Holding holding;
  final String? shareClassName;
  final String? roundName;
  final VestingSchedule? vestingSchedule;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showDeleteButton;
  final bool isDraft;

  const HoldingDetailDialog({
    super.key,
    required this.holding,
    this.shareClassName,
    this.roundName,
    this.vestingSchedule,
    this.onEdit,
    this.onDelete,
    this.showDeleteButton = false,
    this.isDraft = false,
  });

  static Future<void> show({
    required BuildContext context,
    required Holding holding,
    String? shareClassName,
    String? roundName,
    VestingSchedule? vestingSchedule,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    bool showDeleteButton = false,
    bool isDraft = false,
  }) {
    return showDialog(
      context: context,
      builder: (context) => HoldingDetailDialog(
        holding: holding,
        shareClassName: shareClassName,
        roundName: roundName,
        vestingSchedule: vestingSchedule,
        onEdit: onEdit,
        onDelete: onDelete,
        showDeleteButton: showDeleteButton,
        isDraft: isDraft,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hasVesting =
        holding.vestingScheduleId != null && holding.vestedCount != null;
    final vestingPercent = hasVesting
        ? ((holding.vestedCount! / holding.shareCount) * 100)
        : 100.0;
    final isFullyVested = vestingPercent >= 100;

    return AlertDialog(
      title: const Text('Holding Details'),
      content: SizedBox(
        width: Spacing.dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main info section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    DetailRow(
                      label: 'Share Count',
                      value: Formatters.number(holding.shareCount),
                      highlight: true,
                    ),
                    DetailRow(
                      label: 'Share Class',
                      value: shareClassName ?? 'Unknown',
                    ),
                    DetailRow(
                      label: 'Cost Basis',
                      value: Formatters.currency(holding.costBasis),
                    ),
                    DetailRow(
                      label: 'Acquired Date',
                      value: Formatters.date(holding.acquiredDate),
                    ),
                    if (roundName != null)
                      DetailRow(label: 'Round', value: roundName!),
                  ],
                ),
              ),

              // Vesting section
              if (hasVesting) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isFullyVested
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.indigo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vesting',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (vestingSchedule != null) ...[
                        DetailRow(
                          label: 'Schedule',
                          value: vestingSchedule!.name,
                        ),
                        DetailRow(
                          label: 'Terms',
                          value: _buildVestingDescription(vestingSchedule!),
                        ),
                      ],
                      DetailRow(
                        label: 'Vested Shares',
                        value: Formatters.number(holding.vestedCount ?? 0),
                      ),
                      DetailRow(
                        label: 'Unvested Shares',
                        value: Formatters.number(
                          holding.shareCount - (holding.vestedCount ?? 0),
                        ),
                      ),
                      ProgressRow(
                        label: 'Vesting Progress',
                        progress: vestingPercent / 100,
                        color: isFullyVested ? Colors.green : Colors.indigo,
                      ),
                    ],
                  ),
                ),
              ],

              // Value section
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    DetailRow(
                      label: 'Total Cost',
                      value: Formatters.currency(
                        holding.shareCount * holding.costBasis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        // Draft items always show delete, non-drafts need showDeleteButton
        if (onDelete != null && (isDraft || showDeleteButton))
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete!();
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        if (onEdit != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onEdit!();
            },
            child: const Text('Edit'),
          ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  /// Builds a human-readable description of a vesting schedule.
  String _buildVestingDescription(VestingSchedule schedule) {
    final type = schedule.type;

    if (type == VestingType.immediate) return 'Immediate vesting';
    if (type == VestingType.milestone) return 'Milestone-based';
    if (type == VestingType.hours) {
      return '${schedule.totalHours ?? 0} hours';
    }

    final total = schedule.totalMonths ?? 0;
    final years = total ~/ 12;
    final remainingMonths = total % 12;
    final cliffMonths = schedule.cliffMonths;

    final parts = <String>[];

    if (years > 0) {
      parts.add('$years yr${years > 1 ? 's' : ''}');
    }
    if (remainingMonths > 0) {
      parts.add('$remainingMonths mo');
    }

    if (cliffMonths > 0) {
      final cliffYears = cliffMonths ~/ 12;
      final cliffRemaining = cliffMonths % 12;
      if (cliffYears > 0) {
        parts.add('$cliffYears yr cliff');
      } else {
        parts.add('$cliffRemaining mo cliff');
      }
    }

    return parts.isEmpty ? 'Custom' : parts.join(' / ');
  }
}

// =============================================================================
// OPTION GRANT DETAIL DIALOG
// =============================================================================

/// Detail dialog for viewing/editing an option grant.
class OptionDetailDialog extends ConsumerWidget {
  final OptionGrant option;
  final String? shareClassName;
  final String? stakeholderName;
  final double? vestingPercent;
  final VestingSchedule? vestingSchedule;
  final double? currentSharePrice;
  final VoidCallback? onEdit;
  final VoidCallback? onExercise;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;
  final bool showDeleteButton;
  final bool isDraft;

  const OptionDetailDialog({
    super.key,
    required this.option,
    this.shareClassName,
    this.stakeholderName,
    this.vestingPercent,
    this.vestingSchedule,
    this.currentSharePrice,
    this.onEdit,
    this.onExercise,
    this.onCancel,
    this.onDelete,
    this.showDeleteButton = false,
    this.isDraft = false,
  });

  static Future<void> show({
    required BuildContext context,
    required OptionGrant option,
    String? shareClassName,
    String? stakeholderName,
    double? vestingPercent,
    VestingSchedule? vestingSchedule,
    double? currentSharePrice,
    VoidCallback? onEdit,
    VoidCallback? onExercise,
    VoidCallback? onCancel,
    VoidCallback? onDelete,
    bool showDeleteButton = false,
    bool isDraft = false,
  }) {
    return showDialog(
      context: context,
      builder: (context) => OptionDetailDialog(
        option: option,
        shareClassName: shareClassName,
        stakeholderName: stakeholderName,
        vestingPercent: vestingPercent,
        vestingSchedule: vestingSchedule,
        currentSharePrice: currentSharePrice,
        onEdit: onEdit,
        onExercise: onExercise,
        onCancel: onCancel,
        onDelete: onDelete,
        showDeleteButton: showDeleteButton,
        isDraft: isDraft,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final outstanding =
        option.quantity - option.exercisedCount - option.cancelledCount;
    final isActive =
        option.status == 'active' || option.status == 'partially_exercised';
    final isInTheMoney =
        currentSharePrice != null && currentSharePrice! > option.strikePrice;
    final intrinsicValue = isInTheMoney
        ? (currentSharePrice! - option.strikePrice) * outstanding
        : 0.0;

    // Exercise is only available if:
    // 1. Grant is active with outstanding options, AND
    // 2. Either allowsEarlyExercise is true OR options are fully vested (100%)
    final isFullyVested = vestingPercent != null && vestingPercent! >= 100;
    final canExercise =
        isActive &&
        outstanding > 0 &&
        (option.allowsEarlyExercise || isFullyVested || vestingPercent == null);

    return AlertDialog(
      title: const Text('Option Grant Details'),
      content: SizedBox(
        width: Spacing.dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grant info section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          stakeholderName ?? 'Unknown',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        _buildStatusBadge(context),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DetailRow(
                      label: 'Options Granted',
                      value: Formatters.number(option.quantity),
                    ),
                    DetailRow(
                      label: 'Strike Price',
                      value: Formatters.currency(option.strikePrice),
                    ),
                    DetailRow(
                      label: 'Share Class',
                      value: shareClassName ?? 'Unknown',
                    ),
                    DetailRow(
                      label: 'Grant Date',
                      value: Formatters.date(option.grantDate),
                    ),
                    DetailRow(
                      label: 'Expiry Date',
                      value: Formatters.date(option.expiryDate),
                    ),
                  ],
                ),
              ),

              // Status breakdown
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (vestingSchedule != null) ...[
                      DetailRow(
                        label: 'Vesting Schedule',
                        value: vestingSchedule!.name,
                      ),
                      DetailRow(
                        label: 'Terms',
                        value: _buildVestingDescription(vestingSchedule!),
                      ),
                    ],
                    if (vestingPercent != null)
                      ProgressRow(
                        label: 'Vested',
                        progress: vestingPercent! / 100,
                        valueText: '${vestingPercent!.toStringAsFixed(0)}%',
                        color: vestingPercent! >= 100
                            ? Colors.green
                            : Colors.indigo,
                      ),
                    DetailRow(
                      label: 'Outstanding',
                      value: Formatters.number(outstanding),
                    ),
                    DetailRow(
                      label: 'Exercised',
                      value: Formatters.number(option.exercisedCount),
                    ),
                    DetailRow(
                      label: 'Cancelled',
                      value: Formatters.number(option.cancelledCount),
                    ),
                  ],
                ),
              ),

              // Value section
              if (currentSharePrice != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isInTheMoney
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isInTheMoney
                          ? Colors.green.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isInTheMoney ? Icons.trending_up : Icons.trending_flat,
                        color: isInTheMoney ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isInTheMoney ? 'In The Money' : 'Out of Money',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isInTheMoney
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                            Text(
                              'Intrinsic value: ${Formatters.currency(intrinsicValue)}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        // Draft items always show delete, non-drafts need showDeleteButton
        if (onDelete != null && (isDraft || showDeleteButton))
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete!();
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        // Hide cancel for draft items (they should be deleted, not cancelled)
        if (onCancel != null && canExercise && !isDraft)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onCancel!();
            },
            child: const Text('Cancel Options'),
          ),
        if (onEdit != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onEdit!();
            },
            child: const Text('Edit'),
          ),
        // Disable exercise for draft items
        if (onExercise != null && canExercise && !isDraft)
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onExercise!();
            },
            child: const Text('Exercise'),
          )
        else
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final color = _getStatusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _getStatusText(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (option.status) {
      case 'active':
        return Colors.orange;
      case 'partially_exercised':
        return Colors.blue;
      case 'fully_exercised':
      case 'exercised':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'expired':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (option.status) {
      case 'active':
        return 'Active';
      case 'partially_exercised':
        return 'Partial';
      case 'fully_exercised':
      case 'exercised':
        return 'Exercised';
      case 'cancelled':
        return 'Cancelled';
      case 'expired':
        return 'Expired';
      default:
        return option.status;
    }
  }

  /// Builds a human-readable description of a vesting schedule.
  String _buildVestingDescription(VestingSchedule schedule) {
    final type = schedule.type;

    if (type == VestingType.immediate) return 'Immediate vesting';
    if (type == VestingType.milestone) return 'Milestone-based';
    if (type == VestingType.hours) {
      return '${schedule.totalHours ?? 0} hours';
    }

    final total = schedule.totalMonths ?? 0;
    final years = total ~/ 12;
    final remainingMonths = total % 12;
    final cliffMonths = schedule.cliffMonths;

    final parts = <String>[];

    if (years > 0) {
      parts.add('$years yr${years > 1 ? 's' : ''}');
    }
    if (remainingMonths > 0) {
      parts.add('$remainingMonths mo');
    }

    if (cliffMonths > 0) {
      final cliffYears = cliffMonths ~/ 12;
      final cliffRemaining = cliffMonths % 12;
      if (cliffYears > 0) {
        parts.add('$cliffYears yr cliff');
      } else {
        parts.add('$cliffRemaining mo cliff');
      }
    }

    return parts.isEmpty ? 'Custom' : parts.join(' / ');
  }
}

// =============================================================================
// CONVERTIBLE DETAIL DIALOG
// =============================================================================

/// Detail dialog for viewing/editing a convertible instrument.
class ConvertibleDetailDialog extends ConsumerWidget {
  final Convertible convertible;
  final String? stakeholderName;
  final VoidCallback? onEdit;
  final VoidCallback? onConvert;
  final VoidCallback? onRevert;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;
  final bool showDeleteButton;
  final bool isDraft;

  const ConvertibleDetailDialog({
    super.key,
    required this.convertible,
    this.stakeholderName,
    this.onEdit,
    this.onConvert,
    this.onRevert,
    this.onCancel,
    this.onDelete,
    this.showDeleteButton = false,
    this.isDraft = false,
  });

  static Future<void> show({
    required BuildContext context,
    required Convertible convertible,
    String? stakeholderName,
    VoidCallback? onEdit,
    VoidCallback? onConvert,
    VoidCallback? onRevert,
    VoidCallback? onCancel,
    VoidCallback? onDelete,
    bool showDeleteButton = false,
    bool isDraft = false,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ConvertibleDetailDialog(
        convertible: convertible,
        stakeholderName: stakeholderName,
        onEdit: onEdit,
        onConvert: onConvert,
        onRevert: onRevert,
        onCancel: onCancel,
        onDelete: onDelete,
        showDeleteButton: showDeleteButton,
        isDraft: isDraft,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isSafe = convertible.type.toLowerCase() == 'safe';
    final isOutstanding = convertible.status == 'outstanding';
    final isConverted = convertible.status == 'converted';
    final color = isOutstanding
        ? (isSafe ? Colors.purple : Colors.teal)
        : Colors.grey;

    return AlertDialog(
      title: Text(isSafe ? 'SAFE Details' : 'Convertible Note Details'),
      content: SizedBox(
        width: Spacing.dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main info section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          stakeholderName ?? 'Unknown',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        _buildStatusBadge(context, color),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DetailRow(
                      label: 'Principal',
                      value: Formatters.currency(convertible.principal),
                      highlight: true,
                    ),
                    DetailRow(
                      label: 'Issue Date',
                      value: Formatters.date(convertible.issueDate),
                    ),
                    if (convertible.maturityDate != null)
                      DetailRow(
                        label: 'Maturity Date',
                        value: Formatters.date(convertible.maturityDate!),
                      ),
                  ],
                ),
              ),

              // Terms section
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Terms',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (convertible.valuationCap != null)
                      DetailRow(
                        label: 'Valuation Cap',
                        value: Formatters.currency(convertible.valuationCap!),
                      ),
                    if (convertible.discountPercent != null)
                      DetailRow(
                        label: 'Discount',
                        value:
                            '${(convertible.discountPercent! * 100).toStringAsFixed(0)}%',
                      ),
                    if (convertible.interestRate != null)
                      DetailRow(
                        label: 'Interest Rate',
                        value:
                            '${(convertible.interestRate! * 100).toStringAsFixed(1)}%',
                      ),
                    DetailRow(
                      label: 'MFN Clause',
                      value: convertible.hasMfn ? 'Yes' : 'No',
                    ),
                    DetailRow(
                      label: 'Pro-rata Rights',
                      value: convertible.hasProRata ? 'Yes' : 'No',
                    ),
                  ],
                ),
              ),

              // Advanced Terms section (if any are set)
              if (_hasAdvancedTerms()) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Advanced Terms',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (convertible.qualifiedFinancingThreshold != null)
                        DetailRow(
                          label: 'Qualified Financing',
                          value:
                              '≥ ${Formatters.currency(convertible.qualifiedFinancingThreshold!)}',
                        ),
                      if (convertible.maturityBehavior != null)
                        DetailRow(
                          label: 'At Maturity',
                          value: MaturityBehavior.displayName(
                            convertible.maturityBehavior!,
                          ),
                        ),
                      if (convertible.allowsVoluntaryConversion)
                        const DetailRow(
                          label: 'Voluntary Conversion',
                          value: 'Allowed',
                        ),
                      if (convertible.liquidityEventBehavior != null)
                        DetailRow(
                          label: 'On Liquidity Event',
                          value: LiquidityEventBehavior.displayName(
                            convertible.liquidityEventBehavior!,
                          ),
                        ),
                      if (convertible.liquidityPayoutMultiple != null)
                        DetailRow(
                          label: 'Payout Multiple',
                          value: '${convertible.liquidityPayoutMultiple}x',
                        ),
                      if (convertible.dissolutionBehavior != null)
                        DetailRow(
                          label: 'On Dissolution',
                          value: DissolutionBehavior.displayName(
                            convertible.dissolutionBehavior!,
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              // Conversion details (if converted)
              if (isConverted && convertible.sharesReceived != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conversion',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DetailRow(
                        label: 'Shares Received',
                        value: Formatters.number(convertible.sharesReceived!),
                      ),
                    ],
                  ),
                ),
              ],

              // Notes
              if (convertible.notes != null &&
                  convertible.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Notes',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(convertible.notes!, style: theme.textTheme.bodySmall),
              ],
            ],
          ),
        ),
      ),
      actions: [
        // Draft items always show delete, non-drafts need showDeleteButton
        if (onDelete != null && (isDraft || showDeleteButton))
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete!();
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        // Hide cancel for draft items
        if (onCancel != null && isOutstanding && !isDraft)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onCancel!();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Cancel'),
          ),
        if (onEdit != null && isOutstanding)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onEdit!();
            },
            child: const Text('Edit'),
          ),
        if (onRevert != null && isConverted)
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onRevert!();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Revert'),
          ),
        // Convert button only visible if voluntary conversion is allowed
        if (onConvert != null &&
            isOutstanding &&
            !isDraft &&
            convertible.allowsVoluntaryConversion)
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onConvert!();
            },
            child: const Text('Convert'),
          ),
        // Always show Close button
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _getStatusText(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getStatusText() {
    switch (convertible.status) {
      case 'outstanding':
        return 'Outstanding';
      case 'converted':
        return 'Converted';
      case 'cancelled':
        return 'Cancelled';
      default:
        return convertible.status;
    }
  }

  bool _hasAdvancedTerms() {
    return convertible.maturityBehavior != null ||
        convertible.allowsVoluntaryConversion ||
        convertible.liquidityEventBehavior != null ||
        convertible.dissolutionBehavior != null ||
        convertible.preferredShareClassId != null ||
        convertible.qualifiedFinancingThreshold != null;
  }
}

// =============================================================================
// WARRANT DETAIL DIALOG
// =============================================================================

/// Detail dialog for viewing/editing a warrant.
class WarrantDetailDialog extends ConsumerWidget {
  final Warrant warrant;
  final String? shareClassName;
  final String? stakeholderName;
  final double? currentSharePrice;
  final VoidCallback? onEdit;
  final VoidCallback? onExercise;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;
  final bool showDeleteButton;
  final bool isDraft;

  const WarrantDetailDialog({
    super.key,
    required this.warrant,
    this.shareClassName,
    this.stakeholderName,
    this.currentSharePrice,
    this.onEdit,
    this.onExercise,
    this.onCancel,
    this.onDelete,
    this.showDeleteButton = false,
    this.isDraft = false,
  });

  static Future<void> show({
    required BuildContext context,
    required Warrant warrant,
    String? shareClassName,
    String? stakeholderName,
    double? currentSharePrice,
    VoidCallback? onEdit,
    VoidCallback? onExercise,
    VoidCallback? onCancel,
    VoidCallback? onDelete,
    bool showDeleteButton = false,
    bool isDraft = false,
  }) {
    return showDialog(
      context: context,
      builder: (context) => WarrantDetailDialog(
        warrant: warrant,
        shareClassName: shareClassName,
        stakeholderName: stakeholderName,
        currentSharePrice: currentSharePrice,
        onEdit: onEdit,
        onExercise: onExercise,
        onCancel: onCancel,
        onDelete: onDelete,
        showDeleteButton: showDeleteButton,
        isDraft: isDraft,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final remaining =
        warrant.quantity - warrant.exercisedCount - warrant.cancelledCount;
    final isActive = warrant.status == 'active';
    final isInTheMoney =
        currentSharePrice != null && currentSharePrice! > warrant.strikePrice;
    final intrinsicValue = isInTheMoney
        ? (currentSharePrice! - warrant.strikePrice) * remaining
        : 0.0;
    final canExercise = isActive && remaining > 0;
    final color = isActive
        ? (isInTheMoney ? Colors.green : Colors.teal)
        : Colors.grey;

    return AlertDialog(
      title: const Text('Warrant Details'),
      content: SizedBox(
        width: Spacing.dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main info section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          stakeholderName ?? 'Unknown',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        _buildStatusBadge(context, color),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DetailRow(
                      label: 'Warrants',
                      value: Formatters.number(warrant.quantity),
                    ),
                    DetailRow(
                      label: 'Strike Price',
                      value: Formatters.currency(warrant.strikePrice),
                    ),
                    DetailRow(
                      label: 'Share Class',
                      value: shareClassName ?? 'Unknown',
                    ),
                    DetailRow(
                      label: 'Issue Date',
                      value: Formatters.date(warrant.issueDate),
                    ),
                    DetailRow(
                      label: 'Expiry Date',
                      value: Formatters.date(warrant.expiryDate),
                    ),
                  ],
                ),
              ),

              // Status breakdown
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DetailRow(
                      label: 'Remaining',
                      value: Formatters.number(remaining),
                    ),
                    DetailRow(
                      label: 'Exercised',
                      value: Formatters.number(warrant.exercisedCount),
                    ),
                    DetailRow(
                      label: 'Cancelled',
                      value: Formatters.number(warrant.cancelledCount),
                    ),
                  ],
                ),
              ),

              // Value section
              if (currentSharePrice != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isInTheMoney
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isInTheMoney
                          ? Colors.green.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isInTheMoney ? Icons.trending_up : Icons.trending_flat,
                        color: isInTheMoney ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isInTheMoney ? 'In The Money' : 'Out of Money',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isInTheMoney
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                            Text(
                              'Intrinsic value: ${Formatters.currency(intrinsicValue)}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        // Draft items always show delete, non-drafts need showDeleteButton
        if (onDelete != null && (isDraft || showDeleteButton))
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete!();
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        // Hide cancel for draft items
        if (onCancel != null && canExercise && !isDraft)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onCancel!();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Cancel Warrants'),
          ),
        if (onEdit != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onEdit!();
            },
            child: const Text('Edit'),
          ),
        // Disable exercise for draft items
        if (onExercise != null && canExercise && !isDraft)
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onExercise!();
            },
            child: const Text('Exercise'),
          )
        else
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _getStatusText(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getStatusText() {
    switch (warrant.status) {
      case 'active':
        return 'Active';
      case 'partially_exercised':
        return 'Partial';
      case 'fully_exercised':
      case 'exercised':
        return 'Exercised';
      case 'expired':
        return 'Expired';
      case 'cancelled':
        return 'Cancelled';
      default:
        return warrant.status;
    }
  }
}

// =============================================================================
// MFN UPGRADE DETAIL DIALOG
// =============================================================================

/// Detail dialog for viewing an MFN upgrade with optional delete.
class MfnUpgradeDetailDialog extends ConsumerWidget {
  final MfnUpgrade upgrade;
  final Convertible? sourceConvertible;
  final Stakeholder? sourceStakeholder;
  final VoidCallback? onDelete;
  final bool showDeleteButton;

  const MfnUpgradeDetailDialog({
    super.key,
    required this.upgrade,
    this.sourceConvertible,
    this.sourceStakeholder,
    this.onDelete,
    this.showDeleteButton = false,
  });

  static Future<void> show({
    required BuildContext context,
    required MfnUpgrade upgrade,
    Convertible? sourceConvertible,
    Stakeholder? sourceStakeholder,
    VoidCallback? onDelete,
    bool showDeleteButton = false,
  }) {
    return showDialog(
      context: context,
      builder: (context) => MfnUpgradeDetailDialog(
        upgrade: upgrade,
        sourceConvertible: sourceConvertible,
        sourceStakeholder: sourceStakeholder,
        onDelete: onDelete,
        showDeleteButton: showDeleteButton,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('MFN Upgrade Details'),
      content: SizedBox(
        width: Spacing.dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main info section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          sourceStakeholder?.name ?? 'Unknown Source',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Applied',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DetailRow(
                      label: 'Upgrade Date',
                      value: Formatters.date(upgrade.upgradeDate),
                      highlight: true,
                    ),
                    if (sourceConvertible != null)
                      DetailRow(
                        label: 'Source Type',
                        value: sourceConvertible!.type.toUpperCase(),
                      ),
                  ],
                ),
              ),

              // Terms changed section
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Terms Changed',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Discount change
                    if (upgrade.newDiscountPercent != null)
                      _buildTermChangeRow(
                        context,
                        label: 'Discount',
                        oldValue: upgrade.previousDiscountPercent != null
                            ? '${(upgrade.previousDiscountPercent! * 100).toStringAsFixed(0)}%'
                            : 'None',
                        newValue:
                            '${(upgrade.newDiscountPercent! * 100).toStringAsFixed(0)}%',
                      ),
                    // Valuation cap change
                    if (upgrade.newValuationCap != null)
                      _buildTermChangeRow(
                        context,
                        label: 'Valuation Cap',
                        oldValue: upgrade.previousValuationCap != null
                            ? Formatters.compactCurrency(
                                upgrade.previousValuationCap!,
                              )
                            : 'None',
                        newValue: Formatters.compactCurrency(
                          upgrade.newValuationCap!,
                        ),
                      ),
                    // Pro-rata rights change
                    if (upgrade.newHasProRata && !upgrade.previousHasProRata)
                      _buildTermChangeRow(
                        context,
                        label: 'Pro-rata Rights',
                        oldValue: 'No',
                        newValue: 'Yes',
                      ),
                  ],
                ),
              ),

              // Source convertible details
              if (sourceConvertible != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Source Instrument',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DetailRow(
                        label: 'Principal',
                        value: Formatters.currency(
                          sourceConvertible!.principal,
                        ),
                      ),
                      DetailRow(
                        label: 'Issue Date',
                        value: Formatters.date(sourceConvertible!.issueDate),
                      ),
                      if (sourceConvertible!.valuationCap != null)
                        DetailRow(
                          label: 'Valuation Cap',
                          value: Formatters.currency(
                            sourceConvertible!.valuationCap!,
                          ),
                        ),
                      if (sourceConvertible!.discountPercent != null)
                        DetailRow(
                          label: 'Discount',
                          value:
                              '${(sourceConvertible!.discountPercent! * 100).toStringAsFixed(0)}%',
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (showDeleteButton && onDelete != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete!();
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildTermChangeRow(
    BuildContext context, {
    required String label,
    required String oldValue,
    required String newValue,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            oldValue,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            newValue,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
