import 'package:chat_interface/controller/chat/account/friend_controller.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class CallMember extends StatefulWidget {

  final Participant participant;
  final Friend friend;

  const CallMember({super.key, required this.participant, required this.friend});

  @override
  State<CallMember> createState() => _CallMemberState();
}

class _CallMemberState extends State<CallMember> {

  final talking = false.obs;

  @override
  void initState() {
    widget.participant.addListener(() {
      talking.value = widget.participant.isSpeaking;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    ThemeData theme = Theme.of(context);

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [

          //* Talking indicator
          Obx(() =>
            talking.value ? 
            Material(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(defaultSpacing),
            ) : 
            Container()
          ),

          //* Name (eventually with profile picture)
          Padding(
            padding: const EdgeInsets.all(defaultSpacing * 0.25),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(defaultSpacing),
              child: Center(
                child: Text(widget.friend.name, style: theme.textTheme.titleMedium)
              )
            ),
          )
        ]
      ),
    );
  }
}