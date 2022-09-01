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
