import 'dart:async';
import 'dart:math';

import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/theme/components/duration_renderer.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SpaceRenderer extends StatefulWidget {
  final bool requestOnInit;
  final SpaceInfo? info;
  final bool pollNewData;
  final bool clickable;
  final bool sidebar;
  final SpaceConnectionContainer container;

  const SpaceRenderer({
    super.key,
    required this.container,
    this.requestOnInit = true,
    this.info,
    this.pollNewData = false,
    this.clickable = false,
    this.sidebar = false,
  });

  @override
  State<SpaceRenderer> createState() => _SpaceRendererState();
}

class _SpaceRendererState extends State<SpaceRenderer> {
  final _loading = true.obs;
  final _info = Rx<SpaceInfo?>(null);
  StreamSubscription<SpaceInfo?>? _sub;

  @override
  void initState() {
    if (!widget.requestOnInit) {
      _loading.value = false;
      return;
    }
    _info.value = widget.info;
    if (_info.value != null) {
      _loading.value = false;
      return;
    }
    loadState();
    super.initState();
  }

  void loadState() async {
    _info.value = await widget.container.getInfo(timer: widget.pollNewData);
    _sub = widget.container.info.listen((info) {
      if (widget.container.cancelled) {
        _loading.value = false;
      }
      _info.value = info;
    });
    if (_info.value!.exists || _info.value!.error || !widget.pollNewData) {
      _loading.value = false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Obx(() {
        if (_loading.value || _info.value == null) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(defaultSpacing),
              color: Get.theme.colorScheme.primaryContainer,
            ),
            padding: const EdgeInsets.all(defaultSpacing),
            child: SizedBox(
              height: 44,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(elementSpacing),
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        color: Get.theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  horizontalSpacing(defaultSpacing),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "chat.space.loading".tr,
                          style: Get.theme.textTheme.labelMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        verticalSpacing(elementSpacing),
                        Text(
                          "#${widget.container.roomId}",
                          style: Get.theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (!_info.value!.exists) {
          if (widget.sidebar) {
            return Container();
          }
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(defaultSpacing),
              color: Get.theme.colorScheme.primaryContainer,
            ),
            padding: const EdgeInsets.all(defaultSpacing),
            child: SizedBox(
              height: 44,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.public_off, color: Get.theme.colorScheme.error, size: 34),
                  horizontalSpacing(defaultSpacing),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "chat.space.not_found".tr,
                          style: Get.theme.textTheme.labelMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        verticalSpacing(elementSpacing),
                        Text(
                          "#${widget.container.roomId}",
                          style: Get.theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final info = _info.value!;
        final partyAmount = info.members.length;
        final renderAmount = min(info.friends.length, 3);

        return Material(
          color: widget.sidebar
              ? Get.theme.colorScheme.primary.withAlpha(100)
              : widget.clickable
                  ? Get.theme.colorScheme.primaryContainer
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(defaultSpacing),
          child: InkWell(
            borderRadius: BorderRadius.circular(defaultSpacing),
            onTap: widget.clickable
                ? () {
                    showConfirmPopup(
                      ConfirmWindow(
                        title: "join.space".tr,
                        text: "join.space.popup".tr,
                        onConfirm: () {
                          Get.find<SpacesController>().join(widget.container);
                        },
                      ),
                    );
                  }
                : null,
            child: Padding(
              padding: widget.clickable ? const EdgeInsets.all(defaultSpacing) : const EdgeInsets.all(0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      /* Info is buggy, so removed for now
                      Visibility(
                        visible: info.title.isNotEmpty,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: defaultSpacing),
                          child: Text(info.title, style: Get.theme.textTheme.labelLarge),
                        ),
                      ),*/
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Visibility(
                            visible: renderAmount > 0,
                            child: Flexible(
                              child: SizedBox(
                                width: 40 + 25 * (renderAmount - 1),
                                height: 44,
                                child: Stack(
                                  children: List.generate(renderAmount, (index) {
                                    return Positioned(
                                      left: index * 25,
                                      child: Tooltip(
                                        message: info.friends[index].displayName.value.text,
                                        child: SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: UserAvatar(
                                            id: info.friends[index].id,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: partyAmount >= renderAmount && renderAmount > 0 && partyAmount != renderAmount,
                            child: Padding(
                              padding: const EdgeInsets.only(left: defaultSpacing),
                              child: Text("+${partyAmount - renderAmount}", style: Get.theme.textTheme.bodyLarge),
                            ),
                          ),
                          Visibility(
                            visible: renderAmount == 0,
                            child: Text("$partyAmount members", style: Get.theme.textTheme.bodyLarge),
                          )
                        ],
                      )
                    ]),
                  ),
                  DurationRenderer(info.start, style: Get.theme.textTheme.bodyLarge)
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
