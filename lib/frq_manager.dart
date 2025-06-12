import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:student_learning_app/bloc/chat_bloc.dart';
import 'screens/frq_summary_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:student_learning_app/pages/score_summary_screen.dart';

class FRQManager extends StatefulWidget {
  const FRQManager({super.key});

  @override
  State<FRQManager> createState() => _FRQManagerState();
}

class _FRQManagerState extends State<FRQManager> {
  String? lastAIResponse;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AP CS A FRQ Practice'),
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
        child: Column(
          children: [
            Expanded(
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => _showChatModalAndStartGrading(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Answer Workbook',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
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

  void _showChatModalAndStartGrading(BuildContext context) async {
    final chatBloc = ChatBloc();
    
    try {
      // Build the prompt content
      StringBuffer promptContent = StringBuffer();
      
      // Add instructions for the AI
      promptContent.writeln('You are an AP Computer Science A FRQ grader. Please grade the following student answers according to the official answers provided.');
      promptContent.writeln('\nPlease provide your response in the following format:');
      promptContent.writeln('\nFor each question, provide:');
      promptContent.writeln('[question number ||| score student got ||| feedback ||| actual answer]');
      promptContent.writeln('Use the string ||| (three vertical bars) as the separator between fields. Do NOT use ||| inside the code or explanation.');
      promptContent.writeln('\nFor the actual answer, you MUST provide:');
      promptContent.writeln('1. The complete, correct code solution (the full method, not just the header; include all lines and braces)');
      promptContent.writeln('2. A brief explanation of what the code does');
      promptContent.writeln('Do NOT just give the method header. Give the full method body and a brief explanation.');
      promptContent.writeln('\nExample format:');
      promptContent.writeln('Q1a ||| 2/3 ||| Good understanding of the concept but missed edge case ||| public void processArray(int[] arr) {');
      promptContent.writeln('    for (int i = 0; i < arr.length; i++) {');
      promptContent.writeln('        if (arr[i] < 0) arr[i] = 0;');
      promptContent.writeln('    }');
      promptContent.writeln('}');
      promptContent.writeln('// This method processes an array by replacing all negative numbers with 0.');
      promptContent.writeln('\nNow, please grade the following answers:\n');
      
      // Add user answers to the prompt
      promptContent.writeln('=== User Answers ===');
      for (String question in manualQuestions) {
        promptContent.writeln('\nQuestion: $question');
        promptContent.writeln('Answer: ${answers[question] ?? "Not answered"}');
        promptContent.writeln('-------------------');
      }
      
      // Load and add the entire answers file to the prompt
      promptContent.writeln('\n=== Official Answers and Rubrics ===');
      final frqData = await rootBundle.loadString('assets/apcs_2024_frq_answers.txt');
      promptContent.writeln(frqData);
      promptContent.writeln('=== End of Official Answers ===\n');

      // Print the content to console
      print(promptContent.toString());

      // Send the content to QuestAI
      chatBloc.add(ChatGenerationNewTextMessageEvent(
        inputMessage: promptContent.toString()
      ));

      // Listen for the AI response
      chatBloc.stream.listen((state) {
        if (state is ChatSuccessState && state.messages.isNotEmpty) {
          final lastMessage = state.messages.last;
          if (lastMessage.role == "model") {
            setState(() {
              lastAIResponse = lastMessage.parts.first.text;
              print('AI Response stored: $lastAIResponse'); // Debug print
            });
            // Debug print for raw AI response
            print('RAW AI RESPONSE:');
            print(lastMessage.parts.first.text);
            // Automatically navigate to the score summary screen
            Navigator.pop(context); // Close chat modal
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScoreSummaryScreen(
                  aiResponse: lastAIResponse!,
                ),
              ),
            );
          }
        }
      });

    } catch (e) {
      print('Error loading answers file: $e');
    }

    // Show the chat modal
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => true,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              final TextEditingController messageController = TextEditingController();
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
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Chat with QuestAI",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                Navigator.pop(context);
                              },
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
                                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                    padding: EdgeInsets.all(12),
                                    alignment: message.role == "user" ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                                      ),
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: message.role == "user" ? Colors.blue : Colors.purple,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        message.parts.first.text,
                                        style: TextStyle(color: Colors.white, fontSize: 16),
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
                                style: TextStyle(color: Colors.purple),
                                decoration: InputDecoration(
                                  hintText: "Ask QuestAI anything...",
                                  hintStyle: TextStyle(color: Colors.purple.withOpacity(0.5)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide(color: Colors.purple),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide(color: Colors.purple, width: 2),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  // Manual structure for AP Comp Sci 2024
  final List<String> manualQuestions = [
    'Q1a', 'Q1b', 'Q2', 'Q3a', 'Q3b', 'Q4a', 'Q4b'
  ];
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
      else if (inRubricSection && currentQuestion != null && RegExp(r'^\([a-z]\)').hasMatch(line)) {
        // This is a subpart like "(a)" or "(b)"
        String subpart = line.substring(0, 3); // "(a)" or "(b)"
        String questionWithSubpart = currentQuestion + subpart.substring(1, 2); // "Q1a" or "Q1b"
        
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
  String? lastAIResponse;

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

  void _showChatModalAndStartGrading(BuildContext context) async {
    final chatBloc = ChatBloc();
    
    try {
      // Build the prompt content
      StringBuffer promptContent = StringBuffer();
      
      // Add instructions for the AI
      promptContent.writeln('You are an AP Computer Science A FRQ grader. Please grade the following student answers according to the official answers provided.');
      promptContent.writeln('\nPlease provide your response in the following format:');
      promptContent.writeln('\nFor each question, provide:');
      promptContent.writeln('[question number ||| score student got ||| feedback ||| actual answer]');
      promptContent.writeln('Use the string ||| (three vertical bars) as the separator between fields. Do NOT use ||| inside the code or explanation.');
      promptContent.writeln('\nFor the actual answer, you MUST provide:');
      promptContent.writeln('1. The complete, correct code solution (the full method, not just the header; include all lines and braces)');
      promptContent.writeln('2. A brief explanation of what the code does');
      promptContent.writeln('Do NOT just give the method header. Give the full method body and a brief explanation.');
      promptContent.writeln('\nExample format:');
      promptContent.writeln('Q1a ||| 2/3 ||| Good understanding of the concept but missed edge case ||| public void processArray(int[] arr) {');
      promptContent.writeln('    for (int i = 0; i < arr.length; i++) {');
      promptContent.writeln('        if (arr[i] < 0) arr[i] = 0;');
      promptContent.writeln('    }');
      promptContent.writeln('}');
      promptContent.writeln('// This method processes an array by replacing all negative numbers with 0.');
      promptContent.writeln('\nNow, please grade the following answers:\n');
      
      // Add user answers to the prompt
      promptContent.writeln('=== User Answers ===');
      for (String question in manualQuestions) {
        promptContent.writeln('\nQuestion: $question');
        promptContent.writeln('Answer: ${answers[question] ?? "Not answered"}');
        promptContent.writeln('-------------------');
      }
      
      // Load and add the entire answers file to the prompt
      promptContent.writeln('\n=== Official Answers and Rubrics ===');
      final frqData = await rootBundle.loadString('assets/apcs_2024_frq_answers.txt');
      promptContent.writeln(frqData);
      promptContent.writeln('=== End of Official Answers ===\n');

      // Print the content to console
      print(promptContent.toString());

      // Send the content to QuestAI
      chatBloc.add(ChatGenerationNewTextMessageEvent(
        inputMessage: promptContent.toString()
      ));

      // Listen for the AI response
      chatBloc.stream.listen((state) {
        if (state is ChatSuccessState && state.messages.isNotEmpty) {
          final lastMessage = state.messages.last;
          if (lastMessage.role == "model") {
            setState(() {
              lastAIResponse = lastMessage.parts.first.text;
              print('AI Response stored: $lastAIResponse'); // Debug print
            });
            // Debug print for raw AI response
            print('RAW AI RESPONSE:');
            print(lastMessage.parts.first.text);
            // Automatically navigate to the score summary screen
            Navigator.pop(context); // Close chat modal
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScoreSummaryScreen(
                  aiResponse: lastAIResponse!,
                ),
              ),
            );
          }
        }
      });

    } catch (e) {
      print('Error loading answers file: $e');
    }

    // Show the chat modal
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => true,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              final TextEditingController messageController = TextEditingController();
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
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Chat with QuestAI",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                Navigator.pop(context);
                              },
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
                                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                    padding: EdgeInsets.all(12),
                                    alignment: message.role == "user" ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                                      ),
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: message.role == "user" ? Colors.blue : Colors.purple,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        message.parts.first.text,
                                        style: TextStyle(color: Colors.white, fontSize: 16),
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
                                style: TextStyle(color: Colors.purple),
                                decoration: InputDecoration(
                                  hintText: "Ask QuestAI anything...",
                                  hintStyle: TextStyle(color: Colors.purple.withOpacity(0.5)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide(color: Colors.purple),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide(color: Colors.purple, width: 2),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              final TextEditingController messageController = TextEditingController();
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
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Chat with QuestAI",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                Navigator.pop(context);
                              },
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
                                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                    padding: EdgeInsets.all(12),
                                    alignment: message.role == "user" ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                                      ),
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: message.role == "user" ? Colors.blue : Colors.purple,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        message.parts.first.text,
                                        style: TextStyle(color: Colors.white, fontSize: 16),
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
                                style: TextStyle(color: Colors.purple),
                                decoration: InputDecoration(
                                  hintText: "Ask QuestAI anything...",
                                  hintStyle: TextStyle(color: Colors.purple.withOpacity(0.5)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide(color: Colors.purple),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide(color: Colors.purple, width: 2),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                              // Print all user answers to console
                              print('\n=== User Answers ===');
                              for (String question in manualQuestions) {
                                print('Question: $question');
                                print('Answer: ${answers[question] ?? "Not answered"}');
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