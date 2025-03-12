import 'dart:async';

import 'package:chat_interface/theme/components/ssr/ssr.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class SSRFetcher extends StatefulWidget {
  final String label;
  final SSR ssr;
  final String path;
  final int frequency;

  const SSRFetcher({
    super.key,
    required this.label,
    required this.ssr,
    required this.path,
    required this.frequency,
  });

  @override
  State<SSRFetcher> createState() => _SSRFetcherState();
}

class _SSRFetcherState extends State<SSRFetcher> {
  final _error = signal(true);
  final _success = signal(false);
  final _loading = signal(false);

  Timer? _timer;

  @override
  void initState() {
    // Timer for periodically checking the endpoint provided by the server
    _timer = Timer.periodic(
      Duration(seconds: widget.frequency),
      (timer) async {
        if (_loading.value) {
          return;
        }
        _loading.value = true;

        // Do a request to the server using the SSR request function
        final json = await widget.ssr.doRequest.call(widget.path, {
          if (widget.ssr.currentToken != null) "token": widget.ssr.currentToken,
        });
        await Future.delayed(const Duration(milliseconds: 250)); // To show the user that it's actually doing something
        _loading.value = false;
        _error.value = !json["success"];
        await Future.delayed(const Duration(milliseconds: 500)); // To show the user what's going on
        if (json["success"]) {
          unawaited(widget.ssr.handleSSRResponse(widget.path, json));
          timer.cancel();
        }
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _error.dispose();
    _success.dispose();
    _loading.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Get.theme.colorScheme.inverseSurface,
      borderRadius: BorderRadius.circular(defaultSpacing),
      child: Padding(
        padding: const EdgeInsets.all(defaultSpacing),
        child: Row(
          children: [
            // Task as an icon, just to make the UI not as boring and show what the element is doing
            Icon(Icons.task, color: Get.theme.colorScheme.onPrimary),
            horizontalSpacing(defaultSpacing),

            // The label of the actual status fetcher
            Expanded(
              child: Text(
                widget.label,
                style: Get.theme.textTheme.labelMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            horizontalSpacing(defaultSpacing),

            // The icon showing the progress on the fetcher
            Obx(
              () {
                // If it's loading return a loading indicator
                if (_loading.value) {
                  return SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Get.theme.colorScheme.onPrimary,
                    ),
                  );
                }

                // If there was an error, show the error icon until the next request
                if (_error.value) {
                  return Icon(Icons.error, color: Get.theme.colorScheme.error);
                }

                // If it was successful, show a success icon until the next request
                return Icon(Icons.done_all, color: Get.theme.colorScheme.onPrimary);
              },
            ),
          ],
        ),
      ),
    );
  }
}
