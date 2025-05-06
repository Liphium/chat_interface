import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationDot extends StatelessWidget {
  final int amount;

  const NotificationDot({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, color: Get.theme.colorScheme.error),
      child: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
        child: Center(child: Text(min(amount, 99).toString(), style: Get.textTheme.labelSmall)),
      ),
    );
  }
}
