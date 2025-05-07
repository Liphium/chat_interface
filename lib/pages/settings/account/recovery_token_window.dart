import 'dart:async';

import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/services/account/recovery_token_service.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/theme/components/forms/icon_button.dart';
import 'package:chat_interface/theme/components/forms/lph_action_fields.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class RecoveryToken {
  final DateTime creation;

  RecoveryToken(this.creation);

  factory RecoveryToken.fromJson(Map<String, dynamic> json) {
    return RecoveryToken(DateTime.fromMillisecondsSinceEpoch((json['creation'] as num).toInt()));
  }

  Map<String, dynamic> toJson() {
    return {'creation': creation.millisecondsSinceEpoch};
  }
}

class RecoveryTokenWindow extends StatefulWidget {
  const RecoveryTokenWindow({super.key});

  @override
  State<RecoveryTokenWindow> createState() => _RecoveryTokenWindowState();
}

class _RecoveryTokenWindowState extends State<RecoveryTokenWindow> with SignalsMixin {
  late final _loading = createSignal(false);
  late final _error = createSignal("");
  late final _tokens = createListSignal(<RecoveryToken>[]);
  Timer? _timer;

  @override
  void initState() {
    requestTokens();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      requestTokens();
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Load all the tokens from the server.
  Future<void> requestTokens() async {
    if (_loading.peek()) {
      return;
    }
    _loading.value = true;

    // Get the recovery tokens from the server
    final json = await postAuthorizedJSON("/account/keys/recovery/list", {});
    if (!json["success"]) {
      _error.value = (json["error"] as String).tr;
      _loading.value = false;
      return;
    }

    _error.value = "";
    _loading.value = false;

    // Parse all the recovery tokens
    batch(() {
      _tokens.clear();
      for (var jsonToken in json["list"]) {
        final token = RecoveryToken.fromJson(jsonToken);
        _tokens.add(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      title: [
        Expanded(
          child: Text(
            "recovery_tokens.title".tr,
            style: Get.theme.textTheme.labelLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        horizontalSpacing(elementSpacing),

        // Show a button to open the recovery token deletion dialog
        LoadingIconButton(onTap: () => showModal(RecoveryTokenDeleteWindow()), icon: Icons.delete),
        horizontalSpacing(defaultSpacing),

        // Add a button to add a new recovery token
        LoadingIconButton(
          onTap: () async {
            if (_loading.peek()) {
              return;
            }
            _loading.value = true;

            // Ask for confirmation to make the user aware of what a recovery token is
            final confirmed = await showConfirmPopup(
              ConfirmWindow(
                title: "recovery_tokens.creation.confirm".tr,
                text: "recovery_tokens.creation.description".tr,
              ),
            );
            if (!confirmed) {
              _loading.value = false;
              return;
            }

            // Generate a new recovery key
            final (token, error) = await RecoveryTokenService.generateNewToken();
            if (error != null) {
              showErrorPopup("error", error);
              _loading.value = false;
              return;
            }

            // Show the success window
            unawaited(showModal(RecoveryTokenCopyWindow(token: token!)));
            _loading.value = false;
          },
          icon: Icons.add,
          loading: _loading,
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("recovery_tokens.description".tr, style: Get.textTheme.bodyMedium),
          verticalSpacing(defaultSpacing),
          AnimatedErrorContainer(expand: true, padding: const EdgeInsets.only(bottom: defaultSpacing), message: _error),
          Builder(
            builder: (context) {
              // Check if the requests are empty
              if (_tokens.isEmpty) {
                return InfoContainer(expand: true, message: "recovery_tokens.empty".tr);
              }

              // Render the requests (if not empty)
              return Column(
                children: List.generate(_tokens.length, (index) {
                  final request = _tokens[index];
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
                              formatGeneralTime(request.creation),
                              style: Get.textTheme.labelMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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

class RecoveryTokenDeleteWindow extends StatefulWidget {
  const RecoveryTokenDeleteWindow({super.key});

  @override
  State<RecoveryTokenDeleteWindow> createState() => _RecoveryTokenDeleteWindowState();
}

class _RecoveryTokenDeleteWindowState extends State<RecoveryTokenDeleteWindow> with SignalsMixin {
  late final _loading = createSignal(false);
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
      title: [Text("recovery_tokens.delete.title".tr, style: Get.theme.textTheme.labelLarge)],
      child: Column(
        children: [
          Text("recovery_tokens.delete.description".tr, style: Get.theme.textTheme.bodyMedium),
          verticalSpacing(defaultSpacing),
          AnimatedErrorContainer(expand: true, padding: const EdgeInsets.only(bottom: defaultSpacing), message: _error),
          FJTextField(
            autofocus: true,
            controller: _codeController,
            hintText: "recovery_tokens.delete.placeholder".tr, // DRa6KS
          ),
          verticalSpacing(defaultSpacing),
          FJElevatedLoadingButton(loading: _loading, label: "delete".tr, onTap: () {}),
        ],
      ),
    );
  }
}

class RecoveryTokenCopyWindow extends StatelessWidget {
  final String token;

  const RecoveryTokenCopyWindow({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      title: [Text("recovery_tokens.created.title".tr, style: Get.theme.textTheme.labelLarge)],

      child: Column(
        children: [
          Text("recovery_tokens.created.description".tr, style: Get.theme.textTheme.bodyMedium),
          verticalSpacing(defaultSpacing),
          LPHCopyField(value: token, censor: true, censorPlaceholder: "****-****"),
          verticalSpacing(defaultSpacing),
          FJElevatedButton(
            onTap: () => Get.back(),
            child: Center(child: Text("close".tr, style: Get.textTheme.labelMedium)),
          ),
        ],
      ),
    );
  }
}
