import 'package:file_picker/file_picker.dart';
import 'package:tabletop/layouts/canvas_manager.dart';
import 'package:tabletop/pages/editor/editor_controller.dart';
import 'package:tabletop/theme/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class SidebarDeckTab extends StatefulWidget {
  const SidebarDeckTab({super.key});

  @override
  State<SidebarDeckTab> createState() => _SidebarElementTabState();
}

class _SidebarElementTabState extends State<SidebarDeckTab> {
  @override
  Widget build(BuildContext context) {
    return GetX<EditorController>(
      builder: (controller) {
        final decks = controller.currentCanvas.value.decks.values.toList();
        return ListView.builder(
          shrinkWrap: true,
          itemCount: decks.length,
          itemBuilder: (context, index) {
            final deck = decks[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: sectionSpacing),
              child: Obx(() {
                final expanded = deck.expanded.value;
                final GlobalKey addKey = GlobalKey();
            
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Animate(
                          effects: [
                            RotateEffect(
                              duration: 100.ms,
                              begin: -0.25,
                              end: 0,
                              alignment: Alignment.center,
                            )
                          ],
                          target: expanded ? 1 : 0,
                          child: IconButton(
                            onPressed: () {
                              deck.expanded.value = !deck.expanded.value;
                            }, 
                            icon: const Icon(Icons.expand_more)
                          ),
                        ),
                        horizontalSpacing(elementSpacing),
                        Icon(Icons.layers, color: Get.theme.colorScheme.onPrimary),
                        horizontalSpacing(elementSpacing),
                        Text(deck.name, style: Get.theme.textTheme.labelMedium, textHeightBehavior: noTextHeight,),
                        const Expanded(child: SizedBox()),
            
                        Visibility(
                          visible: !controller.renderMode.value,
                          child: IconButton(
                            key: addKey,
                            onPressed: () async {
                              final result = await FilePicker.platform.pickFiles(dialogTitle: "Select images for the deck", type: FileType.image, allowMultiple: true);
                              if(result == null) {
                                return;
                              }

                              for(final file in result.files) {
                                controller.addDeckImage(deck, DeckImage(file.path!));
                              }
                            }, 
                            icon: const Icon(Icons.add)
                          ),
                        ),
                      ],
                    ),
            
                    Animate(
                      effects: [
                        ExpandEffect(
                          axis: Axis.vertical,
                          duration: 250.ms,
                          curve: Curves.easeInOut,
                        )
                      ],
                      target: expanded ? 1 : 0,
                      child: Padding(
                        padding: const EdgeInsets.only(left: sectionSpacing),
                        child: Obx(() =>
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: deck.images.length,
                            itemBuilder: (context, index) {
                              final image = deck.images[index];
                      
                              return Padding(
                                padding: const EdgeInsets.only(top: elementSpacing),
                                child: Obx(() =>
                                  Material(
                                    color: Get.theme.colorScheme.onBackground,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(defaultSpacing),
                                      onTap: () => {},
                                      child: Padding(
                                        padding: const EdgeInsets.all(elementSpacing),
                                        child: Row(
                                          children: [
                                            Icon(Icons.image, color: Get.theme.colorScheme.onPrimary),
                                            horizontalSpacing(elementSpacing),
                                            Expanded(child: Text(image.path.split("\\").last, style: Get.theme.textTheme.labelMedium, overflow: TextOverflow.ellipsis, textHeightBehavior: noTextHeight,)),
                                            Visibility(
                                              visible: !controller.renderMode.value,
                                              replacement: IconButton(
                                                onPressed: () {},
                                                icon: const Icon(Icons.delete, color: Colors.transparent)
                                              ),
                                              child: IconButton(
                                                onPressed: () {
                                                  controller.deleteDeckImage(deck, image);
                                                }, 
                                                icon: const Icon(Icons.delete)
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ),
                              );
                            },
                          )
                        ),
                      )
                    )
                  ],
                );
              }),
            );
          },
        );
      },
    );
  }
}