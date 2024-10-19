import 'package:cross_file/cross_file.dart';
import 'package:liphium_bridge/src/base.dart';

class FileUtil extends FileUtilBase {
  @override
  Future<bool> delete(XFile file, {bool recursive = false}) {
    throw UnimplementedError("delete() is not implemented.");
  }
}
