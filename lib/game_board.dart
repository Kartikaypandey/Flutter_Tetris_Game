import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tetris/pieces.dart';
import 'package:tetris/pixel.dart';
import 'package:tetris/values.dart';

List<List<dynamic>> gameBoard =
    List.generate(numRows, (i) => List.generate(numCols, (j) => null));

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  Piece currentPiece = Piece(type: TetriMino.L);

  int currentScore = 0;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    currentPiece.initPosition();
    Duration gameSpeed = const Duration(milliseconds: 200);
    gameLoop(gameSpeed);
  }

  void gameLoop(Duration gameSpeed) {
    Timer.periodic(gameSpeed, (timer) {
      setState(() {
        clearLines();
        checkLanding();
        if (gameOver) {
          timer.cancel();
          showGameOverDialog();
        }
        currentPiece.movePiece(Direction.down);
      });
    });
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game over'),
        content: Text('Current Score is $currentScore'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                resetGame();
              },
              child: const Text('Restart'))
        ],
      ),
    );
  }

  void resetGame() {
    gameBoard =
        List.generate(numRows, (i) => List.generate(numCols, (j) => null));

    gameOver = false;
    currentScore = 0;

    createNewPiece();

    startGame();
  }

  bool checkCollision(Direction direction) {
    for (int i = 0; i < currentPiece.position.length; i++) {
      int row = currentPiece.position[i] ~/ numCols;
      int col = currentPiece.position[i] % numCols;

      switch (direction) {
        case Direction.down:
          row += 1;
          break;
        case Direction.left:
          col -= 1;
          break;
        case Direction.right:
          col += 1;
          break;
        default:
      }
      if (row >= numRows || col < 0 || col >= numCols) {
        return true;
      }

      if (row >= 0 && col >= 0) {
        if (gameBoard[row][col] != null) return true;
      }
    }
    return false;
  }

  void checkLanding() {
    if (checkCollision(Direction.down)) {
      for (int i = 0; i < currentPiece.position.length; i++) {
        int row = currentPiece.position[i] ~/ numCols;
        int col = currentPiece.position[i] % numCols;

        if (row >= 0 && col >= 0) {
          gameBoard[row][col] = currentPiece.type;
        }
      }

      createNewPiece();
    }
  }

  void moveLeft() {
    if (!checkCollision(Direction.left)) {
      currentPiece.movePiece(Direction.left);
    }
  }

  void moveRight() {
    if (!checkCollision(Direction.right)) {
      currentPiece.movePiece(Direction.right);
    }
  }

  void clearLines() {
    for (int i = numRows - 1; i >= 0; i--) {
      bool isRowFull = true;
      for (int j = 0; j < numCols; j++) {
        if (gameBoard[i][j] == null) {
          isRowFull = false;
        }
      }
      if (isRowFull) {
        currentScore++;
        for (int r = i; r > 0; r--) {
          gameBoard[r] = List.from(gameBoard[r - 1]);
        }
        gameBoard[0] = List.generate(numCols, (index) => null);
      }
    }
  }

  void rotate() {
    setState(() {
      currentPiece.rotatePiece();
    });
  }

  void createNewPiece() {
    Random rand = Random();
    TetriMino randomType =
        TetriMino.values[rand.nextInt(TetriMino.values.length)];
    currentPiece = Piece(type: randomType);
    currentPiece.initPosition();

    if (isGameOver()) {
      gameOver = true;
    }
  }

  bool isGameOver() {
    for (int i = 0; i < numCols; i++) {
      if (gameBoard[0][i] != null) return true;
    }
    return false;
  }

  int numRows = 15;
  int numCols = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              itemCount: numRows * numCols,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: numCols,
              ),
              itemBuilder: (context, index) {
                int row = index ~/ numCols;
                int col = index % numCols;
                if (currentPiece.position.contains(index)) {
                  return Pixel(
                    color: currentPiece.color,
                    number: index,
                  );
                } else if (gameBoard[row][col] != null) {
                  TetriMino type = gameBoard[row][col];

                  return Pixel(
                    color: TetriMinoColors.colorMap[type] ??
                        TetriMinoColors.getRandomColor(),
                    number: index,
                  );
                } else {
                  return Pixel(
                    color: Color.fromARGB(255, 65, 63, 63),
                    number: index,
                  );
                }
              },
            ),
          ),
          Text(
            'Current Score : $currentScore',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0, top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: moveLeft,
                  icon: const Icon(Icons.arrow_back_ios_new),
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: rotate,
                  icon: const Icon(Icons.rotate_right),
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: moveRight,
                  icon: const Icon(Icons.arrow_forward_ios),
                  color: Colors.white,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
