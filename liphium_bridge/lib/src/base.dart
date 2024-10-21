import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:liphium_bridge/src/interface.dart'
    if (dart.library.io) "package:liphium_bridge/src/native.dart"
    if (dart.library.js) "package:liphium_bridge/src/web.dart";

final FileUtil fileUtil = FileUtil();

abstract class FileUtilBase {
  /// Delete a file.
  ///
  /// On web, this method only returns true since deleting files isn't supported there.
  Future<bool> delete(XFile file, {bool recursive = false});

  /// Append bytes to a file. If the file doesn't exist yet, it is created.
  ///
  /// On web, this method throws an exception since it's not supported there.
  Future<bool> appendToFile(XFile file, Uint8List bytes);
}

abstract class XDirectoryBase {
  final String path;

  XDirectoryBase(this.path);

  Future<XDirectoryBase> createTemp([String? prefix]);
  Future<XDirectoryBase> create();
  Future<bool> delete({bool recursive = false});
}
