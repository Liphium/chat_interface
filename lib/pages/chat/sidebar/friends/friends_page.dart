import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/account/friends/requests_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/sidebar/friends/friend_add_window.dart';
import 'package:chat_interface/pages/chat/sidebar/friends/friend_button.dart';
import 'package:chat_interface/pages/chat/sidebar/friends/request_button.dart';
import 'package:chat_interface/controller/current/steps/friends_setup.dart';
import 'package:chat_interface/theme/components/forms/icon_button.dart';
import 'package:chat_interface/theme/ui/containers/success_container.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

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
    return DialogBase(
      title: [
        Text(
          "friends".tr,
          style: Get.theme.textTheme.labelLarge,
        ),
      ],
      showTitleDesktop: false,
      maxWidth: 500,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 800,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 48,
              child: Material(
                borderRadius: BorderRadius.circular(defaultSpacing),
                color: Get.theme.colorScheme.primary,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: defaultSpacing * 0.5),
                  child: Row(
                    children: [
                      horizontalSpacing(defaultSpacing),
                      Icon(Icons.search, color: Get.theme.colorScheme.onPrimary),
                      horizontalSpacing(defaultSpacing),
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
                            hintStyle: Get.textTheme.bodyMedium,
                            hintText: "friends.placeholder".tr,
                          ),
                          onChanged: (value) {
                            query.value = value;
                          },
                          onSubmitted: (value) => {}, // TODO: Think about what do with this
                          cursorColor: Get.theme.colorScheme.onPrimary,
                        ),
                      ),
                      LoadingIconButton(
                        loading: friendsVaultRefreshing,
                        onTap: () => showModal(const FriendAddWindow()),
                        icon: Icons.person_add_alt_1,
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
                        Obx(
                          () => Animate(
                            effects: [
                              ExpandEffect(
                                curve: Curves.easeInOut,
                                duration: 250.ms,
                                axis: Axis.vertical,
                              ),
                              FadeEffect(
                                end: 0,
                                begin: 1,
                                duration: 250.ms,
                              ),
                            ],
                            target: revealSuccess.value ? 1.0 : 0.0,
                            child: SuccessContainer(text: "request.sent".tr),
                          ),
                        ),

                        Obx(() {
                          final found = friendController.friends.values.any((friend) =>
                              (friend.displayName.value.text.toLowerCase().contains(query.value.toLowerCase()) ||
                                  friend.name.toLowerCase().contains(query.value.toLowerCase())) &&
                              friend.id != StatusController.ownAddress);
                          return Animate(
                              effects: [
                                ExpandEffect(
                                  curve: Curves.easeInOut,
                                  duration: 250.ms,
                                  axis: Axis.vertical,
                                ),
                                FadeEffect(
                                  end: 1,
                                  begin: 0,
                                  duration: 250.ms,
                                ),
                              ],
                              target: found ? 0.0 : 1.0,
                              child: Padding(
                                padding: const EdgeInsets.only(top: defaultSpacing, left: defaultSpacing, right: defaultSpacing),
                                child: Center(
                                  child: Text(
                                    "friends.empty".tr,
                                    style: Get.theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ));
                        }),

                        //* Requests
                        Obx(
                          () => Animate(
                            effects: [
                              ReverseExpandEffect(
                                curve: Curves.easeInOut,
                                duration: 250.ms,
                                axis: Axis.vertical,
                              ),
                              FadeEffect(
                                end: 0,
                                begin: 1,
                                duration: 250.ms,
                              ),
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
                                  Text("friends.requests".tr, style: Get.theme.textTheme.labelLarge),
                                  verticalSpacing(elementSpacing),
                                  Builder(
                                    builder: (context) {
                                      if (requestController.requests.isEmpty) {
                                        return const SizedBox.shrink();
                                      }
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(requestController.requests.length, (index) {
                                          final request = requestController.requests.values.elementAt(index);
                                          return RequestButton(request: request, self: false);
                                        }),
                                      );
                                    },
                                  ),
                                  Visibility(
                                    visible: friendController.friends.length > 1 || requestController.requestsSent.isNotEmpty,
                                    child: verticalSpacing(sectionSpacing - elementSpacing),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),

                        //* Sent requests
                        Obx(
                          () => Animate(
                            effects: [
                              ReverseExpandEffect(
                                curve: Curves.easeInOut,
                                duration: 250.ms,
                                axis: Axis.vertical,
                              ),
                              FadeEffect(
                                end: 0,
                                begin: 1,
                                duration: 250.ms,
                              ),
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
                                    Text("friends.requests_sent".tr, style: Get.theme.textTheme.labelLarge),
                                    verticalSpacing(elementSpacing),
                                    Builder(
                                      builder: (context) {
                                        if (requestController.requestsSent.isEmpty) {
                                          return const SizedBox.shrink();
                                        }
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: List.generate(requestController.requestsSent.length, (index) {
                                            final request = requestController.requestsSent.values.elementAt(index);
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: elementSpacing),
                                              child: RequestButton(request: request, self: true),
                                            );
                                          }),
                                        );
                                      },
                                    ),
                                    Visibility(
                                      visible: friendController.friends.length > 1,
                                      child: verticalSpacing(sectionSpacing - elementSpacing),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

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
                                      final friend = friendController.friends.values.elementAt(index);

                                      if (friend.unknown || friend.id == StatusController.ownAddress) {
                                        return const SizedBox();
                                      }
                                      return Obx(
                                        () {
                                          final visible = query.value.isEmpty ||
                                              friend.displayName.value.text.toLowerCase().contains(query.value.toLowerCase()) ||
                                              friend.name.toLowerCase().contains(query.value.toLowerCase());

                                          return Animate(
                                            effects: [
                                              ReverseExpandEffect(
                                                curve: Curves.easeInOut,
                                                duration: 250.ms,
                                                alignment: Alignment.bottomCenter,
                                                axis: Axis.vertical,
                                              ),
                                              FadeEffect(
                                                end: 0,
                                                begin: 1,
                                                duration: 250.ms,
                                              ),
                                            ],
                                            target: visible ? 0.0 : 1.0,
                                            child: Padding(
                                              padding: EdgeInsets.only(top: index == 0 ? defaultSpacing : elementSpacing),
                                              child: FriendButton(friend: friend, position: position),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
