import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../util/vertical_spacing.dart';

class ProfileButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Function() onTap;
  final Color? color;
  final Color? iconColor;
  final RxBool loading;

  const ProfileButton({super.key, required this.icon, required this.label, required this.onTap, required this.loading, this.color, this.iconColor});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Color backgroundColor = (color ?? theme.colorScheme.primary).withAlpha(150);

    return Material(
      borderRadius: BorderRadius.circular(defaultSpacing),
      color: theme.colorScheme.inverseSurface,
      child: InkWell(
        borderRadius: BorderRadius.circular(defaultSpacing),
        hoverColor: backgroundColor,

        //* Button
        onTap: () => loading.value ? null : onTap(),

        //* Button content
        child: Padding(
          padding: const EdgeInsets.all(defaultSpacing),
          child: Row(
            children: [
              //* Loading indicator
              Obx(() => loading.value
                  ? SizedBox(
                      width: 25,
                      height: 25,
                      child: Padding(
                        padding: const EdgeInsets.all(defaultSpacing * 0.25),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: iconColor ?? theme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Icon(icon, size: 25, color: iconColor ?? theme.colorScheme.onPrimary)),

              //* Label
              horizontalSpacing(defaultSpacing),
              Text(label, style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.onSurface))
            ],
          ),
        ),
      ),
    );
  }
}
