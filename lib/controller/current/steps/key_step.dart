import 'dart:async';
import 'dart:convert';

import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/connection/encryption/hash.dart';
import 'package:chat_interface/connection/encryption/signatures.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/controller/current/steps/account_step.dart';
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/pages/status/setup/setup_page.dart';
import 'package:chat_interface/pages/status/setup/smooth_dialog.dart';
import 'package:chat_interface/standards/server_stored_information.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

import '../../../pages/status/setup/setup_manager.dart';

late KeyPair asymmetricKeyPair;
late KeyPair signatureKeyPair;

class KeySetup extends ConnectionStep {
  KeySetup() : super("loading.keys");

  @override
  Future<SetupResponse> load() async {
    // Get the public key from the server (to check if keys are still the same)
    var res = await postAuthorizedJSON("/account/keys/public/get", <String, dynamic>{});

    // Get keys from the local database (or an empty string)
    var publicKey = await retrieveEncryptedValue("public_key");
    var privateKey = await retrieveEncryptedValue("private_key");

    // If there is no public key on the server, generate new keys
    if (!res["success"]) {
      // Generate new keys
      final signatureKeyPair = generateSignatureKeyPair();
      final pair = generateAsymmetricKeyPair();

      final packagedSignaturePriv = packagePrivateKey(signatureKeyPair.secretKey);
      final packagedSignaturePub = packagePublicKey(signatureKeyPair.publicKey);
      final packagedPriv = packagePrivateKey(pair.secretKey);
      final packagedPub = packagePublicKey(pair.publicKey);
      final genProfileKey = randomSymmetricKey();
      final genVaultKey = randomSymmetricKey();

      // Set public key on the server
      res = await postAuthorizedJSON("/account/keys/public/set", <String, dynamic>{
        "key": packagedPub,
      });
      if (!res["success"]) {
        return SetupResponse(error: "key.error");
      }
      res = await postAuthorizedJSON("/account/keys/profile/set", <String, dynamic>{
        "key": ServerStoredInfo(packageSymmetricKey(genProfileKey)).transform(ownKeyPair: pair),
      });
      if (!res["success"]) {
        return SetupResponse(error: "key.error");
      }
      res = await postAuthorizedJSON("/account/keys/vault/set", <String, dynamic>{
        "key": ServerStoredInfo(packageSymmetricKey(genVaultKey)).transform(ownKeyPair: pair),
      });
      if (!res["success"]) {
        return SetupResponse(error: "key.error");
      }
      res = await postAuthorizedJSON("/account/keys/signature/set", <String, dynamic>{
        "key": packagedSignaturePub,
      });
      if (!res["success"]) {
        return SetupResponse(error: "key.error");
      }

      // Insert private key into the database
      privateKey = packagedPriv;
      await setEncryptedValue("private_key", packagedPriv);
      await setEncryptedValue("public_key", packagedPub);
      publicKey = packagedPub;

      // Set the signature keys
      await setEncryptedValue("signature_private_key", packagedSignaturePriv);
      await setEncryptedValue("signature_public_key", packagedSignaturePub);
    } else {
      // Open key synchronization if there are no local keys
      if (publicKey == null || privateKey == null) {
        final res = await openKeySynchronization();
        return SetupResponse(
          restart: true,
          error: res,
        );
      }

      // Check if the key is the same as on the server
      if (res["key"] != publicKey) {
        final res = await openKeySynchronization();
        return SetupResponse(
          restart: true,
          error: res,
        );
      }

      // Set local key pair
      asymmetricKeyPair = toKeyPair(publicKey, privateKey);
    }

    // Grab signature key from client database
    final signaturePrivateKey = await retrieveEncryptedValue("signature_private_key");
    final signaturePublicKey = await retrieveEncryptedValue("signature_public_key");
    if (signaturePrivateKey == null || signaturePublicKey == null) {
      return SetupResponse(error: "key.error");
    }
    signatureKeyPair = toKeyPair(signaturePublicKey, signaturePrivateKey);

    return SetupResponse();
  }

