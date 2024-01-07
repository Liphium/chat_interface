import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/components/fj_switch.dart';
import 'package:chat_interface/theme/components/fj_textfield.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../util/vertical_spacing.dart';

class SpaceAddWindow extends StatefulWidget {
  final Offset position;

  const SpaceAddWindow({super.key, required this.position});

  @override
  State<SpaceAddWindow> createState() => _ConversationAddWindowState();
}

class _ConversationAddWindowState extends State<SpaceAddWindow> {
  final public = true.obs;
  final _conversationLoading = false.obs;
  final _errorText = Rx<String?>(null);

  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return SlidingWindowBase(
      position: ContextMenuData(widget.position, true, true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Create a space".tr, style: theme.textTheme.titleMedium),
          verticalSpacing(sectionSpacing),
          Obx(
            () => FJTextField(
              controller: _controller,
              hintText: "Space name".tr,
              errorText: _errorText.value,
            ),
          ),
          verticalSpacing(defaultSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Public", style: Get.theme.textTheme.bodyMedium),
              Obx(
                () => FJSwitch(
                  value: public.value,
                  onChanged: (p0) {
                    public.value = p0;
                  },
                ),
              ),
            ],
          ),
          verticalSpacing(defaultSpacing),
          FJElevatedLoadingButton(
            onTap: () async {
              if (_controller.text.isEmpty) {
                _errorText.value = "enter.name".tr;
                return;
              }

              Get.find<SpacesController>().createSpace(_controller.text, public.value);
              Get.back();
            },
            label: "create".tr,
            loading: _conversationLoading,
          )
        ],
      ),
    );
  }
}
