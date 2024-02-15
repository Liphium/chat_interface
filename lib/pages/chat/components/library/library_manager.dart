import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/database/accounts/library_entry.dart';
import 'package:chat_interface/database/database.dart';
import 'package:flutter/material.dart';

class LibraryManager {
  static Future<LibraryEntryData?> getFromContainer(AttachmentContainer container) async {
    switch (container.attachmentType) {
      // For normal downloaded files
      case AttachmentContainerType.file:
        if (!container.downloaded.value) {
          return null;
        }
        final size = await _calculateImageDimension(Image.file(File(container.filePath)));
        return LibraryEntryData(
          type: LibraryEntryType.fromFileName(container.filePath),
          createdAt: BigInt.from(DateTime.now().millisecondsSinceEpoch),
          data: jsonEncode(container.toJson()),
          width: size.width.toInt(),
          height: size.height.toInt(),
        );

      // For remote files stored on some kind of server
      case AttachmentContainerType.remoteImage:
        final size = await _calculateImageDimension(Image.network(container.url));
        return LibraryEntryData(
          type: LibraryEntryType.fromFileName(container.url),
          createdAt: BigInt.from(DateTime.now().millisecondsSinceEpoch),
          data: container.url,
          width: size.width.toInt(),
          height: size.height.toInt(),
        );
      default:
        break;
    }
    return null;
  }

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
