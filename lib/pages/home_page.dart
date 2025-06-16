import 'package:flutter/material.dart';
import 'package:student_learning_app/bloc/chat_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/chat_message_model.dart';
import '../database_helper.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({
    super.key,
    required this.username,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController followupController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final ChatBloc _chatBloc; // Create bloc instance here
  final DatabaseHelper _dbHelper = DatabaseHelper();

  int currentQuestionIndex = 0;
  String? selectedAnswer;
  bool isWaitingForQuestions = false;
  String username = ''; // Add username field
  int _score = 0;

  List<Map<String, dynamic>> scienceQuestions = [];
  List<bool> answeredCorrectly =
      []; // Track which questions were answered correctly

  bool showAnswer = false;
  bool showQuizArea = false;
  bool showScoreSummary =
      false; // New variable to control score summary visibility
  String selectedSubject = "Chemistry";
  int numberOfQuestions = 10; // New variable for question count

  List<String> subjects = [
    "Chemistry",
    "Physics",
    "Biology",
    "Mathematics",
    "History",
    "Geography",
    "Computer Science",
    "Economics"
  ];

  @override
  void initState() {
    super.initState();
    _chatBloc = ChatBloc(); // Initialize bloc once
    _loadUsername(); // Load username when page initializes
  }

  Future<void> _loadUsername() async {
    // Get the username from shared preferences or wherever it's stored
    // For now, we'll use a default value
    setState(() {
      username = widget.username; // Replace with actual username loading logic
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _chatBloc.close(); // Don't forget to close the bloc
    super.dispose();
  }

  void goToNextQuestion() {
    setState(() {
      if (currentQuestionIndex + 1 >= scienceQuestions.length) {
        // If we've reached the end, show score summary
        showScoreSummary = true;
        showQuizArea = false;
      } else {
        currentQuestionIndex = currentQuestionIndex + 1;
        showAnswer = false;
        selectedAnswer = null;
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Function to clear chat history
  void _clearChatHistory() {
    _chatBloc.add(ChatClearHistoryEvent());
    print('Chat history cleared');
  }

  // Function to show half-screen chat modal
  void _showChatModal({String? initialMessage}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.grey.shade900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AI Assistant',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Divider(color: Colors.grey),
                Expanded(
                  child: BlocBuilder<ChatBloc, ChatState>(
                    bloc: _chatBloc,
                    builder: (context, state) {
                      if (state is ChatSuccessState) {
                        return ListView.builder(
                          controller: _scrollController,
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            final message = state.messages[index];
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: message.role == "user"
                                    ? Colors.blue.withOpacity(0.2)
                                    : Colors.purple.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                message.parts.first.text,
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          },
                        );
                      } else if (state is ChatErrorState) {
                        return Center(
                          child: Text(
                            state.message,
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
                Divider(color: Colors.grey),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: followupController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Ask a follow-up question...',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.send, color: Colors.purple),
                        onPressed: () {
                          if (followupController.text.isNotEmpty) {
                            _chatBloc.add(ChatGenerationNewTextMessageEvent(
                              inputMessage: followupController.text,
                            ));
                            followupController.clear();
                          }
                        },
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

    if (initialMessage != null) {
      _chatBloc.add(ChatGenerationNewTextMessageEvent(
        inputMessage: initialMessage,
      ));
    }
  }

  // Function to parse AI response and extract questions
  void _parseAndReplaceQuestions(String aiResponse) {
    try {
      print('Full AI Response: $aiResponse');
      print('=== PARSING DEBUG ===');

      List<String> lines = aiResponse.split('\n');
      List<Map<String, dynamic>> newQuestions = [];
      List<String> questionLines = [];

      // First, collect all lines that look like questions
      for (String line in lines) {
        String trimmedLine = line.trim();
        if (trimmedLine.startsWith('[') && trimmedLine.endsWith(']')) {
          questionLines.add(trimmedLine);
          print('Found question line: $trimmedLine');
        }
      }

      print('Total question lines found: ${questionLines.length}');

      // Now parse the collected question lines
      for (String line in questionLines) {
        Map<String, dynamic>? parsedQuestion = _parseBracketFormat(line);
        if (parsedQuestion != null) {
          newQuestions.add(parsedQuestion);
          print('Successfully added question ${newQuestions.length}: ${parsedQuestion['question']}');
        } else {
          print('Failed to parse question line: $line');
        }
      }

      print('Total questions parsed: ${newQuestions.length}');

      // If we got fewer questions than requested, try to parse again with a different strategy
      if (newQuestions.length < numberOfQuestions) {
        print('Got fewer questions than requested, trying alternative parsing');
        newQuestions.clear(); // Clear the previous attempts

        // Try splitting by double newlines first
        List<String> potentialQuestions = aiResponse.split('\n\n');
        for (String block in potentialQuestions) {
          Map<String, dynamic>? parsedQuestion =
              _parseBracketFormat(block.trim());
          if (parsedQuestion != null) {
            newQuestions.add(parsedQuestion);
            print('Alternative parsing added question: ${parsedQuestion['question']}');
          }
        }

        // If still not enough, try splitting by single newlines
        if (newQuestions.length < numberOfQuestions) {
          for (String line in lines) {
            Map<String, dynamic>? parsedQuestion =
                _parseBracketFormat(line.trim());
            if (parsedQuestion != null) {
              newQuestions.add(parsedQuestion);
              print('Single line parsing added question: ${parsedQuestion['question']}');
            }
          }
        }
      }

      // If we successfully parsed questions, replace the current ones
      if (newQuestions.isNotEmpty) {
        // Ensure we don't exceed the requested number of questions
        if (newQuestions.length > numberOfQuestions) {
          newQuestions = newQuestions.sublist(0, numberOfQuestions);
        }

        print('Setting state with ${newQuestions.length} questions');
        print('Before setState - showQuizArea: $showQuizArea, scienceQuestions.length: ${scienceQuestions.length}');
        setState(() {
          scienceQuestions = newQuestions;
          answeredCorrectly = List.filled(newQuestions.length, false);
          currentQuestionIndex = 0; // Reset to first question
          showAnswer = false;
          selectedAnswer = null;
          isWaitingForQuestions = false;
          showQuizArea = true; // Show quiz area after questions are generated
          showScoreSummary = false;
        });

        print('After setState - showQuizArea: $showQuizArea, scienceQuestions.length: ${scienceQuestions.length}');
        print('First question: ${scienceQuestions.isNotEmpty ? scienceQuestions[0]['question'] : 'No questions'}');

        // Clear chat history after successful question generation
        _clearChatHistory();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Successfully loaded ${newQuestions.length} new $selectedSubject questions!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // If parsing failed, show error with more details
        print('No questions were parsed successfully');
        setState(() {
          isWaitingForQuestions = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to parse questions. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isWaitingForQuestions = false;
      });
      print('Exception in parsing: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error parsing questions: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Map<String, dynamic>? _parseBracketFormat(String line) {
    try {
      // Remove trailing comma if present
      String cleanLine =
          line.endsWith(',') ? line.substring(0, line.length - 1) : line;

      // Remove [ and ] brackets
      if (!cleanLine.startsWith('[') || !cleanLine.endsWith(']')) {
        return null;
      }

      String content = cleanLine.substring(1, cleanLine.length - 1);

      // Split by comma, but be careful with quoted strings
      List<String> parts = [];
      StringBuffer currentPart = StringBuffer();
      bool inQuotes = false;

      for (int i = 0; i < content.length; i++) {
        String char = content[i];

        if (char == '"') {
          inQuotes = !inQuotes;
          currentPart.write(char);
        } else if (char == ',' && !inQuotes) {
          parts.add(currentPart.toString().trim());
          currentPart.clear();
        } else {
          currentPart.write(char);
        }
      }

      // Add the last part
      parts.add(currentPart.toString().trim());

      // Clean each part (remove surrounding quotes if present)
      for (int i = 0; i < parts.length; i++) {
        if (parts[i].startsWith('"') && parts[i].endsWith('"')) {
          parts[i] = parts[i].substring(1, parts[i].length - 1);
        }
      }

      if (parts.length == 6) {
        return {
          "question": parts[0],
          "options": [parts[1], parts[2], parts[3], parts[4]],
          "answer": parts[5]
        };
      } else {
        print('Expected 6 parts but got ${parts.length}');
        return null;
      }
    } catch (e) {
      print('Error parsing bracket format: $e');
      return null;
    }
  }

  void _generateQuestions() {
    print('_generateQuestions called');
    setState(() {
      isWaitingForQuestions = true;
      showQuizArea = false; // Reset quiz area visibility
    });

    print('Generating $numberOfQuestions questions for: $selectedSubject');

    // Clear any previous questions and answers
    scienceQuestions.clear();
    answeredCorrectly.clear();

    String prompt = """
Generate exactly $numberOfQuestions multiple choice questions for $selectedSubject.
Format each question exactly like this: [question text, option A, option B, option C, option D, correct answer]
Do not include any explanations or additional text, just the questions in this exact format.
Example format:
[What is the chemical symbol for water?, H2O, CO2, NaCl, O2, H2O]
[What is the capital of France?, London, Berlin, Paris, Madrid, Paris]

Generate exactly $numberOfQuestions questions for $selectedSubject:
""";

    _chatBloc.add(ChatGenerationNewTextMessageEvent(inputMessage: prompt));

    print('Event added to ChatBloc');
  }

  void _restartQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      selectedAnswer = null;
      showAnswer = false;
      showScoreSummary = false;
      showQuizArea = true;
      answeredCorrectly = List.filled(scienceQuestions.length, false);
    });
  }

  void _returnToHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _submitAnswer() {
    if (selectedAnswer == null) return;

    final isCorrect =
        selectedAnswer == scienceQuestions[currentQuestionIndex]["answer"];
    setState(() {
      // Don't clear selectedAnswer - keep it to show wrong answer highlighting
      showAnswer = true;
      if (isCorrect) {
        answeredCorrectly[currentQuestionIndex] = true;
        _dbHelper.updateUserPoints(username, 50);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('HomePage build method called - showQuizArea: $showQuizArea, scienceQuestions.length: ${scienceQuestions.length}');
    return BlocProvider.value(
      value: _chatBloc,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showChatModal(),
          backgroundColor: Colors.purple,
          child: Icon(Icons.message, color: Colors.white),
          heroTag: "chatFAB",
        ),
        body: Stack(
          children: [
            const SpaceBackground(),
            SafeArea(
              child: BlocListener<ChatBloc, ChatState>(
                listener: (context, state) {
                  print('BlocListener triggered with state: ${state.runtimeType}');
                  print('isWaitingForQuestions: $isWaitingForQuestions');
                  if (state is ChatSuccessState) {
                    print('ChatSuccessState received with ${state.messages.length} messages');
                    if (isWaitingForQuestions && state.messages.isNotEmpty) {
                      var lastMessage = state.messages.last;
                      print('Last message role: ${lastMessage.role}');
                      if (lastMessage.role != "user") {
                        print('Parsing AI response...');
                        _parseAndReplaceQuestions(lastMessage.parts.first.text);
                      }
                    }
                  }
                },
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    print('BlocBuilder rebuilding. showQuizArea: $showQuizArea, scienceQuestions.length: ${scienceQuestions.length}, showScoreSummary: $showScoreSummary');
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          Expanded(
                            child: showScoreSummary
                                ? _buildScoreSummary()
                                : showQuizArea && scienceQuestions.isNotEmpty
                                    ? _buildQuizArea()
                                    : _buildHomeScreen(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeScreen() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Quiz Configuration Card
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header with icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.quiz,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Quiz Configuration",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Subject Selection
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.school, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Subject",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        DropdownButton<String>(
                          value: selectedSubject,
                          dropdownColor: Colors.purple.shade800,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          isExpanded: true,
                          underline: Container(),
                          items: subjects.map((String subject) {
                            return DropdownMenuItem<String>(
                              value: subject,
                              child: Text(subject),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedSubject = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Number of Questions Selection
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.format_list_numbered, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Number of Questions",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        DropdownButton<int>(
                          value: numberOfQuestions,
                          dropdownColor: Colors.purple.shade800,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          isExpanded: true,
                          underline: Container(),
                          items: List.generate(20, (index) => index + 1)
                              .map((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString()),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            setState(() {
                              numberOfQuestions = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.withOpacity(0.8),
                                Colors.greenAccent.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: isWaitingForQuestions ? null : _generateQuestions,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isWaitingForQuestions
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        "Starting...",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.play_arrow, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        "Start Quiz",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.withOpacity(0.8),
                              Colors.deepOrange.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => _showChatModal(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                "Chat with AI",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // Loading indicator when generating questions
            if (isWaitingForQuestions)
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.2),
                      Colors.purple.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Generating $numberOfQuestions $selectedSubject questions...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "This may take a few moments",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizArea() {
    print('_buildQuizArea called with ${scienceQuestions.length} questions, current index: $currentQuestionIndex');
    if (scienceQuestions.isEmpty) {
      print('No questions available!');
      return Center(
        child: Text(
          'No questions available',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }
    
    if (currentQuestionIndex >= scienceQuestions.length) {
      print('Current index out of bounds!');
      return Center(
        child: Text(
          'Question index out of bounds',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }
    
    final currentQuestion = scienceQuestions[currentQuestionIndex];
    print('Current question: ${currentQuestion['question']}');
    print('Current options: ${currentQuestion['options']}');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with progress
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: _returnToHome,
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Question ${currentQuestionIndex + 1}/${scienceQuestions.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: (currentQuestionIndex + 1) / scienceQuestions.length,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 16),

        // Question
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                currentQuestion["question"]!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  String question = currentQuestion["question"]!;
                  String prompt =
                      "Please explain how to solve this question: '$question'. Provide a detailed step-by-step explanation with the fundamental concepts involved.";
                  _showChatModal(initialMessage: prompt);
                },
                icon: const Icon(Icons.help_outline, color: Colors.white),
                label: const Text("Ask AI for Help"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.withOpacity(0.2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Answer options
        Flexible(
          child: ListView.builder(
            itemCount: currentQuestion["options"].length,
            itemBuilder: (context, index) {
              final option = currentQuestion["options"][index];
              final isSelected = selectedAnswer == option;
              final isCorrect = showAnswer && option == currentQuestion["answer"];
              final isWrong = showAnswer && isSelected && !isCorrect;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 48,
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? Colors.green.withOpacity(0.2)
                        : isWrong
                            ? Colors.red.withOpacity(0.2)
                            : isSelected
                                ? Colors.blueAccent.withOpacity(0.15)
                                : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCorrect
                          ? Colors.green
                          : isWrong
                              ? Colors.red
                              : isSelected
                                  ? Colors.blueAccent
                                  : Colors.white.withOpacity(0.08),
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    dense: true,
                    minVerticalPadding: 0,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    title: Text(
                      option,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: showAnswer
                        ? Icon(
                            isCorrect
                                ? Icons.check_circle
                                : isWrong
                                    ? Icons.cancel
                                    : null,
                            color: isCorrect ? Colors.green : isWrong ? Colors.red : null,
                          )
                        : null,
                    onTap: showAnswer
                        ? null
                        : () {
                            setState(() {
                              selectedAnswer = option;
                            });
                          },
                  ),
                ),
              );
            },
          ),
        ),

        // Navigation Buttons
        if (!showAnswer && selectedAnswer != null)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Submit Answer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
        else if (showAnswer)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: goToNextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      currentQuestionIndex + 1 == scienceQuestions.length
                          ? Colors.green
                          : Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  currentQuestionIndex + 1 == scienceQuestions.length
                      ? 'Finish Quiz'
                      : 'Next Question',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildScoreSummary() {
    int correctAnswers = answeredCorrectly.where((correct) => correct).length;
    double accuracy = (correctAnswers / scienceQuestions.length) * 100;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade800.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Quiz Completed!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Your Score:",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "$correctAnswers / ${scienceQuestions.length}",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Accuracy: ${accuracy.toStringAsFixed(1)}%",
            style: TextStyle(
              fontSize: 20,
              color: accuracy > 70
                  ? Colors.green
                  : accuracy > 40
                      ? Colors.orange
                      : Colors.red,
            ),
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _restartQuiz,
                child: Text("Retry Quiz"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              ElevatedButton(
                onPressed: _returnToHome,
                child: Text("Return Home"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              String prompt =
                  "I scored $correctAnswers out of ${scienceQuestions.length} ($accuracy%) in my $selectedSubject quiz. "
                  "Can you analyze my performance and suggest areas to improve?";
              _showChatModal(initialMessage: prompt);
            },
            child: Text("Get Performance Analysis"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessages(
      List<ChatMessageModel> messages, ScrollController scrollController) {
    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      thickness: 6,
      radius: Radius.circular(10),
      child: ListView.builder(
        controller: scrollController,
        padding: EdgeInsets.all(16),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          bool isUser = message.role == "user";

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment:
                  isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.blue : Colors.purple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75),
                  child: Text(
                    message.parts.first.text,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSubjectSelectionModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select a Subject'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSubjectButton('Science'),
              _buildSubjectButton('Mathematics'),
              _buildSubjectButton('History'),
              _buildSubjectButton('Geography'),
              _buildSubjectButton('English'),
              _buildSubjectButton('Computer Science'),
              _buildSubjectButton('Physics'),
              _buildSubjectButton('Chemistry'),
              _buildSubjectButton('Biology'),
              _buildSubjectButton('Economics'),
              _buildSubjectButton('Psychology'),
              _buildSubjectButton('Literature'),
              _buildSubjectButton('Art'),
              _buildSubjectButton('Music'),
              _buildSubjectButton('Philosophy'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectButton(String subject) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedSubject = subject;
        });
        Navigator.of(context).pop();
      },
      child: Text(subject),
    );
  }
}

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
              left: Random().nextDouble() * MediaQuery.of(context).size.width,
              top: Random().nextDouble() * MediaQuery.of(context).size.height,
              child: AnimatedContainer(
                duration: Duration(seconds: Random().nextInt(3) + 1),
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