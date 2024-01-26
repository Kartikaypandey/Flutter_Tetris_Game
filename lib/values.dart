import 'dart:math';

import 'package:flutter/material.dart';

enum TetriMino { L, J, I, O, S, Z, T }

enum Direction { left, right, down }

int numRows = 15;
int numCols = 10;

class TetriMinoColors {
  static Map<TetriMino, Color> colorMap = {
    TetriMino.L: Colors.green,
    TetriMino.J: Colors.orange,
    TetriMino.I: Colors.blue,
    TetriMino.O: Colors.yellow,
    TetriMino.S: Colors.red,
    TetriMino.Z: Colors.purple,
    TetriMino.T: Colors.cyan,
  };

  static Color getRandomColor() {
    Random random = Random();
    return colorMap.values.elementAt(random.nextInt(colorMap.length));
  }
}
