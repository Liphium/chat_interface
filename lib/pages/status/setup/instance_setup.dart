import 'dart:async';
import 'dart:io';

import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:chat_interface/pages/status/error/error_page.dart';
import 'package:chat_interface/pages/status/setup/database/database_init_stub.dart'
    if (dart.library.io) 'package:chat_interface/pages/status/setup/database/database_init_native.dart'
    if (dart.library.js) 'package:chat_interface/pages/status/setup/database/database_init_web.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:dbus_secrets/dbus_secrets.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

import '../../../database/database.dart';
import '../../../main.dart';
import '../../../util/vertical_spacing.dart';
import 'setup_manager.dart';

const secureStorage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));

class InstanceSetup extends Setup {
  InstanceSetup() : super('loading.instance', false);

  @override
  Future<Widget?> load() async {
    // Make sure to just launch into the default instance on web
    if (isWeb) {
      await setupInstance("default");
      return null;
    }

    // Get list of instances
    final instances = await getInstances();
    if (instances == null) {
      return ErrorPage(title: "not.supported".tr);
    }

    // Launch into the default instance in release mode and when there is no instance yet
    if (instances.isEmpty || !isDebug) {
      final error = await setupInstance("default");
      if (error != null) {
        return ErrorPage(title: error);
      }
      return null;
    }

    // Open instance selection page
    return InstanceSelectionPage(instances: instances);
  }
}

/// Convert data to a local database encrypted string.
///
/// Encrypts using the database key stored in secure storage.
String dbEncrypted(String data, [Sodium? sodium, SecureKey? key]) {
  return encryptSymmetric(data, key ?? databaseKey, sodium);
}

String fromDbEncrypted(String cipher) {
  return decryptSymmetric(cipher, databaseKey);
}

late SecureKey databaseKey;
String currentInstance = "";

/// Open an instance by name (on web, the name parameter will be ignored)
///
/// Returns an error if there is one.
Future<String?> setupInstance(String name, {bool next = false}) async {
  if (databaseInitialized) {
    await db.close();
  }

  // Load the instance
  await loadInstance(name);

  // Create tables
  var _ = await (db.select(db.setting)).get();

  // Get the encryption password from secure storage
  String? error;
  if (Platform.isLinux) {
    error = await loadEncryptionKeyDbusSecrets(name);
  } else {
    error = await loadEncryptionKeySecureStorage(name);
  }
  if (error != null) {
    return error;
  }

  // Open the next setup page
  if (next) {
    unawaited(setupManager.next(open: true));
  }

  return null;
}

/// Load the encryption key from flutter_secure_storage.
///
/// Returns an error if there was one.
Future<String?> loadEncryptionKeySecureStorage(String instance) async {
  final databaseKeyField = "db_key_$instance";
  String? encryptionKey;
  try {
    encryptionKey = await secureStorage.read(key: databaseKeyField);
  } catch (_) {
    return "secure_storage.not_supported".tr;
  }

  // Generate a new encryption key in case there isn't one yet
  if (encryptionKey == null) {
    // Create a new random encryption key (with sodium so it's secure)
    databaseKey = randomSymmetricKey();

    // Insert the key into secure storage
    await secureStorage.write(key: databaseKeyField, value: packageSymmetricKey(databaseKey));
    encryptionKey = await secureStorage.read(key: databaseKeyField);
    if (encryptionKey == null) {
      return "secure_storage.not_supported".tr;
    }
  } else {
    databaseKey = unpackageSymmetricKey(encryptionKey);
  }

  return null;
}

/// Load the encryption key from dbus_secrets (specifically for Linux).
///
/// Returns an error if there was one.
Future<String?> loadEncryptionKeyDbusSecrets(String instance) async {
  // Connect to org.freedesktop.secrets using dbus
  final secrets = DBusSecrets(appName: linuxDbusAppName);
  var result = await secrets.initialize();
  if (!result) {
    return "secure_storage.not_supported".tr;
  }

  // Try to unlock the vault
  result = await secrets.unlock();
  if (!result) {
    await secrets.close();
    return "secure_storage.unlock_failed".tr;
  }

  // Get the encryption key from the vault
  final databaseKeyField = "db_key_$instance";
  var encryptionKey = await secrets.get(databaseKeyField);

  // Create a new database encryption key in case it isn't there yet
  if (encryptionKey == null) {
    encryptionKey = packageSymmetricKey(randomSymmetricKey());
    result = await secrets.set(databaseKeyField, encryptionKey);
    if (!result) {
      await secrets.close();
      return "secure_storage.not_supported".tr;
    }
  }

  // Set the database key
  databaseKey = unpackageSymmetricKey(encryptionKey);

  // Close the dbus session
  await secrets.close();

  return null;
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
  final List<Instance> instances;

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
        Text('setup.choose.instance'.tr, style: Get.textTheme.headlineMedium, textAlign: TextAlign.center),
        verticalSpacing(sectionSpacing),
        Text(
          "If you don't know what this is, just click on default and you'll be fine.",
          style: Get.textTheme.bodyMedium,
        ),
        verticalSpacing(sectionSpacing),
        ListView.builder(
          shrinkWrap: true,
          itemCount: widget.instances.length,
          itemBuilder: (context, index) {
            var instance = widget.instances[index];

            return Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0 : defaultSpacing),
              child: Material(
                borderRadius: BorderRadius.circular(defaultSpacing),
                color: Get.theme.colorScheme.primary,
                child: InkWell(
                  borderRadius: BorderRadius.circular(defaultSpacing),
                  onTap: () => setupInstance(instance.name, next: true),
                  child: Padding(
                    padding: const EdgeInsets.all(elementSpacing),
                    child: Row(
                      children: [
                        horizontalSpacing(elementSpacing),
                        Text(instance.name, style: Get.textTheme.labelLarge),
                        const Spacer(),
                        IconButton(
                          onPressed: () async {
                            await deleteInstance(instance.name);
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
        FJTextField(controller: _controller, hintText: 'setup.instance.name'.tr),
        verticalSpacing(defaultSpacing),
        FJElevatedButton(
          onTap: () => setupInstance(_controller.text, next: true),
          child: Center(child: Text("create".tr, style: Get.textTheme.labelLarge)),
        ),
      ],
    );
  }
}
