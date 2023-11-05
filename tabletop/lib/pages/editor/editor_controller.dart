import 'package:tabletop/layouts/elements.dart';
import 'package:tabletop/layouts/canvas_manager.dart';
import 'package:tabletop/pages/editor/element_settings/effect_error_dialog.dart';
import 'package:get/get.dart';

class EditorController extends GetxController {

  final currentCanvas = Canvas("name", "").obs;
  final currentElement = Rx<Element?>(null);
  final showSettings = false.obs;
  final renderMode = false.obs;

  final errorMessages = <String>[].obs;
  bool changed = false;
  final loading = false.obs;

  void setCurrentCanvas(Canvas layout) {
    showSettings.value = false;
    currentElement.value = null;
    currentCanvas.value = layout;
    renderMode.value = false;
  }

  void deleteLayer(Layer layer) {
    currentCanvas.value.layers.remove(layer);
    save();
  }

  void reorderLayer(int oldIndex, int newIndex) {
    final layer = currentCanvas.value.layers.removeAt(oldIndex);
    if(newIndex > oldIndex) newIndex--;
    currentCanvas.value.layers.insert(newIndex, layer);
    save();
  }

  void addLayer(Layer layer) {
    currentCanvas.value.layers.insert(0, layer);
    save();
  }
  
  void addDeck(Deck deck) {
    currentCanvas.value.decks[deck.id] = deck;
    save();
  }

  void deleteDeck(Deck deck) {
    currentCanvas.value.decks.remove(deck);
    save();
  }

  void addDeckImage(Deck deck, DeckImage image) {
    deck.addImage(image);
    save();
  }

  void deleteDeckImage(Deck deck, DeckImage image) {
    deck.images.remove(image);
    save();
  }

  void redoCanvas() async {
    loading.value = true;
    while(_doCanvasReorder()) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    loading.value = false;
  }

  bool _doCanvasReorder() {
    changed = false;
    errorMessages.clear();
    for(var layer in currentCanvas.value.layers) {
      for(var element in layer.elements.values) {
        element.startCanvas();
      }
    }

    for(var layer in currentCanvas.value.layers) {
      for(var element in layer.elements.values) {
        element.preProcess();
        for(var effect in element.effects) {
          effect.preProcess(element);
        }
      }
    }

    for(var layer in currentCanvas.value.layers) {
      for(var element in layer.elements.values) {
        element.applyCanvas();
      }
    }

    if(errorMessages.isNotEmpty) {
      Get.dialog(const ErrorDialog());
    }
    save(layout: false);
    return changed;
  }

  void addElement(Layer layer, int type, String name) {
    Element? element;
    switch(type) {
      case 0: element = ImageElement(name); break;
      case 1: element = TextElement(name); break;
      case 2: element = BoxElement(name); break;
      case 3: element = ParagraphElement(name); break;
      default: throw Exception("Unknown element type: $type");
    }
    layer.addElement(element);
    save();
  }

  void deleteElement(Layer layer, Element element) {
    layer.elements.remove(element.id);
    save();
  }

  void save({bool layout = true}) {
    if(layout) {
      redoCanvas();
      return;
    }
    CanvasManager.saveCanvas(currentCanvas.value);
  }

  void selectElement(Element element) {
    if(loading.value) return;
    currentElement.value = element;
  }

}