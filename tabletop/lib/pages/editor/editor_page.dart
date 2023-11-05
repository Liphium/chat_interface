import 'package:tabletop/layouts/canvas_manager.dart';
import 'package:tabletop/pages/editor/editor_canvas.dart';
import 'package:tabletop/pages/editor/editor_controller.dart';
import 'package:tabletop/pages/editor/sidebar/editor_sidebar.dart';
import 'package:tabletop/pages/editor/element_settings/element_settings_window.dart';
import 'package:tabletop/theme/fj_button.dart';
import 'package:tabletop/theme/icon_button.dart';
import 'package:tabletop/theme/vertical_spacing.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class EditorPage extends StatefulWidget {

  final String name;

  const EditorPage({super.key, required this.name});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {

  final scale = Rx<double>(1.0);
  final offset = Rx<Offset>(Offset.zero);
  final layout = Rx<Canvas?>(null);
  final _canvasKey = GlobalKey();

  @override
  void initState() {
    loadCanvas();
    super.initState();
  }

  void loadCanvas() async {
    layout.value = await CanvasManager.loadCanvas(widget.name);
    Get.find<EditorController>().setCurrentCanvas(layout.value!);
    await Future.delayed(500.ms);
    Get.find<EditorController>().redoCanvas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.background,
      body: Column(
        children: [
          //* Canvas info
          Container(
            color: Get.theme.colorScheme.onBackground,
            padding: const EdgeInsets.all(defaultSpacing),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                Icon(Icons.apps, color: Get.theme.colorScheme.onPrimary, size: 30),
                horizontalSpacing(elementSpacing),
                Text(widget.name, style: Get.theme.textTheme.titleMedium),
                const Expanded(child: SizedBox()),
                
                //* Current selected toolbar
                Obx(() {
                  final controller = Get.find<EditorController>();

                  return Visibility(
                    visible: controller.currentElement.value != null,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            final element = controller.currentElement.value!;
                            element.position.value = Offset(element.position.value.dx - 1, element.position.value.dy);
                          }
                        ),
                        horizontalSpacing(elementSpacing),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: () {
                            final element = controller.currentElement.value!;
                            element.position.value = Offset(element.position.value.dx + 1, element.position.value.dy);
                          },
                        ),
                        horizontalSpacing(elementSpacing),
                        IconButton(
                          icon: const Icon(Icons.arrow_upward),
                          onPressed: () {
                            final element = controller.currentElement.value!;
                            element.position.value = Offset(element.position.value.dx, element.position.value.dy - 1);
                          }
                        ),
                        horizontalSpacing(elementSpacing),
                        IconButton(
                          icon: const Icon(Icons.arrow_downward),
                          onPressed: () {
                            final element = controller.currentElement.value!;
                            element.position.value = Offset(element.position.value.dx, element.position.value.dy + 1);
                          }
                        ),
                      ],
                    ),
                  );
                }),

                const Expanded(child: SizedBox()),
                Row(
                  children: [
                    LoadingIconButton(
                      loading: Get.find<EditorController>().loading,
                      color: Get.theme.colorScheme.onPrimary,
                      icon: Icons.save,
                      onTap: () => Get.find<EditorController>().redoCanvas(),
                    ),
                    horizontalSpacing(defaultSpacing),
                    Obx(() =>
                      Get.find<EditorController>().showSettings.value ?
                      IconButton.filled(
                        color: Get.theme.colorScheme.onPrimary,
                        icon: const Icon(Icons.settings),
                        onPressed: () => Get.find<EditorController>().showSettings.value = false,
                      ) :
                      IconButton(
                        color: Get.theme.colorScheme.onPrimary,
                        icon: const Icon(Icons.settings),
                        onPressed: () => Get.find<EditorController>().showSettings.value = true,
                      )
                    ),
                    horizontalSpacing(defaultSpacing),
                    FJElevatedButton(
                      smallCorners: true,
                      onTap: () => {},
                      child: Row(
                        children: [
                          Icon(Icons.launch, color: Get.theme.colorScheme.onPrimary),
                          horizontalSpacing(elementSpacing),
                          Text("Play", style: Get.theme.textTheme.labelMedium),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),

          //* Editor
          Expanded(
            child: Row(
              children: [
          
                //* Sidebar
                Container(
                  width: 380,
                  color: Get.theme.colorScheme.onBackground,
                  padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
                  child: const EditorSidebar(),
                ),
          
                //* Editor
                Expanded(
                  child: ClipRect(
                    child: GestureDetector(
                      onTap: () => Get.find<EditorController>().currentElement.value = null,
                      child: Listener(
                        behavior: HitTestBehavior.opaque,
                        onPointerSignal: (event) {
                          if(event is PointerScrollEvent) {
                            final delta = event.scrollDelta.dy * 0.001 * -1;
                            scale.value += delta;
                          }
                        },
                        onPointerMove: (event) {
                          if(event.buttons == 4) {
                            offset.value += event.delta;
                          }
                        },
                        child: Center(
                          child: Obx(() => 
                            layout.value != null ? EditorCanvas(key: _canvasKey, position: offset.value, zoom: scale.value)
                            : Center(child: CircularProgressIndicator(color: Get.theme.colorScheme.onPrimary))
                          ),
                        ),
                      ),
                    ),
                  ) 
                ),

                //* Other sidebar
                Obx(() {
                  final controller = Get.find<EditorController>();
                  final current = controller.currentElement.value;
                
                  return Animate(
                    target: controller.showSettings.value ? 1 : 0,
                    effects: [
                      ExpandEffect(       
                        axis: Axis.horizontal,
                        alignment: Alignment.topLeft,              
                        curve: Curves.easeInOut,
                        duration: 350.ms,
                      )
                    ],
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: 380,
                            color: Get.theme.colorScheme.onBackground,
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
                                child: current == null ? Center(child: Text("Select an element to modify", style: Get.theme.textTheme.bodyMedium)) : ElementSidebar(element: current)
                              ),
                            )
                          ),
                        ),
                      ],
                    ),
                  );
                })
          
              ],
            ),
          ),
        ],
      )
    );
  }
}