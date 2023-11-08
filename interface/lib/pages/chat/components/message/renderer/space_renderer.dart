import 'dart:math';

import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/theme/components/duration_renderer.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SpaceRenderer extends StatefulWidget {

  final bool requestOnInit;
  final SpaceInfo? info;
  final SpaceConnectionContainer container;

  const SpaceRenderer({super.key, required this.container, this.requestOnInit = true, this.info});

  @override
  State<SpaceRenderer> createState() => _SpaceRendererState();
}

class _SpaceRendererState extends State<SpaceRenderer> {

  final _loading = true.obs;
  SpaceInfo? _info;

  @override
  void initState() {
    if(!widget.requestOnInit) {
      _loading.value = false;
      return;
    }
    _info = widget.info;
    if(_info != null) {
      _loading.value = false;
      return;
    }
    loadState();
    super.initState();
  }

  void loadState() async {
    _info = await widget.container.getInfo();
    _loading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(defaultSpacing),
      child: Obx(() {

        if(_loading.value || _info == null) {
          return Center(child: Padding(
            padding: const EdgeInsets.all(defaultSpacing),
            child: CircularProgressIndicator(
              color: Get.theme.colorScheme.onPrimary,
              backgroundColor: Get.theme.colorScheme.primary,
            ),
          ));
        }

        final info = _info!;
        final partyAmount = info.members.length;
        final renderAmount = min(info.friends.length, 3);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                    visible: info.title.isNotEmpty,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: defaultSpacing),
                      child: Text(info.title, style: Get.theme.textTheme.labelLarge),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Visibility(
                        visible: renderAmount > 0,
                        child: Flexible(
                          child: SizedBox(
                            width: 40 + 25 * (renderAmount - 1),
                            height: 40,
                            child: Stack(
                              children: List.generate(renderAmount, (index) {
                                    
                                return Positioned(
                                  left: index * 25,
                                  child: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: CircleAvatar(
                                      backgroundColor: index % 2 == 0 ? Get.theme.colorScheme.primary : Get.theme.colorScheme.tertiaryContainer,
                                      child: Icon(Icons.person, size: 23, color: Get.theme.colorScheme.onSurface),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: partyAmount >= renderAmount && renderAmount > 0,
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
                ]
              ),
            ),
            DurationRenderer(info.start, style: Get.theme.textTheme.bodyLarge)
          ],
        );
      })
    );
  }
}