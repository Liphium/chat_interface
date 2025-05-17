import 'dart:async';
import 'dart:convert';

import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/services/account/recovery_token_service.dart';
import 'package:chat_interface/src/rust/api/encryption.dart';
import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/util/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/util/encryption/hash.dart';
import 'package:chat_interface/util/encryption/packing.dart';
import 'package:chat_interface/util/encryption/signatures.dart';
import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/current/connection_controller.dart';
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
import 'package:signals/signals_flutter.dart';
import 'package:sodium_libs/sodium_libs.dart';

import '../../../pages/status/setup/setup_manager.dart';

late AsymmetricKeyPair asymmetricKeyPair;
late SignatureKeyPair signatureKeyPair;

class KeySetup extends ConnectionStep {
  // Keys in the local database
  static const String dbSecretKey = "secret_key";
  static const String dbPublicKey = "public_key";
  static const String dbSigningKey = "signing_key";
  static const String dbVerifyingKey = "verifying_key";

  // Keys for key synchronization step in the local database
  static const String dbKeySyncSecretKey = "key_sync_$dbSecretKey";
  static const String dbKeySyncPublicKey = "key_sync_$dbPublicKey";
  static const String dbKeySyncSigningKey = "key_sync_$dbSigningKey";
  static const String dbKeySyncVerifyingKey = "key_sync_$dbVerifyingKey";
  static const String dbKeySyncSignature = "key_sync_sig";

  KeySetup() : super("loading.keys");

  @override
  Future<SetupResponse> load() async {
    // Get the public key from the server (to check if keys are still the same)
    var res = await postAuthorizedJSON("/account/keys/public/get", <String, dynamic>{});

    // Get keys from the local database (or an empty string)
    var publicKey = await retrieveEncryptedValue("public_key");
    var secretKey = await retrieveEncryptedValue("secret_key");

    // If there is no public key on the server, generate new keys
    bool set = false;
    if (!res["success"]) {
      // Generate new keys
      signatureKeyPair = await generateSignatureKeypair();
      asymmetricKeyPair = await generateAsymmetricKeypair();
      set = true;

      final packagedSign = await encodeSigningKey(key: signatureKeyPair.signingKey);
      final packagedVerify = await encodeVerifyingKey(key: signatureKeyPair.verifyingKey);
      final packagedPriv = await encodeSecretKey(key: asymmetricKeyPair.secretKey);
      final packagedPub = await encodePublicKey(key: asymmetricKeyPair.publicKey);
      final genProfileKey = await generateSymmetricKey();
      final genVaultKey = await generateSymmetricKey();

      // Set public key on the server
      res = await postAuthorizedJSON("/account/keys/public/set", <String, dynamic>{"key": base64Encode(packagedPub!)});
      if (!res["success"]) {
        return SetupResponse(error: "key.error");
      }
      res = await postAuthorizedJSON("/account/keys/profile/set", <String, dynamic>{
        "key": encryptAsymmetricContainer(
          message: (await encodeAndDropSymmetricKey(key: genProfileKey))!,
          publicKey: asymmetricKeyPair.publicKey,
          signingKey: signatureKeyPair.signingKey,
        ),
      });
      if (!res["success"]) {
        return SetupResponse(error: "key.error");
      }
      res = await postAuthorizedJSON("/account/keys/vault/set", <String, dynamic>{
        "key": encryptAsymmetricContainer(
          message: (await encodeAndDropSymmetricKey(key: genVaultKey))!,
          publicKey: asymmetricKeyPair.publicKey,
          signingKey: signatureKeyPair.signingKey,
        ),
      });
      if (!res["success"]) {
        return SetupResponse(error: "key.error");
      }
      res = await postAuthorizedJSON("/account/keys/signature/set", <String, dynamic>{
        "key": base64Encode(packagedVerify!),
      });
      if (!res["success"]) {
        return SetupResponse(error: "key.error");
      }

      // Insert private key into the database
      await setEncryptedValue(dbSecretKey, base64Encode(packagedPriv!));
      await setEncryptedValue(dbPublicKey, base64Encode(packagedPub));

      // Set the signature keys
      await setEncryptedValue(dbSigningKey, base64Encode(packagedSign!));
      await setEncryptedValue(dbPublicKey, base64Encode(packagedVerify));
    } else {
      // Open key synchronization if there are no local keys
      if (publicKey == null || secretKey == null) {
        final res = await openKeySynchronization();
        return SetupResponse(restart: true, error: res);
      }

      // Check if the key is the same as on the server
      if (res["key"] != publicKey) {
        final res = await openKeySynchronization();
        return SetupResponse(restart: true, error: res);
      }

      // Set local key pair
      final decodedPub = await decodePublicKey(data: base64Decode(publicKey));
      final decodedSecret = await decodeSecretKey(data: base64Decode(secretKey));
      asymmetricKeyPair = AsymmetricKeyPair(publicKey: decodedPub!, secretKey: decodedSecret!);
    }

    // Grab signature key from client database (in case not set by previous if statement)
    if (!set) {
      final signingKey = await retrieveEncryptedValue(dbSigningKey);
      final verifyingKey = await retrieveEncryptedValue(dbVerifyingKey);
      if (signingKey == null || verifyingKey == null) {
        return SetupResponse(error: "key.error");
      }
      final decodedSign = await decodeSigningKey(data: base64Decode(signingKey));
      final decodedVerify = await decodeVerifyingKey(data: base64Decode(verifyingKey));
      signatureKeyPair = SignatureKeyPair(signingKey: decodedSign!, verifyingKey: decodedVerify!);
    }

    return SetupResponse();
  }

