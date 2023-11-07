part of 'canvas_manager.dart';

class Canvas {
  String name;
  final String path;
  final layers = RxList<Layer>();
  final decks = RxMap<String, Deck>(); 

  final ColorManager colorManager = ColorManager();

  Canvas(this.name, this.path);
  Canvas.create(this.name, this.path);
  Canvas.fromMap(this.path, Map<String, dynamic> json) : name = json["name"] {
    for(var layer in json["layers"]) {
      layers.add(Layer.fromMap(layer));
    }
    for(var deckJson in json["decks"]) {
      final deck = Deck.fromMap(deckJson);
      decks[deck.id] = deck;
    }
    colorManager.load(json["colors"] ?? {});
  }
  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> layersMap = [];
    for(var layer in layers) {
      layersMap.add(layer.toMap());
    }
    return {
      "name": name,
      "layers": layersMap,
      "decks": decks.values.map((e) => e.toMap()).toList(),
      "colors": colorManager.toMap()
    };
  }
}

class Layer {
  final String name;
  late final elements = RxMap<String, Element>();
  final expanded = true.obs;

  Layer(this.name);
  Layer.fromMap(Map<String, dynamic> json) : name = json["name"] {
    for(var jsonElement in json["elements"]) {
      final element = CanvasManager.getElementFromMap(this, jsonElement);
      elements[element.id] = element;
    }
  }
  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> elementsMap = [];
    for(var element in elements.values) {
      final map = element.toMap();
      map["type"] = element.type;
      elementsMap.add(map);
    }
    return {
      "name": name,
      "elements": elementsMap
    };
  }

  void addElement(Element element) {
    elements[element.id] = element;
  }
}

class Deck {
  late String id;
  final String name;
  final int width, height;
  late final images = RxList<DeckImage>();
  final expanded = true.obs;

  Deck(this.name, this.width, this.height) {
    id = generateRandomString(12);
  }
  Deck.fromMap(Map<String, dynamic> json) : name = json["name"], width = json["width"], height = json["height"], id = json["id"] {
    for(var jsonElement in json["images"]) {
      images.add(DeckImage.fromMap(jsonElement));
    }
  }
  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> elementsMap = [];
    for(var image in images) {
      elementsMap.add(image.toMap());
    }
    return {
      "id": id,
      "name": name,
      "width": width,
      "height": height,
      "images": elementsMap
    };
  }

  void addImage(DeckImage element) {
    images.add(element);
  }
}

class DeckImage {
  String path;

  DeckImage(this.path);

  DeckImage.fromMap(Map<String, dynamic> json) : path = json["path"];
  Map<String, dynamic> toMap() => {
    "path": path
  };

  String getPath() {
    return path.replaceAll("_local_", currentProjectFolder);
  }
}

abstract class Element {
  final int type;
  late final String id;
  final String name;
  final IconData icon;
  bool scalable = false, scalableWidth = true, scalableHeight = true;
  final position = const Offset(0, 0).obs;
  final size = const Size(0, 0).obs;
  bool lockX = false, lockY = false;
  late final List<Setting> settings;
  final effects = RxList<Effect>();

  // Stored from layout
  int xOverrides = 0, yOverrides = 0, widthOverrides = 0, heightOverrides = 0;
  Offset? layoutOffset;
  Size? layoutSize;

  Element(this.name, this.type, this.icon) {
    id = generateRandomString(12);
    settings = buildSettings();
    init();
  }
  Element.fromMap(this.type, this.icon, Map<String, dynamic> json) : id = json["id"], name = json["name"] {
    settings = [];
    for(var setting in buildSettings()) {
      setting.fromJson(json["settings"]);
      settings.add(setting);
    }
    position.value = Offset(json["x"], json["y"]);
    size.value = Size(json["width"], json["height"]);
    for(var effect in json["effects"]) {
      effects.add(effectFromMap(effect));
    }
    init();
  }
  Map<String, dynamic> toMap() {
    final settingsMap = <String, dynamic>{};
    for(var setting in settings) {
      setting.intoJson(settingsMap);
    }
    final effectsMap = <Map<String, dynamic>>[];
    for(var effect in effects) {
      effectsMap.add(effect.toMap());
    }

    return {
      "id": id,
      "name": name,
      "x": position.value.dx,
      "y": position.value.dy,
      "width": size.value.width,
      "height": size.value.height,
      "settings": settingsMap,
      "effects": effectsMap
    };
  }

  void addEffect(Effect effect) {
    effects.add(effect);
  }

  void init();
  void onGameClick(PlayableCanvas canvas) {}
  List<Setting> buildSettings();
  void preProcess() {}
  Widget build(BuildContext context);

