import 'package:chat_interface/controller/chat/conversation/call/call_member_controller.dart';
import 'package:chat_interface/pages/chat/components/call/entities/member_entity.dart';
import 'package:chat_interface/pages/chat/components/call/widgets/call_controls.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallRectangle extends StatefulWidget {
  const CallRectangle({super.key});

  @override
  State<CallRectangle> createState() => _CallRectangleState();
}

class _CallRectangleState extends State<CallRectangle> {
  @override
  Widget build(BuildContext context) {

    return Material(
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.all(defaultSpacing * 2),
            child: GetX<CallMemberController>(
              builder: (controller) {
            
                // Compute all widgets
                List<Widget> widgets = [];
                for (Member member in controller.members) {
                  widgets.addAll(renderMember(member));
                }
            
                return Column(
                  children: [
                    RepaintBoundary(
                      child: Wrap(
                        spacing: defaultSpacing,
                        runSpacing: defaultSpacing,
                        alignment: WrapAlignment.center,
                        children: widgets,
                      ),
                    ),
                    verticalSpacing(defaultSpacing * 2),
                    const CallControls(),
                  ],
                );
              },
            )
          ),
        ],
      )
    );
  }

  // Put into a method so we can add screenshares in the future
  List<Widget> renderMember(Member member) {
    return [
      MemberEntity(member: member),
    ];
  }
}