  /// Method to open the key synchronization during setup (needs extra logic cause an extra request needs to be made)
  static Future<String?> openKeySynchronization() async {
    // Make a completer to wait for the entire operation to be over
    final completer = Completer<String?>();

    // Check if there is a keypair already in there
    late final String signature;
    late final SignatureKeyPair signatureKeyPair;
    late final AsymmetricKeyPair encryptionKeyPair;
    final syncPub = await retrieveEncryptedValue(KeySetup.dbKeySyncPublicKey);
    if (syncPub == null) {
      // Generate the key pairs for key sync exchange
      encryptionKeyPair = await generateAsymmetricKeypair();
      signatureKeyPair = await generateSignatureKeypair();
      signature = getRandomString(8);

      // Insert all the values using the defined constants
      await setEncryptedValue(KeySetup.dbKeySyncPublicKey, (await packagePublicKey(encryptionKeyPair.publicKey))!);
      await setEncryptedValue(KeySetup.dbKeySyncSecretKey, (await packageSecretKey(encryptionKeyPair.secretKey))!);
      await setEncryptedValue(
        KeySetup.dbKeySyncVerifyingKey,
        (await packageVerifyingKey(signatureKeyPair.verifyingKey))!,
      );
      await setEncryptedValue(KeySetup.dbKeySyncSigningKey, (await packageSigningKey(signatureKeyPair.signingKey))!);
      await setEncryptedValue(KeySetup.dbKeySyncSignature, signature);
    } else {
      // Load the key pair and signature using the defined constants
      final syncSecret = (await retrieveEncryptedValue(KeySetup.dbKeySyncSecretKey))!;
      encryptionKeyPair = AsymmetricKeyPair(
        publicKey: (await unpackagePublicKey(syncPub))!,
        secretKey: (await unpackageSecretKey(syncSecret))!,
      );

      // Get the signature key pair using the defined constants
      final syncSigVerify = (await retrieveEncryptedValue(KeySetup.dbKeySyncVerifyingKey))!;
      final syncSigSign = (await retrieveEncryptedValue(KeySetup.dbKeySyncSigningKey))!;
      signatureKeyPair = SignatureKeyPair(
        signingKey: (await unpackageSigningKey(syncSigSign))!,
        verifyingKey: (await unpackageVerifyingKey(syncSigVerify))!,
      );

      // Get the signature
      signature = (await retrieveEncryptedValue("key_sync_sig"))!;
    }

    // Ask the server whether the request already exists
    final json = await postJSON("/account/keys/requests/exists", {"token": refreshToken});

    // Check if there was an error
    if (!json["success"]) {
      return json["error"];
    }

    // Go to the key setup page
    unawaited(
      Get.dialog(
        KeySetupPage(
          signature: signature,
          signatureKeyPair: signatureKeyPair,
          encryptionKeyPair: encryptionKeyPair,
          exists: json["exists"],
        ),
        barrierDismissible: false,
      ),
    );
    return completer.future;
  }
}

