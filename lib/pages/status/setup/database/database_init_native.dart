import 'dart:io';

import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class Instance {
  final String name;

  Instance(this.name);
}

Future<String?> loadInstance(String name) async {
  // Get the path to the instance
  final dbFolder = path.join((await getApplicationSupportDirectory()).path, "instances");
  final file = File(path.join(dbFolder, '$name.db'));

  // Clear the temp directory for zap share
  final folder = path.join((await getTemporaryDirectory()).path, "liphium");
  try {
    await File(folder).delete(recursive: true);
  } catch (e) {
    sendLog("seems like the cache folder is already deleted");
  }

  // Open the encrypted database (code was taken from the drift encrypted example)
  db = Database(NativeDatabase.createInBackground(file, logStatements: driftLogger));
  currentInstance = name;

  return null;
}

Future<List<Instance>?> getInstances() async {
  sendLog((await getApplicationSupportDirectory()).path);
  // Create the instance folder
  final instanceFolder = path.join((await getApplicationSupportDirectory()).path, "instances");
  final dir = Directory(instanceFolder);
  await dir.create();

  // Convert the list of files in the folder to instance names
  return (await dir.list().toList())
      .map((e) => Instance(path.basenameWithoutExtension(e.path)))
      .toList();
}

Future<String?> deleteInstance(String name) async {
  final dbFolder = path.join((await getApplicationSupportDirectory()).path, "instances");
  await File(path.join(dbFolder, "$name.db")).delete();
  return null;
}
