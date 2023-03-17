import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sudokusolver/pages/camera_init.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.camera}) : super(key: key);
  final CameraDescription camera;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku Solver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "SF Pro Display",
        visualDensity: VisualDensity.adaptivePlatformDensity,
        //primarySwatch: Colors.blue,
        primaryColor: Colors.blue[700],
      ),
      home: CameraInit(
        camera: camera,
      ),
    );
  }
}
