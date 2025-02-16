import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'questions.dart';
import 'package:audioplayers/audioplayers.dart'; // For sound effects
import 'dart:math'; // For random star positions

void main() {
  runApp(StudentLearningApp());
}

class StudentLearningApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Learning App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFF0A0E21), // Dark space background
      ),
      home: SignInPage(), // Correctly defined home property
    );
  }
}

class SpaceBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
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
                decoration: BoxDecoration(
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

class GameButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  GameButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, // Reduced width for buttons
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.blueAccent, width: 2),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}

class AnimatedProgressBar extends StatelessWidget {
  final double value;

  AnimatedProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.grey[300],
      ),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        width: MediaQuery.of(context).size.width * value,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.purpleAccent],
          ),
        ),
      ),
    );
  }
}

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dbHelper = DatabaseHelper();
  bool _showPassword = false;

  Future<void> _signIn() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both username and password.')),
      );
      return;
    }

    try {
      final isAuthenticated = await _dbHelper.authenticateUser(username, password);

      if (isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in successful!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(username: username),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid username or password.')),
        );
      }
    } catch (e) {
      print('Error during sign-in: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SpaceBackground(),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 30),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: 'Username',
                                labelStyle: TextStyle(color: Colors.black), // Black text
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person, color: Colors.black), // Black icon
                              ),
                              style: TextStyle(color: Colors.black), // Black text
                            ),
                            SizedBox(height: 15),
                            TextField(
                              controller: _passwordController,
                              obscureText: !_showPassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(color: Colors.black), // Black text
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.lock, color: Colors.black), // Black icon
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                      value: _showPassword,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _showPassword = value ?? false;
                                        });
                                      },
                                    ),
                                    Text('Show Password', style: TextStyle(fontSize: 12, color: Colors.black)), // Black text
                                    SizedBox(width: 8),
                                  ],
                                ),
                              ),
                              style: TextStyle(color: Colors.black), // Black text
                            ),
                            SizedBox(height: 20),
                            GameButton(
                              text: 'Sign In',
                              onPressed: _signIn,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
                        );
                      },
                      child: Text(
                        'Don\'t have an account? Sign up',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dbHelper = DatabaseHelper();
  bool _showPassword = false;

  Future<void> _signUp() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    try {
      final userExists = await _dbHelper.checkIfUserExists(username);

      if (userExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Username already exists. Please choose a different one.')),
        );
        return;
      }

      final success = await _dbHelper.addUser(username, password);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account created successfully!')),
        );

        // Navigate back to the Sign-In page
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong. Please try again.')),
        );
      }
    } catch (e) {
      print('Error during sign-up: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: Color(0xFF1D1E33),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // White back arrow
          onPressed: () {
            Navigator.pop(context); // Go back to the Sign-In page
          },
        ),
      ),
      body: Stack(
        children: [
          SpaceBackground(),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Create an Account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 30),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: 'Username',
                                labelStyle: TextStyle(color: Colors.black), // Black text
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person, color: Colors.black), // Black icon
                              ),
                              style: TextStyle(color: Colors.black), // Black text
                            ),
                            SizedBox(height: 15),
                            TextField(
                              controller: _passwordController,
                              obscureText: !_showPassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(color: Colors.black), // Black text
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.lock, color: Colors.black), // Black icon
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                      value: _showPassword,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _showPassword = value ?? false;
                                        });
                                      },
                                    ),
                                    Text('Show Password', style: TextStyle(fontSize: 12, color: Colors.black)), // Black text
                                    SizedBox(width: 8),
                                  ],
                                ),
                              ),
                              style: TextStyle(color: Colors.black), // Black text
                            ),
                            SizedBox(height: 20),
                            GameButton(
                              text: 'Sign Up',
                              onPressed: _signUp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final String username;

  HomeScreen({required this.username});

  final Map<String, List<Question>> subjectQuestions = {
    'Math': QuestionsRepository.getQuestionsForSubject('Math'),
    'History': QuestionsRepository.getQuestionsForSubject('History'),
    'English': QuestionsRepository.getQuestionsForSubject('English'),
    'Science': QuestionsRepository.getQuestionsForSubject('Science'),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Learn Subjects'),
        backgroundColor: Color(0xFF1D1E33),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: FutureBuilder<int>(
                future: DatabaseHelper().getUserPoints(username),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Text(
                      'Points: ${snapshot.data ?? 0}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  }
                },
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white), // White logout icon
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignInPage()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SpaceBackground(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: subjectQuestions.keys.map((subject) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: GameButton(
                    text: subject,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuestionSelectionScreen(
                            subject: subject,
                            questions: subjectQuestions[subject]!,
                            username: username,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class QuestionSelectionScreen extends StatefulWidget {
  final String subject;
  final List<Question> questions;
  final String username;

  QuestionSelectionScreen({required this.subject, required this.questions, required this.username});

  @override
  _QuestionSelectionScreenState createState() => _QuestionSelectionScreenState();
}

class _QuestionSelectionScreenState extends State<QuestionSelectionScreen> {
  int _numberOfQuestions = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Number of Questions'),
        backgroundColor: Color(0xFF1D1E33),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // White back arrow
          onPressed: () {
            Navigator.pop(context); // Go back to the HomeScreen
          },
        ),
      ),
      body: Stack(
        children: [
          SpaceBackground(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'How many questions do you want to answer?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  '$_numberOfQuestions',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
                Slider(
                  value: _numberOfQuestions.toDouble(),
                  min: 1,
                  max: widget.questions.length.toDouble(),
                  divisions: widget.questions.length - 1,
                  label: _numberOfQuestions.toString(),
                  onChanged: (value) {
                    setState(() {
                      _numberOfQuestions = value.toInt();
                    });
                  },
                ),
                SizedBox(height: 20),
                GameButton(
                  text: 'Start Quiz',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          subject: widget.subject,
                          questions: widget.questions.take(_numberOfQuestions).toList(),
                          username: widget.username,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  final String subject;
  final List<Question> questions;
  final String username;

  QuizScreen({required this.subject, required this.questions, required this.username});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  bool isAnswered = false;
  String? currentAnswerResult;
  int points = 0;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadUserPoints();
  }

  Future<void> _loadUserPoints() async {
    final userPoints = await _dbHelper.getUserPoints(widget.username);
    setState(() {
      points = userPoints;
    });
  }

  Future<void> _updateUserPoints() async {
    await _dbHelper.updateUserPoints(widget.username, points);
  }

  Future<void> playSound(String sound) async {
    await _audioPlayer.play(AssetSource(sound));
  }

  void _checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      isAnswered = true;
      if (answer == widget.questions[currentQuestionIndex].correctAnswer) {
        currentAnswerResult = 'Correct!';
        points += 10;
        _updateUserPoints();
        playSound('correct_answer.mp3'); // Play sound for correct answer
      } else {
        currentAnswerResult =
        'Wrong! The correct answer is: ${widget.questions[currentQuestionIndex].correctAnswer}';
        playSound('wrong_answer.mp3'); // Play sound for wrong answer
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      if (currentQuestionIndex < widget.questions.length - 1) {
        currentQuestionIndex++;
        selectedAnswer = null;
        isAnswered = false;
        currentAnswerResult = null;
      } else {
        _showFinalScore();
      }
    });
  }

  void _showFinalScore() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Quiz Finished!', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Your score: ${currentQuestionIndex + 1}/${widget.questions.length}\nPoints: $points',
              style: TextStyle(fontSize: 18)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('OK', style: TextStyle(fontSize: 18)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Question currentQuestion = widget.questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject),
        backgroundColor: Color(0xFF1D1E33),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // White back arrow
          onPressed: () {
            Navigator.pop(context); // Go back to the QuestionSelectionScreen
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Points: $points',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SpaceBackground(),
          Padding(
            padding: const EdgeInsets.only(top: 50.0), // Move content down
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedProgressBar(
                  value: (currentQuestionIndex + 1) / widget.questions.length,
                ),
                SizedBox(height: 20),
                Text(
                  'Question ${currentQuestionIndex + 1}/${widget.questions.length}:',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  currentQuestion.questionText,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                SizedBox(height: 20),
                ...currentQuestion.options.map((option) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: GameButton(
                      text: option,
                      onPressed: () {
                        _checkAnswer(option);
                      },
                    ),
                  );
                }).toList(),
                if (isAnswered)
                  ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple, // Changed color to purple
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      currentQuestionIndex < widget.questions.length - 1 ? 'Next Question' : 'Finish Quiz',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                if (isAnswered)
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: currentAnswerResult!.startsWith('Correct')
                          ? Colors.green.withOpacity(0.8)
                          : Colors.red.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      currentAnswerResult!,
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
