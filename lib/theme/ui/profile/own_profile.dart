import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/settings/settings_page.dart';
import 'package:chat_interface/theme/components/icon_button.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/theme/ui/profile/status_renderer.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class OwnProfile extends StatefulWidget {

  final Offset position;
  final int size;

  const OwnProfile({super.key, required this.position, this.size = 300});

  @override
  State<OwnProfile> createState() => _ProfileState();
}

class _ProfileState extends State<OwnProfile> {

  //* Edit state for buttons
  final edit = false.obs;

  final TextEditingController _status = TextEditingController();
  final statusMessage = "".obs;
  final FocusNode _statusFocus = FocusNode();

  @override
  void dispose() {
    _status.dispose();
    _statusFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    StatusController controller = Get.find();
    ThemeData theme = Theme.of(context);

    _status.text = controller.status.value;
    statusMessage.value = controller.status.value;

    //* Context menu
    return Stack(
      children: [
        Positioned(
          bottom: widget.position.dy,
          left: widget.position.dx,
          width: widget.size.toDouble(),
          child: Material(
            borderRadius: BorderRadius.circular(defaultSpacing),
            color: theme.colorScheme.onBackground,
            child: Padding(
              padding: const EdgeInsets.all(defaultSpacing),
              child: Column(
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
                          Icon(Icons.person, size: 30.0, color: theme.colorScheme.primary),
                          horizontalSpacing(defaultSpacing),
                          Text(controller.name.value, style: theme.textTheme.titleMedium, textHeightBehavior: noTextHeight,),
                          Text("#${controller.tag.value}", textHeightBehavior: noTextHeight, style: theme.textTheme.titleMedium!
                          .copyWith(fontWeight: FontWeight.normal, color: theme.colorScheme.primary)),
                        ],
                      ),

                      //* Copy button
                      LoadingIconButton(
                        loading: false.obs,
                        onTap: () => {},
                        icon: Icons.copy
                      )
                    ],
                  ),

                  Divider(
                    color: theme.dividerColor,
                  ),

                  //* Status

                  //* Current status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(4, (index) {

                      // Get details
                      Color color = getStatusColor(theme, index);
                      IconData icon = getStatusIcon(index);

                      return Material(
                        color: theme.colorScheme.onBackground,
                        borderRadius: BorderRadius.circular(defaultSpacing),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(defaultSpacing),
                          onTap: () => {},
                          child: Padding(
                            padding: const EdgeInsets.all(defaultSpacing),
                            child: Row(
                              children: [
                                //* Status icon
                                Icon(icon, size: 13.0, color: color),
                                horizontalSpacing(defaultSpacing),
                                Text("status.${index.toString()}".tr, style: theme.textTheme.bodyMedium, textHeightBehavior: noTextHeight),
                              ],
                            ),
                          ),
                        ),
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
                          child: Obx(() => 
                            Visibility(
                              visible: edit.value,
                              replacement: Text(controller.status.value == "-" ? 'status.message.add'.tr : controller.status.value,
                                style: theme.textTheme.bodyMedium,
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
                                onEditingComplete: () {
                                  controller.setStatus(_status.text);
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
                      Obx(() =>
                        LoadingIconButton(
                          loading: false.obs,
                          onTap: () {
                            if(controller.status.value == "-" && !edit.value) {
                              edit.value = true;
                              _status.text = "";
                              _statusFocus.requestFocus();
                              return;
                            }

                            if(!edit.value) {
                              controller.setStatus("-");
                              _status.text = "";
                              return;
                            }
                          
                            edit.value = false;
                            _statusFocus.unfocus();
                            controller.setStatus(_status.text);
                          },
                          icon: statusMessage.value == "-" ? Icons.add : edit.value ? Icons.done : Icons.close,
                          color: theme.colorScheme.primary,
                        )
                      )
                    ],
                  ),

                  Divider(
                    color: theme.dividerColor,
                  ),
                        
                  //* Profile settings
                  ProfileButton(
                    icon: Icons.settings,
                    label: 'profile.settings'.tr,
                    onTap: () => Get.off(const SettingsPage(), duration: 300.ms, transition: Transition.fade, curve: Curves.easeInOut),
                    loading: false.obs
                  ),

                  //* Hide profile
                  ProfileButton(
                    icon: Icons.visibility_off,
                    label: 'profile.hide'.tr,
                    onTap: () => Get.off(const SettingsPage(), duration: 300.ms, transition: Transition.fade, curve: Curves.easeInOut),
                    loading: false.obs
                  ),
                ],
              ),
            ),
          )
        ),
      ],
    );
  }
}