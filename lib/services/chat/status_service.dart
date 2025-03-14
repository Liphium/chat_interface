import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/services/chat/conversation_service.dart';
import 'package:chat_interface/services/connection/connection.dart';
import 'package:chat_interface/services/connection/messaging.dart';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class StatusService {
  /// Send a new status packet informing all friends about a new status.
  ///
  /// Returns an error if there was one.
  static Future<String?> sendStatus({String? message, int? type}) async {
    // Validate the status to make sure everything is fine
    final event = await connector.sendActionAndWait(ServerAction("st_validate", <String, dynamic>{
      "status": StatusController.statusPacket(StatusController.newStatusJson(
        message ?? StatusController.status.peek(),
        type ?? StatusController.type.peek(),
      )),
      "data": StatusController.sharedContentPacket(),
    }));
    if (event == null) {
      return "server.error".tr;
    }
    if (!event.data["success"]) {
      return event.data["message"];
    }

    // Update teh status in the controller
    StatusController.updateStatus(message: message, type: type);

    // Send the new status
    ConversationService.subscribeToConversations();
    return null;
  }

  /// Log out of the current account.
  ///
  /// Optionally delete all local database tables and files.
  static Future<void> logOut({deleteEverything = false, deleteFiles = false}) async {
    // Delete the session information
    await db.setting.deleteWhere((tbl) => tbl.key.equals("profile"));

    // Delete all data
    if (deleteEverything) {
      for (var table in db.allTables) {
        await table.deleteAll();
      }
    }

    // Delete all files
    if (deleteFiles) {
      await AttachmentController.deleteAllFiles();
    }

    // Exit the app
    await SystemNavigator.pop(animated: true);
  }
}
