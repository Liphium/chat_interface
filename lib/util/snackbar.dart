import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSnackbar(String title, String message) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.grey[900],
    colorText: Colors.white,
    margin: const EdgeInsets.all(8),
    borderRadius: 8,
    duration: const Duration(seconds: 3),
  );
}