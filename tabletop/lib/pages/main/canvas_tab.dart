import 'dart:async';

import 'package:tabletop/layouts/canvas_manager.dart';
import 'package:tabletop/pages/editor/editor_page.dart';
import 'package:tabletop/theme/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CanvasTab extends StatefulWidget {
  const CanvasTab({super.key});

  @override
  State<CanvasTab> createState() => _CanvasTabState();
}

class _CanvasTabState extends State<CanvasTab> {

  final _loading = true.obs;
  final _layouts = <String>[].obs;
  Timer? _timer;

  @override
  void initState() {
    loadCanvass();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      loadCanvass();
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void loadCanvass() async {
    _layouts.value = await CanvasManager.getCanvass();
    _loading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {

      if(_loading.value) {
        return Center(child: CircularProgressIndicator(color: Get.theme.colorScheme.onPrimary));
      }

      if(_layouts.isEmpty) {
        return const Center(child: Text("No canvases found"));
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
        child: ListView.builder(
          itemCount: _layouts.length,
          itemBuilder: (context, index) {
            final layout = _layouts[index];
            
            return Padding(
              padding: const EdgeInsets.only(bottom: defaultSpacing),
              child: Material(
                elevation: 2.0,
                color: Get.theme.colorScheme.onBackground,
                borderRadius: BorderRadius.circular(defaultSpacing),
                child: InkWell(
                  onTap: () {
                    Get.to(EditorPage(name: layout));
                  },
                  hoverColor: Get.theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(defaultSpacing),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: elementSpacing, horizontal: defaultSpacing),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.draw, color: Get.theme.colorScheme.onPrimary),
                        horizontalSpacing(elementSpacing),
                        Text(layout, style: Get.theme.textTheme.labelMedium, textHeightBehavior: noTextHeight,),
                        Expanded(child: Container()),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            CanvasManager.deleteCanvas(layout);
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}