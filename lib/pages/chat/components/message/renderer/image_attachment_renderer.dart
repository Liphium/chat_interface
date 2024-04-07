import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:flutter/material.dart';

class ImageAttachmentRenderer extends StatefulWidget {
  final AttachmentContainer image;

  const ImageAttachmentRenderer({super.key, required this.image});

  @override
  State<ImageAttachmentRenderer> createState() => _ImageAttachmentRendererState();
}

class _ImageAttachmentRendererState extends State<ImageAttachmentRenderer> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
