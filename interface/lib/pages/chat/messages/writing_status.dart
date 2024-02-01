import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class WritingStatusNotifier extends StatefulWidget {
  final List<String> writers;

  const WritingStatusNotifier({super.key, required this.writers});

  @override
  State<WritingStatusNotifier> createState() => _WritingStatusNotifierState();
}

class _WritingStatusNotifierState extends State<WritingStatusNotifier> {
  String lastWriter = "-1";

  @override
  Widget build(BuildContext context) {
    FriendController friendController = Get.find();

    ThemeData theme = Theme.of(context);

    String members = "";
    for (var member in widget.writers) {
      lastWriter = member;
      members += '${friendController.friends[member]!.name}, ';
    }

    if (widget.writers.isEmpty && lastWriter != "-1") {
      members = friendController.friends[lastWriter]!.name;
    } else if (lastWriter != "-1") {
      members = members.substring(0, members.length - 2);
    }

    if (widget.writers.length >= 2) {
      int index = members.lastIndexOf(",");
      members = members.replaceRange(index, index + 1, " ${"and".tr}");
    }

    return Animate(
      //* Animation
      effects: [
        MoveEffect(
          begin: const Offset(0, 50),
          end: const Offset(0, 0),
          curve: Curves.easeOutQuart,
          duration: 250.ms,
        ),
      ],
      target: widget.writers.isEmpty ? 0 : 1,

      child: Padding(
        padding: const EdgeInsets.only(right: defaultSpacing * 0.5),
        child: Material(
            elevation: 2.0,
            color: Colors.black,
            borderRadius: BorderRadius.circular(30),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: defaultSpacing, vertical: defaultSpacing * 0.5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person,
                      size: 20, color: theme.colorScheme.primary),
                  horizontalSpacing(defaultSpacing * 0.5),
                  Text(
                      "$members ${widget.writers.length > 1 ? "are".tr : "is".tr} typing",
                      style: Theme.of(context).textTheme.bodyMedium),
                  horizontalSpacing(defaultSpacing * 0.5),
                  const SizedBox(
                      height: 20,
                      width: 20,
                      child: Padding(
                        padding: EdgeInsets.all(defaultSpacing * 0.4),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                        ),
                      ))
                ],
              ),
            )),
      ),
    );
  }
}
