import 'dart:async';
import 'dart:io';

import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/pages/chat/components/emojis/emoji_window.dart';
import 'package:chat_interface/pages/chat/components/library/library_window.dart';
import 'package:chat_interface/pages/chat/components/message/message_feed.dart';
import 'package:chat_interface/pages/chat/messages/message_formatter.dart';
import 'package:chat_interface/theme/components/file_renderer.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path_provider/path_provider.dart';

import '../../../theme/components/icon_button.dart';
import '../../../util/vertical_spacing.dart';

import 'package:path/path.dart' as path;

class MessageInput extends StatefulWidget {
  const MessageInput({super.key});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final FormattedTextEditingController _message = FormattedTextEditingController(Get.theme.textTheme.labelLarge!, Get.theme.textTheme.bodyLarge!);
  final loading = false.obs;
  final FocusNode _inputFocus = FocusNode();
  StreamSubscription<Conversation>? _sub;
  final GlobalKey _libraryKey = GlobalKey();
  final GlobalKey _emojiKey = GlobalKey();

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
    if (MessageSendHelper.currentDraft.value != null) {
      MessageSendHelper.drafts[MessageSendHelper.currentDraft.value!.conversationId] = MessageSendHelper.currentDraft.value!;
    }
    MessageSendHelper.currentDraft.value = MessageSendHelper.drafts[conversation] ?? MessageDraft(conversation, "");
    _message.text = MessageSendHelper.currentDraft.value!.message;
    _inputFocus.requestFocus();
  }

  void resetCurrentDraft() {
    if (MessageSendHelper.currentDraft.value != null) {
      MessageSendHelper.drafts[MessageSendHelper.currentDraft.value!.conversationId] =
          MessageDraft(MessageSendHelper.currentDraft.value!.conversationId, "");
      MessageSendHelper.currentDraft.value = MessageDraft(MessageSendHelper.currentDraft.value!.conversationId, "");
      _message.clear();
    }
    loading.value = false;
  }

  /// Replace the current selection with a new text
  void replaceSelection(String replacer) {
    // Compute the new offset before the text is changed
    final beforeLeft =
        _message.selection.baseOffset > _message.selection.extentOffset ? _message.selection.baseOffset : _message.selection.extentOffset;
    final newOffset = beforeLeft - (_message.selection.end - _message.selection.start) + replacer.length;

    // Change the text in the field to include the pasted text
    _message.text =
        _message.text.substring(0, _message.selection.start) + replacer + _message.text.substring(_message.selection.end, _message.text.length);

    // Change the selection to the calculated offset
    _message.selection = _message.selection.copyWith(
      baseOffset: newOffset,
      extentOffset: newOffset,
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    // All actions that can be performed using shortcuts in the input field-
    final actionsMap = {
      SendIntent: CallbackAction<SendIntent>(
        onInvoke: (SendIntent intent) {
          final controller = Get.find<MessageController>();
          if (MessageSendHelper.currentDraft.value!.files.isEmpty) {
            sendTextMessage(loading, controller.selectedConversation.value.id, _message.text, [],
                MessageSendHelper.currentDraft.value!.answer.value?.id ?? "", resetCurrentDraft);
            return;
          }

          if (MessageSendHelper.currentDraft.value!.files.length > 5) {
            return;
          }

          sendTextMessageWithFiles(loading, controller.selectedConversation.value.id, _message.text, MessageSendHelper.currentDraft.value!.files,
              MessageSendHelper.currentDraft.value!.answer.value?.id ?? "", resetCurrentDraft);
          return null;
        },
      ),

      // For support to paste files
      PasteIntent: CallbackAction<PasteIntent>(
        onInvoke: (PasteIntent intent) async {
          sendLog("psste");
          final image = await Pasteboard.image;
          final data = await Clipboard.getData(Clipboard.kTextPlain);

          // When nothing is copied
          if (data == null && image == null) {
            return;
          }

          // Check if an image is copied
          if (image != null) {
            sendLog("image");
            final tempPath = await getTemporaryDirectory();

            // Get the mime type of the image
            final mimeType = lookupMimeType("", headerBytes: image);
            if (mimeType == null) {
              sendLog("no mime type");
              return;
            }

            // Get the file extension of the image
            final args = mimeType.split("/");
            if (args[0] != "image") {
              sendLog("$mimeType isn't an image type");
              return;
            }

            // Save the file
            final tempFile = File(path.join(tempPath.path, "pasted_image_${getRandomString(5)}.${args[1]}"));
            await tempFile.writeAsBytes(image, flush: true);
            MessageSendHelper.currentDraft.value!.files.add(UploadData(tempFile));
            return;
          }

          // Compute the new offset before the text is changed
          replaceSelection(data!.text!);
          return null;
        },
      ),
    };

    // Build actual widget
    return Padding(
      padding: const EdgeInsets.only(right: sectionSpacing, left: sectionSpacing, bottom: sectionSpacing),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          //* Input
          Actions(
            actions: actionsMap,
            child: Material(
              color: theme.colorScheme.onBackground,
              borderRadius: BorderRadius.circular(defaultSpacing * 1.5),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: defaultSpacing,
                  vertical: elementSpacing,
                ),
                child: Column(
                  children: [
                    //* Reply preview
                    Obx(
                      () {
                        final answer = MessageSendHelper.currentDraft.value?.answer.value;

                        if (MessageSendHelper.currentDraft.value == null || answer == null) {
                          return const SizedBox();
                        }
                        return Animate(
                          effects: [
                            ExpandEffect(
                              duration: 250.ms,
                              curve: Curves.easeInOut,
                              axis: Axis.vertical,
                            )
                          ],
                          target: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(elementSpacing),
                            child: Row(
                              children: [
                                Icon(Icons.reply, color: theme.colorScheme.tertiary),
                                horizontalSpacing(defaultSpacing),
                                Expanded(
                                  child: Text(
                                    "message.reply.text".trParams({
                                      "name": Get.find<FriendController>().friends[answer.senderAccount]?.name ??
                                          Friend.unknown(answer.senderAccount).name,
                                    }),
                                    style: theme.textTheme.labelMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                LoadingIconButton(
                                  iconSize: 22,
                                  extra: 4,
                                  padding: 4,
                                  onTap: () {
                                    MessageSendHelper.currentDraft.value!.answer.value = null;
                                  },
                                  icon: Icons.close,
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    //* File preview
                    Obx(
                      () {
                        if (MessageSendHelper.currentDraft.value == null) {
                          return const SizedBox();
                        }
                        return Animate(
                          effects: [
                            ExpandEffect(
                              duration: 250.ms,
                              curve: Curves.easeInOut,
                              axis: Axis.vertical,
                            )
                          ],
                          target: MessageSendHelper.currentDraft.value!.files.isEmpty ? 0 : 1,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: defaultSpacing * 0.5),
                            child: Row(
                              children: [
                                const SizedBox(height: 200 + defaultSpacing),
                                for (final file in MessageSendHelper.currentDraft.value!.files)
                                  SquareFileRenderer(
                                    file: file,
                                    onRemove: () => MessageSendHelper.currentDraft.value!.files.remove(file),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    //* Input
                    Row(
                      children: [
                        //* Attach a file
                        IconButton(
                          onPressed: () async {
                            if (MessageSendHelper.currentDraft.value!.files.length == 5) {
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
                            MessageSendHelper.currentDraft.value!.files.add(UploadData(File(result.path)));
                          },
                          icon: const Icon(Icons.add),
                          color: theme.colorScheme.tertiary,
                          tooltip: "chat.add_file".tr,
                        ),
                        //* Attach from the library
                        horizontalSpacing(defaultSpacing),
                        Expanded(
                          child: FocusableActionDetector(
                            autofocus: true,
                            actions: actionsMap,
                            shortcuts: {
                              LogicalKeySet(LogicalKeyboardKey.enter): const SendIntent(),
                              LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyV): const PasteIntent(),
                            },
                            descendantsAreTraversable: false,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: Get.height * 0.5),
                              child: TextField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'chat.message'.tr,
                                ),
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(1000),
                                ],
                                focusNode: _inputFocus,
                                onChanged: (value) => MessageSendHelper.currentDraft.value!.message = value,
                                onAppPrivateCommand: (action, data) {
                                  sendLog("app private command");
                                },
                                cursorColor: theme.colorScheme.tertiary,
                                style: theme.textTheme.labelLarge,
                                controller: _message,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          key: _emojiKey,
                          onPressed: () async {
                            final result = await Get.dialog(EmojiWindow(data: ContextMenuData.fromKey(_emojiKey, above: true, right: true)));
                            _inputFocus.requestFocus();
                            if (result == null) {
                              return;
                            }
                            replaceSelection(result);
                          },
                          icon: const Icon(Icons.emoji_emotions),
                          color: theme.colorScheme.tertiary,
                        ),
                        horizontalSpacing(elementSpacing),
                        IconButton(
                          key: _libraryKey,
                          onPressed: () => Get.dialog(LibraryWindow(data: ContextMenuData.fromKey(_libraryKey, above: true, right: true))),
                          icon: const Icon(Icons.folder),
                          color: theme.colorScheme.tertiary,
                        ),
                        horizontalSpacing(elementSpacing),
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

class PasteIntent extends Intent {
  const PasteIntent();
}
