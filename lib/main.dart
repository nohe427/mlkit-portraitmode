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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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

Future<Uint8List> graySelfie(ComputeData cd) {
  return compute<ComputeData, Uint8List>(_graySelfie, cd);
}

Uint8List _graySelfie(ComputeData cd) {
  var byteData = cd.byteData;
  var mask = cd.mask;
  var decodedImage = cd;
  var i = 0;
  debugPrint("${mask.confidences.length}");
  for (int y = 0; y < decodedImage.height; y++) {
    for (int x =0; x < decodedImage.width; x++) {
      // debugPrint("Starting $x of ${decodedImage.width} $y pf ${decodedImage.height}");
      var nY = ((y/decodedImage.height)*255).round();
      var nX = ((x/decodedImage.width)*255).round();

      // debugPrint("${mask.confidences[(nY*mask.width) + nX] > 0}");
      if (mask.confidences[(nY*mask.width) + nX] < 0.8) {
        var rO = (y*decodedImage.width*4 + x*4);
        var gO = (y*decodedImage.width*4 + x*4) + 1;
        var bO = (y*decodedImage.width*4 + x*4) + 2;
        var aO = (y*decodedImage.width*4 + x*4) + 3;

        var red = byteData.getUint8(rO); //Red
        var green = byteData.getUint8(gO); //Green
        var blue = byteData.getUint8(bO); //Blue
        var alpha = byteData.getUint8(aO); //Alpha - not used
        var avg = ((red + green + blue)/3).round();
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

  return byteData.buffer.asUint8List();
}

class ComputeData {
  SegmentationMask mask;
  ByteData byteData;
  int height;
  int width;


  ComputeData(this.mask, this.byteData, this.height, this.width);

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

  Future<ui.Image?> imageToImage(Uint8List byteData, ui.Image inputImage) async {
    var decodedImage = inputImage;
    ui.Image? output;
    var fixed = false;
    Completer<ui.Image> completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(byteData, decodedImage.width, decodedImage.height, ui.PixelFormat.rgba8888, (result) {
      debugPrint("finished image Processing");
      output = result;
      completer.complete(result);
      /**
       *
       */
    });
    return completer.future;
  }

  Future<SegmentationPainter> segmentSelfie(File file) async {
    var mask = await segSelfie(file);
    var decodedImage = await decodeImageFromList(file.readAsBytesSync());
    var bd = await decodedImage.toByteData(format: ui.ImageByteFormat.rawRgba);
    var computeData = ComputeData(mask, bd!, decodedImage.height, decodedImage.width);
    // graySelfie(computeData).then((value) => debugPrint("${value.lengthInBytes}"));

    final inputImage = InputImage.fromFile(file);
    decodedImage = await decodeImageFromList(file.readAsBytesSync());
    // debugPrint("${x} of ${decodedImage.width} ${y} pf ${decodedImage.height}");
    final size = Size(decodedImage.width.toDouble()/(decodedImage.width.toDouble()/256), decodedImage.height.toDouble()/(decodedImage.height.toDouble()/256));
    iSize = size;
    // final segmenter = SelfieSegmenter(
    //   mode: SegmenterMode.single,
    //   enableRawSizeMask: true,
    // );
    // // final mask = await segmenter.processImage(inputImage);
    var segP = SegmentationPainter(mask, size, InputImageRotation.rotation0deg, decodedImage);
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
                  value.toByteData(format: ui.ImageByteFormat.rawRgba).then((value) =>
                    // bd = value,
                    mask.then((valuea) =>
                    {
                      computeData = ComputeData(
                          valuea, value!, myDImage.height, myDImage.width),
                      graySelfie(computeData).then((grayOut) =>
                      {
                        debugPrint("${value.lengthInBytes}"),
                        dImage.then((dvalue) => {
                          imageToImage(grayOut, dvalue).then((imageV) =>
                          {
                          debugPrint("complete ${imageV?.width}"),

                            //TOOD fix this
                            segPainFuture.then((value) => {
                              setState(() {
                                file = File(pathA);
                                segPain = ImagePainter(imageV!); //value
                                dValue = dvalue;
                              })
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

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
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
            const Text(
              'You have pushed the button this many times:',
            ),
            file != null ? Image(image: FileImage(file!), height: 40, width: 30,) : Container(),
            dValue != null ? FittedBox(
              child:SizedBox(
                  width: dValue!.width.toDouble(),
                  height: dValue!.height.toDouble(),
                  child:
                    segPain != null ? CustomPaint
                      (painter: segPain,
                      willChange: true,
                      /*child: file != null ? Image(image: FileImage(file!),) : Container(),*/
                    ) : Container()
              ),
            ) : Container(),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickFile,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
