import 'dart:io';
import 'dart:ui' as ui;
import 'package:cheap_portrait/common/compute_data.dart';
import 'package:cheap_portrait/effects/gray.dart';
import 'package:cheap_portrait/utils/image_util.dart';
import 'package:flutter/material.dart';

import '../utils/segment_seflie.dart';

Future<ui.Image?> createEffect(File file) async {
  var mask = await segSelfie(file);
  var decodedImage = await decodeImageFromList(file.readAsBytesSync());
  var byteData =
      await decodedImage.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (byteData == null) {
    return null;
  }
  var computeData =
      ComputeData(mask, byteData, decodedImage.height, decodedImage.width);
  var colorPopRawImage = await graySelfie(computeData);
  var colorPopImage = imageToImage(colorPopRawImage, decodedImage);
  return colorPopImage;
}
