import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';

void main() {
  // Enable debug paint
  // debugPaintSizeEnabled = true;
  false;

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TileGame(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TileGame extends StatefulWidget {
  const TileGame({Key? key}) : super(key: key);

  @override
  _TileGameState createState() => _TileGameState();
}

class _TileGameState extends State<TileGame> {
  List<List<int>> _tiles;
  Timer? _timer; // Make _timer nullable
  int _elapsedTime = 0; // Track elapsed time
  bool _isPaused = true; // Track timer state
  bool _isTimerStarted = false; // Track if the timer has started
  bool _isLoading = false; // Track loading state
  int _moveCount = 0; // Track the number of moves

  _TileGameState()
      : _tiles = List.generate(
            4,
            (i) => List.generate(
                4, (j) => (i * 4 + j + 1) < 16 ? (i * 4 + j + 1) : 16));

  // Define color constants
  static const Color appBarColor = Color.fromARGB(255, 86, 64, 124);
  static const Color buttonColor = Color.fromARGB(50, 0, 0, 0);
  static const Color tileColor = Color.fromRGBO(106, 198, 184, 1);

  void _moveTile(int index) {
    int emptyTileIndex = _tiles.expand((row) => row).toList().indexOf(16);
    // Check if the tapped tile is adjacent to the empty tile
    if (_isAdjacent(index, emptyTileIndex)) {
      setState(() {
        // Swap the tiles
        int tappedRow = index ~/ 4;
        int tappedCol = index % 4;
        int emptyRow = emptyTileIndex ~/ 4;
        int emptyCol = emptyTileIndex % 4;

        // Swap the values
        _tiles[emptyRow][emptyCol] = _tiles[tappedRow][tappedCol];
        _tiles[tappedRow][tappedCol] = 16; // Update the tapped tile to be empty
        _moveCount++; // Increment move count
      });

      // Start the timer when the first tile is moved
      if (!_isTimerStarted) {
        _isTimerStarted = true; // Mark the timer as started
        _startTimer(); // Start the timer
      } else if (_isPaused) {
        _isPaused = false; // Resume the timer if it was paused
      }
    }
  }

  bool _isAdjacent(int index1, int index2) {
    int row1 = index1 ~/ 4;
    int col1 = index1 % 4;
    int row2 = index2 ~/ 4;
    int col2 = index2 % 4;
    return (row1 == row2 && (col1 - col2).abs() == 1) ||
        (col1 == col2 && (row1 - row2).abs() == 1);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _elapsedTime++;
        });
      }
    });
  }

  void _resetTimer() {
    _elapsedTime = 0;
    _isPaused = false; // Ensure timer is not paused
    _timer?.cancel(); // Stop the timer if it's running
    _isTimerStarted = false; // Reset timer started state
    _moveCount = 0; // Reset move count when starting a new game
  }

  void _pauseTimer() {
    setState(() {
      _isPaused = true; // Pause the timer
    });
  }

  void _reshuffleTiles() async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });

    List<int> numbers = List.generate(15, (index) => index + 1)..add(16);
    // Shuffle the numbers
    do {
      numbers.shuffle(); // Shuffle the numbers
    } while (
        !_isSolvable(numbers)); // Ensure the shuffled configuration is solvable

    setState(() {
      _tiles =
          List.generate(4, (i) => List.generate(4, (j) => numbers[i * 4 + j]));
      _isLoading = false; // Set loading state to false
    });
  }

  // New method to check if the configuration is solvable
  bool _isSolvable(List<int> numbers) {
    int inversions = 0;
    for (int i = 0; i < numbers.length; i++) {
      for (int j = i + 1; j < numbers.length; j++) {
        if (numbers[i] != 16 && numbers[j] != 16 && numbers[i] > numbers[j]) {
          inversions++;
        }
      }
    }
    // The puzzle is solvable if the number of inversions is even
    return inversions % 2 == 0;
  }

  @override
  void initState() {
    super.initState();
    _reshuffleTiles(); // Shuffle tiles on initialization
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  String _formattedElapsedTime() {
    int minutes = _elapsedTime ~/ 60;
    int seconds = _elapsedTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "15 Puzzle",
          style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(240, 255, 255, 255)),
        ),
        backgroundColor: appBarColor, // Use constant
      ),
      body: Center(
        child: _isLoading // Show loading indicator if loading
            ? CircularProgressIndicator() // Loading indicator
            : Container(
                color: appBarColor, // Use constant
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 60,
                          width: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor, // Use constant
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              _resetTimer(); // Reset the timer when starting a new game
                              _reshuffleTiles(); // Reshuffle the tiles for a new game
                              // Handle new game action
                            },
                            child: const Text(
                              'New Game',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(113, 0, 0, 0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 2.0),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Timer',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.white)),
                                  Text(_formattedElapsedTime(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                          color: Colors.white)),
                                ],
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Moves',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.white)),
                                  Text("$_moveCount", // Display move count
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                          color: Colors.white)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    SizedBox(
                      height: 550,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 500, // Remove or adjust this height
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                              ),
                              itemCount: 16,
                              itemBuilder: (context, index) {
                                int tileValue = _tiles[index ~/ 4][index % 4];
                                Color tileDisplayColor = (tileValue ==
                                            (index + 1) ||
                                        (index == 15 && tileValue == 16))
                                    ? Colors
                                        .green // Change this to your desired color for correct position
                                    : tileColor; // Use constant for incorrect position

                                return GestureDetector(
                                  onTap: () {
                                    _moveTile(
                                        index); // Call the moveTile method
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Container(
                                      margin: const EdgeInsets.all(4.0),
                                      decoration: BoxDecoration(
                                        color: tileValue == 16
                                            ? buttonColor
                                            : tileDisplayColor, // Use the new color logic
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          tileValue == 16 ? '' : '$tileValue',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 44,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: 50,
                            width: double
                                .infinity, // Make the button take the full width
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonColor, // Use constant
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                _pauseTimer(); // Pause the timer
                                // Handle pause timer action
                              },
                              child: const Text('Pause Timer',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                      color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
