import 'dart:async';
import 'dart:convert';

import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/connection/encryption/hash.dart';
import 'package:chat_interface/connection/encryption/signatures.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/error/error_page.dart';
import 'package:chat_interface/standards/server_stored_information.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/components/transitions/transition_container.dart';
import 'package:chat_interface/theme/components/transitions/transition_controller.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

import '../setup_manager.dart';

late SecureKey vaultKey;
late SecureKey profileKey;
late KeyPair asymmetricKeyPair;
late KeyPair signatureKeyPair;

class KeySetup extends Setup {
  KeySetup() : super("loading.keys", false);

  @override
  Future<Widget?> load() async {
    // Get keys from the server
    final pubBody = await postAuthorizedJSON("/account/keys/public/get", <String, dynamic>{});
    var privateKey = await (db.select(db.setting)..where((tbl) => tbl.key.equals("private_key"))).getSingleOrNull();

    if (!pubBody["success"]) {
      final signatureKeyPair = generateSignatureKeyPair();
      final pair = generateAsymmetricKeyPair();

      final packagedSignaturePriv = packagePrivateKey(signatureKeyPair.secretKey);
      final packagedSignaturePub = packagePublicKey(signatureKeyPair.publicKey);
      final packagedPriv = packagePrivateKey(pair.secretKey);
      final packagedPub = packagePublicKey(pair.publicKey);
      final genProfileKey = randomSymmetricKey();
      final genVaultKey = randomSymmetricKey();

      // Set public key on the server
      var res = await postAuthorizedJSON("/account/keys/public/set", <String, dynamic>{
        "key": packagedPub,
      });
      if (!res["success"]) {
        return const ErrorPage(title: "key.error");
      }
      res = await postAuthorizedJSON("/account/keys/profile/set", <String, dynamic>{
        "key": ServerStoredInfo(packageSymmetricKey(genProfileKey)).transform(ownKeyPair: pair),
      });
      if (!res["success"]) {
        return const ErrorPage(title: "key.error");
      }
      res = await postAuthorizedJSON("/account/keys/vault/set", <String, dynamic>{
        "key": ServerStoredInfo(packageSymmetricKey(genVaultKey)).transform(ownKeyPair: pair),
      });
      if (!res["success"]) {
        return const ErrorPage(title: "key.error");
      }
      res = await postAuthorizedJSON("/account/keys/signature/set", <String, dynamic>{
        "key": packagedSignaturePub,
      });
      if (!res["success"]) {
        return const ErrorPage(title: "key.error");
      }

      // Insert private key into the database
      privateKey = SettingData(key: "private_key", value: packagedPriv);
      await db.into(db.setting).insertOnConflictUpdate(privateKey);
      await db.into(db.setting).insertOnConflictUpdate(SettingData(key: "public_key", value: packagedPub));
      pubBody["key"] = packagedPub;
      final signaturePrivateKey = SettingData(key: "signature_private_key", value: packagedSignaturePriv);
      await db.into(db.setting).insertOnConflictUpdate(signaturePrivateKey);
      await db.into(db.setting).insertOnConflictUpdate(SettingData(key: "signature_public_key", value: packagedSignaturePub));
    } else {
      if (privateKey == null) {
        return await KeySetup.openKeySynchronization();
      }
    }

    // Check if the public keys match
    var publicKey = await (db.select(db.setting)..where((tbl) => tbl.key.equals("public_key"))).getSingleOrNull();
    if (publicKey == null) {
      return const ErrorPage(title: "server.error");
    }
    if (pubBody["key"] != publicKey.value) {
      return await KeySetup.openKeySynchronization();
    }

    // Grab profile key from server
    final json = await postAuthorizedJSON("/account/keys/encrypted", <String, dynamic>{});
    if (!json["success"]) {
      return ErrorPage(title: json["error"]);
    }

    asymmetricKeyPair = toKeyPair(pubBody["key"], privateKey.value);
    final vaultInfo = ServerStoredInfo.untransform(json["vault"]);
    final profileInfo = ServerStoredInfo.untransform(json["profile"]);
    if (profileInfo.error || vaultInfo.error) {
      return const ErrorPage(title: "keys.invalid");
    }
    profileKey = unpackageSymmetricKey(profileInfo.text);
    vaultKey = unpackageSymmetricKey(vaultInfo.text);

    // Grab signature key from client database
    final signaturePrivateKey = await (db.select(db.setting)..where((tbl) => tbl.key.equals("signature_private_key"))).getSingleOrNull();
    final signaturePublicKey = await (db.select(db.setting)..where((tbl) => tbl.key.equals("signature_public_key"))).getSingleOrNull();
    if (signaturePrivateKey == null || signaturePublicKey == null) {
      return const ErrorPage(title: "key.error");
    }

    signatureKeyPair = toKeyPair(signaturePublicKey.value, signaturePrivateKey.value);

    return null;
  }

