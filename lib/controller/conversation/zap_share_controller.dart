import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart' as msg;
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/chat/components/conversations/zap_share_window.dart';
import 'package:chat_interface/pages/chat/components/message/message_feed.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/web.dart';
import 'package:dio/dio.dart' as d;
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:liphium_bridge/liphium_bridge.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sodium_libs/sodium_libs.dart';
import 'package:path/path.dart' as path;

class ZapShareController extends GetxController {
  // Current transaction
  final currentReceiver = Rx<LPHAddress?>(null);
  final currentConversation = Rx<LPHAddress?>(null);
  final waiting = false.obs;
  final step = "loading".tr.obs;
  final progress = 0.0.obs;
  bool uploading = false;
  final currentPart = 0.obs;
  int endPart = 0;
  String? transactionId;
  String? transactionToken;
  String? uploadToken;
  String? filePath;
  XDirectory? chunksDir;
  SecureKey? key;
  StreamSubscription<Uint8List>? partSubscription;

  static const chunkSize = 512 * 1024;

  bool isRunning() {
    return currentReceiver.value != null || currentConversation.value != null || waiting.value;
  }

  void resetControllerState() {
    step.value = "loading".tr;
    currentReceiver.value = null;
    currentConversation.value = null;
    progress.value = 0.0;
    currentPart.value = 0;
    uploading = false;
    endPart = 0;
    transactionId = null;
    transactionToken = null;
    uploadToken = null;
    filePath = null;
    zapperStarted = false;

    // Cancel the partSubscription if it exists and set it to null
    partSubscription?.cancel();
    partSubscription = null;
  }

  void cancel() {
    if (!isRunning()) {
      return;
    }
    if (uploading) {
      connector.sendAction(
        Message("cancel_transaction", <String, dynamic>{}),
      );
    } else {
      partSubscription?.cancel();
    }
    onTransactionEnd();
  }

  /// Open the window for zap share for a conversation
  void openWindow(Conversation conversation, ContextMenuData data) async {
    // If Zap Share is already doing something, show a menu
    if (isRunning()) {
      Get.dialog(ZapShareWindow(data: data, conversation: conversation));
      return;
    }

    // Grab files
    final file = await openFile();
    if (file == null) {
      return;
    }

    // Start the transaction
    newTransaction(conversation.otherMember.id, conversation.id, [file]);
  }

  //* Everything about sending starts here

  void newTransaction(LPHAddress friend, LPHAddress conversationId, List<XFile> files) async {
    if (files.length > 1) {
      sendLog("zapping multiple files is currently not supported");
      return;
    }
    if (isRunning()) {
      sendLog("Already in a transaction");
      return;
    }
    resetControllerState();
    step.value = "preparing".tr;
    waiting.value = true;
    uploading = true;
    sending = 0;

    // Generate chunks dir
    var tempPath = await getTemporaryDirectory();
    final tempDir = XDirectory(path.join(tempPath.path, "liphium"));
    await tempDir.create();
    chunksDir = await tempDir.createTemp("zapzap");
    await chunksDir!.create();
    sendLog(chunksDir!.path);

    // If there are more files than one, put them into an archive
    step.value = "chat.zapshare.compressing".tr;
    XFile file = files[0];

    // Intialize the encryption key
    key = randomSymmetricKey();

    // Start uploading the file
    filePath = file.path;
    final fileName = path.basename(file.path);
    final fileSize = await file.length();
    endPart = (fileSize.toDouble() / chunkSize.toDouble()).ceil();
    step.value = "chat.zapshare.waiting".tr;
    connector.sendAction(
      Message("create_transaction", <String, dynamic>{
        "name": fileName,
        "size": fileSize,
      }),
      handler: (event) {
        if (!event.data["success"]) {
          sendLog("creating transaction failed");
          showErrorPopup("error".tr, "zapshare.create_failed".tr);
          return;
        }

        currentReceiver.value = friend;
        currentConversation.value = conversationId;
        transactionId = event.data["id"];
        transactionToken = event.data["token"];
        uploadToken = event.data["upload_token"];

        // Send live share message
        final container = LiveshareInviteContainer(event.data["url"], transactionId!, transactionToken!, fileName, key!);
        sendActualMessage(false.obs, conversationId, msg.MessageType.liveshare, [], container.toJson(), "", () => {});
      },
    );
  }

