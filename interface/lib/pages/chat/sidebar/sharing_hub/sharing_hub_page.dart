import 'package:chat_interface/pages/chat/sidebar/conversations/conversations_page.dart';
import 'package:chat_interface/theme/ui/dialogs/conversation_add_window.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SharingHubPage extends StatefulWidget {
  const SharingHubPage({super.key});

  @override
  State<SharingHubPage> createState() => _SharingHubPageState();
}

class _SharingHubPageState extends State<SharingHubPage> {

  final GlobalKey _addKey = GlobalKey();
  final query = "".obs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildSearchInputSidebar(Get.theme, query, hintText: "sharing.placeholder"),
                horizontalSpacing(defaultSpacing * 0.5),
                SizedBox(
                  key: _addKey,
                  width: 48,
                  height: 48,
                  child: Material(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(defaultSpacing * 1.5),
                    ),
                    color: Get.theme.colorScheme.primary,
                    child: InkWell(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(defaultSpacing),
                      ),
                      onTap: () {
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(defaultSpacing),
                        child: Icon(Icons.add, color: Get.theme.colorScheme.onPrimary),
                      ),
                    )
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}