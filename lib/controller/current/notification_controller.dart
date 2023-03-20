import 'package:get/get.dart';

import '../../util/snackbar.dart';

class NotificationController extends GetxController {

  final notifications = <Notification>[].obs;

  void clear() {
    notifications.clear();
  }

}

class Notification {
  final String message;
  final SnackbarType type;

  Notification({required this.message, this.type = SnackbarType.info});
}