import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:chat_interface/main.dart';

import '../../../util/web.dart';

class ConnectionSetup extends ConnectionStep {
  ConnectionSetup() : super('loading.connection');

  @override
  Future<SetupResponse> load() async {
    final body = await postAuthorizedJSON("/node/connect", <String, dynamic>{
      "tag": appTag,
      "token": refreshToken,
      "extra": "",
    });

    if (!body["success"]) {
      return SetupResponse(error: body["error"]);
    }

    nodeId = body["id"];
    nodeDomain = body["domain"];

    // Start connection
    final res = await startConnection(body["domain"], body["token"]);
    if (!res) {
      return SetupResponse(error: "node.error");
    }

    return SetupResponse();
  }
}
