import 'dart:async';

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
          setupManager.controller!.transitionTo(widget);
        },
      );

      // Start the SSR process
      ssr.start(
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
      });

      return const SetupLoadingWidget(text: "rendering");
    }

    return null;
  }
}
