import 'package:chat_interface/services/chat/status_service.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/fj_switch.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class LogOutWindow extends StatefulWidget {
  const LogOutWindow({super.key});

  @override
  State<LogOutWindow> createState() => _ChangeNameWindowState();
}

class _ChangeNameWindowState extends State<LogOutWindow> {
  final _deleteFiles = signal(false);

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("log_out".tr, style: Get.theme.textTheme.titleMedium),
          verticalSpacing(sectionSpacing),
          Text("log_out.dialog".tr, style: Get.theme.textTheme.bodyMedium),
          verticalSpacing(defaultSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("log_out.delete_files".tr, style: Get.theme.textTheme.bodyMedium),
              Watch(
                (ctx) => FJSwitch(
                  value: _deleteFiles.value,
                  onChanged: (value) => _deleteFiles.value = value,
                ),
              ),
            ],
          ),
          verticalSpacing(defaultSpacing),
          Row(
            children: [
              Expanded(
                child: FJElevatedButton(
                  onTap: () async {
                    await StatusService.logOut(
                      deleteEverything: true,
                      deleteFiles: _deleteFiles.value,
                    );
                  },
                  child: Center(child: Text("yes".tr, style: Get.theme.textTheme.labelLarge)),
                ),
              ),
              horizontalSpacing(defaultSpacing),
              Expanded(
                child: FJElevatedButton(
                  onTap: () => Get.back(),
                  child: Center(child: Text("no".tr, style: Get.theme.textTheme.labelLarge)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
