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
