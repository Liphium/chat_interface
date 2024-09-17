import 'dart:io';

import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/pages/settings/app/log_settings.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/theme/components/transitions/transition_container.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:sodium_libs/sodium_libs.dart';

import '../../../database/database.dart';
import '../../../main.dart';
import '../../../util/vertical_spacing.dart';
import 'setup_manager.dart';

const secureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
);

class InstanceSetup extends Setup {
  InstanceSetup() : super('loading.instance', true);

  @override
  Future<Widget?> load() async {
    // Get list of instances
    sendLog((await getApplicationSupportDirectory()).path);
    final instanceFolder = path.join((await getApplicationSupportDirectory()).path, "instances");
    final dir = Directory(instanceFolder);

    await dir.create();
    final instances = await dir.list().toList();

    if (instances.isEmpty || !isDebug) {
      await setupInstance("default");
      return null;
    }

    // Open instance selection page
    return InstanceSelectionPage(instances: instances);
  }
}

String dbEncrypted(String data) {
  return encryptSymmetric(data, databaseKey);
}

String fromDbEncrypted(String cipher) {
  return decryptSymmetric(cipher, databaseKey);
}

late SecureKey databaseKey;
String currentInstance = "";

Future<bool> setupInstance(String name, {bool next = false}) async {
  // Initialize database
  if (databaseInitialized) {
    await db.close();
  }

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
  db = Database(NativeDatabase.createInBackground(
    file,
    logStatements: driftLogger,
  ));
  currentInstance = name;

  // Create tables
  var _ = await (db.select(db.setting)).get();

  // Get the encryption password from secure storage
  final databaseKeyField = "db_key_$name";
  var encryptionKey = await secureStorage.read(key: databaseKeyField);
  if (encryptionKey == null) {
    // Create a new random encryption key (with sodium so it's secure)
    databaseKey = randomSymmetricKey();

    // Insert the key into secure storage
    await secureStorage.write(key: databaseKeyField, value: packageSymmetricKey(databaseKey));
    encryptionKey = await secureStorage.read(key: databaseKeyField);
    if (encryptionKey == null) {
      sendLog("couldn't write encryption key to secure storage");
      return false;
    }

    // Migrate all fields that need to be encrypted from now on
    for (var toMigrate in [
      "tokens",
      "private_key",
      "public_key",
      "signature_public_key",
      "signature_private_key",
      "key_sync_pub",
      "key_sync_priv",
      "key_sync_sig_pub",
      "key_sync_sig_priv",
      "key_sync_sig",
    ]) {
      final success = await _migrateFieldToEncryption(toMigrate);
      if (!success) {
        sendLog("field to migrate ($toMigrate) not found..");
      }
    }
  } else {
    databaseKey = unpackageSymmetricKey(encryptionKey);
  }

  // Enable logging for the current instance
  LogManager.enableLogging();

  // Open the next setup page
  if (next) {
    setupManager.next(open: true);
  }

  return true;
}

/// Encrypts the specified field in the settings table of the database (to migrate it from being unencrypted before)
Future<bool> _migrateFieldToEncryption(String field) async {
  final value = await (db.setting.select()..where((tbl) => tbl.key.equals(field))).getSingleOrNull();
  if (value == null) {
    return false;
  }

  // Encrypt the value and put it back into the database
  final encrypted = encryptSymmetric(value.value, databaseKey);
  db.setting.insertOnConflictUpdate(SettingData(key: field, value: encrypted));

  return true;
}

/// Get the value of a specified field store in the settings table
Future<String?> retrieveEncryptedValue(String field) async {
  final value = await (db.setting.select()..where((tbl) => tbl.key.equals(field))).getSingleOrNull();
  if (value == null) {
    return null;
  }

  // Decrypt the thing
  return decryptSymmetric(value.value, databaseKey);
}

/// Get the value of a specified field store in the settings table
Future<int> setEncryptedValue(String field, String value) {
  return db.setting.insertOnConflictUpdate(SettingData(key: field, value: encryptSymmetric(value, databaseKey)));
}

class InstanceSelectionPage extends StatefulWidget {
  final List<FileSystemEntity> instances;

  const InstanceSelectionPage({super.key, required this.instances});

  @override
  State<InstanceSelectionPage> createState() => _InstanceSelectionPageState();
}

class _InstanceSelectionPageState extends State<InstanceSelectionPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'setup.choose.instance'.tr,
          style: Get.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        verticalSpacing(sectionSpacing),
        Text("If you don't know what this is, just click on default and you'll be fine.", style: Get.textTheme.bodyMedium),
        verticalSpacing(sectionSpacing),
        ListView.builder(
          shrinkWrap: true,
          itemCount: widget.instances.length,
          itemBuilder: (context, index) {
            var instance = widget.instances[index];
            final base = path.basename(path.withoutExtension(instance.path));

            return Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0 : defaultSpacing),
              child: Material(
                borderRadius: BorderRadius.circular(defaultSpacing),
                color: Get.theme.colorScheme.primary,
                child: InkWell(
                  borderRadius: BorderRadius.circular(defaultSpacing),
                  onTap: () => setupInstance(path.basename(path.withoutExtension(instance.path)), next: true),
                  child: Padding(
                    padding: const EdgeInsets.all(elementSpacing),
                    child: Row(
                      children: [
                        horizontalSpacing(elementSpacing),
                        Text(base, style: Get.textTheme.labelLarge),
                        const Spacer(),
                        IconButton(
                          onPressed: () async {
                            sendLog("deleting");
                            await File(instance.path).delete();
                            setupManager.retry();
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        verticalSpacing(sectionSpacing),
        FJTextField(
          controller: _controller,
          hintText: 'setup.instance.name'.tr,
        ),
        verticalSpacing(defaultSpacing),
        FJElevatedButton(
          onTap: () => setupInstance(_controller.text, next: true),
          child: Center(child: Text("create".tr, style: Get.textTheme.labelLarge)),
        ),
      ],
    );
  }
}
