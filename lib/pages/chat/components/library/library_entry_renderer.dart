import 'package:chat_interface/database/database.dart';
import 'package:flutter/widgets.dart';

class LibraryEntryRenderer extends StatefulWidget {
  final LibraryEntryData data;

  const LibraryEntryRenderer({
    super.key,
    required this.data,
  });

  @override
  State<LibraryEntryRenderer> createState() => _LibraryEntryRendererState();
}

class _LibraryEntryRendererState extends State<LibraryEntryRenderer> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
