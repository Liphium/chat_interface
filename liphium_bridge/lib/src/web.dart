import 'dart:ui' as ui;

import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liphium_bridge/src/base.dart';

// Feature support
const isDirectorySupported = false;

class FileUtil extends FileUtilBase {
  @override
  Future<bool> delete(XFile file, {bool recursive = false}) async {
    return true;
  }

  @override
  Future<bool> appendToFile(XFile file, Uint8List bytes) {
    throw UnsupportedError("appendToFile() is not supported on the web.");
  }

  @override
  Future<bool> write(XFile file, Uint8List bytes) {
    throw UnsupportedError("write() is not supported on the web.");
  }
}

/// A wrapper for making displaying images easier with cross_file
class XImage extends StatelessWidget {
  final XFile file;
  final BoxFit? fit;
  final double? width;
  final double? height;

  const XImage({
    super.key,
    required this.file,
    this.fit,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Image(
      image: XFileImage(file),
      fit: fit,
      width: width,
      height: height,
    );
  }
}

/// Decodes the given [XFile] object as an image, associating it with the given
/// scale.
///
/// The provider does not monitor the file for changes. If you expect the
/// underlying data to change, you should call the [evict] method.
///
/// This class was copied from the pub package `cross_file_image` and slight
/// modifications were made.
///
/// Copyright (c) 2021 7c00 <i@7c00.cc>
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.
@immutable
class XFileImage extends ImageProvider<XFileImage> {
  /// Creates an object that decodes a [XFile] as an image.
  ///
  /// The arguments must not be null.
  const XFileImage(this.file, {this.scale = 1.0});

  /// The file to decode into an image.
  final XFile file;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  @override
  Future<XFileImage> obtainKey(final ImageConfiguration configuration) => SynchronousFuture<XFileImage>(this);

  @override
  ImageStreamCompleter loadImage(
    final XFileImage key,
    final ImageDecoderCallback decode,
  ) =>
      MultiFrameImageStreamCompleter(
        codec: _loadAsync(key, decode),
        scale: key.scale,
        debugLabel: key.file.path,
        informationCollector: () sync* {
          yield ErrorDescription('Path: ${file.path}');
        },
      );

  Future<ui.Codec> _loadAsync(
    final XFileImage key,
    final ImageDecoderCallback decode,
  ) async {
    final bytes = await file.readAsBytes();

    if (bytes.lengthInBytes == 0) {
      // The file may become available later.
      PaintingBinding.instance.imageCache.evict(key);
      throw StateError('$file is empty and cannot be loaded as an image.');
    }

    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);

    return decode(buffer);
  }
}

class XDirectory extends XDirectoryBase {
  XDirectory(super.path);

  @override
  Future<XDirectory> createTemp([String? prefix]) {
    throw UnimplementedError("createTemp() is not supported.");
  }

  @override
  Future<XDirectory> create() {
    throw UnimplementedError("create() is not supported.");
  }

  @override
  Future<bool> delete({bool recursive = false}) {
    throw UnimplementedError("delete() is not supported.");
  }
}
