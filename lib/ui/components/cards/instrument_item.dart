import 'package:flutter/material.dart';

/// A clickable colorful item for displaying securities/instruments.
///
/// Used in expanded cards to show holdings, options, convertibles, warrants, etc.
/// Matches the archived design pattern with:
/// - Colored icon in rounded container
/// - Title and subtitle
/// - Status badge
/// - Chevron indicating tappable
class InstrumentItem extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// Primary color for the item (affects icon container and background).
  final Color color;

  /// Primary text (e.g., "1,000 shares", "500 Options").
  final String title;

  /// Secondary text (e.g., "Common Stock @ $1.00").
  final String? subtitle;

  /// Status badge text (e.g., "Active", "75%", "Outstanding").
  final String? statusText;

  /// Status badge color override (defaults to [color]).
  final Color? statusColor;

  /// Callback when tapped.
  final VoidCallback? onTap;

  /// Whether to show the chevron indicator.
  final bool showChevron;

  const InstrumentItem({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.statusText,
    this.statusColor,
    this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor = statusColor ?? color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 10),
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (statusText != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: badgeColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                statusText!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (showChevron && onTap != null) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.outline,
                    size: 18,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Variant for holdings with share count and class info.
class HoldingItem extends StatelessWidget {
  final int shareCount;
  final int vestedCount;
  final String shareClassName;
  final double costBasis;
  final DateTime acquiredDate;
  final String? roundName;
  final bool hasVesting;
  final bool isDraft;
  final VoidCallback? onTap;

  const HoldingItem({
    super.key,
    required this.shareCount,
    required this.vestedCount,
    required this.shareClassName,
    required this.costBasis,
    required this.acquiredDate,
    this.roundName,
    this.hasVesting = false,
    this.isDraft = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFullyVested = !hasVesting || vestedCount >= shareCount;
    final vestingPercent =
        hasVesting ? ((vestedCount / shareCount) * 100).round() : 100;

    // Determine status text: draft takes priority, then vesting
    String? statusText;
    Color? statusColor;
    if (isDraft) {
      statusText = 'Draft';
      statusColor = Colors.orange;
    } else if (hasVesting) {
      statusText = '$vestingPercent%';
      statusColor = isFullyVested ? Colors.green : Colors.indigo;
    }

    return InstrumentItem(
      icon: Icons.pie_chart_outline,
      color: isFullyVested ? Colors.blue : Colors.indigo,
      title: _formatNumber(shareCount),
      subtitle: _buildSubtitle(),
      statusText: statusText,
      statusColor: statusColor,
      onTap: onTap,
    );
  }

  String _buildSubtitle() {
    final parts = <String>[shareClassName];
    if (roundName != null) parts.add(roundName!);
    parts.add('@\$${costBasis.toStringAsFixed(2)}');
    return parts.join(' • ');
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M shares';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K shares';
    return '$n shares';
  }
}

/// Variant for option grants.
class OptionItem extends StatelessWidget {
  final int quantity;
  final int exercisedCount;
  final int cancelledCount;
  final double strikePrice;
  final String shareClassName;
  final String status;
  final double? vestingPercent;
  final VoidCallback? onTap;

  const OptionItem({
    super.key,
    required this.quantity,
    required this.exercisedCount,
    required this.cancelledCount,
    required this.strikePrice,
    required this.shareClassName,
    required this.status,
    this.vestingPercent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final outstanding = quantity - exercisedCount - cancelledCount;
    final isPending = status == 'pending';
    final isActive = status == 'active' || status == 'partially_exercised';
    final color = isPending
        ? Colors.amber
        : isActive
            ? Colors.orange
            : Colors.grey;

    return InstrumentItem(
      icon: Icons.workspace_premium,
      color: color,
      title: _formatNumber(outstanding),
      subtitle: '$shareClassName @ \$${strikePrice.toStringAsFixed(2)}'
          '${vestingPercent != null ? ' • ${vestingPercent!.toStringAsFixed(0)}% vested' : ''}',
      statusText: _getStatusText(),
      statusColor: color,
      onTap: onTap,
    );
  }

  String _getStatusText() {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'active':
        return 'Active';
      case 'partially_exercised':
        return 'Partial';
      case 'fully_exercised':
        return 'Exercised';
      case 'cancelled':
        return 'Cancelled';
      case 'expired':
        return 'Expired';
      default:
        return status;
    }
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M Options';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K Options';
    return '$n Options';
  }
}

/// Variant for convertible instruments (SAFEs, notes).
class ConvertibleItem extends StatelessWidget {
  final String type;
  final double principal;
  final double? valuationCap;
  final double? discountPercent;
  final double? interestRate;
  final String status;
  final VoidCallback? onTap;

  const ConvertibleItem({
    super.key,
    required this.type,
    required this.principal,
    this.valuationCap,
    this.discountPercent,
    this.interestRate,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSafe = type.toLowerCase() == 'safe';
    final isPending = status == 'pending';
    final isOutstanding = status == 'outstanding';
    final color = isPending
        ? Colors.orange
        : isOutstanding
            ? (isSafe ? Colors.purple : Colors.teal)
            : Colors.grey;

    return InstrumentItem(
      icon: isSafe ? Icons.flash_on : Icons.description,
      color: color,
      title: '${_getTypeLabel()} • ${_formatCurrency(principal)}',
      subtitle: _buildTermsSummary(),
      statusText: _getStatusText(),
      statusColor: color,
      onTap: onTap,
    );
  }

  String _getTypeLabel() {
    switch (type.toLowerCase()) {
      case 'safe':
        return 'SAFE';
      case 'convertible_note':
        return 'Conv. Note';
      default:
        return type;
    }
  }

  String _getStatusText() {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'outstanding':
        return 'Outstanding';
      case 'converted':
        return 'Converted';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String _buildTermsSummary() {
    final parts = <String>[];
    if (valuationCap != null) {
      parts.add('Cap: ${_formatCurrency(valuationCap!)}');
    }
    if (discountPercent != null && discountPercent! > 0) {
      parts.add('${(discountPercent! * 100).toStringAsFixed(0)}% disc');
    }
    if (interestRate != null && interestRate! > 0) {
      parts.add('${(interestRate! * 100).toStringAsFixed(1)}% int');
    }
    return parts.isEmpty ? 'No terms specified' : parts.join(' • ');
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '\$${(amount / 1000).toStringAsFixed(0)}K';
    return '\$${amount.toStringAsFixed(0)}';
  }
}

/// Variant for warrants.
class WarrantItem extends StatelessWidget {
  final int quantity;
  final int exercisedCount;
  final int cancelledCount;
  final double strikePrice;
  final String? shareClassName;
  final String status;
  final DateTime expiryDate;
  final double? currentSharePrice;
  final VoidCallback? onTap;

  const WarrantItem({
    super.key,
    required this.quantity,
    required this.exercisedCount,
    required this.cancelledCount,
    required this.strikePrice,
    this.shareClassName,
    required this.status,
    required this.expiryDate,
    this.currentSharePrice,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = quantity - exercisedCount - cancelledCount;
    final isPending = status == 'pending';
    final isActive = status == 'active';
    final isInTheMoney =
        currentSharePrice != null && currentSharePrice! > strikePrice;
    final color = isPending
        ? Colors.orange
        : isActive
            ? (isInTheMoney ? Colors.green : Colors.teal)
            : Colors.grey;

    return InstrumentItem(
      icon: Icons.receipt_long,
      color: color,
      title: _formatNumber(remaining),
      subtitle:
          '${shareClassName ?? 'Unspecified'} @ \$${strikePrice.toStringAsFixed(2)}'
          '${isInTheMoney ? ' • ITM' : ''}',
      statusText: _getStatusText(),
      statusColor: color,
      onTap: onTap,
    );
  }

  String _getStatusText() {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'active':
        return 'Active';
      case 'partially_exercised':
        return 'Partial';
      case 'fully_exercised':
        return 'Exercised';
      case 'expired':
        return 'Expired';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M Warrants';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K Warrants';
    return '$n Warrants';
  }
}
