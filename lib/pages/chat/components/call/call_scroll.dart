import 'dart:ui';

import 'package:chat_interface/pages/chat/components/call/call_rectangle.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallScrollView extends StatefulWidget {

  final RxBool cinema;
  final BoxConstraints constraints;

  const CallScrollView({super.key, required this.constraints, required this.cinema});

  @override
  State<CallScrollView> createState() => _CallScrollViewState();
}

class _CallScrollViewState extends State<CallScrollView> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.stylus
        },
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: getParticipants(widget.cinema, theme, 0, defaultSpacing * 1.5, BoxConstraints(
            maxHeight: widget.constraints.maxHeight - defaultSpacing * 3,
          )),
        ),
      ),
    );
  }
}