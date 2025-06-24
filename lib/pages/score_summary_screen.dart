import 'package:flutter/material.dart';
import '../../frq_manager.dart';

class ScoreSummaryScreen extends StatefulWidget {
  final String aiResponse;

  const ScoreSummaryScreen({Key? key, required this.aiResponse})
      : super(key: key);

  @override
  State<ScoreSummaryScreen> createState() => _ScoreSummaryScreenState();
}

class _ScoreSummaryScreenState extends State<ScoreSummaryScreen> {
  // Keep track of which cards are expanded
  final Set<int> expandedCards = {};

  @override
  Widget build(BuildContext context) {
    // Debug print for AI response
    print('AI RESPONSE RAW:\n' + widget.aiResponse);
    // Parse the AI response into a list of feedback items
    List<Map<String, String>> feedbackItems =
        _parseAIResponse(widget.aiResponse);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Score Summary'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          const SpaceBackground(),
          ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: feedbackItems.length,
            itemBuilder: (context, index) {
              final item = feedbackItems[index];
              final isExpanded = expandedCards.contains(index);

              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                color: Colors.white.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['question'] ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item['score'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Feedback:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['feedback'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (isExpanded) {
                              expandedCards.remove(index);
                            } else {
                              expandedCards.add(index);
                            }
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Correct Answer:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedCrossFade(
                        firstChild: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          color: Colors.black26,
                          child: SelectableText(
                            item['answer'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'monospace',
                            ),
                            toolbarOptions: const ToolbarOptions(copy: true),
                          ),
                        ),
                        secondChild: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          color: Colors.black26,
                          child: SelectableText(
                            item['answer'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'monospace',
                            ),
                            toolbarOptions: const ToolbarOptions(copy: true),
                          ),
                        ),
                        crossFadeState: isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _parseAIResponse(String response) {
    List<Map<String, String>> items = [];
    // Split the response by lines and look for question patterns
    List<String> lines = response.split('\n');
    RegExp questionStart = RegExp(r'^Q\d+[a-zA-Z]?\s*\|\|\|');
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      if (questionStart.hasMatch(line)) {
        try {
          // Extract the question number
          String questionNumber = line.split('|||')[0].trim();
          // Get the rest of the line after the first |||
          String remainingLine = line.substring(line.indexOf('|||') + 3).trim();
          // Split the remaining part by |||
          List<String> parts = remainingLine.split('|||');
          if (parts.length >= 2) {
            String score = parts[0].trim();
            String feedback = parts[1].trim();
            String answer = '';
            if (parts.length > 2) {
              answer = parts.sublist(2).join('|||').trim();
              // Continue reading subsequent lines until we hit another question or empty line
              int j = i + 1;
              while (j < lines.length && lines[j].trim().isNotEmpty && !questionStart.hasMatch(lines[j].trim()) && !lines[j].trim().startsWith('===')) {
                answer += '\n' + lines[j].trim();
                j++;
              }
            }
            items.add({
              'question': questionNumber,
              'score': score,
              'feedback': feedback,
              'answer': answer,
            });
          }
        } catch (e) {
          print('Error parsing line: $line');
          print('Error: $e');
        }
      }
    }
    return items;
  }
}