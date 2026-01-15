import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction.dart';
import '../models/investment_round.dart';
import '../providers/core_cap_table_provider.dart';
import '../../../shared/widgets/avatars.dart';
import '../../../shared/widgets/dialogs.dart';
import '../../../shared/widgets/help_icon.dart';

/// Result type for investment dialog
enum InvestmentDialogAction { saved, deleted, cancelled }

/// Wrapper for investment dialog result
class InvestmentDialogResult {
  final InvestmentDialogAction action;
  final Transaction? transaction;

  InvestmentDialogResult.saved(this.transaction)
    : action = InvestmentDialogAction.saved;
  InvestmentDialogResult.deleted()
    : action = InvestmentDialogAction.deleted,
      transaction = null;
  InvestmentDialogResult.cancelled()
    : action = InvestmentDialogAction.cancelled,
      transaction = null;
}

/// Shows a dialog for adding or editing an investment (purchase transaction).
/// Returns an InvestmentDialogResult indicating the action taken.
Future<InvestmentDialogResult> showInvestmentDialog({
  required BuildContext context,
  required CoreCapTableProvider provider,
  required InvestmentRound round,
  Transaction? existingTransaction,
}) async {
  final isEditing = existingTransaction != null;

  // For editing, we lock the investor
  final existingInvestor = isEditing
      ? provider.getInvestorById(existingTransaction.investorId)
      : null;

  // Check if we have investors to add
  if (!isEditing && provider.investors.isEmpty) {
    showInfoSnackbar(context, 'Add investors first before adding them to a round');
    return InvestmentDialogResult.cancelled();
  }

  String? selectedInvestorId =
      existingTransaction?.investorId ?? provider.investors.first.id;
  String? selectedShareClassId =
      existingTransaction?.shareClassId ??
      (provider.shareClasses.isNotEmpty
          ? provider.shareClasses.first.id
          : null);

  // Calculate default price per share:
  // 1. Use existing transaction price if editing
  // 2. Use round's explicit price per share if set
  // 3. Calculate from pre-money valuation / issued shares
  // 4. Fall back to 1.0
  String? priceSource;
  String getDefaultPrice() {
    if (existingTransaction != null) {
      return existingTransaction.pricePerShare.toString();
    }
    if (round.pricePerShare != null) {
      priceSource = 'From round settings';
      return round.pricePerShare.toString();
    }
    final impliedPrice = provider.getImpliedPricePerShare(round.id);
    if (impliedPrice != null && impliedPrice > 0) {
      priceSource = 'Calculated from pre-money valuation';
      return impliedPrice.toStringAsFixed(4);
    }
    return '1.0';
  }

  final sharesController = TextEditingController(
    text: existingTransaction?.numberOfShares.toString() ?? '',
  );
  final priceController = TextEditingController(text: getDefaultPrice());
  final amountController = TextEditingController(
    text: existingTransaction?.totalAmount.toStringAsFixed(2) ?? '',
  );

  // Check if this transaction has vesting
  final int vestedShares = existingTransaction != null
      ? provider.getVestedShares(existingTransaction.id)
      : 0;
  final bool hasVesting =
      existingTransaction != null &&
      (provider.vestingSchedules.any(
            (v) => v.transactionId == existingTransaction.id,
          ) ||
          provider.hoursVestingSchedules.any(
            (v) => v.transactionId == existingTransaction.id,
          ));
  String? sharesError;

  void recalculateFromSharesAndPrice() {
    final shares = int.tryParse(sharesController.text) ?? 0;
    final price = double.tryParse(priceController.text) ?? 0;
    amountController.text = (shares * price).toStringAsFixed(2);
  }

  void recalculateFromSharesAndAmount() {
    final shares = int.tryParse(sharesController.text) ?? 0;
    final amount = double.tryParse(amountController.text) ?? 0;
    if (shares > 0) {
      priceController.text = (amount / shares).toStringAsFixed(4);
    }
  }

  final result = await showDialog<String>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(
          isEditing
              ? 'Edit ${existingInvestor?.name ?? "Investment"}'
              : 'Add Investor to ${round.name}',
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width > 600
                ? 500
                : double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Investor selection (or display if editing)
                if (isEditing) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: InvestorAvatar(
                      name: existingInvestor?.name ?? '?',
                      type: existingInvestor?.type,
                    ),
                    title: Text(existingInvestor?.name ?? 'Unknown'),
                    subtitle: Text('Round: ${round.name}'),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                ] else ...[
                  DropdownButtonFormField<String>(
                    initialValue: selectedInvestorId,
                    decoration: const InputDecoration(
                      labelText: 'Investor',
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: provider.investors.map((investor) {
                      return DropdownMenuItem(
                        value: investor.id,
                        child: Text(investor.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedInvestorId = value);
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Share class selection
                DropdownButtonFormField<String>(
                  initialValue: selectedShareClassId,
                  decoration: InputDecoration(
                    labelText: 'Share Class',
                    prefixIcon: const Icon(Icons.category),
                    suffixIcon: const HelpIcon(
                      helpKey: 'shareClasses.shareClass',
                    ),
                  ),
                  items: provider.shareClasses.map((shareClass) {
                    return DropdownMenuItem(
                      value: shareClass.id,
                      child: Text(shareClass.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedShareClassId = value);
                  },
                ),
                const SizedBox(height: 16),

                // Number of shares
                TextField(
                  controller: sharesController,
                  decoration: InputDecoration(
                    labelText: 'Number of Shares *',
                    hintText: '100000',
                    prefixIcon: const Icon(Icons.pie_chart),
                    suffixIcon: const HelpIcon(
                      helpKey: 'fields.numberOfShares',
                    ),
                    helperText: hasVesting && vestedShares > 0
                        ? 'Minimum: $vestedShares (already vested)'
                        : null,
                    errorText: sharesError,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    // Validate against vested shares
                    final shares = int.tryParse(value) ?? 0;
                    setState(() {
                      if (hasVesting && shares < vestedShares) {
                        sharesError =
                            'Cannot reduce below $vestedShares vested shares';
                      } else {
                        sharesError = null;
                      }
                    });
                    // When shares change, recalculate total from shares × price
                    recalculateFromSharesAndPrice();
                  },
                ),
                const SizedBox(height: 16),

                // Price per share
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: 'Price Per Share (AUD)',
                    hintText: '1.00',
                    prefixIcon: const Icon(Icons.monetization_on),
                    helperText: priceSource,
                    suffixIcon: const HelpIcon(helpKey: 'rounds.pricePerShare'),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (value) {
                    // When price changes, recalculate total from shares × price
                    recalculateFromSharesAndPrice();
                  },
                ),
                const SizedBox(height: 16),

                // Total investment
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Total Investment (AUD)',
                    hintText: '100000',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (value) {
                    // When total changes, recalculate price from total ÷ shares
                    recalculateFromSharesAndAmount();
                  },
                ),

                const SizedBox(height: 8),
                Text(
                  'Tip: Edit shares & price to calculate total, or edit total to calculate price per share',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          if (isEditing)
            TextButton.icon(
              onPressed: () async {
                final confirmed = await showConfirmDialog(
                  context: context,
                  title: 'Remove from Round',
                  message:
                      'Remove ${existingInvestor?.name ?? "this investor"} from this round? This will delete their investment.',
                );
                if (confirmed && context.mounted) {
                  Navigator.pop(context, 'delete');
                }
              },
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child: Text(isEditing ? 'Save' : 'Add'),
          ),
        ],
      ),
    ),
  );

  if (result == 'delete') {
    return InvestmentDialogResult.deleted();
  }

  if (result == 'save' &&
      selectedInvestorId != null &&
      selectedShareClassId != null &&
      sharesController.text.isNotEmpty) {
    final numberOfShares = int.parse(sharesController.text);

    // Validate against vested shares
    if (hasVesting && numberOfShares < vestedShares) {
      return InvestmentDialogResult.cancelled();
    }

    final pricePerShare = double.tryParse(priceController.text) ?? 1.0;
    final totalAmount =
        double.tryParse(amountController.text) ??
        (numberOfShares * pricePerShare);

    if (isEditing) {
      return InvestmentDialogResult.saved(
        existingTransaction.copyWith(
          shareClassId: selectedShareClassId,
          numberOfShares: numberOfShares,
          pricePerShare: pricePerShare,
          totalAmount: totalAmount,
        ),
      );
    } else {
      return InvestmentDialogResult.saved(
        Transaction(
          investorId: selectedInvestorId!,
          shareClassId: selectedShareClassId!,
          roundId: round.id,
          type: TransactionType.purchase,
          numberOfShares: numberOfShares,
          pricePerShare: pricePerShare,
          totalAmount: totalAmount,
          date: round.date,
        ),
      );
    }
  }

  return InvestmentDialogResult.cancelled();
}
