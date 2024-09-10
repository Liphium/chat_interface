import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/database/database_entities.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/controller/current/steps/key_setup.dart';
import 'package:chat_interface/controller/current/steps/vault_setup.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

class LibraryManager {
  /// Load all new entries from the server
  static Future<String?> refreshEntries() async {
    // Get everything from the server after the date
    final json = await postAuthorizedJSON("/account/vault/list", {
      "after": 0,
      "tag": Constants.vaultLibraryTag,
    });

    // Check if there is an error
    if (!json["success"]) {
      return json["error"];
    }

    // Parse all the vault entries in an isolate
    final (parsed, ids) = await sodiumLib.runIsolated(
      (sodium, keys, pairs) {
        final list = <LibraryEntry>[];
        final ids = <String>[];
        for (var entryJson in json["entries"]) {
          final entry = VaultEntry.fromJson(entryJson);
          final libraryEntry = LibraryEntry.fromJson(entry.id, jsonDecode(entry.decryptedPayload(keys[0], sodium)));
          list.add(libraryEntry);
          ids.add(entry.id);
        }

        return (list, ids);
      },
      secureKeys: [vaultKey],
    );

    // Delete all library entries that aren't in the local database anymore
    await db.libraryEntry.deleteWhere((tbl) => tbl.id.isNotIn(ids));

    // Check if there are any
    if (parsed.isEmpty || ids.isEmpty) {
      return null;
    }

    // Add all of them to the database
    for (var entry in parsed) {
      await db.libraryEntry.insertOnConflictUpdate(entry.entity);
    }

    return null;
  }

  /// Remove a library entry from the library
  static Future<bool> removeEntryFromLibrary(LibraryEntry entry) async {
    // Remove from the vault on the server
    final error = await removeFromVault(entry.id);
    if (error != null) {
      showErrorPopup("error", error);
      return false;
    }

    // Remove from the local database
    await db.libraryEntry.deleteWhere((tbl) => tbl.id.equals(entry.id));

    return true;
  }

  /// Add a library entry to the library
  static Future<bool> addContainerToLibrary(AttachmentContainer container) async {
    // Convert container to library entry
    LibraryEntry? entry;
    switch (container.attachmentType) {
      // For normal downloaded files
      case AttachmentContainerType.file:
        if (!container.downloaded.value) {
          break;
        }
        final size = await _calculateImageDimension(Image.file(File(container.filePath)));
        entry = LibraryEntry(
          "",
          LibraryEntryType.fromFileName(container.filePath),
          jsonEncode(container.toJson()),
          DateTime.now(),
          size.width.toInt(),
          size.height.toInt(),
        );
      // For remote files stored on some kind of server
      case AttachmentContainerType.remoteImage:
        final size = await _calculateImageDimension(Image.network(container.url));
        entry = LibraryEntry(
          "",
          LibraryEntryType.fromFileName(container.url),
          container.url,
          DateTime.now(),
          size.width.toInt(),
          size.height.toInt(),
        );
      default:
        break;
    }

    // If the entry couldn't be added, show an error
    if (entry == null) {
      showErrorPopup("error", "app.error");
      return false;
    }

    // Add entry to server vault
    final id = await addToVault(Constants.vaultLibraryTag, jsonEncode(entry.toJson()));
    if (id == null) {
      showErrorPopup("error", "server.error");
      return false;
    }

    // Add to local database as well
    entry.id = id;
    await db.libraryEntry.insertOnConflictUpdate(entry.entity);
    return true;
  }

  /// Calculates the dimensions of a flutter image widget.
  static Future<Size> _calculateImageDimension(Image image) {
    Completer<Size> completer = Completer();
    final stream = image.image.resolve(const ImageConfiguration());
    ImageStreamListener? listener;
    stream.addListener(
      listener = ImageStreamListener(
        (ImageInfo image, bool synchronousCall) {
          var myImage = image.image;
          Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
          completer.complete(size);
          stream.removeListener(listener!);
        },
      ),
    );
    return completer.future;
  }
}

class LibraryEntry {
  String id;
  final LibraryEntryType type;
  final String data;
  final DateTime createdAt;
  final int width;
  final int height;

  LibraryEntry(this.id, this.type, this.data, this.createdAt, this.width, this.height);

  /// Get a library entry from the local database object
  LibraryEntry.fromData(LibraryEntryData data)
      : this(
          data.id,
          data.type,
          data.data,
          DateTime.fromMillisecondsSinceEpoch(data.createdAt.toInt()),
          data.width,
          data.height,
        );

  get entity => LibraryEntryData(
        id: id,
        type: type,
        createdAt: BigInt.from(createdAt.millisecondsSinceEpoch),
        data: data,
        width: width,
        height: height,
      );

  /// Convert a LibraryEntry to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'data': data,
      'created_at': createdAt.millisecondsSinceEpoch,
      'width': width,
      'height': height,
    };
  }

  /// Create a LibraryEntry from a JSON map
  factory LibraryEntry.fromJson(String id, Map<String, dynamic> json) {
    return LibraryEntry(
      id,
      LibraryEntryType.values[json['type']],
      json['data'],
      DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      json['width'],
      json['height'],
    );
  }
}
