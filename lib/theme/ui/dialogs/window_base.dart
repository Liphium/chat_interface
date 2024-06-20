import 'dart:math' as math;

import 'package:chat_interface/theme/components/icon_button.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class WindowBase extends StatelessWidget {
  final Offset position;
  final Widget child;

  const WindowBase({super.key, required this.position, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: position.dx,
          top: position.dy,
          child: child,
        ),
      ],
    );
  }
}

class DialogBase extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final bool showTitleDesktop;
  final List<Widget> title;

  const DialogBase({
    super.key,
    required this.child,
    this.maxWidth = 400,
    this.title = const [],
    this.showTitleDesktop = true,
  });

  @override
  Widget build(BuildContext context) {
    // Return without animation on mobile
    if (isMobileMode()) {
      return Material(
        color: Get.theme.colorScheme.onInverseSurface,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(defaultSpacing),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(elementSpacing),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        LoadingIconButton(
                          onTap: () => Get.back(),
                          color: Get.theme.colorScheme.onPrimary,
                          padding: 0,
                          iconSize: Get.theme.textTheme.labelLarge!.fontSize! * 1.5,
                          extra: defaultSpacing,
                          icon: Icons.arrow_back,
                        ),
                        horizontalSpacing(defaultSpacing),
                        ...title,
                      ],
                    ),
                  ),
                  verticalSpacing(defaultSpacing),
                  child,
                ],
              ),
            ),
          ),
        ),
      );
    }

    final random = math.Random();
    final randomOffset = random.nextDouble() * 5 + 8;
    final randomHz = random.nextDouble() * 0.5 + 2;

    return Center(
      child: Animate(
        effects: [
          ScaleEffect(
            delay: 100.ms,
            duration: 500.ms,
            begin: const Offset(0, 0),
            end: const Offset(1, 1),
            alignment: Alignment.center,
            curve: const ElasticOutCurve(0.8),
          ),
          ShakeEffect(
            delay: 100.ms,
            duration: 400.ms,
            hz: randomHz,
            offset: Offset(random.nextBool() ? randomOffset : -randomOffset, random.nextBool() ? randomOffset : -randomOffset),
            rotation: 0,
            curve: Curves.decelerate,
          ),
          FadeEffect(
            delay: 100.ms,
            duration: 250.ms,
            curve: Curves.easeOut,
          )
        ],
        target: 1,
        child: Material(
          elevation: 2.0,
          color: Get.theme.colorScheme.onInverseSurface,
          borderRadius: BorderRadius.circular(dialogBorderRadius),
          child: Container(
            width: maxWidth,
            padding: const EdgeInsets.all(dialogPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showTitleDesktop && title.isNotEmpty)
                  Row(
                    children: [
                      ...title,
                    ],
                  ),
                if (showTitleDesktop && title.isNotEmpty) verticalSpacing(defaultSpacing),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SlidingWindowBase extends StatelessWidget {
  final ContextMenuData position;
  final bool lessPadding;
  final Widget child;
  final List<Widget> title;
  final double maxSize;

  const SlidingWindowBase({
    super.key,
    required this.title,
    required this.position,
    this.lessPadding = false,
    required this.child,
    this.maxSize = 350,
  });

  @override
  Widget build(BuildContext context) {
    // Return without animation on mobile
    if (isMobileMode()) {
      return Material(
        color: Get.theme.colorScheme.onInverseSurface,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(defaultSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(elementSpacing),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      LoadingIconButton(
                        onTap: () => Get.back(),
                        color: Get.theme.colorScheme.onPrimary,
                        padding: 0,
                        iconSize: Get.theme.textTheme.labelLarge!.fontSize! * 1.5,
                        extra: defaultSpacing,
                        icon: Icons.arrow_back,
                      ),
                      horizontalSpacing(defaultSpacing),
                      ...title,
                    ],
                  ),
                ),
                verticalSpacing(defaultSpacing),
                child,
              ],
            ),
          ),
        ),
      );
    }

    final random = math.Random();
    final randomOffset = random.nextDouble() * 3 + 2;
    final randomHz = random.nextDouble() * 1 + 1.5;

    return Stack(
      children: [
        Positioned(
          left: position.fromLeft ? position.start.dx : null,
          right: position.fromLeft ? null : position.start.dx,
          top: position.fromTop ? position.start.dy : null,
          bottom: position.fromTop ? null : position.start.dy,
          child: Animate(
            effects: [
              MoveEffect(duration: 400.ms, begin: Offset(0, -100 * (position.fromTop ? 1 : -1)), curve: scaleAnimationCurve),
              ShakeEffect(
                duration: 350.ms,
                hz: randomHz,
                offset: Offset(random.nextBool() ? randomOffset : -randomOffset, random.nextBool() ? randomOffset : -randomOffset),
                rotation: 0,
                curve: Curves.decelerate,
              ),
            ],
            target: 1,
            child: SizedBox(
              width: maxSize,
              child: Material(
                elevation: 2.0,
                color: Get.theme.colorScheme.onInverseSurface,
                borderRadius: BorderRadius.circular(dialogBorderRadius),
                child: Padding(
                  padding: EdgeInsets.all(lessPadding ? defaultSpacing : dialogPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: title,
                      ),
                      if (title.isNotEmpty) verticalSpacing(defaultSpacing),
                      child,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ContextMenuData {
  final Offset start;
  final bool fromTop;
  final bool fromLeft;

  const ContextMenuData(this.start, this.fromTop, this.fromLeft);

  // Compute the position of the context menu based on a widget it should be next to
  factory ContextMenuData.fromKey(GlobalKey key, {above = false, right = false}) {
    final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    var position = renderBox.localToGlobal(Offset.zero);
    final widgetDimensions = renderBox.size;
    final screenDimensions = Get.mediaQuery.size;

    // Calculate y position
    final bool fromTop;
    if (position.dy > screenDimensions.height / 2) {
      fromTop = false;
      position = above
          ? Offset(position.dx, screenDimensions.height - position.dy + defaultSpacing)
          : Offset(position.dx, screenDimensions.height - position.dy - widgetDimensions.height);
    } else {
      fromTop = true;
    }

    // Calculate x position
    final bool fromLeft;
    if (position.dx > screenDimensions.width - 350 || right) {
      fromLeft = false;
      if (above) {
        position = Offset(screenDimensions.width - position.dx - widgetDimensions.width, position.dy);
      } else {
        position = Offset(screenDimensions.width - position.dx + defaultSpacing, position.dy);
      }
    } else {
      fromLeft = true;
      position = above ? Offset(position.dx, position.dy) : Offset(position.dx + widgetDimensions.width + defaultSpacing, position.dy);
    }
    sendLog(fromLeft);

    return ContextMenuData(position, fromTop, fromLeft);
  }

  // Compute the position of the context menu based on a widget it should be next to
  factory ContextMenuData.fromPosition(Offset position) {
    final screenDimensions = Get.mediaQuery.size;

    // Calculate y position
    final bool fromTop;
    if (position.dy > screenDimensions.height / 2) {
      fromTop = false;
      position = Offset(position.dx, screenDimensions.height - position.dy);
    } else {
      fromTop = true;
    }

    // Calculate x position
    final bool fromLeft;
    if (position.dx > screenDimensions.width - 350) {
      fromLeft = false;
      position = Offset(screenDimensions.width - position.dx + defaultSpacing, position.dy);
    } else {
      fromLeft = true;
      position = Offset(position.dx + defaultSpacing, position.dy);
    }
    sendLog(fromLeft);

    return ContextMenuData(position, fromTop, fromLeft);
  }
}
