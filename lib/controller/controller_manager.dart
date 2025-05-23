import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/account/friends/requests_controller.dart';
import 'package:chat_interface/controller/account/unknown_controller.dart';
import 'package:chat_interface/controller/account/writing_controller.dart';
import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/message_search_controller.dart';
import 'package:chat_interface/controller/spaces/spaces_message_controller.dart';
import 'package:chat_interface/controller/spaces/warp_controller.dart';
import 'package:chat_interface/controller/conversation/zap_share_controller.dart';
import 'package:chat_interface/controller/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/spaces/spaces_member_controller.dart';
import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/trusted_links.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/controller/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/theme/components/transitions/transition_controller.dart';
import 'package:chat_interface/theme/theme_manager.dart';
import 'package:get/get.dart';

void initializeControllers() {
  // Conversation controls
  Get.put(MessageController());
  Get.put(UnknownController());
  Get.put(AttachmentController());
  Get.put(ConversationController());
  Get.put(MessageSearchController());

  // Account controls
  Get.put(RequestController());
  Get.put(FriendController());
  Get.put(WritingController());
  Get.put(ZapShareController());

  // App controls
  Get.put(ConnectionController());
  Get.put(StatusController());
  Get.put(SettingController());
  Get.put(ThemeManager());
  Get.put(TransitionController());

  // Space controls
  Get.put(SpacesController());
  Get.put(SpaceMemberController());
  Get.put(TabletopController());
  Get.put(SpacesMessageController());
  Get.put(WarpController());

  TrustedLinkHelper.init();
}
