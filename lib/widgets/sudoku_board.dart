import 'package:flutter/material.dart';
import 'package:sudokusolver/widgets/sudoku_cell.dart';

// Class for Sudoku board
class SudokuBoard extends StatelessWidget {
  const SudokuBoard({Key? key, required this.sudoku, required this.sudokuCopy})
      : super(key: key);

  final List<List<int>> sudoku;
  final List<List<int>> sudokuCopy;

  @override
  Widget build(BuildContext context) {
    return Table(
      border: const TableBorder(
        left: BorderSide(width: 3.0, color: Colors.black),
        top: BorderSide(width: 3.0, color: Colors.black),
      ),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: _getTableRows(),
    );
  }

  // method that returns List<TableRow>
  List<TableRow> _getTableRows() {
    return List.generate(9, (int rowNumber) {
      return TableRow(children: _getRow(rowNumber));
    });
  }

  // method that returns the list of widget
  List<Widget> _getRow(int rowNumber) {
    return List.generate(9, (int colNumber) {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              width: (colNumber % 3 == 2) ? 3.0 : 1.0,
              color: Colors.black,
            ),
            bottom: BorderSide(
              width: (rowNumber % 3 == 2) ? 3.0 : 1.0,
              color: Colors.black,
            ),
          ),
        ),
        child: SudokuCell(
          row: rowNumber,
          column: colNumber,
          value: sudoku[rowNumber][colNumber].toString(),
          copyValue: sudokuCopy[rowNumber][colNumber],
        ),
      );
    });
  }
}
