
import 'dart:convert';

import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controller/chat/requests_controller.dart';
import '../../../../util/web.dart';
import '../../error/error_page.dart';
import '../../error/server_offline_page.dart';

class RequestSetup extends Setup {
  
  RequestSetup() : super("loading.requests", false);

  @override
  Future<Widget?> load() async {
    
    // Get new requests from server
    var res = await postRqAuthorized("/account/friends/list", <String, dynamic>{
      "request": true,
      "since": 0,
    });

    if(res.statusCode == 404) return const ServerOfflinePage();
    if(res.statusCode != 200) return const ErrorPage(title: "server.error");

    var body = jsonDecode(res.body);

    RequestController controller = Get.find();
    controller.reset();

    if(body["success"]) {

      var friends = body["friends"];
      if (friends != null) {
        // Add new friends
        for(var friend in friends) {
          var requestData = Request.fromJson(friend as Map<String, dynamic>);
          controller.requests.add(requestData);
        }
      }
    } else {
      return const ErrorPage(title: "server.error");
    }

    return null;
  }
    
}