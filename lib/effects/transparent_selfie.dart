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

import 'dart:typed_data';

import 'package:cheap_portrait/common/compute_data.dart';
import 'package:flutter/foundation.dart';

Future<Uint8List> transparentSelfie(ComputeData cd) {
  return compute<ComputeData, Uint8List>(_transparentSelfie, cd);
}

Uint8List _transparentSelfie(ComputeData cd) {
  var byteData = cd.byteData;
  var mask = cd.mask;
  var decodedImage = cd;
  var i = 0;
  debugPrint("${mask.confidences.length}");
  for (int y = 0; y < decodedImage.height; y++) {
    for (int x = 0; x < decodedImage.width; x++) {
      var nY = ((y / decodedImage.height) * 255).round();
      var nX = ((x / decodedImage.width) * 255).round();

      var newAlpha = ((mask.confidences[(nY * mask.width) + nX]) * 255).round();
      var aO = (y * decodedImage.width * 4 + x * 4) + 3;

      // var alpha = byteData.getUint8(aO); //Alpha - not used

      byteData.setUint8(aO, newAlpha);

      i++;
      // debugPrint("$x of ${decodedImage.width} $y pf ${decodedImage.height} i : $i");
    }
    debugPrint("Exiting X Loop $y");
  }
  debugPrint("Finished.");

  return byteData.buffer.asUint8List();
}
