import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class LoadingIconButton extends StatelessWidget {
  final Signal<bool>? loading;
  final IconData icon;
  final Color? color;
  final String? tooltip;
  final double iconSize;
  final double extra;
  final double padding;
  final bool background;
  final Color? backgroundColor;
  final Function() onTap;
  final Function()? onSecondaryTap;
  final Function(BuildContext)? onTapContext;

  const LoadingIconButton({
    super.key,
    this.loading,
    required this.onTap,
    this.onSecondaryTap,
    this.tooltip,
    this.onTapContext,
    required this.icon,
    this.color,
    this.extra = 17,
    this.iconSize = 23,
    this.padding = 0,
    this.background = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? "",
      child: SizedBox(
        width: iconSize + extra + padding,
        height: iconSize + extra + padding,
        child: Material(
          borderRadius: BorderRadius.circular(50),
          color: background ? backgroundColor ?? Get.theme.colorScheme.primaryContainer : Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () {
              if (loading != null) {
                if (loading!.value) {
                  return;
                }
              }

              onTap();
              if (onTapContext != null) {
                onTapContext!(context);
              }
            },
            onSecondaryTap: () {
              if (loading != null) {
                if (loading!.value) {
                  return;
                }
              }

              onSecondaryTap?.call();
            },
            hoverColor: Get.theme.hoverColor,
            child: Padding(
              padding: EdgeInsets.all(padding),
              child:
                  loading != null
                      ? Watch(
                        (ctx) =>
                            loading!.value
                                ? Padding(
                                  padding: const EdgeInsets.all(defaultSpacing),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3.0,
                                    color: Get.theme.colorScheme.onPrimary,
                                  ),
                                )
                                : Icon(icon, color: color ?? Colors.white, size: iconSize),
                      )
                      : Icon(icon, color: color ?? Colors.white, size: iconSize),
            ),
          ),
        ),
      ),
    );
  }
}
