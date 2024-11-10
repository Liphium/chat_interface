import 'dart:io';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:liphium_bridge/src/base.dart';

// Feature support
const isDirectorySupported = true;

class FileUtil extends FileUtilBase {
  @override
  Future<bool> delete(XFile file, {bool recursive = false}) async {
    await File(file.path).delete(recursive: recursive);
    return true;
  }

  @override
  Future<bool> appendToFile(XFile file, Uint8List bytes) async {
    await File(file.path).writeAsBytes(bytes, mode: FileMode.writeOnlyAppend);
    return true;
  }

  @override
  Future<bool> write(XFile file, Uint8List bytes) async {
    await File(file.path).writeAsBytes(bytes, mode: FileMode.write);
    return true;
  }
}

// The desktop implementation just uses the normal image with a file from dart:io.
class XImage extends StatelessWidget {
  final XFile file;
  final BoxFit? fit;
  final double? width;
  final double? height;

  const XImage({
    super.key,
    required this.file,
    this.width,
    this.height,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(file.path),
      fit: fit,
      width: width,
      height: height,
    );
  }
}

class XDirectory extends XDirectoryBase {
  late final Directory _directory;

  XDirectory(super.path) {
    _directory = Directory(path);
  }

  @override
  Future<XDirectory> create() async {
    final dir = await _directory.create();
    return XDirectory(dir.path);
  }

  @override
  Future<XDirectory> createTemp([String? prefix]) async {
    final dir = await _directory.createTemp(prefix);
    return XDirectory(dir.path);
  }

  @override
  Future<bool> delete({bool recursive = false}) async {
    await _directory.delete(recursive: recursive);
    return true;
  }
}
