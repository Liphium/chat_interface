import 'dart:async';

import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/ffi.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

class SpaceMemberController extends GetxController {

  SecureKey? key;
  final membersLoading = false.obs;
  final members = <String, SpaceMember>{}.obs;
  StreamSubscription<Action>? sub;
  String _ownId = "";
  
  // Action names
  static const String startedTalkingAction = "started_talking";
  static const String stoppedTalkingAction = "stopped_talking";

  void onMembersChanged(List<dynamic> members) {
    sendLog("members changed");
    final statusController = Get.find<StatusController>();
    final myId = statusController.id.value;
    final membersFound = <String>[];

    for (var member in members) {
      final args = member.split(":");
      final decrypted = decryptSymmetric(args[0], key!);
      final clientId = args[1];
      sendLog("$decrypted:$clientId");
      if(decrypted == myId) {
        _ownId = clientId;
      }
      membersFound.add(clientId);
      if(this.members[clientId] == null) {
        this.members[clientId] = SpaceMember(Get.find<FriendController>().friends[decrypted] ?? (decrypted == myId ? Friend.me(statusController) : Friend.unknown(decrypted)));
      }
    }

    // Remove everyone who left the space
    this.members.removeWhere((key, value) => !membersFound.contains(key));
    membersLoading.value = false;
  }

  void onConnect(SecureKey key) async {
    this.key = key;

    sub = api.createActionStream().listen((event) {
      switch(event.action) {
        // Talking stuff
        case startedTalkingAction:
          final target = event.data == "" ? _ownId : event.data;
          sendLog("talking");
          members[target]!.isSpeaking.value = true;
        case stoppedTalkingAction:
          sendLog("stopped talking ${event.data}");
          final target = event.data == "" ? _ownId : event.data;
          members[target]!.isSpeaking.value = false;
      }
    });
  }

  String getClientId() => _ownId;

  void onDisconnect() {
    membersLoading.value = true;
    members.clear();
    sub!.cancel();
  }

}

class SpaceMember {

  final Friend friend;
  
  final isSpeaking = false.obs;
  final isMuted = false.obs;
  final isDeafened = false.obs;

  SpaceMember(this.friend);

  void _onChanged() {
  }

  void disconnect() {
  }

}