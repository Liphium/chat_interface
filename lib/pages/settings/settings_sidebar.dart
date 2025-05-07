import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class SettingsSidebar extends StatefulWidget {
  final Signal<SettingCategory?>? category;
  final String? currentCategory;
  final double sidebarWidth;

  const SettingsSidebar({super.key, required this.sidebarWidth, this.currentCategory, this.category});

  @override
  State<SettingsSidebar> createState() => _SettingsSidebarState();
}

class _SettingsSidebarState extends State<SettingsSidebar> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.sidebarWidth),
      child: Padding(
        padding: const EdgeInsets.only(
          top: defaultSpacing * 1.5,
          bottom: defaultSpacing * 1.5,
          right: defaultSpacing,
          left: defaultSpacing * 1.5,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.onInverseSurface,
            borderRadius: BorderRadius.circular(sectionSpacing),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: sectionSpacing, right: sectionSpacing, left: sectionSpacing),
                child: FJElevatedButton(
                  onTap: () => Get.back(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: elementSpacing * 0.5),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back, color: Get.theme.colorScheme.onPrimary),
                        horizontalSpacing(defaultSpacing),
                        Text("back".tr, style: Get.textTheme.labelLarge),
                      ],
                    ),
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  controller: _controller,
                  itemCount: SettingLabel.values.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final current = SettingLabel.values[index];

                    //* Sidebar buttons
                    return Padding(
                      padding: EdgeInsets.only(
                        right: sectionSpacing,
                        left: sectionSpacing,
                        bottom: index == SettingLabel.values.length - 1 ? sectionSpacing : 0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          verticalSpacing(sectionSpacing),
                          Text(current.label.tr, style: Theme.of(context).textTheme.titleLarge),
                          verticalSpacing(defaultSpacing * 0.5),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children:
                                current.categories.map((element) {
                                  if (!element.mobile && GetPlatform.isMobile) {
                                    return const SizedBox();
                                  }
                                  if (!element.web && isWeb) {
                                    return const SizedBox();
                                  }
                                  if (!StatusController.permissions.contains("admin") && element.admin) {
                                    return const SizedBox();
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(top: defaultSpacing),
                                    child: Material(
                                      color:
                                          widget.currentCategory == element.label
                                              ? Get.theme.colorScheme.primary
                                              : Get.theme.colorScheme.inverseSurface,
                                      borderRadius: BorderRadius.circular(defaultSpacing),
                                      child: InkWell(
                                        onTap: () {
                                          if (widget.category != null) {
                                            widget.category!.value = element;
                                          } else {
                                            Get.to(element.widget, transition: Transition.fadeIn);
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(defaultSpacing),
                                        child: Padding(
                                          padding: const EdgeInsets.all(defaultSpacing),
                                          child: Row(
                                            children: [
                                              Icon(
                                                element.icon,
                                                color: Theme.of(context).colorScheme.onPrimary,
                                                size: Get.theme.textTheme.titleLarge!.fontSize! * 1.5,
                                              ),
                                              horizontalSpacing(defaultSpacing),
                                              Expanded(
                                                child: Text(
                                                  "settings.${element.label}".tr,
                                                  style: Theme.of(context).textTheme.labelLarge!,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
