import 'dart:async';
import 'dart:math';
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
  bool _isProcessing = false;

  // Fun upgrades state
  int _streak = 0;
  int _bestStreak = 0;
  bool _doublePointsArmed = false; // doubles next correct
  int _coinsEarned = 0; // session coins

  Map<String, int> _userPowerups = {};
  bool _loadingPowerups = true;
  Set<int> _hiddenOptionIdx = {}; // indices to hide for current question (50/50)
  bool _showChestGlow = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _loadPowerups();
  }

  Future<void> _loadQuestions() async {
    final raw = await _dbHelper.getStudySetQuestions(widget.studySetId);
    final int limit = (widget.questionCount > 0)
        ? (raw.length < widget.questionCount ? raw.length : widget.questionCount)
        : raw.length;
    // Shuffle questions and options for freshness
    final rng = Random();
    final selected = raw.take(limit).toList()..shuffle(rng);
    final withShuffledOptions = selected.map((q) {
      final opts = (q['options'] as String).split('|');
      opts.shuffle(rng);
      return {
        ...q,
        'shuffled_options': opts,
      };
    }).toList();
    if (!mounted) return;
    setState(() {
      _questions = withShuffledOptions;
    });
  }

  Future<void> _loadPowerups() async {
    final p = await _dbHelper.getUserPowerups(widget.username);
    if (!mounted) return;
    setState(() {
      _userPowerups = p;
      _loadingPowerups = false;
    });
  }

  void _onSelect(String option) async {
    final q = _questions[_index];
    final correct = q['correct_answer'] as String;
    final isCorrect = option == correct;
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    if (isCorrect) {
      // Update streak and rewards
      _streak += 1;
      _bestStreak = max(_bestStreak, _streak);
      int reward = 5; // base coins per correct
      // Streak bonus every 3 answers (+5)
      reward += 5 * (_streak ~/ 3);
      if (_doublePointsArmed) {
        reward *= 2;
        _doublePointsArmed = false;
      }
      _coinsEarned += reward;

      // Persist reward to user's total points
      try {
        final current = await _dbHelper.getUserPoints(widget.username);
        await _dbHelper.updateUserPoints(widget.username, current + reward);
      } catch (_) {}

      // Advance
      setState(() {
        _progress++;
        _index = _index + 1; // do not wrap
        _hiddenOptionIdx.clear();
        _showChestGlow = true;
      });
      // brief glow
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) setState(() => _showChestGlow = false);
      });

      if (_progress >= _questions.length) {
        _showTreasure();
      }
    } else {
      // Wrong: reset streak and show feedback
      setState(() {
        _streak = 0;
      });
      _showTryAgain();
    }

    if (mounted) setState(() => _isProcessing = false);
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

  // Powerups
  Future<void> _usePowerup(String id) async {
    if (_loadingPowerups) return;
    switch (id) {
      case 'skip_question':
        if ((_userPowerups['skip_question'] ?? 0) > 0) {
          await _dbHelper.usePowerup(widget.username, 'skip_question');
          setState(() {
            _userPowerups['skip_question'] =
                (_userPowerups['skip_question'] ?? 1) - 1;
          });
          // Treat as correct without reward penalty
          _onSelect(_questions[_index]['correct_answer'] as String);
        }
        break;
      case 'fifty_fifty':
        if ((_userPowerups['fifty_fifty'] ?? 0) > 0) {
          await _dbHelper.usePowerup(widget.username, 'fifty_fifty');
          setState(() {
            _userPowerups['fifty_fifty'] =
                (_userPowerups['fifty_fifty'] ?? 1) - 1;
          });
          _applyFiftyFifty();
        }
        break;
      case 'double_points':
        if ((_userPowerups['double_points'] ?? 0) > 0 && !_doublePointsArmed) {
          await _dbHelper.usePowerup(widget.username, 'double_points');
          setState(() {
            _userPowerups['double_points'] =
                (_userPowerups['double_points'] ?? 1) - 1;
            _doublePointsArmed = true;
          });
          _showBanner('Double points armed for next correct!');
        }
        break;
      case 'hint':
        if ((_userPowerups['hint'] ?? 0) > 0) {
          await _dbHelper.usePowerup(widget.username, 'hint');
          setState(() {
            _userPowerups['hint'] = (_userPowerups['hint'] ?? 1) - 1;
          });
          _showSimpleHint();
        }
        break;
    }
  }

  void _applyFiftyFifty() {
    final opts = List<String>.from(_questions[_index]['shuffled_options']);
    final correct = _questions[_index]['correct_answer'] as String;
    final incorrectIdx = <int>[];
    for (int i = 0; i < opts.length; i++) {
      if (opts[i] != correct) incorrectIdx.add(i);
    }
    incorrectIdx.shuffle();
    // Hide up to two incorrect options but always leave at least 2 total
    final toHide = min(2, max(0, incorrectIdx.length - (opts.length - 2)));
    _hiddenOptionIdx = incorrectIdx.take(toHide).toSet();
    setState(() {});
  }

  void _showSimpleHint() {
    final correct = _questions[_index]['correct_answer'] as String;
    final first = correct.isNotEmpty ? correct.substring(0, 1) : '';
    final last = correct.isNotEmpty ? correct.substring(correct.length - 1) : '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hint'),
        content: Text('The answer starts with "$first" and ends with "$last".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          )
        ],
      ),
    );
  }

  void _showBanner(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
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
  final options = List<String>.from(q['shuffled_options'] as List);

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
                  const SizedBox(height: 8),
                  _buildStatusRow(),
                  const SizedBox(height: 16),
                  Text(
                    q['question_text'] as String,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  for (int i = 0; i < options.length; i++)
                    if (!_hiddenOptionIdx.contains(i))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Opacity(
                          opacity: _isProcessing ? 0.8 : 1,
                          child: GameButton(
                            text: options[i],
                            currentTheme: widget.currentTheme,
                            onPressed: _isProcessing ? null : () => _onSelect(options[i]),
                          ),
                        ),
                      ),

                  const Spacer(),
                  _buildPowerupBar(),
                ],
              ),
            ),
          ),
          if (_showChestGlow)
            IgnorePointer(
              ignoring: true,
              child: Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Colors.amber.withOpacity(0.4), Colors.transparent],
                    ),
                  ),
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
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: active ? 18 : 14,
          height: 14,
          decoration: BoxDecoration(
            color: active ? Colors.amber : Colors.white24,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: Colors.white38, width: 1),
          ),
        );
      }),
    );
  }

  Widget _buildStatusRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 18),
              const SizedBox(width: 6),
              Text('Streak: $_streak', style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.diamond, color: Colors.amber, size: 18),
              const SizedBox(width: 6),
              Text('+$_coinsEarned', style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
        const Spacer(),
        if (_doublePointsArmed)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.amber, Colors.orange]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(Icons.star, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text('x2 next', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPowerupBar() {
    final textStyle = const TextStyle(color: Colors.white);
    Widget buildChip({required IconData icon, required String id, required String label}) {
      final count = _userPowerups[id] ?? 0;
      final enabled = count > 0 && !_isProcessing;
      return Opacity(
        opacity: enabled ? 1 : 0.5,
        child: InkWell(
          onTap: enabled ? () => _usePowerup(id) : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text('$label ($count)', style: textStyle),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildChip(icon: Icons.skip_next, id: 'skip_question', label: 'Skip'),
            buildChip(icon: Icons.filter_2, id: 'fifty_fifty', label: '50/50'),
            buildChip(icon: Icons.star, id: 'double_points', label: 'x2'),
            buildChip(icon: Icons.lightbulb, id: 'hint', label: 'Hint'),
          ],
        ),
      ],
    );
  }
}
