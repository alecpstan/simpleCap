import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/shareholding.dart';
import '../models/investment_round.dart';
import '../providers/cap_table_provider.dart';
import 'avatars.dart';

/// Shows a dialog for adding or editing a shareholding.
/// Returns the created/updated Shareholding or null if cancelled.
Future<Shareholding?> showShareholdingDialog({
  required BuildContext context,
  required CapTableProvider provider,
  required InvestmentRound round,
  Shareholding? existingShareholding,
}) async {
  final isEditing = existingShareholding != null;

  // For editing, we lock the investor
  final existingInvestor = isEditing
      ? provider.getInvestorById(existingShareholding.investorId)
      : null;

  // Check if we have investors to add
  if (!isEditing && provider.investors.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add investors first before adding them to a round'),
      ),
    );
    return null;
  }

  String? selectedInvestorId =
      existingShareholding?.investorId ?? provider.investors.first.id;
  String? selectedShareClassId =
      existingShareholding?.shareClassId ??
      (provider.shareClasses.isNotEmpty
          ? provider.shareClasses.first.id
          : null);

  final sharesController = TextEditingController(
    text: existingShareholding?.numberOfShares.toString() ?? '',
  );
  final priceController = TextEditingController(
    text:
        existingShareholding?.pricePerShare.toString() ??
        round.pricePerShare?.toString() ??
        '1.0',
  );
  final amountController = TextEditingController(
    text: existingShareholding?.amountInvested.toStringAsFixed(2) ?? '',
  );

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

  final result = await showDialog<bool>(
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
                  decoration: const InputDecoration(
                    labelText: 'Share Class',
                    prefixIcon: Icon(Icons.category),
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
                  decoration: const InputDecoration(
                    labelText: 'Number of Shares *',
                    hintText: '100000',
                    prefixIcon: Icon(Icons.pie_chart),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    // When shares change, recalculate total from shares × price
                    recalculateFromSharesAndPrice();
                  },
                ),
                const SizedBox(height: 16),

                // Price per share
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price Per Share (AUD)',
                    hintText: '1.00',
                    prefixIcon: Icon(Icons.monetization_on),
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(isEditing ? 'Save' : 'Add'),
          ),
        ],
      ),
    ),
  );

  if (result == true &&
      selectedInvestorId != null &&
      selectedShareClassId != null &&
      sharesController.text.isNotEmpty) {
    final numberOfShares = int.parse(sharesController.text);
    final pricePerShare = double.tryParse(priceController.text) ?? 1.0;
    final amountInvested =
        double.tryParse(amountController.text) ??
        (numberOfShares * pricePerShare);

    if (isEditing) {
      return existingShareholding.copyWith(
        shareClassId: selectedShareClassId,
        numberOfShares: numberOfShares,
        pricePerShare: pricePerShare,
        amountInvested: amountInvested,
      );
    } else {
      return Shareholding(
        investorId: selectedInvestorId!,
        shareClassId: selectedShareClassId!,
        roundId: round.id,
        numberOfShares: numberOfShares,
        pricePerShare: pricePerShare,
        amountInvested: amountInvested,
        dateAcquired: round.date,
      );
    }
  }

  return null;
}
