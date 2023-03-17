// ignore_for_file: unnecessary_new

import 'dart:developer';
import 'dart:ffi';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_edge_detection/edge_detection.dart';
import 'package:sudokusolver/pages/sudoku_screen.dart';
import 'package:sudokusolver/services/edge_detector.dart';

class CameraInit extends StatefulWidget {
  const CameraInit({Key? key, required this.camera}) : super(key: key);

  final CameraDescription camera;

  @override
  _CameraInitState createState() => _CameraInitState();
}

class _CameraInitState extends State<CameraInit> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late EdgeDetectionResult edgeDetectionResult;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);

    _initializeControllerFuture = _controller.initialize();
  }

  // Method detect edges
  Future detectEdges(String filePath) async {
    EdgeDetectionResult result = await EdgeDetector().detectEdges(filePath);
    edgeDetectionResult = result;
  }

  // Method process image
  Future processImage(
      String filePath, EdgeDetectionResult edgeDetectionResult) async {
    if (!mounted) {
      log("not mounted");
      return;
    }

    bool result =
        await EdgeDetector().processImage(filePath, edgeDetectionResult);

    if (result == false) {}
  }

  // method for taking picture from Camera
  void takePicture() async {
    try {
      // ensure that camera is initialized
      await _initializeControllerFuture;
      _controller.setFlashMode(FlashMode.off);
      final image = await _controller.takePicture();

      await detectEdges(image.path);
      await processImage(image.path, edgeDetectionResult);
      await Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => SudokuScreen(
            // Pass the automatically generated path to
            // the DisplayPictureScreen widget.
            imagePath: image.path,
          ),
        ),
      );
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Capture Sudoku"),
        backgroundColor: Colors.black,
      ),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10.0, 0, 0),
        child: Column(
          children: [
            FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            const SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () async {
                  HapticFeedback.mediumImpact();
                  takePicture();
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: const [
                    Icon(Icons.circle, color: Colors.white38, size: 100),
                    Icon(Icons.circle, color: Colors.white, size: 75),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
