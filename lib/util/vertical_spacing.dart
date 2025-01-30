import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

const noTextHeight = TextHeightBehavior(
  applyHeightToFirstAscent: false,
  applyHeightToLastDescent: false,
);

Widget verticalSpacing(double height) {
  return SizedBox(height: height);
}

Widget horizontalSpacing(double width) {
  return SizedBox(width: width);
}

String getRandomString(int length) {
  const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final random = Random();
  return String.fromCharCodes(List.generate(length, (index) => chars.codeUnitAt(random.nextInt(chars.length))));
}

bool isMobileMode() {
  return Get.width < 800 || Get.height < 500;
}

void popAllAndPush<T>(BuildContext context, Route<T> route) {
  final nav = Navigator.of(context);
  nav.popUntil((_) => false);
  nav.push(route);
}

double fittedIconSize(double size) {
  return Get.mediaQuery.textScaler.scale(size);
}

Future<T?>? showModal<T>(Widget widget, {mobileSliding = false}) async {
  if (isMobileMode()) {
    if (Get.mediaQuery.viewInsets.bottom > 0) {
      await Future.delayed(300.ms);
    }

    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: Get.context!,
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: EdgeInsets.only(bottom: Get.mediaQuery.viewInsets.bottom),
              child: widget,
            );
          },
        );
      },
    );
  } else {
    return Get.dialog(widget);
  }
}

const defaultSpacing = 8.0;
const elementSpacing = defaultSpacing * 0.5;
const elementSpacing2 = elementSpacing * 1.5;
const sectionSpacing = defaultSpacing * 2;
const modelBorderRadius = defaultSpacing * 1.5;
const modelPadding = defaultSpacing * 2;
const dialogBorderRadius = defaultSpacing * 1.5;
const dialogPadding = defaultSpacing * 1.5;
const scaleAnimationCurve = ElasticOutCurve(1.1);

String formatDay(DateTime time) {
  final now = DateTime.now();

  if (time.day == now.day) {
    return "time.today".tr;
  } else if (time.day == now.day - 1) {
    return "time.yesterday".tr;
  } else {
    return "time"
        .trParams({"day": time.day.toString().padLeft(2, "0"), "month": time.month.toString().padLeft(2, "0"), "year": time.year.toString()});
  }
}

String formatOnlyYear(DateTime time) {
  return "time".trParams({"day": time.day.toString().padLeft(2, "0"), "month": time.month.toString().padLeft(2, "0"), "year": time.year.toString()});
}

String formatMessageTime(DateTime time) {
  return "message.time".trParams({"hour": time.hour.toString().padLeft(2, "0"), "minute": time.minute.toString().padLeft(2, "0")});
}

String formatGeneralTime(DateTime time) {
  return "general_time".trParams({
    "day": time.day.toString().padLeft(2, "0"),
    "month": time.month.toString().padLeft(2, "0"),
    "year": time.year.toString(),
    "hour": time.hour.toString().padLeft(2, "0"),
    "minute": time.minute.toString().padLeft(2, "0"),
  });
}

class ExpandEffect extends CustomEffect {
  ExpandEffect({super.curve, super.duration, Axis? axis, Alignment? alignment, double? customHeightFactor, super.delay})
      : super(builder: (context, value, child) {
          return ClipRect(
            child: Align(
              alignment: alignment ?? Alignment.topCenter,
              heightFactor: customHeightFactor ?? (axis == Axis.vertical ? max(value, 0.0) : null),
              widthFactor: axis == Axis.horizontal ? max(value, 0.0) : null,
              child: child,
            ),
          );
        });
}

class ReverseExpandEffect extends CustomEffect {
  ReverseExpandEffect({super.curve, super.duration, Axis? axis, Alignment? alignment, super.delay})
      : super(
          builder: (context, value, child) {
            return ClipRect(
              child: Align(
                alignment: alignment ?? Alignment.topCenter,
                heightFactor: axis == Axis.vertical ? max(1 - value, 0.0) : null,
                widthFactor: axis == Axis.horizontal ? max(1 - value, 0.0) : null,
                child: child,
              ),
            );
          },
        );
}

class DevicePadding extends StatelessWidget {
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;

  final EdgeInsets padding;
  final Widget? child;

  const DevicePadding({
    super.key,
    this.top = false,
    this.bottom = false,
    this.left = false,
    this.right = false,
    required this.padding,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    var finalPadding = padding;

    // Check if there is device padding
    if (Get.mediaQuery.padding != EdgeInsets.zero) {
      var extraTop = Get.mediaQuery.padding.top;
      var extraBottom = Get.mediaQuery.padding.bottom;
      var extraRight = Get.mediaQuery.padding.right;
      var extraLeft = Get.mediaQuery.padding.left;

      // On iOS Apple adds padding to the bottom and top by themselves, because of this, we can safely
      // ignore the extra padding the user specifies.
      if (GetPlatform.isIOS) {
        finalPadding = EdgeInsets.only(
          top: top ? extraTop : padding.top,
          bottom: bottom ? extraBottom : padding.bottom,
          right: right ? extraRight + padding.right : padding.right,
          left: left ? extraLeft + padding.left : padding.left,
        );
      } else {
        finalPadding = EdgeInsets.only(
          top: top ? extraTop + padding.top : padding.top,
          bottom: bottom ? extraBottom + padding.bottom : padding.bottom,
          right: right ? extraRight + padding.right : padding.right,
          left: left ? extraLeft + padding.left : padding.left,
        );
      }
    }

    return Padding(
      padding: finalPadding,
      child: child,
    );
  }
}
