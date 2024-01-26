import 'package:flutter/material.dart';
import 'package:tetris/game_board.dart';
import 'package:tetris/values.dart';

class Piece {
  TetriMino type;
  List<int> position = [];

  Piece({required this.type});

  Color get color {
    return TetriMinoColors.colorMap[type] ?? TetriMinoColors.getRandomColor();
  }

  // ignore: empty_constructor_bodies
  void initPosition() {
    switch (type) {
      case TetriMino.L:
        position = [-26, -16, -6, -5];
        break;
      case TetriMino.J:
        position = [-25, -15, -5, -6];
        break;
      case TetriMino.I:
        position = [3 - 20, 4 - 20, 5 - 20, 6 - 20];
        break;
      case TetriMino.O:
        position = [-16, -15, -5, -6];
        break;
      case TetriMino.S:
        position = [4 - 20, 5 - 20, 13 - 20, 14 - 20];
        break;
      case TetriMino.Z:
        position = [3 - 20, 4 - 20, 14 - 20, 15 - 20];
        break;
      case TetriMino.T:
        position = [4 - 30, 14 - 30, 15 - 30, 24 - 30];
        break;
      default:
    }
  }

  void movePiece(Direction direction) {
    switch (direction) {
      case Direction.down:
        for (var i = 0; i < position.length; i++) {
          position[i] += numCols;
        }
        break;
      case Direction.left:
        for (var i = 0; i < position.length; i++) {
          position[i] -= 1;
        }
        break;
      case Direction.right:
        for (var i = 0; i < position.length; i++) {
          position[i] += 1;
        }
        break;
      default:
    }
  }

  /// Logic for rotating piece
  /// Translate points to origin  [ newX = x - xOrigin newY = y - yOrigin ]
  /// Rotate on origin  [ new_rotated_matrix  = rotation_matrix * position_matrix ]
  /// Translate back to original value  [calc = translatedX * numCols + translatedY ]

  /// Articles for ref-
  /// https://stackoverflow.com/questions/233850/tetris-piece-rotation-algorithm
  /// https://stackoverflow.com/questions/16196039/java-tetris-rotations-using-rotation-matrices?rq=3

  void rotatePiece() {
    List<int> newPositions = [];
    int xOrigin = position[1] ~/ numCols;
    int yOrigin = position[1] % numCols;
    debugPrint('Position $position');
    debugPrint('Xorigin $xOrigin YOrigin : $yOrigin');
    List<List<int>> matrix = [
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ];
    debugPrint("------ START ----------");
    for (int i = 0; i < position.length; i++) {
      int x = position[i] ~/ numCols;
      int y = position[i] % numCols;

      int newX = x - xOrigin;
      int newY = y - yOrigin;
      debugPrint("------ POINTS ----------");
      debugPrint('curr_x :  $x curr_y   : $y');
      debugPrint('newX   :  $newX newY : $newY');

      matrix[0][i] = newX;
      matrix[1][i] = newY;
    }

    debugPrint('--- Matrix ----');
    debugPrint(matrix as String?);
    debugPrint('--end');

    List<List<int>> matrixB = [
      [0, 1],
      [-1, 0],
    ];
    debugPrint('');
    debugPrint('');
    List<List<int>> result = multiplyMatrices(matrixB, matrix);
    debugPrint("---- Result matrix ------");
    debugPrint(result as String?);
    debugPrint('---- END ------');
    for (int i = 0; i < result[0].length; i++) {
      int translatedX = result[0][i] + xOrigin;
      int translatedY = result[1][i] + yOrigin;
      int calc = translatedX * numCols + translatedY;
      debugPrint(
          'translatedX : $translatedX  translatedY: $translatedY  sol: $calc');
      newPositions.add(calc);
    }
    debugPrint(newPositions as String?);
    if (piecePositionIsValid(newPositions)) {
      position = newPositions;
    }
  }

  List<List<int>> multiplyMatrices(List<List<int>> a, List<List<int>> b) {
    int numRowsA = a.length;
    int numColsA = a[0].length;
    int numRowsB = b.length;
    int numColsB = b[0].length;

    if (numColsA != numRowsB) {
      throw ArgumentError("Matrix dimensions do not match for multiplication.");
    }

    List<List<int>> result =
        List.generate(numRowsA, (i) => List<int>.filled(numColsB, 0));

    for (int i = 0; i < numRowsA; i++) {
      for (int j = 0; j < numColsB; j++) {
        for (int k = 0; k < numColsA; k++) {
          result[i][j] += a[i][k] * b[k][j];
        }
      }
    }

    return result;
  }

  bool isValidPosition(int position) {
    int x = position ~/ numCols;
    int y = position % numCols;

    if (position < 0 || x < 0 || y < 0 || gameBoard[x][y] != null) {
      return false;
    }

    return true;
  }

  bool piecePositionIsValid(List<int> position) {
    bool isInFirstColumn = false;
    bool isInLastColumn = false;
    for (int i = 0; i < position.length; i++) {
      if (!isValidPosition(position[i])) {
        return false;
      }

      int col = position[i] % numCols;
      if (col == 0) {
        isInFirstColumn = true;
      } else if (col == numCols - 1) {
        isInLastColumn = true;
      }
    }
    return !(isInFirstColumn && isInLastColumn);
  }
}
