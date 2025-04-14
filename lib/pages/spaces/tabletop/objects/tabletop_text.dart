import 'dart:convert';

import 'package:chat_interface/controller/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/services/spaces/tabletop/tabletop_object.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/fj_slider.dart';
import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class TextObject extends TableObject {
  static const fontSizeMultiplier = 2;
  final fontSize = AnimatedDouble(0);
  String text = "";

  TextObject(String id, int order, Offset location, Size size)
    : super(id, order, location, size, TableObjectType.text);

  factory TextObject.createFromText(Offset location, String text, double fontSize) {
    final obj = TextObject("", 0, location, const Size(0, 0));
    obj.text = text;
    obj.fontSize.setRealValue(fontSize);
    obj.evaluateSize();
    return obj;
  }

  @override
  void render(Canvas canvas, Offset location) {
    final realFontSize = fontSize.value(DateTime.now()) * fontSizeMultiplier;
    var textSpan = TextSpan(
      text: text,
      style: Get.theme.textTheme.labelLarge!.copyWith(fontSize: realFontSize),
    );
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();
    final hintRect = Rect.fromLTWH(
      location.dx - realFontSize / 2 / 2,
      location.dy - realFontSize / 2 / 2 / 2,
      textPainter.size.width + realFontSize / 2,
      textPainter.size.height + realFontSize / 2 / 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(hintRect, Radius.circular(realFontSize / 4)),
      Paint()..color = Get.theme.colorScheme.primaryContainer,
    );
    textPainter.paint(canvas, location);
  }

  @override
  Future<void> handleData(String data) async {
    final json = jsonDecode(data);
    text = json["text"];
    fontSize.setValue(json["size"]);
  }

  @override
  String getData() {
    return jsonEncode({"text": text, "size": fontSize.realValue});
  }

  void evaluateSize() {
    var textSpan = TextSpan(
      text: text,
      style: Get.theme.textTheme.labelLarge!.copyWith(
        fontSize: fontSize.realValue * fontSizeMultiplier,
      ),
    );
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();
    size = textPainter.size;
  }

  @override
  List<ContextMenuAction> getContextMenuAdditions() {
    return [
      ContextMenuAction(
        icon: Icons.edit,
        label: 'Edit',
        onTap: () {
          Get.back();
          Get.dialog(TextObjectCreationWindow(location: location, object: this));
          Get.dialog(TextObjectCreationWindow(location: location, object: this));
        },
      ),
    ];
  }
}

class TextObjectCreationWindow extends StatefulWidget {
  final Offset location;
  final TextObject? object;

  const TextObjectCreationWindow({super.key, required this.location, this.object});

  @override
  State<TextObjectCreationWindow> createState() => _TextObjectCreationWindowState();
}

class _TextObjectCreationWindowState extends State<TextObjectCreationWindow> with SignalsMixin {
  // Controller for the text input to power the preview
  final _textController = TextEditingController();

  // State
  late final _fontSize = createSignal(16.0);
  late final _text = createSignal("");

  @override
  void initState() {
    _textController.text = widget.object?.text ?? "";
    _text.value = widget.object?.text ?? "";
    _fontSize.value = widget.object?.fontSize.realValue ?? 16;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("tabletop.object.text.create".tr, style: Get.theme.textTheme.titleMedium),
          verticalSpacing(sectionSpacing),
          FJTextField(
            hintText: "tabletop.object.text.placeholder".tr,
            controller: _textController,
            onChange: (value) => _text.value = value,
          ),
          verticalSpacing(defaultSpacing),
          FJSliderWithInput(
            min: 16,
            max: 48,
            value: _fontSize.value,
            label: _fontSize.value.toStringAsFixed(0),
            onChanged: (value) => _fontSize.value = value,
          ),
          verticalSpacing(defaultSpacing),
          Text(
            _text.value,
            style: Get.theme.textTheme.labelLarge!.copyWith(fontSize: _fontSize.value),
          ),
          verticalSpacing(defaultSpacing),
          FJElevatedButton(
            onTap: () {
              Get.back();
              if (widget.object != null) {
                widget.object!.queue(() {
                  widget.object!.text = _textController.text;
                  widget.object!.fontSize.setValue(_fontSize.value);
                  widget.object!.evaluateSize();
                  widget.object!.modifyData();
                });
                return;
              }
              final object = TextObject.createFromText(
                widget.location,
                _textController.text,
                _fontSize.value.roundToDouble(),
              );
              object.sendAdd();
            },
            child: Center(
              child: Text(
                (widget.object != null ? "edit" : "create").tr,
                style: Get.theme.textTheme.labelLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
