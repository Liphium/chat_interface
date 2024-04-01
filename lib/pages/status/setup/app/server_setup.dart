import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/components/fj_textfield.dart';
import 'package:chat_interface/theme/components/transitions/transition_container.dart';
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
  const ServerSelectorPage({super.key});

  @override
  State<ServerSelectorPage> createState() => _ServerSelectorPageState();
}

class _ServerSelectorPageState extends State<ServerSelectorPage> {
  final TextEditingController _name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.background,
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
                ),
                verticalSpacing(sectionSpacing),
                FJTextField(
                  controller: _name,
                  hintText: "https://example.com",
                ),
                verticalSpacing(defaultSpacing),
                FJElevatedButton(
                  onTap: () => chooseServer(_name.text),
                  child: Center(
                    child: Text('Select server', style: Get.theme.textTheme.labelLarge),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void chooseServer(String path) {
    basePath = "$path/$apiVersion";
    db.into(db.setting).insert(SettingCompanion.insert(key: "server", value: path));
    isHttps = path.startsWith("https://");
    setupManager.next();
  }
}
