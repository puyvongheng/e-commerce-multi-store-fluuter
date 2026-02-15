import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app1/services/api_service.dart';

class KhmerQuizPage extends StatefulWidget {
  const KhmerQuizPage({super.key});

  @override
  State<KhmerQuizPage> createState() => _KhmerQuizPageState();
}

class _KhmerQuizPageState extends State<KhmerQuizPage>
    with TickerProviderStateMixin {
  int currentQuestionIndex = 0;
  int score = 0;
  int correctAnswers = 0;
  bool showingAnswer = false;
  String? selectedAnswer;

  final List<Map<String, dynamic>> questions = [
    {
      'type': 'riddle',
      'question': 'អ្វីដែលមានជើងបួន ប៉ុន្តែមិនអាចដើរបាន?',
      'options': ['តុ', 'ឆ្កែ', 'ទូ', 'កៅអី'],
      'answer': 'តុ',
      'explanation': 'តុមានជើងបួន ប៉ុន្តែវាមិនអាចដើរបាន',
      'emoji': '🪑',
    },
    {
      'type': 'quiz',
      'question': 'រដ្ឋធានីនៃកម្ពុជាគឺអ្វី?',
      'options': ['សៀមរាប', 'ភ្នំពេញ', 'បាត់ដំបង', 'កំពង់ចាម'],
      'answer': 'ភ្នំពេញ',
      'explanation': 'ភ្នំពេញគឺជារដ្ឋធានីនៃកម្ពុជា',
      'emoji': '🏛️',
    },
    {
      'type': 'riddle',
      'question': 'អ្វីដែលឡើងទៅមិនចុះមកវិញ?',
      'options': ['យន្តហោះ', 'អាយុ', 'ថ្ម', 'ទឹក'],
      'answer': 'អាយុ',
      'explanation': 'អាយុរបស់យើងឡើងទៅមិនចុះមកវិញ',
      'emoji': '⏰',
    },
    {
      'type': 'quiz',
      'question': 'ប្រាសាទអង្គរវត្តស្ថិតនៅខេត្តណា?',
      'options': ['ភ្នំពេញ', 'កំពត', 'សៀមរាប', 'កែប'],
      'answer': 'សៀមរាប',
      'explanation': 'ប្រាសាទអង្គរវត្តស្ថិតនៅខេត្តសៀមរាប',
      'emoji': '🏰',
    },
    {
      'type': 'riddle',
      'question': 'អ្វីដែលមានភ្នែក ប៉ុន្តែមិនអាចមើលឃើញ?',
      'options': ['ម្ជុល', 'កញ្ចក់', 'ទូរទស្សន៍', 'កាមេរ៉ា'],
      'answer': 'ម្ជុល',
      'explanation': 'ម្ជុលមានភ្នែក (រន្ធ) ប៉ុន្តែមិនអាចមើលឃើញ',
      'emoji': '🪡',
    },
    {
      'type': 'quiz',
      'question': 'ពណ៌ទង់ជាតិខ្មែរមានពណ៌អ្វីខ្លះ?',
      'options': ['ក្រហម ខៀវ ស', 'បៃតង លឿង ក្រហម', 'ខៀវ ស ក្រហម', 'ស លឿង ខៀវ'],
      'answer': 'ខៀវ ស ក្រហម',
      'explanation': 'ទង់ជាតិខ្មែរមានពណ៌ខៀវ ស និងក្រហម',
      'emoji': '🇰🇭',
    },
    {
      'type': 'riddle',
      'question': 'អ្វីដែលអ្នកអាចចាប់បាន ប៉ុន្តែមិនអាចបោះចោលបាន?',
      'options': ['ជំងឺ', 'ថ្ម', 'ទឹក', 'ខ្យល់'],
      'answer': 'ជំងឺ',
      'explanation': 'អ្នកអាចចាប់ជំងឺបាន ប៉ុន្តែពិបាកបោះចោល',
      'emoji': '🤒',
    },
    {
      'type': 'quiz',
      'question': 'ទន្លេធំបំផុតនៅកម្ពុជាគឺអ្វី?',
      'options': ['ទន្លេសាប', 'ទន្លេមេគង្គ', 'ទន្លេបាសាក់', 'ទន្លេស្រែពក់'],
      'answer': 'ទន្លេមេគង្គ',
      'explanation': 'ទន្លេមេគង្គគឺជាទន្លេធំបំផុតនៅកម្ពុជា',
      'emoji': '🏞️',
    },
    {
      'type': 'riddle',
      'question': 'អ្វីដែលមានក្បាល ប៉ុន្តែគ្មានខួរក្បាល?',
      'options': ['ដំឡូង', 'ខ្ទុម', 'ត្រី', 'ឈើ'],
      'answer': 'ខ្ទុម',
      'explanation': 'ខ្ទុមមានក្បាល ប៉ុន្តែគ្មានខួរក្បាល',
      'emoji': '🥬',
    },
    {
      'type': 'quiz',
      'question': 'ភាសាផ្លូវការនៃកម្ពុជាគឺអ្វី?',
      'options': ['ភាសាថៃ', 'ភាសាខ្មែរ', 'ភាសាវៀតណាម', 'ភាសាឡាវ'],
      'answer': 'ភាសាខ្មែរ',
      'explanation': 'ភាសាខ្មែរគឺជាភាសាផ្លូវការនៃកម្ពុជា',
      'emoji': '📚',
    },
  ];

  late AnimationController _questionController;
  late AnimationController _celebrationController;

  @override
  void initState() {
    super.initState();
    _questionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _questionController.forward();
    questions.shuffle();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void _checkAnswer(String answer) {
    final correct = questions[currentQuestionIndex]['answer'] as String;

    setState(() {
      selectedAnswer = answer;
      showingAnswer = true;
    });

    if (answer == correct) {
      score += 100;
      correctAnswers++;
      _celebrationController.forward(from: 0);
    }

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        if (currentQuestionIndex < questions.length - 1) {
          setState(() {
            currentQuestionIndex++;
            showingAnswer = false;
            selectedAnswer = null;
          });
          _questionController.forward(from: 0);
        } else {
          _showFinalScore();
        }
      }
    });
  }

  void _showFinalScore() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF667EEA),
                Color(0xFF764BA2),
              ],
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
              FutureBuilder(
                future: ApiService.claimReward(
                  gameName: 'Khmer Quiz',
                  score: score,
                  coins: (score / 100).floor(),
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }
                  if (snapshot.hasError) {
                    return const SizedBox(); // Hide error for cleaner UI
                  }
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('ទទួលបាន: ',
                            style: TextStyle(color: Colors.white)),
                        Text(
                          '+${(score / 100).floor()} កាក់',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ).animate().scale();
                },
              ),
              const SizedBox(height: 10),
              const Text(
                'ចប់ហើយ!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'ពិន្ទុ: $score',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'ឆ្លើយត្រឹមត្រូវ: $correctAnswers/${questions.length}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
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
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('ចេញ'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        currentQuestionIndex = 0;
                        score = 0;
                        correctAnswers = 0;
                        showingAnswer = false;
                        selectedAnswer = null;
                        questions.shuffle();
                      });
                      _questionController.forward(from: 0);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('លេងម្តងទៀត',
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
    final current = questions[currentQuestionIndex];
    final isRiddle = current['type'] == 'riddle';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6366F1), // Indigo
              Color(0xFF8B5CF6), // Violet
              Color(0xFFEC4899), // Pink
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 600;
              final isDesktop = constraints.maxWidth > 900;
              final maxWidth =
                  isDesktop ? 800.0 : (isTablet ? 600.0 : constraints.maxWidth);

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    children: [
                      _buildHeader(isRiddle, isTablet),
                      _buildProgressBar(isTablet),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 32 : 24,
                            vertical: isTablet ? 24 : 16,
                          ),
                          child: Column(
                            children: [
                              _buildQuestionCard(current, isTablet),
                              SizedBox(height: isTablet ? 40 : 32),
                              _buildOptions(current, isTablet),
                              if (showingAnswer) ...[
                                SizedBox(height: isTablet ? 32 : 24),
                                _buildExplanation(current, isTablet),
                              ],
                              SizedBox(height: isTablet ? 40 : 20),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildHeader(bool isRiddle, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 32 : 24,
        vertical: isTablet ? 24 : 16,
      ),
      child: Row(
        children: [
          _build3DIconButton(
            icon: Icons.arrow_back_ios_new,
            onPressed: () => Navigator.pop(context),
            isTablet: isTablet,
          ),
          const Spacer(),
          Column(
            children: [
              Text(
                isRiddle ? '🧠 និទានបណ្តៅ' : '📚 សំណួរចំណេះដឹង',
                style: TextStyle(
                  fontSize: isTablet ? 32 : 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ).animate().shimmer(duration: 2.seconds, delay: 1.seconds),
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20 : 16,
                  vertical: isTablet ? 8 : 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('💎 ', style: TextStyle(fontSize: 16)),
                    Text(
                      '$score',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(width: isTablet ? 60 : 48), // Balance spacing
        ],
      ),
    );
  }

  Widget _build3DIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isTablet,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: isTablet ? 56 : 48,
        height: isTablet ? 56 : 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: Colors.purple.shade900.withOpacity(0.3),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.purple.shade700,
          size: isTablet ? 24 : 20,
        ),
      ),
    );
  }

  Widget _buildProgressBar(bool isTablet) {
    final progress = (currentQuestionIndex + 1) / questions.length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'សំណួរ ${currentQuestionIndex + 1}/${questions.length}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 18 : 14,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 12, vertical: isTablet ? 6 : 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: Colors.greenAccent.withOpacity(0.5)),
                ),
                child: Text(
                  '✅ $correctAnswers',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 16 : 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Container(
            height: isTablet ? 12 : 8,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.amber, Colors.orange],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                )
                    .animate(target: progress)
                    .slideX(duration: 500.ms, curve: Curves.easeOut),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question, bool isTablet) {
    return AnimatedBuilder(
      animation: _questionController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.9 + (_questionController.value * 0.1),
          child: Opacity(
            opacity: _questionController.value,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(isTablet ? 40 : 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(isTablet ? 35 : 25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4C1D95).withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                  const BoxShadow(
                    color: Color(0xFFE5E7EB), // Bottom 3D effect
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      question['emoji'] as String,
                      style: TextStyle(fontSize: isTablet ? 80 : 64),
                    )
                        .animate(
                            onPlay: (controller) =>
                                controller.repeat(reverse: true))
                        .scale(
                            duration: 2.seconds,
                            begin: const Offset(1, 1),
                            end: const Offset(1.1, 1.1))
                        .rotate(duration: 3.seconds, begin: -0.05, end: 0.05),
                  ),
                  SizedBox(height: isTablet ? 32 : 24),
                  Text(
                    question['question'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isTablet ? 28 : 22,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1F2937),
                      height: 1.4,
                      fontFamily: 'Battambang', // Assume Khmer font available
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

  Widget _buildOptions(Map<String, dynamic> question, bool isTablet) {
    final options = question['options'] as List<String>;
    final correctAnswer = question['answer'] as String;

    return Column(
      children: options.map((option) {
        final isSelected = option == selectedAnswer;
        final isCorrect = option == correctAnswer;

        Color getBaseColor() {
          if (!showingAnswer) return Colors.white;
          if (isSelected && isCorrect)
            return const Color(0xFFDCFCE7); // Green-100
          if (isSelected && !isCorrect)
            return const Color(0xFFFEE2E2); // Red-100
          if (isCorrect) return const Color(0xFFDCFCE7);
          return Colors.white;
        }

        Color getBorderColor() {
          if (!showingAnswer) return Colors.transparent;
          if (isSelected && isCorrect) return Colors.green;
          if (isSelected && !isCorrect) return Colors.red;
          if (isCorrect) return Colors.green;
          return Colors.transparent;
        }

        Color getShadowColor() {
          if (isSelected && !showingAnswer)
            return Colors.purple.withOpacity(0.3);
          if (showingAnswer && (isSelected || isCorrect)) {
            return (isCorrect ? Colors.green : Colors.red).withOpacity(0.3);
          }
          return Colors.black.withOpacity(0.05);
        }

        return Padding(
          padding: EdgeInsets.only(bottom: isTablet ? 20 : 16),
          child: GestureDetector(
            onTap: showingAnswer ? null : () => _checkAnswer(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 24,
                vertical: isTablet ? 24 : 18,
              ),
              decoration: BoxDecoration(
                color: getBaseColor(),
                borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
                border: Border.all(
                  color: getBorderColor(),
                  width: isSelected || (showingAnswer && isCorrect) ? 3 : 0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: getShadowColor(),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                  if (!isSelected && !showingAnswer)
                    BoxShadow(
                      color: Colors.grey.shade300,
                      offset: const Offset(0, 6), // 3D effect
                    ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: isTablet ? 40 : 32,
                    height: isTablet ? 40 : 32,
                    decoration: BoxDecoration(
                      color: showingAnswer
                          ? (isCorrect
                              ? Colors.green
                              : (isSelected
                                  ? Colors.red
                                  : Colors.grey.shade200))
                          : Colors.purple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        showingAnswer
                            ? (isCorrect
                                ? Icons.check
                                : (isSelected
                                    ? Icons.close
                                    : Icons.circle_outlined))
                            : Icons.radio_button_unchecked,
                        color: showingAnswer
                            ? Colors.white
                            : Colors.purple.shade300,
                        size: isTablet ? 24 : 20,
                      ),
                    ),
                  ),
                  SizedBox(width: isTablet ? 24 : 16),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: isTablet ? 22 : 18,
                        fontWeight: FontWeight.bold,
                        color: showingAnswer
                            ? (isCorrect
                                ? Colors.green.shade800
                                : (isSelected
                                    ? Colors.red.shade800
                                    : Colors.grey.shade500))
                            : const Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate(
                  target: showingAnswer && (isSelected || isCorrect) ? 1 : 0)
              .scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.02))
              .shake(hz: 3, curve: Curves.easeInOut),
        );
      }).toList(),
    );
  }

  Widget _buildExplanation(Map<String, dynamic> question, bool isTablet) {
    final isCorrect = selectedAnswer == question['answer'];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFFF0FDF4) : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
        border: Border.all(
          color: isCorrect ? Colors.green.shade200 : Colors.orange.shade200,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isCorrect ? Colors.green : Colors.orange).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green : Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCorrect ? Icons.check : Icons.lightbulb,
                  color: Colors.white,
                  size: isTablet ? 24 : 20,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Text(
                isCorrect ? '✅ ត្រឹមត្រូវ!' : '💡 ពន្យល់',
                style: TextStyle(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.w900,
                  color: isCorrect
                      ? Colors.green.shade800
                      : Colors.orange.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Text(
            question['explanation'] as String,
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              color: const Color(0xFF374151),
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack);
  }
}
