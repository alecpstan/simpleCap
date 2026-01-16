import 'package:flutter/material.dart';

/// An avatar for displaying entities (stakeholders, companies, etc.).
///
/// Shows initials with a colored background, or an icon.
class EntityAvatar extends StatelessWidget {
  /// The name to extract initials from.
  final String? name;

  /// An explicit icon to show instead of initials.
  final IconData? icon;

  /// An image URL to display.
  final String? imageUrl;

  /// Size of the avatar (default 40).
  final double size;

  /// Background color (auto-generated from name if null).
  final Color? backgroundColor;

  /// Foreground color for text/icon.
  final Color? foregroundColor;

  /// The type of entity for default styling.
  final EntityAvatarType type;

  const EntityAvatar({
    super.key,
    this.name,
    this.icon,
    this.imageUrl,
    this.size = 40,
    this.backgroundColor,
    this.foregroundColor,
    this.type = EntityAvatarType.person,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? _getBackgroundColor(theme);
    final fgColor = foregroundColor ?? _getForegroundColor(bgColor);

    // Image avatar
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(imageUrl!),
        onBackgroundImageError: (error, stackTrace) {},
        backgroundColor: bgColor,
        child: null,
      );
    }

    // Icon avatar
    if (icon != null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: bgColor,
        child: Icon(icon, color: fgColor, size: size * 0.5),
      );
    }

    // Initials avatar
    final initials = _getInitials();
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: bgColor,
      child: Text(
        initials,
        style: TextStyle(
          color: fgColor,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.35,
        ),
      ),
    );
  }

  String _getInitials() {
    if (name == null || name!.isEmpty) {
      return _getDefaultInitials();
    }

    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts.first.isNotEmpty) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return _getDefaultInitials();
  }

  String _getDefaultInitials() {
    switch (type) {
      case EntityAvatarType.person:
        return 'U';
      case EntityAvatarType.company:
        return 'C';
      case EntityAvatarType.round:
        return 'R';
      case EntityAvatarType.shareClass:
        return 'S';
      case EntityAvatarType.option:
        return 'O';
    }
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (name == null || name!.isEmpty) {
      return theme.colorScheme.primaryContainer;
    }

    // Generate a consistent color from the name
    final hash = name!.hashCode;
    final hue = (hash % 360).abs().toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.5, 0.8).toColor();
  }

  Color _getForegroundColor(Color background) {
    // Calculate luminance and return appropriate text color
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  /// Creates an avatar for a founder.
  factory EntityAvatar.founder({
    Key? key,
    required String name,
    double size = 40,
  }) {
    return EntityAvatar(
      key: key,
      name: name,
      size: size,
      type: EntityAvatarType.person,
      backgroundColor: Colors.indigo.shade100,
    );
  }

  /// Creates an avatar for an employee.
  factory EntityAvatar.employee({
    Key? key,
    required String name,
    double size = 40,
  }) {
    return EntityAvatar(
      key: key,
      name: name,
      size: size,
      type: EntityAvatarType.person,
      backgroundColor: Colors.teal.shade100,
    );
  }

  /// Creates an avatar for an investor.
  factory EntityAvatar.investor({
    Key? key,
    required String name,
    double size = 40,
  }) {
    return EntityAvatar(
      key: key,
      name: name,
      size: size,
      type: EntityAvatarType.person,
      backgroundColor: Colors.green.shade100,
    );
  }

  /// Creates an avatar for a company/entity.
  factory EntityAvatar.company({
    Key? key,
    required String name,
    double size = 40,
  }) {
    return EntityAvatar(
      key: key,
      name: name,
      icon: Icons.business,
      size: size,
      type: EntityAvatarType.company,
      backgroundColor: Colors.blue.shade100,
    );
  }
}

/// Types of entities for default avatar styling.
enum EntityAvatarType { person, company, round, shareClass, option }

/// A small avatar group showing multiple avatars overlapping.
class AvatarGroup extends StatelessWidget {
  final List<EntityAvatar> avatars;
  final int maxVisible;
  final double size;
  final double overlap;

  const AvatarGroup({
    super.key,
    required this.avatars,
    this.maxVisible = 3,
    this.size = 32,
    this.overlap = 8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visible = avatars.take(maxVisible).toList();
    final extra = avatars.length - maxVisible;

    return SizedBox(
      height: size,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...visible.asMap().entries.map((entry) {
            return Transform.translate(
              offset: Offset(-entry.key * overlap, 0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: EntityAvatar(
                  name: entry.value.name,
                  icon: entry.value.icon,
                  imageUrl: entry.value.imageUrl,
                  size: size,
                  type: entry.value.type,
                ),
              ),
            );
          }),
          if (extra > 0)
            Transform.translate(
              offset: Offset(-visible.length * overlap, 0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: size / 2,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  child: Text(
                    '+$extra',
                    style: TextStyle(
                      fontSize: size * 0.35,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
