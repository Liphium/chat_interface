import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tabletop/layouts/canvas_manager.dart';
import 'package:tabletop/layouts/elements.dart';
import 'package:tabletop/theme/vertical_spacing.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TemplateManager {

  static Future<String> _getPath() async {
    final path = await getApplicationSupportDirectory();
    final directory = await Directory("${path.path}/templates").create();
    return directory.path;
  }

  /// Export a canvas to a template
  static Future<String> buildTemplate(Canvas canvas) async {
    final path = await _getPath();
    final encoder = ZipFileEncoder();
    final copy = Canvas(canvas.name, canvas.path);
    encoder.create("$path/${copy.name}.ctmp");
    for(var layer in canvas.layers) {
      copy.layers.add(Layer(layer.name, ));
      for(var element in layer.elements.values) {
        if(element is ImageElement) {
          final file = File(element.getImagePath());
          final name = "${element.id}.${element.getImagePath().split(".").last}";
          await encoder.addFile(file, name);
          final elementCopy = ImageElement.fromMap(element.type, element.toMap());
          elementCopy.setImagePath("_local_$name");
          copy.layers.last.elements[elementCopy.id] = elementCopy;
        } else {
          copy.layers.last.elements[element.id] = element;
        }
      }
    }
    for(var deck in canvas.decks.values) {
      final newDeck = Deck(deck.name, deck.width, deck.height);
      copy.decks[deck.id] = newDeck;
      newDeck.id = deck.id;
      for(var image in deck.images) {
        final file = File(image.path);
        final id = generateRandomString(10);
        final name = "${deck.name}-${deck.id}-$id.${image.path.split(".").last}";
        await encoder.addFile(file, name);
        newDeck.images.add(DeckImage("_local_$name"));
      }
    }

    // Save the canvas
    final tempPath = "$path/main.can";
    await CanvasManager.saveCanvas(copy, location: tempPath);
    final temp = File(tempPath);
    await encoder.addFile(temp);
    encoder.close();

    // Delete the temp file
    await temp.delete();

    return path;
  }

  static void launchFileExplorer(String path) {
    launchUrlString("file:$path");
  }

}