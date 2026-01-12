import 'package:flutter/material.dart';

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