class KeySetupPage extends StatefulWidget {
  final AsymmetricKeyPair encryptionKeyPair;
  final SignatureKeyPair signatureKeyPair;
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
          controller: controller,
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
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SmoothDialogWindow(controller: controller);
  }
}

class KeySynchronizationPage extends StatefulWidget {
  final AsymmetricKeyPair encryptionKeyPair;
  final SignatureKeyPair signatureKeyPair;
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
  final _loading = signal(false);

  @override
  void dispose() {
    _loading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('key.sync.title'.tr, style: Get.textTheme.headlineMedium, textAlign: TextAlign.center),
        verticalSpacing(sectionSpacing),
        Text("key.sync.desc".tr, style: Get.textTheme.bodyMedium),
        verticalSpacing(sectionSpacing),
        FJElevatedLoadingButton(
          loading: _loading,
          onTap: () async {
            if (_loading.peek()) {
              return;
            }
            _loading.value = true;

            final json = await postJSON("/account/keys/requests/check", {
              "token": refreshToken,
              "signature": signMessage(
                widget.signatureKeyPair.secretKey,
                hashSha(widget.signature + (await packagePublicKey(widget.encryptionKeyPair.publicKey))!),
              ),
              "key":
                  "${packagePublicKey(widget.signatureKeyPair.publicKey)}:${packagePublicKey(widget.encryptionKeyPair.publicKey)}",
            });
            _loading.value = false;

            if (!json["success"]) {
              showErrorPopup("error", json["error"]);
              return;
            }

            unawaited(
              widget.controller.transitionTo(
                KeyCodePage(
                  encryptionKeyPair: widget.encryptionKeyPair,
                  signatureKeyPair: widget.signatureKeyPair,
                  signature: widget.signature,
                  controller: widget.controller,
                ),
              ),
            );
          },
          label: "key.sync.ask_device".tr,
        ),
        verticalSpacing(defaultSpacing),
        FJElevatedLoadingButton(
          onTap:
              () => widget.controller.transitionTo(
                RecoveryTokenPage(
                  encryptionKeyPair: widget.encryptionKeyPair,
                  signatureKeyPair: widget.signatureKeyPair,
                  signature: widget.signature,
                  controller: widget.controller,
                ),
              ),
          label: "key.sync.use_recovery".tr,
        ),
      ],
    );
  }
}

class KeyCodePage extends StatefulWidget {
  final AsymmetricKeyPair encryptionKeyPair;
  final SignatureKeyPair signatureKeyPair;
  final String signature;
  final SmoothDialogController controller;

  const KeyCodePage({
    super.key,
    required this.signatureKeyPair,
    required this.signature,
    required this.encryptionKeyPair,
    required this.controller,
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
        "signature": signMessage(
          widget.signatureKeyPair.secretKey,
          hashSha(widget.signature + packagePublicKey(widget.encryptionKeyPair.publicKey)),
        ),
        "key":
            "${packagePublicKey(widget.signatureKeyPair.publicKey)}:${packagePublicKey(widget.encryptionKeyPair.publicKey)}",
      });

      if (!json["success"]) {
        showErrorPopup("error", json["error"]);
        return;
      }

      // Add all the keys to the database if there is a payload
      if (json["payload"] != null && json["payload"] != "") {
        final payload = decryptAsymmetricAnonymous(
          widget.encryptionKeyPair.publicKey,
          widget.encryptionKeyPair.secretKey,
          json["payload"],
        );
        if (payload == "") {
          sendLog("couldn't decrypt message ${json["payload"]}");
          return;
        }
        final jsonPayload = jsonDecode(payload);
        await setEncryptedValue("public_key", jsonPayload["pub"]);
        await setEncryptedValue("secret_key", jsonPayload["priv"]);
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
        Text('key.code.desc'.tr, style: Get.textTheme.bodyMedium),
        verticalSpacing(defaultSpacing),
        FJElevatedLoadingButton(
          onTap:
              () => widget.controller.transitionTo(
                KeySynchronizationPage(
                  signatureKeyPair: widget.signatureKeyPair,
                  signature: widget.signature,
                  encryptionKeyPair: widget.encryptionKeyPair,
                  controller: widget.controller,
                ),
              ),
          label: "back".tr,
        ),
      ],
    );
  }
}

