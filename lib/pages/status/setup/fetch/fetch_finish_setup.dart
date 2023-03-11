import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:flutter/material.dart';

import '../../../../database/database.dart';

class FetchFinishSetup extends Setup {
  FetchFinishSetup() : super('loading.fetch.finish');

  @override
  Future<Widget?> load() async {

    // Update last fetch time
    await db.into(db.setting).insertOnConflictUpdate(SettingData(key: "lastFetch", value: DateTime.now().millisecondsSinceEpoch.toString()));

    return null;
  }
}