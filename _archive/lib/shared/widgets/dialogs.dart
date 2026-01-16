import 'package:flutter/material.dart';

// =============================================================================
// SHARED BUTTON WIDGETS
// =============================================================================

/// Standard cancel button for dialogs
class DialogCancelButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;

  const DialogCancelButton({
    super.key,
    this.onPressed,
    this.label = 'Cancel',
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed ?? () => Navigator.pop(context),
      child: Text(label),
    );
  }
}

/// Standard primary action button for dialogs (save, create, etc.)
class DialogPrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;

  const DialogPrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
      );
    }
    return FilledButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

/// Standard delete/destructive button for dialogs
class DialogDeleteButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;

  const DialogDeleteButton({
    super.key,
    required this.onPressed,
    this.label = 'Delete',
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(foregroundColor: Colors.red),
      child: Text(label),
    );
  }
}

/// Standard warning/undo action button (orange colored)
class DialogWarningButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;

  const DialogWarningButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(backgroundColor: Colors.orange),
        icon: Icon(icon, size: 18),
        label: Text(label),
      );
    }
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(backgroundColor: Colors.orange),
      child: Text(label),
    );
  }
}

// =============================================================================
// SNACKBAR HELPERS
// =============================================================================

/// Shows a success snackbar with green background
void showSuccessSnackbar(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// Shows an error snackbar with red background
void showErrorSnackbar(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// Shows an info snackbar with default styling
void showInfoSnackbar(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

// =============================================================================
// DIALOG HELPERS
// =============================================================================

/// Shows a confirmation dialog and returns true if confirmed
Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String cancelText = 'Cancel',
  String confirmText = 'Delete',
  bool isDestructive = true,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: isDestructive
              ? FilledButton.styleFrom(backgroundColor: Colors.red)
              : null,
          child: Text(confirmText),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// Shows a text input dialog and returns the entered text
Future<String?> showTextInputDialog({
  required BuildContext context,
  required String title,
  String? initialValue,
  String? labelText,
  String? hintText,
  String cancelText = 'Cancel',
  String confirmText = 'Save',
}) async {
  final controller = TextEditingController(text: initialValue);

  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: labelText, hintText: hintText),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(cancelText),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: Text(confirmText),
        ),
      ],
    ),
  );

  return result;
}