  /// Method to open the key synchronization during setup (needs extra logic cause an extra request needs to be made)
  static Future<Widget> openKeySynchronization() async {
    // Check if there is a keypair already in there
    late final String signature;
    late final KeyPair encryptionKeyPair, signatureKeyPair;
    final syncPub = await (db.setting.select()..where((t) => t.key.equals("key_sync_pub"))).getSingleOrNull();
    if (syncPub == null) {
      // Generate the key pairs for key sync exchange
      encryptionKeyPair = generateAsymmetricKeyPair();
      signatureKeyPair = generateSignatureKeyPair();
      signature = getRandomString(6);

      // Insert all the values
      db.setting.insertOnConflictUpdate(SettingData(key: "key_sync_pub", value: packagePublicKey(encryptionKeyPair.publicKey)));
      db.setting.insertOnConflictUpdate(SettingData(key: "key_sync_priv", value: packagePrivateKey(encryptionKeyPair.secretKey)));
      db.setting.insertOnConflictUpdate(SettingData(key: "key_sync_sig_pub", value: packagePublicKey(signatureKeyPair.publicKey)));
      db.setting.insertOnConflictUpdate(SettingData(key: "key_sync_sig_priv", value: packagePrivateKey(signatureKeyPair.secretKey)));
      db.setting.insertOnConflictUpdate(SettingData(key: "key_sync_sig", value: signature));
    } else {
      // Load the key pair and signature
      final syncPriv = await (db.setting.select()..where((t) => t.key.equals("key_sync_priv"))).getSingle();
      encryptionKeyPair = toKeyPair(syncPub.value, syncPriv.value);

      // Get the signature key pair
      final syncSigPub = await (db.setting.select()..where((t) => t.key.equals("key_sync_sig_pub"))).getSingle();
      final syncSigPriv = await (db.setting.select()..where((t) => t.key.equals("key_sync_sig_priv"))).getSingle();
      signatureKeyPair = toKeyPair(syncSigPub.value, syncSigPriv.value);

      // Get the signature
      signature = (await (db.setting.select()..where((t) => t.key.equals("key_sync_sig"))).getSingle()).value;
    }

    // Ask the server whether the request already exists
    final json = await postJSON("/account/keys/requests/exists", {
      "token": refreshToken,
    });

    // Check if there was an error
    if (!json["success"]) {
      return ErrorPage(title: json["error"] as String);
    }

    if (json["exists"]) {
      return KeyCodePage(
        signature: signature,
        signatureKeyPair: signatureKeyPair,
        encryptionKeyPair: encryptionKeyPair,
      );
    }

    return KeySynchronizationPage(
      signature: signature,
      signatureKeyPair: signatureKeyPair,
      encryptionKeyPair: encryptionKeyPair,
    );
  }
}

class KeySynchronizationPage extends StatefulWidget {
  final KeyPair encryptionKeyPair;
  final KeyPair signatureKeyPair;
  final String signature;

  const KeySynchronizationPage({
    super.key,
    required this.signatureKeyPair,
    required this.signature,
    required this.encryptionKeyPair,
  });

  @override
  State<KeySynchronizationPage> createState() => _KeySynchronizationPageState();
}

