import 'dart:math';

import 'package:chat_interface/pages/status/error/error_page.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final _remoteIDs = <String>[]; // Remote IDs
final _random = Random(); // Random generator

String randomRemoteID() {
  return _remoteIDs[_random.nextInt(_remoteIDs.length)];
}

// Add a new remote ID (returns error message if failed)
Future<String?> addNewRemoteID() async {
  
  final json = await postAuthorizedJSON("/account/remote_id", <String, dynamic>{});
  if(!json["success"]) {
    return json["error"];
  }

  _remoteIDs.add(json["id"]);
  return null;
}

class RemoteIDSetup extends Setup {
  RemoteIDSetup() : super('loading.remote_id', false);
  
  @override
  Future<Widget?> load() async {
    
    // Generate 10 remote IDs
    for(int i = 0; i < 10; i++) {
      final res = await addNewRemoteID();
      if(res != null) {
        return ErrorPage(title: res.tr);
      }
    }

    return null;
  }
  
}