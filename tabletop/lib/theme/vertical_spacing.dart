
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

const defaultSpacing = 8.0;
const elementSpacing = defaultSpacing * 0.5;
const sectionSpacing = defaultSpacing * 2;
const headerSpacing = defaultSpacing * 4;
const modelBorderRadius = defaultSpacing * 1.5;
const modelPadding = defaultSpacing * 2;
const dialogBorderRadius = defaultSpacing * 1.5;
const dialogPadding = defaultSpacing * 1.5;

String formatTime(DateTime time) {
  final now = DateTime.now();

  if(time.day == now.day) {
    return "time.now".trParams({"hour": time.hour.toString().padLeft(2, "0"), "minute": time.minute.toString().padLeft(2, "0")});
  } else {
    return "time".trParams({"hour": time.hour.toString().padLeft(2, "0"), "minute": time.minute.toString().padLeft(2, "0"),
    "day": time.day.toString().padLeft(2, "0"), "month": time.month.toString().padLeft(2, "0"), "year": time.year.toString()});
  }
}

const availableChars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
String generateRandomString(int length) {
  final random = Random();
  final randomString = List.generate(length,
      (index) => availableChars[random.nextInt(availableChars.length)]).join();

  return randomString;
}

class ExpandEffect extends CustomEffect {

  ExpandEffect({Curve? curve, Duration? duration, Axis? axis, Alignment? alignment, Duration? delay}) : super(builder: (context, value, child) {
    return ClipRect(
      child: Align(
        alignment: alignment ?? Alignment.topCenter,
        heightFactor: axis == Axis.vertical ? max(value, 0.0) : null,
        widthFactor: axis == Axis.horizontal ? max(value, 0.0) : null,
        child: child,
      ),
    );
  }, curve: curve, duration: duration, delay: delay);

}