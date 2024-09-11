import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/pages/status/setup/smooth_dialog.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final _controller = SmoothDialogController(const SetupLoadingWidget());

  @override
  void initState() {
    setupManager.controller = _controller;
    if (setupManager.current == -1) {
      setupManager.next(open: false);
    }

    super.initState();
  }

  @override
  void dispose() {
    setupManager.controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        child: SmoothDialog(controller: _controller),
      ),
    );
  }
}

class SetupLoadingWidget extends StatelessWidget {
  const SetupLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        child: Center(
          child: Text("loading".tr, style: Get.textTheme.headlineMedium),
        ),
      ),
    );
  }
}
