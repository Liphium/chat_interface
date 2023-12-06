import 'package:tabletop/layouts/canvas_manager.dart';
import 'package:tabletop/pages/editor/editor_controller.dart';
import 'package:tabletop/theme/fj_button.dart';
import 'package:tabletop/theme/fj_textfield.dart';
import 'package:tabletop/theme/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeckAddWindow extends StatefulWidget {

  final Offset position;
  
  const DeckAddWindow({super.key, required this.position});

  @override
  State<DeckAddWindow> createState() => _ConversationAddWindowState();
}

class _ConversationAddWindowState extends State<DeckAddWindow> {

  final _controller = TextEditingController(), _width = TextEditingController(), _height = TextEditingController();
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

                    Text("Add a deck", style: Get.theme.textTheme.titleMedium),
                    verticalSpacing(sectionSpacing),

                    Text("Dimensions of the elements", style: Get.theme.textTheme.bodyMedium),
                    verticalSpacing(defaultSpacing),

                    Row(
                      children: [
                        Expanded(
                          child: FJTextField(
                            controller: _width,
                            hintText: "Width",
                            errorText: _error.value,
                          ),
                        ),
                        horizontalSpacing(defaultSpacing),
                        Text("X", style: Get.theme.textTheme.labelLarge),
                        horizontalSpacing(defaultSpacing),
                        Expanded(
                          child: FJTextField(
                            controller: _height,
                            hintText: "Height",
                            errorText: _error.value,
                          ),
                        )
                      ],
                    ),
                    verticalSpacing(defaultSpacing),

                    verticalSpacing(defaultSpacing),
                    Text("Name of the deck", style: Get.theme.textTheme.bodyMedium),
                    verticalSpacing(defaultSpacing),
              
                    Obx(() =>
                      FJTextField(
                        controller: _controller,
                        hintText: "Deck name",  
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

                        final width = int.tryParse(_width.text);
                        final height = int.tryParse(_height.text);
                        if (width == null || height == null) {
                          _error.value = "Width and height must be numbers.";
                          return;
                        }

                        Get.find<EditorController>().addDeck(Deck(_controller.text, width, height));
                        Get.back();
                      }, 
                      child: Center(child: Text("Create", style: Get.theme.textTheme.labelLarge)),
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