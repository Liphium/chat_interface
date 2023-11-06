import 'dart:io';
import 'dart:ui';

import 'package:tabletop/layouts/color_manager.dart';
import 'package:tabletop/layouts/canvas_manager.dart' as layout;
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
    scalable = false;
    if(size.value.width == 0) size.value = const Size(100, 100);
  }

  @override
  void preProcess() {
    final width = double.tryParse(settings[3].value.value ?? "100") ?? 100.0;
    final height = double.tryParse(settings[4].value.value ?? "100") ?? 100.0;
    setWidth(width);
    setHeight(height);
    super.preProcess();
  }

  String getImagePath() {
    return (settings[0].value.value as String).replaceAll("_local_", currentProjectFolder);
  }

  void setImagePath(String path) {
    settings[0].value.value = path;
  }

  @override
  Widget build(BuildContext context) {

    final path = getImagePath();
    final xOffset = settings[1].value.value as double;
    final yOffset = settings[2].value.value as double;

    return Image.file(File(path), fit: BoxFit.cover, alignment: AlignmentDirectional(xOffset, yOffset), errorBuilder: (context, error, stackTrace) {
      return Placeholder(
        color: Get.theme.colorScheme.error,
        child: Center(
          child: Text("Error loading image", style: Theme.of(context).textTheme.labelLarge),
        ),
      );
    },);
  }

  @override
  List<layout.Setting> buildSettings() {
    return [
      layout.FileSetting("image", "Image", FileType.image),
      layout.NumberSetting("x_offset", "X offset", 0.0, -1.0, 1.0),
      layout.NumberSetting("y_offset", "Y offset", 0.0, -1.0, 1.0),
      layout.TextSetting("width", "Width", "100"),
      layout.TextSetting("height", "Height", "100"),
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
    final color = controller.currentCanvas.value.colorManager.colors[colorId] ?? PickedColor("error");
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
          color: color.getColor(1.0, controller.currentCanvas.value.colorManager.saturation.value),
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
      layout.TextSetting("text", "Text", "Some text"),
      layout.ColorSetting("color", "Text color"),
      layout.SelectionSetting("align", "Text alignment", 0, 
        [
          const SelectableItem("Left", Icons.format_align_left),
          const SelectableItem("Center", Icons.format_align_center),
          const SelectableItem("Right", Icons.format_align_right),
        ]
      ),
      layout.TextSetting("size", "Font size", "20"),
      layout.BoolSetting("bold", "Bold", false),
      layout.BoolSetting("italic", "Italic", false),
      layout.BoolSetting("autosize", "Auto size", false),
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
    final color = controller.currentCanvas.value.colorManager.colors[colorId] ?? PickedColor("error");
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
          color: color.getColor(1.0, controller.currentCanvas.value.colorManager.saturation.value),
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
      layout.ParagraphSetting("text", "Text", "Some text"),
      layout.ColorSetting("color", "Text color"),
      layout.SelectionSetting("align", "Text alignment", 0, 
        [
          const SelectableItem("Left", Icons.format_align_left),
          const SelectableItem("Center", Icons.format_align_center),
          const SelectableItem("Right", Icons.format_align_right),
        ]
      ),
      layout.TextSetting("size", "Font size", "20"),
      layout.BoolSetting("bold", "Bold", false),
      layout.BoolSetting("italic", "Italic", false),
      layout.BoolSetting("autosize", "Auto size", true),
      layout.TextSetting("lines", "Lines", "1"),
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
    final color = controller.currentCanvas.value.colorManager.colors[colorId] ?? PickedColor("error");
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
              color: color.getColor(opacity, controller.currentCanvas.value.colorManager.saturation.value),
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
      layout.ColorSetting("color", "Color"),
      layout.NumberSetting("opacity", "Opacity", 1.0, 0.0, 1.0),
      layout.NumberSetting("border_radius", "Border radius", 0.0, 0.0, 30.0),
      layout.NumberSetting("blur", "Background blur", 0.0, 0.0, 20.0),
      layout.NumberSetting("padding", "Padding", 0.0, 0.0, 50.0),
    ];
  }

}

class StackElement extends layout.Element {
  
  StackElement(String name) : super(name, 4, Icons.filter_none);
  StackElement.fromMap(int type, Map<String, dynamic> json) : super.fromMap(type, Icons.filter_none, json);

  @override
  void init() {
    scalable = false;
    if(size.value.width == 0) size.value = const Size(100, 100);
  }

  @override
  void preProcess() {
    final deckId = settings[0].value.value as String;
    final deck = Get.find<EditorController>().currentCanvas.value.decks[deckId]; 
    if(deck == null) {
      return;
    }
    setWidth(deck.width.toDouble());
    setHeight(deck.height.toDouble());
  }

  @override
  Widget build(BuildContext context) {

    final deckId = settings[0].value.value as String;
    final deck = Get.find<EditorController>().currentCanvas.value.decks[deckId]; 
    if(deck == null) {
      return const Placeholder();
    }

    if(deck.images.isEmpty) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Text("No images in deck", style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(deck.width / 10),
          child: Image.file(File(deck.images[0].getPath()), fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
            return Placeholder(
              color: Get.theme.colorScheme.error,
              child: Center(
                child: Text("Error loading image", style: Theme.of(context).textTheme.labelLarge),
              ),
            );
          },),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(deck.width / 10),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35), 
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(deck.width / 10),
              ),
            )
          ),
        ),
      ],
    );
  }

  @override
  List<layout.Setting> buildSettings() {
    return [
      layout.DeckSetting("deck", "Deck"),
    ];
  }
}