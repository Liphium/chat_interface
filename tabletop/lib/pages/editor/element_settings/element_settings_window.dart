import 'package:tabletop/layouts/canvas_manager.dart' as layout;
import 'package:tabletop/pages/editor/editor_controller.dart';
import 'package:tabletop/pages/editor/element_settings/effect_add_dialog.dart';
import 'package:tabletop/theme/fj_button.dart';
import 'package:tabletop/theme/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class ElementSidebar extends StatefulWidget {

  final layout.Element element;
  
  const ElementSidebar({super.key, required this.element});

  @override
  State<ElementSidebar> createState() => _ConversationAddWindowState();
}

class _ConversationAddWindowState extends State<ElementSidebar> {

  final _controller = TextEditingController();
  final settings = <layout.Setting>[];

  @override
  void dispose() {
    _controller.dispose();
    for(var setting in settings) {
      setting.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EditorController>();

    return Padding(
      padding: const EdgeInsets.all(defaultSpacing),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      
          Text("Modify element", style: Get.theme.textTheme.titleMedium),
          verticalSpacing(defaultSpacing),
        
          ListView.builder(
            itemCount: widget.element.settings.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final setting = widget.element.settings[index];
              final last = index == widget.element.settings.length - 1;
              settings.add(setting);
      
              if(!setting.exposed && controller.renderMode.value) {
                return Container();
              }
        
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                    visible: setting.showLabel,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: defaultSpacing),
                      child: Text(setting.description, style: Get.theme.textTheme.bodyMedium)
                    ),
                  ),
                  setting.build(context),
                  last ? Container() : verticalSpacing(defaultSpacing),
                ],
              );
            },
          ),
          
          verticalSpacing(defaultSpacing),
          FJElevatedButton(
            onTap: () {
              Get.find<EditorController>().save();
            }, 
            child: Center(child: Text("Save", style: Get.theme.textTheme.labelLarge)),
          ),
          verticalSpacing(headerSpacing),
      
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Effects", style: Get.theme.textTheme.titleMedium),  
              FJElevatedButton(
                smallCorners: true,
                onTap: () => Get.dialog(const EffectAddDialog()), 
                child: Row(
                  children: [
                    Icon(Icons.add, color: Get.theme.colorScheme.onPrimary),
                    horizontalSpacing(4),
                    Text("Add", style: Get.theme.textTheme.labelMedium),
                  ],
                )
              )
            ],
          ),
          verticalSpacing(defaultSpacing),

          Obx(() =>
            controller.renderMode.value ? Container() :
            ReorderableListView.builder(
              itemCount: widget.element.effects.length,
              shrinkWrap: true,
              buildDefaultDragHandles: false,
              onReorder: (oldIndex, newIndex) {
                final effect = widget.element.effects.removeAt(oldIndex);
                if(oldIndex < newIndex) newIndex -= 1;
                widget.element.effects.insert(newIndex, effect);
                Get.find<EditorController>().save();
              },
              itemBuilder: (context, index) {
                final effect = widget.element.effects[index];

                return Padding(
                  key: ValueKey(effect),
                  padding: const EdgeInsets.only(bottom: defaultSpacing),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: defaultSpacing, vertical: elementSpacing),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(defaultSpacing),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Obx(() =>
                              Animate(
                                effects: [
                                  RotateEffect(
                                    duration: 100.ms,
                                    begin: -0.25,
                                    end: 0,
                                    alignment: Alignment.center,
                                  )
                                ],
                                target: effect.expanded.value ? 1 : 0,
                                child: IconButton(
                                  onPressed: () {
                                    effect.expanded.value = !effect.expanded.value;
                                  }, 
                                  icon: const Icon(Icons.expand_more)
                                ),
                              )
                            ),
                            horizontalSpacing(elementSpacing),
                            Obx(() =>
                              ReorderableDragStartListener(
                                index: index,
                                child: Text(effect.name, style: effect.expanded.value ? Get.theme.textTheme.labelMedium : Get.theme.textTheme.bodyMedium)
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                widget.element.effects.remove(effect);
                                Get.find<EditorController>().save();
                              },
                            )
                          ],
                        ),

                        Obx(() =>
                          Visibility(
                            visible: effect.expanded.value,
                            child: ListView.builder(
                              itemCount: effect.settings.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final setting = effect.settings[index];
                                final last = index == effect.settings.length - 1;
                                settings.add(setting);
                                                
                                if(!setting.exposed && controller.renderMode.value) {
                                  return Container();
                                }
                                                  
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Visibility(
                                      visible: setting.showLabel,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: defaultSpacing),
                                        child: Text(setting.description, style: Get.theme.textTheme.bodyMedium)
                                      ),
                                    ),
                                    setting.build(context),
                                    last ? Container() : verticalSpacing(defaultSpacing),
                                  ],
                                );
                              },
                            ),
                          )
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}