import 'dart:async';

import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/components/conversations/conversation_ringing_window.dart';
import 'package:chat_interface/pages/settings/app/spaces_settings.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/theme/ui/profile/status_renderer.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class RingingManager {
  static bool ringing = false;
  static final player = AudioPlayer();
  static const ringtoneDuration = Duration(minutes: 1, seconds: 10);

  /// Start a ringing process based on a conversation and a space container
  static void startRinging(Conversation conversation, SpaceConnectionContainer container) async {
    if (ringing || !_canRing()) {
      return;
    }
    await player.setAsset("assets/music/ringtone.mov");
    await player.setVolume(0.1);
    await player.play();

    // Set a timer to go back from the dialog when the thing is paused
    Timer(ringtoneDuration, () {
      if (ringing) {
        Get.back();
      }
    });

    // Wait for the dialog to be closed and potentially stop the ringtone after that
    await Get.dialog(ConversationRingingWindow(
      conversation: conversation,
      container: container,
    ));
    stopRingtone();
  }

  /// Checks whether the client can currently be ringed
  static bool _canRing() {
    // Only ring when the status is online or away
    if (Get.find<StatusController>().type.value == statusDoNotDisturb || Get.find<StatusController>().type.value == statusOffline) {
      return false;
    }

    // Don't ring when the setting is turned off
    if (!Get.find<SettingController>().settings[SpacesSettings.ringOnInvite]!.getValue()) {
      return false;
    }

    return true;
  }

  /// Stop the ringtone
  static void stopRingtone() async {
    ringing = false;
    await player.stop();
  }
}
