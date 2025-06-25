import 'dart:math' as math;
import '../main.dart' show getBackgroundForTheme;

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:student_learning_app/ai/bloc/chat_bloc.dart';
import 'package:student_learning_app/screens/frq_summary_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:student_learning_app/screens/score_summary_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:student_learning_app/ai/models/chat_message_model.dart';

// Manual structure for AP Comp Sci 2024
const List<String> manualQuestions = [
  'Q1a',
  'Q1b',
  'Q2',
  'Q3a',
  'Q3b',
  'Q4a',
  'Q4b'
];

// Point values for AP CS A 2024 FRQ questions
const Map<String, int> questionPointValues = {
  'Q1a': 4,
  'Q1b': 5,
  'Q2': 9,
  'Q3a': 3,
  'Q3b': 6,
  'Q4a': 3,
  'Q4b': 6,
};

// SpaceBackground widget for the space theme
class SpaceBackground extends StatelessWidget {
  const SpaceBackground({super.key});

  @override
  Widget build(BuildContext context) {
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
          // Twinkling stars
          for (int i = 0; i < 50; i++)
            Positioned(
              left: math.Random().nextDouble() *
                  MediaQuery.of(context).size.width,
              top: math.Random().nextDouble() *
                  MediaQuery.of(context).size.height,
              child: AnimatedContainer(
                duration: Duration(seconds: math.Random().nextInt(3) + 1),
                width: 2,
                height: 2,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                onEnd: () {
                  // Restart animation
                },
              ),
            ),
        ],
      ),
    );
  }
}

class FRQManager extends StatefulWidget {
  final Map<String, dynamic> studySet;
  final String username;
  final String currentTheme;
  final int frqCount;
  const FRQManager(
      {super.key,
      required this.studySet,
      required this.username,
      required this.currentTheme,
      required this.frqCount});

  @override
  State<FRQManager> createState() => _FRQManagerState();
}

