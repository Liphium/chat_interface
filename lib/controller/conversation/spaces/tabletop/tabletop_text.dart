import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/pages/chat/sidebar/friends/friends_page.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/components/fj_slider.dart';
import 'package:chat_interface/theme/components/fj_textfield.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextObject extends TableObject {
  String text = "";

  TextObject(String id, Offset location, Size size) : super(id, location, size, TableObjectType.card);

  @override
  void render(Canvas canvas, Offset location, TabletopController controller) {
    var textSpan = TextSpan(
      text: "hello world",
      style: Get.theme.textTheme.labelLarge,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final hintRect = Rect.fromLTWH(
      location.dx - elementSpacing,
      location.dy - elementSpacing,
      textPainter.size.width + defaultSpacing,
      textPainter.size.height + defaultSpacing,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(hintRect, const Radius.circular(defaultSpacing)), Paint()..color = Get.theme.colorScheme.primaryContainer);
    textPainter.paint(canvas, location);
  }

  @override
  void handleData(String data) async {
    text = data;
  }

  @override
  String getData() {
    return text;
  }

  @override
  List<ContextMenuAction> getContextMenuAdditions() {
    return [
      ContextMenuAction(
        icon: Icons.login,
        label: 'Edit',
        onTap: (controller) {
          Get.dialog(const FriendsPage());
        },
      ),
    ];
  }
}

class TextObjectCreationWindow extends StatefulWidget {
  final Offset location;

  const TextObjectCreationWindow({super.key, required this.location});

  @override
  State<TextObjectCreationWindow> createState() => _TextObjectCreationWindowState();
}

class _TextObjectCreationWindowState extends State<TextObjectCreationWindow> {
  final fontSize = 16.0.obs;
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("tabletop.object.text.create".tr, style: Get.theme.textTheme.titleMedium),
          verticalSpacing(sectionSpacing),
          FJTextField(
            hintText: "tabletop.object.text.placeholder".tr,
            controller: _textController,
          ),
          Obx(
            () => FJSliderWithInput(
              min: 8,
              max: 50,
              value: fontSize.value,
              label: fontSize.value.toStringAsFixed(0),
              onChanged: (value) => fontSize.value = value,
            ),
          ),
          verticalSpacing(defaultSpacing),
          FJElevatedButton(
            onTap: () {},
            child: Center(
              child: Text("create".tr, style: Get.theme.textTheme.labelLarge),
            ),
          )
        ],
      ),
    );
  }
}
