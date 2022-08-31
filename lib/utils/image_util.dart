import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

Future<ui.Image?> imageToImage(Uint8List byteData, ui.Image inputImage) async {
  var decodedImage = inputImage;
  ui.Image? output;
  var fixed = false;
  Completer<ui.Image> completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(byteData, decodedImage.width, decodedImage.height,
      ui.PixelFormat.rgba8888, (result) {
    debugPrint("finished image Processing");
    output = result;
    completer.complete(result);
  });
  return completer.future;
}
