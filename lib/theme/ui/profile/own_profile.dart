import 'dart:async';

import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:chat_interface/controller/spaces/space_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/chat/sidebar/friends/friends_page.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/services/chat/status_service.dart';
import 'package:chat_interface/theme/components/forms/icon_button.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/developer_window.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/theme/ui/profile/status_renderer.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:drift_db_viewer/drift_db_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OwnProfile extends StatefulWidget {
  final ContextMenuData position;
  final int size;

  const OwnProfile({super.key, required this.position, this.size = 300});

  @override
  State<OwnProfile> createState() => _ProfileState();
}

class _ProfileState extends State<OwnProfile> with SignalsMixin {
  //* Edit state for buttons
  final edit = signal(false);

  final TextEditingController _status = TextEditingController();
  final statusMessage = signal("");
  final FocusNode _statusFocus = FocusNode();

  // Developer things
  final testLoading = signal(false);
  final _clicks = signal(0);

  @override
  void dispose() {
    _status.dispose();
    _statusFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    _status.text = StatusController.status.value;
    statusMessage.value = StatusController.status.value;

    //* Context menu
    return SlidingWindowBase(
      title: const [],
      position: widget.position,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //* Profile info
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: 30.0, color: theme.colorScheme.onPrimary),
                  horizontalSpacing(defaultSpacing),
                  Text(
                    StatusController.displayName.value,
                    style: theme.textTheme.titleMedium,
                    textHeightBehavior: noTextHeight,
                  ),
                ],
              ),

              //* Copy button
              LoadingIconButton(
                loading: signal(false),
                onTap: () {
                  _clicks.value++;
                  if (_clicks.value > 7) {
                    Get.dialog(const DeveloperWindow());
                  }
                  Clipboard.setData(ClipboardData(text: StatusController.name.value));
                },
                icon: Icons.copy,
              )
            ],
          ),
          verticalSpacing(defaultSpacing),

          //* Status
          Watch((ctx) {
            if (StatusController.ownContainer.value != null) {
              return Padding(
                padding: const EdgeInsets.only(bottom: elementSpacing),
                child: ProfileButton(
                  icon: Icons.stop,
                  label: 'profile.stop_sharing'.tr,
                  onTap: () => StatusController.stopSharing(),
                  loading: signal(false),
                ),
              );
            }

            if (SpaceController.connected.value) {
              return Padding(
                padding: const EdgeInsets.only(bottom: elementSpacing),
                child: ProfileButton(
                  icon: Icons.start,
                  label: 'profile.start_sharing'.tr,
                  onTap: () => StatusController.share(SpaceController.getContainer()),
                  loading: signal(false),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),

          //* Current status type
          RepaintBoundary(
            child: Watch((ctx) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(4, (index) {
                  // Get details
                  Color color = getStatusColor(theme, index);
                  IconData icon = getStatusIcon(index);
                  final bool selected = StatusController.type.value == index;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: elementSpacing),
                    child: Material(
                      color: selected ? theme.colorScheme.primary : theme.colorScheme.inverseSurface,
                      borderRadius: BorderRadius.circular(defaultSpacing),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(defaultSpacing),
                        onTap: () async {
                          final error = await StatusService.sendStatus(type: index);
                          if (error != null) {
                            showErrorPopup("error", error);
                            return;
                          }
                          Get.back();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(defaultSpacing),
                          child: Row(
                            children: [
                              //* Status icon
                              Icon(icon, size: 13.0, color: color),
                              horizontalSpacing(defaultSpacing),
                              Text(
                                "status.${index.toString()}".tr,
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  color: selected ? theme.colorScheme.onSurface : theme.colorScheme.surface,
                                ),
                                textHeightBehavior: noTextHeight,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
          ),

          //* Status message
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //* Profile id
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    edit.value = true;
                    _statusFocus.requestFocus();
                  },
                  child: Watch(
                    (ctx) => Visibility(
                      visible: edit.value,
                      replacement: Text(
                        StatusController.status.value == "" ? 'status.message.add'.tr : StatusController.status.value,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textHeightBehavior: noTextHeight,
                      ),
                      child: TextField(
                        focusNode: _statusFocus,
                        onChanged: (value) => statusMessage.value = value,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintStyle: theme.textTheme.bodyMedium!,
                          hintText: 'status.message'.tr,
                        ),
                        style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.onSurface),

                        //* Save status
                        onEditingComplete: () async {
                          if (_status.text == "") _status.text = "";
                          final error = await StatusService.sendStatus(message: _status.text);
                          if (error != null) {
                            showErrorPopup("error", error);
                            return;
                          }
                          edit.value = false;
                        },

                        inputFormatters: [
                          LengthLimitingTextInputFormatter(70),
                        ],
                        controller: _status,
                      ),
                    ),
                  ),
                ),
              ),

              //* Close button
              Obx(
                () => LoadingIconButton(
                  loading: StatusController.statusLoading,
                  onTap: () async {
                    if (StatusController.status.value == "" && !edit.value) {
                      edit.value = true;
                      _status.text = "";
                      _statusFocus.requestFocus();
                      return;
                    }

                    if (!edit.value) {
                      final error = await StatusService.sendStatus(message: "");
                      if (error != null) {
                        showErrorPopup("error", error);
                        return;
                      }
                      _status.text = "";
                      return;
                    }

                    final error = await StatusService.sendStatus(message: _status.text);
                    if (error != null) {
                      showErrorPopup("error", error);
                      return;
                    }
                    edit.value = false;
                    _statusFocus.unfocus();
                  },
                  icon: statusMessage.value == ""
                      ? Icons.add
                      : edit.value
                          ? Icons.done
                          : Icons.close,
                  color: theme.colorScheme.onPrimary,
                ),
              )
            ],
          ),
          verticalSpacing(defaultSpacing),

          //* Profile settings
          ProfileButton(
            icon: Icons.settings,
            label: 'profile.settings'.tr,
            onTap: () => SettingController.openSettingsPage(),
            loading: signal(false),
          ),
          verticalSpacing(elementSpacing),

          //* Friends page
          ProfileButton(
            icon: Icons.group,
            label: 'profile.friends'.tr,
            onTap: () => showModal(const FriendsPage()),
            loading: signal(false),
          ),
          verticalSpacing(elementSpacing),

          // For debug only database viewer
          if (isDebug)
            Padding(
              padding: const EdgeInsets.only(bottom: elementSpacing),
              child: ProfileButton(
                icon: Icons.hardware,
                label: 'profile.test'.tr,
                onTap: () async {
                  testLoading.value = true;
                  unawaited(Navigator.of(context).push(MaterialPageRoute(builder: (context) => DriftDbViewer(db))));
                  testLoading.value = false;
                },
                loading: testLoading,
              ),
            ),

          // For debug only retry button
          if (isDebug)
            Padding(
              padding: const EdgeInsets.only(bottom: elementSpacing),
              child: ProfileButton(
                icon: Icons.restart_alt,
                label: 'profile.retry'.tr,
                onTap: () async {
                  Get.find<ConnectionController>().restart();
                },
                loading: testLoading,
              ),
            ),

          // Help & resources button
          ProfileButton(
            icon: Icons.launch,
            label: 'help'.tr,
            onTap: () => launchUrlString(Constants.docsBase),
            loading: signal(false),
          ),
        ],
      ),
    );
  }
}