class _FRQManagerState extends State<FRQManager> {
  String? lastAIResponse;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        getBackgroundForTheme(widget.currentTheme),
        Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('AP CS A FRQ Practice'),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Stack(
            children: [
              getBackgroundForTheme(widget.currentTheme),
              SafeArea(
                child: FRQTextDisplayScreen(
                    year: '2024',
                    frqCount: widget.frqCount,
                    username: widget.username,
                    currentTheme: widget.currentTheme),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String? selectedSubpart;
  Map<String, String> answers = {};

  @override
  void dispose() {
    super.dispose();
  }

  void _zoomIn() {
    // Implementation of _zoomIn method
  }

  void _zoomOut() {
    // Implementation of _zoomOut method
  }

  Map<String, String> _parseCanonicalAnswers(String txt) {
    final Map<String, String> map = {};

    // First, let's add debug logging to see what we're working with
    print('\n=== RAW FILE CONTENT (first 500 chars) ===');
    print(txt.substring(0, math.min<int>(500, txt.length)));
    print('=== END RAW CONTENT ===\n');

    // Split the text into lines for easier processing
    final lines = txt.split('\n');
    String? currentQuestion;
    List<String> currentAnswer = [];
    bool inAnswerSection = false;

    print('\n=== Starting Answer Parsing ===');

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();

      // Skip empty lines
      if (line.isEmpty) continue;

      // Check if this line starts a new question
      // Look for patterns like "Q1a (4 points)" or "Q1a:" or "Q1a)"
      final questionMatch = RegExp(r'^(Q\d+[a-z]?)\s*[\(:)]').firstMatch(line);

      if (questionMatch != null) {
        // Save previous question if exists
        if (currentQuestion != null && currentAnswer.isNotEmpty) {
          String answer = currentAnswer.join('\n').trim();
          map[currentQuestion] = answer;
          print('\nSaved answer for $currentQuestion:');
          print(answer);
        }

        // Start new question
        currentQuestion = questionMatch.group(1);
        currentAnswer = [];
        inAnswerSection = true;

        // Add any content after the question identifier on the same line
        String restOfLine = line.substring(questionMatch.end).trim();
        if (restOfLine.isNotEmpty && !restOfLine.contains('points')) {
          currentAnswer.add(restOfLine);
        }

        print('\nFound new question: $currentQuestion');
      }
      // Check if we're starting a new major section (like "QUESTION 2:")
      else if (line.startsWith('QUESTION ') && line.contains(':')) {
        // This indicates we're moving to rubric section, stop collecting answers
        if (currentQuestion != null && currentAnswer.isNotEmpty) {
          String answer = currentAnswer.join('\n').trim();
          map[currentQuestion] = answer;
          print('\nSaved final answer for $currentQuestion:');
          print(answer);
        }
        inAnswerSection = false;
        currentQuestion = null;
        currentAnswer = [];
        print('\nFound new section: $line');
      }
      // Collect answer content
      else if (inAnswerSection && currentQuestion != null) {
        // Skip lines that look like section headers or rubric content
        if (!line.startsWith('QUESTION ') &&
            !line.startsWith('RUBRIC') &&
            !line.contains('points possible') &&
            !line.contains('Grading Guidelines')) {
          currentAnswer.add(line);
        }
      }
    }

    // Don't forget the last question
    if (currentQuestion != null && currentAnswer.isNotEmpty) {
      String answer = currentAnswer.join('\n').trim();
      map[currentQuestion] = answer;
      print('\nSaved last answer for $currentQuestion:');
      print(answer);
    }

    // Debug: print all found answers
    print('\n=== FINAL PARSED ANSWERS ===');
    map.forEach((key, value) {
      print('\nQuestion: $key');
      print('Answer: $value');
      print('---');
    });
    print('=== END PARSED ANSWERS ===\n');

    return map;
  }

  Map<String, String> _parseRubrics(String txt) {
    final Map<String, String> map = {};

    // Split into lines
    final lines = txt.split('\n');
    String? currentQuestion;
    List<String> currentRubric = [];
    bool inRubricSection = false;

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();

      if (line.isEmpty) continue;

      // Look for "QUESTION X:" patterns
      final questionMatch = RegExp(r'^QUESTION\s+(\d+)\s*:').firstMatch(line);

      if (questionMatch != null) {
        // Save previous rubric if exists
        if (currentQuestion != null && currentRubric.isNotEmpty) {
          map[currentQuestion] = currentRubric.join('\n').trim();
        }

        // Start new rubric section
        String questionNum = questionMatch.group(1)!;
        currentQuestion = 'Q$questionNum';
        currentRubric = [];
        inRubricSection = true;

        // Add any content after the question header
        String restOfLine = line.substring(questionMatch.end).trim();
        if (restOfLine.isNotEmpty) {
          currentRubric.add(restOfLine);
        }
      }
      // Check for subparts within a question
      else if (inRubricSection &&
          currentQuestion != null &&
          RegExp(r'^\([a-z]\)').hasMatch(line)) {
        // This is a subpart like "(a)" or "(b)"
        String subpart = line.substring(0, 3); // "(a)" or "(b)"
        String questionWithSubpart =
            currentQuestion + subpart.substring(1, 2); // "Q1a" or "Q1b"

        // Save any accumulated content for the main question
        if (currentRubric.isNotEmpty && !map.containsKey(questionWithSubpart)) {
          // Start collecting for this subpart
          List<String> subpartRubric = [line];

          // Look ahead for content belonging to this subpart
          for (int j = i + 1; j < lines.length; j++) {
            String nextLine = lines[j].trim();
            if (nextLine.isEmpty) continue;

            // Stop if we hit another subpart or question
            if (RegExp(r'^\([a-z]\)').hasMatch(nextLine) ||
                nextLine.startsWith('QUESTION ')) {
              break;
            }

            subpartRubric.add(nextLine);
            i = j; // Skip these lines in the main loop
          }

          map[questionWithSubpart] = subpartRubric.join('\n').trim();
        }
      }
      // Collect rubric content
      else if (inRubricSection && currentQuestion != null) {
        if (!line.startsWith('QUESTION ')) {
          currentRubric.add(line);
        }
      }
    }

    // Save the last rubric
    if (currentQuestion != null && currentRubric.isNotEmpty) {
      map[currentQuestion] = currentRubric.join('\n').trim();
    }

    return map;
  }

  int _extractMaxPoints(String subpart, String frqData) {
    // Try to find the points from the file
    final regex = RegExp('$subpart \\((\\d+) points\\)');
    final match = regex.firstMatch(frqData);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '') ?? 0;
    }

