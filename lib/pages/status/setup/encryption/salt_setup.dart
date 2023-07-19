import 'package:chat_interface/connection/encryption/aes.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/components/transitions/transition_container.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

late String encryptionSalt;

class SaltSetup extends Setup {
  SaltSetup() : super("setup.salt", true);

  @override
  Future<Widget?> load() async {
    
    final salt = await (db.select(db.setting)..where((tbl) => tbl.key.equals("salt"))).getSingleOrNull();
    var set = false;

    if(salt == null) {
      encryptionSalt = randomAESKey();
      await db.into(db.setting).insert(SettingCompanion.insert(key: "salt", value: encryptionSalt));
      set = true;
    } else {
      encryptionSalt = salt.value;
    }

    return set ? SaltInfoPage(salt: encryptionSalt) : null;
  }
}

class SaltInfoPage extends StatefulWidget {

  final String salt;

  const SaltInfoPage({super.key, required this.salt});

  @override
  State<SaltInfoPage> createState() => _SaltInfoPageState();
}

class _SaltInfoPageState extends State<SaltInfoPage> {
  final copied = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TransitionContainer(
          tag: "login",
          borderRadius: BorderRadius.circular(modelBorderRadius),
          width: 370,
          child: Padding(
            padding: const EdgeInsets.all(modelPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("copy.salt.title".tr, style: Theme.of(context).textTheme.headlineMedium),
                verticalSpacing(sectionSpacing),
                Text("copy.salt".tr, textAlign: TextAlign.center, style: Get.textTheme.bodyMedium),
                verticalSpacing(sectionSpacing),
                SelectableText(widget.salt, style: Theme.of(context).textTheme.labelLarge),
                verticalSpacing(defaultSpacing),
                
                //* Copy button
                SizedBox(
                  width: double.infinity,
                  child: FJElevatedButton(
                    onTap: () {
                      if(copied.value) {
                        setupManager.next();
                        return;
                      }
                  
                      Clipboard.setData(ClipboardData(text: widget.salt));
                      copied.value = true;
                    }, 
                    child: Center(child: Obx(() => Text(!copied.value ? "copy".tr : "continue".tr, style: Get.textTheme.labelLarge)))
                  ),
                ),
              ]
            ),
          ),
        )
      ) 
    );
  }
}