import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/controller/conversation/townsquare_controller.dart';
import 'package:chat_interface/pages/status/setup/fetch/fetch_setup.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../database/database.dart';

bool setupFinished = false;

class FetchFinishSetup extends Setup {
  FetchFinishSetup() : super('loading.fetch.finish', false);

  @override
  Future<Widget?> load() async {
    // Update last fetch time
    await finishFetch();
    setupFinished = true;
    connector.runAfterSetupQueue();

    // Update townsquare controller state
    Get.find<TownsquareController>().updateEnabledState();

    return null;
  }
}

Future<bool> finishFetch() async {
  if (!fetchHappening) return false;
  await db.into(db.setting).insertOnConflictUpdate(SettingData(key: "lastFetch", value: DateTime.now().millisecondsSinceEpoch.toString()));
  fetchHappening = false;
  return true;
}
