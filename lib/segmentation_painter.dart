import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';

// borrowed from the example at :
// https://github.com/bharat-biradar/Google-Ml-Kit-plugin/blob/9efc03b25ca0806c1c29b5b2f0fcdd934f7756c5/packages/google_ml_kit/example/lib/vision_detector_views/painters/segmentation_painter.dart
class SegmentationPainter extends CustomPainter {
  final SegmentationMask mask;
  final Size absoluteImageSize;
  final Color color = Colors.red;
  final InputImageRotation rotation;
  final ui.Image image;

  SegmentationPainter(
    this.mask,
    this.absoluteImageSize,
    this.rotation,
    this.image,
  );

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset.zero, Paint());
    final rect = Offset.zero & size;
    canvas.clipRect(rect);

    final width = mask.width;
    final height = mask.height;
    final confidences = mask.confidences;

    final paint = Paint()..style = PaintingStyle.fill;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int tx = transformX(x.toDouble(), size).round();
        final int ty = transformY(y.toDouble(), size).round();

        final double opacity = confidences[(y * width) + x] * 0.25;
        paint.color = color.withOpacity(opacity);
        canvas.drawCircle(Offset(tx.toDouble(), ty.toDouble()), 20, paint);
      }
    }
  }

  double transformX(double x, Size size) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
        return x * size.width / absoluteImageSize.height;
      case InputImageRotation.rotation270deg:
        return size.width - x * size.width / absoluteImageSize.height;
      default:
        return x * size.width / absoluteImageSize.width;
    }
  }

  double transformY(double y, Size size) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
      case InputImageRotation.rotation270deg:
        return y * size.height / absoluteImageSize.width;
      default:
        return y * size.height / absoluteImageSize.height;
    }
  }

  @override
  bool shouldRepaint(SegmentationPainter oldDelegate) {
    return true;
  }
}