class _KeySynchronizationPageState extends State<KeySynchronizationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.inverseSurface,
      body: Center(
        child: TransitionContainer(
          tag: "login",
          borderRadius: BorderRadius.circular(modelBorderRadius),
          width: 370,
          child: Padding(
            padding: const EdgeInsets.all(modelPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your keys aren\'t synchronized'.tr,
                  style: Get.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                verticalSpacing(sectionSpacing),
                Text("If you are logging in for the first time on this device or changed your keys, this is completely normal. You have a couple of options here.", style: Get.textTheme.bodyMedium),
                verticalSpacing(sectionSpacing),
                Text(
                  "1. Get from another device",
                  style: Get.theme.textTheme.labelMedium,
                  textAlign: TextAlign.center,
                ),
                verticalSpacing(defaultSpacing),
                Text("Ask another device that is currently logged into your account to send you the keys. Don't worry, we'll encrypt them in transfer.", style: Get.textTheme.bodyMedium),
                verticalSpacing(defaultSpacing),
                FJElevatedLoadingButton(
                  loading: false.obs,
                  onTap: () async {
                    final json = await postJSON("/account/keys/requests/check", {
                      "token": refreshToken,
                      "signature": signMessage(widget.signatureKeyPair.secretKey, hashSha(widget.signature + packagePublicKey(widget.encryptionKeyPair.publicKey))),
                      "key": "${packagePublicKey(widget.signatureKeyPair.publicKey)}:${packagePublicKey(widget.encryptionKeyPair.publicKey)}",
                    });

                    if (!json["success"]) {
                      showErrorPopup("error", json["error"]);
                      return;
                    }

                    Get.find<TransitionController>().modelTransition(KeyCodePage(
                      encryptionKeyPair: widget.encryptionKeyPair,
                      signatureKeyPair: widget.signatureKeyPair,
                      signature: widget.signature,
                    ));
                  },
                  label: "Ask another device",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class KeyCodePage extends StatefulWidget {
  final KeyPair signatureKeyPair, encryptionKeyPair;
  final String signature;

  const KeyCodePage({
    super.key,
    required this.signatureKeyPair,
    required this.signature,
    required this.encryptionKeyPair,
  });

  @override
  State<KeyCodePage> createState() => _KeyCodePageState();
}

class _KeyCodePageState extends State<KeyCodePage> {
  Timer? _timer;

  @override
  void initState() {
    // Check state on the server every 5 seconds
    _timer = Timer.periodic(5000.ms, (timer) async {
      final json = await postJSON("/account/keys/requests/check", {
        "token": refreshToken,
        "signature": signMessage(widget.signatureKeyPair.secretKey, hashSha(widget.signature + packagePublicKey(widget.encryptionKeyPair.publicKey))),
        "key": "${packagePublicKey(widget.signatureKeyPair.publicKey)}:${packagePublicKey(widget.encryptionKeyPair.publicKey)}",
      });

      if (!json["success"]) {
        showErrorPopup("error", json["error"]);
        return;
      }

      // Add all the keys to the database if there is a payload
      if (json["payload"] != null && json["payload"] != "") {
        final payload = decryptAsymmetricAnonymous(widget.encryptionKeyPair.publicKey, widget.encryptionKeyPair.secretKey, json["payload"]);
        final jsonPayload = jsonDecode(payload);
        await db.into(db.setting).insertOnConflictUpdate(SettingData(key: "public_key", value: jsonPayload["pub"]));
        await db.into(db.setting).insertOnConflictUpdate(SettingData(key: "private_key", value: jsonPayload["priv"]));
        await db.into(db.setting).insertOnConflictUpdate(SettingData(key: "signature_public_key", value: jsonPayload["sig_pub"]));
        await db.into(db.setting).insertOnConflictUpdate(SettingData(key: "signature_private_key", value: jsonPayload["sig_priv"]));
        setupManager.restart();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.inverseSurface,
      body: Center(
        child: TransitionContainer(
          tag: "login",
          borderRadius: BorderRadius.circular(modelBorderRadius),
          width: 370,
          child: Padding(
            padding: const EdgeInsets.all(modelPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Code: ${widget.signature}",
                  style: Get.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                verticalSpacing(sectionSpacing),
                Text(
                  'On the device where you are logged in, go to Settings > Data > Synchronization requests, click on the request and then type in the code above. We\'ll check if you did automatically.'
                      .tr,
                  style: Get.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
