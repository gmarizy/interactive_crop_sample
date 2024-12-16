import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';

class InteractiveCrop extends StatelessWidget {
  final Uint8List image;
  final double aspectRatio;
  final CropController controller;
  final ValueChanged<Uint8List> onCropped;
  final ValueChanged<CropStatus>? onStatusChanged;

  const InteractiveCrop({
    super.key,
    required this.image,
    this.aspectRatio = 1,
    required this.controller,
    required this.onCropped,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final cropZone = _getCropZone(constraints.biggest);
          final roundedCropZone = RRect.fromRectAndRadius(
            cropZone,
            Radius.circular(12),
          );

          return Stack(
            children: [
              Crop(
                initialRectBuilder: (viewportRect, imageRect) => cropZone,
                cornerDotBuilder: (_, __) => const SizedBox.shrink(),
                interactive: true,
                fixCropRect: true,
                maskColor: Colors.transparent,
                baseColor: Theme.of(context).scaffoldBackgroundColor,
                controller: controller,
                image: image,
                onCropped: onCropped,
                onStatusChanged: onStatusChanged,
              ),
              IgnorePointer(child: _RevealOverlay(roundedCropZone)),
              IgnorePointer(
                child: Container(
                  margin:
                      EdgeInsets.only(left: cropZone.left, top: cropZone.top),
                  width: cropZone.width,
                  height: cropZone.height,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              )
            ],
          );
        },
      );

  Rect _getCropZone(Size size) {
    final rect = Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height,
    );

    final maxWidth = rect.width * 2 / 3;
    final maxHeight = rect.height * 2 / 3;

    if (maxWidth / aspectRatio < maxHeight) {
      return Rect.fromCenter(
        center: rect.center,
        width: maxWidth,
        height: maxWidth / aspectRatio,
      );
    } else {
      return Rect.fromCenter(
        center: rect.center,
        width: maxHeight * aspectRatio,
        height: maxHeight,
      );
    }
  }
}

class _RevealOverlay extends StatelessWidget {
  final RRect _revealed;

  const _RevealOverlay(this._revealed);

  @override
  Widget build(BuildContext context) => ClipPath(
        clipper: _RevealClipper(_revealed),
        child: Container(
          color: Colors.white.withOpacity(0.6),
        ),
      );
}

class _RevealClipper extends CustomClipper<Path> {
  const _RevealClipper(this._revealed);

  final RRect _revealed;

  @override
  Path getClip(Size size) => Path()
    ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
    ..addRRect(_revealed)
    ..fillType = PathFillType.evenOdd;

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
