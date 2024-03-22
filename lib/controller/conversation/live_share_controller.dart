import 'dart:convert';
import 'dart:io';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:dio/dio.dart' as d;
import 'package:file_selector/file_selector.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

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
    final stream = file.openRead(start * chunkSize, (start + 1) * chunkSize);
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

    String receiverId = "";
    bool receivedInfo = false;

    // Create receiving directory
    var tempDir = await getTemporaryDirectory();
    tempDir = Directory("${tempDir.path}/liphium");
    await tempDir.create();
    final receiveDir = await tempDir.createTemp("liveshare-recv");
    await receiveDir.create();
    sendLog(receiveDir.path);

    var currentBuffer = <int>[];

    // Listen for new parts
    body.stream.listen((bytes) async {
      if (!receivedInfo) {
        receivedInfo = true;
        final json = jsonDecode(String.fromCharCodes(bytes));
        receiverId = json["id"];
        sendLog("starting to receive chunks for $receiverId");
        return;
      }

      final text = String.fromCharCodes(bytes);
      if (text.startsWith("\n\nc:")) {
        final args = text.split(":");
        final chunkId = args[1].trim();

        // Save to file
        sendLog("storing chunk $chunkId..");
        final partFile = File("${receiveDir.path}/chunk_$chunkId");
        partFile.writeAsBytes(currentBuffer, mode: FileMode.writeOnlyAppend);

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
          sendLog("Failed to send receive confirmation");
          return;
        }

        if (!res.data["success"]) {
          sendLog("Failed to send receive confirmation");
          return;
        }

        // Clear buffer
        currentBuffer.clear();
        sendLog("stored chunk $chunkId");

        if (res.data["complete"]) {
          sendLog("received all chunks");
          return;
        }

        sendLog("starting with next chunk");
        return;
      }

      // Save the part to file
      currentBuffer += bytes;
    });
  }
}
