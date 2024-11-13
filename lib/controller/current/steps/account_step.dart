import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/controller/current/steps/stored_actions_step.dart';
import 'package:chat_interface/standards/server_stored_information.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

late SecureKey vaultKey;
late SecureKey profileKey;

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
    for (var rankJson in body["ranks"]) {
      StatusController.ranks.add(RankData.fromJson(rankJson));
    }

    // Decrypt the profile and vault key
    final vaultInfo = ServerStoredInfo.untransform(body["vault"]);
    final profileInfo = ServerStoredInfo.untransform(body["profile"]);
    if (profileInfo.error || vaultInfo.error) {
      return SetupResponse(error: "keys.invalid");
    }
    profileKey = unpackageSymmetricKey(profileInfo.text);
    vaultKey = unpackageSymmetricKey(vaultInfo.text);
    storedActionKey = body["actions"];

    return SetupResponse();
  }
}
