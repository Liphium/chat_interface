import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:dio/dio.dart' as d;
import 'package:file_selector/file_selector.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sodium_libs/sodium_libs.dart';

class LiveShareController extends GetxController {
  final currentFile = Rx<XFile?>(null);

  // Current transaction
  final enabled = false.obs;
  String? transactionId;
  String? transactionToken;
  String? uploadToken;
  Directory? chunksDir;

  static const chunkSize = 512 * 1024;

  /// Start a transaction with a new file
  void startSharing() async {
    if (currentFile.value == null) {
      return;
    }

    // Generate chunks dir
    var tempDir = await getTemporaryDirectory();
    tempDir = Directory("${tempDir.path}/liphium");
    await tempDir.create();
    chunksDir = await tempDir.createTemp("liveshare");
    await chunksDir!.create();
    sendLog(chunksDir!.path);

    final file = File(currentFile.value!.path);
    final fileSize = await file.length();
    sendLog("File name: ${currentFile.value!.name}");
    sendLog("File size: $fileSize");
    connector.sendAction(
      Message("create_transaction", <String, dynamic>{
        "name": currentFile.value!.name,
        "size": fileSize,
      }),
      handler: (event) {
        if (!event.data["success"]) {
          sendLog("creating transaction failed");
          return;
        }

        enabled.value = true;
        transactionId = event.data["id"];
        transactionToken = event.data["token"];
        uploadToken = event.data["upload_token"];
        sendLog("Transaction ID: $transactionId");
        sendLog("Transaction token: $transactionToken");

        // Prepare sending

        // Share with self for now
        _joinTransaction(transactionId!, transactionToken!);
      },
    );
  }

  int sending = 0;
  void sendFilePart(Event event) async {
    final start = event.data["start"] as int;
    //final end = event.data["end"] as int;
    if (sending >= start) {
      return;
    }
    final prevSending = sending;
    sending = start;

    // Send one part for now
    final file = File(currentFile.value!.path);

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

  void _joinTransaction(String id, String token) async {
    if (transactionId == null || transactionToken == null) {
      return;
    }

    // Subscribe to byte stream
    final formData = d.FormData.fromMap({
      "id": id,
      "token": token,
    });
    final res = await dio.post(
      nodePath("/liveshare/subscribe"),
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
    body.stream.listen((event) async {
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
        Timer.periodic(20.ms, (timer) async {
          if (downloading) return;
          if (completed) {
            timer.cancel();
            return;
          }

          // Check if new chunk is available
          if (waiting) {
            if (currentChunk < maxChunk) {
              currentChunk++;
              waiting = false;
            } else {
              return;
            }
          }
          downloading = true;

          // Download stuff
          final formData = d.FormData.fromMap({
            "id": id,
            "token": token,
            "chunk": currentChunk,
          });
          final res = await dio.download(
            nodePath("/liveshare/download"),
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
            id,
            token,
            receiverId,
            callback: (complete) {
              completed = complete;
              if (completed) {
                _stitchFileTogether("test.mkv", receiveDir);
              }
              sendLog("is completed: $complete");
            },
            onError: () => sendLog("error"),
          );
        });
      }
    });
  }

  void _tellReceived(String id, String token, String receiverId, {Function(bool)? callback, Function()? onError}) async {
    // Send receive confirmation
    final res = await dio.post(
      nodePath("/liveshare/received"), // TODO: Eventually use domain of the node here (might be different from the server domain)
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

  void _stitchFileTogether(String fileName, Directory dir) async {
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
  }
}

class LiveshareInviteContainer {
  final String id;
  final String token;
  final SecureKey key;

  LiveshareInviteContainer(this.id, this.token, this.key);

  factory LiveshareInviteContainer.fromJson(String json) {
    final data = jsonDecode(json);
    return LiveshareInviteContainer(
      data["id"],
      data["token"],
      unpackageSymmetricKey(data["key"]),
    );
  }

  String toJson() {
    return jsonEncode({
      "id": id,
      "token": token,
      "key": packageSymmetricKey(key),
    });
  }
}
