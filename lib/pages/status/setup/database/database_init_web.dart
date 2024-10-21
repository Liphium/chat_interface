import 'package:chat_interface/database/database.dart';
import 'package:drift/wasm.dart';
import 'package:get/get.dart';

class Instance {
  final String name;

  Instance(this.name);
}

Future<String?> loadInstance(String name) async {
  // Initialize the wasm database for web
  final wasmDb = await WasmDatabase.open(
    databaseName: "default",
    sqlite3Uri: Uri.parse("sqlite3.wasm"),
    driftWorkerUri: Uri.parse("drift_worker.dart.js"),
  );
  db = Database(wasmDb.resolvedExecutor);

  return null;
}

Future<List<Instance>?> getInstances() async => [Instance("default")];

Future<String?> deleteInstance(String name) async {
  return "not.supported".tr;
}
