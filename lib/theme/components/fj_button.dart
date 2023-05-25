import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';

class FJElevatedButton extends StatelessWidget {

  final Function() onTap;
  final Widget child;
  final bool shadow;
  final bool smallCorners;

  const FJElevatedButton({super.key, required this.onTap, required this.child, this.shadow = false, this.smallCorners = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(defaultSpacing * (smallCorners ? 1.0 : 1.5)),
        topRight: Radius.circular(defaultSpacing * (smallCorners ? 1.0 : 1.5)),
      ),
      elevation: shadow ? 5.0 : 0.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(defaultSpacing * 1.5),
          topRight: Radius.circular(defaultSpacing * 1.5),
        ),
        splashColor: Theme.of(context).hoverColor.withAlpha(20),
        child: Padding(
          padding: const EdgeInsets.all(defaultSpacing),
          child: child,
        ),
      ),
    );
  }
}