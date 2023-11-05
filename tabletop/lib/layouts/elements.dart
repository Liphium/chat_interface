import 'dart:io';
import 'dart:ui';

import 'package:tabletop/layouts/color_manager.dart';
import 'package:tabletop/layouts/layout_manager.dart' as layout;
import 'package:tabletop/pages/editor/editor_controller.dart';
import 'package:tabletop/theme/list_selection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImageElement extends layout.Element {
  
  ImageElement(String name) : super(name, 0, Icons.image);
  ImageElement.fromMap(int type, Map<String, dynamic> json) : super.fromMap(type, Icons.image, json);

  @override
  void init() {
    scalable = true;
    if(size.value.width == 0) size.value = const Size(100, 100);
  }

  @override
  Widget build(BuildContext context) {

    final path = settings[0].value.value as String;
    final fit = settings[1].value.value as int;
    final xOffset = settings[2].value.value as double;
    final yOffset = settings[3].value.value as double;

    return Image.file(File(path), fit: BoxFit.values[fit], alignment: AlignmentDirectional(xOffset, yOffset), errorBuilder: (context, error, stackTrace) {
      return Placeholder(
        color: Get.theme.colorScheme.error,
        child: Center(
          child: Text("Error loading image", style: Theme.of(context).textTheme.labelLarge),
        ),
      );
    },);
  }

  final iconMap = {
    BoxFit.contain: Icons.crop_square,
    BoxFit.cover: Icons.crop_5_4,
    BoxFit.fill: Icons.crop_7_5,
    BoxFit.fitHeight: Icons.crop_16_9,
    BoxFit.fitWidth: Icons.crop_din,
    BoxFit.none: Icons.crop_free,
    BoxFit.scaleDown: Icons.crop_landscape
  };

  @override
  List<layout.Setting> buildSettings() {
    return [
      layout.FileSetting("image", "Image", FileType.image, true),
      layout.SelectionSetting("fit", "Image fit", true, BoxFit.values.indexOf(BoxFit.cover), 
        List.generate(BoxFit.values.length, (index) {
          final value = BoxFit.values[index];
          var formattedName = value.toString().split(".").last;
          for(var i = 0; i < formattedName.length; i++) {
            if(formattedName[i].toUpperCase() == formattedName[i]) {
              formattedName = "${formattedName.substring(0, i)} ${formattedName.substring(i).toLowerCase()}";
              i++;
            }
          }
          formattedName = formattedName.substring(0, 1).toUpperCase() + formattedName.substring(1);

          return SelectableItem(formattedName, iconMap[value]!);
        })
      ),
      layout.NumberSetting("x_offset", "X offset", true, 0.0, -1.0, 1.0),
      layout.NumberSetting("y_offset", "Y offset", true, 0.0, -1.0, 1.0),
    ];
  }
}

class TextElement extends layout.Element {
  
  TextElement(String name) : super(name, 1, Icons.text_fields);
  TextElement.fromMap(int type, Map<String, dynamic> json) : super.fromMap(type, Icons.text_fields, json);

  @override
  void init() {
    scalable = true;
    if(size.value.width == 0) size.value = const Size(100, 30);
  }

  @override
  void preProcess() {
    final fontSize = double.tryParse(settings[3].value.value ?? "17") ?? 17.0; 
    final autoSize = settings[6].value.value as bool;
    scalableHeight = false;
    setHeight(autoSize ? fontSize * 1.6 : size.value.height);
  }

  @override
  Widget build(BuildContext context) {

    final text = settings[0].value.value as String;
    final controller = Get.find<EditorController>();
    final colorId = settings[1].value.value as String;
    final color = controller.currentLayout.value.colorManager.colors[colorId] ?? PickedColor("error");
    final align = settings[2].value.value as int;
    final fontSize = double.tryParse(settings[3].value.value ?? "17") ?? 17.0; 
    final bold = settings[4].value.value as bool;
    final italic = settings[5].value.value as bool;
    final autoSize = settings[6].value.value as bool;
    size.value = autoSize ? Size(size.value.width, fontSize * 1.6) : size.value;

    return SizedBox(
      width: size.value.width,
      height: size.value.height,
      child: Text(
        text,
        style: TextStyle(
          color: color.getColor(1.0, controller.currentLayout.value.colorManager.saturation.value),
          fontSize: fontSize, 
          fontWeight: bold ? FontWeight.bold : FontWeight.normal, 
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          overflow: TextOverflow.ellipsis
        ),
        textAlign: alignmentMap[align],
      ),
    );
  }

  final alignmentMap = {
    0: TextAlign.left,
    1: TextAlign.center,
    2: TextAlign.right
  };

