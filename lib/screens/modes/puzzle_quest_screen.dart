import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/questions.dart';

class PuzzleQuestScreen extends StatefulWidget {
  final List<Question> questions;
  final String currentTheme;
  final Map<String, int> userPowerups;

  const PuzzleQuestScreen({
    Key? key,
    required this.questions,
    required this.currentTheme,
    required this.userPowerups,
  }) : super(key: key);

  @override
  State<PuzzleQuestScreen> createState() => _PuzzleQuestScreenState();
}

class _PuzzleQuestScreenState extends State<PuzzleQuestScreen>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  String? _selectedAnswer;
  bool _showAnswer = false;
  bool _showScoreSummary = false;
  bool _puzzleSolved = false;
  int _currentPoints = 0;

  // Puzzle specific
  String _currentPuzzle = '';
  String _puzzleAnswer = '';
  List<String> _puzzlePieces = [];
  List<bool> _piecePositions = [];
  List<String> _builtWord = [];
  List<String> _availableLetters = [];

  // Animations
  late AnimationController _puzzleAnimationController;
  late AnimationController _revealAnimationController;
  late Animation<double> _puzzleAnimation;
  late Animation<double> _revealAnimation;

  // Powerups
  Map<String, int> _userPowerups = {};
  bool _skipUsed = false;
  bool _fiftyFiftyUsed = false;
  bool _doublePointsActive = false;
  List<String> _removedOptions = [];

  @override
  void initState() {
    super.initState();
    _userPowerups = Map.from(widget.userPowerups);

    _puzzleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _revealAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _puzzleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _puzzleAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _revealAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _generatePuzzle();
  }

  @override
  void dispose() {
    _puzzleAnimationController.dispose();
    _revealAnimationController.dispose();
    super.dispose();
  }

  void _generatePuzzle() {
    final question = widget.questions[_currentQuestionIndex];

    // Generate educational puzzles based on question content
    final puzzleTypes = [
      'concept_builder',
      'word_association',
      'definition_match',
      'fill_blanks',
      'concept_map'
    ];

    final puzzleType = puzzleTypes[_currentQuestionIndex % puzzleTypes.length];

    switch (puzzleType) {
      case 'concept_builder':
        _generateConceptBuilder(question);
        break;
      case 'word_association':
        _generateWordAssociation(question);
        break;
      case 'definition_match':
        _generateDefinitionMatch(question);
        break;
      case 'fill_blanks':
        _generateFillBlanks(question);
        break;
      case 'concept_map':
        _generateConceptMap(question);
        break;
    }

    _puzzleAnimationController.forward();
  }

  void _generateConceptBuilder(Question question) {
    // Extract key terms from the question and correct answer
    final keyTerms = _extractKeyTerms(question);
    final targetConcept =
        keyTerms.isNotEmpty ? keyTerms.first : question.correctAnswer;

    _puzzleAnswer = targetConcept.toUpperCase();
    final letters = _puzzleAnswer.split('');
    letters.shuffle();
    _puzzlePieces = letters;
    _availableLetters = List.from(letters);
    _builtWord = [];
    _piecePositions = List.filled(letters.length, false);

    _currentPuzzle =
        "Build the key concept from this question by unscrambling the letters:";
  }

  List<String> _extractKeyTerms(Question question) {
    // Extract important terms from question text and correct answer
    final allText = '${question.questionText} ${question.correctAnswer}';
    final words = allText
        .split(RegExp(r'[^\w]+'))
        .where((word) => word.length > 4 && !_isCommonWord(word))
        .toList();
    return words.take(3).toList();
  }

  bool _isCommonWord(String word) {
    final commonWords = {
      'what',
      'which',
      'when',
      'where',
      'this',
      'that',
      'with',
      'from',
      'they',
      'have',
      'will',
      'been',
      'said',
      'each',
      'their'
    };
    return commonWords.contains(word.toLowerCase());
  }

  void _generateWordAssociation(Question question) {
    // Create word association puzzle using question content
    final keyWords = _extractKeyTerms(question);
    final correctAnswer = question.correctAnswer;

    _currentPuzzle =
        "Which concept is most associated with: ${question.questionText.split('?')[0]}?";
    _puzzleAnswer = correctAnswer;
    _puzzlePieces = [];
    _availableLetters = [];
    _builtWord = [];
    _piecePositions = [];
  }

  void _generateDefinitionMatch(Question question) {
    // Create a definition matching puzzle
    final definitionHint = _extractDefinitionFromQuestion(question);

    _currentPuzzle = "Match the definition: $definitionHint";
    _puzzleAnswer = question.correctAnswer;
    _puzzlePieces = [];
    _availableLetters = [];
    _builtWord = [];
    _piecePositions = [];
  }

  void _generateFillBlanks(Question question) {
    // Create fill-in-the-blanks from question text
    final questionText = question.questionText;
    final correctAnswer = question.correctAnswer;

    // Remove key words to create blanks
    String puzzleText = questionText;
    final keyTerms = _extractKeyTerms(question);

    for (final term in keyTerms.take(1)) {
      puzzleText =
          puzzleText.replaceAll(RegExp(term, caseSensitive: false), '____');
    }

    _currentPuzzle = "Fill in the blank: $puzzleText";
    _puzzleAnswer =
        keyTerms.isNotEmpty ? keyTerms.first.toUpperCase() : correctAnswer;
    _puzzlePieces = [];
    _availableLetters = [];
    _builtWord = [];
    _piecePositions = [];
  }

  void _generateConceptMap(Question question) {
    // Create concept mapping puzzle
    final concepts = question.options.take(3).toList();
    concepts.shuffle();

    _currentPuzzle = "Which concept best answers: ${question.questionText}";
    _puzzleAnswer = question.correctAnswer;
    _puzzlePieces = [];
    _availableLetters = [];
    _builtWord = [];
    _piecePositions = [];
  }

  String _extractDefinitionFromQuestion(Question question) {
    final questionText = question.questionText.toLowerCase();
    if (questionText.contains('what is') || questionText.contains('define')) {
      return "This concept is described in the question above";
    } else if (questionText.contains('which') ||
        questionText.contains('select')) {
      return "Choose the correct option for the given scenario";
    } else {
      return "Based on the question context, identify the key concept";
    }
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
              child: _getBackgroundForTheme(widget.currentTheme),
            ),
            SafeArea(
              child: _showScoreSummary
                  ? _buildScoreSummary()
                  : !_puzzleSolved
                      ? _buildPuzzleScreen()
                      : _buildQuestionScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getBackgroundForTheme(String theme) {
    if (theme == 'beach') {
      return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/beach.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
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

  Widget _buildPuzzleScreen() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildPuzzleCard(),
                const SizedBox(height: 18),
                Expanded(
                  child: _buildPuzzleInterface(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.currentTheme == 'beach'
                        ? [const Color(0xFF4DD0E1), const Color(0xFF26C6DA)]
                        : [const Color(0xFF667eea), const Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667eea).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  'Puzzle ${_currentQuestionIndex + 1}/${widget.questions.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFF8F00)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.diamond, color: Colors.white, size: 14),
                const SizedBox(width: 3),
                Text(
                  '$_currentPoints',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPuzzleCard() {
    return AnimatedBuilder(
      animation: _puzzleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _puzzleAnimation.value,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: widget.currentTheme == 'beach'
                  ? LinearGradient(
                      colors: [
                        const Color(0xFFF5F5DC).withOpacity(0.95),
                        const Color(0xFFE6D3A3).withOpacity(0.9),
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        const Color(0xFF2A2D3E),
                        const Color(0xFF1D1E33),
                        const Color(0xFF16213E).withOpacity(0.9),
                      ],
                    ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4facfe).withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.extension,
                  size: 36,
                  color: widget.currentTheme == 'beach'
                      ? const Color(0xFF4DD0E1)
                      : Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Learning Challenge',
                        style: TextStyle(
                          color: widget.currentTheme == 'beach'
                              ? const Color(0xFF2E2E2E)
                              : Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentPuzzle,
                        style: TextStyle(
                          color: widget.currentTheme == 'beach'
                              ? const Color(0xFF2E2E2E).withOpacity(0.8)
                              : Colors.white.withOpacity(0.9),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPuzzleInterface() {
    if (_puzzlePieces.isNotEmpty) {
      return _buildWordScrambleInterface();
    } else {
      return _buildTextInputInterface();
    }
  }

  Widget _buildWordScrambleInterface() {
    final question = widget.questions[_currentQuestionIndex];

    return Column(
      children: [
        // Compact Learning Context
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: widget.currentTheme == 'beach'
                ? const Color(0xFF4DD0E1).withOpacity(0.15)
                : const Color(0xFF4facfe).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.school,
                color: widget.currentTheme == 'beach'
                    ? const Color(0xFF4DD0E1)
                    : const Color(0xFF4facfe),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question.questionText,
                  style: TextStyle(
                    color: widget.currentTheme == 'beach'
                        ? const Color(0xFF2E2E2E).withOpacity(0.8)
                        : Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Text(
          'Drag letters to build the concept:',
          style: TextStyle(
            color: widget.currentTheme == 'beach'
                ? const Color(0xFF2E2E2E)
                : Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableLetters.map((letter) {
            return Draggable<String>(
              data: letter,
              feedback: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              childWhenDragging: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: widget.currentTheme == 'beach'
                      ? LinearGradient(colors: [
                          const Color(0xFF4DD0E1),
                          const Color(0xFF26C6DA)
                        ])
                      : LinearGradient(colors: [
                          const Color(0xFF4facfe),
                          const Color(0xFF00f2fe)
                        ]),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        // Built word display area
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: widget.currentTheme == 'beach'
                ? Colors.white.withOpacity(0.9)
                : Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _builtWord.isNotEmpty
                  ? (widget.currentTheme == 'beach'
                      ? const Color(0xFF4DD0E1)
                      : const Color(0xFF4facfe))
                  : Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Word:',
                    style: TextStyle(
                      color: widget.currentTheme == 'beach'
                          ? const Color(0xFF2E2E2E)
                          : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_builtWord.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _availableLetters = List.from(_puzzlePieces);
                          _builtWord = [];
                        });
                      },
                      icon: const Icon(Icons.refresh, size: 14),
                      label: const Text('Clear'),
                      style: TextButton.styleFrom(
                        foregroundColor: widget.currentTheme == 'beach'
                            ? const Color(0xFF4DD0E1)
                            : const Color(0xFF4facfe),
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        textStyle: const TextStyle(fontSize: 10),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_builtWord.isEmpty)
                    Text(
                      '_ ' * _puzzleAnswer.length,
                      style: TextStyle(
                        color: widget.currentTheme == 'beach'
                            ? const Color(0xFF2E2E2E).withOpacity(0.5)
                            : Colors.white.withOpacity(0.5),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    )
                  else
                    ..._builtWord
                        .map((letter) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  gradient: widget.currentTheme == 'beach'
                                      ? LinearGradient(colors: [
                                          const Color(0xFF4DD0E1),
                                          const Color(0xFF26C6DA)
                                        ])
                                      : LinearGradient(colors: [
                                          const Color(0xFF4facfe),
                                          const Color(0xFF00f2fe)
                                        ]),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    letter,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                ],
              ),
            ],
          ),
        ),

        DragTarget<String>(
          onAccept: (data) => _checkWordScramble(data),
          builder: (context, candidateData, rejectedData) {
            return Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                border: Border.all(
                  color: candidateData.isNotEmpty
                      ? Colors.green
                      : (widget.currentTheme == 'beach'
                          ? const Color(0xFF4DD0E1).withOpacity(0.5)
                          : Colors.white.withOpacity(0.5)),
                  width: 1,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12),
                color: candidateData.isNotEmpty
                    ? Colors.green.withOpacity(0.2)
                    : Colors.transparent,
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      candidateData.isNotEmpty
                          ? Icons.add_circle
                          : Icons.touch_app,
                      color: candidateData.isNotEmpty
                          ? Colors.green
                          : (widget.currentTheme == 'beach'
                              ? const Color(0xFF4DD0E1)
                              : Colors.white),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      candidateData.isNotEmpty
                          ? 'Drop to add!'
                          : 'Drag letters here',
                      style: TextStyle(
                        color: candidateData.isNotEmpty
                            ? Colors.green
                            : (widget.currentTheme == 'beach'
                                ? const Color(0xFF2E2E2E)
                                : Colors.white),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTextInputInterface() {
    final TextEditingController controller = TextEditingController();
    final question = widget.questions[_currentQuestionIndex];

    return Column(
      children: [
        // Compact Learning Hint
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: widget.currentTheme == 'beach'
                ? const Color(0xFF4DD0E1).withOpacity(0.15)
                : const Color(0xFF4facfe).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: widget.currentTheme == 'beach'
                    ? const Color(0xFF4DD0E1)
                    : const Color(0xFF4facfe),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Context: ${question.questionText}',
                  style: TextStyle(
                    color: widget.currentTheme == 'beach'
                        ? const Color(0xFF2E2E2E).withOpacity(0.8)
                        : Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: widget.currentTheme == 'beach'
                ? Colors.white.withOpacity(0.9)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(
              color: widget.currentTheme == 'beach'
                  ? const Color(0xFF2E2E2E)
                  : Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'Type your answer here...',
              hintStyle: TextStyle(
                color: widget.currentTheme == 'beach'
                    ? const Color(0xFF2E2E2E).withOpacity(0.6)
                    : Colors.white.withOpacity(0.6),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: Icon(
                Icons.edit,
                color: widget.currentTheme == 'beach'
                    ? const Color(0xFF4DD0E1)
                    : const Color(0xFF4facfe),
                size: 20,
              ),
            ),
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.characters,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: widget.currentTheme == 'beach'
                ? LinearGradient(
                    colors: [const Color(0xFF4CAF50), const Color(0xFF2E7D32)])
                : LinearGradient(
                    colors: [const Color(0xFF4facfe), const Color(0xFF00f2fe)]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4facfe).withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () => _checkTextAnswer(controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.send, color: Colors.white, size: 18),
            label: const Text(
              'Submit Answer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _checkWordScramble(String letter) {
    HapticFeedback.lightImpact();

    setState(() {
      // Add letter to built word
      _builtWord.add(letter);

      // Remove letter from available letters (only remove the first occurrence)
      final index = _availableLetters.indexOf(letter);
      if (index != -1) {
        _availableLetters.removeAt(index);
      }
    });

    // Check if word is complete and correct
    if (_builtWord.length == _puzzleAnswer.length) {
      final builtWordString = _builtWord.join('');
      if (builtWordString.toUpperCase() == _puzzleAnswer.toUpperCase()) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _solvePuzzle();
        });
      } else {
        // Word is wrong, give feedback and reset
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Not quite right! Try again.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );

        // Reset after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            _availableLetters = List.from(_puzzlePieces);
            _builtWord = [];
          });
        });
      }
    }
  }

  void _checkTextAnswer(String answer) {
    if (answer.trim().toUpperCase() == _puzzleAnswer.toUpperCase()) {
      _solvePuzzle();
    } else {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Incorrect! Try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _solvePuzzle() {
    HapticFeedback.mediumImpact();
    setState(() {
      _puzzleSolved = true;
      _currentPoints += 20; // Bonus points for solving puzzle
    });
    _revealAnimationController.forward();
  }

  Widget _buildQuestionScreen() {
    final question = widget.questions[_currentQuestionIndex];

    return AnimatedBuilder(
      animation: _revealAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _revealAnimation.value,
          child: Transform.scale(
            scale: 0.8 + (_revealAnimation.value * 0.2),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Success message
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: widget.currentTheme == 'beach'
                                  ? [
                                      const Color(0xFF4CAF50),
                                      const Color(0xFF2E7D32)
                                    ]
                                  : [
                                      const Color(0xFF43e97b),
                                      const Color(0xFF38f9d7)
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.psychology,
                                      color: Colors.white, size: 32),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Concept Mastered!',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Great thinking! You\'ve unlocked deeper learning',
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.9),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        const Icon(Icons.diamond,
                                            color: Colors.white, size: 20),
                                        Text(
                                          '+20 Points',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        const Icon(Icons.trending_up,
                                            color: Colors.white, size: 20),
                                        Text(
                                          'Level Up',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        const Icon(Icons.lightbulb,
                                            color: Colors.white, size: 20),
                                        Text(
                                          'Knowledge+',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

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
                          final isCorrect =
                              _showAnswer && option == question.correctAnswer;
                          final isWrong =
                              _showAnswer && isSelected && !isCorrect;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: _showAnswer
                                    ? null
                                    : () => _checkAnswer(option),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: isCorrect
                                        ? LinearGradient(
                                            colors: widget.currentTheme ==
                                                    'beach'
                                                ? [
                                                    const Color(0xFF4CAF50),
                                                    const Color(0xFF2E7D32)
                                                  ]
                                                : [
                                                    const Color(0xFF43e97b),
                                                    const Color(0xFF38f9d7)
                                                  ])
                                        : isWrong
                                            ? LinearGradient(
                                                colors: widget.currentTheme ==
                                                        'beach'
                                                    ? [
                                                        const Color(0xFFFF8A65),
                                                        const Color(0xFFFF7043)
                                                      ]
                                                    : [
                                                        const Color(0xFFf5576c),
                                                        const Color(0xFFf093fb)
                                                      ])
                                            : isSelected
                                                ? LinearGradient(
                                                    colors:
                                                        widget.currentTheme ==
                                                                'beach'
                                                            ? [
                                                                const Color(
                                                                    0xFF4DD0E1),
                                                                const Color(
                                                                    0xFF26C6DA)
                                                              ]
                                                            : [
                                                                const Color(
                                                                    0xFF4facfe),
                                                                const Color(
                                                                    0xFF00f2fe)
                                                              ])
                                                : widget.currentTheme == 'beach'
                                                    ? LinearGradient(
                                                        colors: [
                                                          const Color(
                                                                  0xFFF5F5DC)
                                                              .withOpacity(
                                                                  0.95),
                                                          const Color(
                                                                  0xFFE6D3A3)
                                                              .withOpacity(0.9),
                                                        ],
                                                      )
                                                    : const LinearGradient(
                                                        colors: [
                                                            Color(0xFF23243a),
                                                            Color(0xFF23243a)
                                                          ]),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isCorrect
                                          ? Colors.greenAccent.withOpacity(0.7)
                                          : isWrong
                                              ? Colors.redAccent
                                                  .withOpacity(0.7)
                                              : Colors.white.withOpacity(0.2),
                                      width: 2,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFF4facfe)
                                                  .withOpacity(0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 6),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          option,
                                          style: TextStyle(
                                            color: (isCorrect ||
                                                    isWrong ||
                                                    isSelected)
                                                ? Colors.white
                                                : widget.currentTheme == 'beach'
                                                    ? const Color(0xFF2E2E2E)
                                                    : Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      if (_showAnswer && isCorrect)
                                        const Icon(Icons.check_circle,
                                            color: Colors.white, size: 24),
                                      if (_showAnswer &&
                                          isSelected &&
                                          !isCorrect)
                                        const Icon(Icons.cancel,
                                            color: Colors.white, size: 24),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),

                        if (_showAnswer) ...[
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: widget.currentTheme == 'beach'
                                  ? LinearGradient(colors: [
                                      const Color(0xFF4DD0E1),
                                      const Color(0xFF26C6DA)
                                    ])
                                  : LinearGradient(colors: [
                                      const Color(0xFF4facfe),
                                      const Color(0xFF00f2fe)
                                    ]),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF4facfe).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: _continueToNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: Icon(
                                _currentQuestionIndex <
                                        widget.questions.length - 1
                                    ? Icons.arrow_forward_rounded
                                    : Icons.check_circle_rounded,
                                color: Colors.white,
                              ),
                              label: Text(
                                _currentQuestionIndex <
                                        widget.questions.length - 1
                                    ? 'Next Puzzle Quest'
                                    : 'Complete Quest',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                _buildPowerupBar(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionCard(Question question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: widget.currentTheme == 'beach'
            ? LinearGradient(
                colors: [
                  const Color(0xFFF5F5DC).withOpacity(0.95),
                  const Color(0xFFE6D3A3).withOpacity(0.9),
                ],
              )
            : LinearGradient(
                colors: [
                  const Color(0xFF2A2D3E),
                  const Color(0xFF1D1E33),
                  const Color(0xFF16213E).withOpacity(0.9),
                ],
              ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4facfe).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.quiz,
            size: 40,
            color: widget.currentTheme == 'beach'
                ? const Color(0xFF4DD0E1)
                : Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            question.questionText,
            style: TextStyle(
              color: widget.currentTheme == 'beach'
                  ? const Color(0xFF2E2E2E)
                  : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _checkAnswer(String answer) {
    HapticFeedback.selectionClick();

    setState(() {
      _selectedAnswer = answer;
      _showAnswer = true;
    });

    final isCorrect =
        answer == widget.questions[_currentQuestionIndex].correctAnswer;

    if (isCorrect) {
      _correctAnswers++;
      _currentPoints += (_doublePointsActive ? 30 : 15);
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }

    _doublePointsActive = false;
    _removedOptions.clear();
  }

  void _continueToNext() {
    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _showAnswer = false;
        _puzzleSolved = false;
        _skipUsed = false;
        _fiftyFiftyUsed = false;
      });
      _revealAnimationController.reset();
      _puzzleAnimationController.reset();
      _generatePuzzle();
    } else {
      _showFinalScore();
    }
  }

  void _showFinalScore() {
    setState(() {
      _showScoreSummary = true;
    });
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
              ? LinearGradient(
                  colors: [
                    const Color(0xFFF5F5DC).withOpacity(0.95),
                    const Color(0xFFE6D3A3).withOpacity(0.9),
                  ],
                )
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: widget.currentTheme == 'beach'
                    ? LinearGradient(colors: [
                        const Color(0xFF4DD0E1),
                        const Color(0xFF26C6DA)
                      ])
                    : LinearGradient(colors: [
                        const Color(0xFF4facfe),
                        const Color(0xFF00f2fe)
                      ]),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.extension,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Learning Quest Complete!',
              style: TextStyle(
                color: widget.currentTheme == 'beach'
                    ? const Color(0xFF2E2E2E)
                    : Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ve mastered ${widget.questions.length} educational challenges!',
              style: TextStyle(
                color: widget.currentTheme == 'beach'
                    ? const Color(0xFF2E2E2E).withOpacity(0.8)
                    : Colors.white.withOpacity(0.8),
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(
                    'Mastered',
                    '$_correctAnswers/${widget.questions.length}',
                    Icons.psychology),
                _buildStatCard(
                    'Learning Rate', '$accuracy%', Icons.trending_up),
                _buildStatCard(
                    'Challenges', '${widget.questions.length}', Icons.school),
              ],
            ),
            const SizedBox(height: 20),
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
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Play Again',
                    Icons.refresh,
                    widget.currentTheme == 'beach'
                        ? [const Color(0xFF4DD0E1), const Color(0xFF26C6DA)]
                        : [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
                    () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => PuzzleQuestScreen(
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
                    widget.currentTheme == 'beach'
                        ? [const Color(0xFF4CAF50), const Color(0xFF2E7D32)]
                        : [const Color(0xFF11998e), const Color(0xFF38ef7d)],
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
                ? const Color(0xFF4DD0E1)
                : Colors.white,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: widget.currentTheme == 'beach'
                  ? const Color(0xFF2E2E2E)
                  : Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: widget.currentTheme == 'beach'
                  ? const Color(0xFF2E2E2E).withOpacity(0.7)
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

  Widget _buildPowerupBar() {
    List<Widget> powerupButtons = [
      _buildPowerupButton('skip_question', Icons.skip_next, 'Skip',
          const Color(0xFF4CAF50), _skipUsed),
      _buildPowerupButton('fifty_fifty', Icons.filter_2, '50/50',
          const Color(0xFF2196F3), _fiftyFiftyUsed),
      _buildPowerupButton('double_points', Icons.star, '2x Points',
          const Color(0xFFFFD700), _doublePointsActive),
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
        width: 80,
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
                width: 80,
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

  void _usePowerup(String powerupId) {
    if ((_userPowerups[powerupId] ?? 0) <= 0 || _showAnswer) return;

    setState(() {
      _userPowerups[powerupId] = (_userPowerups[powerupId] ?? 0) - 1;
    });

    switch (powerupId) {
      case 'skip_question':
        _skipUsed = true;
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
}
