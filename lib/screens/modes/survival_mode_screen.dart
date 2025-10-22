import 'dart:async';
import 'package:flutter/material.dart';
import '../../helpers/database_helper.dart';
import '../../data/questions.dart' as quiz;
import '../../main.dart' show getBackgroundForTheme, ThemeColors, GameButton;

class SurvivalModeScreen extends StatefulWidget {
  final String username;
  final String currentTheme;
  final int studySetId;
  final int questionCount;

  const SurvivalModeScreen({
    super.key,
    required this.username,
    required this.currentTheme,
    required this.studySetId,
    required this.questionCount,
  });

  @override
  State<SurvivalModeScreen> createState() => _SurvivalModeScreenState();
}

class _SurvivalModeScreenState extends State<SurvivalModeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _questions = [];
  int _index = 0;
  int _lives = 3;
  int _score = 0;
  String? _selected;
  bool _showAnswer = false;
  int _answeredCount = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final raw = await _dbHelper.getStudySetQuestions(widget.studySetId);
    final int limit = (widget.questionCount > 0)
        ? (raw.length < widget.questionCount ? raw.length : widget.questionCount)
        : raw.length;
    setState(() {
      _questions = raw.take(limit).toList();
    });
  }

  void _onSelect(String option) {
    if (_showAnswer) return;
    setState(() {
      _selected = option;
      _showAnswer = true;
    });
    final correct = _questions[_index]['correct_answer'] as String;
    final isCorrect = option == correct;
    if (isCorrect) {
      _score += 10;
    } else {
      _lives -= 1;
    }
    Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      _answeredCount++;
      if (_lives <= 0) {
        _showGameOver();
      } else if (_answeredCount >= _questions.length) {
        _showCompleted();
      } else {
        setState(() {
          if (_index < _questions.length - 1) {
            _index++;
          }
          _selected = null;
          _showAnswer = false;
        });
      }
    });
  }

  void _showGameOver() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Score: $_score'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Close')),
        ],
      ),
    );
  }

  void _showCompleted() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('All done!'),
        content: Text('You completed ${_questions.length} questions.\nScore: $_score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        body: Stack(children: [
          getBackgroundForTheme(widget.currentTheme),
          const Center(child: CircularProgressIndicator()),
        ]),
      );
    }

    final q = _questions[_index];
    final options = (q['options'] as String).split('|');
    final correct = q['correct_answer'] as String;

    return Scaffold(
      body: Stack(
        children: [
          getBackgroundForTheme(widget.currentTheme),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Icon(Icons.favorite, color: Colors.red),
                        const SizedBox(width: 6),
                        Text('$_lives', style: const TextStyle(color: Colors.white, fontSize: 18)),
                      ]),
                      Row(children: [
                        const Icon(Icons.score, color: Colors.amber),
                        const SizedBox(width: 6),
                        Text('$_score', style: const TextStyle(color: Colors.white, fontSize: 18)),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    q['question_text'] as String,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  for (final opt in options)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: GameButton(
                        text: opt,
                        currentTheme: widget.currentTheme,
                        isSelected: _selected == opt,
                        isCorrect: _showAnswer ? (opt == correct) : null,
                        onPressed: () => _onSelect(opt),
                      ),
                    ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
