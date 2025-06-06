import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'questions.dart';
import 'dart:math'; // For random star positions
import 'package:google_sign_in/google_sign_in.dart'; // For Google Sign-In
import 'package:share_plus/share_plus.dart'; // For sharing the app
import 'dart:async';
import 'package:flutter/services.dart'; // For haptic feedback
import 'package:lottie/lottie.dart'; // For Lottie animations
import 'package:confetti/confetti.dart'; // For celebration effects
import 'study_set_selection_screen.dart';
import 'profile_screen.dart';

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

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both username and password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      HapticFeedback.mediumImpact();
      final isAuthenticated =
          await _dbHelper.authenticateUser(username, password);

      if (!mounted) return;

      if (isAuthenticated) {
        HapticFeedback.heavyImpact();
        Navigator.pushReplacement(
          context,
          CustomPageRoute(
            page: HomeScreen(
              username: username,
              currentTheme: 'space',
            ),
            routeName: '/home',
          ),
        );
      } else {
        HapticFeedback.vibrate();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('Invalid username or password'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error during sign-in: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
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
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final String email =
          googleUser.email ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';

      HapticFeedback.heavyImpact();
      Navigator.pushReplacement(
        context,
        CustomPageRoute(
          page: HomeScreen(
            username: email,
            currentTheme: 'space',
          ),
          routeName: '/home',
        ),
      );
    } catch (e) {
      print('Error during Google Sign-In: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to sign in with Google. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      print('Error during sign-up: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
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

class HomeScreen extends StatefulWidget {
  final String username;
  final String currentTheme;

  const HomeScreen({
    super.key,
    required this.username,
    required this.currentTheme,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          StudySetSelectionScreen(
            username: widget.username,
            currentTheme: widget.currentTheme,
          ),
          ShopScreen(
            username: widget.username,
            currentTheme: widget.currentTheme,
          ),
          ProfileScreen(
            username: widget.username,
            currentTheme: widget.currentTheme,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Study',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
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

class SubjectCard extends StatelessWidget {
  final String subject;
  final VoidCallback onTap;

  const SubjectCard({super.key, required this.subject, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.blueAccent, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getSubjectIcon(subject),
              size: 35,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
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
    );
  }

  // Helper function to get an icon for each subject
  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'math':
        return Icons.calculate;
      case 'history':
        return Icons.history;
      case 'english':
        return Icons.menu_book;
      case 'science':
        return Icons.science;
      default:
        return Icons.subject;
    }
  }
}

class GameModeSelectionScreen extends StatefulWidget {
  final String subject;
  final String username;
  final String currentTheme;
  final List<Question> questions;

  const GameModeSelectionScreen({
    super.key,
    required this.subject,
    required this.username,
    required this.currentTheme,
    required this.questions,
  });

  @override
  _GameModeSelectionScreenState createState() =>
      _GameModeSelectionScreenState();
}

class _GameModeSelectionScreenState extends State<GameModeSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
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
    _animationController.dispose();
    super.dispose();
  }

  void _startGame(String mode) async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    // Simulate loading
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    Navigator.push(
      context,
      CustomPageRoute(
        page: QuizScreen(
          subject: widget.subject,
          username: widget.username,
          questions: widget.questions,
          gameMode: mode,
          currentTheme: widget.currentTheme,
        ),
        routeName: '/quiz',
      ),
    ).then((_) => setState(() => _isLoading = false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.subject} Quiz',
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
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose Game Mode',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: widget.currentTheme == 'beach'
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Select how you want to play:',
                            style: TextStyle(
                              fontSize: 16,
                              color: widget.currentTheme == 'beach'
                                  ? Colors.black
                                  : Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Expanded(
                            child: GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              children: [
                                _buildGameModeCard(
                                  'Classic',
                                  Icons.timer,
                                  'Test your knowledge with timed questions',
                                  () => _startGame('classic'),
                                ),
                                _buildGameModeCard(
                                  'Survival',
                                  Icons.favorite,
                                  'See how long you can last with limited lives',
                                  () => _startGame('survival'),
                                ),
                                _buildGameModeCard(
                                  'Practice',
                                  Icons.school,
                                  'Learn at your own pace with no time limit',
                                  () => _startGame('practice'),
                                ),
                                _buildGameModeCard(
                                  'Challenge',
                                  Icons.emoji_events,
                                  'Compete for high scores and achievements',
                                  () => _startGame('challenge'),
                                ),
                              ],
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

  Widget _buildGameModeCard(
      String title, IconData icon, String description, VoidCallback onTap) {
    return Hero(
      tag: 'mode_$title',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blueAccent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 35,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShopScreen extends StatefulWidget {
  final String username;
  final String currentTheme;

  const ShopScreen({
    super.key,
    required this.username,
    required this.currentTheme,
  });

  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  int _userPoints = 0;
  String _currentTheme = 'space';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserPoints();
    _loadCurrentTheme();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
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
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPoints() async {
    final points = await _dbHelper.getUserPoints(widget.username);
    setState(() {
      _userPoints = points;
      _isLoading = false;
    });
  }

  Future<void> _loadCurrentTheme() async {
    final theme = await _dbHelper.getCurrentTheme(widget.username);
    setState(() {
      _currentTheme = theme ?? 'space';
    });
  }

  Future<void> _purchaseTheme(String theme) async {
    if (_userPoints >= 100) {
      try {
        await _dbHelper.purchaseTheme(widget.username, theme);
        setState(() {
          _userPoints -= 100;
          _currentTheme = theme;
        });
        HapticFeedback.heavyImpact();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully purchased $theme theme!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to purchase theme. Please try again.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else {
      HapticFeedback.vibrate();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not enough points!'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shop',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor:
            _currentTheme == 'beach' ? Colors.orange : const Color(0xFF1D1E33),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Row(
                children: [
                  const Icon(Icons.stars, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    '$_userPoints',
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
        ],
      ),
      body: Stack(
        children: [
          _currentTheme == 'beach'
              ? Image.asset(
                  'assets/images/beach.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              : const SpaceBackground(),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Available Themes',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: _currentTheme == 'beach'
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Purchase new themes for 100 points each',
                            style: TextStyle(
                              fontSize: 16,
                              color: _currentTheme == 'beach'
                                  ? Colors.black
                                  : Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Expanded(
                            child: GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              children: [
                                _buildThemeCard(
                                  'Space',
                                  Icons.rocket_launch,
                                  'A cosmic adventure',
                                  'space',
                                ),
                                _buildThemeCard(
                                  'Beach',
                                  Icons.beach_access,
                                  'Relaxing ocean vibes',
                                  'beach',
                                ),
                                _buildThemeCard(
                                  'Forest',
                                  Icons.forest,
                                  'Nature\'s tranquility',
                                  'forest',
                                ),
                                _buildThemeCard(
                                  'City',
                                  Icons.location_city,
                                  'Urban exploration',
                                  'city',
                                ),
                              ],
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

  Widget _buildThemeCard(
      String title, IconData icon, String description, String theme) {
    final isOwned = theme == _currentTheme;
    final canAfford = _userPoints >= 100;

    return Hero(
      tag: 'theme_$theme',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isOwned ? null : () => _purchaseTheme(theme),
          borderRadius: BorderRadius.circular(15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isOwned ? Colors.green : Colors.blueAccent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 35,
                  color: isOwned ? Colors.green : Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isOwned ? Colors.green : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                if (!isOwned)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color: canAfford ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars, color: Colors.white, size: 16),
                        const SizedBox(width: 5),
                        const Text(
                          '100',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (isOwned)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, color: Colors.white, size: 16),
                        SizedBox(width: 5),
                        Text(
                          'Owned',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
    );
  }
}

class QuestionSelectionScreen extends StatelessWidget {
  final String subject;
  final List<Question> questions;
  final String username;
  final String currentTheme;

  const QuestionSelectionScreen({
    super.key,
    required this.subject,
    required this.questions,
    required this.username,
    required this.currentTheme,
  });

  @override
  Widget build(BuildContext context) {
    return QuizScreen(
      subject: subject,
      username: username,
      questions: questions,
      currentTheme: currentTheme,
      gameMode: 'classic', // Add the gameMode parameter
    );
  }
}

class QuizScreen extends StatefulWidget {
  final String subject;
  final List<Question> questions;
  final String username;
  final String currentTheme;
  final String gameMode;

  const QuizScreen({
    super.key,
    required this.subject,
    required this.questions,
    required this.username,
    required this.currentTheme,
    required this.gameMode,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _hasAnswered = false;
  String? _selectedAnswer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;
  int _lives = 3;
  int _timeLeft = 30;
  Timer? _timer;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _startTimer();
    _animationController.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (widget.gameMode == 'classic' || widget.gameMode == 'survival') {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_timeLeft > 0) {
          setState(() {
            _timeLeft--;
          });
        } else {
          _handleTimeUp();
        }
      });
    }
  }

  void _handleTimeUp() {
    if (widget.gameMode == 'survival') {
      setState(() {
        _lives--;
        if (_lives <= 0) {
          _endGame();
        } else {
          _nextQuestion();
        }
      });
    } else {
      _nextQuestion();
    }
  }

  void _endGame() {
    setState(() {
      _isGameOver = true;
      _timer?.cancel();
    });
  }

  void _checkAnswer(String answer) {
    if (_hasAnswered) return;

    setState(() {
      _hasAnswered = true;
      _selectedAnswer = answer;
      _timer?.cancel();
    });

    HapticFeedback.mediumImpact();

    if (answer == widget.questions[_currentQuestionIndex].correctAnswer) {
      setState(() {
        _score++;
      });
      HapticFeedback.heavyImpact();
    } else if (widget.gameMode == 'survival') {
      setState(() {
        _lives--;
      });
      HapticFeedback.vibrate();
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        if (widget.gameMode == 'survival' && _lives <= 0) {
          _endGame();
        } else {
          _nextQuestion();
        }
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _hasAnswered = false;
        _selectedAnswer = null;
        _timeLeft = 30;
        _animationController.reset();
        _animationController.forward();
      });
      _startTimer();
    } else {
      _endGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isGameOver) {
      return _buildGameOverScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.subject} Quiz',
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
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.gameMode == 'classic' ||
                              widget.gameMode == 'survival')
                            LinearProgressIndicator(
                              value: _timeLeft / 30,
                              backgroundColor: Colors.grey.withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _timeLeft > 10 ? Colors.green : Colors.red,
                              ),
                            ),
                          const SizedBox(height: 20),
                          Text(
                            'Question ${_currentQuestionIndex + 1}/${widget.questions.length}',
                            style: TextStyle(
                              fontSize: 16,
                              color: widget.currentTheme == 'beach'
                                  ? Colors.black
                                  : Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget
                                .questions[_currentQuestionIndex].questionText,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: widget.currentTheme == 'beach'
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Expanded(
                            child: ListView.builder(
                              itemCount: widget.questions[_currentQuestionIndex]
                                  .options.length,
                              itemBuilder: (context, index) {
                                final option = widget
                                    .questions[_currentQuestionIndex]
                                    .options[index];
                                final isCorrect = option ==
                                    widget.questions[_currentQuestionIndex]
                                        .correctAnswer;
                                final isSelected = _selectedAnswer == option;
                                Color backgroundColor =
                                    Colors.blueAccent.withOpacity(0.2);
                                Color borderColor = Colors.blueAccent;

                                if (_hasAnswered) {
                                  if (isCorrect) {
                                    backgroundColor =
                                        Colors.green.withOpacity(0.2);
                                    borderColor = Colors.green;
                                  } else if (isSelected) {
                                    backgroundColor =
                                        Colors.red.withOpacity(0.2);
                                    borderColor = Colors.red;
                                  }
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _checkAnswer(option),
                                      borderRadius: BorderRadius.circular(15),
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: backgroundColor,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                              color: borderColor, width: 2),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 10,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              _hasAnswered
                                                  ? (isCorrect
                                                      ? Icons.check_circle
                                                      : isSelected
                                                          ? Icons.cancel
                                                          : Icons
                                                              .circle_outlined)
                                                  : Icons.circle_outlined,
                                              color: _hasAnswered
                                                  ? (isCorrect
                                                      ? Colors.green
                                                      : isSelected
                                                          ? Colors.red
                                                          : Colors.white)
                                                  : Colors.white,
                                            ),
                                            const SizedBox(width: 15),
                                            Expanded(
                                              child: Text(
                                                option,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white,
                                                ),
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

  Widget _buildGameOverScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Game Over',
          style: TextStyle(
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
          Center(
            child: Container(
              padding: const EdgeInsets.all(30),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blueAccent, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Final Score',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: widget.currentTheme == 'beach'
                          ? Colors.orange
                          : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '$_score/${widget.questions.length}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.currentTheme == 'beach'
                          ? Colors.orange
                          : Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Back to Menu',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
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

// Add this new class for custom page transitions
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
