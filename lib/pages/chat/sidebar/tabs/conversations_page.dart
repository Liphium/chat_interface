import 'package:chat_interface/controller/chat/conversation_controller.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  @override
  Widget build(BuildContext context) {
    ConversationController controller = Get.find();
    ThemeData theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
          child: SizedBox(
            height: 48,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildInput(theme),
                horizontalSpacing(defaultSpacing),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Material(
                    borderRadius: BorderRadius.circular(10),
                    color: theme.colorScheme.secondaryContainer,
                    elevation: 2.0,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(defaultSpacing),
                        child: Icon(Icons.add, color: theme.colorScheme.primary),
                      ),
                    )
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),

            //* Conversation list
            child: Obx(() => controller.conversations.isNotEmpty ? ListView.builder(
              itemCount: controller.conversations.length,
              addRepaintBoundaries: true,
              padding: const EdgeInsets.only(top: defaultSpacing),
              itemBuilder: (context, index) {
                Conversation conversation = controller.conversations[index];

                final hover = false.obs;
                
                //* Conversation item
                return Padding(
                  padding: const EdgeInsets.only(bottom: defaultSpacing * 0.5),
                  child: Material(
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      hoverColor: theme.colorScheme.secondaryContainer.withAlpha(100),
                      splashColor: theme.hoverColor,
                      onHover: (value) {
                        hover.value = value;
                      },

                      //* When conversation is tapped
                      onTap: () {},

                      //* Conversation item content
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: defaultSpacing, vertical: defaultSpacing * 0.5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            //* Conversation info
                            Row(
                              children: [
                                Icon(Icons.group, size: 35, color: theme.colorScheme.primary),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(conversation.data, style: theme.textTheme.titleMedium),
                                    Text("test", style: theme.textTheme.bodySmall),
                                  ],
                                ),
                              ],
                            ),

                            //* Call button (only visible on hover)
                            Obx(() =>
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: Visibility(
                                  visible: hover.value,
                                  child: IconButton(
                                    icon: Icon(Icons.call, color: theme.colorScheme.primary),
                                    onPressed: () {},
                                  ),
                                ),
                              ),
                            ),
                          ]
                        ),
                      ),
                    ),
                  ),
                );
              },
            ) : Center(child: Text('conversations.empty'.tr, style: theme.textTheme.titleMedium))),
          ),
        ),
      ],
    );
  }
}

Widget buildInput(ThemeData theme) {
  return Expanded(
    child: Material(
      borderRadius: BorderRadius.circular(10),
      color: theme.colorScheme.secondaryContainer,
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: defaultSpacing * 0.5),
        child: TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
            hintText: 'conversations.placeholder'.tr,
          ),
        ),
      ),
    ),
  );
}