import 'package:tabletop/pages/editor/editor_controller.dart';
import 'package:tabletop/theme/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ColorManager {

  final colors = RxMap<String, PickedColor>();
  final saturation = 0.5.obs;

  ColorManager();
  
  void load(Map<String, dynamic> json) {
    saturation.value = json["sat"] ?? saturation.value;
    for(var color in json["colors"]) {
      colors[color["id"]] = PickedColor.fromMap(color);
    }
  }

  Map<String, dynamic> toMap() {
    final json = <String, dynamic>{};
    json["sat"] = saturation.value;

    final colorList = <Map<String, dynamic>>[];
    for(var color in colors.values) {
      colorList.add(color.toMap());
    }
    json["colors"] = colorList;
    return json;
  }

  void addColor(String name) {
    final color = PickedColor(name);
    colors[color.id] = color;
    Get.find<EditorController>().save();
  }

  void removeColor(String id) {
    colors.remove(id);
    Get.find<EditorController>().save();
  }

  void loadFromExported(Map<String, dynamic> json) {
    for(var color in json["colors"]) {
      colors[color["id"]] = PickedColor.fromMap(color);
    }
  }
}

class PickedColor {

  late final String id;
  String name;
  final hue = 0.0.obs;
  final avoidSat = false.obs;
  final luminosity = 0.5.obs;

  PickedColor(this.name) {
    id = generateRandomString(8);
  }
  PickedColor.fromMap(Map<String, dynamic> json) : id = json["id"], name = json["name"] {
    hue.value = json["hue"];
    avoidSat.value = json["asat"];
    luminosity.value = json["lum"];
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "hue": hue.value,
      "asat": avoidSat.value,
      "lum": luminosity.value
    };
  }

  Color getColor(double alpha, double sat) => HSLColor.fromAHSL(alpha, hue.value, avoidSat.value ? 0.0 : sat, luminosity.value).toColor();
  Color colorFromController(double alpha) => HSLColor.fromAHSL(alpha, hue.value, avoidSat.value ? 0.0 : Get.find<EditorController>().currentLayout.value.colorManager.saturation.value, luminosity.value).toColor();
}