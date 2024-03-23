import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart' as msg;
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/chat/components/message/message_feed.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/web.dart';
import 'package:dio/dio.dart' as d;
import 'package:file_selector/file_selector.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sodium_libs/sodium_libs.dart';

class LiveShareController extends GetxController {
  // Current transaction
  final currentReceiver = Rx<String?>(null);
  final currentConversation = Rx<String?>(null);
  final loading = false.obs;
  final progress = 0.0.obs;
  bool uploading = false;
  int endPart = 0;
  String? transactionId;
  String? transactionToken;
  String? uploadToken;
  String? filePath;
  Directory? chunksDir;
  StreamSubscription<Uint8List>? partSubscription;

  static const chunkSize = 512 * 1024;

  bool isRunning() {
    return currentReceiver.value != null && currentConversation.value != null;
  }

  void cancel() {
    if (currentReceiver.value == null || currentConversation.value == null) {
      return;
    }
    if (uploading) {
      connector.sendAction(
        Message("cancel_transaction", <String, dynamic>{}),
      );
    } else {
      partSubscription?.cancel();
    }
  }

  //* Everything about sending starts here

  void newTransaction(String friendId, String conversationId, XFile shared) async {
    if (currentReceiver.value != null || currentConversation.value != null || loading.value) {
      sendLog("Already in a transaction");
      return;
    }
    loading.value = true;
    uploading = true;

    // Generate chunks dir
    var tempDir = await getTemporaryDirectory();
    tempDir = Directory("${tempDir.path}/liphium");
    await tempDir.create();
    chunksDir = await tempDir.createTemp("liveshare");
    await chunksDir!.create();
    sendLog(chunksDir!.path);

    final file = File(shared.path);
    filePath = shared.path;
    final fileSize = await file.length();
    endPart = (fileSize.toDouble() / chunkSize.toDouble()).ceil();
    connector.sendAction(
      Message("create_transaction", <String, dynamic>{
        "name": shared.name,
        "size": fileSize,
      }),
      handler: (event) {
        if (!event.data["success"]) {
          sendLog("creating transaction failed");
          showErrorPopup("error".tr, "liveshare.create_failed".tr);
          return;
        }

        currentReceiver.value = friendId;
        currentConversation.value = conversationId;
        transactionId = event.data["id"];
        transactionToken = event.data["token"];
        uploadToken = event.data["upload_token"];

        // Send live share message
        final container = LiveshareInviteContainer(event.data["url"], transactionId!, transactionToken!, shared.name, randomSymmetricKey());
        sendActualMessage(false.obs, conversationId, msg.MessageType.liveshare, [], container.toJson(), "", () => {});
      },
    );
  }

  int sending = 0;

  /// Called for every file part sending event (only when sending)
  void sendFilePart(Event event) async {
    loading.value = false;
    final start = event.data["start"] as int;
    //final end = event.data["end"] as int;
    if (sending >= start) {
      return;
    }
    final prevSending = sending;
    sending = start;
    progress.value = start / endPart;

    final file = File(filePath!);

    // Read the original file and extract one chunk
    final stream = file.openRead((start - 1) * chunkSize, start * chunkSize);
    final chunkFile = File("${chunksDir!.path}/chunk_$start");
    await chunkFile.create();
    final writeStream = chunkFile.openWrite();

    // Send the chunk once done
    stream.listen(
      (event) => writeStream.add(event),
      cancelOnError: true,
      onError: (e) => sendLog(e),
      onDone: () async {
        // Save chunk to file
        await writeStream.flush();
        await writeStream.close();

        // Send chunk
        final formData = d.FormData.fromMap({
          "id": transactionId,
          "token": uploadToken,
          "part": await d.MultipartFile.fromFile(chunkFile.path),
        });
        final res = await dio.post(
          nodePath("/auth/liveshare/upload"),
          data: formData,
          options: d.Options(
            validateStatus: (status) => status != 404,
            headers: {
              authorizationHeader: authorizationValue(),
            },
          ),
        );
        if (res.statusCode != 200) {
          sending = prevSending;
          sendLog("Failed to send chunk $start");
          return;
        }

        sendLog("sent chunk $start");
      },
    );
  }

  /// Called when a transaction is ended (only when sending)
  void onTransactionEnd() async {
    loading.value = false;
    uploading = false;
    progress.value = 0.0;
    currentReceiver.value = null;
    currentConversation.value = null;
    transactionId = null;
    transactionToken = null;
    filePath = null;
    uploadToken = null;
    await chunksDir?.delete(recursive: true);
    chunksDir = null;
  }

