import 'package:chat_interface/pages/settings/settings_page_base.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class InvitesPage extends StatefulWidget {
  const InvitesPage({super.key});

  @override
  State<InvitesPage> createState() => _InvitesPageState();
}

class _InvitesPageState extends State<InvitesPage> {
  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    loading.value = true;

    final json = await postAuthorizedJSON("/account/invite/get_all", <String, dynamic>{});
    loading.value = false;

    if (!json["success"]) {
      _error.value = (json["error"] as String).tr;
      return;
    }

    count.value = json["count"];
    if (json["invites"] != null) {
      invites.value = List<String>.from(json["invites"]);
    }
  }

  // Data
  final _error = "".obs;
  final count = 0.obs;
  final invites = <String>[].obs;
  final loading = false.obs;
  final hovering = "".obs;
  final generateLoading = false.obs;

  /// Generate a new invite code
  void generateNewInvite() async {
    generateLoading.value = true;

    final json = await postAuthorizedJSON("/account/invite/generate", <String, dynamic>{});
    if (!json["success"]) {
      showErrorPopup("error", json["error"]);
      generateLoading.value = false;
      return;
    }

    showErrorPopup("success", "settings.invites.generated");
    Clipboard.setData(ClipboardData(text: json["invite"]));

    count.value -= 1;
    invites.insert(0, json["invite"]);
    generateLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPageBase(
      label: "invites",
      child: Obx(() {
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

        if (_error.value != "") {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verticalSpacing(defaultSpacing),
              Text("error".tr, style: Get.theme.textTheme.headlineMedium),
              verticalSpacing(defaultSpacing),
              Text(_error.value, style: Get.theme.textTheme.bodyMedium),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            verticalSpacing(defaultSpacing),
            Obx(() => Text("settings.invites.title".trParams({"count": count.value.toString()}), style: Get.theme.textTheme.headlineMedium)),
            verticalSpacing(defaultSpacing),
            Text("settings.invites.description".tr, style: Get.theme.textTheme.bodyMedium),
            verticalSpacing(defaultSpacing),
            FJElevatedLoadingButtonCustom(
              loading: generateLoading,
              onTap: () => generateNewInvite(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mail_lock, color: Get.theme.colorScheme.onPrimary),
                  horizontalSpacing(defaultSpacing),
                  Text("settings.invites.generate".tr, style: Get.theme.textTheme.labelLarge),
                ],
              ),
            ),
            verticalSpacing(sectionSpacing),

            //* Profile picture
            Text("settings.invites.history".tr, style: Get.theme.textTheme.labelLarge),
            verticalSpacing(defaultSpacing),
            Text("settings.invites.history.description".tr, style: Get.theme.textTheme.bodyMedium),
            verticalSpacing(defaultSpacing),
            Obx(() {
              if (invites.isEmpty) {
                return Text("settings.invites.history.empty".tr, style: Get.theme.textTheme.labelMedium);
              }

              return Column(
                children: [
                  for (final invite in invites)
                    Animate(
                      effects: [
                        ExpandEffect(
                          alignment: Alignment.center,
                          duration: 250.ms,
                          curve: scaleAnimationCurve,
                          axis: Axis.vertical,
                        ),
                      ],
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: elementSpacing),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: elementSpacing, horizontal: defaultSpacing),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(defaultSpacing),
                            color: Get.theme.colorScheme.primaryContainer,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Obx(
                                () => MouseRegion(
                                  onEnter: (_) => hovering.value = invite,
                                  onExit: (_) => hovering.value = "",
                                  child: Animate(
                                    effects: [
                                      BlurEffect(
                                        end: const Offset(5, 5),
                                        duration: 100.ms,
                                      )
                                    ],
                                    onInit: (controller) {
                                      controller.value = 1.0;
                                    },
                                    target: invite == hovering.value ? 0.0 : 1.0,
                                    child: Text(invite, style: Get.theme.textTheme.labelMedium),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: invite));
                                },
                                icon: Icon(Icons.copy, color: Get.theme.colorScheme.onPrimary),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ],
        );
      }),
    );
  }
}
