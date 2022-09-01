// Copyright 2022 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cheap_portrait/segmentation_painter.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';

import '../common/compute_data.dart';

Future<SegmentationMask> segSelfie(File file) async {
  final inputImage = InputImage.fromFile(file);
  var decodedImage = await decodeImageFromList(file.readAsBytesSync());
  final segmenter = SelfieSegmenter(
    mode: SegmenterMode.single,
    enableRawSizeMask: true,
  );
  final mask = await segmenter.processImage(inputImage);
  segmenter.close();
  return mask!;
}

// avoid this one. Used for testing early on.
Future<SegmentationPainter> segmentSelfieDontUsePlease(File file) async {
  var mask = await segSelfie(file);
  var decodedImage = await decodeImageFromList(file.readAsBytesSync());
  var bd = await decodedImage.toByteData(format: ui.ImageByteFormat.rawRgba);
  var computeData =
      ComputeData(mask, bd!, decodedImage.height, decodedImage.width);
  // graySelfie(computeData).then((value) => debugPrint("${value.lengthInBytes}"));

  final inputImage = InputImage.fromFile(file);
  decodedImage = await decodeImageFromList(file.readAsBytesSync());
  // debugPrint("${x} of ${decodedImage.width} ${y} pf ${decodedImage.height}");
  final size = Size(
      decodedImage.width.toDouble() / (decodedImage.width.toDouble() / 256),
      decodedImage.height.toDouble() / (decodedImage.height.toDouble() / 256));
  // final segmenter = SelfieSegmenter(
  //   mode: SegmenterMode.single,
  //   enableRawSizeMask: true,
  // );
  // // final mask = await segmenter.processImage(inputImage);
  var segP = SegmentationPainter(
      mask, size, InputImageRotation.rotation0deg, decodedImage);
  //segmenter.close();
  return segP;
}
