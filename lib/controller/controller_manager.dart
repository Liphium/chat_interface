import 'package:chat_interface/controller/chat/message_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:get/get.dart';

void initializeControllers() {
  
  Get.put(StatusController());
  Get.put(MessageController());
}