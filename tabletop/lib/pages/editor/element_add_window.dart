import 'package:tabletop/layouts/canvas_manager.dart';
import 'package:tabletop/pages/editor/editor_controller.dart';
import 'package:tabletop/theme/fj_button.dart';
import 'package:tabletop/theme/fj_textfield.dart';
import 'package:tabletop/theme/list_selection.dart';
import 'package:tabletop/theme/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ElementAddWindow extends StatefulWidget {

  final Layer layer;
  final Offset position;
  
  const ElementAddWindow({super.key, required this.layer, required this.position});

  @override
  State<ElementAddWindow> createState() => _ConversationAddWindowState();
}

class _ConversationAddWindowState extends State<ElementAddWindow> {

  final _controller = TextEditingController();
  final revealSuccess = false.obs;
  final _error = Rx<String?>(null);

  final current = 0.obs;
  final items = [
    const SelectableItem("Image", Icons.image),
    const SelectableItem("Text", Icons.text_fields),
    const SelectableItem("Box", Icons.crop_square),
    const SelectableItem("Paragraph", Icons.segment),
    const SelectableItem("Stack", Icons.filter_none),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

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
                    Text("Add an element", style: Get.theme.textTheme.titleMedium),
                    verticalSpacing(sectionSpacing),

                    Text("Pick a type of element", style: Get.theme.textTheme.bodyMedium),
                    verticalSpacing(defaultSpacing),
                    Obx(() =>
                      ListSelection(
                        currentIndex: current.value, 
                        items: items,
                        callback: (item, index) {
                          current.value = index;
                        },
                      )
                    ),
                    verticalSpacing(sectionSpacing),
            
                    Text("Enter a name for your element", style: Get.theme.textTheme.bodyMedium),
                    verticalSpacing(defaultSpacing),

                    Obx(() =>
                      FJTextField(
                        controller: _controller,
                        hintText: "Element name",  
                        errorText: _error.value,
                      )
                    ),
                    verticalSpacing(defaultSpacing),
                    FJElevatedButton(
                      onTap: () {

                        if (_controller.text.length < 3) {
                          _error.value = "Must be at least 3 characters long.";
                          return;
                        }

                        Get.find<EditorController>().addElement(widget.layer, current.value, _controller.text);
                        Get.back();
                      }, 
                      child: Center(child: Text("Create element", style: Get.theme.textTheme.labelLarge)),
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