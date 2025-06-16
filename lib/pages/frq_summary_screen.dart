import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('FRQ Grading Summary'),
        backgroundColor: const Color(0xFF1D1E33),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final result = results[index];
          return _FrqResultCard(result: result);
        },
      ),
    );
  }
}

class _FrqResultCard extends StatefulWidget {
  final FrqGradingResult result;
  const _FrqResultCard({required this.result});

  @override
  State<_FrqResultCard> createState() => _FrqResultCardState();
}

class _FrqResultCardState extends State<_FrqResultCard> {
  bool showDetails = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.result.subpart,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                Text(
                  '${widget.result.pointsAwarded} / ${widget.result.maxPoints} pts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        widget.result.pointsAwarded == widget.result.maxPoints
                            ? Colors.green
                            : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Your Answer:', style: const TextStyle(color: Colors.white70)),
            Text(widget.result.userAnswer,
                style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            Text('Canonical Answer:',
                style: const TextStyle(color: Colors.white70)),
            Text(widget.result.canonicalAnswer,
                style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  showDetails = !showDetails;
                });
              },
              child: Text(showDetails ? 'Hide Details' : 'View Details'),
            ),
            if (showDetails)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(widget.result.feedback,
                    style: const TextStyle(color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }
}
