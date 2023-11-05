import 'package:tabletop/layouts/canvas_manager.dart';
import 'package:tabletop/pages/editor/editor_controller.dart';
import 'package:tabletop/theme/fj_button.dart';
import 'package:tabletop/theme/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditLayersWindow extends StatefulWidget {

  final Offset position;
  
  const EditLayersWindow({super.key, required this.position});

  @override
  State<EditLayersWindow> createState() => _ConversationAddWindowState();
}

class _ConversationAddWindowState extends State<EditLayersWindow> {

  final _controller = TextEditingController();
  final revealSuccess = false.obs;
  final _error = Rx<String?>(null);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layout = Get.find<EditorController>().currentCanvas.value;

    return Stack(
      children: [
        Positioned(
          top: widget.position.dy,
          left: widget.position.dx,
          child: SizedBox(
            width: 300,
            child: Material(
              elevation: 2.0,
              color: Get.theme.colorScheme.onBackground,
              borderRadius: BorderRadius.circular(dialogBorderRadius),
              child: Padding(
                padding: const EdgeInsets.all(dialogPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            
                    Text("Edit layers", style: Get.theme.textTheme.titleMedium),
            
                    verticalSpacing(sectionSpacing),
            
                    Obx(() =>
                      ReorderableListView.builder(
                        itemCount: layout.layers.length,
                        shrinkWrap: true,
                        buildDefaultDragHandles: false,
                        onReorder: (oldIndex, newIndex) {
                          Get.find<EditorController>().reorderLayer(oldIndex, newIndex);
                        },
                        itemBuilder: (context, index) {
                          final layer = layout.layers[index];
                          return Row(
                            key: ValueKey(layer),
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ReorderableDragStartListener(
                                index: index,
                                child: Icon(Icons.drag_handle, color: Get.theme.colorScheme.onPrimary)
                              ),
                              horizontalSpacing(elementSpacing),
                              Text(layer.name, style: Get.theme.textTheme.labelMedium, textHeightBehavior: noTextHeight,),
                              const Expanded(child: SizedBox()),
                              IconButton(
                                onPressed: () {
                                  Get.find<EditorController>().deleteLayer(layer);
                                }, 
                                icon: const Icon(Icons.delete)
                              )
                            ],
                          );
                        },
                      )
                    ),
                    verticalSpacing(defaultSpacing),
                    FJElevatedButton(
                      onTap: () => Get.back(), 
                      child: Center(child: Text("Done", style: Get.theme.textTheme.labelLarge)),
                    )
                  ],
                ),
              )
            ),
          )
        )
      ]
    );
  }
}