  /// Method to open the key synchronization during setup (needs extra logic cause an extra request needs to be made)
  static Future<String?> openKeySynchronization() async {
    // Make a completer to wait for the entire operation to be over
    final completer = Completer<String?>();

    // Check if there is a keypair already in there
    late final String signature;
    late final KeyPair encryptionKeyPair, signatureKeyPair;
    final syncPub = await retrieveEncryptedValue("key_sync_pub");
    if (syncPub == null) {
      // Generate the key pairs for key sync exchange
      encryptionKeyPair = generateAsymmetricKeyPair();
      signatureKeyPair = generateSignatureKeyPair();
      signature = getRandomString(6);

      // Insert all the values
      await setEncryptedValue("key_sync_pub", packagePublicKey(encryptionKeyPair.publicKey));
      await setEncryptedValue("key_sync_priv", packagePrivateKey(encryptionKeyPair.secretKey));
      await setEncryptedValue("key_sync_sig_pub", packagePublicKey(signatureKeyPair.publicKey));
      await setEncryptedValue("key_sync_sig_priv", packagePrivateKey(signatureKeyPair.secretKey));
      await setEncryptedValue("key_sync_sig", signature);
    } else {
      // Load the key pair and signature
      final syncPriv = (await retrieveEncryptedValue("key_sync_priv"))!;
      encryptionKeyPair = toKeyPair(syncPub, syncPriv);

      // Get the signature key pair
      final syncSigPub = (await retrieveEncryptedValue("key_sync_sig_pub"))!;
      final syncSigPriv = (await retrieveEncryptedValue("key_sync_sig_priv"))!;
      signatureKeyPair = toKeyPair(syncSigPub, syncSigPriv);

      // Get the signature
      signature = (await retrieveEncryptedValue("key_sync_sig"))!;
    }

    // Ask the server whether the request already exists
    final json = await postJSON("/account/keys/requests/exists", {
      "token": refreshToken,
    });

    // Check if there was an error
    if (!json["success"]) {
      return json["error"];
    }

    // Go to the key setup page
    Get.dialog(
      KeySetupPage(
        signature: signature,
        signatureKeyPair: signatureKeyPair,
        encryptionKeyPair: encryptionKeyPair,
        exists: json["exists"],
      ),
      barrierDismissible: false,
    );
    return completer.future;
  }
}

class KeySetupPage extends StatefulWidget {
  final KeyPair encryptionKeyPair;
  final KeyPair signatureKeyPair;
  final String signature;
  final bool exists;

  const KeySetupPage({
    super.key,
    required this.signatureKeyPair,
    required this.signature,
    required this.encryptionKeyPair,
    required this.exists,
  });

  @override
  State<KeySetupPage> createState() => _KeySetupPageState();
}

class _KeySetupPageState extends State<KeySetupPage> {
  late SmoothDialogController controller;

  @override
  void initState() {
    // Initalize the controller, so we can pass it into the key pages
    controller = SmoothDialogController(const SetupLoadingWidget(text: "preparing"));

    if (widget.exists) {
      // If there is a key request already, go to the code page
      controller.transitionTo(
        KeyCodePage(
          signature: widget.signature,
          signatureKeyPair: widget.signatureKeyPair,
          encryptionKeyPair: widget.encryptionKeyPair,
        ),
      );
    } else {
      // If there is no key request, go to the key sync page
      controller.transitionTo(
        KeySynchronizationPage(
          signature: widget.signature,
          signatureKeyPair: widget.signatureKeyPair,
          encryptionKeyPair: widget.encryptionKeyPair,
          controller: controller,
        ),
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SmoothDialogWindow(controller: controller);
  }
}

class KeySynchronizationPage extends StatefulWidget {
  final KeyPair encryptionKeyPair;
  final KeyPair signatureKeyPair;
  final SmoothDialogController controller;
  final String signature;

  const KeySynchronizationPage({
    super.key,
    required this.signatureKeyPair,
    required this.signature,
    required this.encryptionKeyPair,
    required this.controller,
  });

  @override
  State<KeySynchronizationPage> createState() => _KeySynchronizationPageState();
}

class _KeySynchronizationPageState extends State<KeySynchronizationPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'key.sync.title'.tr,
          style: Get.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        verticalSpacing(sectionSpacing),
        Text(
          "key.sync.desc".tr,
          style: Get.textTheme.bodyMedium,
        ),
        verticalSpacing(sectionSpacing),
        FJElevatedLoadingButton(
          loading: false.obs,
          onTap: () async {
            final json = await postJSON("/account/keys/requests/check", {
              "token": refreshToken,
              "signature":
                  signMessage(widget.signatureKeyPair.secretKey, hashSha(widget.signature + packagePublicKey(widget.encryptionKeyPair.publicKey))),
              "key": "${packagePublicKey(widget.signatureKeyPair.publicKey)}:${packagePublicKey(widget.encryptionKeyPair.publicKey)}",
            });

            if (!json["success"]) {
              showErrorPopup("error", json["error"]);
              return;
            }

            widget.controller.transitionTo(KeyCodePage(
              encryptionKeyPair: widget.encryptionKeyPair,
              signatureKeyPair: widget.signatureKeyPair,
              signature: widget.signature,
            ));
          },
          label: "key.sync.ask_device".tr,
        ),
      ],
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
        if (payload == "") {
          sendLog("couldn't decrypt message ${json["payload"]}");
          return;
        }
        final jsonPayload = jsonDecode(payload);
        await setEncryptedValue("public_key", jsonPayload["pub"]);
        await setEncryptedValue("private_key", jsonPayload["priv"]);
        await setEncryptedValue("signature_public_key", jsonPayload["sig_pub"]);
        await setEncryptedValue("signature_private_key", jsonPayload["sig_priv"]);
        setupManager.retry();
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "key.code".trParams({"code": widget.signature}),
          style: Get.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        verticalSpacing(sectionSpacing),
        Text(
          'key.code.desc'.tr,
          style: Get.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
