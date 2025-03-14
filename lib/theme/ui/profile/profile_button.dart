import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../../util/vertical_spacing.dart';

class ProfileButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Function() onTap;
  final Color? color;
  final Color? iconColor;
  final Signal<bool>? loading;

  const ProfileButton({super.key, required this.icon, required this.label, required this.onTap, this.loading, this.color, this.iconColor});

  @override
  State<ProfileButton> createState() => _ProfileButtonState();
}

class _ProfileButtonState extends State<ProfileButton> with SignalsMixin {
  late final Signal<bool> _loading;

  @override
  void initState() {
    _loading = widget.loading ?? createSignal(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Color backgroundColor = (widget.color ?? theme.colorScheme.primary).withAlpha(150);

    return Material(
      borderRadius: BorderRadius.circular(defaultSpacing),
      color: theme.colorScheme.inverseSurface,
      child: InkWell(
        borderRadius: BorderRadius.circular(defaultSpacing),
        hoverColor: backgroundColor,

        //* Button
        onTap: () => _loading.value ? null : widget.onTap(),

        //* Button content
        child: Padding(
          padding: const EdgeInsets.all(defaultSpacing),
          child: Row(
            children: [
              //* Loading indicator
              Watch((ctx) => _loading.value
                  ? SizedBox(
                      width: 25,
                      height: 25,
                      child: Padding(
                        padding: const EdgeInsets.all(defaultSpacing * 0.25),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: widget.iconColor ?? theme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Icon(widget.icon, size: 25, color: widget.iconColor ?? theme.colorScheme.onPrimary)),

              //* Label
              horizontalSpacing(defaultSpacing),
              Flexible(
                child: Text(
                  widget.label,
                  style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.onSurface),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
