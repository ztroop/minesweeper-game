import 'dart:math';

import 'package:flutter/foundation.dart';

/// Represents the status of a cell in the Minesweeper game
enum CellStatus { covered, uncovered, flagged }

/// Represents a single cell on the Minesweeper game board
class Cell {
  CellStatus status;
  bool hasMine;
  int adjacentMines;

  /// Creates a new cell with the specified [status], [hasMine], and [adjacentMines] properties
  Cell({this.status = CellStatus.covered, this.hasMine = false, this.adjacentMines = 0});
}

/// Represents the Minesweeper game logic and state
class MinesweeperGame extends ChangeNotifier {
  final int rows;
  final int cols;
  final int mineCount;
  List<List<Cell>> _board;
  bool _gameOver;
  bool _gameWon;

  /// Creates a new Minesweeper game with the specified [rows], [cols], and [mineCount]
  MinesweeperGame({required this.rows, required this.cols, required this.mineCount})
      : _board = List.generate(rows, (_) => List.generate(cols, (_) => Cell())),
        _gameOver = false,
        _gameWon = false {
    _initializeMines();
    _calculateAdjacentMines();
  }

  /// Returns the cell at the specified [row] and [col]
  Cell getCell(int row, int col) => _board[row][col];

  bool get gameOver => _gameOver;
  bool get gameWon => _gameWon;

  /// Initializes mines randomly on the game board
  void _initializeMines() {
    int minesPlaced = 0;
    Random random = Random();

    while (minesPlaced < mineCount) {
      int row = random.nextInt(rows);
      int col = random.nextInt(cols);
      if (!_board[row][col].hasMine) {
        _board[row][col].hasMine = true;
        minesPlaced++;
      }
    }
  }

  /// Calculates the number of adjacent mines for each cell on the game board
  void _calculateAdjacentMines() {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        if (_board[row][col].hasMine) continue;

        int count = 0;
        for (int i = -1; i <= 1; i++) {
          for (int j = -1; j <= 1; j++) {
            if (row + i < 0 || row + i >= rows || col + j < 0 || col + j >= cols) continue;
            if (_board[row + i][col + j].hasMine) count++;
          }
        }

        _board[row][col].adjacentMines = count;
      }
    }
  }

  /// Uncovers the cell at the specified [row] and [col]
  void uncoverCell(int row, int col) {
    if (_gameOver || _gameWon || _board[row][col].status != CellStatus.covered) return;

    _board[row][col].status = CellStatus.uncovered;

    if (_board[row][col].hasMine) {
      _gameOver = true;
      return;
    }

    if (_board[row][col].adjacentMines == 0) {
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          if (row + i < 0 || row + i >= rows || col + j < 0 || col + j >= cols) continue;
          if (_board[row + i][col + j].status == CellStatus.covered) {
            uncoverCell(row + i, col + j);
                   }
        }
      }
    }

    _checkGameWon();
  }

  /// Toggles the flagged status of the cell at the specified [row] and [col]
  void toggleFlag(int row, int col) {
    if (_gameOver || _gameWon) return;

    if (_board[row][col].status == CellStatus.covered) {
      _board[row][col].status = CellStatus.flagged;
    } else if (_board[row][col].status == CellStatus.flagged) {
      _board[row][col].status = CellStatus.covered;
    }
  }

  /// Checks if the game has been won and updates the [_gameWon] property accordingly
  void _checkGameWon() {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        if (!_board[row][col].hasMine && _board[row][col].status != CellStatus.uncovered) {
          return;
        }
      }
    }

    _gameWon = true;
  }
}
