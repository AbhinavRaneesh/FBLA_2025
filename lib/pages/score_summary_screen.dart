import 'package:flutter/material.dart';

class ScoreSummaryScreen extends StatefulWidget {
  final String aiResponse;

  const ScoreSummaryScreen({Key? key, required this.aiResponse}) : super(key: key);

  @override
  State<ScoreSummaryScreen> createState() => _ScoreSummaryScreenState();
}

class _ScoreSummaryScreenState extends State<ScoreSummaryScreen> {
  // Keep track of which cards are expanded
  final Set<int> expandedCards = {};

  @override
  Widget build(BuildContext context) {
    // Parse the AI response into a list of feedback items
    List<Map<String, String>> feedbackItems = _parseAIResponse(widget.aiResponse);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Score Summary'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1D1E33), Color(0xFF2A2B4A)],
          ),
        ),
        child: ListView.builder(
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedCrossFade(
                      firstChild: Container(
                        constraints: BoxConstraints(maxHeight: 24),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        color: Colors.black26,
                        child: SelectableText(
                          (item['answer'] ?? '').split('\n').first,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 1,
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
                      crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Map<String, String>> _parseAIResponse(String response) {
    List<Map<String, String>> items = [];
    
    // Split the response into lines
    List<String> lines = response.split('\n');
    
    for (String line in lines) {
      // Skip empty lines
      if (line.trim().isEmpty) continue;
      
      // Try to parse the line in the format [question, score, feedback, answer]
      try {
        // Remove the square brackets and split by the new separator
        String content = line.trim();
        if (content.startsWith('[') && content.endsWith(']')) {
          content = content.substring(1, content.length - 1);
        }
        
        List<String> parts = content.split('|||');
        if (parts.length >= 4) {
          // Join everything after the third separator for the answer
          String answer = parts.sublist(3).join('|||').trim();
          items.add({
            'question': parts[0].trim(),
            'score': parts[1].trim(),
            'feedback': parts[2].trim(),
            'answer': answer,
          });
        }
      } catch (e) {
        print('Error parsing line: $line');
        print('Error: $e');
      }
    }
    
    return items;
  }
} 