import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'minesweeper.dart';

void main() {
  runApp(const MyApp());
}

/// Represents the root widget of the Minesweeper game application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider(
        create: (context) => MinesweeperGame(rows: 9, cols: 9, mineCount: 10),
        child: const MinesweeperBoard(),
      ),
    );
  }
}

/// Represents the Minesweeper game board widget
class MinesweeperBoard extends StatelessWidget {
  const MinesweeperBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minesweeper')),
      body: Consumer<MinesweeperGame>(
        builder: (context, game, child) {
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
                  Provider.of<MinesweeperGame>(context, listen: false).notifyListeners();
                },
                onLongPress: () {
                  game.toggleFlag(row, col);
                  Provider.of<MinesweeperGame>(context, listen: false).notifyListeners();
                },
                child: GridTile(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      color: cell.status == CellStatus.uncovered ? Colors.white : Colors.grey[300],
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
      }

      if (cell.adjacentMines > 0) {
        return Text('${cell.adjacentMines}', style: const TextStyle(fontSize: 18));
      }
    }

    return null;
  }
}