  // For the zapper to know what to download
  int currentlySending = 0;
  int currentEndPart = 0;
  bool zapperStarted = false;

  /// Zap deamon
  void _startZapper(int start, int end) async {
    if (zapperStarted) {
      return;
    }
    zapperStarted = true;
    waiting.value = false;
    step.value = "chat.zapshare.uploading".tr;

    // Set the current variables
    currentlySending = start - 1;
    currentEndPart = end;
    bool uploaded = true;
    int tries = 0;

    while (true) {
      // Cancel if the thing isn't running anymore
      if (!isRunning()) {
        break;
      }

      // Cancel if it took to many tries to upload the current part
      if (tries > 5) {
        showErrorPopup("zap.error", "server.error".tr);
        cancel();
        break;
      }

      // Check if new parts can be sent
      if (currentlySending >= currentEndPart || !uploaded) {
        await Future.delayed(10.ms); // To prevent infinite spinning
        continue;
      }

      // Update all the variables to send the new part
      currentlySending++;
      progress.value = currentlySending / endPart;
      currentPart.value = currentlySending;

      // Send a new part
      uploaded = false;
      final success = await _sendActualFilePart(currentlySending);
      if (!success) {
        // Retry in case of an error and wait a little bit
        currentlySending--;
        tries++;
        await Future.delayed(2000.ms);
      } else {
        tries = 0;
      }
      uploaded = true;
    }
  }

  /// Upload the actual file part to the server
  Future<bool> _sendActualFilePart(int chunk) async {
    if (!isRunning()) {
      sendLog("why would the server ask for parts when zap share isn't even running :smug:");
      return false;
    }

    // Read the original file and extract one chunk
    final file = XFile(filePath!);
    final stream = file.openRead((chunk - 1) * chunkSize, chunk * chunkSize);
    final toEncrypt = <int>[];

    // Send the chunk once done
    final completer = Completer<bool>();
    stream.listen(
      (bytes) {
        toEncrypt.addAll(bytes);
      },
      cancelOnError: true,
      onError: (e) => sendLog(e),
      onDone: () async {
        // Encrypt all the bytes and write them to the chunk file
        final encrypted = encryptSymmetricBytes(Uint8List.fromList(toEncrypt), key!);

        // Send chunk
        final formData = d.FormData.fromMap({
          "id": transactionId,
          "token": uploadToken,
          "part": d.MultipartFile.fromBytes(encrypted, filename: "chunk_$chunk"),
        });
        final res = await dio.post(
          nodePath("/auth/liveshare/upload"),
          data: formData,
          options: d.Options(
            validateStatus: (status) => true,
            headers: {
              authorizationHeader: authorizationValue(),
            },
          ),
        );

        // Could've been stopped at this point
        if (!isRunning()) {
          completer.complete(true);
          return;
        }

        if (res.statusCode != 200) {
          sendLog("Failed to send chunk $chunk");
          completer.complete(false);
          return;
        }

        final json = jsonDecode(res.data);
        if (!json["success"]) {
          sendLog("Failed to send chunk $chunk cause ${json["error"]}");
          completer.complete(false);
          return;
        }

        completer.complete(true);
      },
    );

    return completer.future;
  }

  int sending = 0;

  /// Called for every file part sending request by the server
  void onFilePartRequest(Event event) async {
    if (!isRunning()) {
      sendLog("why would the server ask for parts when zap share isn't even running :smug:");
      return;
    }

    // Get the data from the event
    final start = event.data["start"] as int;
    final end = event.data["end"] as int;

    // Update the end (cause the zapper won't anymore cause it's already started)
    currentEndPart = end;

    // Start the zapper (in case it isn't started yet)
    _startZapper(start, end);
  }

