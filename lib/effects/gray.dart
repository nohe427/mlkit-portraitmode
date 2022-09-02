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
import 'dart:isolate';
import 'dart:typed_data';

import 'package:cheap_portrait/common/compute_data.dart';
import 'package:flutter/foundation.dart';

class Effect {}

class GraySelfie {
  factory GraySelfie() {
    return _graySelfieInstance;
  }

  static final GraySelfie _graySelfieInstance = GraySelfie._internal();

  GraySelfie._internal();

  Isolate? _imageIsolate;

  Future<Uint8List> graySelfie(ComputeData cd) async {
    Completer<Uint8List> completer = Completer<Uint8List>();
    ReceivePort rp = ReceivePort();
    if (_imageIsolate != null) {
      _imageIsolate!.kill(priority: Isolate.immediate);
    }
    cd.recieverSendPort = rp.sendPort;
    _imageIsolate = await Isolate.spawn(_graySelfie, cd);

    rp.listen((message) {
      completer.complete(message);
    });

    return completer.future;
    // return compute<ComputeData, Uint8List>(_graySelfie, cd);
  }

  void _graySelfie(ComputeData cd) {
    var byteData = cd.byteData;
    var mask = cd.mask;
    var decodedImage = cd;
    var i = 0;
    debugPrint("${mask.confidences.length}");
    for (int y = 0; y < decodedImage.height; y++) {
      for (int x = 0; x < decodedImage.width; x++) {
        // debugPrint("Starting $x of ${decodedImage.width} $y pf ${decodedImage.height}");
        var nY = ((y / decodedImage.height) * 255).round();
        var nX = ((x / decodedImage.width) * 255).round();

        // debugPrint("${mask.confidences[(nY*mask.width) + nX] > 0}");
        // gray any pixel without a confidence of 80% or higher
        cd.confidence_limit ??= .8;
        if (mask.confidences[(nY * mask.width) + nX] < cd.confidence_limit!) {
          var rO = (y * decodedImage.width * 4 + x * 4);
          var gO = (y * decodedImage.width * 4 + x * 4) + 1;
          var bO = (y * decodedImage.width * 4 + x * 4) + 2;
          var aO = (y * decodedImage.width * 4 + x * 4) + 3;

          var red = byteData.getUint8(rO); //Red
          var green = byteData.getUint8(gO); //Green
          var blue = byteData.getUint8(bO); //Blue
          var alpha = byteData.getUint8(aO); //Alpha - not used
          var avg = ((red + green + blue) / 3).round();

          // debugPrint("red $red\ngreen $green\nblue $blue\nalpha $alpha\navg $avg");
          byteData.setUint8(rO, avg);
          byteData.setUint8(gO, avg);
          byteData.setUint8(bO, avg);
        }
        i++;
        // debugPrint("$x of ${decodedImage.width} $y pf ${decodedImage.height} i : $i");
      }
      debugPrint("Exiting X Loop $y");
    }
    debugPrint("Finished.");

    var sendPort = cd.recieverSendPort;
    if (sendPort != null) {
      debugPrint("Send port not null");
      sendPort.send(byteData.buffer.asUint8List());
    } else {
      debugPrint("Send port null");
    }
  }
}
