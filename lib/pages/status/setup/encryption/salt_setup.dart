import 'package:chat_interface/connection/encryption/aes.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("copy.salt.title".tr, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center,),
              verticalSpacing(defaultSpacing * 0.25),
              Text("copy.salt".tr, textAlign: TextAlign.center),
              verticalSpacing(defaultSpacing * 0.5),
              SelectableText(widget.salt, style: Theme.of(context).textTheme.labelLarge),
              verticalSpacing(defaultSpacing * 2),
              
              //* Copy button
              ElevatedButton(
                onPressed: () {
                  if(copied.value) {
                    setupManager.next();
                    return;
                  }
              
                  Clipboard.setData(ClipboardData(text: widget.salt));
                  copied.value = true;
                }, 
                child: Obx(() => !copied.value ? Text("copy".tr) : Text("continue".tr))
              ),
            ]
          ),
        )
      ) 
    );
  }
}