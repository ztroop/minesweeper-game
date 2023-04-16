import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'minesweeper.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MinesweeperGame(rows: 9, cols: 9, mineCount: 10),
      child: MaterialApp(
        title: 'Minesweeper',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: Builder(
          builder: (BuildContext context) {
            return MinesweeperBoard(
              onGameOver: () {
                _showGameOverDialog(context);
              },
            );
          },
        ),
      ),
    ),
  );
}

class MinesweeperBoard extends StatelessWidget {
  final VoidCallback onGameOver;

  const MinesweeperBoard({super.key, required this.onGameOver});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minesweeper')),
      body: Consumer<MinesweeperGame>(
        builder: (context, game, child) {
          if (game.gameOver) {
            WidgetsBinding.instance!.addPostFrameCallback((_) {
              onGameOver(); // Use the callback here
            });
          }

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: game.cols,
              childAspectRatio: 1,
            ),
            itemCount: game.rows * game.cols,
            itemBuilder: (context, index) {
              int row = index ~/ game.cols;
              int col = index % game.cols;
              Cell cell = game.getCell(row, col);

              return GestureDetector(
                onTap: () {
                  game.uncoverCell(row, col);
                  Provider.of<MinesweeperGame>(context, listen: false)
                      .notifyListeners();
                },
                onLongPress: () {
                  game.toggleFlag(row, col);
                  Provider.of<MinesweeperGame>(context, listen: false)
                      .notifyListeners();
                },
                child: GridTile(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      color: cell.status == CellStatus.uncovered
                          ? Colors.white
                          : Colors.grey[300],
                    ),
                    child: Center(
                      child: _buildCellContent(cell),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Returns the widget representing the content of the given [cell] in the Minesweeper game board
  Widget? _buildCellContent(Cell cell) {
    if (cell.status == CellStatus.flagged) {
      return const Icon(Icons.flag, color: Colors.red);
    }

    if (cell.status == CellStatus.uncovered) {
      if (cell.hasMine) {
        return const Icon(Icons.error, color: Colors.red);
      } else if (cell.adjacentMines > 0) {
        return Text(
          '${cell.adjacentMines}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        );
      }
    }

    return null;
  }
}

/// Returns the widget that shows the game over and restart option
Future<void> _showGameOverDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Game Over'),
        content: const Text('You triggered a mine!'),
        actions: <Widget>[
          TextButton(
            child: const Text('Restart'),
            onPressed: () {
              Provider.of<MinesweeperGame>(context, listen: false).restart();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
