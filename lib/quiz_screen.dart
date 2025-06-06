import 'package:flutter/material.dart';
import 'study_set.dart';
import 'main.dart';

class QuizScreen extends StatefulWidget {
  final StudySet studySet;
  final List<Question> questions;
  final String gameMode;
  final String currentTheme;

  const QuizScreen({
    super.key,
    required this.studySet,
    required this.questions,
    required this.gameMode,
    required this.currentTheme,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _hasAnswered = false;
  String? _selectedAnswer;
  late DateTime _startTime;
  late Duration _timeLimit;
  bool _isTimeUp = false;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _timeLimit = const Duration(minutes: 1);
  }

  void _checkAnswer(String answer) {
    if (_hasAnswered) return;

    setState(() {
      _selectedAnswer = answer;
      _hasAnswered = true;
      if (answer == widget.questions[_currentQuestionIndex].correctAnswer) {
        _score++;
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_currentQuestionIndex < widget.questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _hasAnswered = false;
          _selectedAnswer = null;
        });
      } else {
        _showResults();
      }
    });
  }

  void _showResults() {
    final timeTaken = DateTime.now().difference(_startTime);
    final minutes = timeTaken.inMinutes;
    final seconds = timeTaken.inSeconds % 60;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'Quiz Complete!',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: widget.currentTheme == 'beach'
            ? Colors.orange.withOpacity(0.9)
            : const Color(0xFF1D1E33),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: $_score/${widget.questions.length}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            if (widget.gameMode == 'timed')
              Text(
                'Time: ${minutes}m ${seconds}s',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to study set screen
            },
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.questions[_currentQuestionIndex];
    final timeLeft = _timeLimit - DateTime.now().difference(_startTime);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.studySet.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: widget.currentTheme == 'beach'
            ? Colors.orange
            : const Color(0xFF1D1E33),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          widget.currentTheme == 'beach'
              ? Image.asset(
                  'assets/images/beach.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              : const SpaceBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.gameMode == 'timed')
                    LinearProgressIndicator(
                      value: timeLeft.inSeconds / _timeLimit.inSeconds,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        timeLeft.inSeconds < 10 ? Colors.red : Colors.green,
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    'Question ${_currentQuestionIndex + 1}/${widget.questions.length}',
                    style: TextStyle(
                      fontSize: 18,
                      color: widget.currentTheme == 'beach'
                          ? Colors.black
                          : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentQuestion.questionText,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: widget.currentTheme == 'beach'
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ...currentQuestion.options.map((option) {
                    final isCorrect = option == currentQuestion.correctAnswer;
                    final isSelected = option == _selectedAnswer;
                    Color backgroundColor;
                    if (_hasAnswered) {
                      if (isCorrect) {
                        backgroundColor = Colors.green.withOpacity(0.3);
                      } else if (isSelected) {
                        backgroundColor = Colors.red.withOpacity(0.3);
                      } else {
                        backgroundColor = Colors.grey.withOpacity(0.2);
                      }
                    } else {
                      backgroundColor = Colors.blueAccent.withOpacity(0.2);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ElevatedButton(
                        onPressed:
                            _hasAnswered ? null : () => _checkAnswer(option),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: backgroundColor,
                          padding: const EdgeInsets.all(15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? (isCorrect ? Colors.green : Colors.red)
                                  : Colors.blueAccent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 18,
                            color: widget.currentTheme == 'beach'
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  if (_hasAnswered && currentQuestion.explanation != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blueAccent,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        currentQuestion.explanation!,
                        style: TextStyle(
                          fontSize: 16,
                          color: widget.currentTheme == 'beach'
                              ? Colors.black
                              : Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
