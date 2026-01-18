import 'package:flutter/material.dart';

/// A confirmation dialog with consistent styling.
///
/// Use for destructive actions or important confirmations.
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final VoidCallback? onConfirm;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDestructive = false,
    this.onConfirm,
  });

  /// Shows the dialog and returns true if confirmed.
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
      ),
    );
    return result ?? false;
  }

  /// Convenience for delete confirmations.
  static Future<bool> showDelete({
    required BuildContext context,
    required String itemName,
    String? additionalMessage,
    String? customMessage,
  }) {
    return show(
      context: context,
      title: 'Delete $itemName?',
      message:
          customMessage ??
          additionalMessage ??
          'This action cannot be undone. Are you sure you want to delete this $itemName?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
  }

  /// Convenience for discard changes confirmation.
  static Future<bool> showDiscard({required BuildContext context}) {
    return show(
      context: context,
      title: 'Discard changes?',
      message:
          'You have unsaved changes. Are you sure you want to discard them?',
      confirmLabel: 'Discard',
      isDestructive: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        if (isDestructive)
          TextButton(
            onPressed: () {
              onConfirm?.call();
              Navigator.of(context).pop(true);
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: Text(confirmLabel),
          )
        else
          FilledButton(
            onPressed: () {
              onConfirm?.call();
              Navigator.of(context).pop(true);
            },
            child: Text(confirmLabel),
          ),
      ],
    );
  }
}

/// Standard action buttons for dialogs.
class DialogButtons extends StatelessWidget {
  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final bool isLoading;
  final bool confirmEnabled;

  const DialogButtons({
    super.key,
    this.cancelLabel = 'Cancel',
    this.confirmLabel = 'Save',
    this.onCancel,
    this.onConfirm,
    this.isLoading = false,
    this.confirmEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: isLoading
              ? null
              : (onCancel ?? () => Navigator.pop(context)),
          child: Text(cancelLabel),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: isLoading || !confirmEnabled ? null : onConfirm,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(confirmLabel),
        ),
      ],
    );
  }
}

/// A full-screen dialog for complex forms.
class FormDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final VoidCallback? onClose;

  const FormDialog({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.onClose,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    List<Widget>? actions,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          FormDialog(title: title, actions: actions, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose ?? () => Navigator.of(context).pop(),
          ),
          actions: actions,
        ),
        body: child,
      ),
    );
  }
}

/// A bottom sheet with consistent styling.
class AppBottomSheet extends StatelessWidget {
  final String? title;
  final Widget child;
  final bool showHandle;
  final double? maxHeight;

  const AppBottomSheet({
    super.key,
    this.title,
    required this.child,
    this.showHandle = true,
    this.maxHeight,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget child,
    bool showHandle = true,
    double? maxHeight,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (context) => AppBottomSheet(
        title: title,
        showHandle: showHandle,
        maxHeight: maxHeight,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? mediaQuery.size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHandle)
            Container(
              width: 32,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(title!, style: theme.textTheme.titleLarge),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: mediaQuery.viewInsets.bottom + 16,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
