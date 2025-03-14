import 'dart:async';

import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/pages/status/setup/server_selector_container.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/pages/status/setup/setup_page.dart';
import 'package:chat_interface/theme/components/ssr/ssr.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

class TokensSetup extends Setup {
  TokensSetup() : super("loading.tokens", false);

  @override
  Future<Widget?> load() async {
    // Check if there are tokens for logging in
    final token = await (db.setting.select()..where((tbl) => tbl.key.equals("tokens"))).getSingleOrNull();
    if (token == null) {
      // Create the SSR renderer
      bool first = true;
      final ssr = SSR(
        startPath: "/account/auth/form",
        onSuccess: (data) {
          loadTokensFromPayload(data);
          setEncryptedValue("tokens", tokensToPayload());
          setupManager.next();
        },
        onRender: (widget) async {
          if (first) {
            // You shall waste 750ms of your life to witness this amazing animation better
            await Future.delayed(const Duration(milliseconds: 750));
            first = false;
          }
          unawaited(setupManager.controller!.transitionTo(widget));
        },
      );

      // Start the SSR process
      unawaited(ssr.start(
        extra: {
          "/account/auth/form": ServerSelectorContainer(
            onSelected: () {
              setupManager.retry();
            },
          ),
        },
      ).then((error) async {
        // You shall waste 750ms of your life to witness this amazing animation better
        await Future.delayed(const Duration(milliseconds: 750));

        // Return error (in here cause cool animation)
        if (error != null) {
          setupManager.error(error);
        }
      }));

      return const SetupLoadingWidget(text: "rendering");
    }

    // Load account stuff from settings
    StatusController.ownAccountId = await retrieveEncryptedValue("cache_account_id") ?? "";
    StatusController.name.value = await retrieveEncryptedValue("cache_account_uname") ?? "";
    StatusController.displayName.value = await retrieveEncryptedValue("cache_account_dname") ?? "";

    // Init file paths with account id
    await AttachmentController.initFilePath(StatusController.ownAccountId);

    return null;
  }
}
