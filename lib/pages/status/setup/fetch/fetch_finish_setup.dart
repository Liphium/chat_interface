import 'package:chat_interface/pages/status/setup/fetch/fetch_setup.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:flutter/material.dart';

import '../../../../database/database.dart';

class FetchFinishSetup extends Setup {
  FetchFinishSetup() : super('loading.fetch.finish', false);

  @override
  Future<Widget?> load() async {

    // Update last fetch time
    await finishFetch();

    return null;
  }
}

Future<bool> finishFetch() async {
  if(!fetchHappening) return false;
  await db.into(db.setting).insertOnConflictUpdate(SettingData(key: "lastFetch", value: DateTime.now().millisecondsSinceEpoch.toString()));
  fetchHappening = false;
  return true;
}