import 'dart:async';
import 'dart:io';

import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class ServerOfflinePage extends StatefulWidget {
  const ServerOfflinePage({super.key});

  @override
  State<ServerOfflinePage> createState() => _ServerOfflinePageState();
}

class _ServerOfflinePageState extends State<ServerOfflinePage> {
  Timer? _timer;
  var _start = 30.0;
  final _progress = 0.0.obs;

  @override
  void initState() {
    int duration = 10;

    _timer = Timer.periodic(
      duration.ms,
      (timer) {
        if (_start <= 0) {
          timer.cancel();
          setupManager.restart();
        } else {
          _start -= duration / 1000;
          _progress.value = _start / 30;
        }
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('server.offline'.tr),
              verticalSpacing(defaultSpacing * 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Obx(() => Row(
                    children: [
                      SizedBox(
                        width: 20.0,
                        height: 20.0,
                        child: CircularProgressIndicator(
                          backgroundColor: Theme.of(context).secondaryHeaderColor,
                          value: _progress.value,
                          strokeWidth: 2,
                        ),
                      ),
                      horizontalSpacing(defaultSpacing * 2),
                      Text('retry.text.1'.tr),
                      Text('${_start.toInt()}'),
                      Text('retry.text.2'.tr),
                    ],
                  )),
                ],
              ),
              verticalSpacing(defaultSpacing),
              ElevatedButton(
                onPressed: () => setupManager.restart(),
                child: Text('button.retry'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
