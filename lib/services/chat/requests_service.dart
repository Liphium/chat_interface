import 'package:chat_interface/controller/account/friends/requests_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:drift/drift.dart';
import 'package:get/get.dart';

class RequestsService {
  /// Called when the request is updated in the vault
  static void onVaultUpdateSent(Request request) {
    db.request.insertOnConflictUpdate(request.entity(true));
    Get.find<RequestController>().addSentRequestOrUpdate(request);
  }

  /// Called when the request is updated in the vault
  static void onVaultUpdate(Request request) {
    db.request.insertOnConflictUpdate(request.entity(false));
    Get.find<RequestController>().addRequestOrUpdate(request);
  }
}
