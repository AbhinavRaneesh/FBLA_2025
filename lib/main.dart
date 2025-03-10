import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'questions.dart';
import 'dart:math'; // For random star positions
import 'package:google_sign_in/google_sign_in.dart'; // For Google Sign-In
import 'package:share_plus/share_plus.dart'; // For sharing the app

void main() {
  runApp(const StudentLearningApp());
}

class StudentLearningApp extends StatelessWidget {
  const StudentLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Learning App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0A0E21), // Dark space background
      ),
      home: SignInPage(), // Correctly defined home property
      debugShowCheckedModeBanner: false,
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
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20), // Adjust padding
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

class _SignInPageState extends State<SignInPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dbHelper = DatabaseHelper();
  bool _showPassword = false;
  bool _isFormValid = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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
      _isFormValid = _usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    });
  }

  Future<void> _signIn() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both username and password.')),
      );
      return;
    }

    try {
      final isAuthenticated = await _dbHelper.authenticateUser(username, password);

      if (isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign-in successful!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              username: username,
              onPointsUpdated: (newPoints) {},
              onThemeChanged: (newTheme) {},
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid username or password.')),
        );
      }
    } catch (e) {
      print('Error during sign-in: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // User canceled the sign-in

      // Navigate to HomeScreen with Google user's email as the username
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            username: googleUser.email,
            onPointsUpdated: (newPoints) {},
            onThemeChanged: (newTheme) {},
          ),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed in with Google successfully!')),
      );
    } catch (e) {
      print('Error during Google Sign-In: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to sign in with Google. Please try again.')),
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
            top: 50,
            left: 20,
            child: Image.asset(
              'assets/images/planet.png',
              height: 200,
            ),
          ),
          Positioned(
            bottom: 30,
            right: 20,
            child: Image.asset(
              'assets/images/astronaut.png',
              height: 200,
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
                      'Welcome To EduQuest!',
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
                        child: Column(
                          children: [
                            TextField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                labelStyle: TextStyle(color: Colors.black),
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person, color: Colors.black),
                              ),
                              style: const TextStyle(color: Colors.black),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: _passwordController,
                              obscureText: !_showPassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: const TextStyle(color: Colors.black),
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.lock, color: Colors.black),
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
                                    const Text('Show Password', style: TextStyle(fontSize: 12, color: Colors.black)),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                              ),
                              style: const TextStyle(color: Colors.black),
                            ),
                            const SizedBox(height: 20),
                            // Sign In Button
                            Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: ElevatedButton(
                                onPressed: _isFormValid ? _signIn : null, // Disable if form is invalid
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isFormValid ? Colors.blueAccent : Colors.grey, // Grey out if disabled
                                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(color: _isFormValid ? Colors.blueAccent : Colors.grey, width: 2),
                                  ),
                                ),
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(fontSize: 18, color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Sign in with Google Button
                            ElevatedButton(
                              onPressed: _signInWithGoogle,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/google_icon.png', // Add a Google icon asset
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
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
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
      _isFormValid = _usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty;
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
          const SnackBar(content: Text('Username already exists. Please choose a different one.')),
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
          const SnackBar(content: Text('Something went wrong. Please try again.')),
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
            top: 50,
            left: 20,
            child: Image.asset(
              'assets/images/planet.png',
              height: 200,
            ),
          ),
          Positioned(
            bottom: 30,
            right: 20,
            child: Image.asset(
              'assets/images/astronaut.png',
              height: 200,
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
                        child: Column(
                          children: [
                            TextField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                labelStyle: TextStyle(color: Colors.black),
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person, color: Colors.black),
                              ),
                              style: const TextStyle(color: Colors.black),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: _passwordController,
                              obscureText: !_showPassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: const TextStyle(color: Colors.black),
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.lock, color: Colors.black),
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
                                    const Text('Show Password', style: TextStyle(fontSize: 12, color: Colors.black)),
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
                                onPressed: _isFormValid ? _signUp : null, // Disable if form is invalid
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isFormValid ? Colors.blueAccent : Colors.grey, // Grey out if disabled
                                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(color: _isFormValid ? Colors.blueAccent : Colors.grey, width: 2),
                                  ),
                                ),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(fontSize: 18, color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Navigate back to the SignInPage
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
  final Function(int) onPointsUpdated;
  final Function(String) onThemeChanged;

  HomeScreen({
    super.key,
    required this.username,
    required this.onPointsUpdated,
    required this.onThemeChanged,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _userPoints = 0;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String _currentTheme = 'space'; // Default theme

  @override
  void initState() {
    super.initState();
    _loadUserPoints();
    _loadCurrentTheme();
  }

  Future<void> _loadUserPoints() async {
    final points = await _dbHelper.getUserPoints(widget.username);
    setState(() {
      _userPoints = points;
    });
  }

  Future<void> _loadCurrentTheme() async {
    final theme = await _dbHelper.getCurrentTheme(widget.username);
    setState(() {
      _currentTheme = theme ?? 'space';
    });
  }

  void _updatePoints(int newPoints) {
    setState(() {
      _userPoints = newPoints;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EduQuest', style: TextStyle(color: Colors.white)),
        backgroundColor: _currentTheme == 'beach' ? Colors.orange : const Color(0xFF1D1E33),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Points: $_userPoints',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _currentTheme == 'beach' ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
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
          _currentTheme == 'beach'
              ? Image.asset(
            'assets/images/beach.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          )
              : const SpaceBackground(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${widget.username}!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _currentTheme == 'beach' ? Colors.black : Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Choose a subject to start learning:',
                  style: TextStyle(
                    fontSize: 16,
                    color: _currentTheme == 'beach' ? Colors.black : Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    children: [
                      SubjectCard(
                        subject: 'Math',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuestionSelectionScreen(
                                subject: 'Math',
                                questions: QuestionsRepository.getQuestionsForSubject('Math'),
                                username: widget.username,
                                currentTheme: _currentTheme,
                              ),
                            ),
                          );
                        },
                      ),
                      SubjectCard(
                        subject: 'History',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuestionSelectionScreen(
                                subject: 'History',
                                questions: QuestionsRepository.getQuestionsForSubject('History'),
                                username: widget.username,
                                currentTheme: _currentTheme,
                              ),
                            ),
                          );
                        },
                      ),
                      SubjectCard(
                        subject: 'English',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuestionSelectionScreen(
                                subject: 'English',
                                questions: QuestionsRepository.getQuestionsForSubject('English'),
                                username: widget.username,
                                currentTheme: _currentTheme,
                              ),
                            ),
                          );
                        },
                      ),
                      SubjectCard(
                        subject: 'Science',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuestionSelectionScreen(
                                subject: 'Science',
                                questions: QuestionsRepository.getQuestionsForSubject('Science'),
                                username: widget.username,
                                currentTheme: _currentTheme,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Shop Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShopScreen(
                            username: widget.username,
                            onPointsUpdated: _updatePoints,
                            onThemeChanged: (newTheme) {
                              setState(() {
                                _currentTheme = newTheme;
                              });
                            },
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentTheme == 'beach' ? Colors.orange : Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Visit Shop',
                      style: TextStyle(fontSize: 20, color: Colors.white),
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
              size: 50,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            Text(
              subject,
              style: const TextStyle(
                fontSize: 20,
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

class ShopScreen extends StatefulWidget {
  final String username;
  final Function(int) onPointsUpdated;
  final Function(String) onThemeChanged;

  const ShopScreen({
    super.key,
    required this.username,
    required this.onPointsUpdated,
    required this.onThemeChanged,
  });

  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _userPoints = 0;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, int> powerupQuantities = {};
  bool isLoading = true;
  String _currentTheme = 'space'; // Track the current theme

  final List<ShopItem> powerups = [
    ShopItem(
      itemName: 'Double Points',
      cost: 10,
      isPurchased: false,
      isEquipped: false,
      type: ShopItemType.powerup,
    ),
    ShopItem(
      itemName: '50/50',
      cost: 20,
      isPurchased: false,
      isEquipped: false,
      type: ShopItemType.powerup,
    ),
    ShopItem(
      itemName: 'Skip Question',
      cost: 30,
      isPurchased: false,
      isEquipped: false,
      type: ShopItemType.powerup,
    ),
    ShopItem(
      itemName: 'Double or Nothing',
      cost: 30,
      isPurchased: false,
      isEquipped: false,
      type: ShopItemType.powerup,
    ),
  ];

  final List<ShopItem> themes = [
    ShopItem(
      itemName: 'Space Theme',
      cost: 0, // Free
      isPurchased: true, // Defaultly purchased
      isEquipped: true, // Defaultly equipped
      type: ShopItemType.theme,
      themeName: 'space',
    ),
    ShopItem(
      itemName: 'Beach Theme',
      cost: 0,
      isPurchased: false,
      isEquipped: false,
      type: ShopItemType.theme,
      themeName: 'beach',
    ),
    ShopItem(
      itemName: 'Mountain Theme',
      cost: 750,
      isPurchased: false,
      isEquipped: false,
      type: ShopItemType.theme,
      themeName: 'mountain',
    ),
    ShopItem(
      itemName: 'Egypt Theme',
      cost: 1000,
      isPurchased: false,
      isEquipped: false,
      type: ShopItemType.theme,
      themeName: 'egypt',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final points = await _dbHelper.getUserPoints(widget.username);
    final quantities = await Future.wait(
      powerups.map((powerup) => _dbHelper.getPowerupQuantity(widget.username, powerup.itemName)),
    );

    // Load theme purchase and equip status
    for (var theme in themes) {
      final isPurchased = await _dbHelper.isThemePurchased(widget.username, theme.themeName!);
      final currentTheme = await _dbHelper.getCurrentTheme(widget.username);
      setState(() {
        theme.isPurchased = isPurchased;
        theme.isEquipped = currentTheme == theme.themeName;
        _currentTheme = currentTheme ?? 'space';
      });
    }

    setState(() {
      _userPoints = points;
      for (var i = 0; i < powerups.length; i++) {
        powerupQuantities[powerups[i].itemName] = quantities[i];
        powerups[i].quantity = quantities[i];
      }
      isLoading = false;
    });
  }

  Future<void> _purchaseItem(ShopItem item) async {
    if (_userPoints < item.cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough points to purchase this item.')),
      );
      return;
    }

    try {
      final newPoints = _userPoints - item.cost;
      await _dbHelper.updateUserPoints(widget.username, newPoints);

      if (item.type == ShopItemType.powerup) {
        final newQuantity = (powerupQuantities[item.itemName] ?? 0) + 1;
        await _dbHelper.updatePowerupQuantity(widget.username, item.itemName, newQuantity);

        setState(() {
          _userPoints = newPoints;
          powerupQuantities[item.itemName] = newQuantity;
          item.quantity = newQuantity;
        });
      } else if (item.type == ShopItemType.theme) {
        await _dbHelper.purchaseTheme(widget.username, item.themeName!);

        setState(() {
          _userPoints = newPoints;
          item.isPurchased = true;
        });
      }

      widget.onPointsUpdated(newPoints);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.itemName} purchased successfully!')),
      );
    } catch (e) {
      print('Error purchasing item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  Future<void> _equipTheme(ShopItem theme) async {
    try {
      await _dbHelper.equipTheme(widget.username, theme.themeName!);
      setState(() {
        for (var t in themes) {
          t.isEquipped = false;
        }
        theme.isEquipped = true;
        _currentTheme = theme.themeName!;
      });
      widget.onThemeChanged(theme.themeName!); // Notify the HomeScreen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${theme.itemName} equipped successfully!')),
      );
    } catch (e) {
      print('Error equipping theme: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop', style: TextStyle(color: Colors.white)),
        backgroundColor: _currentTheme == 'beach' ? Colors.orange : const Color(0xFF1D1E33),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.palette),
                  SizedBox(width: 8),
                  Text('Themes'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome),
                  SizedBox(width: 8),
                  Text('Powerups'),
                ],
              ),
            ),
          ],
        ),
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
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.stars, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      'Points: $_userPoints',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _currentTheme == 'beach' ? Colors.black : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildThemesTab(),
                    _buildPowerupsTab(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemesTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: themes.length,
      itemBuilder: (context, index) {
        final theme = themes[index];
        return ShopItemCard(
          item: theme,
          onPurchase: () => _purchaseItem(theme),
          onEquip: theme.isPurchased ? () => _equipTheme(theme) : null,
          currentTheme: _currentTheme,
        );
      },
    );
  }

  Widget _buildPowerupsTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: powerups.length,
      itemBuilder: (context, index) {
        final powerup = powerups[index];
        return ShopItemCard(
          item: powerup,
          onPurchase: () => _purchaseItem(powerup),
          currentTheme: _currentTheme,
        );
      },
    );
  }
}

