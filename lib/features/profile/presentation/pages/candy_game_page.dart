import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app1/services/api_service.dart';

class CandyGamePage extends StatefulWidget {
  const CandyGamePage({super.key});

  @override
  State<CandyGamePage> createState() => _CandyGamePageState();
}

class _CandyGamePageState extends State<CandyGamePage>
    with TickerProviderStateMixin {
  static const int rows = 8;
  static const int cols = 8;
  late List<List<CandyCell>> grid;
  int score = 0;
  int moves = 30;
  int level = 1;
  int targetScore = 500;
  List<String> candies = ['🍎', '🍇', '🍊', '🍓', '🍋', '🍐'];

  // Selection state
  int? selectedRow;
  int? selectedCol;

  // Animation controllers
  late AnimationController _comboController;
  int comboMultiplier = 1;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _comboController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _initializeGrid();
    _removeInitialMatches();
  }

  @override
  void dispose() {
    _comboController.dispose();
    super.dispose();
  }

  void _initializeGrid() {
    final random = math.Random();
    grid = List.generate(
      rows,
      (r) => List.generate(
        cols,
        (c) => CandyCell(
          emoji: candies[random.nextInt(candies.length)],
          key: UniqueKey(),
        ),
      ),
    );
  }

  void _removeInitialMatches() {
    bool found;
    do {
      found = false;
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          if (_checkMatchAt(r, c)) {
            grid[r][c] = CandyCell(
              emoji: candies[math.Random().nextInt(candies.length)],
              key: UniqueKey(),
            );
            found = true;
          }
        }
      }
    } while (found);
  }

  bool _checkMatchAt(int r, int c) {
    String type = grid[r][c].emoji;
    if (type.isEmpty) return false;
    // Horizontal
    if (c >= 2 && grid[r][c - 1].emoji == type && grid[r][c - 2].emoji == type)
      return true;
    // Vertical
    if (r >= 2 && grid[r - 1][c].emoji == type && grid[r - 2][c].emoji == type)
      return true;
    return false;
  }

  void _handleTap(int r, int c) {
    if (isProcessing || moves <= 0) return;

    if (selectedRow == null) {
      setState(() {
        selectedRow = r;
        selectedCol = c;
      });
    } else {
      // Check if adjacent
      if ((r == selectedRow && (c - selectedCol!).abs() == 1) ||
          (c == selectedCol && (r - selectedRow!).abs() == 1)) {
        _swap(selectedRow!, selectedCol!, r, c);
        setState(() {
          moves--;
        });
        _processMatches();
      }
      setState(() {
        selectedRow = null;
        selectedCol = null;
      });
    }
  }

  void _swap(int r1, int c1, int r2, int c2) {
    final temp = grid[r1][c1];
    grid[r1][c1] = grid[r2][c2];
    grid[r2][c2] = temp;
  }

  Future<void> _processMatches() async {
    isProcessing = true;
    comboMultiplier = 1;
    bool hasMatches = true;

    while (hasMatches) {
      List<List<int>> matches = _findMatches();
      if (matches.isEmpty) break;

      // Animate combo
      _comboController.forward(from: 0);

      setState(() {
        int matchScore = matches.length * 10 * comboMultiplier;
        score += matchScore;

        for (var pos in matches) {
          grid[pos[0]][pos[1]] = CandyCell(emoji: '', key: UniqueKey());
        }

        comboMultiplier++;
      });

      await Future.delayed(const Duration(milliseconds: 400));
      _applyGravity();
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 400));
    }

    isProcessing = false;
    comboMultiplier = 1;

    // Check win/lose conditions
    if (score >= targetScore) {
      _levelUp();
    } else if (moves <= 0) {
      _gameOver();
    }
  }

  List<List<int>> _findMatches() {
    Set<String> matchPositions = {};

    // Horizontal
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols - 2; c++) {
        String t = grid[r][c].emoji;
        if (t.isNotEmpty &&
            grid[r][c + 1].emoji == t &&
            grid[r][c + 2].emoji == t) {
          matchPositions.add('$r,$c');
          matchPositions.add('$r,${c + 1}');
          matchPositions.add('$r,${c + 2}');

          // Check for 4 or 5 matches
          if (c + 3 < cols && grid[r][c + 3].emoji == t) {
            matchPositions.add('$r,${c + 3}');
            if (c + 4 < cols && grid[r][c + 4].emoji == t) {
              matchPositions.add('$r,${c + 4}');
            }
          }
        }
      }
    }

    // Vertical
    for (int c = 0; c < cols; c++) {
      for (int r = 0; r < rows - 2; r++) {
        String t = grid[r][c].emoji;
        if (t.isNotEmpty &&
            grid[r + 1][c].emoji == t &&
            grid[r + 2][c].emoji == t) {
          matchPositions.add('$r,$c');
          matchPositions.add('${r + 1},$c');
          matchPositions.add('${r + 2},$c');

          // Check for 4 or 5 matches
          if (r + 3 < rows && grid[r + 3][c].emoji == t) {
            matchPositions.add('${r + 3},$c');
            if (r + 4 < rows && grid[r + 4][c].emoji == t) {
              matchPositions.add('${r + 4},$c');
            }
          }
        }
      }
    }

    return matchPositions.map((s) {
      var parts = s.split(',');
      return [int.parse(parts[0]), int.parse(parts[1])];
    }).toList();
  }

  void _applyGravity() {
    final random = math.Random();
    for (int c = 0; c < cols; c++) {
      int emptyIdx = rows - 1;
      while (emptyIdx >= 0) {
        if (grid[emptyIdx][c].emoji.isEmpty) {
          int nextFull = emptyIdx - 1;
          while (nextFull >= 0 && grid[nextFull][c].emoji.isEmpty) {
            nextFull--;
          }
          if (nextFull >= 0) {
            grid[emptyIdx][c] = grid[nextFull][c];
            grid[nextFull][c] = CandyCell(emoji: '', key: UniqueKey());
          } else {
            grid[emptyIdx][c] = CandyCell(
              emoji: candies[random.nextInt(candies.length)],
              key: UniqueKey(),
            );
          }
        }
        emptyIdx--;
      }
    }
  }

  void _levelUp() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎉',
                style: TextStyle(fontSize: 80),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .rotate(duration: 2.seconds),
              const SizedBox(height: 20),
              const Text(
                'LEVEL COMPLETE!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Score: $score',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    level++;
                    targetScore += 300;
                    moves = 30;
                    _initializeGrid();
                    _removeInitialMatches();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.purple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'NEXT LEVEL',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _gameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFF97316)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '😢',
                style: TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 20),
              const Text(
                'GAME OVER',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Final Score: $score',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white24,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('EXIT'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        score = 0;
                        moves = 30;
                        level = 1;
                        targetScore = 500;
                        _initializeGrid();
                        _removeInitialMatches();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('RETRY',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E1B4B),
              Color(0xFF312E81),
              Color(0xFF4C1D95),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 600;
              final isDesktop = constraints.maxWidth > 900;
              final maxWidth =
                  isDesktop ? 600.0 : (isTablet ? 500.0 : constraints.maxWidth);

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    children: [
                      _buildHeader(isTablet, isDesktop),
                      _buildStatsBar(isTablet, isDesktop),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, gameConstraints) {
                            final availableWidth = gameConstraints.maxWidth;
                            final availableHeight = gameConstraints.maxHeight;
                            final gridSize =
                                math.min(availableWidth, availableHeight) -
                                    (isTablet ? 48 : 24);

                            // Calculate dynamic sizes
                            final cellWidth = gridSize / cols;
                            final emojiSize = cellWidth * 0.65;

                            return Center(
                              child: Container(
                                width: gridSize,
                                height: gridSize,
                                padding: EdgeInsets.all(isTablet ? 12 : 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius:
                                      BorderRadius.circular(isTablet ? 30 : 20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: isTablet ? 3 : 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.purple.withOpacity(0.3),
                                      blurRadius: isTablet ? 40 : 30,
                                      spreadRadius: isTablet ? 8 : 5,
                                    ),
                                  ],
                                ),
                                child: GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: cols,
                                    crossAxisSpacing: isTablet ? 8 : 4,
                                    mainAxisSpacing: isTablet ? 8 : 4,
                                  ),
                                  itemCount: rows * cols,
                                  itemBuilder: (context, index) {
                                    int r = index ~/ cols;
                                    int c = index % cols;
                                    return _buildCandyCell(
                                        r, c, isTablet, emojiSize);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      _buildBottomInfo(isTablet),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _saveAndExit() async {
    // Save progress to server
    if (score > 0) {
      try {
        await ApiService.claimReward(
          gameName: 'Candy Crush',
          score: score,
          coins: (score / 100).floor(),
        );
      } catch (e) {
        debugPrint("Error saving progress: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save progress: $e')),
          );
        }
      }
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Widget _buildHeader(bool isTablet, bool isDesktop) {
    final titleSize = isDesktop ? 32.0 : (isTablet ? 28.0 : 24.0);
    final levelSize = isDesktop ? 14.0 : (isTablet ? 13.0 : 12.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 12 : 8,
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: isTablet ? 24 : 18,
              ),
              onPressed: _saveAndExit,
            ),
          ),
          const Spacer(),
          Column(
            children: [
              Text(
                'CANDY CRUSH',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: isTablet ? 4 : 2,
                  shadows: const [
                    Shadow(
                      color: Colors.purple,
                      blurRadius: 10,
                    ),
                  ],
                ),
              ).animate(onPlay: (controller) => controller.repeat()).shimmer(
                  duration: 2.seconds, color: Colors.white.withOpacity(0.3)),
              Text(
                'Level $level',
                style: TextStyle(
                  fontSize: levelSize,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(width: isTablet ? 56 : 40),
        ],
      ),
    );
  }

  Widget _buildStatsBar(bool isTablet, bool isDesktop) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 12 : 8,
      ),
      padding: EdgeInsets.all(isTablet ? 20 : 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isTablet ? 24 : 16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
              '🎯', 'Score', score.toString(), Colors.amber, isTablet),
          Container(
              width: 1, height: isTablet ? 50 : 30, color: Colors.white24),
          _buildStatItem(
              '🎮', 'Moves', moves.toString(), Colors.cyan, isTablet),
          Container(
              width: 1, height: isTablet ? 50 : 30, color: Colors.white24),
          _buildStatItem(
              '⭐', 'Target', targetScore.toString(), Colors.pink, isTablet),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String emoji, String label, String value, Color color, bool isTablet) {
    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: isTablet ? 26 : 20)),
        SizedBox(height: isTablet ? 6 : 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 12 : 10,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  Widget _buildCandyCell(int r, int c, bool isTablet, double emojiSize) {
    bool isSelected = selectedRow == r && selectedCol == c;
    String emoji = grid[r][c].emoji;

    return GestureDetector(
      onTap: () => _handleTap(r, c),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
          borderRadius: BorderRadius.circular(isTablet ? 16 : 10),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.white.withOpacity(0.1),
            width: isSelected ? (isTablet ? 4 : 3) : (isTablet ? 2 : 1),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.5),
                    blurRadius: isTablet ? 20 : 15,
                    spreadRadius: isTablet ? 3 : 2,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: emoji.isEmpty
              ? const SizedBox.shrink()
              : Text(
                  emoji,
                  style: TextStyle(fontSize: emojiSize),
                )
                  .animate(key: grid[r][c].key)
                  .scale(
                    duration: 400.ms,
                    curve: Curves.elasticOut,
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                  )
                  .fadeIn(duration: 300.ms),
        ),
      ),
    );
  }

  Widget _buildBottomInfo(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      child: Column(
        children: [
          if (comboMultiplier > 1)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 28 : 20,
                vertical: isTablet ? 14 : 10,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEC4899), Color(0xFFF97316)],
                ),
                borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.5),
                    blurRadius: isTablet ? 25 : 20,
                  ),
                ],
              ),
              child: Text(
                'COMBO x$comboMultiplier! 🔥',
                style: TextStyle(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            )
                .animate(controller: _comboController)
                .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1))
                .fadeIn(),
          SizedBox(height: isTablet ? 12 : 10),
          Text(
            'Match 3 or more candies! 🍬✨',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class CandyCell {
  final String emoji;
  final Key key;

  CandyCell({required this.emoji, required this.key});
}
