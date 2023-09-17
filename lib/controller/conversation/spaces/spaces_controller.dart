import 'package:chat_interface/controller/conversation/spaces/spaces_member_controller.dart';
import 'package:get/get.dart';

class SpacesController extends GetxController {

  //* Call status
  @Deprecated("Not used anymore")
  final livekit = false.obs;

  final inSpace = false.obs;
  final connected = false.obs;
  final title = "just playing".obs;
  final start = DateTime.now().obs;

  //* Call layout
  final expanded = false.obs;
  final fullScreen = false.obs;
  final hasVideo = false.obs;

  void join(String id) {

  }

  void leaveCall() {

    // Tell other controllers about it
    Get.find<SpaceMemberController>().onDisconnect();
  }
}