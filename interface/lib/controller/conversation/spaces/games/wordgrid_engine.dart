import 'package:chat_interface/controller/conversation/spaces/game_hub_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/games/wordgrid_widget.dart';
import 'package:flutter/material.dart';

class WordgridEngine extends Engine {

  WordgridEngine(super.session);

  @override
  void receiveEvent(String event, dynamic data) {
    print("Received event $event with data $data");
  }

  @override
  Widget build(BuildContext context) {

    const gridSize = 6;
    const fontSize = 50.0;
   
    return const WordgridGrid(fontSize: fontSize, gridSize: gridSize);
  }
}