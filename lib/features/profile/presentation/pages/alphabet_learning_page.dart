import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';

class AlphabetLearningPage extends StatefulWidget {
  const AlphabetLearningPage({super.key});

  @override
  State<AlphabetLearningPage> createState() => _AlphabetLearningPageState();
}

class _AlphabetLearningPageState extends State<AlphabetLearningPage>
    with TickerProviderStateMixin {
  int currentLetterIndex = 0;
  int score = 0;
  int streak = 0;
  bool showingAnswer = false;
  String selectedAnswer = '';

  final List<Map<String, dynamic>> alphabet = [
    {'letter': 'A', 'word': 'Apple', 'emoji': '🍎', 'color': Colors.red},
    {'letter': 'B', 'word': 'Banana', 'emoji': '🍌', 'color': Colors.yellow},
    {'letter': 'C', 'word': 'Cat', 'emoji': '🐱', 'color': Colors.orange},
    {'letter': 'D', 'word': 'Dog', 'emoji': '🐕', 'color': Colors.brown},
    {'letter': 'E', 'word': 'Elephant', 'emoji': '🐘', 'color': Colors.grey},
    {'letter': 'F', 'word': 'Fish', 'emoji': '🐟', 'color': Colors.blue},
    {'letter': 'G', 'word': 'Grapes', 'emoji': '🍇', 'color': Colors.purple},
    {'letter': 'H', 'word': 'House', 'emoji': '🏠', 'color': Colors.brown},
    {'letter': 'I', 'word': 'Ice Cream', 'emoji': '🍦', 'color': Colors.pink},
    {'letter': 'J', 'word': 'Jellyfish', 'emoji': '🪼', 'color': Colors.cyan},
    {'letter': 'K', 'word': 'Kite', 'emoji': '🪁', 'color': Colors.red},
    {'letter': 'L', 'word': 'Lion', 'emoji': '🦁', 'color': Colors.orange},
    {'letter': 'M', 'word': 'Moon', 'emoji': '🌙', 'color': Colors.yellow},
    {'letter': 'N', 'word': 'Nest', 'emoji': '🪺', 'color': Colors.brown},
    {'letter': 'O', 'word': 'Orange', 'emoji': '🍊', 'color': Colors.orange},
    {'letter': 'P', 'word': 'Penguin', 'emoji': '🐧', 'color': Colors.blue},
    {'letter': 'Q', 'word': 'Queen', 'emoji': '👸', 'color': Colors.pink},
    {'letter': 'R', 'word': 'Rainbow', 'emoji': '🌈', 'color': Colors.purple},
    {'letter': 'S', 'word': 'Sun', 'emoji': '☀️', 'color': Colors.yellow},
    {'letter': 'T', 'word': 'Tree', 'emoji': '🌳', 'color': Colors.green},
    {'letter': 'U', 'word': 'Umbrella', 'emoji': '☂️', 'color': Colors.blue},
    {'letter': 'V', 'word': 'Volcano', 'emoji': '🌋', 'color': Colors.red},
    {'letter': 'W', 'word': 'Watermelon', 'emoji': '🍉', 'color': Colors.green},
    {'letter': 'X', 'word': 'Xylophone', 'emoji': '🎵', 'color': Colors.cyan},
    {'letter': 'Y', 'word': 'Yo-yo', 'emoji': '🪀', 'color': Colors.red},
    {'letter': 'Z', 'word': 'Zebra', 'emoji': '🦓', 'color': Colors.grey},
  ];

  late AnimationController _letterController;
  late AnimationController _celebrationController;
  final random = math.Random();

  @override
  void initState() {
    super.initState();
    _letterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _letterController.forward();
  }

  @override
  void dispose() {
    _letterController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  List<String> _generateOptions() {
    final current = alphabet[currentLetterIndex];
    final options = <String>[current['letter'] as String];

    while (options.length < 4) {
      final randomLetter =
          alphabet[random.nextInt(alphabet.length)]['letter'] as String;
      if (!options.contains(randomLetter)) {
        options.add(randomLetter);
      }
    }

    options.shuffle();
    return options;
  }

  void _checkAnswer(String answer) {
    final correct = alphabet[currentLetterIndex]['letter'] as String;

    setState(() {
      selectedAnswer = answer;
      showingAnswer = true;
    });

    if (answer == correct) {
      score += 10 + (streak * 5);
      streak++;
      _celebrationController.forward(from: 0);
    } else {
      streak = 0;
    }

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          currentLetterIndex = (currentLetterIndex + 1) % alphabet.length;
          showingAnswer = false;
          selectedAnswer = '';
        });
        _letterController.forward(from: 0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = alphabet[currentLetterIndex];
    final options = _generateOptions();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
              Color(0xFFF093FB),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildStatsBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildLetterCard(current),
                      const SizedBox(height: 40),
                      _buildQuestion(),
                      const SizedBox(height: 30),
                      _buildOptions(options),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Spacer(),
          Column(
            children: [
              const Text(
                'ABC LEARNING',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              Text(
                'Letter ${currentLetterIndex + 1} of ${alphabet.length}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('⭐', 'Score', score.toString(), Colors.amber),
          Container(width: 1, height: 40, color: Colors.white30),
          _buildStatItem('🔥', 'Streak', streak.toString(), Colors.orange),
          Container(width: 1, height: 40, color: Colors.white30),
          _buildStatItem(
              '📚',
              'Progress',
              '${((currentLetterIndex / alphabet.length) * 100).toInt()}%',
              Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String label, String value, Color color) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildLetterCard(Map<String, dynamic> current) {
    return AnimatedBuilder(
      animation: _letterController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_letterController.value * 0.2),
          child: Opacity(
            opacity: _letterController.value,
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: (current['color'] as Color).withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    current['emoji'] as String,
                    style: const TextStyle(fontSize: 120),
                  )
                      .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true))
                      .scale(
                          duration: 2.seconds,
                          begin: const Offset(1, 1),
                          end: const Offset(1.1, 1.1))
                      .rotate(duration: 3.seconds, begin: -0.05, end: 0.05),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          (current['color'] as Color).withOpacity(0.8),
                          (current['color'] as Color),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (current['color'] as Color).withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Text(
                      current['word'] as String,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestion() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: const Text(
        'Which letter does this word start with?',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildOptions(List<String> options) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final isCorrect = option == alphabet[currentLetterIndex]['letter'];
        final isSelected = option == selectedAnswer;

        Color getColor() {
          if (!showingAnswer) return Colors.white;
          if (isSelected && isCorrect) return Colors.green;
          if (isSelected && !isCorrect) return Colors.red;
          if (isCorrect) return Colors.green.shade200;
          return Colors.white;
        }

        return GestureDetector(
          onTap: showingAnswer ? null : () => _checkAnswer(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: getColor(),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? (isCorrect ? Colors.green.shade700 : Colors.red.shade700)
                    : Colors.white.withOpacity(0.3),
                width: isSelected ? 4 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? (isCorrect ? Colors.green : Colors.red).withOpacity(0.5)
                      : Colors.black.withOpacity(0.2),
                  blurRadius: isSelected ? 20 : 10,
                  spreadRadius: isSelected ? 5 : 2,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    option,
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      color: showingAnswer
                          ? (isCorrect ? Colors.white : Colors.black87)
                          : Color(0xFF667EEA),
                      shadows: const [
                        Shadow(
                          color: Colors.black12,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  if (isSelected && showingAnswer)
                    Text(
                      isCorrect ? '✓ Correct!' : '✗ Wrong',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isCorrect ? Colors.white : Colors.black87,
                      ),
                    ),
                ],
              ),
            ),
          )
              .animate(target: isSelected && isCorrect ? 1 : 0)
              .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1))
              .shake(hz: 5),
        );
      },
    );
  }
}
