import 'dart:typed_data';

import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';

class ComputeData {
  SegmentationMask mask;
  ByteData byteData;
  int height;
  int width;

  ComputeData(this.mask, this.byteData, this.height, this.width);
}
