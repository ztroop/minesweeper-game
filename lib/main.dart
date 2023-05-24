import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'minesweeper.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameSettings(),
      child: MaterialApp(
        title: 'Minesweeper',
        theme: ThemeData(primarySwatch: Colors.blueGrey),
        home: const StartScreen(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

class MinesweeperBoard extends StatelessWidget {
  final VoidCallback onGameOver;
  final VoidCallback onGameWon;

  const MinesweeperBoard(
      {super.key, required this.onGameOver, required this.onGameWon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Get Sweepin!')),
      body: Consumer<MinesweeperGame>(
        builder: (context, game, child) {
          if (game.gameOver) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onGameOver(); // Use the callback here
            });
          }

          if (game.gameWon) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onGameWon(); // Use the callback here
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
      return const Image(
          image: AssetImage('assets/flag.png'), fit: BoxFit.fill);
    }

    if (cell.status == CellStatus.uncovered) {
      if (cell.hasMine) {
        return const Image(
            image: AssetImage('assets/bomb.png'), fit: BoxFit.fill);
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
              Provider.of<GameSettings>(context, listen: false)
                  .currentGame
                  .restart();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

/// Returns the widget that shows the game won and restart option
Future<void> _showGameWonDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Congratulations!'),
        content: const Text('You have won the game!'),
        actions: <Widget>[
          TextButton(
            child: const Text('Restart'),
            onPressed: () {
              Provider.of<GameSettings>(context, listen: false)
                  .currentGame
                  .restart();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

enum GameDifficulty { easy, medium, hard }

class GameSettings extends ChangeNotifier {
  GameDifficulty _gameDifficulty = GameDifficulty.easy;
  late MinesweeperGame _currentGame;

  GameSettings() {
    _currentGame = _createNewGame();
  }

  set gameDifficulty(GameDifficulty difficulty) {
    _gameDifficulty = difficulty;
    _currentGame = _createNewGame();
    notifyListeners();
  }

  GameDifficulty get gameDifficulty => _gameDifficulty;

  MinesweeperGame get currentGame => _currentGame;

  MinesweeperGame _createNewGame() {
    switch (_gameDifficulty) {
      case GameDifficulty.easy:
        return MinesweeperGame(rows: 9, cols: 9, mineCount: 10);
      case GameDifficulty.medium:
        return MinesweeperGame(rows: 16, cols: 16, mineCount: 40);
      case GameDifficulty.hard:
        return MinesweeperGame(rows: 30, cols: 16, mineCount: 99);
      default:
        return MinesweeperGame(rows: 9, cols: 9, mineCount: 10);
    }
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minesweeper')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Image(
                      image: AssetImage('assets/bomb.png'),
                      height: 150,
                      width: 150)),
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                  child: Text(
                    """To play Minesweeper, start by choosing your desired difficulty. The game grid consists of covered squares, some of which contain hidden mines.

Gameplay involves clicking a square to reveal what's underneath. If the square is empty, it will show a number indicating how many mines are in the adjacent eight squares. If it contains a mine, you lose the game.

Alternatively, hold-click on a square to place a flag if you suspect there's a mine underneath it.

The objective of the game is to uncover all squares that don't have mines, correctly flagging all squares containing mines.""",
                    textAlign: TextAlign.center,
                  )),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text('Select Difficulty',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              for (var difficulty in GameDifficulty.values)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: ElevatedButton(
                    child: Text(describeEnum(difficulty).toUpperCase()),
                    onPressed: () {
                      Provider.of<GameSettings>(context, listen: false)
                          .gameDifficulty = difficulty;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MinesweeperScreen(),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class MinesweeperScreen extends StatelessWidget {
  const MinesweeperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameSettings>(
      builder: (context, settings, _) =>
          ChangeNotifierProvider<MinesweeperGame>(
        create: (context) => settings.currentGame,
        child: MinesweeperBoard(
          onGameOver: () {
            _showGameOverDialog(context);
          },
          onGameWon: () {
            _showGameWonDialog(context);
          },
        ),
      ),
    );
  }
}
