import 'dart:isolate';

import 'package:simple_edge_detection/edge_detection.dart';

class ProcessImageInput {
  ProcessImageInput(
      {required this.inputPath,
      required this.edgeDetectionResult,
      required this.sendPort});

  String inputPath;
  EdgeDetectionResult edgeDetectionResult;
  SendPort sendPort;
}
