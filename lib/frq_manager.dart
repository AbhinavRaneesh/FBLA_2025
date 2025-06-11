import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:student_learning_app/bloc/chat_bloc.dart';
import 'screens/frq_summary_screen.dart';

class FRQManager extends StatelessWidget {
  const FRQManager({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AP FRQs'),
        backgroundColor: const Color(0xFF1D1E33),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSubjectSection(
                context,
                'AP Computer Science',
                [
                  {'year': '2025', 'title': 'AP Computer Science 2025', 'file': 'assets/apfrq/ap25-frq-computer-science-a.pdf'},
                  {'year': '2024', 'title': 'AP Computer Science 2024', 'file': 'assets/apfrq/ap24-frq-comp-sci-a.pdf'},
                  {'year': '2023', 'title': 'AP Computer Science 2023', 'file': 'assets/apfrq/ap23-frq-comp-sci-a.pdf'},
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectSection(BuildContext context, String subject, List<Map<String, String>> years) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subject,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...years.map((year) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildYearButton(context, year['title']!, year['year']!, year['file']),
            )),
      ],
    );
  }

  Widget _buildYearButton(BuildContext context, String title, String year, [String? file]) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.blue],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openPDF(context, year, file),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openPDF(BuildContext context, String year, [String? file]) async {
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF file not available for this year'),
          backgroundColor: Colors.red,
        ),
      );
      print('No file provided for year $year');
      return;
    }
    print('Attempting to open PDF: $file');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerScreen(filePath: file, year: year),
      ),
    );
  }
}

class PDFViewerScreen extends StatefulWidget {
  final String filePath;
  final String year;
  const PDFViewerScreen({super.key, required this.filePath, required this.year});

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

