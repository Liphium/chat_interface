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

  PlayableCanvas.copy(Canvas canvas) : super(canvas.name, canvas.name) {
    for(var layer in canvas.layers) {
      layers.add(Layer(layer.name));
      for(var element in layer.elements.values) {
        layers.last.addElement(element);
      }
    }
    for(var deck in canvas.decks.values) {
      final newDeck = Deck(deck.name, deck.width, deck.height);
      decks[deck.id] = newDeck;
      newDeck.id = deck.id;
      for(var image in deck.images) {
        newDeck.images.add(image);
      }
    }
    playLayer = Layer("_playing");
    layers.insert(0, playLayer);
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{};
  }
}

class DeckImageElement extends cv.Element {

  final Deck deck;
  final DeckImage deckImage;
  final bool stackAnimation;

  DeckImageElement(this.deck, this.deckImage, {this.stackAnimation = false}) : super(deckImage.path, 999, Icons.abc);

  @override
  Widget build(BuildContext context) {
    return Image.file(File(deckImage.path), fit: BoxFit.contain,);
  }

  @override
  List<Setting> buildSettings() {
    return [];
  }
  @override
  void init() {
    scalable = false;
    size.value = Size(deck.width.toDouble(), deck.height.toDouble());
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{};
  }

  @override
  bool gameDragging() => true;

  @override
  void onGameClick(PlayableCanvas canvas) {
  }
}