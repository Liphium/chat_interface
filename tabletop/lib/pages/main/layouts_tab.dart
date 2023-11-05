import 'package:tabletop/layouts/layout_manager.dart';
import 'package:tabletop/pages/editor/editor_page.dart';
import 'package:tabletop/theme/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LayoutsTab extends StatefulWidget {
  const LayoutsTab({super.key});

  @override
  State<LayoutsTab> createState() => _LayoutsTabState();
}

class _LayoutsTabState extends State<LayoutsTab> {

  final _loading = true.obs;
  final _layouts = <String>[].obs;

  @override
  void initState() {
    loadLayouts();
    super.initState();
  }

  void loadLayouts() async {
    _layouts.value = await LayoutManager.getLayouts();
    _loading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {

      if(_loading.value) {
        return Center(child: CircularProgressIndicator(color: Get.theme.colorScheme.onPrimary));
      }

      if(_layouts.isEmpty) {
        return const Center(child: Text("No layouts found"));
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
                        Icon(Icons.apps, color: Get.theme.colorScheme.onPrimary),
                        horizontalSpacing(elementSpacing),
                        Text(layout, style: Get.theme.textTheme.labelMedium, textHeightBehavior: noTextHeight,),
                        Expanded(child: Container()),
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () {
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