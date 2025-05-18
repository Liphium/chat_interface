import 'dart:async';
import 'dart:convert';

import 'package:chat_interface/src/rust/api/encryption.dart';
import 'package:chat_interface/util/encryption/packing.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/controller/current/steps/key_step.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/theme/components/forms/icon_button.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class KeyRequest {
  final String session;
  final PublicKey publicKey;
  final VerifyingKey verifyingKey;
  final String payload;
  final String signature;
  final int createdAt;
  final processing = signal(false);

  KeyRequest({
    required this.session,
    required this.publicKey,
    required this.verifyingKey,
    required this.payload,
    required this.signature,
    required this.createdAt,
  });

  static Future<KeyRequest> fromJson(Map<String, dynamic> json) async {
    assert(json["pub"] is String);
    final args = (json["pub"] as String).split(":");
    final ver = await unpackageVerifyingKey(args[0]);
    final pub = await unpackagePublicKey(args[1]);
    assert(ver != null && pub != null);

    return KeyRequest(
      session: json['session'],
      verifyingKey: ver!,
      publicKey: pub!,
      payload: json['payload'],
      signature: json['signature'],
      createdAt: json['creation'],
    );
  }

  Future<Map<String, dynamic>> toJson() async {
    final pub = (await packagePublicKey(publicKey))!;
    final ver = (await packageVerifyingKey(verifyingKey))!;
    return {'session': session, 'pub': '$ver:$pub', 'payload': payload, 'signature': signature, 'creation': createdAt};
  }

  /// Dispose all the signals related to the key request
  void dispose() {
    processing.dispose();
  }

  Future<void> updateStatus(bool delete, Function() success) async {
    // Make the payload
    late final String payload;
    if (delete) {
      payload = "";
    } else {
      // Encode the verification key
      final ver = await packageVerifyingKey(signatureKeyPair.verifyingKey);
      assert(ver != null);

      // Put together the packet from the verification key and the asymmetric container
      final container = await encryptAsymmetricContainer(
        publicKey: publicKey,
        signingKey: signatureKeyPair.signingKey,
        message: packToBytes(
          jsonEncode({
            "enc_pub": (await packagePublicKey(asymmetricKeyPair.publicKey))!,
            "enc_sec": (await packageSecretKey(asymmetricKeyPair.secretKey))!,
            "sig_ver": (await packageVerifyingKey(signatureKeyPair.verifyingKey))!,
            "sig_sig": (await packageSigningKey(signatureKeyPair.signingKey))!,
          }),
        ),
      );
      payload = "$ver:${base64Encode(container!)}";
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

class _KeyRequestsWindowState extends State<KeyRequestsWindow> with SignalsMixin {
  late final _loading = createSignal(false);
  late final _error = createSignal("");
  late final _requests = createListSignal(<KeyRequest>[]);
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
    for (var req in _requests) {
      req.dispose();
    }

    _timer?.cancel();
    super.dispose();
  }

  Future<void> requestKeyRequests() async {
    _loading.value = true;

    // Get the key synchronization requests from the server
    final json = await postAuthorizedJSON("/account/keys/requests/list", {});
    if (!json["success"]) {
      _error.value = (json["error"] as String).tr;
      _loading.value = false;
      return;
    }

    _error.value = "";
    _loading.value = false;

    // Parse all the requests
    for (var request in json["requests"]) {
      final keyRequest = await KeyRequest.fromJson(request);
      if (keyRequest.payload != "") {
        continue;
      }
      if (!_requests.any((element) => keyRequest.session == element.session)) {
        _requests.add(keyRequest);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      title: [
        Expanded(
          child: Text("key_requests.title".tr, style: Get.theme.textTheme.labelLarge, overflow: TextOverflow.ellipsis),
        ),
        Visibility(
          visible: _loading.value,
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(color: Get.theme.colorScheme.onPrimary),
          ),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedErrorContainer(expand: true, padding: const EdgeInsets.only(bottom: defaultSpacing), message: _error),
          Builder(
            builder: (context) {
              // Check if the requests are empty
              if (_requests.isEmpty) {
                return InfoContainer(expand: true, message: "key_requests.empty".tr);
              }

              // Render the requests (if not empty)
              return Column(
                children: List.generate(_requests.length, (index) {
                  final request = _requests[index];
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
                          Watch((ctx) {
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
                                    if (result != null && result) {
                                      _requests.remove(request);
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
                                      _requests.remove(request);
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
            },
          ),
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

class _KeyRequestAcceptWindowState extends State<KeyRequestAcceptWindow> with SignalsMixin {
  late final _error = createSignal("");
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      title: [Text("key_requests.code.title".tr, style: Get.theme.textTheme.labelLarge)],
      child: Column(
        children: [
          Text("key_requests.code.description".tr, style: Get.theme.textTheme.bodyMedium),
          verticalSpacing(defaultSpacing),
          AnimatedErrorContainer(expand: true, padding: const EdgeInsets.only(bottom: defaultSpacing), message: _error),
          FJTextField(
            autofocus: true,
            controller: _codeController,
            hintText: "key_requests.code.placeholder".tr, // DRa6KS
          ),
          verticalSpacing(defaultSpacing),
          FJElevatedLoadingButton(
            loading: widget.request.processing,
            label: "key_requests.code.button".tr,
            onTap: () async {
              // Create everything needed for the signature
              final packagedPub = await encodePublicKey(key: widget.request.publicKey);
              assert(packagedPub != null);

              // Verify the code
              final result = await verifySignature(
                key: widget.request.verifyingKey,
                signature: base64Decode(widget.request.signature),
                message: packToBytes(_codeController.text) + packagedPub!,
              );
              if (result == null || !result) {
                _error.value = "key_requests.code.error".tr; // JEeSqn
                return;
              }

              unawaited(
                widget.request.updateStatus(false, () {
                  Get.back(result: true);
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}
