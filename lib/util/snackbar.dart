import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnackbarType { success, error, warning, info }

extension SnackbarColorExtension on SnackbarType {
  Color get color {
    switch (this) {
      case SnackbarType.success:
        return Colors.green;
      case SnackbarType.error:
        return Colors.red;
      case SnackbarType.warning:
        return Colors.orange;
      case SnackbarType.info:
        return Colors.blue;
    }
  }
}

void showSnackbar(SnackbarType type, String title, String message) {
  Get.snackbar(
    title.tr,
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.grey[900],
    colorText: Colors.white,
    margin: const EdgeInsets.all(8),
    borderRadius: 8,
    duration: const Duration(seconds: 3),
  );
}

void showMessage(SnackbarType type, String message) {

  Get.snackbar(
    message,
    '',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.grey[900],
    colorText: Colors.white,
    margin: const EdgeInsets.all(8),
    borderRadius: 8,
    duration: const Duration(seconds: 3),
  );
}