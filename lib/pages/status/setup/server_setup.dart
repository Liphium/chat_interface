import 'dart:async';

import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/theme/components/transitions/transition_controller.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const apiVersion = "v1";

class ServerSetup extends Setup {
  ServerSetup() : super('loading.server', true);

  @override
  Future<Widget?> load() async {
    final server = await (db.select(db.setting)..where((tbl) => tbl.key.equals("server_url"))).getSingleOrNull();

    if (server == null) {
      return const ServerSelectorPage();
    } else {
      basePath = server.value;
      isHttps = server.value.startsWith("https://");
      return null;
    }
  }
}

class ServerSelectorPage extends StatefulWidget {
  final Function()? onSelected;

  const ServerSelectorPage({super.key, this.onSelected});

  @override
  State<ServerSelectorPage> createState() => _ServerSelectorPageState();
}

class _ServerSelectorPageState extends State<ServerSelectorPage> {
  final _error = "".obs;
  final _loading = false.obs;
  final TextEditingController _name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "${'setup.choose.server'.tr}.",
          style: Get.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        verticalSpacing(sectionSpacing),
        FJTextField(
          controller: _name,
          hintText: "placeholder.domain".tr,
        ),
        verticalSpacing(defaultSpacing),
        AnimatedErrorContainer(
          padding: const EdgeInsets.only(bottom: defaultSpacing),
          message: _error,
          expand: true,
        ),
        FJElevatedLoadingButton(
          loading: _loading,
          onTap: () async {
            _loading.value = true;
            final json = await postAny("${formatPath(_name.text)}/pub", {}); // Send a request to get the public key (good test ig)
            _loading.value = false;
            if (json["pub"] == null) {
              _error.value = "server.not_found".tr;
              return;
            }

            // Choose the server if valid
            chooseServer(_name.text);
          },
          label: "select".tr,
        ),
      ],
    );
  }

  /// Format a server path to be usable by the app (prevent user error)
  String formatPath(String path) {
    // If not present, add https:// to make sure the path is correct (maybe a mistake people make)
    if (!path.startsWith("http://") && !path.startsWith("https://")) {
      path = "https://$path";
    }

    // I've seen people put a / at the end of the path and it broke the entire system, so that's fixed now
    if (path.endsWith("/")) {
      path = path.substring(0, path.length - 1);
    }

    return path;
  }

  /// Set a server in the database
  void chooseServer(String path) {
    path = formatPath(path); // Make sure the path is valid

    // Set the path in the app and update it in the database
    basePath = path;
    db.into(db.setting).insertOnConflictUpdate(SettingCompanion.insert(key: "server_url", value: path));
    isHttps = path.startsWith("https://");
    if (widget.onSelected != null) {
      widget.onSelected!.call();
    } else {
      setupManager.next();
    }
  }
}
