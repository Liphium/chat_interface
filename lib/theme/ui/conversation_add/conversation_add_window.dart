import 'package:chat_interface/controller/chat/friend_controller.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../util/vertical_spacing.dart';

class ConversationAddWindow extends StatefulWidget {

  final Offset position;
  
  const ConversationAddWindow({super.key, required this.position});

  @override
  State<ConversationAddWindow> createState() => _ConversationAddWindowState();
}

class _ConversationAddWindowState extends State<ConversationAddWindow> {

  final members = <int>[].obs;

  @override
  Widget build(BuildContext context) {

    FriendController controller = Get.find();

    return Stack(
      children: [
        Positioned(
          top: widget.position.dy,
          left: widget.position.dx,
          child: SizedBox(
            width: 300,
            child: Material(
              elevation: 2.0,
              borderRadius: BorderRadius.circular(defaultSpacing),
              child: Padding(
                padding: const EdgeInsets.all(defaultSpacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("friends.add".tr, style: Theme.of(context).textTheme.titleMedium),
            
                        Obx(() =>
                          Text("${members.length}/100", style: Theme.of(context).textTheme.bodyMedium)
                        )
                      ],
                    ),
            
                    verticalSpacing(defaultSpacing * 0.5),
            
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: Obx(() => ListView.builder(
                        itemCount: controller.friends.length + 20,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          Friend friend = controller.friends.values.elementAt(0);
                                
                          return Obx(() => Material(
                            color: members.contains(index) ? Theme.of(context).colorScheme.secondaryContainer : Colors.transparent,
                            borderRadius: BorderRadius.circular(defaultSpacing),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(defaultSpacing),
                              onTap: () {
                                if (members.contains(index)) {
                                  members.remove(index);
                                } else {
                                  members.add(index);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: defaultSpacing, vertical: defaultSpacing),
                                child: Row(
                                  children: [
                                    Icon(Icons.person, size: 25, color: Theme.of(context).colorScheme.primary),
                                    horizontalSpacing(defaultSpacing),
                                    Text("${friend.name}#${friend.tag}", style: Theme.of(context).textTheme.bodyLarge),
                                  ],
                                ),
                              ),
                            ),
                          ));
                        },
                      )),
                    ),
            
                    const Divider(),
            
                    //* Create conversation button
                    SizedBox(
                      width: double.infinity,
                      child: ProfileButton(
                        icon: Icons.message,
                        onTap: () {
            
                          if(members.isEmpty) {
                            showMessage(SnackbarType.error, "choose.members".tr);
                          }
            
            
                        },
                        loading: false.obs,
                        label: "friends.create".tr,
                      ),
                    )
                  ],
                ),
              )
            ),
          )
        )
      ]
    );
  }
}