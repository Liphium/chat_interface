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
}
