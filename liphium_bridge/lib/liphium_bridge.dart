/// An extension library for Liphium to be able to all kinds of things on all major platforms.
/// Supports all major platforms supported by Flutter.
library liphium_bridge;

export "src/base.dart" show fileUtil;
export "src/interface.dart"
    if (dart.library.io) "src/native.dart"
    if (dart.library.js) "src/web.dart"
    show XImage, XDirectory, isDirectorySupported;
export "src/web.dart" show XFileImage;
