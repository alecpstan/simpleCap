import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const HoldingDetailDialog({
    super.key,
    required this.holding,
    this.shareClassName,
    this.roundName,
    this.onEdit,
    this.onDelete,
  });

  static Future<void> show({
    required BuildContext context,
    required Holding holding,
    String? shareClassName,
    String? roundName,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return showDialog(
      context: context,
      builder: (context) => HoldingDetailDialog(
        holding: holding,
        shareClassName: shareClassName,
        roundName: roundName,
        onEdit: onEdit,
        onDelete: onDelete,
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
        width: 400,
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
        if (onDelete != null)
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
  final double? currentSharePrice;
  final VoidCallback? onEdit;
  final VoidCallback? onExercise;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;

  const OptionDetailDialog({
    super.key,
    required this.option,
    this.shareClassName,
    this.stakeholderName,
    this.vestingPercent,
    this.currentSharePrice,
    this.onEdit,
    this.onExercise,
    this.onCancel,
    this.onDelete,
  });

  static Future<void> show({
    required BuildContext context,
    required OptionGrant option,
    String? shareClassName,
    String? stakeholderName,
    double? vestingPercent,
    double? currentSharePrice,
    VoidCallback? onEdit,
    VoidCallback? onExercise,
    VoidCallback? onCancel,
    VoidCallback? onDelete,
  }) {
    return showDialog(
      context: context,
      builder: (context) => OptionDetailDialog(
        option: option,
        shareClassName: shareClassName,
        stakeholderName: stakeholderName,
        vestingPercent: vestingPercent,
        currentSharePrice: currentSharePrice,
        onEdit: onEdit,
        onExercise: onExercise,
        onCancel: onCancel,
        onDelete: onDelete,
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
    final canExercise = isActive && outstanding > 0;

    return AlertDialog(
      title: const Text('Option Grant Details'),
      content: SizedBox(
        width: 400,
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
                    if (vestingPercent != null)
                      ProgressRow(
                        label: 'Vested',
                        progress: vestingPercent! / 100,
                        valueText: '${vestingPercent!.toStringAsFixed(0)}%',
                        color:
                            vestingPercent! >= 100 ? Colors.green : Colors.indigo,
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
                                color: isInTheMoney ? Colors.green : Colors.grey,
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
        if (onDelete != null)
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
        if (onCancel != null && canExercise)
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
        if (onExercise != null && canExercise)
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
  final VoidCallback? onDelete;

  const ConvertibleDetailDialog({
    super.key,
    required this.convertible,
    this.stakeholderName,
    this.onEdit,
    this.onConvert,
    this.onRevert,
    this.onDelete,
  });

  static Future<void> show({
    required BuildContext context,
    required Convertible convertible,
    String? stakeholderName,
    VoidCallback? onEdit,
    VoidCallback? onConvert,
    VoidCallback? onRevert,
    VoidCallback? onDelete,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ConvertibleDetailDialog(
        convertible: convertible,
        stakeholderName: stakeholderName,
        onEdit: onEdit,
        onConvert: onConvert,
        onRevert: onRevert,
        onDelete: onDelete,
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
        width: 400,
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
                Text(
                  convertible.notes!,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (onDelete != null)
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
          )
        else if (onConvert != null && isOutstanding)
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onConvert!();
            },
            child: const Text('Convert'),
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
  final VoidCallback? onDelete;

  const WarrantDetailDialog({
    super.key,
    required this.warrant,
    this.shareClassName,
    this.stakeholderName,
    this.currentSharePrice,
    this.onEdit,
    this.onExercise,
    this.onDelete,
  });

  static Future<void> show({
    required BuildContext context,
    required Warrant warrant,
    String? shareClassName,
    String? stakeholderName,
    double? currentSharePrice,
    VoidCallback? onEdit,
    VoidCallback? onExercise,
    VoidCallback? onDelete,
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
        onDelete: onDelete,
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
        width: 400,
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
                                color: isInTheMoney ? Colors.green : Colors.grey,
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
        if (onDelete != null)
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
        if (onExercise != null && canExercise)
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