  @override
  List<layout.Setting> buildSettings() {
    return [
      layout.TextSetting("text", "Text", true, "Some text"),
      layout.ColorSetting("color", "Text color", false),
      layout.SelectionSetting("align", "Text alignment", false, 0, 
        [
          const SelectableItem("Left", Icons.format_align_left),
          const SelectableItem("Center", Icons.format_align_center),
          const SelectableItem("Right", Icons.format_align_right),
        ]
      ),
      layout.TextSetting("size", "Font size", false, "20"),
      layout.BoolSetting("bold", "Bold", false, false),
      layout.BoolSetting("italic", "Italic", false, false),
      layout.BoolSetting("autosize", "Auto size", false, false),
    ];
  }
}

class ParagraphElement extends layout.Element {
  
  ParagraphElement(String name) : super(name, 3, Icons.segment);
  ParagraphElement.fromMap(int type, Map<String, dynamic> json) : super.fromMap(type, Icons.segment, json);

  @override
  void init() {
    scalable = true;
    if(size.value.width == 0) size.value = const Size(100, 30);
  }

  @override
  void preProcess() {
    final fontSize = double.tryParse(settings[3].value.value ?? "20") ?? 20.0;
    final autoSize = settings[6].value.value as bool;
    final lines = settings[7].value.value as String;
    final lineCount = int.tryParse(lines) ?? 1;
    scalableHeight = false;
    setHeight(autoSize ? fontSize * 1.6 + fontSize * 1.5 * (lineCount - 1) : size.value.height);
  }

  @override
  Widget build(BuildContext context) {

    final text = settings[0].value.value as String;
    final controller = Get.find<EditorController>();
    final colorId = settings[1].value.value as String;
    final color = controller.currentLayout.value.colorManager.colors[colorId] ?? PickedColor("error");
    final align = settings[2].value.value as int;
    final fontSize = double.tryParse(settings[3].value.value ?? "20") ?? 20.0;
    final bold = settings[4].value.value as bool;
    final italic = settings[5].value.value as bool;

    return SizedBox(
      width: size.value.width,
      height: size.value.height,
      child: Text(
        text, 
        style: TextStyle(
          color: color.getColor(1.0, controller.currentLayout.value.colorManager.saturation.value),
          fontSize: fontSize, 
          fontWeight: bold ? FontWeight.bold : FontWeight.normal, 
          fontStyle: italic ? FontStyle.italic : FontStyle.normal
        ), 
        textAlign: alignmentMap[align],
      ),
    );
  }

  final alignmentMap = {
    0: TextAlign.left,
    1: TextAlign.center,
    2: TextAlign.right
  };

  @override
  List<layout.Setting> buildSettings() {
    return [
      layout.ParagraphSetting("text", "Text", true, "Some text"),
      layout.ColorSetting("color", "Text color", false),
      layout.SelectionSetting("align", "Text alignment", false, 0, 
        [
          const SelectableItem("Left", Icons.format_align_left),
          const SelectableItem("Center", Icons.format_align_center),
          const SelectableItem("Right", Icons.format_align_right),
        ]
      ),
      layout.TextSetting("size", "Font size", false, "20"),
      layout.BoolSetting("bold", "Bold", false, false),
      layout.BoolSetting("italic", "Italic", false, false),
      layout.BoolSetting("autosize", "Auto size", false, true),
      layout.TextSetting("lines", "Lines", true, "1"),
    ];
  }
}

class BoxElement extends layout.Element {

  BoxElement(String name) : super(name, 2, Icons.crop_square);
  BoxElement.fromMap(int type, Map<String, dynamic> json) : super.fromMap(type, Icons.crop_square, json);

  @override
  void init() {
    scalable = true;
    if(size.value.width == 0) size.value = const Size(100, 100);
  }

  @override
  Widget build(BuildContext context) {

    final controller = Get.find<EditorController>();
    final colorId = settings[0].value.value as String;
    final color = controller.currentLayout.value.colorManager.colors[colorId] ?? PickedColor("error");
    final opacity = settings[1].value.value as double;
    final borderRadius = settings[2].value.value as double;
    final blur = settings[3].value.value as double;
    final padding = settings[4].value.value as double;

    return SizedBox(
      width: size.value.width,
      height: size.value.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: color.getColor(opacity, controller.currentLayout.value.colorManager.saturation.value),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: Container(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  List<layout.Setting> buildSettings() {
    return [
      layout.ColorSetting("color", "Color", false),
      layout.NumberSetting("opacity", "Opacity", false, 1.0, 0.0, 1.0),
      layout.NumberSetting("border_radius", "Border radius", false, 0.0, 0.0, 30.0),
      layout.NumberSetting("blur", "Background blur", false, 0.0, 0.0, 20.0),
      layout.NumberSetting("padding", "Padding", false, 0.0, 0.0, 50.0),
    ];
  }

}