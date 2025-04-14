import 'dart:async';
import 'dart:convert';

import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/database/database_entities.dart';
import 'package:chat_interface/controller/current/tasks/vault_sync_task.dart';
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/encryption/hash.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LibraryManager extends VaultTarget {
  LibraryManager() : super(Constants.vaultLibraryTag);

  @override
  Future<void> processEntries(List<String> deleted, List<VaultEntry> newEntries) async {
    // Add all new entries
    final list = <LibraryEntry>[];
    for (var entry in newEntries) {
      final libraryEntry = LibraryEntry.fromJson(entry.id, jsonDecode(entry.payload));
      list.add(libraryEntry);
      await db.libraryEntry.insertOnConflictUpdate(await libraryEntry.entity);
    }

    // Delete all library entries that aren't in the local database anymore
    await db.libraryEntry.deleteWhere((tbl) => tbl.id.isIn(deleted));

    return;
  }

  /// Remove a library entry from the library
  static Future<bool> removeEntryFromLibrary(LibraryEntry entry) async {
    // Remove from the vault on the server
    final error = await removeFromVault(entry.id);
    if (error != null) {
      showErrorPopup("error", error);
      return false;
    }

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
        final size = await _calculateImageDimension(
          Image.memory(await container.file!.readAsBytes()),
        );
        entry = LibraryEntry(
          "",
          LibraryEntryType.fromFileName(container.file!.path),
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
      showErrorPopup("error", "app.error".tr);
      return false;
    }

    // Add entry to server vault
    final (error, _) = await addToVault(Constants.vaultLibraryTag, jsonEncode(entry.toJson()));
    if (error != null) {
      showErrorPopup("error", error);
      return false;
    }
    return true;
  }

  /// Calculates the dimensions of a flutter image widget.
  static Future<Size> _calculateImageDimension(Image image) {
    Completer<Size> completer = Completer();
    final stream = image.image.resolve(const ImageConfiguration());
    ImageStreamListener? listener;
    stream.addListener(
      listener = ImageStreamListener((ImageInfo image, bool synchronousCall) {
        var myImage = image.image;
        Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
        completer.complete(size);
        stream.removeListener(listener!);
      }),
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
  String? identifier;
  AttachmentContainer? container;

  LibraryEntry(this.id, this.type, this.data, this.createdAt, this.width, this.height);

  /// Get a library entry from the local database object
  static Future<LibraryEntry> fromData(LibraryEntryData data) async {
    // Migrate to new system in case still not database encrypted
    if (data.identifierHash == "to-migrate") {
      // Get the new identifier
      final container = await AttachmentController.fromString(data.data);
      final identifier = LibraryEntry.entryIdentifier(container);

      // Fix the entry
      data = LibraryEntryData(
        id: data.id,
        type: data.type,
        createdAt: data.createdAt,
        identifierHash: identifier,
        data: dbEncrypted(data.data),
        width: data.width,
        height: data.height,
      );
      unawaited(db.libraryEntry.insertOnConflictUpdate(data));
    }

    // Create the actual library entry
    final entry = LibraryEntry(
      data.id,
      data.type,
      fromDbEncrypted(data.data),
      DateTime.fromMillisecondsSinceEpoch(data.createdAt.toInt()),
      data.width,
      data.height,
    );
    entry.identifier = data.identifierHash;

    return entry;
  }

  Future<LibraryEntryData> get entity async => LibraryEntryData(
    id: id,
    type: type,
    createdAt: BigInt.from(createdAt.millisecondsSinceEpoch),
    identifierHash: identifier ?? (await getIdentifier()),
    data: dbEncrypted(data),
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

  /// Get the identifier of the library entry.
  Future<String> getIdentifier() async {
    final container = await AttachmentController.fromString(data);
    return LibraryEntry.entryIdentifier(container);
  }

  /// Load all the things needed for displaying the entry.
  Future<void> initForUI() async {
    container = await AttachmentController.fromString(data);
    identifier = LibraryEntry.entryIdentifier(container!);
  }

  /// Get the identifier of a Library entry from an AttachmentContainer.
  static String entryIdentifier(AttachmentContainer container) {
    // If it's a file hash the file id
    if (container.attachmentType == AttachmentContainerType.file) {
      return hashSha(container.id);
    }

    // Otherwise hash the URL of the remote container
    return hashSha(container.url);
  }
}
