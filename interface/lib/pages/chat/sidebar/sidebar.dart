import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/sidebar/sidebar_profile.dart';
import 'package:chat_interface/theme/dialog_route.dart';
import 'package:chat_interface/theme/ui/dialogs/conversation_add_window.dart';
import 'package:chat_interface/theme/ui/profile/status_renderer.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {

  final query = "".obs;
  final GlobalKey _addKey = GlobalKey();

  @override
  Widget build(BuildContext context) {

    ThemeData theme = Theme.of(context);
    
    MessageController messageController = Get.find();
    StatusController statusController = Get.find();
    FriendController friendController = Get.find();
    ConversationController controller = Get.find();

    //* Sidebar
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onBackground,
      ),

      //* Sidebar content
      child: Padding(
        padding: const EdgeInsets.only(top: defaultSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      
            //* Search field
            SizedBox(
              height: 48,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Material(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(defaultSpacing * 1.5),
                        ),
                        color: theme.colorScheme.primary,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: defaultSpacing * 0.5),
                          child: TextField(
                            style: theme.textTheme.labelMedium,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusColor: theme.colorScheme.onPrimary,
                              iconColor: theme.colorScheme.onPrimary,
                              fillColor: theme.colorScheme.onPrimary,
                              hoverColor: theme.colorScheme.onPrimary,
                              prefixIcon: Icon(Icons.search, color: theme.colorScheme.onPrimary),
                              hintText: "conversations.placeholder".tr,
                            ),
                            onChanged: (value) {
                              query.value = value;
                            },
                            cursorColor: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    horizontalSpacing(defaultSpacing * 0.5),
                    SizedBox(
                      key: _addKey,
                      width: 48,
                      height: 48,
                      child: Material(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(defaultSpacing * 1.5),
                        ),
                        color: theme.colorScheme.primary,
                        child: InkWell(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(defaultSpacing),
                          ),
                          onTap: () {
                            final RenderBox box = _addKey.currentContext?.findRenderObject() as RenderBox;
                                  
                            //* Open conversation add window
                            Get.dialog(ConversationAddWindow(position: box.localToGlobal(box.size.bottomLeft(const Offset(0, 5)))));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(defaultSpacing),
                            child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
                          ),
                        )
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //* Selected tab
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
                child: Obx(() {
                  return ListView.builder(
                    itemCount: controller.conversations.length,
                    addRepaintBoundaries: true,
                    padding: const EdgeInsets.only(top: defaultSpacing),
                    itemBuilder: (context, index) {
                      Conversation conversation = controller.conversations.values.elementAt(index);
                  
                      Friend? friend;
                      if(!conversation.isGroup) {
                        String id = conversation.members.values.firstWhere((element) => element.account != statusController.id.value).account;
                        friend = friendController.friends[id];
                      }
                  
                      final hover = false.obs;
                      
                      //* Conversation item
                      return Obx(() {
                        var title = conversation.isGroup || friend == null ? conversation.containerSub.value.name : conversation.dmName;
                        if(friend == null) {
                          title = ".$title";
                        }
              
                        if(query.value != "") {
                          if(!title.toLowerCase().startsWith(query.value.toLowerCase())) {
                            return const SizedBox.shrink();
                          }
                        } else if(friend == null) {
                          return const SizedBox.shrink();
                        }
              
                        return Padding(
                          padding: const EdgeInsets.only(bottom: defaultSpacing * 0.5),
                          child: Obx(() => 
                          Material(
                            borderRadius: BorderRadius.circular(10),
                            color: messageController.selectedConversation.value == conversation ? theme.colorScheme.primary : Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              hoverColor: theme.colorScheme.primary.withAlpha(150),
                              splashColor: theme.hoverColor,
                              onHover: (value) {
                                hover.value = value;
                              },
                    
                              //* When conversation is tapped (open conversation)
                              onTap: () {
                                if(messageController.selectedConversation.value == conversation) return;
                                messageController.selectConversation(conversation);
                              },
                    
                              //* Conversation item content
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: defaultSpacing, vertical: defaultSpacing * 0.5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                    
                                    //* Conversation info
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(conversation.isGroup ? Icons.group : friend == null ? Icons.person_off : Icons.person, size: 35, color: theme.colorScheme.onPrimary),
                                          horizontalSpacing(defaultSpacing * 0.75),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                    
                    
                                                //* Conversation title
                                                Obx(() {
              
                                                  if(conversation.isGroup) {
                                                    return Text(conversation.containerSub.value.name, style: messageController.selectedConversation.value == conversation ? theme.textTheme.labelMedium : theme.textTheme.bodyMedium,
                                                      textHeightBehavior: noTextHeight,
                                                    );
                                                  }
              
                                                  if(friend == null) {
                                                    return Row(
                                                      children: [
                                                        Flexible(
                                                          child: Text(conversation.containerSub.value.name, style: messageController.selectedConversation.value == conversation ? theme.textTheme.labelMedium : theme.textTheme.bodyMedium,
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            textHeightBehavior: noTextHeight,
                                                          ),
                                                        ),
                                                        horizontalSpacing(defaultSpacing),
                                                      ],
                                                    );
                                                  }
              
                                                  return Row(
                                                    children: [
                                                      Flexible(
                                                        child: Text(conversation.dmName, style: messageController.selectedConversation.value == conversation ? theme.textTheme.labelMedium : theme.textTheme.bodyMedium,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          textHeightBehavior: noTextHeight,
                                                        ),
                                                      ),
                                                      horizontalSpacing(defaultSpacing),
                                                      StatusRenderer(status: friend.statusType.value),
                                                    ],
                                                  );
                                                }),
                    
                                                friend == null ?
                                                verticalSpacing(elementSpacing * 0.5) :
                                                Visibility(
                                                  visible: conversation.isGroup || friend.status.value != "-",
                                                  child: verticalSpacing(defaultSpacing * 0.25),
                                                ),
                                                                      
                                                // Conversation description
                                                conversation.isGroup ?
                                                Text(
                                                                    
                                                  //* Conversation status message
                                                  "chat.members".trParams(<String, String>{
                                                    'count': conversation.members.length.toString()
                                                  }),
                                                                    
                                                  style: theme.textTheme.bodySmall,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ) :
                  
                                                //* Friend status message
                                                friend == null ?
                                                Text(
                                                  friend != null ? friend.status.value : "friend.removed".tr,
                                                  style: theme.textTheme.bodySmall,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  textHeightBehavior: noTextHeight,
                                                ) :
                                                Obx(() =>
                                                  Visibility(
                                                    visible: friend!.status.value != "-" && friend.statusType.value != statusOffline,
                                                    child: Text(
                                                      friend.status.value,
                                                      style: theme.textTheme.bodySmall,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      textHeightBehavior: noTextHeight,
                                                    ),
                                                  )
                                                ),
                                                
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]
                                ),
                              ),
                            ),
                          )),
                        );
                      });
                    },
                  );
                }),
              )
            ),
            const SidebarProfile()
          ]
        ),
      ),
    );
  }
}
