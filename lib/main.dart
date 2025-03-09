import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'questions.dart';
import 'dart:math'; // For random star positions
import 'package:google_sign_in/google_sign_in.dart'; // For Google Sign-In

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

  const GameButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, color: Colors.white),
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
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Google Sign-In instance

  // Track whether the username and password fields have input
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    // Listen for changes in the text fields
    _usernameController.addListener(_updateFormState);
    _passwordController.addListener(_updateFormState);
  }

  @override
  void dispose() {
    // Clean up the controllers
    _usernameController.removeListener(_updateFormState);
    _passwordController.removeListener(_updateFormState);
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Update the form state based on input
  void _updateFormState() {
    print('Username: ${_usernameController.text}'); // Debugging
    print('Password: ${_passwordController.text}'); // Debugging

    setState(() {
      _isFormValid = _usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    });

    print('Form Valid: $_isFormValid'); // Debugging
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
            builder: (context) => HomeScreen(username: username),
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

  // Function to handle Google Sign-In
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // User canceled the sign-in

      // You can now use the googleUser object to get user details
      final email = googleUser.email;
      final displayName = googleUser.displayName;

      // For simplicity, navigate to the HomeScreen with the user's email as the username
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(username: email ?? 'Google User'),
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
  bool _isFormValid = false; // Track form validity

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

  HomeScreen({super.key, required this.username});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _userPoints = 0;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadUserPoints();
  }

  Future<void> _loadUserPoints() async {
    final points = await _dbHelper.getUserPoints(widget.username);
    setState(() {
      _userPoints = points;
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
        backgroundColor: const Color(0xFF1D1E33),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Points: $_userPoints',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
          const SpaceBackground(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
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
                const SizedBox(height: 10),
                const Text(
                  'Choose a subject to start learning:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
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
                            onPointsUpdated: _updatePoints, // Pass the callback
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
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

  const ShopScreen({super.key, required this.username, required this.onPointsUpdated});

  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _userPoints = 0;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // List of themes
  final List<ShopItem> themes = [
    ShopItem(
      itemName: 'Space Theme',
      cost: 0,
      isPurchased: true,
      isEquipped: true,
      type: ShopItemType.theme,
    ),
    ShopItem(
      itemName: 'Jungle Theme',
      cost: 100,
      isPurchased: false,
      isEquipped: false,
      type: ShopItemType.theme,
    ),
    ShopItem(
      itemName: 'Egypt Theme',
      cost: 150,
      isPurchased: false,
      isEquipped: false,
      type: ShopItemType.theme,
    ),
    ShopItem(
      itemName: 'Mountain Theme',
      cost: 200,
      isPurchased: false,
      isEquipped: false,
      type: ShopItemType.theme,
    ),
  ];

  // List of powerups
  final List<ShopItem> powerups = [
    ShopItem(
      itemName: 'Double Points',
      cost: 50,
      isPurchased: false,
      isEquipped: false,
      type: ShopItemType.powerup,
    ),
    ShopItem(
      itemName: '50/50',
      cost: 30,
      isPurchased: false,
      isEquipped: false,
      type: ShopItemType.powerup,
    ),
    ShopItem(
      itemName: 'Skip Question',
      cost: 40,
      isPurchased: false,
      isEquipped: false,
      type: ShopItemType.powerup,
    ),
    ShopItem(
      itemName: 'Double or Nothing',
      cost: 60,
      isPurchased: false,
      isEquipped: false,
      type: ShopItemType.powerup,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Two tabs: Themes and Powerups
    _loadUserPoints();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPoints() async {
    final points = await _dbHelper.getUserPoints(widget.username);
    setState(() {
      _userPoints = points;
    });
  }

  Future<void> _purchaseItem(ShopItem item) async {
    if (_userPoints < item.cost) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide previous SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough points to purchase this item.')),
      );
      return;
    }

    try {
      final newPoints = _userPoints - item.cost;

      // Update points in the database
      await _dbHelper.updateUserPoints(widget.username, newPoints);

      if (item.type == ShopItemType.powerup) {
        // Update powerup quantity
        final currentQuantity = await _dbHelper.getPowerupQuantity(widget.username, item.itemName);
        await _dbHelper.updatePowerupQuantity(widget.username, item.itemName, currentQuantity + 1);
        print('Updated ${item.itemName} quantity to ${currentQuantity + 1}'); // Debug log
      }

      // Update local state
      setState(() {
        _userPoints = newPoints;
        item.isPurchased = true;
      });

      // Notify HomeScreen about the updated points
      widget.onPointsUpdated(newPoints);

      ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide previous SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.itemName} purchased successfully!')),
      );
    } catch (e) {
      print('Error purchasing item: $e');
      ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide previous SnackBar
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
        backgroundColor: const Color(0xFF1D1E33),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Points: $_userPoints',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blueAccent,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          tabs: [
            Tab(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const Text('Themes'),
              ),
            ),
            Tab(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const Text('Powerups'),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          const SpaceBackground(),
          TabBarView(
            controller: _tabController,
            children: [
              _buildThemesTab(),
              _buildPowerupsTab(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: themes.length,
      itemBuilder: (context, index) {
        final theme = themes[index];
        return ShopItemCard(
          item: theme,
          onPurchase: () async {
            await _purchaseItem(theme);
          },
          onEquip: () {
            // Logic to equip the theme
            setState(() {
              for (var t in themes) {
                t.isEquipped = false;
              }
              theme.isEquipped = true;
            });
            ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide previous SnackBar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${theme.itemName} equipped!')),
            );
          },
        );
      },
    );
  }

  Widget _buildPowerupsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: powerups.length,
      itemBuilder: (context, index) {
        final powerup = powerups[index];
        return FutureBuilder<int>(
          key: ValueKey(powerup.itemName), // Unique key for each FutureBuilder
          future: _dbHelper.getPowerupQuantity(widget.username, powerup.itemName),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Show a loading indicator
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            final quantity = snapshot.data ?? 0; // Default to 0 if no data
            powerup.quantity = quantity; // Update the powerup quantity

            return ShopItemCard(
              item: powerup,
              onPurchase: () async {
                await _purchaseItem(powerup);
                setState(() {}); // Force the FutureBuilder to rebuild
              },
            );
          },
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

  ShopItem({
    required this.itemName,
    required this.cost,
    required this.isPurchased,
    required this.isEquipped,
    required this.type,
    this.quantity = 0, // Default to 0
  });
}


// Custom widget for shop item cards
class ShopItemCard extends StatelessWidget {
  final ShopItem item;
  final VoidCallback onPurchase;
  final VoidCallback? onEquip;

  const ShopItemCard({
    super.key,
    required this.item,
    required this.onPurchase,
    this.onEquip,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueAccent.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.blueAccent, width: 2),
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (item.type == ShopItemType.powerup)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueAccent),
                    ),
                    child: Text(
                      'x${item.quantity}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Cost: ${item.cost} points',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
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
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            if (item.type == ShopItemType.powerup || !item.isPurchased)
              ElevatedButton(
                onPressed: onPurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
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

  const QuestionSelectionScreen({super.key, required this.subject, required this.questions, required this.username});

  @override
  _QuestionSelectionScreenState createState() => _QuestionSelectionScreenState();
}

class _QuestionSelectionScreenState extends State<QuestionSelectionScreen> {
  int _numberOfQuestions = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Number of Questions', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1D1E33),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // White back arrow
          onPressed: () {
            Navigator.pop(context); // Go back to the HomeScreen
          },
        ),
      ),
      body: Stack(
        children: [
          const SpaceBackground(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Amount of Questions:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  '$_numberOfQuestions',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
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
                const SizedBox(height: 20),
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
        currentAnswerResult = 'Correct!';
        if (isDoublePointsActive) {
          pointsEarnedInRound += 20;
        } else if (isDoubleOrNothingActive) {
          pointsEarnedInRound += 20;
        } else {
          pointsEarnedInRound += 10;
        }
        correctAnswersCount++;
      } else {
        currentAnswerResult = 'Wrong! The correct answer is: ${widget.questions[currentQuestionIndex].correctAnswer}';
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
        currentAnswerResult = null;
        isDoublePointsActive = false;
        isFiftyFiftyActive = false;
        isSkipQuestionActive = false;
        isDoubleOrNothingActive = false;
      } else {
        _showFinalScore();
      }
    });
  }

  Widget _buildPowerupButton(String powerup, int quantity, Widget icon) {
    bool isActive = false;
    Color buttonColor = Colors.blueAccent;

    switch (powerup) {
      case 'Double Points':
        isActive = isDoublePointsActive;
        buttonColor = Colors.green;
        break;
      case '50/50':
        isActive = isFiftyFiftyActive;
        buttonColor = Colors.orange;
        break;
      case 'Skip Question':
        isActive = isSkipQuestionActive;
        buttonColor = Colors.red;
        break;
      case 'Double or Nothing':
        isActive = isDoubleOrNothingActive;
        buttonColor = Colors.purple;
        break;
    }

    return Opacity(
      opacity: quantity > 0 ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Tooltip(
          message: '$powerup ($quantity left)',
          child: ElevatedButton(
            onPressed: quantity > 0 && !isAnswered ? () => _usePowerup(powerup) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? buttonColor : Colors.blueAccent.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isActive ? buttonColor : Colors.blueAccent,
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(height: 4),
                Text(
                  quantity.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  void _showFinalScore() {
    _updateUserPoints().then((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1D1E33),
          title: const Text(
            'Quiz Finished!',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Your Score:',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                '$correctAnswersCount/${widget.questions.length}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              const SizedBox(height: 10),
              Text(
                'Points Earned This Round: $pointsEarnedInRound',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                'Total Points: ${totalPoints + pointsEarnedInRound}',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(username: widget.username),
                    ),
                  );
                },
                child: const Text(
                  'OK',
                  style: TextStyle(fontSize: 18, color: Colors.blueAccent),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Question currentQuestion = widget.questions[currentQuestionIndex];
    List<String> options = currentQuestion.options;

    if (isFiftyFiftyActive) {
      options = _applyFiftyFifty(options, currentQuestion.correctAnswer);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1D1E33),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Points: ${totalPoints + pointsEarnedInRound}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const SpaceBackground(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  width: MediaQuery.of(context).size.width * ((currentQuestionIndex + (isAnswered ? 1 : 0)) / widget.questions.length),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blueAccent, Colors.purpleAccent],
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Question ${currentQuestionIndex + 1}/${widget.questions.length}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 10), // Reduced padding
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Changed from center
                  children: [
                    Flexible(child: _buildPowerupButton('Double Points', doublePointsQuantity,
                        const Text('2×', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
                    Flexible(child: _buildPowerupButton('50/50', fiftyFiftyQuantity,
                        const Text('50/50', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))),
                    Flexible(child: _buildPowerupButton('Skip Question', skipQuestionQuantity,
                        const Icon(Icons.skip_next, size: 20))),
                    Flexible(child: _buildPowerupButton('Double or Nothing', doubleOrNothingQuantity,
                        const Icon(Icons.casino_outlined, size: 20))),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  currentQuestion.questionText,
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    ...options.map((option) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: GameButton(
                        text: option,
                        onPressed: isAnswered ? null : () => _checkAnswer(option),
                      ),
                    )),
                    if (isAnswered) ...[
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _nextQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          currentQuestionIndex < widget.questions.length - 1
                              ? 'Next Question'
                              : 'Finish Quiz',
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: currentAnswerResult!.startsWith('Correct')
                              ? Colors.green.withOpacity(0.8)
                              : Colors.red.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          currentAnswerResult!,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
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