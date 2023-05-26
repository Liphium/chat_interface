import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../util/vertical_spacing.dart';

class ProfileSettingsStatus extends StatefulWidget {

  final bool enabled;

  const ProfileSettingsStatus({super.key, required this.enabled});

  @override
  State<ProfileSettingsStatus> createState() => _ProfileSettingsStatusState();
}

class _ProfileSettingsStatusState extends State<ProfileSettingsStatus> {

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

            widget.enabled ? 
            FJElevatedButton(
              smallCorners: true,
              onTap: () => {}, 
              child: Row(
                children: [
                  Icon(Icons.cancel, color: theme.colorScheme.primary),
                  horizontalSpacing(defaultSpacing * 0.5),
                  Text("disable".tr, style: theme.textTheme.bodyMedium!.copyWith(
                    color: theme.colorScheme.onSurface
                  )),
                ],
              )
            ) :
            FJElevatedButton(
              smallCorners: true,
              onTap: () => {}, 
              child: Row(
                children: [
                  Icon(Icons.done_all, color: theme.colorScheme.primary),
                  horizontalSpacing(defaultSpacing * 0.5),
                  Text("enable".tr, style: theme.textTheme.bodyMedium!.copyWith(
                    color: theme.colorScheme.onSurface
                  )),
                ],
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