  void startCanvas() {
    layoutOffset = null;
    layoutSize = null;
    xOverrides = yOverrides = widthOverrides = heightOverrides = 0;
  }

  void setX(double x) {
    layoutOffset = Offset(x, (layoutOffset ?? position.value).dy);
    xOverrides++;
  }

  void setY(double y) {
    layoutOffset = Offset((layoutOffset ?? position.value).dx, y);
    yOverrides++;
  }

  void setWidth(double width) {
    layoutSize = Size(width, (layoutSize ?? size.value).height);
    widthOverrides++;
  }

  void setHeight(double height) {
    layoutSize = Size((layoutSize ?? size.value).width, height);
    heightOverrides++;
  }

  void applyCanvas() {
    final controller = Get.find<EditorController>();

    if(position.value != layoutOffset && layoutOffset != null) {
      controller.changed = true;
    }
    if(size.value != layoutSize && layoutSize != null) {
      controller.changed = true;
    }

    position.value = layoutOffset ?? position.value;
    size.value = layoutSize ?? size.value;
    if(xOverrides > 1) {
      controller.errorMessages.add("Element $name has $xOverrides x overrides");
    }
    if(yOverrides > 1) {
      controller.errorMessages.add("Element $name has $yOverrides y overrides");
    }
    if(widthOverrides > 1) {
      controller.errorMessages.add("Element $name has $widthOverrides width overrides");
    }
    if(heightOverrides > 1) {
      controller.errorMessages.add("Element $name has $heightOverrides height overrides");
    }
  }

  Widget buildParent(Widget child) {
    return SizedBox(
      width: size.value.width,
      height: size.value.height,
      child: child,
    );
  }
}

enum SettingType {
  number,
  text,
  selection,
  file,
  bool,
  color,
  element
}

abstract class Setting<T> {
  
  final String name;
  final String description;
  final SettingType type;

  final T _defaultValue;
  final value = Rx<T?>(null);
 
  // Configuration
  bool showLabel = true;
 
  Setting(this.name, this.description, this.type, this._defaultValue) {
    value.value = _defaultValue;
    init();
  }

  void setValue(T newVal) {
    value.value = newVal;
  }

  void fromJson(Map<String, dynamic> json) {
    if (json.containsKey(name)) {
      value.value = json[name];
    }
  }

  void intoJson(Map<String, dynamic> json) {
    if(value.value != null) {
      json[name] = value.value;
    }
  }

  void init() {}
  Widget build(BuildContext context);
  void dispose() {}
}

class TextSetting extends Setting<String> {
  TextSetting(String name, String description, String def) : super(name, description, SettingType.text, def);

  TextEditingController? _controller;

  @override
  void dispose() {
    if(_controller == null) return;
    _controller!.dispose();
    _controller = null;
  }

  @override
  Widget build(BuildContext context) {
    _controller = TextEditingController();
    _controller!.text = value.value ?? _defaultValue;
    _controller!.addListener(() {
      setValue(_controller!.text);
    });
    return FJTextField(
      controller: _controller,
      hintText: "Value",
    );
  }
}

class ParagraphSetting extends Setting<String> {
  ParagraphSetting(String name, String description, String def) : super(name, description, SettingType.text, def);

  TextEditingController? _controller;

  @override
  void dispose() {
    if(_controller == null) return;
    _controller!.dispose();
    _controller = null;
  }

  @override
  Widget build(BuildContext context) {
    _controller = TextEditingController();
    _controller!.text = value.value ?? _defaultValue;
    _controller!.addListener(() {
      setValue(_controller!.text);
    });
    return FJTextField(
      maxLines: 3,
      controller: _controller,
      hintText: "Value",
    );
  }
}

class NumberSetting extends Setting<double> {

  final double min, max;

  NumberSetting(String name, String description, double def, this.min, this.max) : super(name, description, SettingType.number, def);

  @override
  Widget build(BuildContext context) {
    return Obx(() =>
      Slider(
        value: clampDouble(value.value ?? _defaultValue, min, max),
        focusNode: FocusNode(),
        inactiveColor: Get.theme.colorScheme.primary,
        thumbColor: Get.theme.colorScheme.onPrimary,
        activeColor: Get.theme.colorScheme.onPrimary,
        min: min,
        max: max,
        onChanged: (newVal) => setValue(newVal),
        onChangeEnd: (value) => Get.find<EditorController>().save(),
      )
    );
  }
}

class BoolSetting extends Setting<bool> {

