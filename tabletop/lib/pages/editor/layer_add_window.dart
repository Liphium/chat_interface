import 'package:tabletop/layouts/layout_manager.dart';
import 'package:tabletop/pages/editor/editor_controller.dart';
import 'package:tabletop/theme/fj_button.dart';
import 'package:tabletop/theme/fj_textfield.dart';
import 'package:tabletop/theme/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LayerAddWindow extends StatefulWidget {

  final Offset position;
  
  const LayerAddWindow({super.key, required this.position});

  @override
  State<LayerAddWindow> createState() => _ConversationAddWindowState();
}

class _ConversationAddWindowState extends State<LayerAddWindow> {

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
            
                    Text("Add a layer", style: Get.theme.textTheme.titleMedium),
            
                    verticalSpacing(sectionSpacing),
            
                    Obx(() =>
                      FJTextField(
                        controller: _controller,
                        hintText: "Layer name",  
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

                        Get.find<EditorController>().addLayer(Layer(_controller.text));
                        Get.back();
                      }, 
                      child: Center(child: Text("Create layer", style: Get.theme.textTheme.labelLarge)),
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