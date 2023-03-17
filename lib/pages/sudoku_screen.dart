import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as image_package;
import 'package:sudokusolver/widgets/sudoku_board.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer';

// Stateful class for Sudoku screen
class SudokuScreen extends StatefulWidget {
  final String imagePath;

  const SudokuScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  // row
  int rowMainGrid = 9;
  // column
  int colMainGrid = 9;
  // flag for grid loaded
  bool boGridLoaded = false;
  // check if the elements are 0
  bool boListEmpty = true;
  // is loading
  bool boIsLoading = true;

  // Google ML Vision TextDetector
  late final TextDetector _textDetector;

  // multi dimensional list for sudoku
  late List<List<int>> sudoku = List.generate(
      rowMainGrid, (i) => List.generate(colMainGrid, (index) => 0));

  // multi dimensional list for sudoku copy
  late List<List<int>> sudokuCopy = List.generate(
      rowMainGrid, (i) => List.generate(colMainGrid, (index) => 0));

  @override
  void initState() {
    // initialize TextDetector
    _textDetector = GoogleMlKit.vision.textDetector();
    // call crop image method
    cropImage();
    super.initState();
  }

  // async method for calling solve sudoku
  void callSolveSudoku() async {
    var call = await solvesudoku(sudoku);

    // set state to update the UI
    setState(() {});
  }

  // crop image method
  void cropImage() async {
    for (var i = 0; i < rowMainGrid; i++) {
      for (var j = 0; j < colMainGrid; j++) {
        String path = await getCropImage(widget.imagePath, j, i);
        sudoku[i][j] = await recognizeText(path);
        sudokuCopy[i][j] = sudoku[i][j];
      }
    }

    setState(() {
      //boGridLoaded = true;
      boListEmpty =
          sudoku.every((element) => element.every((element) => element == 0));
      boIsLoading = false;
      if (!boListEmpty) {
        boGridLoaded = true;
      }
    });
  }

  // Future method to get crop image
  Future<String> getCropImage(String imagePath, int row, int column) async {
    File? croppedImageFile;
    // decode image
    image_package.Image image =
        image_package.decodeJpg(File(imagePath).readAsBytesSync());

    // get directory
    final Directory directory = await getApplicationDocumentsDirectory();
    // get path
    final String path = directory.path;

    // copy crop image
    image_package.Image destImage =
        image_package.copyCrop(image, 50 * row, 50 * column, 50, 50);

    // convert copycrop to a file
    croppedImageFile = await File('$path/thumbnail.png')
        .writeAsBytes(image_package.encodePng(destImage));

    // return cropped image path
    return croppedImageFile.path;
  }

  // async method to recognize text
  Future<int> recognizeText(String sImagePath) async {
    int iRecognizedText = 0;
    try {
      final inputImage = InputImage.fromFilePath(sImagePath);
      // Retrieving the RecognisedText from the InputImage
      final text = await _textDetector.processImage(inputImage);

      // example code block from internet
      for (TextBlock block in text.blocks) {
        if (text.blocks.isEmpty) {
          iRecognizedText = 0;
        } else {
          final Rect rect = block.rect;
          final List<Offset> cornerPoints = block.cornerPoints;
          final String text = block.text;
          final List<String> languages = block.recognizedLanguages;

          for (TextLine line in block.lines) {
            // Same getters as TextBlock
            for (TextElement element in line.elements) {
              iRecognizedText = int.parse(element.text);
              if (iRecognizedText > 9) {
                iRecognizedText = 0;
              }
            }
          }
        }
      }
    } catch (e) {
      iRecognizedText = 0;
      log(e.toString());
    }

    // return recognized text
    return iRecognizedText;
  }

  // method to find empty location
  bool findEmptyLocation(List<List<int>> sudokuGrid, List list) {
    bool boEmptyLocation = false;
    try {
      for (var i = 0; i < rowMainGrid; i++) {
        for (var j = 0; j < colMainGrid; j++) {
          if (sudokuGrid[i][j] == 0) {
            list[0] = i;
            list[1] = j;
            boEmptyLocation = true;
          }
        }
      }
    } catch (e) {
      log("Error in find Empty location");
    }

    return boEmptyLocation;
  }

  // method to check if the number is used in a row
  bool usedInARow(List<List<int>> sudokuGrid, int row, int num) {
    bool boUsedInARow = false;
    try {
      for (var i = 0; i < 9; i++) {
        if (sudokuGrid[row][i] == num) {
          boUsedInARow = true;
        }
      }
    } catch (e) {
      log("Error in used in a row");
    }

    return boUsedInARow;
  }

  // method to check if the number is used in a column
  bool usedInAColumn(List<List<int>> sudokuGrid, int col, int num) {
    bool boUsedInAColumn = false;
    for (var i = 0; i < 9; i++) {
      if (sudokuGrid[i][col] == num) {
        boUsedInAColumn = true;
      }
    }
    return boUsedInAColumn;
  }

  // method to check if the number is used in a box
  bool usedInABox(List<List<int>> sudokuGrid, int row, int col, int num) {
    bool boUsedInABox = false;
    try {
      for (var i = 0; i < 3; i++) {
        for (var j = 0; j < 3; j++) {
          if (sudoku[i + row][j + col] == num) {
            boUsedInABox = true;
          }
        }
      }
    } catch (e) {
      log("error in used in a box");
    }

    return boUsedInABox;
  }

  // method to check if the location is safe
  bool checkLocationIsSafe(
      List<List<int>> sudokuGrid, int row, int col, int num) {
    bool boSafeLocation = false;

    boSafeLocation = !(usedInARow(sudokuGrid, row, num)) &&
        !(usedInAColumn(sudokuGrid, col, num)) &&
        !(usedInABox(
            sudokuGrid, ((row / 3).floor()) * 3, ((col / 3).floor()) * 3, num));

    return boSafeLocation;
  }

  // method call sudoku
  bool solvesudoku(List<List<int>> sudokuGrid) {
    // it is a list variable that keeps the record of row and col in _findEmptyLocation Function
    var arrRowColumn = [0, 0];

    try {
      if (!(findEmptyLocation(sudokuGrid, arrRowColumn))) {
        // If there is no unassigned location, we are done
        return true;
      }

      // Assigning list values to row and col that we got from the above Function
      var row = arrRowColumn[0];
      var col = arrRowColumn[1];

      for (var num = 1; num < 10; num++) {
        if (checkLocationIsSafe(sudokuGrid, row, col, num)) {
          // # make tentative assignment
          sudokuGrid[row][col] = num;

          if (solvesudoku(sudokuGrid)) {
            // return if success
            return true;
          }

          // we made a wrong decision, try again
          sudokuGrid[row][col] = 0;
        }
      }
    } catch (e) {
      log(e.toString());
    }

    // this triggers backtracking
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        title: const Text(
          "Sudoku Board",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
      ),
      body: boIsLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : Container(
              child: boListEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Sorry! The image identified is not a Sudoku puzzle!\n\nPlease try again",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SudokuBoard(
                            sudoku: sudoku,
                            sudokuCopy: sudokuCopy,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(80.0),
                          child: CupertinoButton(
                            color: Theme.of(context).primaryColor,
                            onPressed: !boGridLoaded
                                ? null
                                : () async {
                                    callSolveSudoku();
                                  },
                            child: const Text("Solve Sudoku"),
                          ),
                        ),
                      ],
                    ),
            ),
    );
  }
}