// Model class for shop items
enum ShopItemType { theme, powerup }

class ShopItem {
  final String itemName;
  final int cost;
  bool isPurchased;
  bool isEquipped;
  final ShopItemType type;
  int quantity; // Track how many powerups the user owns
  String? themeName; // Add this field for themes

  ShopItem({
    required this.itemName,
    required this.cost,
    required this.isPurchased,
    required this.isEquipped,
    required this.type,
    this.quantity = 0, // Default to 0
    this.themeName, // Add this field for themes
  });
}

// Custom widget for shop item cards
class ShopItemCard extends StatelessWidget {
  final ShopItem item;
  final VoidCallback onPurchase;
  final VoidCallback? onEquip;
  final String currentTheme;

  const ShopItemCard({
    super.key,
    required this.item,
    required this.onPurchase,
    this.onEquip,
    required this.currentTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: currentTheme == 'beach' ? Colors.orange.withOpacity(0.2) : Colors.blueAccent.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: currentTheme == 'beach' ? Colors.orange : Colors.blueAccent, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.itemName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: currentTheme == 'beach' ? Colors.black : Colors.white,
                    ),
                  ),
                ),
                if (item.type == ShopItemType.powerup)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: currentTheme == 'beach' ? Colors.orange.withOpacity(0.3) : Colors.blueAccent.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: currentTheme == 'beach' ? Colors.orange : Colors.blueAccent),
                    ),
                    child: Text(
                      'x${item.quantity}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: currentTheme == 'beach' ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Cost: ${item.cost} points',
              style: TextStyle(
                fontSize: 16,
                color: currentTheme == 'beach' ? Colors.black : Colors.white70,
              ),
            ),
            const SizedBox(height: 10),
            if (item.type == ShopItemType.theme && item.isPurchased)
              ElevatedButton(
                onPressed: onEquip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: item.isEquipped ? Colors.green : Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  item.isEquipped ? 'Equipped' : 'Equip',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            if (item.type == ShopItemType.powerup || !item.isPurchased)
              ElevatedButton(
                onPressed: onPurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentTheme == 'beach' ? Colors.orange : Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Buy',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class QuestionSelectionScreen extends StatefulWidget {
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
  _QuestionSelectionScreenState createState() => _QuestionSelectionScreenState();
}

class _QuestionSelectionScreenState extends State<QuestionSelectionScreen> {
  int _numberOfQuestions = 10;

  @override
  Widget build(BuildContext context) {
    final questions = QuestionsRepository.getQuestionsForSubject(widget.subject);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Number of Questions',
          style: TextStyle(
            color: widget.currentTheme == 'beach' ? Colors.black : Colors.white, // Dynamic text color
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: widget.currentTheme == 'beach' ? Colors.orange : const Color(0xFF1D1E33), // Dynamic app bar color
        iconTheme: IconThemeData(
          color: widget.currentTheme == 'beach' ? Colors.black : Colors.white, // Dynamic icon color
        ),
        elevation: 0,
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
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Amount of Questions:',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: widget.currentTheme == 'beach' ? Colors.black : Colors.white, // Dynamic text color
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  '$_numberOfQuestions',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: widget.currentTheme == 'beach' ? Colors.blue : Colors.blueAccent, // Dynamic text color
                  ),
                ),
                Slider(
                  value: _numberOfQuestions.toDouble(),
                  min: 1,
                  max: widget.questions.length.toDouble(),
                  divisions: widget.questions.length - 1,
                  label: _numberOfQuestions.toString(),
                  activeColor: widget.currentTheme == 'beach' ? Colors.orange : Colors.blueAccent, // Dynamic slider color
                  inactiveColor: widget.currentTheme == 'beach' ? Colors.orange.withOpacity(0.3) : Colors.blueAccent.withOpacity(0.3), // Dynamic slider color
                  onChanged: (value) {
                    setState(() {
                      _numberOfQuestions = value.toInt();
                    });
                  },
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizScreen(
                            subject: widget.subject,
                            questions: widget.questions.take(_numberOfQuestions).toList(),
                            username: widget.username,
                            currentTheme: widget.currentTheme,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.currentTheme == 'beach' ? Colors.orange : Colors.blueAccent, // Dynamic button color
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Start Quiz',
                      style: TextStyle(
                        fontSize: 18,
                        color: widget.currentTheme == 'beach' ? Colors.black : Colors.white, // Dynamic text color
                        fontWeight: FontWeight.bold,
                      ),
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

class QuizScreen extends StatefulWidget {
  final String subject;
  final List<Question> questions;
  final String username;
  final String currentTheme;

  const QuizScreen({
    super.key,
    required this.subject,
    required this.questions,
    required this.username,
    required this.currentTheme,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  bool isAnswered = false;
  int pointsEarnedInRound = 0;
  int totalPoints = 0;
  int correctAnswersCount = 0;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Powerups
  bool isDoublePointsActive = false;
  bool isFiftyFiftyActive = false;
  bool isSkipQuestionActive = false;
  bool isDoubleOrNothingActive = false;

  // Powerup quantities
  int doublePointsQuantity = 0;
  int fiftyFiftyQuantity = 0;
  int skipQuestionQuantity = 0;
  int doubleOrNothingQuantity = 0;

  @override
  void initState() {
    super.initState();
    _loadUserPoints();
    _loadPowerupQuantities();
  }

  Future<void> _loadUserPoints() async {
    final points = await _dbHelper.getUserPoints(widget.username);
    setState(() {
      totalPoints = points;
    });
  }

  Future<void> _loadPowerupQuantities() async {
    doublePointsQuantity = await _dbHelper.getPowerupQuantity(widget.username, 'Double Points');
    fiftyFiftyQuantity = await _dbHelper.getPowerupQuantity(widget.username, '50/50');
    skipQuestionQuantity = await _dbHelper.getPowerupQuantity(widget.username, 'Skip Question');
    doubleOrNothingQuantity = await _dbHelper.getPowerupQuantity(widget.username, 'Double or Nothing');
    setState(() {});
  }

  Future<void> _updateUserPoints() async {
    await _dbHelper.updateUserPoints(widget.username, totalPoints + pointsEarnedInRound);
  }

  void _checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      isAnswered = true;

      if (answer == widget.questions[currentQuestionIndex].correctAnswer) {
        if (isDoublePointsActive) {
          pointsEarnedInRound += 20;
        } else if (isDoubleOrNothingActive) {
          pointsEarnedInRound += 20;
        } else {
          pointsEarnedInRound += 10;
        }
        correctAnswersCount++;
      } else {
        if (isDoubleOrNothingActive) {
          pointsEarnedInRound -= 20;
        }
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      if (currentQuestionIndex < widget.questions.length - 1) {
        currentQuestionIndex++;
        selectedAnswer = null;
        isAnswered = false;
        isDoublePointsActive = false;
        isFiftyFiftyActive = false;
        isSkipQuestionActive = false;
        isDoubleOrNothingActive = false;
      } else {
        _showFinalScore();
      }
    });
  }

  void _usePowerup(String powerup) {
    setState(() {
      switch (powerup) {
        case 'Double Points':
          if (doublePointsQuantity > 0) {
            isDoublePointsActive = true;
            doublePointsQuantity--;
            _dbHelper.updatePowerupQuantity(widget.username, powerup, doublePointsQuantity);
          }
          break;
        case '50/50':
          if (fiftyFiftyQuantity > 0) {
            isFiftyFiftyActive = true;
            fiftyFiftyQuantity--;
            _dbHelper.updatePowerupQuantity(widget.username, powerup, fiftyFiftyQuantity);
          }
          break;
        case 'Skip Question':
          if (skipQuestionQuantity > 0) {
            isSkipQuestionActive = true;
            skipQuestionQuantity--;
            _dbHelper.updatePowerupQuantity(widget.username, powerup, skipQuestionQuantity);
            _nextQuestion();
          }
          break;
        case 'Double or Nothing':
          if (doubleOrNothingQuantity > 0) {
            isDoubleOrNothingActive = true;
            doubleOrNothingQuantity--;
            _dbHelper.updatePowerupQuantity(widget.username, powerup, doubleOrNothingQuantity);
          }
          break;
      }
    });
  }

  List<String> _applyFiftyFifty(List<String> options, String correctAnswer) {
    final incorrectOptions = options.where((option) => option != correctAnswer).toList();
    incorrectOptions.shuffle();
    return [correctAnswer, incorrectOptions.first];
  }

  // Function to share quiz results
  void _shareQuizResults() {
    String message = "I just scored $correctAnswersCount out of ${widget.questions.length} in ${widget.subject} on EduQuest! 🚀\n"
        "Total Points: ${totalPoints + pointsEarnedInRound}\n"
        "Download the app and join the fun!";

    Share.share(message); // Use Share.share() to show the share sheet
  }

  void _showFinalScore() {
    _updateUserPoints().then((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: widget.currentTheme == 'beach' ? Colors.orange.withOpacity(0.9) : const Color(0xFF1D1E33),
          title: Text(
            'Quiz Finished!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: widget.currentTheme == 'beach' ? Colors.black : Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your Score:',
                style: TextStyle(
                    fontSize: 16,
                    color: widget.currentTheme == 'beach' ? Colors.black : Colors.white
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$correctAnswersCount/${widget.questions.length}',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.currentTheme == 'beach' ? Colors.blue : Colors.blueAccent
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Points Earned This Round: $pointsEarnedInRound',
                style: TextStyle(
                    fontSize: 14,
                    color: widget.currentTheme == 'beach' ? Colors.black : Colors.white
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total Points: ${totalPoints + pointsEarnedInRound}',
                style: TextStyle(
                    fontSize: 14,
                    color: widget.currentTheme == 'beach' ? Colors.black : Colors.white
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(
                        username: widget.username,
                        onPointsUpdated: (newPoints) {},
                        onThemeChanged: (newTheme) {},
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.currentTheme == 'beach' ? Colors.orange : Colors.blueAccent,
                  minimumSize: Size(120, 40),
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _shareQuizResults,
                style: TextButton.styleFrom(
                  minimumSize: Size(120, 40),
                ),
                child: Text(
                  'Share Results',
                  style: TextStyle(
                    fontSize: 16,
                    color: widget.currentTheme == 'beach' ? Colors.blue : Colors.blueAccent,
                  ),
                ),
              ),
            ],
          ),
          actions: [], // Removed actions from here
        ),
      );
    });
  }

  Widget _buildPowerupButton(String powerup, int quantity, Widget icon, Color activeColor) {
    bool isActive = false;
    Color buttonColor = widget.currentTheme == 'beach' ? Colors.orange.withOpacity(0.2) : const Color(0xFF1D1E33);

    switch (powerup) {
      case 'Double Points':
        isActive = isDoublePointsActive;
        buttonColor = isActive ? activeColor : widget.currentTheme == 'beach' ? Colors.orange.withOpacity(0.2) : const Color(0xFF1D1E33);
        break;
      case '50/50':
        isActive = isFiftyFiftyActive;
        buttonColor = isActive ? activeColor : widget.currentTheme == 'beach' ? Colors.orange.withOpacity(0.2) : const Color(0xFF1D1E33);
        break;
      case 'Skip Question':
        isActive = isSkipQuestionActive;
        buttonColor = isActive ? activeColor : widget.currentTheme == 'beach' ? Colors.orange.withOpacity(0.2) : const Color(0xFF1D1E33);
        break;
      case 'Double or Nothing':
        isActive = isDoubleOrNothingActive;
        buttonColor = isActive ? activeColor : widget.currentTheme == 'beach' ? Colors.orange.withOpacity(0.2) : const Color(0xFF1D1E33);
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Opacity(
        opacity: quantity > 0 ? 1.0 : 0.5,
        child: ElevatedButton(
          onPressed: quantity > 0 && !isAnswered ? () => _usePowerup(powerup) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: widget.currentTheme == 'beach' ? Colors.orange : Colors.blueAccent, width: 2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: icon,
              ),
              const SizedBox(width: 4),
              Text(
                'x$quantity',
                style: TextStyle(
                  color: widget.currentTheme == 'beach' ? Colors.black : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Question currentQuestion = widget.questions[currentQuestionIndex];
    List<String> options = currentQuestion.options;

    if (isFiftyFiftyActive) {
      options = _applyFiftyFifty(options, currentQuestion.correctAnswer);
    }

    return Scaffold(
      backgroundColor: widget.currentTheme == 'beach'
          ? Colors.orange.withOpacity(0.1)
          : const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(
          widget.subject,
          style: TextStyle(
            color: widget.currentTheme == 'beach' ? Colors.black : Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: widget.currentTheme == 'beach'
            ? Colors.orange
            : const Color(0xFF1D1E33),
        iconTheme: IconThemeData(
          color: widget.currentTheme == 'beach' ? Colors.black : Colors.white,
        ),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Points: ${totalPoints + pointsEarnedInRound}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.currentTheme == 'beach' ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
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
         Column(
          children: [
          // Progress Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${currentQuestionIndex + 1}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.currentTheme == 'beach' ? Colors.black : Colors.white,
                      ),
                    ),
                    Text(
                      '${currentQuestionIndex + 1}/${widget.questions.length}',
                      style: TextStyle(
                        fontSize: 18,
                        color: widget.currentTheme == 'beach' ? Colors.black : Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (currentQuestionIndex + 1) / widget.questions.length,
                    backgroundColor: widget.currentTheme == 'beach'
                        ? Colors.orange.withOpacity(0.3)
                        : Colors.blueAccent.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.currentTheme == 'beach' ? Colors.orange : Colors.blueAccent,
                    ),
                    minHeight: 10,
                  ),
                ),
              ],
            ),
          ),

          // Question Text
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.currentTheme == 'beach'
                          ? Colors.orange.withOpacity(0.2)
                          : Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: widget.currentTheme == 'beach'
                            ? Colors.orange
                            : Colors.blueAccent.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      currentQuestion.questionText,
                      style: TextStyle(
                        fontSize: 20,
                        color: widget.currentTheme == 'beach' ? Colors.black : Colors.white,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Answer Options
                  ...options.map((option) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: GameButton(
                      text: option,
                      onPressed: isAnswered ? null : () => _checkAnswer(option),
                      isSelected: selectedAnswer == option,
                      isCorrect: isAnswered
                          ? option == currentQuestion.correctAnswer
                          : null,
                      currentTheme: widget.currentTheme,
                    ),
                  )),
                  if (isAnswered) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7, // Makes button wider
                      margin: const EdgeInsets.only(bottom: 20),
                      child: ElevatedButton(
                        onPressed: _nextQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.currentTheme == 'beach'
                              ? Colors.orange
                              : Colors.purple,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          currentQuestionIndex < widget.questions.length - 1
                              ? 'Next Question'
                              : 'Finish Quiz',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: widget.currentTheme == 'beach'
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Powerups Bar at the bottom
          Container(
            height: 80, // Adjust height as needed
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: widget.currentTheme == 'beach'
                  ? Colors.orange.withOpacity(0.2)
                  : Colors.black.withOpacity(0.3),
              border: Border(
                top: BorderSide(
                  color: widget.currentTheme == 'beach'
                      ? Colors.orange
                      : Colors.blueAccent.withOpacity(0.3),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPowerupButton(
                  'Double Points',
                  doublePointsQuantity,
                  const Icon(Icons.looks_two, color: Colors.white, size: 24),
                  Colors.green,
                ),
                _buildPowerupButton(
                  '50/50',
                  fiftyFiftyQuantity,
                  const Icon(Icons.balance, color: Colors.white, size: 24),
                  Colors.orange,
                ),
                _buildPowerupButton(
                  'Skip Question',
                  skipQuestionQuantity,
                  const Icon(Icons.skip_next, color: Colors.white, size: 24),
                  Colors.red,
                ),
                _buildPowerupButton(
                  'Double or Nothing',
                  doubleOrNothingQuantity,
                  const Icon(Icons.casino, color: Colors.white, size: 24),
                  Colors.purple,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}