  // Manual structure for AP Comp Sci 2024
  final List<String> manualQuestions = [
    'Q1a', 'Q1b', 'Q2', 'Q3a', 'Q3b', 'Q4a', 'Q4b'
  ];
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
          if (_loading)
            const Center(child: CircularProgressIndicator()),
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
                                icon: const Icon(Icons.close, color: Colors.red),
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
                                children: manualQuestions.map((q) {
                                  return ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedSubpart = q;
                                        _answerController.text = answers[q] ?? '';
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(q, style: const TextStyle(color: Colors.white)),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              // Open QuestAI chat modal immediately
                              Navigator.of(context).pop(); // Close the workbook modal
                              await Future.delayed(Duration(milliseconds: 300));
                              _showChatModalAndStartGrading(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Submit Answers', style: TextStyle(fontSize: 16)),
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
                                icon: const Icon(Icons.close, color: Colors.red),
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
                              style: const TextStyle(color: Color(0xFFFFEB3B)), // Yellow text
                              textAlign: TextAlign.left,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xFF1976D2), // Blue background
                                hintText: 'Type your answer here...',
                                hintStyle: const TextStyle(color: Color(0xFFFFF9C4)), // Light yellow hint
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
                                answers[selectedSubpart!] = _answerController.text;
                                selectedSubpart = null;
                              });
                              FocusScope.of(context).unfocus();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Answer saved!')),
                              );
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
                    label: const Text('Answer Workbook', style: TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            )
          : null,
    );
  }

  void _showChatModalAndStartGrading(BuildContext context) async {
    // Show the chat modal immediately (reuse chat modal logic)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('QuestAI Grading'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Grading in progress...'),
          ],
        ),
      ),
    );

    // 1. Read canonical answers and rubrics from the .txt file
    final frqData = await rootBundle.loadString('lib/apcs_2024_frq_answers.txt');
    final Map<String, dynamic> canonical = _parseCanonicalAnswers(frqData);
    final Map<String, dynamic> rubrics = _parseRubrics(frqData);

    // 2. For each subpart, send grading prompt to QuestAI and collect results
    List<FrqGradingResult> gradingResults = [];
    for (final subpart in manualQuestions) {
      final userAnswer = answers[subpart] ?? '';
      final canonicalAnswer = canonical[subpart] ?? '';
      final rubric = rubrics[subpart] ?? '';
      final prompt = _buildGradingPrompt(subpart, userAnswer, canonicalAnswer, rubric);

      // Use ChatBloc and ChatRepo to get grading result
      final chatBloc = ChatBloc();
      final completer = Completer<String>();
      late StreamSubscription sub;
      sub = chatBloc.stream.listen((state) {
        if (state is ChatSuccessState && state.messages.isNotEmpty) {
          final last = state.messages.last;
          if (last.role == "model") {
            completer.complete(last.parts.first.text);
            sub.cancel();
          }
        } else if (state is ChatErrorState) {
          completer.completeError(state.message);
          sub.cancel();
        }
      });
      chatBloc.add(ChatGenerationNewTextMessageEvent(inputMessage: prompt));
      String feedback = '';
      try {
        feedback = await completer.future.timeout(Duration(seconds: 60));
      } catch (e) {
        feedback = 'Error: $e';
      }
      // Parse points awarded from feedback (simple regex or fallback)
      final points = _extractPoints(feedback, subpart, frqData);
      final maxPoints = _extractMaxPoints(subpart, frqData);
      gradingResults.add(FrqGradingResult(
        subpart: subpart,
        userAnswer: userAnswer,
        canonicalAnswer: canonicalAnswer,
        pointsAwarded: points,
        maxPoints: maxPoints,
        feedback: feedback,
      ));
      await Future.delayed(Duration(milliseconds: 500)); // Small delay between requests
    }

    // 3. After all grading, close dialog and navigate to summary screen
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FrqSummaryScreen(results: gradingResults),
      ),
    );
  }

  Map<String, dynamic> _parseCanonicalAnswers(String txt) {
    final Map<String, String> map = {};
    final regex = RegExp(r'Q([\d]+[a-z]?) \(\d+ points\):\n([\s\S]+?)(?=\nQ|\$)');
    for (final match in regex.allMatches(txt)) {
      final key = 'Q${match.group(1)}';
      final value = match.group(2)?.trim() ?? '';
      map[key] = value;
    }
    return map;
  }

  Map<String, dynamic> _parseRubrics(String txt) {
    final Map<String, String> map = {};
    final regex = RegExp(r'QUESTION ([\d]+):([\s\S]+?)(?=QUESTION|Q|$)');
    for (final match in regex.allMatches(txt)) {
      final qnum = match.group(1)?.trim() ?? '';
      final rubric = match.group(2)?.trim() ?? '';
      if (rubric.isNotEmpty) {
        if (rubric.contains('(a)')) map['Q${qnum}a'] = rubric;
        if (rubric.contains('(b)')) map['Q${qnum}b'] = rubric;
        if (!rubric.contains('(a)') && !rubric.contains('(b)')) map['Q${qnum}'] = rubric;
      }
    }
    return map;
  }

  String _buildGradingPrompt(String subpart, String user, String canonical, String rubric) {
    return '''You are an AP Computer Science A FRQ grader. Grade the following student answer for $subpart.\n\nStudent Answer:\n$user\n\nCanonical Answer:\n$canonical\n\nRubric:\n$rubric\n\nGive a score out of the maximum points, and detailed feedback. Format your response as:\nScore: X/Y\nFeedback: ...''';
  }

  int _extractPoints(String feedback, String subpart, String frqData) {
    final regex = RegExp(r'Score:\s*(\d+)\s*/\s*(\d+)');
    final match = regex.firstMatch(feedback);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '') ?? 0;
    }
    // fallback: use 0
    return 0;
  }

  int _extractMaxPoints(String subpart, String frqData) {
    final regex = RegExp('$subpart \\((\\d+) points\\)');
    final match = regex.firstMatch(frqData);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '') ?? 0;
    }
    // fallback: 6
    return 6;
  }
} 