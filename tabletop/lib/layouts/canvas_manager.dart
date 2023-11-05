import 'dart:convert';
import 'dart:io';

import 'package:tabletop/layouts/color_manager.dart';
import 'package:tabletop/layouts/effects.dart';
import 'package:tabletop/layouts/elements.dart';
import 'package:tabletop/pages/editor/editor_controller.dart';
import 'package:tabletop/theme/fj_button.dart';
import 'package:tabletop/theme/fj_textfield.dart';
import 'package:tabletop/theme/list_selection.dart';
import 'package:tabletop/theme/vertical_spacing.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

part 'canvas_objects.dart';

class CanvasManager {

  /// Gets an element from a map (returns an [Element] or throws an [Exception])
  static Element getElementFromMap(Layer layer, Map<String, dynamic> json) {
    final type = json["type"];
    switch(type) {
      case 0: return ImageElement.fromMap(type, json);
      case 1: return TextElement.fromMap(type, json);
      case 2: return BoxElement.fromMap(type, json);
      case 3: return ParagraphElement.fromMap(type, json);
      case 4: return StackElement.fromMap(type, json);
      default: throw Exception("Unknown element type: $type");
    }
  }

  static Future<String> _getPath() async {
    final path = await getApplicationSupportDirectory();
    final directory = await Directory("${path.path}/canvases").create();
    return directory.path;
  }

  static Future<bool> saveCanvas(Canvas layout) async {
    final path = await _getPath();
    final map = layout.toMap();
    final file = File("$path/${layout.name}.can");
    await file.writeAsString(jsonEncode(map));
    return true;
  }

  static Future<Canvas> loadCanvas(String name) async {
    final path = await _getPath();
    final file = File("$path/$name.can");
    final json = jsonDecode(await file.readAsString());
    return Canvas.fromMap(file.path, json);
  }

  static Future<List<String>> getCanvass() async {
    final directory = Directory(await _getPath());
    final layouts = <String>[];
    for(var element in directory.listSync(followLinks: false)) {
      if(element is File) {
        final file = File(element.path);
        final filePath = file.path.split("/").last;
        final args = filePath.split("\\");
        var name = args.last;
        if(name.endsWith(".can")) {
          name = name.substring(0, name.length - 4);
          layouts.add(name);
        }
      }
    }
    
    return layouts;
  }

  static Future<bool> deleteCanvas(String name) async {
    final path = await _getPath();
    final file = File("$path/$name.can");
    await file.delete();
    return true;
  }

}