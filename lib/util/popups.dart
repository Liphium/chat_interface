import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/theme/ui/dialogs/error_window.dart';
import 'package:get/get.dart';

/// Only title is translated
void showErrorPopup(String title, String message) {
  Get.dialog(ErrorWindow(title: title.tr, error: message));
}

/// Everything is automatically translated
void showErrorPopupTranslated(String title, String message) {
  Get.dialog(ErrorWindow(title: title.tr, error: message.tr));
}

/// Only title is translated
void showSuccessPopup(String title, String message) {
  Get.dialog(ErrorWindow(title: title.tr, error: message));
}

/// Everything translated
void showSuccessPopupTranslated(String title, String message) {
  Get.dialog(ErrorWindow(title: title.tr, error: message.tr));
}

Future<bool> showConfirmPopup(ConfirmWindow window) async {
  final result = await Get.dialog<bool>(window);
  if (result == null) {
    return true;
  }
  return result;
}