  BoolSetting(String name, String description, bool def) : super(name, description, SettingType.bool, def);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(description, style: Get.theme.textTheme.bodyMedium, overflow: TextOverflow.ellipsis,)),
        horizontalSpacing(elementSpacing),
        Obx(() =>
          Switch(
            activeColor: Get.theme.colorScheme.secondary,
            trackColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected) ? Get.theme.colorScheme.primary : Get.theme.colorScheme.primaryContainer),
            hoverColor: Get.theme.hoverColor,
            thumbColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected) ? Get.theme.colorScheme.onPrimary : Get.theme.colorScheme.surface),
            value: value.value ?? _defaultValue,
            onChanged: (newVal) {
              setValue(newVal);
              Get.find<EditorController>().save();
            }, 
          )
        ),
      ],
    );
  }

  @override
  void init() {
    showLabel = false;
  }
}

class FileSetting extends Setting<String> {
  final fp.FileType fileType;
  FileSetting(String name, String description, this.fileType) : super(name, description, SettingType.file, "");

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(fileType == fp.FileType.image ? Icons.image : Icons.note, color: Get.theme.colorScheme.onPrimary),
        horizontalSpacing(elementSpacing),
        Expanded(
          child: Obx(() {
            final fileName = (value.value ?? "Choose a file").split("\\").last;
            return Text(fileName == "" ? "Choose a file" : fileName, style: Get.theme.textTheme.labelMedium, overflow: TextOverflow.ellipsis,);
          }),
        ),
        horizontalSpacing(elementSpacing),
        FJElevatedButton(
          child: Text("Browse", style: Get.theme.textTheme.labelMedium),
          onTap: () async {
            final result = await fp.FilePicker.platform.pickFiles(type: fileType);
            if(result != null && result.paths.isNotEmpty) {
              setValue(result.paths.first!);
              Get.find<EditorController>().save();
            }
          },
        )
      ],
    );
  }
}

class SelectionSetting extends Setting<int> {
  final List<SelectableItem> options;
  SelectionSetting(String name, String description, int def, this.options) : super(name, description, SettingType.selection, def);

  @override
  Widget build(BuildContext context) {
    return Obx(() =>ListSelection(
      currentIndex: value.value ?? _defaultValue,
      items: options,
      callback: (newVal, index) {
        setValue(index);
        Get.find<EditorController>().save();
      },
    ));
  }
}

// String is the id of the color
class ColorSetting extends Setting<String> {
  ColorSetting(String name, String description) : super(name, description, SettingType.color, "");

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EditorController>();

    return Obx(() => ListSelection(
      currentIndex: controller.currentCanvas.value.colorManager.colors.keys.toList().indexOf(value.value ?? _defaultValue),
      items: List.generate(controller.currentCanvas.value.colorManager.colors.length, (index) {
        final color = controller.currentCanvas.value.colorManager.colors.values.toList()[index];
        return SelectableItem(color.name, Icons.color_lens, iconColor: color.getColor(1.0, controller.currentCanvas.value.colorManager.saturation.value));
      }),
      callback: (newVal, index) {
        setValue(controller.currentCanvas.value.colorManager.colors.keys.toList()[index]);
        Get.find<EditorController>().save();
      },
    ));
  }
}

// String is the id of the element
class ElementSetting extends Setting<String> {
  ElementSetting(String name, String description) : super(name, description, SettingType.element, "");

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EditorController>();

    return Obx(() {

      // Grab all elements in the current layout
      final elements = <String, Element>{};
      for(var layer in controller.currentCanvas.value.layers) {
        for(var element in layer.elements.values) {
          elements[element.id] = element;
        }
      }

      return ListSelection(
        currentIndex: elements.keys.toList().indexOf(value.value ?? _defaultValue),
        items: List.generate(elements.length, (index) {
          final element = elements[elements.keys.toList()[index]]!;
          return SelectableItem(element.name, element.icon);
        }),
        callback: (newVal, index) {
          setValue(elements.keys.toList()[index]);
          Get.find<EditorController>().save();
        },
      );
    });
  }
}

// String is the id of the deck
class DeckSetting extends Setting<String> {
  DeckSetting(String name, String description) : super(name, description, SettingType.element, "");

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EditorController>();

    return Obx(() {

      // Grab all elements in the current layout
      final decks = controller.currentCanvas.value.decks.values.toList();

      return ListSelection(
        currentIndex: controller.currentCanvas.value.decks.keys.toList().indexOf(value.value ?? _defaultValue),
        items: List.generate(decks.length, (index) {
          final element = decks[index];
          return SelectableItem(element.name, Icons.layers);
        }),
        callback: (newVal, index) {
          setValue(controller.currentCanvas.value.decks.keys.toList()[index]);
          Get.find<EditorController>().save();
        },
      );
    });
  }
}