    // Fallback based on known AP CS A structure
    final Map<String, int> defaultPoints = {
      'Q1a': 4,
      'Q1b': 5,
      'Q2': 9,
      'Q3a': 3,
      'Q3b': 6,
      'Q4a': 3,
      'Q4b': 6,
    };

    return defaultPoints[subpart] ?? 5; // Default to 5 if not found
  }
}

class PDFViewerScreen extends StatefulWidget {
  final String filePath;
  final String year;
  final int frqCount;
  final String currentTheme;
  const PDFViewerScreen(
      {super.key,
      required this.filePath,
      required this.year,
      required this.frqCount,
      required this.currentTheme});

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  bool _loading = true;
  bool _error = false;
  bool _showAnswerBox = false;
  final TextEditingController _answerController = TextEditingController();
  final PdfViewerController _pdfViewerController = PdfViewerController();
  double _currentZoom = 1.0;
  String? lastAIResponse;

  String? selectedSubpart;
  Map<String, String> answers = {};

  @override
  void dispose() {
    _answerController.dispose();
    _pdfViewerController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    setState(() {
      _currentZoom += 0.25;
      if (_currentZoom > 4.0) _currentZoom = 4.0;
      _pdfViewerController.zoomLevel = _currentZoom;
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom -= 0.25;
      if (_currentZoom < 1.0) _currentZoom = 1.0;
      _pdfViewerController.zoomLevel = _currentZoom;
    });
  }

