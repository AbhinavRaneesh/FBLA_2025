import 'package:flutter/material.dart';


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:student_learning_app/bloc/chat_bloc.dart';
import '../models/chat_message_model.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});


  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  final TextEditingController followupController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final ChatBloc _chatBloc; // Create bloc instance here


  int currentQuestionIndex = 0;
  String? selectedAnswer;
  bool isWaitingForQuestions = false;


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
    showQuizArea = false; // Ensure quiz area is not shown initially
    showScoreSummary = false;
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
    if (initialMessage != null) {
      _chatBloc
          .add(ChatGenerationNewTextMessageEvent(inputMessage: initialMessage));
    }


    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                  )
                ],
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),


                  // Header
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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Close button with better styling
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.red.withOpacity(0.3)),
                              ),
                              child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(Icons.close,
                                    color: Colors.red[700], size: 20),
                                padding: EdgeInsets.all(4),
                                constraints: BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                tooltip: "Close Chat",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),


                  Divider(height: 1, color: Colors.grey[300]),


                  // Chat messages area
                  Expanded(
                    child: BlocBuilder<ChatBloc, ChatState>(
                      bloc: _chatBloc,
                      builder: (context, state) {
                        if (state is ChatSuccessState) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToBottom();
                          });
                          return ListView.builder(
                            controller: _scrollController,
                            itemCount: state.messages.length,
                            itemBuilder: (context, index) {
                              final message = state.messages[index];
                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 8),
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


                  // Input area
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Colors.grey[300]!)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: followupController,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              fillColor: Colors.grey[100],
                              filled: true,
                              hintText: "Ask something from QuestAI",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(color: Colors.purple),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide:
                                    BorderSide(color: Colors.purple, width: 2),
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
                              if (followupController.text.isNotEmpty) {
                                _chatBloc.add(
                                  ChatGenerationNewTextMessageEvent(
                                    inputMessage: followupController.text,
                                  ),
                                );
                                followupController.clear();
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
            );
          },
        );
      },
    );
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
        }
      }

      print('Found ${questionLines.length} potential question lines');

      // Now parse the collected question lines
      for (String line in questionLines) {
        Map<String, dynamic>? parsedQuestion = _parseBracketFormat(line);
        if (parsedQuestion != null) {
          newQuestions.add(parsedQuestion);
          print('Successfully added question ${newQuestions.length}');
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
          }
        }

        // If still not enough, try splitting by single newlines
        if (newQuestions.length < numberOfQuestions) {
          for (String line in lines) {
            Map<String, dynamic>? parsedQuestion =
                _parseBracketFormat(line.trim());
            if (parsedQuestion != null) {
              newQuestions.add(parsedQuestion);
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
        print('First question: ${newQuestions.first}');

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

        print('State updated - showQuizArea: $showQuizArea, scienceQuestions.length: ${scienceQuestions.length}');

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
          showQuizArea =
              false; // Ensure we stay on configuration screen if parsing fails
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
      print('Exception in parsing: $e');
      setState(() {
        isWaitingForQuestions = false;
        showQuizArea = false;
      });
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
          "correct_answer": parts[5]
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
    setState(() {
      isWaitingForQuestions = true;
    });

    print('Generating $numberOfQuestions questions for: $selectedSubject');

    // Clear any previous questions and answers
    scienceQuestions.clear();
    answeredCorrectly.clear();

    _chatBloc.add(ChatGenerationNewTextMessageEvent(
        inputMessage:
            "Give me exactly $numberOfQuestions $selectedSubject questions in the following format: [question, option1, option2, option3, option4, answerchoice]. "
            "Provide only the questions in this exact format, with no additional text or explanations. "
            "Ensure you provide exactly $numberOfQuestions questions."));

    print('Event added to ChatBloc');
    
    // Add a timeout fallback in case AI doesn't respond
    Future.delayed(Duration(seconds: 30), () {
      if (isWaitingForQuestions && scienceQuestions.isEmpty) {
        print('AI response timeout, using fallback questions');
        _generateFallbackQuestions();
      }
    });
  }

  void _generateFallbackQuestions() {
    print('Generating fallback questions');
    
    List<Map<String, dynamic>> fallbackQuestions = [];
    
    // Generate sample questions based on selected subject
    for (int i = 0; i < numberOfQuestions; i++) {
      fallbackQuestions.add({
        "question": "Sample $selectedSubject question ${i + 1}?",
        "options": [
          "Option A for question ${i + 1}",
          "Option B for question ${i + 1}",
          "Option C for question ${i + 1}",
          "Option D for question ${i + 1}"
        ],
        "correct_answer": "Option A for question ${i + 1}"
      });
    }
    
    setState(() {
      scienceQuestions = fallbackQuestions;
      answeredCorrectly = List.filled(fallbackQuestions.length, false);
      currentQuestionIndex = 0;
      showAnswer = false;
      selectedAnswer = null;
      isWaitingForQuestions = false;
      showQuizArea = true;
      showScoreSummary = false;
    });
    
    print('Fallback questions generated: ${fallbackQuestions.length}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Using sample questions for testing. AI response may be delayed.'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );
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
    setState(() {
      currentQuestionIndex = 0;
      selectedAnswer = null;
      showAnswer = false;
      showScoreSummary = false;
      showQuizArea = false; // Reset to show configuration screen
      scienceQuestions.clear();
      answeredCorrectly.clear();
    });
  }


  void _submitAnswer() {
    setState(() {
      showAnswer = true;
      // Record whether the answer was correct
      answeredCorrectly[currentQuestionIndex] = selectedAnswer ==
          scienceQuestions[currentQuestionIndex]["correct_answer"];
    });
  }


  void _askForExplanation(Map<String, dynamic> question) {
    String userAnswer = selectedAnswer ?? 'No answer selected';
    String correctAnswer = question['correct_answer'];
    bool isCorrect = userAnswer == correctAnswer;
   
    String prompt = '''
Question: ${question['question']}
Options: ${question['options'].join(', ')}
Correct Answer: $correctAnswer
My Answer: $userAnswer
Result: ${isCorrect ? 'Correct' : 'Incorrect'}


Please explain why the correct answer is "$correctAnswer" and provide a detailed explanation of the concept. If I got it wrong, please help me understand where I went wrong.
''';


    _showChatModal(initialMessage: prompt);
  }


  @override
  Widget build(BuildContext context) {
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
        appBar: AppBar(
          title: const Text('QuestAI Quiz'),
          backgroundColor: const Color(0xFF1D1E33),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1D1E33), Color(0xFF2A2B4A)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (!showQuizArea && !showScoreSummary) ...[
                  SizedBox(height: 150), // Increased top padding
                  // Subject Selection Area
                  Text(
                    'Select a Subject',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  DropdownButton<String>(
                    value: selectedSubject,
                    dropdownColor: Colors.grey.shade900,
                    style: TextStyle(color: Colors.white),
                    underline: Container(
                      height: 2,
                      color: Colors.purple,
                    ),
                    items: subjects.map((String subject) {
                      return DropdownMenuItem<String>(
                        value: subject,
                        child: Text(subject),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedSubject = newValue;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  // Number of Questions Selection
                  Text(
                    'Number of Questions',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  DropdownButton<int>(
                    value: numberOfQuestions,
                    dropdownColor: Colors.grey.shade900,
                    style: TextStyle(color: Colors.white),
                    underline: Container(
                      height: 2,
                      color: Colors.purple,
                    ),
                    items: [5, 10, 15, 20].map((int number) {
                      return DropdownMenuItem<int>(
                        value: number,
                        child: Text('$number Questions'),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          numberOfQuestions = newValue;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  BlocBuilder<ChatBloc, ChatState>(
                    bloc: _chatBloc,
                    builder: (context, state) {
                      if (state is ChatSuccessState &&
                          state.messages.isNotEmpty) {
                        // Get the last message from the AI
                        final lastMessage = state.messages.last;
                        if (lastMessage.role == "model") {
                          // Use a more reliable way to trigger parsing
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            print('Parsing AI response: ${lastMessage.parts.first.text}');
                            _parseAndReplaceQuestions(
                                lastMessage.parts.first.text);
                          });
                        }
                      }
                      
                      // Add debug information
                      print('Current state: showQuizArea=$showQuizArea, scienceQuestions.length=${scienceQuestions.length}');
                      
                      return Column(
                        children: [
                          ElevatedButton(
                            onPressed:
                                isWaitingForQuestions ? null : _generateQuestions,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 6,
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFFFD600), // Bright yellow
                                    Color(0xFFFF9800), // Bright orange
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                constraints:
                                    BoxConstraints(minWidth: 150, minHeight: 48),
                                alignment: Alignment.center,
                                child: isWaitingForQuestions
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
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
                                          Text("Generating...",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      )
                                    : Text(
                                        "Start Quiz",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          // Debug button for testing
                          ElevatedButton(
                            onPressed: isWaitingForQuestions ? null : _generateFallbackQuestions,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.withOpacity(0.3),
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              "Test with Sample Questions",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
                if (showQuizArea) _buildQuizArea(),
                if (showScoreSummary) _buildScoreSummary(),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildQuizArea() {
    print('_buildQuizArea called - scienceQuestions.length: ${scienceQuestions.length}');
    print('currentQuestionIndex: $currentQuestionIndex');
    
    if (scienceQuestions.isEmpty) {
      print('No questions available, showing loading indicator');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Loading questions...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'If this takes too long, please try again',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (currentQuestionIndex >= scienceQuestions.length) {
      print('currentQuestionIndex out of bounds, resetting to 0');
      setState(() {
        currentQuestionIndex = 0;
      });
    }

    final q = scienceQuestions[currentQuestionIndex];
    print('Displaying question: ${q['question']}');
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Back button in top left
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Question counter with improved styling
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Text(
              'Question ${currentQuestionIndex + 1} of ${scienceQuestions.length}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Enhanced progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / scienceQuestions.length,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 30),
          // Enhanced question display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Text(
              q['question'] ?? 'Question not available',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),
          // Enhanced options with better visual feedback
          Expanded(
            child: Column(
              children: [
                ...List.generate(
                  (q['options'] as List<dynamic>?)?.length ?? 0,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: showAnswer ? null : () {
                          setState(() {
                            selectedAnswer = q['options'][i];
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getOptionColor(
                            q['options'][i],
                            q['correct_answer'],
                            selectedAnswer,
                            showAnswer,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: _getOptionBorderColor(
                                q['options'][i],
                                q['correct_answer'],
                                selectedAnswer,
                                showAnswer,
                              ),
                              width: 2,
                            ),
                          ),
                          elevation: showAnswer ? 4 : 2,
                        ),
                        child: Row(
                          children: [
                            // Option letter (A, B, C, D)
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _getOptionLetterColor(
                                  q['options'][i],
                                  q['correct_answer'],
                                  selectedAnswer,
                                  showAnswer,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + i), // A, B, C, D
                                  style: TextStyle(
                                    color: _getOptionLetterTextColor(
                                      q['options'][i],
                                      q['correct_answer'],
                                      selectedAnswer,
                                      showAnswer,
                                    ),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Option text
                            Expanded(
                              child: Text(
                                q['options'][i] ?? 'Option not available',
                                style: TextStyle(
                                  color: _getOptionTextColor(
                                    q['options'][i],
                                    q['correct_answer'],
                                    selectedAnswer,
                                    showAnswer,
                                  ),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            // Icon for correct/incorrect feedback
                            if (showAnswer) ...[
                              Icon(
                                q['options'][i] == q['correct_answer']
                                    ? Icons.check_circle
                                    : q['options'][i] == selectedAnswer
                                        ? Icons.cancel
                                        : null,
                                color: q['options'][i] == q['correct_answer']
                                    ? Colors.white
                                    : q['options'][i] == selectedAnswer
                                        ? Colors.white
                                        : Colors.transparent,
                                size: 24,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Enhanced Submit Answer button
                if (selectedAnswer != null && !showAnswer) ...[
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Submit Answer',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                // Enhanced feedback and next options
                if (showAnswer) ...[
                  const SizedBox(height: 20),
                  // Enhanced feedback message
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: selectedAnswer == q['correct_answer']
                          ? Colors.green.withOpacity(0.15)
                          : Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selectedAnswer == q['correct_answer']
                            ? Colors.green.withOpacity(0.5)
                            : Colors.red.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: selectedAnswer == q['correct_answer']
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            selectedAnswer == q['correct_answer']
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: selectedAnswer == q['correct_answer']
                                ? Colors.green
                                : Colors.red,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedAnswer == q['correct_answer']
                                    ? 'Correct!'
                                    : 'Incorrect',
                                style: TextStyle(
                                  color: selectedAnswer == q['correct_answer']
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedAnswer == q['correct_answer']
                                    ? 'Well done! You got it right!'
                                    : 'The correct answer is: ${q['correct_answer']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Enhanced action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: goToNextQuestion,
                          icon: Icon(
                            currentQuestionIndex < scienceQuestions.length - 1
                                ? Icons.arrow_forward
                                : Icons.check_circle,
                            color: Colors.white,
                          ),
                          label: Text(
                            currentQuestionIndex < scienceQuestions.length - 1
                                ? 'Next Question'
                                : 'Finish Quiz',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _askForExplanation(q),
                          icon: const Icon(Icons.lightbulb, color: Colors.white),
                          label: const Text(
                            'Explanation',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for option styling
  Color _getOptionColor(String option, String correctAnswer, String? selectedAnswer, bool showAnswer) {
    if (!showAnswer) {
      return selectedAnswer == option
          ? Colors.blue.withOpacity(0.3)
          : Colors.white.withOpacity(0.1);
    }
    
    if (option == correctAnswer) {
      return Colors.green.withOpacity(0.3);
    } else if (option == selectedAnswer) {
      return Colors.red.withOpacity(0.3);
    } else {
      return Colors.white.withOpacity(0.05);
    }
  }

  Color _getOptionBorderColor(String option, String correctAnswer, String? selectedAnswer, bool showAnswer) {
    if (!showAnswer) {
      return selectedAnswer == option
          ? Colors.blue.withOpacity(0.5)
          : Colors.white.withOpacity(0.2);
    }
    
    if (option == correctAnswer) {
      return Colors.green;
    } else if (option == selectedAnswer) {
      return Colors.red;
    } else {
      return Colors.white.withOpacity(0.1);
    }
  }

  Color _getOptionLetterColor(String option, String correctAnswer, String? selectedAnswer, bool showAnswer) {
    if (!showAnswer) {
      return selectedAnswer == option
          ? Colors.blue
          : Colors.white.withOpacity(0.2);
    }
    
    if (option == correctAnswer) {
      return Colors.green;
    } else if (option == selectedAnswer) {
      return Colors.red;
    } else {
      return Colors.white.withOpacity(0.1);
    }
  }

  Color _getOptionLetterTextColor(String option, String correctAnswer, String? selectedAnswer, bool showAnswer) {
    if (!showAnswer) {
      return selectedAnswer == option
          ? Colors.white
          : Colors.white.withOpacity(0.7);
    }
    
    return Colors.white;
  }

  Color _getOptionTextColor(String option, String correctAnswer, String? selectedAnswer, bool showAnswer) {
    if (!showAnswer) {
      return selectedAnswer == option
          ? Colors.white
          : Colors.white.withOpacity(0.8);
    }
    
    if (option == correctAnswer) {
      return Colors.white;
    } else if (option == selectedAnswer) {
      return Colors.white;
    } else {
      return Colors.white.withOpacity(0.6);
    }
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
                child: Text("New Quiz"),
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
}