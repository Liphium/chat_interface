import 'package:chat_interface/theme/components/forms/fj_slider.dart';
import 'package:chat_interface/theme/components/forms/fj_switch.dart';
import 'package:chat_interface/theme/components/lph_tab_element.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryData {
  final String name;
  final String id;

  CategoryData(this.name, this.id);

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(json["name"], json["id"]);
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name};
  }
}

class TownAdminSettings extends StatefulWidget {
  const TownAdminSettings({super.key});

  @override
  State<TownAdminSettings> createState() => _TownAdminSettingsState();
}

class _TownAdminSettingsState extends State<TownAdminSettings> {
  // Error things
  final error = "".obs;
  final loading = true.obs;
  String? currentCategory;

  // Current tabs
  final categories = <CategoryData>[];
  final currentTab = Rx<List<dynamic>?>(null);

  @override
  void initState() {
    fetchCategories();
    super.initState();
  }

  /// Get all the categories from the server
  Future<void> fetchCategories() async {
    loading.value = true;
    error.value = "";
    final json = await postAuthorizedJSON("/townhall/settings/categories", {});
    loading.value = false;
    if (!json["success"]) {
      error.value = json["error"];
      return;
    }

    // Parse all the categories
    for (var category in json["categories"]) {
      categories.add(CategoryData.fromJson(category));
    }

    // Fetch category one
    await fetchSettings(categories[0].name);
  }

  /// Fetch the settings for a category
  Future<void> fetchSettings(String name) async {
    final category = categories.firstWhere((c) => c.name == name);
    currentCategory = category.name;
    final json = await postAuthorizedJSON("/townhall/settings/${category.id}", {});
    if (currentCategory != category.name) {
      return;
    }

    // Show an error in case there is one
    if (!json["success"]) {
      showErrorPopup("error", json["error"]);
      return;
    }

    // Load the settings
    currentTab.value = json["settings"];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        //* Settings for the current town (admin only)
        Text("settings.town.settings".tr, style: Get.theme.textTheme.labelLarge),
        verticalSpacing(defaultSpacing),

        Obx(() {
          // Render a loading indicator in case the tabs are still loading
          if (loading.value) {
            return Padding(
              padding: const EdgeInsets.only(top: defaultSpacing),
              child: Padding(
                padding: const EdgeInsets.all(defaultSpacing),
                child: Center(
                  child: CircularProgressIndicator(color: Get.theme.colorScheme.onPrimary),
                ),
              ),
            );
          }

          // Render an error message
          if (error.value != "") {
            return Text(error.value, style: Get.theme.textTheme.bodyMedium);
          }

          // Render the tab overview
          return LPHTabElement(
            tabs: categories.map((c) => c.name).toList(),
            onTabSwitch: (tab) => fetchSettings(tab),
          );
        }),
        verticalSpacing(defaultSpacing),
        Obx(() {
          // Return nothing if there is no tab content
          if (currentTab.value == null) {
            return const SizedBox();
          }

          return Column(
            children: List.generate(
              currentTab.value!.length,
              (index) {
                final setting = currentTab.value![index]!;
                if (setting["visible"] != null && !setting["visible"]) {
                  return const SizedBox();
                }

                Widget? settingsWidget;
                if (setting["value"] is num) {
                  final devider = (setting["dev"] as num).toDouble();
                  final currentValue = (setting["value"] as num).toDouble().obs;
                  settingsWidget = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(setting["label"], style: Get.textTheme.bodyMedium),
                      Obx(
                        () => FJSliderWithInput(
                          secondaryColor: true,
                          min: (setting["min"] as num).toDouble() / devider,
                          value: currentValue.value / devider,
                          max: (setting["max"] as num).toDouble() / devider,
                          onChanged: (val) {
                            currentValue.value = val * devider;
                          },

                          // Update the value on the server
                          onChangeEnd: (val) async {
                            final json = await postAuthorizedJSON("/townhall/settings/set_int", {
                              "name": setting["name"] as String,
                              "value": "${currentValue.value.toInt()}",
                            });
                            if (!json["success"]) {
                              showErrorPopup("error", json["error"]);
                              return;
                            }
                          },
                        ),
                      ),
                    ],
                  );
                } else if (setting["value"] is bool) {
                  final currentValue = (setting["value"] as bool).obs;
                  settingsWidget = Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(setting["label"], style: Get.textTheme.bodyMedium),
                      Obx(
                        () => FJSwitch(
                          value: currentValue.value,
                          onChanged: (val) async {
                            currentValue.value = val;
                            final json = await postAuthorizedJSON("/townhall/settings/set_bool", {
                              "name": setting["name"] as String,
                              "value": "${currentValue.value}",
                            });
                            if (!json["success"]) {
                              showErrorPopup("error", json["error"]);
                              return;
                            }
                          },
                        ),
                      ),
                    ],
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: defaultSpacing),
                  child: settingsWidget,
                );
              },
            ),
          );
        }),
      ],
    );
  }
}
