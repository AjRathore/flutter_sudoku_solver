import 'package:flutter/material.dart';

// Class for Sudoku cell
class SudokuCell extends StatelessWidget {
  const SudokuCell(
      {Key? key,
      required this.row,
      required this.column,
      required this.value,
      required this.copyValue})
      : super(key: key);

  // required variables for the cell
  final int row;
  final int column;
  final String value;
  final int copyValue;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Center(
        child: Text(
          value == "0" ? "" : value,
          style: TextStyle(
              fontSize: 28,
              color: copyValue == 0
                  ? Theme.of(context).primaryColor
                  : Colors.black),
        ),
      ),
    );
  }
}
