import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/theme/components/ssr/ssr.dart';
import 'package:chat_interface/theme/components/ssr/ssr_fetcher.dart';
import 'package:chat_interface/util/dispose_hook.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SSRRenderer extends StatefulWidget {
  final SSR ssr;
  final String path;
  final List<dynamic> json;

  const SSRRenderer({super.key, required this.ssr, required this.json, required this.path});

  @override
  State<SSRRenderer> createState() => _SSRRendererState();
}

class _SSRRendererState extends State<SSRRenderer> {
  final toDispose = <TextEditingController>[];
  var widgets = <Widget>[];

  @override
  void initState() {
    widgets = List.generate(widget.json.length, (index) {
      final last = index == widget.json.length - 1;
      final element = widget.json[index];
      switch (element["type"]) {
        case "text":
          return _renderText(element, last);
        case "input":
          return _renderInput(element, last);
        case "submit":
          return _renderSubmitButton(element, last);
        case "button":
          return _renderButton(element, last);
        case "fetcher":
          return _renderFetcher(element, last);
      }

      return _renderError(element["type"], last);
    });

    super.initState();
  }

  /// Render a text element from the element json
  Widget _renderText(Map<String, dynamic> json, bool last) {
    switch (json["style"]) {
      case 0:
        return Padding(padding: EdgeInsets.only(bottom: last ? 0 : sectionSpacing), child: Text(json["text"], style: Get.textTheme.headlineMedium));
      case 1:
        return Padding(
          padding: EdgeInsets.only(top: defaultSpacing, bottom: last ? 0 : defaultSpacing),
          child: Align(alignment: Alignment.centerLeft, child: Text(json["text"], style: Get.textTheme.titleMedium, textAlign: TextAlign.start)),
        );
      case 2:
        return Padding(padding: EdgeInsets.only(bottom: last ? 0 : defaultSpacing), child: Text(json["text"], style: Get.textTheme.bodyMedium));
    }

    return _renderError("text-style-${json["style"]}", last);
  }

  /// Render an input field from the element json
  Widget _renderInput(Map<String, dynamic> json, bool last) {
    // Create a new text editing controller to fill in a value
    final controller = TextEditingController();
    controller.text = json["value"] ?? "";
    toDispose.add(controller); // Make sure the thing is disposed

    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : defaultSpacing),
      child: FJTextField(
        controller: controller,
        obscureText: json["hidden"],
        hintText: json["placeholder"],
        maxLength: json["max"],
        onChange: (value) {
          widget.ssr.currentInputValues[json["name"]] = value;
        },
      ),
    );
  }

  /// Render a submit button from the element json
  Widget _renderSubmitButton(Map<String, dynamic> json, bool last) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : defaultSpacing),
      child: Column(
        children: [
          AnimatedErrorContainer(padding: const EdgeInsets.only(bottom: defaultSpacing), message: widget.ssr.error, expand: true),
          _renderButton(json, true), // Last = true for no padding
          Watch(
            (ctx) => Animate(
              effects: [ExpandEffect(duration: 250.ms, axis: Axis.vertical, alignment: Alignment.bottomCenter)],
              target: widget.ssr.error.value == "" ? 0 : 1,
              child:
                  widget.ssr.suggestButton != null
                      ? Padding(
                        padding: const EdgeInsets.only(top: defaultSpacing),
                        child: _renderButton(widget.ssr.suggestButton!, true), // Last = true for no padding
                      )
                      : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  /// Render a normal button using json (NOT A NORMAL ELEMENT)
  Widget _renderButton(Map<String, dynamic> json, bool last) {
    final loading = signal(false);
    return DisposeHook(
      dispose: () {
        loading.dispose();
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: last ? 0 : defaultSpacing),
        child: FJElevatedLoadingButton(
          onTap: () async {
            if (json["link"] ?? false) {
              await launchUrl(Uri.parse(json["path"] ?? ""));
              return;
            }

            widget.ssr.error.value = "";
            loading.value = true;
            await Future.delayed(250.ms);
            widget.ssr.suggestButton = null;
            widget.ssr.error.value = await widget.ssr.next(json["path"]) ?? "";
            loading.value = false;
          },
          label: json["label"],
          loading: loading,
        ),
      ),
    );
  }

  /// Render a fetcher
  Widget _renderFetcher(Map<String, dynamic> json, bool last) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : defaultSpacing),
      child: SSRFetcher(label: json["label"] ?? "", ssr: widget.ssr, frequency: json["frequency"] ?? 5, path: json["path"]),
    );
  }

  /// Render an error
  Widget _renderError(String type, bool last) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : defaultSpacing),
      child: ErrorContainer(message: "render.error".trParams({"type": type}), expand: true),
    );
  }

  @override
  void dispose() {
    for (var controller in toDispose) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children:
          widgets +
          [
            if (widget.ssr.extra?[widget.path] != null)
              Padding(padding: const EdgeInsets.only(top: defaultSpacing), child: widget.ssr.extra?[widget.path]),
          ],
    );
  }
}