  void _showChatModalAndStartGrading(BuildContext context) async {
    final chatBloc = ChatBloc();
    try {
      // Build the prompt content
      StringBuffer promptContent = StringBuffer();

      // Add instructions for the AI
      promptContent.writeln(
          'You are an AP Computer Science A FRQ grader. Please grade the following student answers according to the official rubric.');
      promptContent.writeln(
          '\nFor each question, provide your response in the following format:');
      promptContent.writeln(
          '[question number ||| points awarded ||| detailed feedback ||| correct solution]');
      promptContent.writeln(
          '\nPoints should be awarded according to the official rubric:');
      promptContent.writeln('Q1a: 3 points - Array manipulation and logic');
      promptContent.writeln('Q1b: 3 points - Array traversal and conditionals');
      promptContent.writeln('Q2: 4 points - Class implementation and methods');
      promptContent.writeln('Q3a: 3 points - Method implementation');
      promptContent.writeln('Q3b: 3 points - Method implementation');
      promptContent.writeln('Q4a: 3 points - Class design and implementation');
      promptContent.writeln('Q4b: 3 points - Method implementation');
      promptContent.writeln('\nFor each answer, provide:');
      promptContent.writeln('1. Points awarded (0 to max points)');
      promptContent.writeln(
          '2. Detailed feedback explaining what was done correctly and what needs improvement');
      promptContent.writeln('3. The complete, correct solution with comments');
      promptContent.writeln('\nNow, please grade the following answers:\n');

      // Add user answers to the prompt
      promptContent.writeln('=== User Answers ===');
      for (String question in manualQuestions.take(widget.frqCount)) {
        promptContent.writeln('\nQuestion: $question');
        promptContent.writeln('Answer: ${answers[question] ?? "Not answered"}');
        promptContent.writeln('-------------------');
      }

      // Load and add the official answers and rubric
      promptContent.writeln('\n=== Official Answers and Rubrics ===');
      final frqData =
          await rootBundle.loadString('assets/apcs_2024_frq_answers.txt');
      promptContent.writeln(frqData);
      promptContent.writeln('=== End of Official Answers ===\n');

      // Send the content to QuestAI
      chatBloc.add(ChatGenerationNewTextMessageEvent(
        inputMessage: promptContent.toString(),
      ));

      // Listen for the AI response
      chatBloc.stream.listen((state) {
        if (state is ChatSuccessState && state.messages.isNotEmpty) {
          final lastMessage = state.messages.last;
          if (lastMessage.role == "model") {
            lastAIResponse = lastMessage.parts.first.text;
            // Parse the AI response and create results
            List<FrqGradingResult> results = [];
            List<String> lines = lastAIResponse!.split('\n');
            RegExp questionStart = RegExp(r'^\[Q\d+[a-zA-Z]?\s*\|\|\|');
            for (int i = 0; i < lines.length; i++) {
              String line = lines[i].trim();
              if (questionStart.hasMatch(line)) {
                try {
                  // Remove leading '[' and trailing ']' if present
                  String entry = line;
                  if (entry.startsWith('[')) entry = entry.substring(1);
                  if (entry.endsWith(']'))
                    entry = entry.substring(0, entry.length - 1);
                  // If the canonical answer is multi-line, keep reading until we hit a line ending with ']'
                  while (!line.endsWith(']') && i + 1 < lines.length) {
                    i++;
                    entry += '\n' + lines[i].trim();
                    line = lines[i].trim();
                  }
                  // Now split by '|||'
                  List<String> parts = entry.split('|||');
                  if (parts.length >= 4) {
                    String questionNumber = parts[0].trim();
                    String pointsStr = parts[1].trim();
                    String feedback = parts[2].trim();
                    String canonicalAnswer =
                        parts.sublist(3).join('|||').trim();
                    // Remove trailing ']' if present
                    if (canonicalAnswer.endsWith(']')) {
                      canonicalAnswer = canonicalAnswer
                          .substring(0, canonicalAnswer.length - 1)
                          .trim();
                    }
                    // Parse points (e.g., '0 points' -> 0)
                    int pointsAwarded = 0;
                    RegExp pointsReg = RegExp(r'(\d+)');
                    var match = pointsReg.firstMatch(pointsStr);
                    if (match != null) {
                      pointsAwarded = int.parse(match.group(1)!);
                    }
                    // Get max points based on question - Updated to match AP CS A 2024 FRQ
                    int maxPoints = questionPointValues[questionNumber] ??
                        3; // Default to 3 if not found
                    results.add(FrqGradingResult(
                      subpart: questionNumber,
                      userAnswer: answers[questionNumber] ?? '',
                      canonicalAnswer: canonicalAnswer,
                      pointsAwarded: pointsAwarded,
                      maxPoints: maxPoints,
                      feedback: feedback,
                    ));
                  }
                } catch (e) {
                  print('Error parsing line: $line');
                  print('Error: $e');
                }
              }
            }

            // After parsing, print the results for debugging
            print('FRQ AI Grading Results:');
            for (var r in results) {
              print(
                  'Question: \'${r.subpart}\', Points: ${r.pointsAwarded}/${r.maxPoints}, Feedback: ${r.feedback.substring(0, r.feedback.length > 50 ? 50 : r.feedback.length)}...');
            }
            // Navigate to the FrqSummaryScreen with the results
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FrqSummaryScreen(
                  results: results,
                  username:
                      '', // PDFViewerScreen is unused, but keeping for compatibility
                  currentTheme: widget.currentTheme,
                ),
              ),
            );
          }
        }
      });
    } catch (e) {
      print('Error in grading process: $e');
    }
  }

  void _showGeneralChatModal(BuildContext context) {
    final chatBloc = ChatBloc();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => true,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              final TextEditingController messageController =
                  TextEditingController();
              final ScrollController scrollController = ScrollController();
              void _scrollToBottom() {
                if (scrollController.hasClients) {
                  scrollController.animateTo(
                    scrollController.position.maxScrollExtent,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              }

              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: EdgeInsets.zero,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.psychology,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'QuestAI Model Chat',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: Colors.grey[300]),
                      Expanded(
                        child: BlocBuilder<ChatBloc, ChatState>(
                          bloc: chatBloc,
                          builder: (context, state) {
                            if (state is ChatSuccessState) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _scrollToBottom();
                              });
                              return ListView.builder(
                                controller: scrollController,
                                itemCount: state.messages.length,
                                itemBuilder: (context, index) {
                                  final message = state.messages[index];
                                  return Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    padding: EdgeInsets.all(12),
                                    alignment: message.role == "user"
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.75,
                                      ),
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: message.role == "user"
                                            ? Colors.blue
                                            : Colors.purple,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        message.parts.first.text,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                            return Center(child: CircularProgressIndicator());
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: messageController,
                                decoration: InputDecoration(
                                  hintText: 'Type your message...',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide:
                                        BorderSide(color: Colors.purple),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide(
                                        color: Colors.purple, width: 2),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.purple,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: () {
                                  if (messageController.text.isNotEmpty) {
                                    chatBloc.add(
                                      ChatGenerationNewTextMessageEvent(
                                        inputMessage: messageController.text,
                                      ),
                                    );
                                    messageController.clear();
                                  }
                                },
                                icon: Icon(Icons.send, color: Colors.white),
                                iconSize: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AP FRQ ${widget.year}'),
        backgroundColor: const Color(0xFF1D1E33),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Visibility(
            visible: !_error,
            child: SfPdfViewer.asset(
              widget.filePath,
              controller: _pdfViewerController,
              canShowPaginationDialog: true,
              canShowScrollHead: true,
              enableDoubleTapZooming: true,
              onDocumentLoaded: (details) {
                setState(() {
                  _loading = false;
                });
                print('PDF loaded: ${widget.filePath}');
              },
              onDocumentLoadFailed: (details) {
                setState(() {
                  _loading = false;
                  _error = true;
                });
                print('Failed to load PDF: ${widget.filePath}');
              },
            ),
          ),
          if (_loading) const Center(child: CircularProgressIndicator()),
          if (_error)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load PDF file:\n${widget.filePath}',
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          // Manual Answer Workbook Modal
          if (_showAnswerBox)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.5,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: selectedSubpart == null
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Answer Workbook',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _showAnswerBox = false;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('Select a question/subpart to answer:'),
                          const SizedBox(height: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: manualQuestions
                                    .take(widget.frqCount)
                                    .map((q) {
                                  return ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedSubpart = q;
                                        _answerController.text =
                                            answers[q] ?? '';
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(q,
                                        style: const TextStyle(
                                            color: Colors.white)),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              // Print all user answers to console
                              print('\n=== User Answers ===');
                              for (String question
                                  in manualQuestions.take(widget.frqCount)) {
                                print('Question: $question');
                                print(
                                    'Answer: ${answers[question] ?? "Not answered"}');
                                print('-------------------');
                              }
                              print('===================\n');

                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _showChatModalAndStartGrading(context);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Submit Answers',
                                style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Answer for $selectedSubpart',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _showAnswerBox = false;
                                    selectedSubpart = null;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: TextField(
                              controller: _answerController,
                              maxLines: null,
                              expands: true,
                              style: const TextStyle(
                                  color: Color(0xFFFFEB3B)), // Yellow text
                              textAlign: TextAlign.left,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xFF1976D2), // Blue background
                                hintText: 'Type your answer here...',
                                hintStyle: const TextStyle(
                                    color:
                                        Color(0xFFFFF9C4)), // Light yellow hint
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                answers[selectedSubpart!] =
                                    _answerController.text;
                                selectedSubpart = null;
                              });
                              FocusScope.of(context).unfocus();
                            },
                            child: const Text('Back to Questions'),
                          ),
                        ],
                      ),
              ),
            ),
        ],
      ),
      floatingActionButton: !_showAnswerBox
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 100.0, right: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        heroTag: 'zoom_in',
                        mini: true,
                        backgroundColor: Colors.purple,
                        onPressed: _zoomIn,
                        child: const Icon(Icons.add, size: 28),
                        tooltip: 'Zoom In',
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        heroTag: 'zoom_out',
                        mini: true,
                        backgroundColor: Colors.purple,
                        onPressed: _zoomOut,
                        child: const Icon(Icons.remove, size: 28),
                        tooltip: 'Zoom Out',
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0, right: 8.0),
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      setState(() {
                        _showAnswerBox = true;
                        selectedSubpart = null;
                      });
                    },
                    backgroundColor: Colors.purple,
                    icon: const Icon(Icons.edit_note),
                    label: const Text('Answer Workbook',
                        style: TextStyle(fontSize: 14)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 170.0, right: 8.0),
                  child: FloatingActionButton(
                    heroTag: 'chat_ai',
                    backgroundColor: Colors.purple,
                    onPressed: () => _showGeneralChatModal(context),
                    child: const Icon(Icons.message, size: 28),
                    tooltip: 'Chat with QuestAI',
                  ),
                ),
              ],
            )
          : null,
    );
  }
}