  /// Called when a transaction is ended (only when sending)
  void onTransactionEnd() async {
    waiting.value = false;
    uploading = false;
    progress.value = 0.0;
    sending = 0;
    currentReceiver.value = null;
    currentConversation.value = null;
    transactionId = null;
    transactionToken = null;
    filePath = null;
    zapperStarted = false;
    uploadToken = null;
    Timer.periodic(2000.ms, (timer) async {
      try {
        await chunksDir?.delete(recursive: true);
        chunksDir = null;
        timer.cancel();
      } catch (e) {
        sendLog("couldn't delete chunk directory: $e");
      }
    });
    resetControllerState();
  }

  //* Everything about receiving starts here

  /// Join a transaction with a given ID and token + start listening for parts
  void joinTransaction(LPHAddress conversation, LPHAddress friendAddress, LiveshareInviteContainer container) async {
    if (isRunning()) {
      sendLog("Already in a transaction");
      return;
    }
    if (friendAddress == StatusController.ownAddress) {
      showErrorPopup("error", "chat.zapshare.not_send_self".tr);
      return;
    }
    resetControllerState();
    uploading = false;
    step.value = "preparing".tr;

    // Get info about the file
    final json = await postAny(
      "${nodeProtocol()}${container.url}/liveshare/info",
      {"id": container.id, "token": container.token},
    );
    if (!json["success"]) {
      showErrorPopup("error", "chat.zapshare.not_found".tr);
      return;
    }
    endPart = (json["size"].toDouble() / chunkSize.toDouble()).ceil();

    sendLog(base64Encode(container.key.extractBytes()));
    key = container.key;
    currentConversation.value = conversation;
    currentReceiver.value = friendAddress;

    // Subscribe to byte stream
    final formData = d.FormData.fromMap({
      "id": container.id,
      "token": container.token,
    });
    final res = await dio.post(
      "${nodeProtocol()}${container.url}/liveshare/subscribe",
      data: formData,
      options: d.Options(
        validateStatus: (status) => status != 404,
        responseType: d.ResponseType.stream,
        headers: {
          authorizationHeader: authorizationValue(),
        },
      ),
    );
    final body = res.data as d.ResponseBody;

    // Create receiving directory
    var tempPath = await getTemporaryDirectory();
    final tempDir = XDirectory(path.join(tempPath.path, "liphium"));
    await tempDir.create();
    final receiveDir = await tempDir.createTemp("liveshare-recv");
    await receiveDir.create();
    sendLog(receiveDir.path);

    // Data for downloads
    bool completed = false, waiting = false;
    int currentChunk = 0;
    int maxChunk = 0;
    int tries = 0;
    String receiverId = "";
    bool receivedInfo = false;

    // Listen for new parts
    step.value = "chat.zapshare.downloading".tr;
    partSubscription = body.stream.listen(
      (event) async {
        // Parse the server sent event (Format: data: <data>\n\n)
        final packet = utf8.decode(event);
        final data = packet.substring(6).trim();
        if (!receivedInfo) {
          receivedInfo = true;
          receiverId = data;
          return;
        }

        maxChunk = int.parse(data);
        if (currentChunk == 0) {
          currentChunk = maxChunk;

          while (true) {
            if (completed) {
              break;
            }

            // Only try a max of 5 times
            if (tries > 5) {
              showErrorPopup("zap.error", "server.error".tr);
              cancel();
              break;
            }

            // Check if new chunk is available
            if (waiting) {
              if (currentChunk < maxChunk) {
                currentChunk++;
                progress.value = currentChunk / endPart;
                waiting = false;
              } else {
                await Future.delayed(10.ms); // To prevent infinite spinning
                continue;
              }
            }

            // Download stuff
            final formData = d.FormData.fromMap({
              "id": container.id,
              "token": container.token,
              "chunk": currentChunk,
            });
            final res = await dio.download(
              "${nodeProtocol()}${container.url}/liveshare/download",
              "${receiveDir.path}/chunk_$currentChunk",
              data: formData,
              options: d.Options(
                validateStatus: (status) => true,
              ),
            );

            if (res.statusCode != 200) {
              sendLog("ERROR DOWNLOADING CHUNK $currentChunk");
              await Future.delayed(2000.ms); // Wait a little before trying again
              tries++;
              continue;
            }
            tries = 0;

            currentPart.value = currentChunk;

            // Check if new chunk can be downloaded right away
            if (currentChunk < maxChunk) {
              currentChunk++;
              waiting = false;
            } else {
              waiting = true;
            }

            _tellReceived(
              container.url,
              container.id,
              container.token,
              receiverId,
              callback: (complete) async {
                completed = complete;
                if (completed) {
                  sendLog("download completed, stitching..");
                  final dir = await _stitchFileTogether(container.fileName, receiveDir);
                  await receiveDir.delete(recursive: true);
                  if (dir != null) {
                    OpenAppFile.open(dir);
                  }
                  partSubscription?.cancel();
                }
              },
              onError: () => sendLog("error"),
            );
          }
        }
      },
      onError: (e) {
        sendLog("download error: $e");
      },
      cancelOnError: true,
      onDone: () async {
        onTransactionEnd();
        // Give time to delete files
        Timer(const Duration(seconds: 5), () {
          if (!completed) {
            receiveDir.delete(recursive: true);
          }
        });
      },
    );
  }

