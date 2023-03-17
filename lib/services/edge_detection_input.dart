import 'dart:isolate';

// class EdgeDetectionInput
class EdgeDetectionInput {
  EdgeDetectionInput({required this.inputPath, required this.sendPort});

  String inputPath;
  SendPort sendPort;
}
