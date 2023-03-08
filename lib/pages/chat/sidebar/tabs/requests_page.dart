import 'package:chat_interface/controller/chat/friend_controller.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  @override
  Widget build(BuildContext context) {
    FriendController controller = Get.find();
    ThemeData theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
          child: Material(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.secondaryContainer,
            elevation: 2.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultSpacing * 0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.person, color: theme.colorScheme.primary),
                        hintText: 'requests.placeholder'.tr,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => {},
                    icon: const Icon(Icons.person_add, color: Colors.white),
                  )
                ]
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(defaultSpacing),
            itemCount: controller.friends.length,
            itemBuilder: (context, index) {
              Friend friend = controller.friends[index];
        
              return Padding(
                padding: const EdgeInsets.only(bottom: defaultSpacing * 0.5),
                child: Material(
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    hoverColor: Theme.of(context).colorScheme.secondaryContainer.withAlpha(100),
                    splashColor: Theme.of(context).colorScheme.secondaryContainer.withAlpha(100),
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: defaultSpacing, vertical: defaultSpacing * 0.5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person, size: 30, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 10),
                              Text("${friend.name}#${friend.tag}", style: theme.textTheme.titleMedium),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.check, color: Theme.of(context).colorScheme.primary),
                                onPressed: () {},
                              ),
                              horizontalSpacing(defaultSpacing * 0.5),
                              IconButton(
                                icon: Icon(Icons.close, color: Theme.of(context).colorScheme.primary),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ]
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}