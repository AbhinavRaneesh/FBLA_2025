
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as excel;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:student_learning_app/frq_manager.dart';
import 'package:student_learning_app/mcq_manager.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'database_helper.dart';
import 'questions.dart' as quiz;
import 'premade_sets_screen.dart';
import 'premade_study_sets.dart' as premade;
import 'package:student_learning_app/pages/home_page.dart';
import 'package:student_learning_app/bloc/chat_bloc.dart';
import 'package:student_learning_app/models/chat_message_model.dart';
import 'mcq_manager.dart';
import 'frq_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const StudentLearningApp());
}

class StudentLearningApp extends StatelessWidget {
  const StudentLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduQuest',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          displayMedium: TextStyle(
              fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 4,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        this.context,
        PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) =>
              SignInPage(),
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/eduquest_logo.png',
                      height: 150,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'EduQuest',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Learn. Play. Grow.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
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
}

class FlappyBirdGameScreen extends StatefulWidget {
  final String username;
  final String currentTheme;
  final List<quiz.Question> questions;

  const FlappyBirdGameScreen({
    super.key,
    required this.username,
    required this.currentTheme,
    required this.questions,
  });

  @override
  _FlappyBirdGameScreenState createState() => _FlappyBirdGameScreenState();
}

class _FlappyBirdGameScreenState extends State<FlappyBirdGameScreen> {
  double birdY = 0.4; // Initial vertical position of the bird (0 to 1)
  double birdVelocity = 0.0; // Vertical velocity of the bird
  double gravity = 0.0003; // Further reduced gravity for even slower fall
  double jumpStrength =
      -0.01; // Even smaller jump strength for minimal vertical movement
  List<double> obstacleX = [1.0, 2.0, 3.0]; // Initial X positions of obstacles
  List<double> obstacleHeights = [
    0.3,
    0.4,
    0.5
  ]; // Random heights for obstacles
  double obstacleWidth = 0.2; // Width of the obstacles
  double obstacleGap = 0.3; // Gap between top and bottom obstacles
  int score = 0; // Player's score
  bool isGameOver = false; // Whether the game is over
  Timer? gameTimer; // Timer for game updates
  int currentQuestionIndex = 0; // Current question index
  bool isPausedForQuestion = false; // Whether the game is paused for a question
  Random random = Random(); // Random number generator

  // Define minimum and maximum distance between obstacles
  final double minObstacleDistance = 1.0; // Minimum distance between obstacles
  final double maxObstacleDistance = 1.5; // Maximum distance between obstacles

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    // Initialize random obstacle heights
    for (int i = 0; i < obstacleHeights.length; i++) {
      obstacleHeights[i] =
          0.2 + random.nextDouble() * 0.5; // Random height between 0.2 and 0.7
    }

