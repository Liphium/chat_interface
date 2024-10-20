import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:liphium_bridge/src/base.dart';

class FileUtil extends FileUtilBase {
  @override
  Future<bool> delete(XFile file, {bool recursive = false}) async {
    await File(file.path).delete(recursive: recursive);
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
