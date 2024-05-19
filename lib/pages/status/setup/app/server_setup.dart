import 'dart:async';

import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/components/fj_textfield.dart';
import 'package:chat_interface/theme/components/transitions/transition_container.dart';
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
    final server = await (db.select(db.setting)..where((tbl) => tbl.key.equals("server"))).getSingleOrNull();

    if (server == null) {
      return const ServerSelectorPage();
    } else {
      basePath = "${server.value}/$apiVersion";
      isHttps = server.value.startsWith("https://");
      return null;
    }
  }
}

class ServerSelectorPage extends StatefulWidget {
  final Widget? nextPage;

  const ServerSelectorPage({super.key, this.nextPage});

  @override
  State<ServerSelectorPage> createState() => _ServerSelectorPageState();
}

class _ServerSelectorPageState extends State<ServerSelectorPage> {
  final _error = "".obs;
  final _loading = false.obs;
  final TextEditingController _name = TextEditingController();

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
                    final json = await postAny("${formatPath(_name.text)}/v1/pub", {}); // Send a request to get the public key (good test ig)
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
                if (widget.nextPage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: defaultSpacing),
                    child: FJElevatedLoadingButton(
                      loading: false.obs,
                      onTap: () async {
                        Get.find<TransitionController>().modelTransition(widget.nextPage);
                      },
                      label: "back".tr,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
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
    basePath = "$path/$apiVersion";
    db.into(db.setting).insertOnConflictUpdate(SettingCompanion.insert(key: "server", value: path));
    isHttps = path.startsWith("https://");
    if (widget.nextPage != null) {
      Get.find<TransitionController>().modelTransition(widget.nextPage);
    } else {
      setupManager.next();
    }
  }
}
