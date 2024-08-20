import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/theme/ui/dialogs/error_window.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart';

/// Automatically translated
void showErrorPopup(String title, String message) {
  Get.dialog(ErrorWindow(title: title.tr, error: translateError(message)));
}

/// Automatically translated
void showSuccessPopup(String title, String message) {
  Get.dialog(ErrorWindow(title: title.tr, error: message.tr));
}

Future<bool> showConfirmPopup(ConfirmWindow window) async {
  final result = await Get.dialog<bool>(window);
  if (result == null) {
    return true;
  }
  return result;
}
