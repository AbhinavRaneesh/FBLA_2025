import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/questions.dart';
import '../../helpers/database_helper.dart';

// Theme Colors Helper
class ThemeColors {
  static Color getPrimaryColor(String theme) {
    switch (theme) {
      case 'beach':
        return const Color(0xFF4DD0E1);
      default:
        return const Color(0xFF4facfe);
    }
  }

  static Color getTextColor(String theme) {
    switch (theme) {
      case 'beach':
        return const Color(0xFF2E2E2E);
      default:
        return Colors.white;
    }
  }

  static LinearGradient getBeachCardGradient() {
    return const LinearGradient(
      colors: [Color(0xFFF5F5DC), Color(0xFFE6E6DC)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static List<Color> getBeachGradient1() {
    return [const Color(0xFF4DD0E1), const Color(0xFF26C6DA)];
  }

  static List<Color> getBeachGradient2() {
    return [const Color(0xFF4CAF50), const Color(0xFF2E7D32)];
  }

  static List<Color> getBeachGradient3() {
    return [const Color(0xFFFF8A65), const Color(0xFFFF7043)];
  }
}

class SpaceBackground extends StatelessWidget {
  const SpaceBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A0E21), Color(0xFF1D1E33)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Twinkling stars
          for (int i = 0; i < 50; i++)
            Positioned(
              left: (i * 37) % MediaQuery.of(context).size.width,
              top: (i * 91) % MediaQuery.of(context).size.height,
              child: Container(
                width: 2,
                height: 2,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class BeachBackground extends StatelessWidget {
  const BeachBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/beach.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        // Optional overlay for better text readability
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}

// Theme helper function
Widget getBackgroundForTheme(String theme) {
  switch (theme) {
    case 'beach':
      return const BeachBackground();
    case 'space':
    default:
      return const SpaceBackground();
  }
}

class LightningModeScreen extends StatefulWidget {
  final List<Question> questions;
  final String currentTheme;
  final Map<String, int> userPowerups;

  const LightningModeScreen({
    Key? key,
    required this.questions,
    required this.currentTheme,
    required this.userPowerups,
  }) : super(key: key);

  @override
  State<LightningModeScreen> createState() => _LightningModeScreenState();
}

class _LightningModeScreenState extends State<LightningModeScreen>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  String? _selectedAnswer;
  bool _showAnswer = false;
  bool _showScoreSummary = false;
  bool _showChat = false;
  int _currentPoints = 0;

  // Lightning Mode Specific
  Timer? _timer;
  int _timeLeft = 30; // 30 seconds per question
  bool _timeUp = false;
  late AnimationController _timerAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;

  // Powerups
  Map<String, int> _userPowerups = {};
  bool _skipUsed = false;
  bool _fiftyFiftyUsed = false;
  bool _doublePointsActive = false;
  bool _extraTimeUsed = false;
  List<String> _removedOptions = [];

  // Streak and Combo
  int _currentStreak = 0;
  int _maxStreak = 0;
  bool _isOnFire = false; // 3+ streak

  @override
  void initState() {
    super.initState();
    _userPowerups = Map.from(widget.userPowerups);
    _timerAnimationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timeLeft =
        _extraTimeUsed ? 45 : 30; // Extra time powerup gives 15 more seconds
    _timeUp = false;
    _timerAnimationController.reset();
    _timerAnimationController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timeUp = true;
          _handleTimeUp();
        }
      });
    });
  }

  void _handleTimeUp() {
    _timer?.cancel();
    HapticFeedback.heavyImpact();
    _currentStreak = 0;
    _isOnFire = false;

    setState(() {
      _showAnswer = true;
    });

    // Don't auto-advance - wait for user to click next button
  }

  void _checkAnswer(String answer) {
    if (_showAnswer || _timeUp) return;

    _timer?.cancel();
    HapticFeedback.selectionClick();

    setState(() {
      _selectedAnswer = answer;
      _showAnswer = true;
    });

    final isCorrect =
        answer == widget.questions[_currentQuestionIndex].correctAnswer;

    if (isCorrect) {
      _currentStreak++;
      _maxStreak = max(_maxStreak, _currentStreak);

      // Calculate points with time bonus and streak multiplier
      int basePoints = 10;
      int timeBonus =
          (_timeLeft * 0.5).round(); // 0.5 points per second remaining
      int streakMultiplier = _currentStreak >= 3 ? 2 : 1;
      if (_doublePointsActive) streakMultiplier *= 2;

      int earnedPoints = (basePoints + timeBonus) * streakMultiplier;
      _currentPoints += earnedPoints;
      _correctAnswers++;

      // Check for fire streak
      if (_currentStreak >= 3 && !_isOnFire) {
        _isOnFire = true;
        _pulseAnimationController.repeat(reverse: true);
      }

      HapticFeedback.mediumImpact();
    } else {
      _currentStreak = 0;
      _isOnFire = false;
      _pulseAnimationController.stop();
      _pulseAnimationController.reset();
      HapticFeedback.heavyImpact();
    }

    // Reset powerup states for next question
    _doublePointsActive = false;
    _extraTimeUsed = false;
    _removedOptions.clear();

    // Don't auto-advance - wait for user to click next button
  }

  void _continueToNext() {
    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _showAnswer = false;
        _showChat = false;
        _skipUsed = false;
        _fiftyFiftyUsed = false;
      });
      _startTimer();
    } else {
      _showFinalScore();
    }
  }

  void _showFinalScore() {
    _timer?.cancel();
    setState(() {
      _showScoreSummary = true;
    });
    _saveScore();
  }

  void _saveScore() async {
    // TODO: Implement score saving to database
    // For now, we just track the score in memory
    print(
        'Lightning Mode Score: $_correctAnswers/${widget.questions.length} - $_currentPoints points');
  }

  void _usePowerup(String powerupId) {
    if ((_userPowerups[powerupId] ?? 0) <= 0 || _showAnswer) return;

    setState(() {
      _userPowerups[powerupId] = (_userPowerups[powerupId] ?? 0) - 1;
    });

    switch (powerupId) {
      case 'skip_question':
        _skipUsed = true;
        _timer?.cancel();
        Future.delayed(const Duration(milliseconds: 500), () {
          _continueToNext();
        });
        break;
      case 'fifty_fifty':
        _fiftyFiftyUsed = true;
        _remove50Percent();
        break;
      case 'double_points':
        _doublePointsActive = true;
        break;
      case 'extra_time':
        if (!_extraTimeUsed) {
          _extraTimeUsed = true;
          _timeLeft += 15;
          if (_timeLeft > 45) _timeLeft = 45;
        }
        break;
      case 'hint':
        _showChat = true;
        break;
    }
  }

  void _remove50Percent() {
    final currentQuestion = widget.questions[_currentQuestionIndex];
    final incorrectOptions = currentQuestion.options
        .where((option) => option != currentQuestion.correctAnswer)
        .toList();

    incorrectOptions.shuffle();
    _removedOptions = incorrectOptions.take(2).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: getBackgroundForTheme(widget.currentTheme),
            ),
            SafeArea(
              child: _showScoreSummary
                  ? _buildScoreSummary()
                  : _buildQuizContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreSummary() {
    final accuracy = widget.questions.isNotEmpty
        ? (_correctAnswers / widget.questions.length * 100).round()
        : 0;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: widget.currentTheme == 'beach'
              ? ThemeColors.getBeachCardGradient()
              : const LinearGradient(
                  colors: [Color(0xFF2A2D3E), Color(0xFF1D1E33)],
                ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lightning Mode Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: ThemeColors.getBeachGradient3(),
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.flash_on,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Lightning Round Complete!',
              style: TextStyle(
                color: widget.currentTheme == 'beach'
                    ? ThemeColors.getTextColor('beach')
                    : Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('Score',
                    '$_correctAnswers/${widget.questions.length}', Icons.quiz),
                _buildStatCard('Accuracy', '$accuracy%', Icons.track_changes),
                _buildStatCard(
                    'Max Streak', '$_maxStreak', Icons.local_fire_department),
              ],
            ),

            const SizedBox(height: 20),

            // Points Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.amber, Colors.orange],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.diamond, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    '$_currentPoints Points',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Play Again',
                    Icons.refresh,
                    ThemeColors.getBeachGradient1(),
                    () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => LightningModeScreen(
                            questions: widget.questions,
                            currentTheme: widget.currentTheme,
                            userPowerups: widget.userPowerups,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    'Home',
                    Icons.home,
                    ThemeColors.getBeachGradient2(),
                    () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.currentTheme == 'beach'
            ? Colors.white.withOpacity(0.9)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: widget.currentTheme == 'beach'
                ? ThemeColors.getPrimaryColor('beach')
                : Colors.white,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: widget.currentTheme == 'beach'
                  ? ThemeColors.getTextColor('beach')
                  : Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: widget.currentTheme == 'beach'
                  ? ThemeColors.getTextColor('beach').withOpacity(0.7)
                  : Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon,
      List<Color> gradientColors, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildQuizContent() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: _buildQuestionArea(),
          ),
        ),
        _buildPowerupBar(),
      ],
    );
  }

  Widget _buildQuestionArea() {
    final question = widget.questions[_currentQuestionIndex];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header with progress and timer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Back button with fixed width
              SizedBox(
                width: 48,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              // Centered question counter
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF667eea).withOpacity(0.8),
                          const Color(0xFF764ba2).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.2), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF667eea).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Text(
                      'Question ${_currentQuestionIndex + 1}/${widget.questions.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
              // Streak and Points display
              Column(
                children: [
                  if (_isOnFire)
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [Colors.orange, Colors.red]),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.local_fire_department,
                                    color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '$_currentStreak',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 4),
                  Container(
                    constraints:
                        const BoxConstraints(minWidth: 70, maxWidth: 100),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFF8F00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.diamond,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '$_currentPoints',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Timer
        _buildTimer(),

        const SizedBox(height: 20),

        // Question Card
        _buildQuestionCard(question),

        const SizedBox(height: 24),

        // Answer Options
        ...question.options
            .asMap()
            .entries
            .where((e) => !_removedOptions.contains(e.value))
            .map((e) {
          final option = e.value;
          final isSelected = _selectedAnswer == option;
          final isCorrect = _showAnswer && option == question.correctAnswer;
          final isWrong = _showAnswer && isSelected && !isCorrect;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: isCorrect
                    ? LinearGradient(
                        colors: widget.currentTheme == 'beach'
                            ? ThemeColors.getBeachGradient2()
                            : [
                                const Color(0xFF43e97b),
                                const Color(0xFF38f9d7)
                              ])
                    : isWrong
                        ? LinearGradient(
                            colors: widget.currentTheme == 'beach'
                                ? ThemeColors.getBeachGradient3()
                                : [
                                    const Color(0xFFf5576c),
                                    const Color(0xFFf093fb)
                                  ])
                        : isSelected
                            ? LinearGradient(
                                colors: widget.currentTheme == 'beach'
                                    ? ThemeColors.getBeachGradient1()
                                    : [
                                        const Color(0xFF4facfe),
                                        const Color(0xFF00f2fe)
                                      ])
                            : widget.currentTheme == 'beach'
                                ? ThemeColors.getBeachCardGradient()
                                : const LinearGradient(colors: [
                                    Color(0xFF23243a),
                                    Color(0xFF23243a)
                                  ]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF4facfe).withOpacity(0.18),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
                border: Border.all(
                  color: isCorrect
                      ? Colors.greenAccent.withOpacity(0.7)
                      : isWrong
                          ? Colors.redAccent.withOpacity(0.7)
                          : Colors.white.withOpacity(0.08),
                  width: 2,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _showAnswer ? null : () => _checkAnswer(option),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    child: Center(
                      child: Text(
                        option,
                        style: TextStyle(
                          color: (isCorrect || isWrong || isSelected)
                              ? Colors.white
                              : widget.currentTheme == 'beach'
                                  ? ThemeColors.getTextColor('beach')
                                  : Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),

        if (_showAnswer) ...[
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: widget.currentTheme == 'beach'
                    ? LinearGradient(
                        colors: ThemeColors.getBeachGradient1(),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4facfe).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _continueToNext,
                icon: Icon(
                  _currentQuestionIndex < widget.questions.length - 1
                      ? Icons.arrow_forward_rounded
                      : Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  _currentQuestionIndex < widget.questions.length - 1
                      ? 'Next Question'
                      : 'Finish',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTimer() {
    final progress = _timeLeft / 30.0;
    Color timerColor = _timeLeft > 10
        ? Colors.green
        : _timeLeft > 5
            ? Colors.orange
            : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: widget.currentTheme == 'beach'
              ? ThemeColors.getBeachCardGradient()
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05)
                  ],
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: timerColor.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: timerColor.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      color: timerColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Time Left',
                      style: TextStyle(
                        color: widget.currentTheme == 'beach'
                            ? ThemeColors.getTextColor('beach')
                            : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${_timeLeft}s',
                  style: TextStyle(
                    color: timerColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Question question) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double minHeight = MediaQuery.of(context).size.height * 0.12;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          constraints: BoxConstraints(minHeight: minHeight),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4facfe).withOpacity(0.22),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.13),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              gradient: widget.currentTheme == 'beach'
                  ? ThemeColors.getBeachCardGradient()
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF2A2D3E),
                        const Color(0xFF1D1E33),
                        const Color(0xFF16213E).withOpacity(0.9),
                      ],
                    ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.10),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                question.questionText,
                style: TextStyle(
                  color: widget.currentTheme == 'beach'
                      ? ThemeColors.getTextColor('beach')
                      : Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPowerupBar() {
    List<Widget> powerupButtons = [
      _buildPowerupButton('skip_question', Icons.skip_next, 'Skip',
          const Color(0xFF4CAF50), _skipUsed),
      _buildPowerupButton('fifty_fifty', Icons.filter_2, '50/50',
          const Color(0xFF2196F3), _fiftyFiftyUsed),
      _buildPowerupButton('double_points', Icons.star, '2x Points',
          const Color(0xFFFFD700), _doublePointsActive),
      _buildPowerupButton('extra_time', Icons.access_time, '+15s',
          const Color(0xFFFF9800), _extraTimeUsed),
    ];

    return Container(
      height: 70,
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A2D3E), Color(0xFF1D1E33)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: powerupButtons,
      ),
    );
  }

  Widget _buildPowerupButton(
      String powerupId, IconData icon, String label, Color color, bool used) {
    final count = _userPowerups[powerupId] ?? 0;
    final canUse = count > 0 && !used && !_showAnswer;

    return GestureDetector(
      onTap: canUse ? () => _usePowerup(powerupId) : null,
      child: Container(
        width: 60,
        height: 58,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          gradient: canUse
              ? LinearGradient(colors: [color, color.withOpacity(0.8)])
              : LinearGradient(
                  colors: [Colors.grey.shade700, Colors.grey.shade800]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: canUse ? color.withOpacity(0.6) : Colors.grey.shade600,
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (count > 0)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)]),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      '$count',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            if (used)
              Container(
                width: 60,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child:
                      Icon(Icons.check_circle, color: Colors.white, size: 24),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
