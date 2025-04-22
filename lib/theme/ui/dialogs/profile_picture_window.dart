import 'dart:ui' as ui;

import 'package:chat_interface/services/chat/profile_picture_helper.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/fj_slider.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import 'package:signals/signals_flutter.dart';

class ProfilePictureWindow extends StatefulWidget {
  final XFile file;

  const ProfilePictureWindow({super.key, required this.file});

  @override
  State<ProfilePictureWindow> createState() => _ProfilePictureWindowState();
}

class _ProfilePictureWindowState extends State<ProfilePictureWindow> {
  double minScale = 0;
  double maxScale = 0;
  late final _scaleFactor = signal(1.0);
  late final _moveX = signal(0.0);
  late final _moveY = signal(0.0);

  late final _uploading = signal(false);
  late final _image = signal<ui.Image?>(null);

  @override
  void initState() {
    initImage();
    super.initState();
  }

  @override
  void dispose() {
    _scaleFactor.dispose();
    _moveX.dispose();
    _moveY.dispose();
    _uploading.dispose();
    _image.dispose();
    super.dispose();
  }

  Future<void> initImage() async {
    final image = await ProfileHelper.loadImage(widget.file.path);
    if (image == null) return;

    // Calculate the scale factor to fit the image into the window
    if (image.width < image.height) {
      _scaleFactor.value = 1.0 / (300.0 / image.width.toDouble());
      maxScale = _scaleFactor.value;
    } else {
      _scaleFactor.value = 1.0 / (300.0 / image.height.toDouble());
      maxScale = _scaleFactor.value;
    }

    _image.value = image;
  }

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      maxWidth: 450,
      child: Watch((ctx) {
        if (_image.value == null) {
          return SizedBox(
            height: 100,
            width: 100,
            child: Center(child: CircularProgressIndicator(color: Get.theme.colorScheme.onPrimary)),
          );
        }

        final scale = _scaleFactor.value;
        final offset = Offset(_moveX.value, _moveY.value);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("settings.data.profile_picture.select".tr, style: Get.theme.textTheme.bodyMedium),
            verticalSpacing(sectionSpacing),
            Center(
              child: ClipOval(
                child: SizedBox(
                  height: 300,
                  width: 300,
                  child: RawImage(
                    fit: BoxFit.none,
                    scale: scale,
                    image: _image.value,
                    alignment: Alignment(offset.dx, offset.dy),
                  ),
                ),
              ),
            ),
            verticalSpacing(defaultSpacing),
            Row(
              children: [
                Text("zoom".tr, style: Get.theme.textTheme.labelMedium),
                horizontalSpacing(defaultSpacing),
                Expanded(
                  child: FJSlider(
                    value: (maxScale - _scaleFactor.value) + 0.5,
                    min: 0.5,
                    max: maxScale + 0.45,
                    onChanged: (val) {
                      _scaleFactor.value = (maxScale - val) + 0.5;
                    },
                  ),
                ),
                horizontalSpacing(defaultSpacing),
                Text(((maxScale - _scaleFactor.value) + 0.5).toStringAsFixed(1), style: Get.theme.textTheme.bodyMedium),
              ],
            ),
            Row(
              children: [
                Text("x".tr, style: Get.theme.textTheme.labelMedium),
                horizontalSpacing(defaultSpacing),
                Expanded(child: FJSlider(value: _moveX.value, min: -1, max: 1, onChanged: (val) => _moveX.value = val)),
                horizontalSpacing(defaultSpacing),
                Text(_moveX.value.toStringAsFixed(1), style: Get.theme.textTheme.bodyMedium),
              ],
            ),
            Row(
              children: [
                Text("y".tr, style: Get.theme.textTheme.labelMedium),
                horizontalSpacing(defaultSpacing),
                Expanded(child: FJSlider(value: _moveY.value, min: -1, max: 1, onChanged: (val) => _moveY.value = val)),
                horizontalSpacing(defaultSpacing),
                Text(_moveY.value.toStringAsFixed(1), style: Get.theme.textTheme.bodyMedium),
              ],
            ),
            verticalSpacing(sectionSpacing),
            FJElevatedLoadingButton(
              loading: _uploading,
              onTap: () async {
                if (_uploading.value) return;
                _uploading.value = true;

                final screenshotController = ScreenshotController();
                final scale = _scaleFactor.value * (300 / 500);

                final image = await screenshotController.captureFromWidget(
                  SizedBox(
                    width: 500,
                    height: 500,
                    child: RawImage(
                      fit: BoxFit.none,
                      scale: scale,
                      image: _image.value!,
                      alignment: Alignment(_moveX.value, _moveY.value),
                    ),
                  ),
                );
                final cutFile = XFile("cut-${widget.file.name}");
                final res = await ProfileHelper.uploadProfilePicture(cutFile, widget.file.name, bytes: image);
                if (!res) {
                  _uploading.value = false;
                  sendLog("kinda didn't work");
                  return;
                }
                _uploading.value = false;
                sendLog("uploaded");
                Get.back();
              },
              label: "select".tr,
            ),
          ],
        );
      }),
    );
  }
}
