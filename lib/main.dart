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
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cheap_portrait/ImagePainter.dart';
import 'package:cheap_portrait/segmentation_painter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';

import 'common/compute_data.dart';
import 'effects/gray.dart';
import 'utils/image_util.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Cheap portrait maker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  File? file;
  CustomPainter? segPain;
  ui.Image? dValue;
  Size iSize = Size.zero;

  Future<SegmentationMask> segSelfie(File file) async {
    final inputImage = InputImage.fromFile(file);
    var decodedImage = await decodeImageFromList(file.readAsBytesSync());
    final segmenter = SelfieSegmenter(
      mode: SegmenterMode.single,
      enableRawSizeMask: true,
    );
    final mask = await segmenter.processImage(inputImage);
    return mask!;
  }

  Future<SegmentationPainter> segmentSelfie(File file) async {
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
        decodedImage.height.toDouble() /
            (decodedImage.height.toDouble() / 256));
    iSize = size;
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
//TODO fix later
  // Future<ImagePainter> imagePainter(File file) async {
  //   final image = await decodeImageFromList(file.readAsBytesSync());
  //
  // }

  void _pickFile() {
    var result = FilePicker.platform.pickFiles(
      dialogTitle: "Find your file",
      type: FileType.image,
    );
    Future<SegmentationPainter> segPainFuture;
    Future<ui.Image> dImage;
    String pathA;
    Future<SegmentationMask> mask;
    Future<ui.Image> decodedImage;
    ui.Image myDImage;
    ByteData? bd;
    ComputeData computeData;
    result.then(
      (value) => {
        if (value == null)
          {}
        else
          {
            if (value.files.isNotEmpty)
              {
                file = File(value.files.first.path!),
                pathA = value.files.first.path!,
                segPainFuture = segmentSelfie(file!),
                dImage = decodeImageFromList(file!.readAsBytesSync()),
                mask = segSelfie(file!),
                decodedImage = decodeImageFromList(file!.readAsBytesSync()),
                decodedImage.then((value) => {
                      myDImage = value,
                      value.toByteData(format: ui.ImageByteFormat.rawRgba).then(
                            (value) =>
                                // bd = value,
                                mask.then((valuea) => {
                                      computeData = ComputeData(valuea, value!,
                                          myDImage.height, myDImage.width),
                                      graySelfie(computeData).then((grayOut) =>
                                          {
                                            debugPrint(
                                                "${value.lengthInBytes}"),
                                            dImage.then((dvalue) => {
                                                  imageToImage(grayOut, dvalue)
                                                      .then((imageV) => {
                                                            debugPrint(
                                                                "complete ${imageV?.width}"),
                                                            setState(() {
                                                              file =
                                                                  File(pathA);
                                                              segPain =
                                                                  ImagePainter(
                                                                      imageV!); //value
                                                              dValue = dvalue;
                                                            })
                                                          })
                                                }),
                                          })
                                    }),
                          )
                    }),
              }
          }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            file != null
                ? Image(
                    image: FileImage(file!),
                    height: 40,
                    width: 30,
                  )
                : Container(),
            dValue != null
                ? FittedBox(
                    child: SizedBox(
                        width: dValue!.width.toDouble(),
                        height: dValue!.height.toDouble(),
                        child: segPain != null
                            ? CustomPaint(
                                painter: segPain,
                                willChange: true,
                                /*child: file != null ? Image(image: FileImage(file!),) : Container(),*/
                              )
                            : Container()),
                  )
                : Container(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickFile,
        tooltip: 'Pick file to gray background',
        child: const Icon(Icons.file_open_outlined),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