class FRQTextDisplayScreen extends StatefulWidget {
  final String year;
  final int frqCount;
  final String username;
  final String currentTheme;

  const FRQTextDisplayScreen(
      {super.key,
      required this.year,
      required this.frqCount,
      required this.username,
      required this.currentTheme});

  @override
  State<FRQTextDisplayScreen> createState() => _FRQTextDisplayScreenState();
}

class _FRQTextDisplayScreenState extends State<FRQTextDisplayScreen> {
  List<String> questions = [];
  int currentQuestionIndex = 0;
  bool isLoading = true;
  bool isSubmitting = false;
  String? error;
  String? lastAIResponse;

  // Answer storage
  Map<String, String> answers = {};

  // Text input modal state
  bool showTextInput = false;
  String currentAnswerKey = '';
  final TextEditingController _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final String content =
          await rootBundle.loadString('assets/apfrq/APCompSciA2024.txt');
      final List<String> questionList = content.split(
          '-----------------------------------------------------------------------------');

      // Filter out empty questions and trim whitespace
      questions = questionList
          .where((question) => question.trim().isNotEmpty)
          .map((question) => question.trim())
          .toList();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load questions: $e';
        isLoading = false;
      });
    }
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  // Function to open text input modal for a specific question part
  void _openTextInput(String answerKey) {
    setState(() {
      currentAnswerKey = answerKey;
      _answerController.text = answers[answerKey] ?? '';
      showTextInput = true;
    });
  }

  // Function to save answer and close text input
  void _saveAnswer() {
    setState(() {
      answers[currentAnswerKey] = _answerController.text;
      showTextInput = false;
    });
  }

  // Function to close text input without saving
  void _closeTextInput() {
    setState(() {
      showTextInput = false;
    });
  }

  // Get the appropriate buttons for the current question
  List<Widget> _getQuestionButtons() {
    switch (currentQuestionIndex + 1) {
      case 1:
        return [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4facfe).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _openTextInput('Q1a'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(
                Icons.edit_outlined,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                'Question 1a',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _openTextInput('Q1b'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(
                Icons.edit_outlined,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                'Question 1b',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ];
      case 2:
        return [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF11998e).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _openTextInput('Q2'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(
                Icons.edit_outlined,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                'Question 2',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ];
      case 3:
        return [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFf093fb).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _openTextInput('Q3a'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(
                Icons.edit_outlined,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                'Question 3a',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4facfe).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _openTextInput('Q3b'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(
                Icons.edit_outlined,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                'Question 3b',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ];
      case 4:
        return [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _openTextInput('Q4a'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(
                Icons.edit_outlined,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                'Question 4a',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFf093fb).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _openTextInput('Q4b'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(
                Icons.edit_outlined,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                'Question 4b',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ];
      default:
        return [];
    }
  }

  // Get the submit button (only for question 4)
  Widget? _getSubmitButton() {
    if (currentQuestionIndex == 3) {
      // Question 4 (index 3) - show submit button
      return Container(
        margin: const EdgeInsets.only(top: 24),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: isSubmitting
              ? null
              : () {
                  setState(() {
                    isSubmitting = true;
                  });
                  _showChatModalAndStartGrading(context);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          icon: isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 24,
                ),
          label: Text(
            isSubmitting ? 'Grading Answers...' : 'Submit Answers',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
    return null;
  }

  void _showChatModalAndStartGrading(BuildContext context) async {
    final chatBloc = ChatBloc();
    try {
      // Build the prompt content
      StringBuffer promptContent = StringBuffer();

      // Add instructions for the AI
      promptContent.writeln(
          'You are an AP Computer Science A FRQ grader. Please grade the following student answers according to the official rubric.');
      promptContent.writeln(
          '\nFor each question, provide your response in the following format:');
      promptContent.writeln(
          '[question number ||| points awarded ||| detailed feedback ||| correct solution]');
      promptContent.writeln(
          '\nPoints should be awarded according to the official rubric:');
      promptContent.writeln('Q1a: 3 points - Array manipulation and logic');
      promptContent.writeln('Q1b: 3 points - Array traversal and conditionals');
      promptContent.writeln('Q2: 4 points - Class implementation and methods');
      promptContent.writeln('Q3a: 3 points - Method implementation');
      promptContent.writeln('Q3b: 3 points - Method implementation');
      promptContent.writeln('Q4a: 3 points - Class design and implementation');
      promptContent.writeln('Q4b: 3 points - Method implementation');
      promptContent.writeln('\nFor each answer, provide:');
      promptContent.writeln('1. Points awarded (0 to max points)');
      promptContent.writeln(
          '2. Detailed feedback explaining what was done correctly and what needs improvement');
      promptContent.writeln('3. The complete, correct solution with comments');
      promptContent.writeln('\nNow, please grade the following answers:\n');

      // Add user answers to the prompt
      promptContent.writeln('=== User Answers ===');
      for (String question in manualQuestions.take(widget.frqCount)) {
        promptContent.writeln('\nQuestion: $question');
        promptContent.writeln('Answer: ${answers[question] ?? "Not answered"}');
        promptContent.writeln('-------------------');
      }

      // Load and add the official answers and rubric
      promptContent.writeln('\n=== Official Answers and Rubrics ===');
      final frqData =
          await rootBundle.loadString('assets/apcs_2024_frq_answers.txt');
      promptContent.writeln(frqData);
      promptContent.writeln('=== End of Official Answers ===\n');

      // Send the content to QuestAI
      chatBloc.add(ChatGenerationNewTextMessageEvent(
        inputMessage: promptContent.toString(),
      ));

      // Listen for the AI response
      chatBloc.stream.listen((state) {
        if (state is ChatSuccessState && state.messages.isNotEmpty) {
          final lastMessage = state.messages.last;
          if (lastMessage.role == "model") {
            lastAIResponse = lastMessage.parts.first.text;
            // Parse the AI response and create results
            List<FrqGradingResult> results = [];
            List<String> lines = lastAIResponse!.split('\n');
            RegExp questionStart = RegExp(r'^\[Q\d+[a-zA-Z]?\s*\|\|\|');
            for (int i = 0; i < lines.length; i++) {
              String line = lines[i].trim();
              if (questionStart.hasMatch(line)) {
                try {
                  // Remove leading '[' and trailing ']' if present
                  String entry = line;
                  if (entry.startsWith('[')) entry = entry.substring(1);
                  if (entry.endsWith(']'))
                    entry = entry.substring(0, entry.length - 1);
                  // If the canonical answer is multi-line, keep reading until we hit a line ending with ']'
                  while (!line.endsWith(']') && i + 1 < lines.length) {
                    i++;
                    entry += '\n' + lines[i].trim();
                    line = lines[i].trim();
                  }
                  // Now split by '|||'
                  List<String> parts = entry.split('|||');
                  if (parts.length >= 4) {
                    String questionNumber = parts[0].trim();
                    String pointsStr = parts[1].trim();
                    String feedback = parts[2].trim();
                    String canonicalAnswer =
                        parts.sublist(3).join('|||').trim();
                    // Remove trailing ']' if present
                    if (canonicalAnswer.endsWith(']')) {
                      canonicalAnswer = canonicalAnswer
                          .substring(0, canonicalAnswer.length - 1)
                          .trim();
                    }
                    // Parse points (e.g., '0 points' -> 0)
                    int pointsAwarded = 0;
                    RegExp pointsReg = RegExp(r'(\d+)');
                    var match = pointsReg.firstMatch(pointsStr);
                    if (match != null) {
                      pointsAwarded = int.parse(match.group(1)!);
                    }
                    // Get max points based on question - Updated to match AP CS A 2024 FRQ
                    int maxPoints = questionPointValues[questionNumber] ??
                        3; // Default to 3 if not found
                    results.add(FrqGradingResult(
                      subpart: questionNumber,
                      userAnswer: answers[questionNumber] ?? '',
                      canonicalAnswer: canonicalAnswer,
                      pointsAwarded: pointsAwarded,
                      maxPoints: maxPoints,
                      feedback: feedback,
                    ));
                  }
                } catch (e) {
                  print('Error parsing line: $line');
                  print('Error: $e');
                }
              }
            }

            // Navigate to the FrqSummaryScreen with the results
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FrqSummaryScreen(
                  results: results,
                  username: widget.username,
                  currentTheme: widget.currentTheme,
                ),
              ),
            );
          }
        }
      });
    } catch (e) {
      print('Error in grading process: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        getBackgroundForTheme(widget.currentTheme),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              // Enhanced question navigation header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Enhanced back button
                    Container(
                      decoration: BoxDecoration(
                        color: currentQuestionIndex > 0
                            ? Colors.white.withOpacity(0.15)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        onPressed:
                            currentQuestionIndex > 0 ? _previousQuestion : null,
                        icon: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: currentQuestionIndex > 0
                              ? Colors.white
                              : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),

                    // Enhanced progress indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667eea).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.quiz_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Question ${currentQuestionIndex + 1} of ${questions.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Enhanced forward button
                    Container(
                      decoration: BoxDecoration(
                        color: currentQuestionIndex < questions.length - 1
                            ? Colors.white.withOpacity(0.15)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        onPressed: currentQuestionIndex < questions.length - 1
                            ? _nextQuestion
                            : null,
                        icon: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: currentQuestionIndex < questions.length - 1
                              ? Colors.white
                              : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Enhanced question content
              Expanded(
                child: isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading questions...',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : error != null
                        ? Center(
                            child: Container(
                              margin: const EdgeInsets.all(24),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red[300],
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    error!,
                                    style: TextStyle(
                                      color: Colors.red[300],
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(
                            margin: const EdgeInsets.all(20),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Question header
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.assignment_outlined,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Question ${currentQuestionIndex + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Enhanced question text
                                  Text(
                                    questions[currentQuestionIndex],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      height: 1.8,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
              ),

              // Enhanced question part buttons section
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    // Enhanced question part buttons
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: _getQuestionButtons(),
                    ),
                    const SizedBox(height: 16),
                    // Enhanced submit button (only for question 4)
                    if (_getSubmitButton() != null) _getSubmitButton()!,
                  ],
                ),
              ),
            ],
          ),
        ),

        // Enhanced text input modal overlay
        if (showTextInput)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2A2B4A),
                    const Color(0xFF1F1F3A),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Enhanced header with drag handle
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.12),
                          Colors.white.withOpacity(0.06),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Enhanced drag handle
                        Container(
                          width: 48,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Enhanced header content
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF667eea)
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.edit_note,
                                    color: const Color(0xFF667eea),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  currentAnswerKey,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                onPressed: _closeTextInput,
                                icon: const Icon(Icons.close,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Enhanced text input area
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.08),
                            Colors.white.withOpacity(0.03),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _answerController,
                        maxLines: null,
                        expands: true,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.5,
                          fontFamily:
                              'Fira Code', // Use a monospace font for code
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Type your answer here...\n\nTip: For code, use proper Java syntax and comments to explain your solution.',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 16,
                            fontFamily: 'Fira Code',
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(20),
                        ),
                      ),
                    ),
                  ),

                  // Enhanced action buttons
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Cancel button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: TextButton.icon(
                            onPressed: _closeTextInput,
                            icon: Icon(
                              Icons.cancel_outlined,
                              color: Colors.white.withOpacity(0.8),
                              size: 18,
                            ),
                            label: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                        // Save button
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4CAF50).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _saveAnswer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            icon: const Icon(
                              Icons.save_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: const Text(
                              'Save Answer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
