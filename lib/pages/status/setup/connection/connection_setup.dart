import 'dart:convert';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/status/error/error_page.dart';
import 'package:chat_interface/pages/status/error/server_offline_page.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:flutter/material.dart';

import '../../../../util/web.dart';
import 'cluster_setup.dart';

class ConnectionSetup extends Setup {
  ConnectionSetup() : super('loading.connection', false);

  @override
  Future<Widget?> load() async {

    var res = await postRqAuthorized("/node/connect", <String, dynamic>{
      "cluster": connectedCluster.id,
      "app": appId,
      "token": refreshToken,
    });

    if(res.statusCode != 200) {
      return const ServerOfflinePage();
    }

    var body = jsonDecode(res.body);
    if(!body["success"]) {

      return ErrorPage(title: body["error"]);
    }

    // Start connection
    startConnection(body["domain"], body["token"]);

    nodeId = body["id"];
    nodeDomain = body["domain"];

    return null;
  }
}