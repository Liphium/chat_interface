import 'dart:async';

import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/pages/chat/components/library/library_window.dart';
import 'package:chat_interface/pages/chat/components/message/message_feed.dart';
import 'package:chat_interface/theme/components/file_renderer.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../theme/components/icon_button.dart';
import '../../../util/vertical_spacing.dart';

class MessageInput extends StatefulWidget {
  const MessageInput({super.key});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _message = TextEditingController();
  final loading = false.obs;
  final FocusNode _inputFocus = FocusNode();
  StreamSubscription<Conversation>? _sub;
  final GlobalKey _libraryKey = GlobalKey();
  final currentDraft = Rx<MessageDraft?>(null);

  @override
  void dispose() {
    _message.dispose();
    _sub?.cancel();
    _inputFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Clear message input when conversation changes
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _sub = Get.find<MessageController>().selectedConversation.listenAndPump((conversation) {
        loadDraft(conversation.id);
      });
    });
  }

  void loadDraft(String conversation) {
    if (currentDraft.value != null) {
      MessageSendHelper.drafts[currentDraft.value!.conversationId] = currentDraft.value!;
    }
    currentDraft.value = MessageSendHelper.drafts[conversation] ?? MessageDraft(conversation, "");
    _message.text = currentDraft.value!.message;
    _inputFocus.requestFocus();
  }

  void resetCurrentDraft() {
    if (currentDraft.value != null) {
      MessageSendHelper.drafts[currentDraft.value!.conversationId] = MessageDraft(currentDraft.value!.conversationId, "");
      currentDraft.value = MessageDraft(currentDraft.value!.conversationId, "");
      _message.clear();
    }
    loading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    // Setup actions
    final actionsMap = {
      SendIntent: CallbackAction<SendIntent>(
        onInvoke: (SendIntent intent) {
          final controller = Get.find<MessageController>();
          if (currentDraft.value!.files.isEmpty) {
            sendTextMessage(loading, controller.selectedConversation.value.id, _message.text, [], resetCurrentDraft);
            return;
          }

          if (currentDraft.value!.files.length > 5) {
            return;
          }

          sendTextMessageWithFiles(loading, controller.selectedConversation.value.id, _message.text, currentDraft.value!.files, resetCurrentDraft);
          return null;
        },
      ),
    };

    // Build actual widget
    return Padding(
      padding: const EdgeInsets.only(right: defaultSpacing, left: defaultSpacing, bottom: defaultSpacing),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          //* Input
          Actions(
            actions: actionsMap,
            child: Material(
              color: theme.colorScheme.onBackground,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(defaultSpacing * 1.5),
                bottomLeft: Radius.circular(defaultSpacing * 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: defaultSpacing,
                  vertical: elementSpacing,
                ),
                child: Column(
                  children: [
                    //* File preview
                    Obx(() {
                      if (currentDraft.value == null) {
                        return const SizedBox();
                      }
                      return Animate(
                        effects: [ExpandEffect(duration: 250.ms, curve: Curves.easeInOut, axis: Axis.vertical)],
                        target: currentDraft.value!.files.isEmpty ? 0 : 1,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: defaultSpacing * 0.5),
                          child: Row(
                            children: [
                              const SizedBox(height: 200 + defaultSpacing),
                              for (final file in currentDraft.value!.files)
                                SquareFileRenderer(
                                  file: file,
                                  onRemove: () => currentDraft.value!.files.remove(file),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),

                    //* Input
                    Row(
                      children: [
                        //* Attach a file
                        IconButton(
                          onPressed: () async {
                            if (currentDraft.value!.files.length == 5) {
                              return;
                            }
                            final result = await openFile();
                            if (result == null) {
                              return;
                            }
                            final size = await result.length();
                            if (size > 10 * 1000 * 1000) {
                              showErrorPopup("error".tr, "file.too_large".tr);
                              return;
                            }
                            currentDraft.value!.files.add(UploadData(result));
                          },
                          icon: const Icon(Icons.add),
                          color: theme.colorScheme.tertiary,
                          tooltip: "chat.add_file".tr,
                        ),
                        //* Attach from the library
                        IconButton(
                          key: _libraryKey,
                          onPressed: () => Get.dialog(LibraryWindow(data: ContextMenuData.fromKey(_libraryKey, above: true))),
                          icon: const Icon(Icons.folder),
                          color: theme.colorScheme.tertiary,
                        ),
                        horizontalSpacing(defaultSpacing),
                        Expanded(
                          child: Shortcuts(
                            shortcuts: {
                              LogicalKeySet(LogicalKeyboardKey.enter): const SendIntent(),
                            },
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'chat.message'.tr,
                              ),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1000),
                              ],
                              focusNode: _inputFocus,
                              onChanged: (value) => currentDraft.value!.message = value,
                              cursorColor: theme.colorScheme.tertiary,
                              style: theme.textTheme.labelLarge,
                              controller: _message,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                            ),
                          ),
                        ),
                        horizontalSpacing(defaultSpacing),
                        LoadingIconButton(
                          onTap: () => {},
                          onTapContext: (context) {
                            Actions.invoke(context, const SendIntent());
                          },
                          icon: Icons.send,
                          color: theme.colorScheme.tertiary,
                          loading: loading,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SendIntent extends Intent {
  const SendIntent();
}

class InsertFileIntent extends Intent {
  const InsertFileIntent();
}
