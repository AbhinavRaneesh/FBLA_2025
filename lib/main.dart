import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'database_helper.dart';
import 'questions.dart';
import 'dart:math'; // For random star positions
import 'package:google_sign_in/google_sign_in.dart'; // For Google Sign-In
import 'package:share_plus/share_plus.dart'; // For sharing the app
import 'dart:async';
import 'package:flutter/services.dart'; // For haptic feedback
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:excel/excel.dart' as excel;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

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
        fontFamily: 'Poppins', // Modern font
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 4,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => SignInPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
  final List<Question> questions;

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
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside
      builder: (context) => Theme(
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
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside
      builder: (context) => Theme(
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
  bool _showPassword = false;
  bool _isFormValid = false;
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

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
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
        HapticFeedback.heavyImpact();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          CustomPageRoute(
            page: MainScreen(username: username),
            routeName: '/home',
          ),
        );
      } else {
        HapticFeedback.vibrate();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
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
      ScaffoldMessenger.of(context).showSnackBar(
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
        ScaffoldMessenger.of(context).showSnackBar(
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
        context,
        CustomPageRoute(
          page: MainScreen(username: googleUser.email),
          routeName: '/home',
        ),
      );
    } catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
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
          Positioned(
            top: 10,
            left: 20,
            child: Hero(
              tag: 'planet',
              child: Image.asset(
                'assets/images/planet.png',
                height: 190,
              ),
            ),
          ),
          Positioned(
            bottom: -15,
            right: 0,
            child: Hero(
              tag: 'astronaut',
              child: Image.asset(
                'assets/images/astronaut.png',
                height: 195,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Welcome To EduQuest!',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  TextField(
                                    controller: _usernameController,
                                    decoration: InputDecoration(
                                      labelText: 'Username',
                                      labelStyle:
                                          const TextStyle(color: Colors.black),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      prefixIcon: const Icon(Icons.person,
                                          color: Colors.black),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  const SizedBox(height: 15),
                                  TextField(
                                    controller: _passwordController,
                                    obscureText: !_showPassword,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      labelStyle:
                                          const TextStyle(color: Colors.black),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      prefixIcon: const Icon(Icons.lock,
                                          color: Colors.black),
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
                                          const Text('Show Password',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black)),
                                          const SizedBox(width: 8),
                                        ],
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    child: ElevatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : (_isFormValid ? _signIn : null),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _isFormValid
                                            ? Colors.blueAccent
                                            : Colors.grey,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15, horizontal: 30),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          side: BorderSide(
                                              color: _isFormValid
                                                  ? Colors.blueAccent
                                                  : Colors.grey,
                                              width: 2),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            )
                                          : const Text(
                                              'Sign In',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white),
                                              textAlign: TextAlign.center,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed:
                                        _isLoading ? null : _signInWithGoogle,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/google_icon.png',
                                          height: 24,
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          'Sign in with Google',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
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
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Don\'t have an account? ',
                                  style: TextStyle(color: Colors.white),
                                ),
                                TextSpan(
                                  text: 'Sign Up',
                                  style: TextStyle(
                                    color: Colors.white,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
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
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_updateFormState);
    _passwordController.addListener(_updateFormState);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_updateFormState);
    _passwordController.removeListener(_updateFormState);
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateFormState() {
    setState(() {
      _isFormValid = _usernameController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    });
  }

  Future<void> _signUp() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    try {
      final userExists = await _dbHelper.usernameExists(username);

      if (userExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Username already exists. Please choose a different one.')),
        );
        return;
      }

      final success = await _dbHelper.addUser(username, password);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Something went wrong. Please try again.')),
        );
      }
    } catch (e) {
      debugPrint('Error during sign-up: $e');
      if (!mounted) return; // Add mounted check
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred during sign-up: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const SpaceBackground(),
          Positioned(
            top: 10,
            left: 20,
            child: Image.asset(
              'assets/images/planet.png',
              height: 190,
            ),
          ),
          Positioned(
            bottom: -15,
            right: 0,
            child: Image.asset(
              'assets/images/astronaut.png',
              height: 195,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Create an Account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              TextField(
                                controller: _usernameController,
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                  labelStyle: TextStyle(color: Colors.black),
                                  border: OutlineInputBorder(),
                                  prefixIcon:
                                      Icon(Icons.person, color: Colors.black),
                                ),
                                style: const TextStyle(color: Colors.black),
                              ),
                              const SizedBox(height: 15),
                              TextField(
                                controller: _passwordController,
                                obscureText: !_showPassword,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle:
                                      const TextStyle(color: Colors.black),
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.lock,
                                      color: Colors.black),
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
                                      const Text('Show Password',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black)),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                ),
                                style: const TextStyle(color: Colors.black),
                              ),
                              const SizedBox(height: 20),
                              // Sign Up Button
                              Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: ElevatedButton(
                                  onPressed: _isFormValid
                                      ? _signUp
                                      : null, // Disable if form is invalid
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isFormValid
                                        ? Colors.blueAccent
                                        : Colors.grey, // Grey out if disabled
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 30),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                          color: _isFormValid
                                              ? Colors.blueAccent
                                              : Colors.grey,
                                          width: 2),
                                    ),
                                  ),
                                  child: const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(
                            context); // Navigate back to the SignInPage
                      },
                      child: const Text(
                        'Already have an account? Sign in',
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
  int _userPoints = 0;
  String _currentTheme = 'space';
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final points = await _dbHelper.getUserPoints(widget.username);
    final theme = await _dbHelper.getCurrentTheme(widget.username);
    setState(() {
      _userPoints = points;
      _currentTheme = theme ?? 'space';
    });
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class LearnTab extends StatefulWidget {
  final String username;
  final int userPoints;
  final String currentTheme;
  final Function(int) onPointsUpdated;

  const LearnTab({
    super.key,
    required this.username,
    required this.userPoints,
    required this.currentTheme,
    required this.onPointsUpdated,
  });

  @override
  _LearnTabState createState() => _LearnTabState();
}

class _LearnTabState extends State<LearnTab>
    with AutomaticKeepAliveClientMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _studySets = [];
  List<Map<String, dynamic>> _premadeStudySets = [];
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadStudySets();
  }

  Future<void> _loadStudySets() async {
    final userSets = await _dbHelper.getUserStudySets(widget.username);
    final premadeSets = await _dbHelper.getPremadeStudySets();
    setState(() {
      _studySets = userSets;
      _premadeStudySets = premadeSets;
      _isLoading = false;
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
            child: Column(
              children: [
                // Header with points
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${widget.username}!',
                            style: const TextStyle(
                              fontSize: 24,
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
                // Study Sets Content
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : DefaultTabController(
                          length: 3,
                          child: Column(
                            children: [
                              const TabBar(
                                labelColor: Colors.white,
                                unselectedLabelColor: Colors.white70,
                                indicatorColor: Colors.blueAccent,
                                tabs: [
                                  Tab(text: 'My Sets'),
                                  Tab(text: 'Browse'),
                                  Tab(text: 'Quick Play'),
                                ],
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    _buildMyStudySets(),
                                    _buildBrowseStudySets(),
                                    _buildQuickPlay(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
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
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add),
        label: const Text('Create Set'),
      ),
    );
  }

  Widget _buildMyStudySets() {
    if (_studySets.isEmpty) {
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
              'Create your first study set to get started!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _studySets.length,
      itemBuilder: (context, index) {
        final studySet = _studySets[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              studySet['name'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text(studySet['description']),
                const SizedBox(height: 5),
                Text(
                  'Created: ${_formatDate(studySet['created_at'])}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.play_arrow, color: Colors.green),
                  onPressed: () => _startPractice(studySet),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteStudySet(studySet['id']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBrowseStudySets() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _premadeStudySets.length,
      itemBuilder: (context, index) {
        final studySet = _premadeStudySets[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.school, color: Colors.blueAccent),
            ),
            title: Text(
              studySet['name'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text(studySet['description']),
            trailing: ElevatedButton(
              onPressed: () => _startPractice(studySet),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  const Text('Practice', style: TextStyle(color: Colors.white)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickPlay() {
    final subjects = ['Math', 'Science', 'History', 'English'];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Practice',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Jump into a quick practice session',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () => _startQuickPlay(subject),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _getSubjectColor(subject),
                            _getSubjectColor(subject).withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getSubjectIcon(subject),
                            size: 40,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            subject,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'Math':
        return Colors.blue;
      case 'Science':
        return Colors.green;
      case 'History':
        return Colors.orange;
      case 'English':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject) {
      case 'Math':
        return Icons.calculate;
      case 'Science':
        return Icons.science;
      case 'History':
        return Icons.history_edu;
      case 'English':
        return Icons.menu_book;
      default:
        return Icons.school;
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  }

  void _startPractice(Map<String, dynamic> studySet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PracticeModeScreen(
          studySet: studySet,
          username: widget.username,
          currentTheme: widget.currentTheme,
        ),
      ),
    );
  }

  void _startQuickPlay(String subject) {
    final questions = QuestionsRepository.getQuestionsForSubject(subject);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          subject: subject,
          username: widget.username,
          questions: questions,
          currentTheme: widget.currentTheme,
          gameMode: 'classic',
          questionCount: 10,
        ),
      ),
    );
  }

  void _deleteStudySet(int studySetId) {
    showDialog(
      context: context,
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
              await _dbHelper.deleteStudySet(studySetId);
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
                    itemBuilder: (context, index) {
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
      ScaffoldMessenger.of(context).showSnackBar(
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully purchased ${theme['name']} theme!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Theme changed to $themeName!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
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
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.blueAccent, Colors.blue],
                          ),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: Text(
                                widget.username.isNotEmpty
                                    ? widget.username[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
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
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 5),
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
                    ),

                    const SizedBox(height: 20),

                    // Stats Section
                    if (_userStats != null) ...[
                      Card(
                        elevation: 4,
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
                                ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Account Settings',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildSettingsItem(
                              'Change Password',
                              Icons.lock,
                              Colors.orange,
                              () => _showChangePasswordDialog(),
                            ),
                            const Divider(),
                            _buildSettingsItem(
                              'About App',
                              Icons.info,
                              Colors.blue,
                              () => _showAboutDialog(),
                            ),
                            const Divider(),
                            _buildSettingsItem(
                              'Share App',
                              Icons.share,
                              Colors.green,
                              () => _shareApp(),
                            ),
                            const Divider(),
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
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
              ScaffoldMessenger.of(context).showSnackBar(
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
      context: context,
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
      context: context,
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
                    'Choose how you\'d like to create your study set:',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: Column(
                      children: [
                        _buildOptionCard(
                          context,
                          'Import from Quizlet',
                          'Import questions from an existing Quizlet set',
                          Icons.link,
                          Colors.green,
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
                          'Upload an Excel file with your questions and answers',
                          Icons.upload_file,
                          Colors.blue,
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
                          'Add questions one by one using our question builder',
                          Icons.edit,
                          Colors.purple,
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
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
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
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
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
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;
  String _selectedMode = 'classic';
  int _questionCount = 10;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final questions =
        await _dbHelper.getStudySetQuestions(widget.studySet['id']);
    setState(() {
      _questions = questions;
      _isLoading = false;
    });
  }

  void _startPractice() {
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No questions available in this study set'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      CustomPageRoute(
        page: QuizScreen(
          subject: widget.studySet['name'],
          username: widget.username,
          questions: _questions
              .map((q) => Question(
                    questionText: q['question_text'],
                    options: (q['options'] as String).split('|'),
                    correctAnswer: q['correct_answer'],
                  ))
              .toList(),
          currentTheme: widget.currentTheme,
          gameMode: _selectedMode,
          questionCount: _questionCount,
        ),
        routeName: '/quiz',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Practice Mode',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: widget.currentTheme == 'beach'
            ? Colors.orange
            : const Color(0xFF1D1E33),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          widget.currentTheme == 'beach'
              ? Image.asset(
                  'assets/images/beach.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              : const SpaceBackground(),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Practice Mode',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        color: Colors.blueAccent.withOpacity(0.2),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              RadioListTile<String>(
                                title: const Text(
                                  'Classic Mode',
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: const Text(
                                  'Answer questions at your own pace',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                value: 'classic',
                                groupValue: _selectedMode,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedMode = value!;
                                  });
                                },
                                activeColor: Colors.blueAccent,
                              ),
                              RadioListTile<String>(
                                title: const Text(
                                  'Timed Mode',
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: const Text(
                                  'Answer questions against the clock',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                value: 'timed',
                                groupValue: _selectedMode,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedMode = value!;
                                  });
                                },
                                activeColor: Colors.blueAccent,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Number of Questions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Slider(
                        value: _questionCount.toDouble(),
                        min: 5,
                        max: _questions.length.toDouble(),
                        divisions: (_questions.length ~/ 5) - 1,
                        label: _questionCount.toString(),
                        onChanged: (value) {
                          setState(() {
                            _questionCount = value.round();
                          });
                        },
                      ),
                      Text(
                        '$_questionCount questions',
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _startPractice,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text(
                            'Start Practice',
                            style: TextStyle(fontSize: 18),
                          ),
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

class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final String routeName;

  CustomPageRoute({required this.page, required this.routeName})
      : super(
          settings: RouteSettings(name: routeName),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        );
}

class QuizScreen extends StatefulWidget {
  final String subject;
  final String username;
  final List<Question> questions;
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
  int timeLeft = 30;

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
    timeLeft = 30;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
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
      context: context,
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
    final question = widget.questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject),
        backgroundColor: const Color(0xFF1D1E33),
        foregroundColor: Colors.white,
        actions: [
          if (widget.gameMode == 'timed')
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '$timeLeft',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
        ],
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
                  // Progress indicator
                  LinearProgressIndicator(
                    value: (currentQuestionIndex + 1) / widget.questionCount,
                    backgroundColor: Colors.grey[300],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                  ),
                  const SizedBox(height: 20),

                  // Question counter
                  Text(
                    'Question ${currentQuestionIndex + 1} of ${widget.questionCount}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Score
                  Text(
                    'Score: $score',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Question
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        question.questionText,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Answer options
                  Expanded(
                    child: ListView.builder(
                      itemCount: question.options.length,
                      itemBuilder: (context, index) {
                        final option = question.options[index];
                        Color cardColor = Colors.white;

                        if (isAnswered) {
                          if (option == question.correctAnswer) {
                            cardColor = Colors.green;
                          } else if (option == selectedAnswer) {
                            cardColor = Colors.red;
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Card(
                            elevation: 2,
                            color: cardColor,
                            child: ListTile(
                              title: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      isAnswered ? Colors.white : Colors.black,
                                ),
                              ),
                              onTap: () => selectAnswer(option),
                              trailing: isAnswered &&
                                      option == question.correctAnswer
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : null,
                            ),
                          ),
                        );
                      },
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
      ScaffoldMessenger.of(context).showSnackBar(
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Imported ${parsedQuestions.length} terms from Quizlet'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Could not parse Quizlet set. Please check the URL.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
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
      ScaffoldMessenger.of(context).showSnackBar(
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
      ScaffoldMessenger.of(context).showSnackBar(
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
      ScaffoldMessenger.of(context).showSnackBar(
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
      context: context,
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
      ),
      body: Stack(
        children: [
          const SpaceBackground(),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'How to use:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          color: Colors.green.withOpacity(0.1),
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '1. Go to any Quizlet set',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  '2. Copy the URL from your browser',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  '3. Paste it below and click Import',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Study Set Name',
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'Quizlet URL',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _urlController,
                          decoration: const InputDecoration(
                            labelText: 'Paste Quizlet set URL here',
                            labelStyle: TextStyle(color: Colors.white),
                            hintText:
                                'https://quizlet.com/123456789/sample-set',
                            hintStyle: TextStyle(color: Colors.white54),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                            prefixIcon: Icon(Icons.link, color: Colors.white),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _importFromQuizlet,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                            ),
                            child: const Text('Import from Quizlet'),
                          ),
                        ),
                        if (_questions.isNotEmpty) ...[
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Successfully imported ${_questions.length} terms',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Preview',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ...List.generate(
                            _questions.take(3).length,
                            (index) => Card(
                              color: Colors.green.withOpacity(0.2),
                              child: ListTile(
                                title: Text(
                                  _questions[index]['question'],
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  'Answer: ${_questions[index]['correct_answer']}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (_questions.length > 3)
                            Text(
                              '... and ${_questions.length - 3} more terms',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                        ],
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                _questions.isNotEmpty ? _createStudySet : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _questions.isNotEmpty
                                  ? Colors.blueAccent
                                  : Colors.grey,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                            ),
                            child: const Text('Create Study Set'),
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
      ScaffoldMessenger.of(context).showSnackBar(
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
      var excelDoc = excel.Excel.decodeBytes(bytes);
      var sheet = excelDoc.tables.values.first;

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Parsed ${parsedQuestions.length} questions from spreadsheet'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Excel parsing error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
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
      ScaffoldMessenger.of(context).showSnackBar(
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
      ScaffoldMessenger.of(context).showSnackBar(
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
      context: context,
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
      ),
      body: Stack(
        children: [
          const SpaceBackground(),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Expected Format:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          color: Colors.blue.withOpacity(0.1),
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Column A: Question',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  'Column B: Correct Answer',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  'Columns C-F: Options 1-4',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Study Set Name',
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'Select Spreadsheet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Card(
                          elevation: 4,
                          child: ListTile(
                            leading: Icon(
                              _hasFile ? Icons.check_circle : Icons.upload_file,
                              color: _hasFile ? Colors.green : Colors.blue,
                              size: 40,
                            ),
                            title: Text(
                              _hasFile ? 'File Selected' : 'Select Excel File',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              _hasFile ? _fileName : 'Tap to select .xlsx file',
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: _pickFile,
                          ),
                        ),
                        if (_questions.isNotEmpty) ...[
                          const SizedBox(height: 30),
                          Text(
                            'Preview (${_questions.length} questions)',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ...List.generate(
                            _questions.take(3).length,
                            (index) => Card(
                              color: Colors.blueAccent.withOpacity(0.2),
                              child: ListTile(
                                title: Text(
                                  _questions[index]['question'],
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  'Answer: ${_questions[index]['correct_answer']}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (_questions.length > 3)
                            Text(
                              '... and ${_questions.length - 3} more questions',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                        ],
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                _questions.isNotEmpty ? _createStudySet : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _questions.isNotEmpty
                                  ? Colors.green
                                  : Colors.grey,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                            ),
                            child: const Text('Create Study Set'),
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
      ScaffoldMessenger.of(context).showSnackBar(
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
      ScaffoldMessenger.of(context).showSnackBar(
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
      ScaffoldMessenger.of(context).showSnackBar(
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
      context: context,
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
        title: const Text('Create Questions Manually'),
        backgroundColor: const Color(0xFF1D1E33),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          const SpaceBackground(),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Study Set Name',
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'Add Questions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _questionController,
                          decoration: const InputDecoration(
                            labelText: 'Question',
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _correctAnswerController,
                          decoration: const InputDecoration(
                            labelText: 'Correct Answer',
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        ...List.generate(
                          4,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: TextFormField(
                              controller: _optionControllers[index],
                              decoration: InputDecoration(
                                labelText: 'Option ${index + 1}',
                                labelStyle:
                                    const TextStyle(color: Colors.white),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.blueAccent),
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _addQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                          ),
                          child: const Text('Add Question'),
                        ),
                        const SizedBox(height: 30),
                        if (_questions.isNotEmpty) ...[
                          const Text(
                            'Added Questions',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ...List.generate(
                            _questions.length,
                            (index) => Card(
                              color: Colors.blueAccent.withOpacity(0.2),
                              child: ListTile(
                                title: Text(
                                  _questions[index]['question'],
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  'Correct Answer: ${_questions[index]['correct_answer']}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _createStudySet,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                            ),
                            child: const Text('Create Study Set'),
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
