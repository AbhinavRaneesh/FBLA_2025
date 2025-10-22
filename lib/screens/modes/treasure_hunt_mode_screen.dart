import 'dart:async';
import 'package:flutter/material.dart';
import '../../helpers/database_helper.dart';
import '../../main.dart' show getBackgroundForTheme, GameButton;

class TreasureHuntModeScreen extends StatefulWidget {
  final String username;
  final String currentTheme;
  final int studySetId;
  final int questionCount;

  const TreasureHuntModeScreen({
    super.key,
    required this.username,
    required this.currentTheme,
    required this.studySetId,
    required this.questionCount,
  });

  @override
  State<TreasureHuntModeScreen> createState() => _TreasureHuntModeScreenState();
}

class _TreasureHuntModeScreenState extends State<TreasureHuntModeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _questions = [];
  int _index = 0;
  int _progress = 0;

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
    final q = _questions[_index];
    final correct = q['correct_answer'] as String;
    final isCorrect = option == correct;
    if (isCorrect) {
      setState(() {
        _progress++;
        _index = (_index + 1) % _questions.length;
      });
      if (_progress >= _questions.length) {
        _showTreasure();
      }
    } else {
      _showTryAgain();
    }
  }

  void _showTreasure() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Treasure Found!'),
        content: const Text('You completed the hunt!'),
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

  void _showTryAgain() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wrong turn! Try another path.')),
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
                      const Text('Treasure Hunt', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      _buildProgressBar(),
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
                        onPressed: () => _onSelect(opt),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final total = _questions.length;
    return Row(
      children: List.generate(total, (i) {
        final active = i < _progress;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: active ? Colors.amber : Colors.white24,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white38, width: 1),
          ),
        );
      }),
    );
  }
}
