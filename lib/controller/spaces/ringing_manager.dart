import 'dart:async';

import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/services/spaces/space_container.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/components/conversations/conversation_ringing_window.dart';
import 'package:chat_interface/pages/settings/app/general_settings.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/theme/ui/profile/status_renderer.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:window_manager/window_manager.dart';

class RingingManager {
  static bool ringing = false;
  static final player = AudioPlayer();
  static const ringtoneDuration = Duration(minutes: 1, seconds: 10);

  /// Start a ringing process based on a conversation and a space container
  static Future<void> startRinging(Conversation conversation, SpaceConnectionContainer container) async {
    if (ringing || !await _canRing()) {
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
    await Get.dialog(ConversationRingingWindow(conversation: conversation, container: container));
    await stopRingtone();
  }

  static Future<void> playRingSound() async {
    await player.setAsset("assets/music/ringtone.mov");
    await player.setVolume(0.1);
    ringing = true;
    await player.play();
    Timer(ringtoneDuration, () {
      if (ringing) {
        ringing = false;
      }
    });
  }

  static Future<void> playNotificationSound() async {
    if (!await _canPlayNotificationSound()) {
      return;
    }
    await player.setAsset("assets/music/notification.mov");
    await player.setVolume(0.1);
    await player.play();
  }

  /// Checks whether the client can currently be ringed
  static Future<bool> _canRing() async {
    // Don't ring when the setting is turned off
    if (!SettingController.settings[GeneralSettings.ringOnInvite]!.getValue()) {
      return false;
    }

    // Only ring when the status is online or away
    final doNotDisturb = StatusController.type.value == statusDoNotDisturb || StatusController.type.value == statusOffline;
    if (doNotDisturb && !SettingController.settings[GeneralSettings.soundsDoNotDisturb]!.getValue()) {
      return false;
    }

    // Check if ring should only be played when Liphium is minimized
    final inTray = await windowManager.isVisible();
    final ignoreTray = SettingController.settings[GeneralSettings.ringIgnoreTray]!.getValue();
    final playOnlyInTray = SettingController.settings[GeneralSettings.soundsOnlyWhenTray]!.getValue();
    if (inTray && playOnlyInTray && !ignoreTray) {
      return false;
    }

    return true;
  }

  /// Checks whether a notification sound can currently be played
  static Future<bool> _canPlayNotificationSound() async {
    // Don't play a sound when the setting is turned off
    if (!SettingController.settings[GeneralSettings.soundsEnabled]!.getValue()) {
      return false;
    }

    // Check if it should play a sound when the status is do not disturb
    final doNotDisturb = StatusController.type.value == statusDoNotDisturb || StatusController.type.value == statusOffline;
    if (doNotDisturb && !SettingController.settings[GeneralSettings.soundsDoNotDisturb]!.getValue()) {
      return false;
    }

    // Check if notification sound should only be played when in tray
    final inTray = await windowManager.isVisible();
    final playOnlyInTray = SettingController.settings[GeneralSettings.soundsOnlyWhenTray]!.getValue();
    if (inTray && playOnlyInTray) {
      return false;
    }

    return true;
  }

  /// Stop the ringtone
  static Future<void> stopRingtone() async {
    ringing = false;
    await player.stop();
  }
}