    // Game loop: updates bird and obstacle positions
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!isPausedForQuestion && !isGameOver) {
        setState(() {
          // Apply gravity to the bird
          birdVelocity += gravity;
          birdY += birdVelocity;

          // Prevent the bird from going too high
          if (birdY < 0.1) {
            birdY = 0.1;
            birdVelocity = 0.0;
          }

          // Move obstacles to the left
          for (int i = 0; i < obstacleX.length; i++) {
            obstacleX[i] -= 0.008; // Slower obstacle movement
            if (obstacleX[i] < -obstacleWidth) {
              // Reset obstacle position and randomize height
              double previousObstacleX =
                  obstacleX[(i - 1 + obstacleX.length) % obstacleX.length];
              double newX = previousObstacleX +
                  minObstacleDistance +
                  random.nextDouble() *
                      (maxObstacleDistance - minObstacleDistance);
              obstacleX[i] = newX;
              obstacleHeights[i] = 0.2 +
                  random.nextDouble() *
                      0.5; // Random height between 0.2 and 0.7
              score++; // Increase score when passing an obstacle

              // Show a question every 5 points
              if (score % 5 == 0) {
                isPausedForQuestion = true;
                showQuestion();
              }
            }
          }

          // Check for collisions with top or bottom of the screen
          if (birdY < 0 || birdY > 1) {
            endGame(); // End the game if the bird hits the top or bottom
          }

          // Check for collisions with obstacles
          for (int i = 0; i < obstacleX.length; i++) {
            if (obstacleX[i] < 0.2 && obstacleX[i] + obstacleWidth > 0.1) {
              // Bird is within the horizontal range of an obstacle
              if (birdY < obstacleHeights[i] ||
                  birdY > obstacleHeights[i] + obstacleGap) {
                // Bird hits the top or bottom obstacle
                endGame();
              }
            }
          }
        });
      }
    });
  }

  void endGame() {
    setState(() {
      isGameOver = true;
    });
    gameTimer?.cancel(); // Stop the game loop

    // Show game over dialog
    showDialog(
      context: this.context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) => Theme(
        data: Theme.of(context).copyWith(
          dialogBackgroundColor: widget.currentTheme == 'beach'
              ? Colors.orange.withOpacity(0.9)
              : const Color(0xFF1D1E33),
          textTheme: Theme.of(context).textTheme.copyWith(
                titleLarge: TextStyle(
                  fontSize: 28, // Larger title
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Always black
                ),
                bodyMedium: TextStyle(
                  fontSize: 22, // Larger body text
                  color: Colors.black, // Always black
                ),
              ),
        ),
        child: AlertDialog(
          title: Text(
            'Game Over',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Always black
            ),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'Your score: $score',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.black, // Always black
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Return to the home screen
              },
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black, // Always black
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showQuestion() {
    // Show a question dialog
    showDialog(
      context: this.context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) => Theme(
        data: Theme.of(context).copyWith(
          dialogBackgroundColor: widget.currentTheme == 'beach'
              ? Colors.orange.withOpacity(0.9)
              : const Color(0xFF1D1E33),
          textTheme: Theme.of(context).textTheme.copyWith(
                titleLarge: TextStyle(
                  fontSize: 28, // Larger title
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Always black
                ),
                bodyMedium: TextStyle(
                  fontSize: 22, // Larger body text
                  color: Colors.black, // Always black
                ),
              ),
        ),
        child: AlertDialog(
          title: Text(
            'Answer the Question',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Always black
            ),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      widget.questions[currentQuestionIndex].questionText,
                      style: TextStyle(
                        fontSize: 22, // Larger question text
                        color: Colors.black, // Always black
                      ),
                    ),
                    const SizedBox(height: 20), // Add spacing
                    ...widget.questions[currentQuestionIndex].options
                        .map((option) => Container(
                              margin: const EdgeInsets.only(
                                  bottom: 10), // Add spacing between buttons
                              child: ElevatedButton(
                                onPressed: () {
                                  if (option ==
                                      widget.questions[currentQuestionIndex]
                                          .correctAnswer) {
                                    // Correct answer: resume the game
                                    setState(() {
                                      isPausedForQuestion = false;
                                      currentQuestionIndex =
                                          (currentQuestionIndex + 1) %
                                              widget.questions.length;
                                    });
                                    Navigator.pop(context); // Close the dialog
                                  } else {
                                    // Incorrect answer: end the game
                                    Navigator.pop(
                                        context); // Close the question dialog
                                    endGame(); // Show the game over dialog
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      widget.currentTheme == 'beach'
                                          ? Colors.orange
                                          : Colors.blueAccent,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16), // Larger button padding
                                ),
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 20, // Larger button text
                                    color: Colors.black, // Always black
                                  ),
                                ),
                              ),
                            )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel(); // Clean up the game timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.currentTheme == 'beach'
          ? Colors.orange.withOpacity(0.1)
          : const Color(0xFF1A1A2E),
      body: Stack(
        children: [
          // Background
          widget.currentTheme == 'beach'
              ? Image.asset(
                  'assets/images/beach.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              : const SpaceBackground(),

          // Bird
          Positioned(
            left: 50,
            top: MediaQuery.of(context).size.height * birdY,
            child: Image.asset(
              'assets/images/bird.png',
              width: 50,
              height: 50,
            ),
          ),

          // Obstacles
          for (int i = 0; i < obstacleX.length; i++) ...[
            // Top obstacle
            Positioned(
              left: MediaQuery.of(context).size.width * obstacleX[i],
              top: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * obstacleWidth,
                height: MediaQuery.of(context).size.height * obstacleHeights[i],
                color: Colors.green,
              ),
            ),
            // Bottom obstacle
            Positioned(
              left: MediaQuery.of(context).size.width * obstacleX[i],
              top: MediaQuery.of(context).size.height *
                  (obstacleHeights[i] + obstacleGap),
              child: Container(
                width: MediaQuery.of(context).size.width * obstacleWidth,
                height: MediaQuery.of(context).size.height *
                    (1 - obstacleHeights[i] - obstacleGap),
                color: Colors.green,
              ),
            ),
          ],

          // Score
          Positioned(
            top: 50,
            left: 20,
            child: Text(
              'Score: $score',
              style: TextStyle(
                fontSize: 24,
                color: widget.currentTheme == 'beach'
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ),
        ],
      ),
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

class GameButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSelected;
  final bool? isCorrect;
  final String currentTheme;

  const GameButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isSelected = false,
    this.isCorrect,
    required this.currentTheme,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = const Color(0xFF1D1E33);
    Color borderColor = Colors.blueAccent;
    Color textColor = Colors.white;

    if (currentTheme == 'beach') {
      backgroundColor = Colors.orange.withOpacity(0.2);
      borderColor = Colors.orange;
      textColor = Colors.black;
    }

    if (isSelected && isCorrect != null) {
      backgroundColor = isCorrect! ? Colors.green : Colors.red;
      borderColor = isCorrect! ? Colors.green : Colors.red;
      textColor = Colors.white;
    } else if (isCorrect == true) {
      backgroundColor = Colors.green;
      borderColor = Colors.green;
      textColor = Colors.white;
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.9, // Adjust width
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(
              vertical: 15, horizontal: 20), // Adjust padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: borderColor, width: 2),
          ),
          elevation: 5,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16, // Adjust font size
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dbHelper = DatabaseHelper();
  bool _obscurePassword = true;
  bool _isFormValid = false;
  bool _rememberAccount = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_updateFormState);
    _passwordController.addListener(_updateFormState);
    _loadSavedCredentials();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _usernameController.text = prefs.getString('saved_username') ?? '';
      _passwordController.text = prefs.getString('saved_password') ?? '';
      _rememberAccount = prefs.getBool('remember_account') ?? false;
    });
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberAccount) {
      await prefs.setString('saved_username', _usernameController.text);
      await prefs.setString('saved_password', _passwordController.text);
      await prefs.setBool('remember_account', true);
    } else {
      await prefs.remove('saved_username');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_account', false);
    }
  }

  @override
  void dispose() {
    _usernameController.removeListener(_updateFormState);
    _passwordController.removeListener(_updateFormState);
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _updateFormState() {
    setState(() {
      _isFormValid = _usernameController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    });
  }

  Future<void> _signIn() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.mediumImpact();

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (username.isEmpty || password.isEmpty) {
        throw Exception('Please fill in all fields');
      }

      final isAuthenticated =
          await _dbHelper.authenticateUser(username, password);

      if (isAuthenticated) {
        await _saveCredentials(); // Save credentials if remember is checked
        HapticFeedback.heavyImpact();
        if (!mounted) return;
        Navigator.pushReplacement(
          this.context,
          CustomPageRoute(
            page: MainScreen(username: username),
            routeName: '/home',
          ),
        );
      } else {
        HapticFeedback.vibrate();
        if (!mounted) return;
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Invalid username or password'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error during sign-in: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(
            content: Text('Google sign in was cancelled'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      HapticFeedback.heavyImpact();
      if (!mounted) return;
      Navigator.pushReplacement(
        this.context,
        CustomPageRoute(
          page: MainScreen(username: googleUser.email),
          routeName: '/home',
        ),
      );
    } catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in with Google: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const SpaceBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/eduquest_logo.png',
                              height: 120,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Welcome to EduQuest',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sign in to continue your journey',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Form
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            // Username field
                            TextFormField(
                              controller: _usernameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Username',
                                labelStyle:
                                    const TextStyle(color: Colors.white70),
                                prefixIcon: const Icon(Icons.person,
                                    color: Colors.white70),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Password field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle:
                                    const TextStyle(color: Colors.white70),
                                prefixIcon: const Icon(Icons.lock,
                                    color: Colors.white70),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Remember Account Checkbox
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberAccount,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _rememberAccount = value ?? false;
                                    });
                                  },
                                  activeColor: Colors.blueAccent,
                                ),
                                const Text(
                                  'Remember Account',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Sign In button
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _isFormValid
                                      ? [
                                          const Color(0xFF4facfe),
                                          const Color(0xFF00f2fe)
                                        ]
                                      : [Colors.grey, Colors.grey.shade700],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: _isFormValid
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF4facfe)
                                              .withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : (_isFormValid ? _signIn : null),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Google Sign In button
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : _signInWithGoogle,
                              icon: Image.asset(
                                'assets/images/google_icon.png',
                                height: 24,
                              ),
                              label: const Text('Sign in with Google'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Sign up text
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  CustomPageRoute(
                                    page: SignUpPage(),
                                    routeName: '/signup',
                                  ),
                                );
                              },
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: Colors.white70),
                                  children: [
                                    const TextSpan(
                                        text: 'Don\'t have an account? '),
                                    TextSpan(
                                      text: 'Sign Up',
                                      style: TextStyle(
                                        color: Colors.blueAccent[200],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dbHelper = DatabaseHelper();
  bool _obscurePassword = true;
  bool _isFormValid = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_updateFormState);
    _passwordController.addListener(_updateFormState);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _usernameController.removeListener(_updateFormState);
    _passwordController.removeListener(_updateFormState);
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _updateFormState() {
    setState(() {
      _isFormValid = _usernameController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    });
  }

  Future<void> _signUp() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (username.isEmpty || password.isEmpty) {
        throw Exception('Please fill in all fields');
      }

      final userExists = await _dbHelper.usernameExists(username);

      if (userExists) {
        throw Exception('Username already exists. Please choose another.');
      }

      final success = await _dbHelper.addUser(username, password);
      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Account created successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        Navigator.pop(this.context);
      } else {
        throw Exception('Something went wrong. Please try again.');
      }
    } catch (e) {
      debugPrint('Error during sign-up: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const SpaceBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/eduquest_logo.png',
                              height: 120,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Create Your Account',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Join the quest for knowledge',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Form
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            // Username field
                            TextFormField(
                              controller: _usernameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Username',
                                labelStyle:
                                    const TextStyle(color: Colors.white70),
                                prefixIcon: const Icon(Icons.person,
                                    color: Colors.white70),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Password field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle:
                                    const TextStyle(color: Colors.white70),
                                prefixIcon: const Icon(Icons.lock,
                                    color: Colors.white70),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Sign Up button
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _isFormValid
                                      ? [
                                          const Color(0xFF4facfe),
                                          const Color(0xFF00f2fe)
                                        ]
                                      : [Colors.grey, Colors.grey.shade700],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: _isFormValid
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF4facfe)
                                              .withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : (_isFormValid ? _signUp : null),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Sign Up',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Sign in text
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: Colors.white70),
                                  children: [
                                    const TextSpan(
                                        text: 'Already have an account? '),
                                    TextSpan(
                                      text: 'Sign In',
                                      style: TextStyle(
                                        color: Colors.blueAccent[200],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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

class MainScreen extends StatefulWidget {
  final String username;

  const MainScreen({
    super.key,
    required this.username,
  });

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String _currentTheme = 'space';
  int _userPoints = 0;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _studySets = [];
  List<Map<String, dynamic>> _premadeStudySets = [];
  bool _isLoading = true;
  int _learnTabIndex = 0; // Add this line to track the Learn tab index

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadStudySets();
  }

  Future<void> _loadUserData() async {
    final points = await _dbHelper.getUserPoints(widget.username);
    final theme = await _dbHelper.getCurrentTheme(widget.username);
    setState(() {
      _userPoints = points;
      _currentTheme = theme ?? 'space';
    });
  }

  Future<void> _loadStudySets() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final userSets = await _dbHelper.getUserStudySets(widget.username);
    final importedSets = await _dbHelper.getUserImportedSets(widget.username);
    if (mounted) {
      setState(() {
        _studySets = userSets;
        _premadeStudySets = importedSets;
        _isLoading = false;
      });
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _updatePoints(int newPoints) {
    setState(() {
      _userPoints = newPoints;
    });
  }

  void _updateTheme(String newTheme) {
    setState(() {
      _currentTheme = newTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _children = [
      LearnTab(
        username: widget.username,
        userPoints: _userPoints,
        currentTheme: _currentTheme,
        onPointsUpdated: _updatePoints,
        onTabChanged: (index) {
          // Add this callback
          setState(() {
            _learnTabIndex = index;
          });
        },
      ),
      ShopTab(
        username: widget.username,
        userPoints: _userPoints,
        currentTheme: _currentTheme,
        onPointsUpdated: _updatePoints,
        onThemeChanged: _updateTheme,
      ),
      ProfileTab(
        username: widget.username,
        userPoints: _userPoints,
        currentTheme: _currentTheme,
      ),
    ];

    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onTabTapped,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1D1E33),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white70,
        elevation: 20,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: (_currentIndex == 0 &&
              _learnTabIndex == 0) // Show only on My Sets tab
          ? Padding(
              padding: const EdgeInsets.only(bottom: 16.0, left: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF667eea),
                          Color(0xFF764ba2)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF667eea).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudySetCreationOptionsScreen(
                              username: widget.username,
                              onStudySetCreated: _loadStudySets,
                            ),
                          ),
                        );
                      },
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Create Set',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

class LearnTab extends StatefulWidget {
  final String username;
  final int userPoints;
  final String currentTheme;
  final Function(int) onPointsUpdated;
  final Function(int) onTabChanged; // Add this callback

  const LearnTab({
    super.key,
    required this.username,
    required this.userPoints,
    required this.currentTheme,
    required this.onPointsUpdated,
    required this.onTabChanged, // Add this parameter
  });

  @override
  _LearnTabState createState() => _LearnTabState();
}

class _LearnTabState extends State<LearnTab>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _studySets = [];
  List<Map<String, dynamic>> _premadeStudySets = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadStudySets();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0); // Set initial tab to My Sets
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        widget.onTabChanged(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStudySets() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final userSets = await _dbHelper.getUserStudySets(widget.username);
    final importedSets = await _dbHelper.getUserImportedSets(widget.username);
    if (mounted) {
      setState(() {
        _studySets = userSets;
        _premadeStudySets = importedSets;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Stack(
        children: [
          const SpaceBackground(),
          SafeArea(
            child: Column(
              children: [
                // Header with points
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${widget.username}!',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Let\'s learn something new today!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.amber, Colors.orange],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 5),
                            Text(
                              '${widget.userPoints}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Add vertical space
                const SizedBox(height: 32),
                // Study Sets Content
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 0),
                              child: TabBar(
                                controller: _tabController,
                                labelColor: Colors.white,
                                unselectedLabelColor: Colors.white70,
                                indicatorColor: Colors.blueAccent,
                                tabs: const [
                                  Tab(text: 'My Sets'),
                                  Tab(text: 'Browse'),
                                  Tab(text: 'Quick Play'),
                                ],
                              ),
                            ),
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildMyStudySets(),
                                  _buildBrowseTab(),
                                  _buildQuickPlayTab(),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyStudySets() {
    final allSets = [..._studySets, ..._premadeStudySets];
    if (allSets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              'No study sets yet',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Create your first study set or import a premade one!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  this.context,
                  MaterialPageRoute(
                    builder: (context) => PremadeSetsScreen(
                      username: widget.username,
                      onSetImported: _loadStudySets,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.download),
              label: const Text('Browse Premade Sets'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allSets.length,
      itemBuilder: (BuildContext context, int index) {
        final studySet = allSets[index];
        final isImported =
            _premadeStudySets.any((s) => s['id'] == studySet['id']);
        return Card(
          margin: const EdgeInsets.only(bottom: 20),
          elevation: 10,
          shadowColor: Colors.black.withOpacity(0.4),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2A2D3E).withOpacity(0.9),
                  const Color(0xFF1D1E33),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _getSubjectIcon(studySet['name']),
                          color: Colors.blueAccent,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              studySet['name'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              studySet['description'] ?? '',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isImported)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Imported',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Created: ${_formatDate(studySet['created_at'])}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _deleteStudySet(studySet['id']),
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent.withOpacity(0.8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => _startPractice(studySet),
                        icon: const Icon(Icons.play_arrow, size: 18),
                        label: const Text('Practice'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.withOpacity(0.8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBrowseTab() {
    return MCQManager(
      username: widget.username,
      onSetImported: _loadStudySets,
      studySet: {}, // Empty map for browse tab
      currentTheme: 'default', // Default theme for browse tab
    );
  }

  Widget _buildQuickPlayTab() {
    return HomePage(username: widget.username);
  }

  Widget _buildQuickPlay() {
    // This method has been removed - quiz configuration moved to home_page.dart
    return Container();
  }

  IconData _getSubjectIcon(String setName) {
    if (setName.toLowerCase().contains('math')) {
      return Icons.calculate;
    } else if (setName.toLowerCase().contains('physics')) {
      return Icons.science;
    } else if (setName.toLowerCase().contains('computer')) {
      return Icons.computer;
    } else if (setName.toLowerCase().contains('chemistry')) {
      return Icons.science;
    } else {
      return Icons.school;
    }
  }

  Widget _buildQuizArea(
    Map<String, dynamic> question,
    int currentIndex,
    int totalQuestions,
    String? selectedAnswer,
    bool showAnswer,
    VoidCallback submitAnswer,
    VoidCallback nextQuestion,
    VoidCallback selectOption1,
    VoidCallback selectOption2,
    VoidCallback selectOption3,
    VoidCallback selectOption4,
  ) {
    return Builder(
      builder: (BuildContext context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
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
                    'Question ${currentIndex + 1}/$totalQuestions',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (currentIndex + 1) / totalQuestions,
                backgroundColor: Colors.white24,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 32),

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
              child: Text(
                question['question'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),

            // Answer options
            Expanded(
              child: ListView.builder(
                itemCount: question['options'].length,
                itemBuilder: (context, index) {
                  final option = question['options'][index];
                  final isSelected = selectedAnswer == option;
                  final isCorrect =
                      showAnswer && option == question['correct_answer'];
                  final isWrong = showAnswer && isSelected && !isCorrect;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? Colors.green.withOpacity(0.2)
                            : isWrong
                                ? Colors.red.withOpacity(0.2)
                                : isSelected
                                    ? Colors.blueAccent.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCorrect
                              ? Colors.green
                              : isWrong
                                  ? Colors.red
                                  : isSelected
                                      ? Colors.blueAccent
                                      : Colors.white.withOpacity(0.1),
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        title: Text(
                          option,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: showAnswer
                            ? Icon(
                                isCorrect
                                    ? Icons.check_circle
                                    : isWrong
                                        ? Icons.cancel
                                        : null,
                                color: isCorrect ? Colors.green : Colors.red,
                              )
                            : null,
                        onTap: showAnswer
                            ? null
                            : () {
                                switch (index) {
                                  case 0:
                                    selectOption1();
                                    break;
                                  case 1:
                                    selectOption2();
                                    break;
                                  case 2:
                                    selectOption3();
                                    break;
                                  case 3:
                                    selectOption4();
                                    break;
                                }
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
                    onPressed: submitAnswer,
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
                    onPressed: nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentIndex < totalQuestions - 1
                          ? Colors.blueAccent
                          : Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      currentIndex < totalQuestions - 1
                          ? 'Next Question'
                          : 'Finish Quiz',
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
      },
    );
  }

  Widget _buildScoreSummary(
    List<bool> answeredCorrectly,
    int totalQuestions,
    String subject,
    VoidCallback restartQuiz,
    VoidCallback returnToConfig,
  ) {
    int correctAnswers = answeredCorrectly.where((correct) => correct).length;
    double accuracy = (correctAnswers / totalQuestions) * 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade800.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Quiz Completed!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Your Score:",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "$correctAnswers / $totalQuestions",
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: restartQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "Retry Quiz",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: returnToConfig,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "New Quiz",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  }

  void _startPractice(Map<String, dynamic> studySet) {
    // Check if this is AP Computer Science A
    String studySetName = studySet['name']?.toString().toLowerCase() ?? '';
    bool isAPCompSciA = studySetName.contains('ap computer science a') || 
                       studySetName.contains('ap comp sci a') ||
                       studySetName.contains('apcsa');
    
    if (isAPCompSciA) {
      // Show practice mode selection for AP Computer Science A
      Navigator.push(
        this.context,
        MaterialPageRoute(
          builder: (context) => PracticeTypeChoiceScreen(
            studySet: studySet,
            username: widget.username,
            currentTheme: widget.currentTheme,
          ),
        ),
      );
    } else {
      // Go directly to MCQ practice for all other courses
      Navigator.push(
        this.context,
        MaterialPageRoute(
          builder: (context) => PracticeModeScreen(
            studySet: studySet,
            username: widget.username,
            currentTheme: widget.currentTheme,
          ),
        ),
      );
    }
  }

  void _deleteStudySet(int studySetId) {
    showDialog(
      context: this.context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Study Set'),
        content: const Text('Are you sure you want to delete this study set?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _dbHelper.removeImportedSet(widget.username, studySetId);
              Navigator.pop(context);
              _loadStudySets();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class ShopTab extends StatefulWidget {
  final String username;
  final int userPoints;
  final String currentTheme;
  final Function(int) onPointsUpdated;
  final Function(String) onThemeChanged;

  const ShopTab({
    super.key,
    required this.username,
    required this.userPoints,
    required this.currentTheme,
    required this.onPointsUpdated,
    required this.onThemeChanged,
  });

  @override
  _ShopTabState createState() => _ShopTabState();
}

class _ShopTabState extends State<ShopTab> with AutomaticKeepAliveClientMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  bool get wantKeepAlive => true;

  final List<Map<String, dynamic>> _themes = [
    {
      'name': 'Space',
      'price': 0,
      'color': const Color(0xFF0A0E21),
      'description': 'Classic space theme',
      'icon': Icons.rocket_launch,
    },
    {
      'name': 'Ocean',
      'price': 100,
      'color': const Color(0xFF006994),
      'description': 'Deep ocean vibes',
      'icon': Icons.waves,
    },
    {
      'name': 'Forest',
      'price': 100,
      'color': const Color(0xFF2E7D32),
      'description': 'Natural forest feel',
      'icon': Icons.forest,
    },
    {
      'name': 'Sunset',
      'price': 150,
      'color': const Color(0xFFFF6D00),
      'description': 'Warm sunset colors',
      'icon': Icons.wb_sunny,
    },
    {
      'name': 'Purple',
      'price': 100,
      'color': const Color(0xFF6A1B9A),
      'description': 'Royal purple theme',
      'icon': Icons.color_lens,
    },
    {
      'name': 'Dark',
      'price': 200,
      'color': const Color(0xFF121212),
      'description': 'Pure dark mode',
      'icon': Icons.dark_mode,
    },
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Stack(
        children: [
          const SpaceBackground(),
          SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Theme Shop',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 5),
                            Text(
                              '${widget.userPoints}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Themes Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _themes.length,
                    itemBuilder: (BuildContext context, int index) {
                      final theme = _themes[index];
                      final isOwned = theme['price'] == 0 ||
                          widget.currentTheme == theme['name'].toLowerCase();
                      final canAfford =
                          widget.userPoints >= (theme['price'] as int);

                      return Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: widget.currentTheme ==
                                  theme['name'].toLowerCase()
                              ? const BorderSide(color: Colors.amber, width: 2)
                              : BorderSide.none,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                theme['color'],
                                theme['color'].withOpacity(0.7),
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Icon(
                                      theme['icon'],
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      theme['name'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      theme['description'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    if (widget.currentTheme ==
                                        theme['name'].toLowerCase())
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.amber,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'EQUIPPED',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    else if (theme['price'] == 0)
                                      ElevatedButton(
                                        onPressed: () => _selectTheme(
                                            theme['name'].toLowerCase()),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('SELECT',
                                            style:
                                                TextStyle(color: Colors.white)),
                                      )
                                    else
                                      ElevatedButton(
                                        onPressed: canAfford
                                            ? () => _purchaseTheme(theme)
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: canAfford
                                              ? Colors.blueAccent
                                              : Colors.grey,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.star,
                                                size: 16, color: Colors.white),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${theme['price']}',
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseTheme(Map<String, dynamic> theme) async {
    if (widget.userPoints < (theme['price'] as int)) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content: Text('Not enough points!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await _dbHelper.purchaseTheme(
          widget.username, theme['name'].toLowerCase());
      final newPoints = widget.userPoints - (theme['price'] as int);
      await _dbHelper.updateUserPoints(widget.username, newPoints);

      widget.onPointsUpdated(newPoints);
      widget.onThemeChanged(theme['name'].toLowerCase());

      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text('Successfully purchased ${theme['name']} theme!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text('Failed to purchase theme: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectTheme(String themeName) async {
    try {
      await _dbHelper.updateCurrentTheme(widget.username, themeName);
      widget.onThemeChanged(themeName);

      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text('Theme changed to $themeName!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text('Failed to change theme: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class ProfileTab extends StatefulWidget {
  final String username;
  final int userPoints;
  final String currentTheme;

  const ProfileTab({
    super.key,
    required this.username,
    required this.userPoints,
    required this.currentTheme,
  });

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab>
    with AutomaticKeepAliveClientMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, dynamic>? _userStats;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    final userSets = await _dbHelper.getUserStudySets(widget.username);
    setState(() {
      _userStats = {
        'studySetsCreated': userSets.length,
        'totalQuestions': 0, // You can implement this if needed
        'averageScore': 0, // You can implement this if needed
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Stack(
        children: [
          const SpaceBackground(),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Profile Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4facfe).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Text(
                              widget.username.isNotEmpty
                                  ? widget.username[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.username,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '${widget.userPoints} points',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Stats Section
                    if (_userStats != null) ...[
                      Card(
                        elevation: 4,
                        color: Colors.white.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Statistics',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem(
                                    'Study Sets',
                                    '${_userStats!['studySetsCreated']}',
                                    Icons.school,
                                    Colors.blue,
                                  ),
                                  _buildStatItem(
                                    'Current Theme',
                                    widget.currentTheme.toUpperCase(),
                                    Icons.palette,
                                    Colors.purple,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Account Settings
                    Card(
                      elevation: 4,
                      color: Colors.white.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
                              child: Text(
                                'Account Settings',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            _buildSettingsItem(
                              'Change Password',
                              Icons.lock,
                              Colors.orange,
                              () => _showChangePasswordDialog(),
                            ),
                            const Divider(
                                color: Colors.white24,
                                indent: 20,
                                endIndent: 20),
                            _buildSettingsItem(
                              'About App',
                              Icons.info,
                              Colors.blue,
                              () => _showAboutDialog(),
                            ),
                            const Divider(
                                color: Colors.white24,
                                indent: 20,
                                endIndent: 20),
                            _buildSettingsItem(
                              'Share App',
                              Icons.share,
                              Colors.green,
                              () => _shareApp(),
                            ),
                            const Divider(
                                color: Colors.white24,
                                indent: 20,
                                endIndent: 20),
                            _buildSettingsItem(
                              'Sign Out',
                              Icons.logout,
                              Colors.red,
                              () => _showSignOutDialog(),
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

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
      onTap: onTap,
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: this.context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement password change logic
              Navigator.pop(context);
              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(
                    content: Text('Password change feature coming soon!')),
              );
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: this.context,
      builder: (context) => AlertDialog(
        title: const Text('About EduQuest'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EduQuest v1.0.0',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
                'A gamified learning platform designed to make education fun and engaging.'),
            SizedBox(height: 16),
            Text('Features:'),
            Text('• Create custom study sets'),
            Text('• Practice with interactive quizzes'),
            Text('• Earn points and unlock themes'),
            Text('• Track your learning progress'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _shareApp() {
    Share.share(
        'Check out EduQuest - the fun way to learn! Download now and start your learning journey.');
  }

  void _showSignOutDialog() {
    showDialog(
      context: this.context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => SignInPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class StudySetCreationOptionsScreen extends StatelessWidget {
  final String username;
  final VoidCallback onStudySetCreated;

  const StudySetCreationOptionsScreen({
    super.key,
    required this.username,
    required this.onStudySetCreated,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Study Set',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1D1E33),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Stack(
        children: [
          const SpaceBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose Creation Method',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'How would you like to build your set?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildOptionCard(
                          context,
                          'Import from Quizlet',
                          'Use a public Quizlet set URL',
                          Icons.link,
                          const [Color(0xFF16A085), Color(0xFF1ABC9C)],
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizletImportScreen(
                                username: username,
                                onStudySetCreated: onStudySetCreated,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildOptionCard(
                          context,
                          'Import from Spreadsheet',
                          'Upload an Excel (.xlsx) file',
                          Icons.upload_file,
                          const [Color(0xFF2980B9), Color(0xFF3498DB)],
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SpreadsheetImportScreen(
                                username: username,
                                onStudySetCreated: onStudySetCreated,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildOptionCard(
                          context,
                          'Create Questions Manually',
                          'Add questions one-by-one',
                          Icons.edit_note,
                          const [Color(0xFF8E44AD), Color(0xFF9B59B6)],
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ManualQuestionCreationScreen(
                                username: username,
                                onStudySetCreated: onStudySetCreated,
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
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    List<Color> colors,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PracticeModeScreen extends StatefulWidget {
  final Map<String, dynamic> studySet;
  final String username;
  final String currentTheme;

  const PracticeModeScreen({
    super.key,
    required this.studySet,
    required this.username,
    required this.currentTheme,
  });

  @override
  _PracticeModeScreenState createState() => _PracticeModeScreenState();
}

class _PracticeModeScreenState extends State<PracticeModeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<Map<String, dynamic>> _questions = [];
  int _questionCount = 20;
  String _selectedMode = 'classic';
  bool _showModeSelection = true;
  bool _showQuizArea = false;
  bool _showScoreSummary = false;
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  bool _showAnswer = false;
  int _correctAnswers = 0;
  bool _showChat = false;
  late ChatBloc _chatBloc;
  final TextEditingController _chatController = TextEditingController();
  double _chatHeightRatio = 0.5; // Default 50% of available area
  bool _isResizing = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _chatBloc = ChatBloc();
  }

  @override
  void dispose() {
    _chatController.dispose();
    _chatBloc.close();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final questions =
          await _dbHelper.getStudySetQuestions(widget.studySet['id']);
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _startPractice(BuildContext context) {
    if (_selectedMode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a practice mode')),
      );
      return;
    }

    setState(() {
      _showModeSelection = false;
      _showQuizArea = true;
      _showScoreSummary = false;
      _currentQuestionIndex = 0;
      _correctAnswers = 0;
    });
  }

  void _checkAnswer(String answer) {
    setState(() {
      _selectedAnswer = answer;
      _showAnswer = true;
      if (answer == _questions[_currentQuestionIndex]['correct_answer']) {
        _correctAnswers++;
      }
    });
  }

  void _continueToNext() {
    final int totalQuestions = _questions.length < _questionCount ? _questions.length : _questionCount;
    if (_currentQuestionIndex < totalQuestions - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _showAnswer = false;
      });
    } else {
      setState(() {
        _showQuizArea = false;
        _showScoreSummary = true;
      });
    }
  }

  void _answerWithAI() {
    // Get current question data
    final currentQuestion = _questions[_currentQuestionIndex];
    final questionText = currentQuestion['question_text'];
    final options = currentQuestion['options'].split('|');

    // Create the prompt with question and options
    String prompt = "Question: $questionText\n\nOptions:\n";
    for (int i = 0; i < options.length; i++) {
      prompt += "${String.fromCharCode(65 + i)}. ${options[i]}\n";
    }
    prompt +=
        "\nPlease help me understand this question and explain the correct answer.";

    // Set the chat controller text
    _chatController.text = prompt;

    // Show the chat interface
    setState(() {
      _showChat = true;
    });

    // Send the message to the chat
    _chatBloc.add(ChatGenerationNewTextMessageEvent(inputMessage: prompt));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const SpaceBackground(),
          SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    ),
                  )
                : _hasError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red.withOpacity(0.8),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _loadQuestions,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _showModeSelection
                        ? SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.arrow_back,
                                            color: Colors.white),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.studySet['name'] ??
                                                'Practice Mode',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            '${_questions.length} questions available',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color:
                                                  Colors.white.withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                const Text(
                                  'Choose Your Challenge',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Pick a mode that suits your learning style',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildEnhancedModeCard(
                                  'classic',
                                  'Classic Mode',
                                  'Take your time and learn at your own pace',
                                  Icons.school,
                                  const LinearGradient(
                                    colors: [
                                      Color(0xFF667eea),
                                      Color(0xFF764ba2)
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildEnhancedModeCard(
                                  'timed',
                                  'Lightning Mode',
                                  'Race against time for maximum challenge',
                                  Icons.flash_on,
                                  const LinearGradient(
                                    colors: [
                                      Color(0xFFf093fb),
                                      Color(0xFFf5576c)
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Container(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.amber.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.quiz,
                                              color: Colors.amber,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'Question Count',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blueAccent
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          child: Text(
                                            '$_questionCount Questions',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      SliderTheme(
                                        data: SliderThemeData(
                                          activeTrackColor: Colors.blueAccent,
                                          inactiveTrackColor:
                                              Colors.white.withOpacity(0.3),
                                          thumbColor: Colors.white,
                                          thumbShape:
                                              const RoundSliderThumbShape(
                                            enabledThumbRadius: 12,
                                          ),
                                          overlayColor: Colors.blueAccent
                                              .withOpacity(0.2),
                                          valueIndicatorColor:
                                              Colors.blueAccent,
                                          valueIndicatorTextStyle:
                                              const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        child: Slider(
                                          value: _questionCount.toDouble(),
                                          min: 1.0,
                                          max: 20.0,
                                          divisions: 19,
                                          label: '$_questionCount',
                                          onChanged: (value) {
                                            setState(() {
                                              _questionCount = value.round();
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 40),
                                // Start Practice button
                                Container(
                                  width: double.infinity,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF4facfe),
                                        Color(0xFF00f2fe)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF4facfe).withOpacity(0.4),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () => _startPractice(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Start Practice',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _showScoreSummary
                            ? Center(
                                child: Container(
                                  padding: const EdgeInsets.all(32),
                                  margin: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color(0xFF2A2D3E),
                                        const Color(0xFF1D1E33)
                                            .withOpacity(0.9),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.emoji_events,
                                        size: 64,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(height: 24),
                                      const Text(
                                        'Quiz Complete!',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Score: $_correctAnswers/$_questionCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            _showModeSelection = true;
                                            _showQuizArea = false;
                                            _showScoreSummary = false;
                                          });
                                        },
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('Try Again'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueAccent,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  // Top navigation bar
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 24,
                                        left: 16,
                                        right: 16,
                                        bottom: 0),
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.arrow_back,
                                                color: Colors.white, size: 24),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Gradient pill for question counter (blue/cyan)
                                        Expanded(
                                          child: Center(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 28,
                                                      vertical: 12),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFF4facfe),
                                                    Color(0xFF00f2fe)
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color:
                                                        const Color(0xFF4facfe)
                                                            .withOpacity(0.18),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                '${_currentQuestionIndex + 1} of $_questionCount',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                            width:
                                                48), // Balance the back button
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF4facfe)
                                              .withOpacity(0.18),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: 10,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white.withOpacity(0.1),
                                                  Colors.white
                                                      .withOpacity(0.05),
                                                ],
                                              ),
                                            ),
                                          ),
                                          FractionallySizedBox(
                                            widthFactor:
                                                (_currentQuestionIndex + 1) /
                                                    _questionCount,
                                            child: Container(
                                              height: 10,
                                              decoration: const BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(0xFF4facfe),
                                                    Color(0xFF00f2fe)
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  // Main content area - split between quiz and chat
                                  Expanded(
                                    child: _showChat
                                        ? Column(
                                            children: [
                                              // Quiz area (top half)
                                              Expanded(
                                                flex: 1,
                                                child: SingleChildScrollView(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 16),
                                                  child: _buildQuizContent(),
                                                ),
                                              ),
                                              // Chat area (bottom half)
                                              Expanded(
                                                flex: 1,
                                                child: _buildChatInterface(),
                                              ),
                                            ],
                                          )
                                        : SingleChildScrollView(
                                            padding: const EdgeInsets.only(
                                                bottom: 24),
                                            child: _buildQuizContent(),
                                          ),
                                  ),
                                ],
                              ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedModeCard(
    String mode,
    String title,
    String subtitle,
    IconData icon,
    Gradient gradient,
  ) {
    final isSelected = _selectedMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = mode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          color: isSelected ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gradient.colors.first.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(isSelected ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                color: isSelected ? Colors.white : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Color(0xFF302B63),
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizContent() {
    final int totalQuestions = _questions.length < _questionCount ? _questions.length : _questionCount;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final double minHeight = MediaQuery.of(context).size.height * 0.14;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              constraints: BoxConstraints(minHeight: minHeight),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4facfe).withOpacity(0.22),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.13),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF2A2D3E),
                      const Color(0xFF1D1E33),
                      const Color(0xFF16213E).withOpacity(0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.10),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    _questions[_currentQuestionIndex]['question_text'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        ..._questions[_currentQuestionIndex]['options']
            .split('|')
            .asMap()
            .entries
            .map((e) {
          final i = e.key;
          final opt = e.value;
          final sel = _selectedAnswer == opt;
          final cor = _showAnswer &&
              opt == _questions[_currentQuestionIndex]['correct_answer'];
          final wrg = _showAnswer && sel && !cor;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: cor
                    ? const LinearGradient(
                        colors: [Color(0xFF43e97b), Color(0xFF38f9d7)])
                    : wrg
                        ? const LinearGradient(
                            colors: [Color(0xFFf5576c), Color(0xFFf093fb)])
                        : sel
                            ? const LinearGradient(
                                colors: [Color(0xFF4facfe), Color(0xFF00f2fe)])
                            : const LinearGradient(
                                colors: [Color(0xFF23243a), Color(0xFF23243a)]),
                borderRadius: BorderRadius.circular(18),
                boxShadow: sel
                    ? [
                        BoxShadow(
                          color: const Color(0xFF4facfe).withOpacity(0.18),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
                border: Border.all(
                  color: cor
                      ? Colors.greenAccent.withOpacity(0.7)
                      : wrg
                          ? Colors.redAccent.withOpacity(0.7)
                          : Colors.white.withOpacity(0.08),
                  width: 2,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: _showAnswer ? null : () => _checkAnswer(opt),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    child: Center(
                      child: Text(
                        opt,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
        if (_showAnswer) ...[
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: Row(
              children: [
                // Ask AI Button
                Expanded(
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF667eea).withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _answerWithAI,
                      icon: const Icon(Icons.psychology, color: Colors.white),
                      label: const Text(
                        'Ask AI',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Next Question Button
                Expanded(
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4facfe).withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _continueToNext,
                      icon: Icon(
                        _currentQuestionIndex < totalQuestions - 1 ? Icons.arrow_forward : Icons.check_circle,
                        color: Colors.white,
                      ),
                      label: Text(
                        _currentQuestionIndex < totalQuestions - 1 ? 'Next Question' : 'Finish',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChatInterface() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Chat header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.psychology, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'AI Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showChat = false;
                    });
                  },
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          // Chat messages
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              bloc: _chatBloc,
              builder: (context, state) {
                if (state is ChatSuccessState) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final isUser = message.role == 'user';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: isUser
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            if (!isUser) ...[
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF667eea),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(Icons.psychology,
                                    color: Colors.white, size: 16),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? const Color(0xFF4facfe)
                                      : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  message.parts.isNotEmpty ? message.parts.first.text : 'No message content',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                              ),
                            ),
                            if (isUser) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4facfe),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(Icons.person,
                                    color: Colors.white, size: 16),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                } else if (state is ChatErrorState) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(color: Colors.blueAccent),
                );
              },
            ),
          ),
          // Chat input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Ask a follow-up question...',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (_chatController.text.trim().isNotEmpty) {
                      _chatBloc.add(ChatGenerationNewTextMessageEvent(
                          inputMessage: _chatController.text));
                      _chatController.clear();
                    }
                  },
                  icon: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomPageRoute extends PageRouteBuilder {
  final Widget page;
  final String routeName;

  CustomPageRoute({
    required this.page,
    required this.routeName,
  }) : super(
          settings: RouteSettings(name: routeName),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}

class QuizScreen extends StatefulWidget {
  final String subject;
  final String username;
  final List<quiz.Question> questions;
  final String currentTheme;
  final String gameMode;
  final int questionCount;

  const QuizScreen({
    super.key,
    required this.subject,
    required this.username,
    required this.questions,
    required this.currentTheme,
    required this.gameMode,
    required this.questionCount,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int score = 0;
  bool isAnswered = false;
  String? selectedAnswer;
  Timer? timer;
  double timeLeft = 10.0; // Changed to double
  double timerProgress = 1.0;
  bool showAnswer = false;
  List<bool> answeredCorrectly = [];
  bool showScoreSummary = false;
  bool showQuizArea = true;

  @override
  void initState() {
    super.initState();
    if (widget.gameMode == 'timed') {
      startTimer();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timeLeft = 45.0; // Reset to 45 seconds
    timerProgress = 1.0;
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft -= 0.1;
          timerProgress = timeLeft / 45.0;
        });
      } else {
        nextQuestion();
      }
    });
  }

  void selectAnswer(String answer) {
    if (isAnswered) return;

    setState(() {
      selectedAnswer = answer;
      isAnswered = true;
    });

    if (answer == widget.questions[currentQuestionIndex].correctAnswer) {
      score++;
    }

    Future.delayed(const Duration(seconds: 1), () {
      nextQuestion();
    });
  }

  void nextQuestion() {
    timer?.cancel();

    if (currentQuestionIndex < widget.questionCount - 1 &&
        currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        isAnswered = false;
        selectedAnswer = null;
      });

      if (widget.gameMode == 'timed') {
        startTimer();
      }
    } else {
      showResults();
    }
  }

  void showResults() {
    timer?.cancel();

    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your Score: $score/${widget.questionCount}'),
            const SizedBox(height: 10),
            Text(
                'Percentage: ${((score / widget.questionCount) * 100).toStringAsFixed(1)}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject),
        backgroundColor: const Color(0xFF1D1E33),
        foregroundColor: Colors.white,
        actions: [
          if (widget.gameMode == 'timed')
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      value: timerProgress,
                      strokeWidth: 2,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.blueAccent),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${timeLeft.toStringAsFixed(1)}s',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          const SpaceBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
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
                          'Question ${currentQuestionIndex + 1}/${widget.questionCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (currentQuestionIndex + 1) / widget.questionCount,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.blueAccent),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Score
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Score: $score',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

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
                    child: Text(
                      widget.questions[currentQuestionIndex].questionText,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Answer options
                  Expanded(
                    child: ListView.builder(
                      itemCount:
                          widget.questions[currentQuestionIndex].options.length,
                      itemBuilder: (context, index) {
                        final option = widget
                            .questions[currentQuestionIndex].options[index];
                        final isSelected = selectedAnswer == option;
                        final isCorrect = isAnswered &&
                            option ==
                                widget.questions[currentQuestionIndex]
                                    .correctAnswer;
                        final isWrong = isAnswered && isSelected && !isCorrect;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isCorrect
                                  ? Colors.green.withOpacity(0.2)
                                  : isWrong
                                      ? Colors.red.withOpacity(0.2)
                                      : isSelected
                                          ? Colors.blueAccent.withOpacity(0.2)
                                          : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCorrect
                                    ? Colors.green
                                    : isWrong
                                        ? Colors.red
                                        : isSelected
                                            ? Colors.blueAccent
                                            : Colors.white.withOpacity(0.1),
                                width: 2,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              title: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              trailing: isAnswered
                                  ? Icon(
                                      isCorrect
                                          ? Icons.check_circle
                                          : isWrong
                                              ? Icons.cancel
                                              : null,
                                      color:
                                          isCorrect ? Colors.green : Colors.red,
                                    )
                                  : null,
                              onTap: isAnswered
                                  ? null
                                  : () => selectAnswer(option),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Timer (if in timed mode)
                  if (widget.gameMode == 'timed') ...[
                    const SizedBox(height: 24),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: timerProgress,
                        backgroundColor: Colors.white24,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.amber),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Time Left: ${timeLeft.toStringAsFixed(1)}s',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuizletImportScreen extends StatefulWidget {
  final String username;
  final VoidCallback onStudySetCreated;

  const QuizletImportScreen({
    super.key,
    required this.username,
    required this.onStudySetCreated,
  });

  @override
  _QuizletImportScreenState createState() => _QuizletImportScreenState();
}

class _QuizletImportScreenState extends State<QuizletImportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _urlController = TextEditingController();
  final _dbHelper = DatabaseHelper();
  bool _isLoading = false;
  List<Map<String, dynamic>> _questions = [];
  bool _hasImported = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _importFromQuizlet() async {
    if (_urlController.text.isEmpty) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a Quizlet URL'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.get(Uri.parse(_urlController.text));
      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        List<Map<String, dynamic>> parsedQuestions = [];

        // Try to find JSON first
        final scriptTags = document.getElementsByTagName('script');
        String? jsonData;
        for (var script in scriptTags) {
          if (script.text.contains('window.Quizlet')) {
            final start = script.text.indexOf('{');
            final end = script.text.lastIndexOf('};');
            if (start != -1 && end != -1) {
              jsonData = script.text.substring(start, end + 1);
              break;
            }
          }
        }

        if (jsonData != null) {
          final termRegExp = RegExp(r'"word":"(.*?)","definition":"(.*?)"');
          for (final match in termRegExp.allMatches(jsonData)) {
            final question = match.group(1)?.replaceAll('\\u002F', '/') ?? '';
            final answer = match.group(2)?.replaceAll('\\u002F', '/') ?? '';
            if (question.isNotEmpty && answer.isNotEmpty) {
              // Create 4 options with the correct answer as one of them
              List<String> options = [answer];
              // Add some dummy options for now - in a real app, you might generate these
              while (options.length < 4) {
                options.add('Option ${options.length}');
              }
              options.shuffle();

              parsedQuestions.add({
                'question': question,
                'correct_answer': answer,
                'options': options,
              });
            }
          }
        }

        // Fallback: Try to parse HTML for terms
        if (parsedQuestions.isEmpty) {
          final termEls = document.querySelectorAll('.SetPageTerm-content');
          for (var el in termEls) {
            final question =
                el.querySelector('.SetPageTerm-wordText')?.text.trim() ?? '';
            final answer =
                el.querySelector('.SetPageTerm-definitionText')?.text.trim() ??
                    '';
            if (question.isNotEmpty && answer.isNotEmpty) {
              List<String> options = [answer];
              while (options.length < 4) {
                options.add('Option ${options.length}');
              }
              options.shuffle();

              parsedQuestions.add({
                'question': question,
                'correct_answer': answer,
                'options': options,
              });
            }
          }
        }

        setState(() {
          _questions = parsedQuestions;
          _hasImported = parsedQuestions.isNotEmpty;
          _isLoading = false;
        });

        if (parsedQuestions.isNotEmpty) {
          ScaffoldMessenger.of(this.context).showSnackBar(
            SnackBar(
              content:
                  Text('Imported ${parsedQuestions.length} terms from Quizlet'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(this.context).showSnackBar(
            const SnackBar(
              content:
                  Text('Could not parse Quizlet set. Please check the URL.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to fetch Quizlet set: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Quizlet import error: $e');
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content: Text('Failed to import from Quizlet. Please check the URL.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createStudySet() async {
    if (!_formKey.currentState!.validate()) return;
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content: Text('Please import questions from Quizlet first'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final studySetId = await _dbHelper.createStudySet(
        _nameController.text,
        _descriptionController.text,
        widget.username,
      );

      for (var question in _questions) {
        try {
          await _dbHelper.addQuestionToStudySet(
            studySetId,
            question['question'],
            question['correct_answer'],
            question['options'],
          );
        } catch (e) {
          debugPrint('Error adding question: $e');
          throw Exception('Failed to add question: ${e.toString()}');
        }
      }

      if (!mounted) return;
      _showPostAddDialog(studySetId);
    } catch (e) {
      debugPrint('Error creating study set: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text('Failed to create study set: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showPostAddDialog(int studySetId) {
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Study Set Created!'),
        content: const Text('Your study set was created successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PracticeModeScreen(
                    studySet: {
                      'id': studySetId,
                      'name': _nameController.text,
                      'description': _descriptionController.text,
                    },
                    username: widget.username,
                    currentTheme: '',
                  ),
                ),
              );
            },
            child: const Text('Practice Now'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _nameController.clear();
                _descriptionController.clear();
                _urlController.clear();
                _questions.clear();
                _hasImported = false;
              });
            },
            child: const Text('Create Another'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onStudySetCreated();
              Navigator.pop(context);
            },
            child: const Text('Back to My Sets'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from Quizlet'),
        backgroundColor: const Color(0xFF1D1E33),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const SpaceBackground(),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFormField(
                            _nameController, 'Study Set Name', 'Enter a name'),
                        const SizedBox(height: 20),
                        _buildFormField(_descriptionController, 'Description',
                            'Enter a description',
                            maxLines: 3),
                        const SizedBox(height: 30),
                        const Text(
                          'Quizlet URL',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildFormField(
                          _urlController,
                          'Paste Quizlet URL here',
                          'Please enter a valid URL',
                          prefixIcon: Icons.link,
                        ),
                        const SizedBox(height: 24),
                        _buildGradientButton(
                          'Import from Quizlet',
                          _importFromQuizlet,
                          Icons.download,
                          const [Color(0xFF16A085), Color(0xFF1ABC9C)],
                        ),
                        if (_questions.isNotEmpty) ...[
                          const SizedBox(height: 30),
                          _buildPreviewSection(),
                        ],
                        const SizedBox(height: 30),
                        _buildGradientButton(
                          'Create Study Set',
                          _questions.isNotEmpty ? _createStudySet : null,
                          Icons.check_circle,
                          const [Color(0xFF2980B9), Color(0xFF3498DB)],
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildFormField(
      TextEditingController controller, String label, String validationMessage,
      {int maxLines = 1, IconData? prefixIcon}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon:
            prefixIcon != null ? Icon(prefixIcon, color: Colors.white70) : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.blueAccent,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        return null;
      },
    );
  }

  Widget _buildPreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.greenAccent,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              'Imported ${_questions.length} terms',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Preview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Text('${index + 1}',
                      style: const TextStyle(color: Colors.white)),
                ),
                title: Text(
                  _questions[index]['question'],
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  'Answer: ${_questions[index]['correct_answer']}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGradientButton(
      String text, VoidCallback? onPressed, IconData icon, List<Color> colors) {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              onPressed != null ? colors : [Colors.grey, Colors.grey.shade700],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: colors.first.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : [],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class SpreadsheetImportScreen extends StatefulWidget {
  final String username;
  final VoidCallback onStudySetCreated;

  const SpreadsheetImportScreen({
    super.key,
    required this.username,
    required this.onStudySetCreated,
  });

  @override
  _SpreadsheetImportScreenState createState() =>
      _SpreadsheetImportScreenState();
}

class _SpreadsheetImportScreenState extends State<SpreadsheetImportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dbHelper = DatabaseHelper();
  bool _isLoading = false;
  List<Map<String, dynamic>> _questions = [];
  bool _hasFile = false;
  String _fileName = '';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _fileName = result.files.single.name;
          _hasFile = true;
        });
        await _parseExcelFile(result.files.single.path!);
      }
    } catch (e) {
      debugPrint('File picker error: $e');
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content: Text('Failed to pick file'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _parseExcelFile(String filePath) async {
    try {
      setState(() => _isLoading = true);

      var bytes = await File(filePath).readAsBytes();
      final excelFile = excel.Excel.decodeBytes(bytes);
      var sheet = excelFile.tables.values.first;

      List<Map<String, dynamic>> parsedQuestions = [];

      for (var row in sheet.rows.skip(1)) {
        // Skip header row
        if (row.length < 6) continue;

        String? question = row[0]?.value?.toString();
        String? correct = row[1]?.value?.toString();
        List<String> options = [
          row[2]?.value?.toString() ?? '',
          row[3]?.value?.toString() ?? '',
          row[4]?.value?.toString() ?? '',
          row[5]?.value?.toString() ?? '',
        ];

        if (question != null &&
            correct != null &&
            options.every((o) => o.isNotEmpty)) {
          parsedQuestions.add({
            'question': question,
            'correct_answer': correct,
            'options': options,
          });
        }
      }

      setState(() {
        _questions = parsedQuestions;
        _isLoading = false;
      });

      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text(
              'Parsed ${parsedQuestions.length} questions from spreadsheet'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Excel parsing error: $e');
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content:
              Text('Failed to parse spreadsheet. Please check the format.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createStudySet() async {
    if (!_formKey.currentState!.validate()) return;
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content: Text('Please select a spreadsheet with questions'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final studySetId = await _dbHelper.createStudySet(
        _nameController.text,
        _descriptionController.text,
        widget.username,
      );

      for (var question in _questions) {
        try {
          await _dbHelper.addQuestionToStudySet(
            studySetId,
            question['question'],
            question['correct_answer'],
            question['options'],
          );
        } catch (e) {
          debugPrint('Error adding question: $e');
          throw Exception('Failed to add question: ${e.toString()}');
        }
      }

      if (!mounted) return;
      _showPostAddDialog(studySetId);
    } catch (e) {
      debugPrint('Error creating study set: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text('Failed to create study set: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showPostAddDialog(int studySetId) {
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Study Set Created!'),
        content: const Text('Your study set was created successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PracticeModeScreen(
                    studySet: {
                      'id': studySetId,
                      'name': _nameController.text,
                      'description': _descriptionController.text,
                    },
                    username: widget.username,
                    currentTheme: '',
                  ),
                ),
              );
            },
            child: const Text('Practice Now'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _nameController.clear();
                _descriptionController.clear();
                _questions.clear();
                _hasFile = false;
                _fileName = '';
              });
            },
            child: const Text('Create Another'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onStudySetCreated();
              Navigator.pop(context);
            },
            child: const Text('Back to My Sets'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from Spreadsheet'),
        backgroundColor: const Color(0xFF1D1E33),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const SpaceBackground(),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildFormField(
                            _nameController, 'Study Set Name', 'Enter a name'),
                        const SizedBox(height: 20),
                        _buildFormField(_descriptionController, 'Description',
                            'Enter a description',
                            maxLines: 3),
                        const SizedBox(height: 30),
                        const Text(
                          'Upload File',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _pickFile,
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _hasFile
                                        ? Icons.check_circle
                                        : Icons.upload_file,
                                    color: _hasFile
                                        ? Colors.greenAccent
                                        : Colors.white70,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _hasFile
                                        ? _fileName
                                        : 'Tap to select .xlsx file',
                                    style: TextStyle(
                                      color: _hasFile
                                          ? Colors.white
                                          : Colors.white70,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (_questions.isNotEmpty) ...[
                          const SizedBox(height: 30),
                          _buildPreviewSection(),
                        ],
                        const SizedBox(height: 30),
                        _buildGradientButton(
                          'Create Study Set',
                          _questions.isNotEmpty ? _createStudySet : null,
                          Icons.check_circle,
                          const [Color(0xFF2980B9), Color(0xFF3498DB)],
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildFormField(
      TextEditingController controller, String label, String validationMessage,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.blueAccent,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        return null;
      },
    );
  }

  Widget _buildPreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.greenAccent,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              'Parsed ${_questions.length} questions',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Preview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Text('${index + 1}',
                      style: const TextStyle(color: Colors.white)),
                ),
                title: Text(
                  _questions[index]['question'],
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  'Answer: ${_questions[index]['correct_answer']}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGradientButton(
      String text, VoidCallback? onPressed, IconData icon, List<Color> colors) {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              onPressed != null ? colors : [Colors.grey, Colors.grey.shade700],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: colors.first.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : [],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class ManualQuestionCreationScreen extends StatefulWidget {
  final String username;
  final VoidCallback onStudySetCreated;

  const ManualQuestionCreationScreen({
    super.key,
    required this.username,
    required this.onStudySetCreated,
  });

  @override
  _ManualQuestionCreationScreenState createState() =>
      _ManualQuestionCreationScreenState();
}

class _ManualQuestionCreationScreenState
    extends State<ManualQuestionCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dbHelper = DatabaseHelper();
  bool _isLoading = false;
  List<Map<String, dynamic>> _questions = [];
  final _questionController = TextEditingController();
  final _correctAnswerController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _questionController.dispose();
    _correctAnswerController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _createStudySet() async {
    if (!_formKey.currentState!.validate()) return;
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one question'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final studySetId = await _dbHelper.createStudySet(
        _nameController.text,
        _descriptionController.text,
        widget.username,
      );

      for (var question in _questions) {
        try {
          await _dbHelper.addQuestionToStudySet(
            studySetId,
            question['question'],
            question['correct_answer'],
            question['options'],
          );
        } catch (e) {
          debugPrint('Error adding question: $e');
          throw Exception('Failed to add question: ${e.toString()}');
        }
      }

      if (!mounted) return;
      _showPostAddDialog(studySetId);
    } catch (e) {
      debugPrint('Error creating study set: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text('Failed to create study set: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _addQuestion() {
    if (_questionController.text.isEmpty ||
        _correctAnswerController.text.isEmpty ||
        _optionControllers.any((controller) => controller.text.isEmpty)) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _questions.add({
        'question': _questionController.text,
        'correct_answer': _correctAnswerController.text,
        'options': _optionControllers.map((c) => c.text).toList(),
      });
      _questionController.clear();
      _correctAnswerController.clear();
      for (var controller in _optionControllers) {
        controller.clear();
      }
    });
  }

  void _showPostAddDialog(int studySetId) {
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Study Set Created!'),
        content: const Text('Your study set was created successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PracticeModeScreen(
                    studySet: {
                      'id': studySetId,
                      'name': _nameController.text,
                      'description': _descriptionController.text,
                    },
                    username: widget.username,
                    currentTheme: '',
                  ),
                ),
              );
            },
            child: const Text('Practice Now'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _nameController.clear();
                _descriptionController.clear();
                _questions.clear();
                for (var c in _optionControllers) c.clear();
              });
            },
            child: const Text('Create Another'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onStudySetCreated();
              Navigator.pop(context);
            },
            child: const Text('Back to My Sets'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Manually'),
        backgroundColor: const Color(0xFF1D1E33),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const SpaceBackground(),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                  ),
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormField(_nameController, 'Study Set Name',
                                'Enter a name'),
                            const SizedBox(height: 20),
                            _buildFormField(_descriptionController,
                                'Description', 'Enter a description',
                                maxLines: 2),
                          ],
                        ),
                      ),
                      const Divider(color: Colors.white24, height: 1),
                      Expanded(
                        child: _questions.isEmpty
                            ? _buildEmptyState()
                            : _buildQuestionList(),
                      ),
                      _buildAddQuestionButton(),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: _buildGradientButton(
                          'Create Study Set',
                          _questions.isNotEmpty ? _createStudySet : null,
                          Icons.check_circle,
                          const [Color(0xFF2980B9), Color(0xFF3498DB)],
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildFormField(
      TextEditingController controller, String label, String validationMessage,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.blueAccent,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        return null;
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_task, color: Colors.white38, size: 64),
          const SizedBox(height: 16),
          const Text(
            'No questions yet',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Click the button below to add your first question',
            style:
                TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _questions.length,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white.withOpacity(0.1),
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Text('${index + 1}',
                  style: const TextStyle(color: Colors.white)),
            ),
            title: Text(
              _questions[index]['question'],
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'Correct: ${_questions[index]['correct_answer']}',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () {
                setState(() {
                  _questions.removeAt(index);
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddQuestionButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: TextButton.icon(
        onPressed: _showAddQuestionDialog,
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Add Question'),
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.white.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }

  Widget _buildGradientButton(
      String text, VoidCallback? onPressed, IconData icon, List<Color> colors) {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              onPressed != null ? colors : [Colors.grey, Colors.grey.shade700],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: colors.first.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : [],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showAddQuestionDialog() {
    final questionController = TextEditingController();
    final correctAnswerController = TextEditingController();
    final optionControllers = List.generate(4, (_) => TextEditingController());

    showDialog(
      context: this.context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        title: const Text('Add a New Question',
            style: TextStyle(color: Colors.white)),
        content: _QuestionInputCard(
          questionController: questionController,
          correctAnswerController: correctAnswerController,
          optionControllers: optionControllers,
          onQuestionAdded: (question) {
            setState(() {
              _questions.add(question);
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

class _QuestionInputCard extends StatefulWidget {
  final Function(Map<String, dynamic>) onQuestionAdded;
  final TextEditingController questionController;
  final TextEditingController correctAnswerController;
  final List<TextEditingController> optionControllers;

  const _QuestionInputCard({
    required this.onQuestionAdded,
    required this.questionController,
    required this.correctAnswerController,
    required this.optionControllers,
  });

  @override
  _QuestionInputCardState createState() => _QuestionInputCardState();
}

class _QuestionInputCardState extends State<_QuestionInputCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueAccent.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Question',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: widget.questionController,
              decoration: InputDecoration(
                labelText: 'Question',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon:
                    const Icon(Icons.help_outline, color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: widget.correctAnswerController,
              decoration: InputDecoration(
                labelText: 'Correct Answer',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.check_circle_outline,
                    color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: widget.optionControllers[index],
                  decoration: InputDecoration(
                    labelText: 'Option ${index + 1}',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.radio_button_unchecked,
                      color: Colors.white70,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  widget.onQuestionAdded({
                    'question': widget.questionController.text,
                    'correct_answer': widget.correctAnswerController.text,
                    'options':
                        widget.optionControllers.map((c) => c.text).toList(),
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Question'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PracticeTypeChoiceScreen extends StatelessWidget {
  final Map<String, dynamic> studySet;
  final String username;
  final String currentTheme;
  const PracticeTypeChoiceScreen({
    super.key,
    required this.studySet,
    required this.username,
    required this.currentTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Space theme background
          const SpaceBackground(),
          // Additional space elements
          ...List.generate(
            20,
            (index) => Positioned(
              left: (index * 50.0 + 30) % MediaQuery.of(context).size.width,
              top: (index * 80.0 + 50) % MediaQuery.of(context).size.height,
              child: TweenAnimationBuilder(
                duration: Duration(seconds: 4 + (index % 3)),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.5 + (value * 0.5),
                    child: Opacity(
                      opacity: 0.3 + (value * 0.4),
                      child: Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
                onEnd: () {
                  // Restart animation
                },
              ),
            ),
          ),
          // Nebula-like floating orbs
          ...List.generate(
            3,
            (index) => Positioned(
              left: (index * 150.0) % MediaQuery.of(context).size.width,
              top: (index * 200.0 + 100) % MediaQuery.of(context).size.height,
              child: TweenAnimationBuilder(
                duration: Duration(seconds: 8 + index),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(
                      sin(value * 2 * pi) * 30,
                      cos(value * 2 * pi) * 20,
                    ),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF4facfe).withOpacity(0.1),
                            const Color(0xFF667eea).withOpacity(0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
                onEnd: () {
                  // Restart animation
                },
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced header with space theme
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.15),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_rounded,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  studySet['name'] ?? 'Practice',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Select your preferred practice mode',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Select Practice Mode',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Choose how you would like to practice this set.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, (1 - value) * 50),
                        child: Opacity(
                          opacity: value,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PracticeModeScreen(
                                    studySet: studySet,
                                    username: username,
                                    currentTheme: currentTheme,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(28),
                              margin: const EdgeInsets.only(bottom: 24),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4facfe),
                                    Color(0xFF00f2fe)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4facfe)
                                        .withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: const [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.quiz_outlined,
                                          color: Colors.white, size: 32),
                                      SizedBox(width: 16),
                                      Text(
                                        'Multiple Choice Practice',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Timed multiple choice questions with instant feedback.',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, (1 - value) * 50),
                        child: Opacity(
                          opacity: value,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FRQManager(
                                    studySet: studySet,
                                    username: username,
                                    currentTheme: currentTheme,
                                    frqCount: 7,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF667eea),
                                    Color(0xFF764ba2)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF667eea)
                                        .withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: const [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.code,
                                          color: Colors.white, size: 32),
                                      SizedBox(width: 16),
                                      Text(
                                        'Free Response Practice',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Practice free response questions with detailed AI grading.',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF4facfe).withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4facfe).withOpacity(0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Removed the blue accent bar
                        const Icon(Icons.info_outline,
                            color: Color(0xFF4facfe), size: 24),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Tip',
                                style: TextStyle(
                                  color: Color(0xFF4facfe),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'You can switch between practice modes at any time for a comprehensive study experience.',
                                style: TextStyle(
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
