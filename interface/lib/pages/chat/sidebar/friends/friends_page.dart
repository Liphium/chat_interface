
import 'dart:async';
import 'dart:math';

import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/account/requests_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/sidebar/friends/friend_button.dart';
import 'package:chat_interface/pages/chat/sidebar/friends/request_button.dart';
import 'package:chat_interface/theme/components/icon_button.dart';
import 'package:chat_interface/theme/ui/containers/success_container.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

part 'friend_actions.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {

  final position = const Offset(0, 0).obs;
  final query = "".obs;
  final loading = false.obs;
  final revealSuccess = false.obs;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    final random = Random();
    final randomOffset = random.nextDouble() * 8 + 5;
    final randomHz = random.nextDouble() * 1 + 1;

    return Animate(
      effects: [
        ScaleEffect(
          delay: 100.ms,
          duration: 500.ms,
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          alignment: Alignment.center,
          curve: const ElasticOutCurve(0.8)
        ),
        ShakeEffect(
          delay: 100.ms,
          duration: 400.ms,
          hz: randomHz,
          offset: Offset(random.nextBool() ? randomOffset : -randomOffset, random.nextBool() ? randomOffset : -randomOffset),
          rotation: 0,
          curve: Curves.decelerate
        ),
        FadeEffect(
          delay: 100.ms,
          duration: 250.ms,
          curve: Curves.easeOut
        )
      ],
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 500,
            maxHeight: 400,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.background,
              borderRadius: BorderRadius.circular(dialogBorderRadius),
            ),
            padding: const EdgeInsets.only(left: dialogPadding, top: dialogPadding, right: dialogPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 48,
                  child: Material(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(defaultSpacing * 1.5),
                      topRight: Radius.circular(defaultSpacing * 1.5),
                    ),
                    color: Get.theme.colorScheme.primary,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: defaultSpacing * 0.5),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              autofocus: true,
                              style: Get.theme.textTheme.labelMedium,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                focusColor: Get.theme.colorScheme.onPrimary,
                                iconColor: Get.theme.colorScheme.onPrimary,
                                fillColor: Get.theme.colorScheme.onPrimary,
                                hoverColor: Get.theme.colorScheme.onPrimary,
                                prefixIcon: Icon(Icons.search, color: Get.theme.colorScheme.onPrimary),
                                hintText: "friends.placeholder".tr,
                              ),
                              onChanged: (value) {
                                query.value = value;
                              },
                              onSubmitted: (value) => doAction(),
                              cursorColor: Get.theme.colorScheme.onPrimary,
                            ),
                          ),
                          LoadingIconButton(
                            loading: requestsLoading,
                            onTap: () => doAction(), 
                            icon: Icons.check
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                
                //* Friends list
                Flexible(
                  child: RepaintBoundary(
                    child: Obx(() {
                      final friendController = Get.find<FriendController>();
                      final requestController = Get.find<RequestController>();
    
                      //* Friends, requests, sent requests list
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
    
                            Obx(() => Animate(
                              effects: [
                                ExpandEffect(
                                  curve: Curves.easeInOut,
                                  duration: 250.ms,
                                  axis: Axis.vertical,
                                )
                              ],
                              target: revealSuccess.value ? 1.0 : 0.0,
                              child: SuccessContainer(text: "request.sent".tr),
                            )),
                      
                            Obx(() {
                              final found = friendController.friends.values.any((friend) => friend.name.toLowerCase().startsWith(query.value.toLowerCase()) && friend.id != ownAccountId);
                              final hashtag = query.value.contains("#");
                              return Animate(
                                effects: [
                                  ExpandEffect(
                                    curve: Curves.easeInOut,
                                    duration: 250.ms,
                                    axis: Axis.vertical,
                                  )
                                ],
                                target: found ? 0.0 : 1.0,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: defaultSpacing),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(defaultSpacing),
                                      color: theme.colorScheme.onBackground,
                                    ),
                                    padding: const EdgeInsets.all(defaultSpacing),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Animate(
                                          effects: [
                                            ReverseExpandEffect(
                                              curve: Curves.easeInOut,
                                              duration: 250.ms,
                                              axis: Axis.vertical,
                                              alignment: Alignment.topLeft
                                            )
                                          ],
                                          target: hashtag ? 1.0 : 0.0,
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: defaultSpacing),
                                            child: Text("friends.empty".tr, style: theme.textTheme.bodyMedium),
                                          ),
                                        ),
                                        hashtag ?
                                        Text("friends.send_request".tr, style: theme.textTheme.labelMedium) :
                                        Text("friends.example".tr, style: theme.textTheme.labelMedium),
                                      ],
                                    ),
                                  ),
                                )
                              );
                            }),
                      
                            //* Requests
                            Obx(() => Animate(
                              effects: [
                                ReverseExpandEffect(
                                  curve: Curves.easeInOut,
                                  duration: 250.ms,
                                  axis: Axis.vertical,
                                )
                              ],
                              target: query.value.isEmpty ? 0.0 : 1.0,
                              child: Visibility(
                                visible: requestController.requests.isNotEmpty,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    verticalSpacing(sectionSpacing),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
                                      child: Text("friends.requests".tr, style: theme.textTheme.labelLarge),
                                    ),
                                    verticalSpacing(elementSpacing),
                                    Builder(
                                      builder: (context) {
                                        if (requestController.requests.isEmpty) {
                                          return const SizedBox.shrink();
                                        }
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: requestController.requests.map((request) {
                                            return RequestButton(request: request, self: false);
                                          }).toList(),
                                        );
                                      },
                                    ),
                                    verticalSpacing(sectionSpacing),
                                  ],
                                )
                              ),
                            )),
                                
                            //* Sent requests
                            Obx(() => Animate(
                              effects: [
                                ReverseExpandEffect(
                                  curve: Curves.easeInOut,
                                  duration: 250.ms,
                                  axis: Axis.vertical,
                                )
                              ],
                              target: query.value.isEmpty ? 0.0 : 1.0,
                              child: Visibility(
                                visible: requestController.requestsSent.isNotEmpty,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: sectionSpacing),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
                                        child: Text("friends.requests_sent".tr, style: theme.textTheme.labelLarge),
                                      ),                                
                                      verticalSpacing(elementSpacing),
                                      Builder(
                                        builder: (context) {
                                          if (requestController.requestsSent.isEmpty) {
                                            return const SizedBox.shrink();
                                          }
                                          return ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: requestController.requestsSent.length,
                                            itemBuilder: (context, index) {
                                              final request = requestController.requestsSent.elementAt(index);
                                              return Padding(
                                                padding: const EdgeInsets.only(bottom: elementSpacing),
                                                child: RequestButton(request: request, self: true),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      verticalSpacing(sectionSpacing - elementSpacing),
                                    ],
                                  ),
                                )
                              )
                            )),
                                
                            //* Friends
                            Visibility(
                              visible: friendController.friends.length > 1,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Builder(
                                    builder: (context) {
                                      if (friendController.friends.length <= 1) {
                                        return const SizedBox.shrink();
                                      }
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: friendController.friends.length,
                                        itemBuilder: (context, index) {
                                          return Obx(() {
                                            final friend = friendController.friends.values.elementAt(index);
                                            final visible = query.value.isEmpty || friend.name.toLowerCase().startsWith(query.value.toLowerCase());
                                            return Visibility(
                                              visible: friend.id != ownAccountId,
                                              child: Animate(
                                                effects: [
                                                  ReverseExpandEffect(
                                                    curve: Curves.easeInOut,
                                                    duration: 250.ms,
                                                    axis: Axis.vertical,
                                                  )
                                                ],
                                                target: visible ? 0.0 : 1.0,
                                                child: Padding(
                                                  padding: EdgeInsets.only(top: index == 0 ? defaultSpacing : elementSpacing),
                                                  child: FriendButton(friend: friend, position: position),
                                                )
                                              ),
                                            );
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ],
                              )
                            ),
                          verticalSpacing(dialogPadding),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void doAction() {
    var args = query.value.split("#");
    if (args.length != 2) {
      // TODO: Open friend settings
      sendLog("TODO: This is where we open friend settings or detect if the friend the user is trying to add doesn't exist");
      return;
    }

    newFriendRequest(args[0], args[1], (message) {
      revealSuccess.value = true;
      Timer(const Duration(seconds: 3), () {
        revealSuccess.value = false;
      });
    });
  }

  Widget buildInput(ThemeData theme) {
    return Expanded(
      child: Material(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(defaultSpacing * 1.5),
        ),
        color: theme.colorScheme.primary,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultSpacing * 0.5),
          child: TextField(
            style: Get.theme.textTheme.labelMedium,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: theme.colorScheme.onPrimary),
              hintText: 'friends.placeholder'.tr,
            ),
          ),
        ),
      ),
    );
  }
}