  //* Everything about receiving starts here

  /// Join a transaction with a given ID and token + start listening for parts
  void joinTransaction(String conversation, String friendId, LiveshareInviteContainer container) async {
    if (currentReceiver.value != null || currentConversation.value != null || loading.value) {
      sendLog("Already in a transaction");
      return;
    }
    if (friendId == StatusController.ownAccountId) {
      showErrorPopup("error", "chat.liveshare.not_send_self");
      return;
    }
    uploading = false;

    // Get info about the file
    final json = await postAny(
      "$nodeProtocol${container.url}/liveshare/info",
      {"id": container.id, "token": container.token},
    );
    if (!json["success"]) {
      sendLog("failed to get info");
      return;
    }
    endPart = (json["size"].toDouble() / chunkSize.toDouble()).ceil();

    currentConversation.value = conversation;
    currentReceiver.value = friendId;

    // Subscribe to byte stream
    final formData = d.FormData.fromMap({
      "id": container.id,
      "token": container.token,
    });
    final res = await dio.post(
      "$nodeProtocol${container.url}/liveshare/subscribe",
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
    var tempDir = await getTemporaryDirectory();
    tempDir = Directory("${tempDir.path}/liphium");
    await tempDir.create();
    final receiveDir = await tempDir.createTemp("liveshare-recv");
    await receiveDir.create();
    sendLog(receiveDir.path);

    // Data for downloads
    bool completed = false, downloading = false, waiting = false;
    int currentChunk = 0;
    int maxChunk = 0;
    String receiverId = "";
    bool receivedInfo = false;

    // Listen for new parts
    Timer? downloadTimer;
    partSubscription = body.stream.listen(
      (event) async {
        // Parse the server sent event (Format: data: <data>\n\n)
        final packet = String.fromCharCodes(event);
        final data = packet.substring(6).trim();
        if (!receivedInfo) {
          receivedInfo = true;
          receiverId = data;
          return;
        }

        sendLog("can now download until $data");

        maxChunk = int.parse(data);
        if (currentChunk == 0) {
          currentChunk = maxChunk;

          // Start a timer for downloading the parts
          downloadTimer = Timer.periodic(20.ms, (timer) async {
            if (downloading) return;
            if (completed) {
              timer.cancel();
              return;
            }

            // Check if new chunk is available
            if (waiting) {
              if (currentChunk < maxChunk) {
                currentChunk++;
                progress.value = currentChunk / endPart;
                waiting = false;
              } else {
                return;
              }
            }
            downloading = true;

            // Download stuff
            final formData = d.FormData.fromMap({
              "id": container.id,
              "token": container.token,
              "chunk": currentChunk,
            });
            final res = await dio.download(
              "$nodeProtocol${container.url}/liveshare/download",
              "${receiveDir.path}/chunk_$currentChunk",
              data: formData,
              options: d.Options(
                validateStatus: (status) => status != 404,
              ),
            );

            if (res.statusCode != 200) {
              sendLog("ERROR DOWNLOADING CHUNK $currentChunk");
              return;
            }

            sendLog("downloaded chunk $currentChunk");
            downloading = false;

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
                  await _stitchFileTogether(container.fileName, receiveDir);
                  await receiveDir.delete(recursive: true);
                  OpenAppFile.open((await getDownloadsDirectory())!.path);
                  partSubscription?.cancel();
                }
                sendLog("is completed: $complete");
              },
              onError: () => sendLog("error"),
            );
          });
        }
      },
      onError: (e) {
        sendLog("download error: $e");
      },
      cancelOnError: true,
      onDone: () async {
        downloadTimer?.cancel();
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
      "$nodeProtocol$url/liveshare/received",
      data: jsonEncode({
        "id": id,
        "token": token,
        "receiver": receiverId,
      }),
      options: d.Options(
        validateStatus: (status) => status != 404,
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

  Future<bool> _stitchFileTogether(String fileName, Directory dir) async {
    final downloads = await getDownloadsDirectory();
    final file = File("${downloads!.path}/$fileName");

    int currentIndex = 1;
    while (true) {
      final chunk = File("${dir.path}/chunk_$currentIndex");
      final exists = await chunk.exists();
      if (!exists) {
        break;
      }

      await file.writeAsBytes(await chunk.readAsBytes(), mode: currentIndex == 1 ? FileMode.write : FileMode.append);
      chunk.delete();

      currentIndex++;
    }

    return true;
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
