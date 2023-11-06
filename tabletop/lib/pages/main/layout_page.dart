import 'package:file_picker/file_picker.dart';
import 'package:tabletop/layouts/canvas_manager.dart';
import 'package:tabletop/pages/editor/editor_controller.dart';
import 'package:tabletop/pages/editor/editor_page.dart';
import 'package:tabletop/pages/main/canvas_add_dialog.dart';
import 'package:tabletop/pages/main/canvas_tab.dart';
import 'package:tabletop/theme/fj_button.dart';
import 'package:tabletop/theme/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CanvasPage extends StatefulWidget {
  const CanvasPage({super.key});

  @override
  State<CanvasPage> createState() => _CanvasPageState();
}

class _CanvasPageState extends State<CanvasPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(defaultSpacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [          
                Text("Tabletop", style: Get.theme.textTheme.headlineMedium),
          
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ["can"], dialogTitle: "Select a canvas to open");
                        if(result != null) {
                          final path = result.files.single.path!;
                          Get.to(EditorPage(name: "", location: path));
                        }
                      }, 
                      icon: const Icon(Icons.launch),
                    ),
                    horizontalSpacing(defaultSpacing),
                    FJElevatedButton(
                      smallCorners: true,
                      onTap: () {
                        Get.dialog(const CanvasAddDialog());
                      }, 
                      child: Row(
                        children: [
                          Icon(Icons.add, color: Get.theme.colorScheme.onPrimary),
                          horizontalSpacing(elementSpacing),
                          Text("Add", style: Get.theme.textTheme.labelMedium),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        
          //* Canvas list
          const Expanded(
            child: CanvasTab()
          )
        ],
      )
    );
  }
}