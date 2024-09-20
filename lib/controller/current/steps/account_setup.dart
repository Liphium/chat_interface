import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart';

class AccountSetup extends ConnectionStep {
  AccountSetup() : super('loading.account');

  @override
  Future<SetupResponse> load() async {
    // Get account from database
    final body = await postAuthorizedJSON("/account/me", <String, dynamic>{});
    final account = body["account"];

    if (!body["success"]) {
      return SetupResponse(error: body["error"]);
    }

    // Set all account data
    StatusController controller = Get.find();
    controller.name.value = account["username"];
    if (account["display_name"] != "") {
      sendLog("HELLO DISPLAY NAME FROM SERVER ${account["display_name"]}");
      controller.displayName.value = account["display_name"];
    } else {
      controller.displayName.value = account["username"];
      sendLog("SETTING DISPLAY NAME ${controller.displayName.value}");
    }
    StatusController.ownAccountId = account["id"];

    // Init file paths with account id
    AttachmentController.initFilePath(account["id"]);

    // Set all permissions
    StatusController.permissions = List<String>.from(body["permissions"]);

    return SetupResponse();
  }
}
