import 'dart:convert';

import 'package:chat_interface/connection/encryption/aes.dart';
import 'package:chat_interface/connection/encryption/rsa.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../util/vertical_spacing.dart';

class ProfileSettingsStatus extends StatefulWidget {

  final RxBool enabled;

  const ProfileSettingsStatus({super.key, required this.enabled});

  @override
  State<ProfileSettingsStatus> createState() => _ProfileSettingsStatusState();
}

class _ProfileSettingsStatusState extends State<ProfileSettingsStatus> {

  final loading = false.obs;

  @override
  Widget build(BuildContext context) {

    ThemeData theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("settings.profile.status".tr, style: theme.textTheme.titleMedium),

            Obx(() =>
              widget.enabled.value ? 
              FJElevatedButton(
                smallCorners: true,
                onTap: () async {
                  if(loading.value) return;
                  loading.value = true;

                  // Request data from server
                  final key = randomAESKey();
                  final res = await postRqAuthorized("/account/profile/enable", <String, dynamic>{
                    "key": encryptRSA64(key, asymmetricKeyPair.publicKey)
                  });

                  loading.value = false;

                  if(res.statusCode != 200) {
                    showMessage(SnackbarType.error, "error.offline");
                    return;
                  }

                  final body = jsonDecode(res.body);
                  if(!body["success"]) {
                    return;
                  }
                }, 
                child: Row(
                  children: [
                    Obx(() =>
                      loading.value ?
                      const Padding(
                        padding: EdgeInsets.all(defaultSpacing * 0.5),
                        child: CircularProgressIndicator()
                      ) :
                      Icon(Icons.cancel, color: theme.colorScheme.primary)
                    ),
                    horizontalSpacing(defaultSpacing * 0.5),
                    Text("disable".tr, style: theme.textTheme.bodyMedium!.copyWith(
                      color: theme.colorScheme.onSurface
                    )),
                  ],
                )
              ) :
              FJElevatedButton(
                smallCorners: true,
                onTap: () {
                  showMessage(SnackbarType.error, "Hello world!");
                }, 
                child: Row(
                  children: [
                    Obx(() =>
                      loading.value ?
                      const Padding(
                        padding: EdgeInsets.all(defaultSpacing * 0.5),
                        child: CircularProgressIndicator()
                      ) :
                      Icon(Icons.done_all, color: theme.colorScheme.primary)
                    ),
                    horizontalSpacing(defaultSpacing * 0.5),
                    Text("enable".tr, style: theme.textTheme.bodyMedium!.copyWith(
                      color: theme.colorScheme.onSurface
                    )),
                  ],
                )
              )
            )
          ],
        ),
        verticalSpacing(defaultSpacing * 0.5),
        Padding(
          padding: const EdgeInsets.all(defaultSpacing * 0.5),
          child: Text("settings.profile.status.description".tr, style: theme.textTheme.bodyMedium)
        ),
      ],
    );
  }
}