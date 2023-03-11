import 'package:flutter/material.dart';

import '../../../util/vertical_spacing.dart';

class ProfileButton extends StatelessWidget {

  final IconData icon;
  final String label;
  final Function() onTap;
  final Color? color;
  final Color? iconColor;

  const ProfileButton({super.key, required this.icon, required this.label, required this.onTap, this.color, this.iconColor});

  @override
  Widget build(BuildContext context) {
    
    ThemeData theme = Theme.of(context);
    Color backgroundColor = color ?? theme.colorScheme.secondaryContainer.withAlpha(100);

    return Material(
      borderRadius: BorderRadius.circular(defaultSpacing),
      child: InkWell(
        borderRadius: BorderRadius.circular(defaultSpacing),
        hoverColor: backgroundColor,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(defaultSpacing),
          child: Row(
            children: [
              Icon(icon, size: 25, color: iconColor ?? theme.colorScheme.primary),
              horizontalSpacing(defaultSpacing),
              Text(label, style: theme.textTheme.bodyMedium)
            ],
          ),
        ),
      ),
    );
  }
}