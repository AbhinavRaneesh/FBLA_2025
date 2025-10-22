import 'dart:async';
import 'package:flutter/material.dart';
import '../../helpers/database_helper.dart';
import '../../main.dart' show getBackgroundForTheme, GameButton, ThemeColors;

class MemoryMasterModeScreen extends StatefulWidget {
  final String username;
  final String currentTheme;
  final int studySetId;
  final int questionCount;

  const MemoryMasterModeScreen({
    super.key,
    required this.username,
    required this.currentTheme,
    required this.studySetId,
    required this.questionCount,
  });

  @override
  State<MemoryMasterModeScreen> createState() => _MemoryMasterModeScreenState();
}

class _MemoryMasterModeScreenState extends State<MemoryMasterModeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _questions = [];
  int _index = 0;
  bool _memorizePhase = true;
  String? _selected;
  bool _showAnswer = false;
  int _score = 0;
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
    _startMemorizePhase();
  }

  void _startMemorizePhase() {
    setState(() {
      _memorizePhase = true;
      _showAnswer = true; // briefly reveal correct
    });
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _memorizePhase = false;
        _showAnswer = false;
      });
    });
  }

  void _onSelect(String option) {
    if (_memorizePhase || _showAnswer) return;
    final q = _questions[_index];
    final correct = q['correct_answer'] as String;
    setState(() {
      _selected = option;
      _showAnswer = true;
      if (option == correct) _score += 10;
    });
    Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      _answeredCount++;
      if (_answeredCount >= _questions.length) {
        _showCompleted();
      } else {
        setState(() {
          if (_index < _questions.length - 1) {
            _index++;
          }
          _selected = null;
        });
        _startMemorizePhase();
      }
    });
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
                      Text('Memory Master', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Row(children: [
                        const Icon(Icons.score, color: Colors.amber),
                        const SizedBox(width: 6),
                        Text('$_score', style: const TextStyle(color: Colors.white, fontSize: 18)),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _memorizePhase ? 'Memorize the answer...' : 'Choose the correct answer',
                      style: const TextStyle(color: Colors.white70),
                    ),
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
                        onPressed: _memorizePhase ? null : () => _onSelect(opt),
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
