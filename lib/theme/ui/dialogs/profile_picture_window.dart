import 'dart:ui' as ui;

import 'package:chat_interface/controller/account/profile_picture_helper.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/components/fj_slider.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePictureWindow extends StatefulWidget {
  final XFile file;

  const ProfilePictureWindow({super.key, required this.file});

  @override
  State<ProfilePictureWindow> createState() => _ProfilePictureWindowState();
}

class _ProfilePictureWindowState extends State<ProfilePictureWindow> {
  double maxScale = 0;
  final scaleFactor = (1 / 0.15625).obs;
  final moveX = 0.0.obs;
  final moveY = 0.0.obs;

  final uploading = false.obs;
  final _image = Rx<ui.Image?>(null);

  @override
  void initState() {
    super.initState();
    initImage();
  }

  void initImage() async {
    final image = await ProfilePictureHelper.loadImage(widget.file.path);
    if (image == null) return;

    // Calculate the scale factor to fit the image into the window
    if (image.width < image.height) {
      scaleFactor.value = 1 / (300 / image.width);
      maxScale = scaleFactor.value;
    } else {
      scaleFactor.value = 1 / (300 / image.height);
      maxScale = scaleFactor.value;
    }

    _image.value = image;
  }

  @override
  Widget build(BuildContext context) {
    return DialogBase(
        maxWidth: 450,
        child: Obx(() {
          if (_image.value == null) {
            return SizedBox(
                height: 100,
                width: 100,
                child: Center(
                    child: CircularProgressIndicator(
                        color: Get.theme.colorScheme.onPrimary)));
          }

          final scale = scaleFactor.value;
          final offset = Offset(moveX.value, moveY.value);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("settings.data.profile_picture.select".tr,
                  style: Get.theme.textTheme.bodyMedium),
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
                      value: (maxScale - scaleFactor.value) + 0.5,
                      min: 0.5,
                      max: maxScale,
                      onChanged: (val) {
                        scaleFactor.value = (maxScale - val) + 0.5;
                      },
                    ),
                  ),
                  horizontalSpacing(defaultSpacing),
                  Text(
                      ((maxScale - scaleFactor.value) + 0.5).toStringAsFixed(1),
                      style: Get.theme.textTheme.bodyMedium),
                ],
              ),
              Row(
                children: [
                  Text("x".tr, style: Get.theme.textTheme.labelMedium),
                  horizontalSpacing(defaultSpacing),
                  Expanded(
                    child: FJSlider(
                      value: moveX.value,
                      min: -1,
                      max: 1,
                      onChanged: (val) => moveX.value = val,
                    ),
                  ),
                  horizontalSpacing(defaultSpacing),
                  Text(moveX.value.toStringAsFixed(1),
                      style: Get.theme.textTheme.bodyMedium),
                ],
              ),
              Row(
                children: [
                  Text("y".tr, style: Get.theme.textTheme.labelMedium),
                  horizontalSpacing(defaultSpacing),
                  Expanded(
                    child: FJSlider(
                      value: moveY.value,
                      min: -1,
                      max: 1,
                      onChanged: (val) => moveY.value = val,
                    ),
                  ),
                  horizontalSpacing(defaultSpacing),
                  Text(moveY.value.toStringAsFixed(1),
                      style: Get.theme.textTheme.bodyMedium),
                ],
              ),
              verticalSpacing(sectionSpacing),
              FJElevatedLoadingButton(
                loading: uploading,
                onTap: () async {
                  if (uploading.value) return;
                  uploading.value = true;
                  await ProfilePictureHelper.uploadProfilePicture(
                      widget.file,
                      ProfilePictureData(
                          scaleFactor.value, moveX.value, moveY.value));
                  uploading.value = false;
                  Get.back();
                },
                label: "select".tr,
              ),
            ],
          );
        }));
  }
}
