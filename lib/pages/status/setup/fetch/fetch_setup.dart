import 'package:chat_interface/pages/status/setup/fetch/fetch_finish_setup.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:flutter/material.dart';

import '../../../../database/database.dart';

bool fetchHappening = false;
late DateTime lastFetchTime;

class FetchSetup extends Setup {
  FetchSetup() : super('loading.fetch', false);

  @override
  Future<Widget?> load() async {
    setupFinished = false;

    // Setup last fetch time
    await startFetch();

    return null;
  }
}

Future<bool> startFetch() async {
  if (fetchHappening) return false;
  fetchHappening = true;
  var lastFetch = await (db.select(db.setting)..where((tbl) => tbl.key.equals("lastFetch"))).getSingleOrNull();
  if (lastFetch == null) {
    var first = DateTime.fromMillisecondsSinceEpoch(0);
    await db.into(db.setting).insertOnConflictUpdate(SettingData(key: "lastFetch", value: first.millisecondsSinceEpoch.toString()));
    lastFetch = SettingData(key: "lastFetch", value: first.millisecondsSinceEpoch.toString());
  }

  lastFetchTime = DateTime.fromMillisecondsSinceEpoch(int.parse(lastFetch.value));
  return true;
}
