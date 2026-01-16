import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Service to load and cache help content from JSON
class HelpContentService {
  static HelpContentService? _instance;
  static HelpContentService get instance =>
      _instance ??= HelpContentService._();

  HelpContentService._();

  Map<String, dynamic>? _content;
  bool _isLoading = false;

  /// Load help content from assets
  Future<void> load() async {
    if (_content != null || _isLoading) return;

    _isLoading = true;
    try {
      final jsonString = await rootBundle.loadString(
        'assets/help_content.json',
      );
      _content = json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Failed to load help content: $e');
      _content = {};
    }
    _isLoading = false;
  }

  /// Get help content for a specific key (e.g., "general.valuation")
  HelpContent? getContent(String key) {
    if (_content == null) return null;

    final parts = key.split('.');
    if (parts.length != 2) return null;

    final category = _content![parts[0]] as Map<String, dynamic>?;
    if (category == null) return null;

    final item = category[parts[1]] as Map<String, dynamic>?;
    if (item == null) return null;

    return HelpContent(
      title: item['title'] as String? ?? '',
      description: item['description'] as String? ?? '',
    );
  }
}

/// Help content data class
class HelpContent {
  final String title;
  final String description;

  const HelpContent({required this.title, required this.description});
}

/// A small info icon that shows help content when tapped
class HelpIcon extends StatelessWidget {
  /// The help content key (e.g., "general.valuation", "vesting.cliff")
  final String helpKey;

  /// Optional custom size (default 16)
  final double size;

  /// Optional custom color (default pale grey)
  final Color? color;

  const HelpIcon({
    super.key,
    required this.helpKey,
    this.size = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showHelpDialog(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(
          Icons.info_outline,
          size: size,
          color: color ?? Colors.grey.shade400,
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    final content = HelpContentService.instance.getContent(helpKey);

    if (content == null) {
      debugPrint('Help content not found for key: $helpKey');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.help_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(content.title)),
          ],
        ),
        content: Text(
          content.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

/// A row label with an optional help icon
class LabelWithHelp extends StatelessWidget {
  final String label;
  final String? helpKey;
  final TextStyle? style;

  const LabelWithHelp({
    super.key,
    required this.label,
    this.helpKey,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: style),
        if (helpKey != null) HelpIcon(helpKey: helpKey!),
      ],
    );
  }
}

/// A TextField with an optional help icon in the decoration
class TextFieldWithHelp extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helpKey;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final int? maxLines;

  const TextFieldWithHelp({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helpKey,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      enabled: enabled,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (helpKey != null) HelpIcon(helpKey: helpKey!),
            if (suffixIcon != null) suffixIcon!,
          ],
        ),
      ),
    );
  }
}

/// Extension to easily add help icons to widgets
extension HelpIconExtension on Widget {
  Widget withHelp(String helpKey) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        this,
        HelpIcon(helpKey: helpKey),
      ],
    );
  }
}
