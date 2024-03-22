import 'dart:io';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:file_selector/file_selector.dart';
import 'package:get/get.dart';

class LiveShareController extends GetxController {
  final currentFile = Rx<XFile?>(null);

  // Current transaction
  final enabled = false.obs;
  String? transactionId;
  String? transactionToken;
  Directory? chunksDir;

  static const chunkSize = 512 * 1024;

  /// Start a transaction with a new file
  void startSharing() async {
    if (currentFile.value == null) {
      return;
    }

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
        sendLog("Transaction ID: $transactionId");
        sendLog("Transaction token: $transactionToken");

        // Prepare sending

        // Share with self for now
        _joinTransaction(transactionId!, transactionToken!);
      },
    );
  }

  void sendFilePart(Event event) {
    final index = event.data["index"] as int;
  }

  void _joinTransaction(String id, String token) {
    if (transactionId == null || transactionToken == null) {
      return;
    }

    connector.sendAction(
      Message("join_transaction", <String, dynamic>{
        "id": transactionId,
        "token": transactionToken,
      }),
      handler: (event) {
        sendLog("Joined transaction");
      },
    );
  }
}
