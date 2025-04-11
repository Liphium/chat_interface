import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class FJElevatedButton extends StatelessWidget {
  final Function() onTap;
  final Widget child;
  final bool shadow;
  final bool smallCorners;
  final bool secondary;
  final Color? color;

  const FJElevatedButton({
    super.key,
    required this.onTap,
    required this.child,
    this.shadow = false,
    this.secondary = false,
    this.smallCorners = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Get.theme.colorScheme.primary,
      borderRadius: BorderRadius.circular(defaultSpacing * (smallCorners ? 1.0 : 1.5)),
      elevation: shadow ? 5.0 : 0.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(defaultSpacing * (smallCorners ? 1.0 : 1.5)),
        splashColor: Get.theme.hoverColor.withAlpha(20),
        child: Padding(padding: const EdgeInsets.all(defaultSpacing), child: child),
      ),
    );
  }
}

class FJElevatedLoadingButton extends StatelessWidget {
  final Function() onTap;
  final String label;
  final ReadonlySignal<bool>? loading;

  const FJElevatedLoadingButton({super.key, required this.onTap, required this.label, this.loading});

  @override
  Widget build(BuildContext context) {
    return FJElevatedButton(
      onTap: () => (loading?.value ?? false) ? null : onTap(),
      child: Center(
        child: Builder(
          builder: (context) {
            // Don't care about state in case there is no loading state
            if (loading == null) {
              return Text(label, style: Get.theme.textTheme.labelLarge);
            }

            // Handle loading states as well
            return Watch(
              (ctx) =>
                  loading!.value
                      ? SizedBox(
                        height: Get.theme.textTheme.labelLarge!.fontSize! + defaultSpacing,
                        width: Get.theme.textTheme.labelLarge!.fontSize! + defaultSpacing,
                        child: Padding(
                          padding: const EdgeInsets.all(defaultSpacing * 0.25),
                          child: CircularProgressIndicator(strokeWidth: 3.0, color: Get.theme.colorScheme.onPrimary),
                        ),
                      )
                      : Text(label, style: Get.theme.textTheme.labelLarge),
            );
          },
        ),
      ),
    );
  }
}

class FJElevatedLoadingButtonCustom extends StatelessWidget {
  final Function() onTap;
  final Widget Function()? builder;
  final Widget child;
  final Signal<bool> loading;

  const FJElevatedLoadingButtonCustom({super.key, required this.onTap, required this.child, required this.loading, this.builder});

  @override
  Widget build(BuildContext context) {
    return FJElevatedButton(
      onTap: () => loading.value ? null : onTap(),
      child: Watch(
        (ctx) =>
            loading.value
                ? builder?.call() ??
                    SizedBox(
                      height: Get.theme.textTheme.labelLarge!.fontSize! + defaultSpacing,
                      width: Get.theme.textTheme.labelLarge!.fontSize! + defaultSpacing,
                      child: Padding(
                        padding: const EdgeInsets.all(defaultSpacing * 0.25),
                        child: CircularProgressIndicator(strokeWidth: 3.0, color: Get.theme.colorScheme.onPrimary),
                      ),
                    )
                : child,
      ),
    );
  }
}