class RecoveryTokenPage extends StatefulWidget {
  final KeyPair signatureKeyPair, encryptionKeyPair;
  final String signature;
  final SmoothDialogController controller;

  const RecoveryTokenPage({
    super.key,
    required this.signatureKeyPair,
    required this.encryptionKeyPair,
    required this.signature,
    required this.controller,
  });

  @override
  State<RecoveryTokenPage> createState() => _RecoveryTokenPageState();
}

class _RecoveryTokenPageState extends State<RecoveryTokenPage> with SignalsMixin {
  late final _loading = createSignal(false);
  late final _error = createSignal("");
  final _tokenController = TextEditingController();

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("key.recovery.title".tr, style: Get.textTheme.headlineMedium, textAlign: TextAlign.center),
        verticalSpacing(sectionSpacing),
        Text('key.recovery.desc'.tr, style: Get.textTheme.bodyMedium),
        verticalSpacing(sectionSpacing),
        FJTextField(hintText: "recovery_tokens.delete.placeholder".tr, autofocus: true, controller: _tokenController),
        verticalSpacing(defaultSpacing),
        AnimatedErrorContainer(message: _error, padding: const EdgeInsets.only(bottom: defaultSpacing), expand: true),
        FJElevatedLoadingButton(
          loading: _loading,
          onTap: () async {
            if (_loading.peek()) {
              return;
            }
            _loading.value = true;
            _error.value = "";

            // Parse the token
            final args = _tokenController.text.split("-");

            // Get the token to see if it is correct
            var json = await postJSON("/account/keys/recovery/get", {
              "session_token": refreshToken,
              "recovery_token": args[0],
            });
            if (!json["success"]) {
              _loading.value = false;
              _error.value = json["error"];
              return;
            }

            // Try decrypting
            RecoveryKeyStorage? storage;
            try {
              storage = await RecoveryKeyStorage.fromEncrypted(json["data"], args[1]);
              if (storage == null) {
                _loading.value = false;
                _error.value = "key.recovery.decryption_error".tr;
                return;
              }
            } catch (e) {
              sendLog("ERROR: couldn't decrypt recovery token: $e");
              _loading.value = false;
              _error.value = "key.recovery.decryption_error".tr;
              return;
            }

            // Verify the session with the token in case it succeeded
            json = await postJSON("/account/keys/recovery/use", {
              "session_token": refreshToken,
              "recovery_token": args[0],
            });
            if (!json["success"]) {
              _loading.value = false;
              _error.value = json["error"];
              return;
            }

            // Save all the keys to the local database and restart
            await setEncryptedValue(
              KeySetup.dbPublicKey,
              (await packagePublicKey(storage.encryptionKeyPair.publicKey))!,
            );
            await setEncryptedValue(
              KeySetup.dbSecretKey,
              (await packageSecretKey(storage.encryptionKeyPair.secretKey))!,
            );
            await setEncryptedValue(
              KeySetup.dbVerifyingKey,
              (await packageVerifyingKey(storage.signatureKeyPair.verifyingKey))!,
            );
            await setEncryptedValue(
              KeySetup.dbSigningKey,
              (await packageSigningKey(storage.signatureKeyPair.signingKey))!,
            );
            setupManager.retry();
          },
          label: "check".tr,
        ),
        verticalSpacing(defaultSpacing),
        FJElevatedLoadingButton(
          onTap:
              () => widget.controller.transitionTo(
                KeySynchronizationPage(
                  signatureKeyPair: widget.signatureKeyPair,
                  signature: widget.signature,
                  encryptionKeyPair: widget.encryptionKeyPair,
                  controller: widget.controller,
                ),
              ),
          label: "back".tr,
        ),
      ],
    );
  }
}
