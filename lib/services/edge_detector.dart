import 'dart:async';
import 'dart:isolate';
import 'dart:io';

import 'package:simple_edge_detection/edge_detection.dart';
import 'package:sudokusolver/services/process_image_input.dart';

import 'edge_detection_input.dart';

// class EdgeDetector that calls the native code
class EdgeDetector {
  static Future<void> startEdgeDetectionIsolate(
      EdgeDetectionInput edgeDetectionInput) async {
    EdgeDetectionResult result =
        await EdgeDetection.detectEdges(edgeDetectionInput.inputPath);
    edgeDetectionInput.sendPort.send(result);
  }

  // method processImageIsolate
  static Future<void> processImageIsolate(
      ProcessImageInput processImageInput) async {
    EdgeDetection.processImage(
        processImageInput.inputPath, processImageInput.edgeDetectionResult);
    processImageInput.sendPort.send(true);
  }

  // method detectEdges
  Future<EdgeDetectionResult> detectEdges(String filePath) async {
    final port = ReceivePort();

    _spawnIsolate<EdgeDetectionInput>(startEdgeDetectionIsolate,
        EdgeDetectionInput(inputPath: filePath, sendPort: port.sendPort), port);

    return await _subscribeToPort<EdgeDetectionResult>(port);
  }

  // method processImage
  Future<bool> processImage(
      String filePath, EdgeDetectionResult edgeDetectionResult) async {
    final port = ReceivePort();

    _spawnIsolate<ProcessImageInput>(
        processImageIsolate,
        ProcessImageInput(
            inputPath: filePath,
            edgeDetectionResult: edgeDetectionResult,
            sendPort: port.sendPort),
        port);

    return await _subscribeToPort<bool>(port);
  }

  // method _spawnIsolate
  void _spawnIsolate<T>(
      void Function(T message) function, dynamic input, ReceivePort port) {
    Isolate.spawn<T>(function, input,
        onError: port.sendPort, onExit: port.sendPort);
  }

  // method _subscribeToPort
  Future<T> _subscribeToPort<T>(ReceivePort port) async {
    late StreamSubscription sub;

    var completer = new Completer<T>();

    sub = port.listen((result) async {
      await sub.cancel();
      completer.complete(await result);
    });

    return completer.future;
  }
}
