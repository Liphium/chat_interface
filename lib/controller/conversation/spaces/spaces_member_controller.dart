import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:get/get.dart';

class SpaceMemberController extends GetxController {

  final members = <String, SpaceMember>{}.obs;

  void onCall(String id) {

    
  }

  void onDisconnect() {

    
  }

  void addMember() {

  }

  void disconnectMember() {

  }

}

class SpaceMember {

  final Friend friend;
  
  final isSpeaking = false.obs;
  final isMuted = false.obs;
  final isAudioMuted = false.obs;

  SpaceMember(this.friend);

  void _onChanged() {
  }

  void disconnect() {
  }

}