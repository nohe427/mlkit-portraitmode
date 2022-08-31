import 'package:flutter/material.dart';
import 'dart:ui' as ui;

// Used to just paint images to a widget
class ImagePainter extends CustomPainter {
  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(covariant ImagePainter oldDelegate) {
    return image != oldDelegate.image;
  }

  ImagePainter(this.image);
}
