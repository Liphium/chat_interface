import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/theme/ui/dialogs/profile_picture_window.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DataSettingsPage extends StatelessWidget {
  const DataSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        //* Profile picture
        Text("settings.data.profile_picture".tr, style: Get.theme.textTheme.labelLarge),
        verticalSpacing(defaultSpacing),

        Container(
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(sectionSpacing),
          ),
          padding: const EdgeInsets.all(sectionSpacing),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("settings.data.profile_picture.requirements".tr, style: Get.theme.textTheme.bodyMedium),
                  verticalSpacing(defaultSpacing),
                  Row(
                    children: [
                      FJElevatedButton(
                        smallCorners: true,
                        onTap: () async {
                          final result = await openFile();
                          if(result == null) {
                            return;
                          }
                          final size = await result.length();
                          if(size > 10 * 1000 * 1000) {
                            showErrorPopup("error".tr, "settings.data.profile_picture.requirements".tr);
                            return;
                          }
                      
                          final fileType = result.path.split(".").last;
                          if(!["jpeg", "jpg", "png"].contains(fileType)) {
                            showErrorPopup("error".tr, "settings.data.profile_picture.requirements".tr);
                            return;
                          }
                      
                          Get.dialog(ProfilePictureWindow(file: result));
                        }, 
                        child: Text("Change".tr, style: Get.theme.textTheme.labelMedium)
                      ),
                      horizontalSpacing(defaultSpacing),
                      IconButton(
                        tooltip: "settings.data.profile_picture.remove".tr,
                        onPressed: () => showConfirmPopup(ConfirmWindow(
                          title: "settings.data.profile_picture.remove".tr, 
                          text: "settings.data.profile_picture.remove.confirm".tr, 
                          onConfirm: () => {}, 
                          onDecline: () => {},
                        )), 
                        icon: Icon(Icons.delete, color: Get.theme.colorScheme.onPrimary)
                      )
                    ],
                  )
                ],
              ),
              UserAvatar(
                id: ownAccountId,
                size: 100,
              )
            ],
          ),
        )
      ],
    );
  }
}