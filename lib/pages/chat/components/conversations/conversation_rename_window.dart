import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/services/chat/conversation_service.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class ConversationRenameWindow extends StatefulWidget {
  final Conversation conversation;

  const ConversationRenameWindow({super.key, required this.conversation});

  @override
  State<ConversationRenameWindow> createState() => _ConversationRenameWindowState();
}

class _ConversationRenameWindowState extends State<ConversationRenameWindow> {
  // Text controllers
  final _titleController = TextEditingController();

  // State
  final _errorText = signal('');
  final _loading = signal(false);

  @override
  void initState() {
    _titleController.text = widget.conversation.containerSub.value.name;
    super.initState();
  }

  @override
  void dispose() {
    _errorText.dispose();
    _loading.dispose();
    _titleController.dispose();
    super.dispose();
  }

  /// Save the conversation title
  Future<void> save() async {
    if (_loading.value) return;
    _loading.value = true;
    _errorText.value = "";

    // Make sure the name fits within the requirements
    final name = _titleController.text;
    if (name.isEmpty || name == "") {
      _errorText.value = "enter.name".tr;
      _loading.value = false;
      return;
    }
    if (name.length > specialConstants[Constants.specialConstantMaxConversationNameLength]!) {
      _errorText.value = "conversations.name.length".trParams({
        "length": specialConstants["max_conversation_name_length"].toString(),
      });
      _loading.value = false;
      return;
    }

    // Change the data of the conversation
    final error = await ConversationService.setData(
      widget.conversation,
      ConversationContainer(_titleController.text),
    );
    if (error != null) {
      _errorText.value = error;
      _loading.value = false;
      return;
    }

    _loading.value = false;
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      title: [Text("conversations.name.edit".tr, style: Get.textTheme.labelLarge)],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FJTextField(
            hintText: 'conversations.name.placeholder'.tr,
            controller: _titleController,
            maxLength: 16,
            autofocus: true,
            onSubmitted: (t) => save(),
          ),
          verticalSpacing(defaultSpacing),
          AnimatedErrorContainer(
            message: _errorText,
            padding: const EdgeInsets.only(bottom: defaultSpacing),
            expand: true,
          ),
          FJElevatedLoadingButtonCustom(
            loading: _loading,
            onTap: () => save(),
            child: Center(child: Text("save".tr, style: Get.theme.textTheme.labelLarge)),
          ),
        ],
      ),
    );
  }
}
