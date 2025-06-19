import 'package:flutter/material.dart';
import '../frq_manager.dart';

// Point values for AP CS A 2024 FRQ questions - matching the FRQ manager
const Map<String, int> questionPointValues = {
  'Q1a': 4,
  'Q1b': 5,
  'Q2': 9,
  'Q3a': 3,
  'Q3b': 6,
  'Q4a': 3,
  'Q4b': 6,
};

class FrqGradingResult {
  final String subpart;
  final String userAnswer;
  final String canonicalAnswer;
  final int pointsAwarded;
  final int maxPoints;
  final String feedback;

  FrqGradingResult({
    required this.subpart,
    required this.userAnswer,
    required this.canonicalAnswer,
    required this.pointsAwarded,
    required this.maxPoints,
    required this.feedback,
  });
}

class FrqSummaryScreen extends StatelessWidget {
  final List<FrqGradingResult> results;

  const FrqSummaryScreen({Key? key, required this.results}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate total points and max points using the correct point values
    int totalPoints = 0;
    int maxTotalPoints = 0;

    for (var result in results) {
      int maxPoints = questionPointValues[result.subpart] ?? result.maxPoints;
      totalPoints += result.pointsAwarded;
      maxTotalPoints += maxPoints;
    }

    double percentage =
        maxTotalPoints > 0 ? (totalPoints / maxTotalPoints) * 100 : 0;

    // Accurate correct and partial counts
    int correctCount = 0;
    int partialCount = 0;

    for (var result in results) {
      int maxPoints = questionPointValues[result.subpart] ?? result.maxPoints;
      if (result.pointsAwarded == maxPoints) {
        correctCount++;
      } else if (result.pointsAwarded > 0 && result.pointsAwarded < maxPoints) {
        partialCount++;
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'FRQ Grading Summary',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ),
      ),
      body: Stack(
        children: [
          const SpaceBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Enhanced score summary header
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4facfe),
                                    Color(0xFF00f2fe)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.assessment_outlined,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Overall Score',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$totalPoints / $maxTotalPoints',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Total Possible: 36 points',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color:
                                    _getScoreColor(percentage).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _getScoreColor(percentage),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: _getScoreColor(percentage),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                _getScoreColor(percentage)),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              'Questions',
                              results.length.toString(),
                              Icons.question_answer_outlined,
                              const Color(0xFF4facfe),
                            ),
                            _buildStatItem(
                              'Correct',
                              correctCount.toString(),
                              Icons.check_circle_outline,
                              const Color(0xFF4CAF50),
                            ),
                            _buildStatItem(
                              'Partial',
                              partialCount.toString(),
                              Icons.star_half,
                              const Color(0xFFFF9800),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Results list
                  if (results.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      child: Text(
                        'No results to display. There may have been an error with grading. Please try again.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ...results.asMap().entries.map((entry) {
                      final index = entry.key;
                      final result = entry.value;
                      final maxPoints = questionPointValues[result.subpart] ??
                          result.maxPoints;
                      return _FrqResultCard(
                        result: result,
                        maxPoints: maxPoints,
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 80) return const Color(0xFF4CAF50);
    if (percentage >= 60) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _FrqResultCard extends StatefulWidget {
  final FrqGradingResult result;
  final int maxPoints;

  const _FrqResultCard({
    required this.result,
    required this.maxPoints,
  });

  @override
  State<_FrqResultCard> createState() => _FrqResultCardState();
}

class _FrqResultCardState extends State<_FrqResultCard>
    with TickerProviderStateMixin {
  bool showDetails = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double percentage = widget.maxPoints > 0
        ? (widget.result.pointsAwarded / widget.maxPoints) * 100
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Enhanced header
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${widget.result.subpart} (${widget.maxPoints} pts)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getScoreColor(percentage).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getScoreColor(percentage),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${widget.result.pointsAwarded} / ${widget.maxPoints} pts',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(percentage),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                        _getScoreColor(percentage)),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 16),
                // Enhanced toggle button
                InkWell(
                  onTap: () {
                    setState(() {
                      showDetails = !showDetails;
                      if (showDetails) {
                        _animationController.forward();
                      } else {
                        _animationController.reverse();
                      }
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          showDetails
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          showDetails ? 'Hide Details' : 'Show Details',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Animated details section
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailSection(
                    'Your Answer:',
                    widget.result.userAnswer.isEmpty
                        ? 'Not answered'
                        : widget.result.userAnswer,
                    Icons.edit_outlined,
                  ),
                  const SizedBox(height: 16),
                  // Partial Answer (if applicable)
                  if (widget.result.userAnswer.isNotEmpty &&
                      widget.result.pointsAwarded < widget.result.maxPoints)
                    _buildDetailSection(
                      'Partial Answer:',
                      widget.result.userAnswer,
                      Icons.star_half,
                    ),
                  const SizedBox(height: 16),
                  // Correct Answer
                  _buildDetailSection(
                    'Correct Answer:',
                    widget.result.canonicalAnswer,
                    Icons.check_circle_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailSection(
                    'Feedback',
                    widget.result.feedback,
                    Icons.feedback_outlined,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 80) return const Color(0xFF4CAF50);
    if (percentage >= 60) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }
}
