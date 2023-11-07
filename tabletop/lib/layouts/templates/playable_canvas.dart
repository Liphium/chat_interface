import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tabletop/layouts/canvas_manager.dart';
import 'package:tabletop/layouts/canvas_manager.dart' as cv;

class PlayableCanvas extends cv.Canvas {
  
  late final Layer playLayer;
  
  PlayableCanvas.fromMap(super.path, super.json) : super.fromMap() {
    playLayer = Layer("_playing");
    layers.insert(0, playLayer);
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{};
  }
}

class DeckImageElement extends cv.Element {

  final DeckImage deckImage;
  final bool stackAnimation;

  DeckImageElement(this.deckImage, {this.stackAnimation = false}) : super(deckImage.path, 999, Icons.abc);

  @override
  Widget build(BuildContext context) {
    return Image.file(File(deckImage.getPath()), fit: BoxFit.cover);
  }

  @override
  List<Setting> buildSettings() {
    return [];
  }
  @override
  void init() {}

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{};
  }
}