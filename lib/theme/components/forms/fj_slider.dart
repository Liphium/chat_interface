import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class FJSlider extends StatelessWidget {
  final double? secondaryTrackValue;
  final double value;
  final double min, max;
  final String? label;

  final Function(double)? onChanged;
  final Function(double)? onChangeEnd;

  const FJSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.secondaryTrackValue,
    this.onChangeEnd,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: const SliderThemeData(
        trackShape: CustomSliderTrackShape(),
        thumbShape: CustomSliderThumbShape(),
        overlayShape: CustomSliderOverlayShape(),
        trackHeight: 6,
      ),
      child: Row(
        children: [
          Expanded(
            child: Slider(
              value: value,
              inactiveColor: Get.theme.colorScheme.primary,
              thumbColor: Get.theme.colorScheme.onPrimary,
              activeColor: Get.theme.colorScheme.onPrimary,
              min: min,
              max: max,
              secondaryActiveColor: Get.theme.colorScheme.secondary,
              secondaryTrackValue: secondaryTrackValue?.clamp(min, max),
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
            ),
          ),
          label != null
              ? Padding(
                  padding: const EdgeInsets.only(left: defaultSpacing),
                  child: Text(label!),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}

class FJSliderWithInput extends StatefulWidget {
  final double value;
  final double min, max;
  final String? label;
  final Function(double)? transformer;
  final Function(double)? reverseTransformer;

  final Function(double)? onChanged;
  final Function(double)? onChangeEnd;

  const FJSliderWithInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.onChangeEnd,
    this.label,
    this.transformer,
    this.reverseTransformer,
  });

  @override
  State<FJSliderWithInput> createState() => _FJSliderWithInputState();
}

class _FJSliderWithInputState extends State<FJSliderWithInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.value = TextEditingValue(text: (widget.transformer?.call(widget.value) ?? widget.value).toStringAsFixed(0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: const SliderThemeData(
        trackShape: CustomSliderTrackShape(),
        thumbShape: CustomSliderThumbShape(),
        overlayShape: CustomSliderOverlayShape(),
        trackHeight: 6,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Slider(
              value: widget.value,
              inactiveColor: Get.theme.colorScheme.primary,
              thumbColor: Get.theme.colorScheme.onPrimary,
              activeColor: Get.theme.colorScheme.onPrimary,
              min: widget.min,
              max: widget.max,
              onChanged: (value) {
                widget.onChanged!(value);
                _controller.value = TextEditingValue(text: (widget.transformer?.call(value) ?? value).toStringAsFixed(0));
              },
              onChangeEnd: widget.onChangeEnd,
            ),
          ),
          horizontalSpacing(defaultSpacing),
          Expanded(
            flex: 1,
            child: FJTextField(
              animation: false,
              hintText: widget.label,
              controller: _controller,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChange: (value) {
                if (value.isEmpty) {
                  return;
                }
                final newValue = double.parse(value);
                var finalValue = widget.reverseTransformer?.call(newValue) ?? newValue;
                finalValue = clampDouble(finalValue, widget.min, widget.max);
                widget.onChanged!(finalValue);
              },
            ),
          )
        ],
      ),
    );
  }
}

class CustomSliderTrackShape extends RoundedRectSliderTrackShape {
  const CustomSliderTrackShape();
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight!) / 2;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

class CustomSliderThumbShape extends RoundSliderThumbShape {
  const CustomSliderThumbShape({super.enabledThumbRadius = 10.0});

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    super.paint(context, center.translate(-(value - 0.5) / 0.5 * enabledThumbRadius, 0.0),
        activationAnimation: activationAnimation,
        enableAnimation: enableAnimation,
        isDiscrete: isDiscrete,
        labelPainter: labelPainter,
        parentBox: parentBox,
        sliderTheme: sliderTheme,
        textDirection: textDirection,
        value: value,
        textScaleFactor: textScaleFactor,
        sizeWithOverflow: sizeWithOverflow);
  }
}

class CustomSliderOverlayShape extends RoundSliderOverlayShape {
  final double thumbRadius;
  const CustomSliderOverlayShape({this.thumbRadius = 10.0});

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    super.paint(context, center.translate(-(value - 0.5) / 0.5 * thumbRadius, 0.0),
        activationAnimation: activationAnimation,
        enableAnimation: enableAnimation,
        isDiscrete: isDiscrete,
        labelPainter: labelPainter,
        parentBox: parentBox,
        sliderTheme: sliderTheme,
        textDirection: textDirection,
        value: value,
        textScaleFactor: textScaleFactor,
        sizeWithOverflow: sizeWithOverflow);
  }
}
