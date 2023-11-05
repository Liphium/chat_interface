import 'package:tabletop/pages/main/layout_add_dialog.dart';
import 'package:tabletop/pages/main/layouts_tab.dart';
import 'package:tabletop/theme/fj_button.dart';
import 'package:tabletop/theme/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LayoutPage extends StatefulWidget {
  const LayoutPage({super.key});

  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage> {

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
          
                FJElevatedButton(
                  smallCorners: true,
                  onTap: () {
                    Get.dialog(const LayoutAddDialog());
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
            ),
          ),
        
          //* Layout list
          const LayoutsTab()
        ],
      )
    );
  }
}