import 'package:tabletop/layouts/canvas_manager.dart' as layout;
import 'package:tabletop/pages/editor/editor_controller.dart';
import 'package:tabletop/theme/list_selection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Effect effectFromMap(Map<String, dynamic> json) {
  final type = json["type"];
  switch(type) {
    case 0: return PaddingEffect.fromMap(json);
    case 1: return InheritSizeEffect.fromMap(json);
    case 2: return InheritPositionEffect.fromMap(json);
    case 3: return ElementAlignmentEffect.fromMap(json);
    default: throw Exception("Unknown effect type: $type");
  }
}

abstract class Effect {
  final int type;
  final String name;
  final IconData icon;
  late final List<layout.Setting> settings;
  final enabled = false.obs;
  final expanded = false.obs;

  Effect(this.type, this.name, this.icon) {
    settings = buildSettings();
  }
  Effect.fromMap(this.name, this.icon, Map<String, dynamic> json) : type = json["type"] {
    settings = buildSettings();
    for(var setting in settings) {
      setting.fromJson(json["settings"]);
    }
  }

  Map<String, dynamic> toMap() {
    var json = <String, dynamic>{};
    json["type"] = type;
    final settingsMap = <String, dynamic>{};
    for(var setting in settings) {
      setting.intoJson(settingsMap);
    }
    json["settings"] = settingsMap;
    return json;
  }

  List<layout.Setting> buildSettings();
  void preProcess(layout.Element element) {}
  Widget apply(layout.Element element, Widget child) { return child; }
}

//* Effects
class PaddingEffect extends Effect {

  final padding = layout.TextSetting("padding", "Padding", false, "0");

  PaddingEffect() : super(0, "Padding", Icons.padding);
  PaddingEffect.fromMap(Map<String, dynamic> json) : super.fromMap("Padding", Icons.padding, json);

  @override
  List<layout.Setting> buildSettings() {
    return [padding];
  }

  @override
  void preProcess(layout.Element element) {}

  @override
  Widget apply(layout.Element element, Widget child) {
    final paddingVal = double.tryParse(padding.value.value ?? "0") ?? 0.0;
    return Padding(
      padding: EdgeInsets.all(paddingVal),
      child: child,
    );
  }
}

class InheritSizeEffect extends Effect {

  final element = layout.ElementSetting("element", "Element", false);
  final inheritWidth = layout.BoolSetting("inheritWidth", "Inherit width", false, true);
  final inheritHeight = layout.BoolSetting("inheritHeight", "Inherit height", false, true);
  final extra = layout.TextSetting("extra", "Extra spacing", false, "0");

  InheritSizeEffect() : super(1, "Inherit size", Icons.crop_square);
  InheritSizeEffect.fromMap(Map<String, dynamic> json) : super.fromMap("Inherit size", Icons.crop_square, json);

  @override
  List<layout.Setting> buildSettings() {
    return [element, inheritWidth, inheritHeight, extra];
  }

  @override
  void preProcess(layout.Element element) {
    final target = this.element.value.value as String;

    // Find element
    final controller = Get.find<EditorController>();
    layout.Element? parent;
    for(var layer in controller.currentCanvas.value.layers) {
      for(var eId in layer.elements.keys.toList()) {
        if(eId == target) {
          parent = layer.elements[eId]!;
          break;
        }
      }
    }

    if(parent == null) {
      return;
    }

    final extra = double.tryParse(this.extra.value.value ?? "0") ?? 0.0;
    if(inheritWidth.value.value == true) {
      element.setWidth(parent.size.value.width + extra);
    }
    if(inheritHeight.value.value == true) {
      element.setHeight(parent.size.value.height + extra);
    }
  }

}

class InheritPositionEffect extends Effect {

  final element = layout.ElementSetting("element", "Element", false);
  final inheritX = layout.BoolSetting("inheritX", "Inherit X", false, true);
  final inheritY = layout.BoolSetting("inheritY", "Inherit Y", false, true);
  final extra = layout.TextSetting("extra", "Extra addition", false, "0");

  InheritPositionEffect() : super(2, "Inherit position", Icons.radar);
  InheritPositionEffect.fromMap(Map<String, dynamic> json) : super.fromMap("Inherit position", Icons.radar, json);

  @override
  List<layout.Setting> buildSettings() {
    return [element, inheritX, inheritY, extra];
  }

  @override
  void preProcess(layout.Element element) {
    final target = this.element.value.value as String;

    // Find element
    final controller = Get.find<EditorController>();
    layout.Element? parent;
    for(var layer in controller.currentCanvas.value.layers) {
      for(var eId in layer.elements.keys.toList()) {
        if(eId == target) {
          parent = layer.elements[eId]!;
          break;
        }
      }
    }

    if(parent == null) {
      return;
    }

    final extra = double.tryParse(this.extra.value.value ?? "0") ?? 0.0;
    if(inheritX.value.value == true) {
      element.setX(parent.position.value.dx + extra);
    }
    if(inheritY.value.value == true) {
      element.setY(parent.position.value.dy + extra);
    }
  }

}

class ElementAlignmentEffect extends Effect {

  final element = layout.ElementSetting("element", "Element", false);
  final alignment = layout.SelectionSetting("alignment", "Alignment", false, 0, 
    [
      const SelectableItem("Top", Icons.arrow_upward),
      const SelectableItem("Bottom", Icons.arrow_downward),
      const SelectableItem("Left", Icons.arrow_back),
      const SelectableItem("Right", Icons.arrow_forward),
    ]
  );
  final spacing = layout.TextSetting("spacing", "Spacing", false, "0");

  ElementAlignmentEffect() : super(3, "Element alignment", Icons.arrow_downward);
  ElementAlignmentEffect.fromMap(Map<String, dynamic> json) : super.fromMap("Element alignment", Icons.arrow_downward, json);

  @override
  List<layout.Setting> buildSettings() {
    return [element, alignment, spacing];
  }

  @override
  void preProcess(layout.Element element) {
    final target = this.element.value.value as String;

    // Find element
    final controller = Get.find<EditorController>();
    layout.Element? parent;
    for(var layer in controller.currentCanvas.value.layers) {
      for(var eId in layer.elements.keys.toList()) {
        if(eId == target) {
          parent = layer.elements[eId]!;
          break;
        }
      }
    }

    if(parent == null) return;
    final spacingVal = double.tryParse(spacing.value.value ?? "0") ?? 0.0;

    switch(alignment.value.value ?? 0) {
      case 0: 
        element.setX(parent.position.value.dx);
        element.setY(parent.position.value.dy - element.size.value.height - spacingVal); 
        break;
      case 1: 
        element.setX(parent.position.value.dx);
        element.setY(parent.position.value.dy + parent.size.value.height + spacingVal); 
        break;
      case 2: 
        element.setX(parent.position.value.dx - element.size.value.width - spacingVal); 
        element.setY(parent.position.value.dy);
        break;
      case 3: 
        element.setX(parent.position.value.dx + parent.size.value.width + spacingVal); 
        element.setY(parent.position.value.dy);
        break;
    }
  }

}