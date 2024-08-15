import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/connection/encryption/hash.dart';
import 'package:chat_interface/connection/encryption/signatures.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/controller/current/steps/key_setup.dart';
import 'package:chat_interface/controller/current/steps/stored_actions_setup.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/components/fj_textfield.dart';
import 'package:chat_interface/theme/components/icon_button.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KeyRequest {
  final String session;
  final Uint8List encryptionPub;
  final Uint8List signaturePub;
  final String payload;
  final String signature;
  final int createdAt;
  final processing = false.obs;

  KeyRequest({
    required this.session,
    required this.encryptionPub,
    required this.signaturePub,
    required this.payload,
    required this.signature,
    required this.createdAt,
  });

  factory KeyRequest.fromJson(Map<String, dynamic> json) {
    sendLog(json["pub"]);
    return KeyRequest(
      session: json['session'],
      signaturePub: unpackagePublicKey((json['pub'] as String).split(":")[0]),
      encryptionPub: unpackagePublicKey((json['pub'] as String).split(":")[1]),
      payload: json['payload'],
      signature: json['signature'],
      createdAt: json['creation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session': session,
      'pub': '${packagePublicKey(signaturePub)}:${packagePublicKey(encryptionPub)}',
      'payload': payload,
      'signature': signature,
      'creation': createdAt,
    };
  }

  void updateStatus(bool delete, Function() success) async {
    // Make the payload
    late final String payload;
    if (delete) {
      payload = "";
    } else {
      payload = encryptAsymmetricAnonymous(
        encryptionPub,
        jsonEncode({
          "pub": packagePublicKey(asymmetricKeyPair.publicKey),
          "priv": packagePrivateKey(asymmetricKeyPair.secretKey),
          "sig_pub": packagePublicKey(signatureKeyPair.publicKey),
          "sig_priv": packagePrivateKey(signatureKeyPair.secretKey),
          "profile": packageSymmetricKey(profileKey),
          "sa": storedActionKey,
        }),
      );
    }

    // Respond to the key request
    processing.value = true;
    final json = await postAuthorizedJSON("/account/keys/requests/respond", {
      "session": session,
      "delete": delete,
      "payload": payload,
    });
    processing.value = false;

    if (!json["success"]) {
      showErrorPopup("error", json["error"]);
      return;
    }

    success.call();
  }
}

class KeyRequestsWindow extends StatefulWidget {
  const KeyRequestsWindow({super.key});

  @override
  State<KeyRequestsWindow> createState() => _KeyRequestsWindowState();
}

class _KeyRequestsWindowState extends State<KeyRequestsWindow> {
  final loading = false.obs;
  final error = "".obs;
  final requests = <KeyRequest>[].obs;
  Timer? _timer;

  @override
  void initState() {
    requestKeyRequests();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      requestKeyRequests();
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void requestKeyRequests() async {
    loading.value = true;

    // Get the key synchronization requests from the server
    final json = await postAuthorizedJSON("/account/keys/requests/list", {});
    if (!json["success"]) {
      error.value = (json["error"] as String).tr;
      loading.value = false;
      return;
    }

    error.value = "";
    loading.value = false;

    // Parse all the requests
    for (var request in json["requests"]) {
      final keyRequest = KeyRequest.fromJson(request);
      if (keyRequest.payload != "") {
        return;
      }
      if (!requests.any((element) => keyRequest.session == element.session)) {
        requests.add(keyRequest);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      title: [
        Expanded(
            child: Text(
          "Synchronization requests".tr,
          style: Get.theme.textTheme.labelLarge,
          overflow: TextOverflow.ellipsis,
        )),
        Obx(
          () => Visibility(
            visible: loading.value,
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Get.theme.colorScheme.onPrimary,
              ),
            ),
          ),
        )
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedErrorContainer(
            expand: true,
            padding: const EdgeInsets.all(0),
            message: error,
          ),
          Obx(() {
            // Check if the requests are empty
            if (requests.isEmpty) {
              return InfoContainer(
                expand: true,
                message: "key_requests.empty".tr,
              );
            }

            // Render the requests (if not empty)
            return Column(
              children: List.generate(requests.length, (index) {
                final request = requests[index];
                return Padding(
                  padding: EdgeInsets.only(top: index == 0 ? 0 : defaultSpacing),
                  child: Container(
                    padding: const EdgeInsets.all(defaultSpacing),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.inverseSurface,
                      borderRadius: BorderRadius.circular(defaultSpacing),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.key, color: Get.theme.colorScheme.onPrimary),
                        horizontalSpacing(defaultSpacing),
                        Expanded(
                          child: Text(
                            formatGeneralTime(DateTime.fromMillisecondsSinceEpoch(request.createdAt)),
                            style: Get.textTheme.labelMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        horizontalSpacing(defaultSpacing),
                        Obx(() {
                          if (request.processing.value) {
                            return SizedBox(
                              width: 31,
                              height: 31,
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3.0,
                                  color: Get.theme.colorScheme.onPrimary,
                                ),
                              ),
                            );
                          }

                          return Row(
                            children: [
                              LoadingIconButton(
                                onTap: () async {
                                  final result = await Get.dialog(KeyRequestAcceptWindow(request: request));
                                  if (result) {
                                    requests.remove(request);
                                  }
                                },
                                padding: 0,
                                extra: defaultSpacing,
                                icon: Icons.check,
                              ),
                              horizontalSpacing(elementSpacing),
                              LoadingIconButton(
                                onTap: () {
                                  request.updateStatus(true, () {
                                    requests.remove(request);
                                  });
                                },
                                padding: 0,
                                extra: defaultSpacing,
                                icon: Icons.close,
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                );
              }),
            );
          })
        ],
      ),
    );
  }
}

class KeyRequestAcceptWindow extends StatefulWidget {
  final KeyRequest request;

  const KeyRequestAcceptWindow({super.key, required this.request});

  @override
  State<KeyRequestAcceptWindow> createState() => _KeyRequestAcceptWindowState();
}

class _KeyRequestAcceptWindowState extends State<KeyRequestAcceptWindow> {
  final _error = "".obs;
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      title: [
        Text("key_requests.code.title".tr, style: Get.theme.textTheme.labelLarge),
      ],
      child: Column(
        children: [
          Text("key_requests.code.description".tr, style: Get.theme.textTheme.bodyMedium),
          verticalSpacing(defaultSpacing),
          AnimatedErrorContainer(
            expand: true,
            padding: const EdgeInsets.only(bottom: defaultSpacing),
            message: _error,
          ),
          FJTextField(
            controller: _codeController,
            hintText: "key_requests.code.placeholder".tr, // DRa6KS
          ),
          verticalSpacing(defaultSpacing),
          FJElevatedLoadingButton(
            loading: widget.request.processing,
            label: "key_requests.code.button".tr,
            onTap: () {
              // Verify the code
              if (!checkSignature(widget.request.signature, widget.request.signaturePub, hashSha(_codeController.text + packagePublicKey(widget.request.encryptionPub)))) {
                _error.value = "key_requests.code.error".tr; // JEeSqn
                return;
              }

              widget.request.updateStatus(false, () {
                Get.back(result: true);
              });
            },
          ),
        ],
      ),
    );
  }
}
