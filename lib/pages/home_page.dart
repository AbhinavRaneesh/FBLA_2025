import 'package:flutter/material.dart';
import 'package:student_learning_app/bloc/chat_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/chat_message_model.dart';
import '../database_helper.dart';

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
        }
      }

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
      selectedAnswer = null;
      showAnswer = true;
      if (isCorrect) {
        answeredCorrectly[currentQuestionIndex] = true;
        _dbHelper.updateUserPoints(username, 50);
      }
    });
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
          title: Text("QuestAI Quiz App"),
          backgroundColor: Colors.purple,
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/beach.jpg'),
              fit: BoxFit.cover,
              opacity: 0.5,
            ),
          ),
          child: BlocListener<ChatBloc, ChatState>(
            listener: (context, state) {
              if (state is ChatSuccessState &&
                  isWaitingForQuestions &&
                  state.messages.isNotEmpty) {
                var lastMessage = state.messages.last;
                if (lastMessage.role != "user") {
                  _parseAndReplaceQuestions(lastMessage.parts.first.text);
                }
              }
            },
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      SizedBox(height: 60),
                      Text(
                        "QuestAI Quiz App",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Show different sections based on app state
                      if (showScoreSummary) ...[
                        _buildScoreSummary()
                      ] else if (showQuizArea &&
                          scienceQuestions.isNotEmpty) ...[
                        _buildQuizArea()
                      ] else ...[
                        _buildHomeScreen()
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeScreen() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade800.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                "Quiz Configuration:",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),

              // Subject Selection
              Row(
                children: [
                  Text(
                    "Subject: ",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Expanded(
                    child: DropdownButton<String>(
                      value: selectedSubject,
                      dropdownColor: Colors.grey.shade800,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      isExpanded: true,
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
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Number of Questions Selection
              Row(
                children: [
                  Text(
                    "Questions: ",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Expanded(
                    child: DropdownButton<int>(
                      value: numberOfQuestions,
                      dropdownColor: Colors.grey.shade800,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      isExpanded: true,
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
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Generate Button and Chat Button
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          isWaitingForQuestions ? null : _generateQuestions,
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
                                Text("Generating..."),
                              ],
                            )
                          : Text("Generate Quiz"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showChatModal(),
                      child: Text("Chat with QuestAI"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildQuizArea() {
    return Flexible(
      flex: 10,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Back to Subject Selection Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _returnToHome,
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  label: Text("Back to Home",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
                // Question counter
                Text(
                  "Question ${currentQuestionIndex + 1}/${scienceQuestions.length}",
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade200),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Display science question
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade800.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    scienceQuestions[currentQuestionIndex]["question"]!,
                    style: TextStyle(fontSize: 22, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      String question =
                          scienceQuestions[currentQuestionIndex]["question"]!;
                      String prompt =
                          "Please explain how to solve this question: '$question'. Provide a detailed step-by-step explanation with the fundamental concepts involved.";
                      _showChatModal(initialMessage: prompt);
                    },
                    icon: Icon(Icons.help_outline, color: Colors.white),
                    label: Text("Ask AI for Help"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Multiple choice options
            ...buildMultipleChoiceOptions(),

            SizedBox(height: 16),

            // Submit and Next Question buttons in a row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: selectedAnswer != null ? _submitAnswer : null,
                  child: Text("Submit"),
                ),
                if (showAnswer) // Only show Next Question button after submitting
                  ElevatedButton(
                    onPressed: goToNextQuestion,
                    child: Text(
                      currentQuestionIndex + 1 == scienceQuestions.length
                          ? "Finish Quiz"
                          : "Next Question",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
              ],
            ),

            if (showAnswer)
              Column(
                children: [
                  SizedBox(height: 16),
                  Text(
                    "Correct Answer: ${scienceQuestions[currentQuestionIndex]["answer"]}",
                    style: TextStyle(
                        fontSize: 18,
                        color: selectedAnswer ==
                                scienceQuestions[currentQuestionIndex]["answer"]
                            ? Colors.green
                            : Colors.red),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      String question =
                          scienceQuestions[currentQuestionIndex]["question"]!;
                      String prompt =
                          "Please explain how to solve this question: '$question'. Provide a brief explanation with the fundamental concepts involved.";
                      _showChatModal(initialMessage: prompt);
                    },
                    child: Text("ASK QuestAI for explanation"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildMultipleChoiceOptions() {
    List<String> options = scienceQuestions[currentQuestionIndex]["options"];

    return options.map((option) {
      bool isSelected = selectedAnswer == option;
      bool isCorrectAnswer = showAnswer &&
          option == scienceQuestions[currentQuestionIndex]["answer"];
      bool isWrongSelected = showAnswer &&
          isSelected &&
          option != scienceQuestions[currentQuestionIndex]["answer"];

      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: InkWell(
          onTap: showAnswer
              ? null
              : () {
                  setState(() {
                    selectedAnswer = option;
                  });
                },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCorrectAnswer
                  ? Colors.green.withOpacity(0.9)
                  : isWrongSelected
                      ? Colors.red.withOpacity(0.9)
                      : isSelected
                          ? Colors.blue.withOpacity(0.7)
                          : Colors.grey.shade800.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCorrectAnswer
                    ? Colors.green
                    : isWrongSelected
                        ? Colors.red
                        : isSelected
                            ? Colors.blue
                            : Colors.grey,
                width: isSelected || isWrongSelected || isCorrectAnswer ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                    color: isWrongSelected
                        ? Colors.red
                        : isCorrectAnswer
                            ? Colors.green
                            : isSelected
                                ? Colors.blue
                                : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCorrectAnswer
                          ? Colors.green
                          : isWrongSelected
                              ? Colors.red
                              : isSelected
                                  ? Colors.blue
                                  : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: showAnswer
                      ? (isCorrectAnswer
                          ? Icon(Icons.check, size: 16, color: Colors.white)
                          : isWrongSelected
                              ? Icon(Icons.close, size: 16, color: Colors.white)
                              : null)
                      : (isSelected
                          ? Icon(Icons.check, size: 16, color: Colors.white)
                          : null),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isSelected || isWrongSelected || isCorrectAnswer
                              ? FontWeight.bold
                              : FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (isCorrectAnswer && !isSelected)
                  Icon(Icons.check_circle, color: Colors.green)
              ],
            ),
          ),
        ),
      );
    }).toList();
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