  void _tellReceived(String url, String id, String token, String receiverId, {Function(bool)? callback, Function()? onError}) async {
    // Send receive confirmation
    final res = await dio.post(
      "${nodeProtocol()}$url/liveshare/received",
      data: jsonEncode({
        "id": id,
        "token": token,
        "receiver": receiverId,
      }),
      options: d.Options(
        validateStatus: (status) => true,
      ),
    );

    if (res.statusCode != 200) {
      onError?.call();
      return;
    }

    if (!res.data["success"]) {
      onError?.call();
      return;
    }

    callback?.call(res.data["complete"]);
  }

  /// Returns the directory the file was saved to (if successful)
  Future<String?> _stitchFileTogether(String fileName, XDirectory dir) async {
    step.value = "chat.zapshare.finishing".tr;

    // Let the user pick where to store the finished file on desktop
    XFile file;
    if (GetPlatform.isDesktop) {
      final FileSaveLocation? result = await getSaveLocation(suggestedName: fileName);
      if (result == null) {
        showErrorPopup("error", "zap.no_save_location".tr);
        file = XFile(path.join(AttachmentController.getFilePathForType(StorageType.permanent), fileName));
      } else {
        file = XFile(result.path);
      }
    } else {
      // Just put it into the downloads folder
      // TODO: Check if this actually works on mobile
      final downloads = await getDownloadsDirectory();
      file = XFile(path.join(downloads!.path, fileName));
    }

    // Stitch together the final file
    int currentIndex = 1;
    while (true) {
      final chunk = XFile("${dir.path}/chunk_$currentIndex");
      if (!await doesFileExist(chunk)) {
        break;
      }

      // Decrypt the current chunk
      final bytes = await chunk.readAsBytes();
      final decrypted = decryptSymmetricBytes(bytes, key!);

      // Add the chunk to the file and delete the chunk
      await fileUtil.appendToFile(file, decrypted);
      fileUtil.delete(chunk);

      currentIndex++;
    }

    return path.dirname(file.path);
  }
}

class LiveshareInviteContainer {
  final String url;
  final String id;
  final String token;
  final String fileName;
  final SecureKey key;

  LiveshareInviteContainer(this.url, this.id, this.token, this.fileName, this.key);

  factory LiveshareInviteContainer.fromJson(String json) {
    final data = jsonDecode(json);
    return LiveshareInviteContainer(
      data["url"],
      data["id"],
      data["token"],
      data["name"],
      unpackageSymmetricKey(data["key"]),
    );
  }

  String toJson() {
    return jsonEncode({
      "url": url,
      "id": id,
      "token": token,
      "name": fileName,
      "key": packageSymmetricKey(key),
    });
  }
}
