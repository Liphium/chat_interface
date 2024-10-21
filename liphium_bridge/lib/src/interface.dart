import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:liphium_bridge/src/base.dart';

// Feature support
const isDirectorySupported = false;

class FileUtil extends FileUtilBase {
  @override
  Future<bool> delete(XFile file, {bool recursive = false}) {
    throw UnimplementedError("delete() is not implemented.");
  }

  @override
  Future<bool> appendToFile(XFile file, Uint8List bytes) {
    throw UnimplementedError("appendToFile() is not implemented.");
  }
}

/// A wrapper for making displaying images easier with cross_file.
///
/// The native implementation just uses the normal image with a file from dart:io.
///
/// The web implementation falls back to using an image provider that reads the bytes
/// from the file and turns them into an image.
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
    return const Placeholder();
  }
}

class XDirectory extends XDirectoryBase {
  XDirectory(super.path);

  @override
  Future<XDirectory> createTemp([String? prefix]) {
    throw UnimplementedError("createTemp() is not implemented.");
  }

  @override
  Future<XDirectory> create() {
    throw UnimplementedError("create() is not implemented.");
  }

  @override
  Future<bool> delete({bool recursive = false}) {
    throw UnimplementedError("delete() is not implemented");
  }
}
