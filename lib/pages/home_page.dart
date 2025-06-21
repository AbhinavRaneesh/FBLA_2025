import 'package:flutter/material.dart';
import 'package:student_learning_app/bloc/chat_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/chat_message_model.dart';
import '../database_helper.dart';
import 'package:student_learning_app/mcq_manager.dart';
import 'dart:math';
import 'package:lottie/lottie.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

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
  final ScrollController _scrollController = ScrollController(); // For chat only
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
  File? _userProfileImage; // Add profile image state

  List<String> subjects = [
    "Chemistry",
    "Physics",
    "Biology",
    "Mathematics",
    "History",
    "Geography",
    "Computer Science",
    "Economics",
    "Literature",
    "Art",
    "Music",
    "Psychology",
    "Sociology",
    "Philosophy",
    "Astronomy",
    "Geology",
    "Environmental Science",
    "Political Science",
    "Anthropology",
    "Linguistics",
    "Engineering",
    "Ethics",
    "Statistics",
    "Media Studies",
    "Theater",
    "Architecture",
    "Law",
    "Business Studies",
    "Education",
    "Archaeology",
    "Religious Studies",
    "Health Sciences",
    "Veterinary Science",
    "Nutrition",
    "Communication Studies",
    "Criminology",
    "Cultural Studies",
    "Agricultural Science",
    "Marine Biology",
    "Robotics"

  ];

  // Sample questions for each subject
  final Map<String, List<Map<String, dynamic>>> sampleQuestions = {
    "Chemistry": [
      {"question": "What is the chemical symbol for gold?", "options": ["Au", "Ag", "Fe", "Cu"], "answer": "Au"},
      {"question": "What is the molecular formula for water?", "options": ["H2O", "CO2", "O2", "N2"], "answer": "H2O"},
      {"question": "What is the atomic number of carbon?", "options": ["6", "12", "14", "16"], "answer": "6"},
      {"question": "What type of bond is formed between sodium and chlorine in NaCl?", "options": ["Ionic", "Covalent", "Metallic", "Hydrogen"], "answer": "Ionic"},
      {"question": "What is the pH of a neutral solution?", "options": ["0", "7", "14", "10"], "answer": "7"},
    ],
    "Physics": [
      {"question": "What is the SI unit of force?", "options": ["Newton", "Joule", "Watt", "Pascal"], "answer": "Newton"},
      {"question": "What is the speed of light in vacuum?", "options": ["3x10^8 m/s", "2x10^8 m/s", "4x10^8 m/s", "1x10^8 m/s"], "answer": "3x10^8 m/s"},
      {"question": "What is Newton's first law also known as?", "options": ["Law of Inertia", "Law of Motion", "Law of Action-Reaction", "Law of Acceleration"], "answer": "Law of Inertia"},
      {"question": "What is the unit of electrical resistance?", "options": ["Ohm", "Volt", "Ampere", "Watt"], "answer": "Ohm"},
      {"question": "What is the formula for kinetic energy?", "options": ["1/2mv²", "mgh", "Fd", "Pt"], "answer": "1/2mv²"},
    ],
    "Biology": [
      {"question": "What is the powerhouse of the cell?", "options": ["Mitochondria", "Nucleus", "Ribosome", "Golgi"], "answer": "Mitochondria"},
      {"question": "What is the process by which plants make food?", "options": ["Photosynthesis", "Respiration", "Digestion", "Excretion"], "answer": "Photosynthesis"},
      {"question": "What is the largest organ in the human body?", "options": ["Skin", "Liver", "Heart", "Brain"], "answer": "Skin"},
      {"question": "What are the building blocks of proteins?", "options": ["Amino acids", "Nucleotides", "Fatty acids", "Monosaccharides"], "answer": "Amino acids"},
      {"question": "What is the study of fossils called?", "options": ["Paleontology", "Archaeology", "Anthropology", "Geology"], "answer": "Paleontology"},
    ],
    "Mathematics": [
      {"question": "What is the value of π (pi) to two decimal places?", "options": ["3.14", "3.41", "3.12", "3.16"], "answer": "3.14"},
      {"question": "What is the square root of 144?", "options": ["12", "14", "10", "16"], "answer": "12"},
      {"question": "What is the formula for the area of a circle?", "options": ["πr²", "2πr", "πd", "2πd"], "answer": "πr²"},
      {"question": "What is the sum of angles in a triangle?", "options": ["180°", "90°", "360°", "270°"], "answer": "180°"},
      {"question": "What is 2 to the power of 8?", "options": ["256", "128", "512", "64"], "answer": "256"},
    ],
    "History": [
      {"question": "In what year did World War II end?", "options": ["1945", "1944", "1946", "1943"], "answer": "1945"},
      {"question": "Who was the first President of the United States?", "options": ["George Washington", "Thomas Jefferson", "John Adams", "Benjamin Franklin"], "answer": "George Washington"},
      {"question": "What year did Columbus discover America?", "options": ["1492", "1493", "1491", "1494"], "answer": "1492"},
      {"question": "Who was the first Emperor of Rome?", "options": ["Augustus", "Julius Caesar", "Nero", "Caligula"], "answer": "Augustus"},
      {"question": "What year did the French Revolution begin?", "options": ["1789", "1790", "1788", "1791"], "answer": "1789"},
    ],
    "Geography": [
      {"question": "What is the capital of Australia?", "options": ["Canberra", "Sydney", "Melbourne", "Brisbane"], "answer": "Canberra"},
      {"question": "What is the largest continent?", "options": ["Asia", "Africa", "North America", "Europe"], "answer": "Asia"},
      {"question": "What is the longest river in the world?", "options": ["Nile", "Amazon", "Yangtze", "Mississippi"], "answer": "Nile"},
      {"question": "What is the highest mountain in the world?", "options": ["Mount Everest", "K2", "Kangchenjunga", "Lhotse"], "answer": "Mount Everest"},
      {"question": "What is the largest ocean?", "options": ["Pacific", "Atlantic", "Indian", "Arctic"], "answer": "Pacific"},
    ],
    "Computer Science": [
      {"question": "What does CPU stand for?", "options": ["Central Processing Unit", "Computer Personal Unit", "Central Program Utility", "Computer Processing Unit"], "answer": "Central Processing Unit"},
      {"question": "What is the primary function of RAM?", "options": ["Temporary storage", "Permanent storage", "Processing", "Display"], "answer": "Temporary storage"},
      {"question": "What programming language was created by Guido van Rossum?", "options": ["Python", "Java", "C++", "JavaScript"], "answer": "Python"},
      {"question": "What does HTML stand for?", "options": ["HyperText Markup Language", "High Tech Modern Language", "Hyper Transfer Markup Language", "Home Tool Markup Language"], "answer": "HyperText Markup Language"},
      {"question": "What is the binary representation of decimal 10?", "options": ["1010", "1001", "1100", "1110"], "answer": "1010"},
    ],
    "Economics": [
      {"question": "What is the study of how societies allocate scarce resources?", "options": ["Economics", "Sociology", "Psychology", "Political Science"], "answer": "Economics"},
      {"question": "What is the law of supply and demand?", "options": ["Price increases with demand", "Price decreases with supply", "Price balances supply and demand", "Price is fixed"], "answer": "Price balances supply and demand"},
      {"question": "What is GDP?", "options": ["Gross Domestic Product", "General Domestic Price", "Gross Demand Price", "General Demand Product"], "answer": "Gross Domestic Product"},
      {"question": "What is inflation?", "options": ["Rise in general price level", "Fall in general price level", "No change in prices", "Currency devaluation"], "answer": "Rise in general price level"},
      {"question": "What is a monopoly?", "options": ["Single seller", "Single buyer", "Many sellers", "Many buyers"], "answer": "Single seller"},
    ],
    "Literature": [
      {"question": "Who wrote 'Romeo and Juliet'?", "options": ["William Shakespeare", "Charles Dickens", "Jane Austen", "Mark Twain"], "answer": "William Shakespeare"},
      {"question": "What is a sonnet?", "options": ["14-line poem", "10-line poem", "20-line poem", "12-line poem"], "answer": "14-line poem"},
      {"question": "Who wrote 'Pride and Prejudice'?", "options": ["Jane Austen", "Emily Brontë", "Charlotte Brontë", "Virginia Woolf"], "answer": "Jane Austen"},
      {"question": "What is alliteration?", "options": ["Repetition of consonant sounds", "Repetition of vowel sounds", "Rhyming words", "Metaphor"], "answer": "Repetition of consonant sounds"},
      {"question": "Who wrote 'The Great Gatsby'?", "options": ["F. Scott Fitzgerald", "Ernest Hemingway", "John Steinbeck", "William Faulkner"], "answer": "F. Scott Fitzgerald"},
    ],
    "Art": [
      {"question": "Who painted the Mona Lisa?", "options": ["Leonardo da Vinci", "Michelangelo", "Raphael", "Donatello"], "answer": "Leonardo da Vinci"},
      {"question": "What is the primary color that is not a primary color?", "options": ["Green", "Red", "Blue", "Yellow"], "answer": "Green"},
      {"question": "What is chiaroscuro?", "options": ["Light and shadow contrast", "Color mixing", "Perspective", "Texture"], "answer": "Light and shadow contrast"},
      {"question": "Who painted 'The Starry Night'?", "options": ["Vincent van Gogh", "Pablo Picasso", "Claude Monet", "Salvador Dalí"], "answer": "Vincent van Gogh"},
      {"question": "What is a fresco?", "options": ["Wall painting on wet plaster", "Oil painting", "Watercolor", "Sculpture"], "answer": "Wall painting on wet plaster"},
    ],
    "Music": [
      {"question": "How many notes are in an octave?", "options": ["8", "7", "12", "10"], "answer": "8"},
      {"question": "What is the time signature 4/4 also known as?", "options": ["Common time", "Waltz time", "March time", "Cut time"], "answer": "Common time"},
      {"question": "Who composed 'Symphony No. 9'?", "options": ["Ludwig van Beethoven", "Wolfgang Mozart", "Johann Bach", "Franz Schubert"], "answer": "Ludwig van Beethoven"},
      {"question": "What is a chord?", "options": ["Three or more notes played together", "Two notes played together", "Single note", "Rhythm pattern"], "answer": "Three or more notes played together"},
      {"question": "What is the Italian term for 'loud'?", "options": ["Forte", "Piano", "Allegro", "Adagio"], "answer": "Forte"},
    ],
    "Psychology": [
      {"question": "Who is considered the father of psychoanalysis?", "options": ["Sigmund Freud", "Carl Jung", "B.F. Skinner", "Ivan Pavlov"], "answer": "Sigmund Freud"},
      {"question": "What is classical conditioning?", "options": ["Learning through association", "Learning through consequences", "Learning through observation", "Learning through insight"], "answer": "Learning through association"},
      {"question": "What is the study of behavior and mental processes?", "options": ["Psychology", "Sociology", "Anthropology", "Philosophy"], "answer": "Psychology"},
      {"question": "What is the id?", "options": ["Unconscious desires", "Conscious mind", "Moral conscience", "Reality principle"], "answer": "Unconscious desires"},
      {"question": "What is cognitive dissonance?", "options": ["Mental discomfort from conflicting beliefs", "Memory loss", "Anxiety disorder", "Depression"], "answer": "Mental discomfort from conflicting beliefs"},
    ],
    "Sociology": [
      {"question": "What is the study of human society and social behavior?", "options": ["Sociology", "Psychology", "Anthropology", "Economics"], "answer": "Sociology"},
      {"question": "What is a social norm?", "options": ["Expected behavior in society", "Law", "Religion", "Custom"], "answer": "Expected behavior in society"},
      {"question": "What is social stratification?", "options": ["Division of society into classes", "Social mobility", "Social change", "Social interaction"], "answer": "Division of society into classes"},
      {"question": "What is a primary group?", "options": ["Small, intimate group", "Large organization", "Formal group", "Temporary group"], "answer": "Small, intimate group"},
      {"question": "What is deviance?", "options": ["Behavior that violates social norms", "Criminal behavior", "Social change", "Social control"], "answer": "Behavior that violates social norms"},
    ],
    "Philosophy": [
      {"question": "Who said 'I think, therefore I am'?", "options": ["René Descartes", "Socrates", "Plato", "Aristotle"], "answer": "René Descartes"},
      {"question": "What is epistemology?", "options": ["Study of knowledge", "Study of ethics", "Study of reality", "Study of beauty"], "answer": "Study of knowledge"},
      {"question": "What is the Socratic method?", "options": ["Questioning to stimulate critical thinking", "Lecture method", "Debate method", "Research method"], "answer": "Questioning to stimulate critical thinking"},
      {"question": "What is utilitarianism?", "options": ["Greatest good for greatest number", "Individual rights", "Duty-based ethics", "Virtue ethics"], "answer": "Greatest good for greatest number"},
      {"question": "Who wrote 'The Republic'?", "options": ["Plato", "Aristotle", "Socrates", "Descartes"], "answer": "Plato"},
    ],
    "Astronomy": [
      {"question": "What is the closest planet to the Sun?", "options": ["Mercury", "Venus", "Earth", "Mars"], "answer": "Mercury"},
      {"question": "What is a light year?", "options": ["Distance light travels in one year", "Time light takes to reach Earth", "Speed of light", "Light intensity"], "answer": "Distance light travels in one year"},
      {"question": "What is the largest planet in our solar system?", "options": ["Jupiter", "Saturn", "Neptune", "Uranus"], "answer": "Jupiter"},
      {"question": "What is a black hole?", "options": ["Region where gravity is so strong nothing can escape", "Dark star", "Empty space", "Dead star"], "answer": "Region where gravity is so strong nothing can escape"},
      {"question": "What is the name of our galaxy?", "options": ["Milky Way", "Andromeda", "Triangulum", "Large Magellanic Cloud"], "answer": "Milky Way"},
    ],
    "Geology": [
      {"question": "What is the hardest mineral on Earth?", "options": ["Diamond", "Quartz", "Topaz", "Corundum"], "answer": "Diamond"},
      {"question": "What type of rock is formed by heat and pressure?", "options": ["Metamorphic", "Igneous", "Sedimentary", "Volcanic"], "answer": "Metamorphic"},
      {"question": "What is the center of the Earth called?", "options": ["Core", "Mantle", "Crust", "Lithosphere"], "answer": "Core"},
      {"question": "What is the study of fossils called?", "options": ["Paleontology", "Archaeology", "Anthropology", "Biology"], "answer": "Paleontology"},
      {"question": "What is the most abundant element in Earth's crust?", "options": ["Oxygen", "Silicon", "Aluminum", "Iron"], "answer": "Oxygen"},
    ],
    "Environmental Science": [
      {"question": "What is the main cause of global warming?", "options": ["Greenhouse gases", "Solar radiation", "Volcanic activity", "Ocean currents"], "answer": "Greenhouse gases"},
      {"question": "What is biodiversity?", "options": ["Variety of life on Earth", "Number of species", "Ecosystem health", "Environmental quality"], "answer": "Variety of life on Earth"},
      {"question": "What is the ozone layer?", "options": ["Protective layer in atmosphere", "Pollution layer", "Cloud layer", "Wind layer"], "answer": "Protective layer in atmosphere"},
      {"question": "What is renewable energy?", "options": ["Energy from natural sources", "Fossil fuel energy", "Nuclear energy", "Coal energy"], "answer": "Energy from natural sources"},
      {"question": "What is deforestation?", "options": ["Clearing of forests", "Planting trees", "Forest management", "Wildlife protection"], "answer": "Clearing of forests"},
    ],
    "Political Science": [
      {"question": "What is democracy?", "options": ["Government by the people", "Government by one person", "Government by military", "Government by religion"], "answer": "Government by the people"},
      {"question": "What are the three branches of US government?", "options": ["Executive, Legislative, Judicial", "President, Congress, Senate", "Federal, State, Local", "Democrat, Republican, Independent"], "answer": "Executive, Legislative, Judicial"},
      {"question": "What is the Bill of Rights?", "options": ["First 10 amendments to Constitution", "Declaration of Independence", "Articles of Confederation", "Federalist Papers"], "answer": "First 10 amendments to Constitution"},
      {"question": "What is federalism?", "options": ["Division of power between levels of government", "Centralized government", "State government only", "Local government only"], "answer": "Division of power between levels of government"},
      {"question": "What is the electoral college?", "options": ["System for electing president", "Congressional voting", "State legislature", "Popular vote"], "answer": "System for electing president"},
    ],
  };

  @override
  void initState() {
    super.initState();
    _chatBloc = ChatBloc(); // Initialize bloc once
    _loadUsername(); // Load username when page initializes
    _loadUserProfileImage(); // Load profile image on init
  }

  Future<void> _loadUsername() async {
    // Get the username from shared preferences or wherever it's stored
    // For now, we'll use a default value
    setState(() {
      username = widget.username; // Replace with actual username loading logic
    });
  }

  void _loadUserProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_${widget.username}');
    if (path != null && path.isNotEmpty) {
      setState(() {
        _userProfileImage = File(path);
      });
    }
  }

  void _refreshUserProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_${widget.username}');
    setState(() {
      _userProfileImage = path != null && path.isNotEmpty ? File(path) : null;
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
    // Refresh profile image before showing chat
    _refreshUserProfileImage();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey.shade900.withOpacity(0.95),
                  Colors.grey.shade800.withOpacity(0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF667eea),
                        const Color(0xFF764ba2),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.psychology,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Learning Assistant',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Ask me anything about your studies!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                
                // Chat Messages
                Expanded(
                  child: BlocBuilder<ChatBloc, ChatState>(
                    bloc: _chatBloc,
                    builder: (context, state) {
                      if (state is ChatSuccessState) {
                        // Auto-scroll to bottom when new messages arrive
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_scrollController.hasClients) {
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          }
                        });

                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            final message = state.messages[index];
                            final isUser = message.role == "user";
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                mainAxisAlignment: isUser
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!isUser) ...[
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF667eea).withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.psychology,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  
                                  Flexible(
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isUser
                                              ? [
                                                  const Color(0xFF4facfe),
                                                  const Color(0xFF00f2fe),
                                                ]
                                              : [
                                                  Colors.white.withOpacity(0.1),
                                                  Colors.white.withOpacity(0.05),
                                                ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isUser
                                              ? const Color(0xFF4facfe).withOpacity(0.3)
                                              : Colors.white.withOpacity(0.1),
                                          width: 1,
                                        ),
                                        boxShadow: isUser
                                            ? [
                                                BoxShadow(
                                                  color: const Color(0xFF4facfe).withOpacity(0.2),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Text(
                                        message.parts.isNotEmpty
                                            ? message.parts.first.text
                                            : 'No message content',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  if (isUser) ...[
                                    const SizedBox(width: 8),
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.transparent,
                                      backgroundImage: _userProfileImage != null ? FileImage(_userProfileImage!) : null,
                                      child: _userProfileImage == null
                                          ? Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xFF4facfe).withOpacity(0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                widget.username.isNotEmpty 
                                                    ? widget.username.substring(0, 1).toUpperCase()
                                                    : 'U',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        );
                      } else if (state is ChatErrorState) {
                        return Center(
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
                                'Error: ${state.message}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Lottie.asset(
                                'assets/animation/Animation - 1750352180300.json',
                                width: 120,
                                height: 120,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'AI Assistant Ready!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ask me anything about your studies',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
                
                // Input Area
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: followupController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Ask a follow-up question...',
                              hintStyle: TextStyle(color: Colors.white60),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667eea).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: () {
                            if (followupController.text.trim().isNotEmpty) {
                              _chatBloc.add(ChatGenerationNewTextMessageEvent(
                                inputMessage: followupController.text.trim(),
                              ));
                              followupController.clear();

                              // Auto-scroll to bottom when user sends a message
                              Future.delayed(const Duration(milliseconds: 100), () {
                                if (_scrollController.hasClients) {
                                  _scrollController.animateTo(
                                    _scrollController.position.maxScrollExtent,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                }
                              });
                            }
                          },
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
          print(
              'Successfully added question ${newQuestions.length}: ${parsedQuestion['question']}');
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
            print(
                'Alternative parsing added question: ${parsedQuestion['question']}');
          }
        }

        // If still not enough, try splitting by single newlines
        if (newQuestions.length < numberOfQuestions) {
          for (String line in lines) {
            Map<String, dynamic>? parsedQuestion =
                _parseBracketFormat(line.trim());
            if (parsedQuestion != null) {
              newQuestions.add(parsedQuestion);
              print(
                  'Single line parsing added question: ${parsedQuestion['question']}');
            }
          }
        }
      }

      // If we still have fewer questions than requested, add sample questions
      if (newQuestions.length < numberOfQuestions) {
        print('Still have fewer questions than requested, adding sample questions');
        int questionsNeeded = numberOfQuestions - newQuestions.length;
        
        // Get sample questions for the selected subject
        List<Map<String, dynamic>> subjectSamples = sampleQuestions[selectedSubject] ?? [];
        
        if (subjectSamples.isNotEmpty) {
          // Shuffle the sample questions to randomize them
          List<Map<String, dynamic>> shuffledSamples = List.from(subjectSamples);
          shuffledSamples.shuffle();
          
          // Add the needed number of sample questions
          for (int i = 0; i < questionsNeeded && i < shuffledSamples.length; i++) {
            newQuestions.add(shuffledSamples[i]);
            print('Added sample question: ${shuffledSamples[i]['question']}');
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
        print(
            'Before setState - showQuizArea: $showQuizArea, scienceQuestions.length: ${scienceQuestions.length}');
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

        print(
            'After setState - showQuizArea: $showQuizArea, scienceQuestions.length: ${scienceQuestions.length}');
        print(
            'First question: ${scienceQuestions.isNotEmpty ? scienceQuestions[0]['question'] : 'No questions'}');

        // Clear chat history after successful question generation
        _clearChatHistory();

        // Show success message in console instead of UI
        print(
            'Successfully loaded ${newQuestions.length} new $selectedSubject questions!');
      } else {
        // If parsing failed completely, use sample questions
        print('No questions were parsed successfully, using sample questions');
        List<Map<String, dynamic>> subjectSamples = sampleQuestions[selectedSubject] ?? [];
        
        if (subjectSamples.isNotEmpty) {
          // Shuffle and take the requested number
          List<Map<String, dynamic>> shuffledSamples = List.from(subjectSamples);
          shuffledSamples.shuffle();
          
          int questionsToUse = numberOfQuestions < shuffledSamples.length 
              ? numberOfQuestions 
              : shuffledSamples.length;
          
          List<Map<String, dynamic>> finalQuestions = shuffledSamples.sublist(0, questionsToUse);
          
          setState(() {
            scienceQuestions = finalQuestions;
            answeredCorrectly = List.filled(finalQuestions.length, false);
            currentQuestionIndex = 0;
            showAnswer = false;
            selectedAnswer = null;
            isWaitingForQuestions = false;
            showQuizArea = true;
            showScoreSummary = false;
          });
          
          print('Using ${finalQuestions.length} sample questions for $selectedSubject');
        } else {
          setState(() {
            isWaitingForQuestions = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to parse questions and no sample questions available. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
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
Do not include any explanations or additional text, just the questions in this exact format and randomize the correct answer.
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
    setState(() {
      showQuizArea = false;
      showScoreSummary = false;
      currentQuestionIndex = 0;
      selectedAnswer = null;
      showAnswer = false;
      answeredCorrectly = []; // Create a new empty list instead of clearing
      scienceQuestions.clear();
    });
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
    print(
        'HomePage build method called - showQuizArea: $showQuizArea, scienceQuestions.length: ${scienceQuestions.length}');
    return BlocProvider.value(
      value: _chatBloc,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const SpaceBackground(),
            SafeArea(
              child: BlocListener<ChatBloc, ChatState>(
                listener: (context, state) {
                  print(
                      'BlocListener triggered with state: ${state.runtimeType}');
                  print('isWaitingForQuestions: $isWaitingForQuestions');
                  if (state is ChatSuccessState) {
                    print(
                        'ChatSuccessState received with ${state.messages.length} messages');
                    if (isWaitingForQuestions && state.messages.isNotEmpty) {
                      try {
                        var lastMessage = state.messages.last;
                        print('Last message role: ${lastMessage.role}');
                        print(
                            'Last message parts length: ${lastMessage.parts.length}');
                        if (lastMessage.role != "user" &&
                            lastMessage.parts.isNotEmpty) {
                          print('Parsing AI response...');
                          _parseAndReplaceQuestions(
                              lastMessage.parts.first.text);
                        } else {
                          print(
                              'Skipping parsing - role: ${lastMessage.role}, parts empty: ${lastMessage.parts.isEmpty}');
                        }
                      } catch (e) {
                        print('Error in BlocListener: $e');
                        setState(() {
                          isWaitingForQuestions = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error processing AI response: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } else if (state is ChatErrorState) {
                    print('ChatErrorState received: ${state.message}');
                    setState(() {
                      isWaitingForQuestions = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${state.message}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    print(
                        'BlocBuilder rebuilding. showQuizArea: $showQuizArea, scienceQuestions.length: ${scienceQuestions.length}, showScoreSummary: $showScoreSummary');

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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose Your Subject',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: HorizontalSubjectWheel(
                subjects: subjects,
                selectedSubject: selectedSubject,
                onSubjectSelected: (subject) {
                  setState(() {
                    selectedSubject = subject;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Number of Questions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    if (numberOfQuestions > 5) {
                      setState(() {
                        numberOfQuestions -= 5;
                      });
                    }
                  },
                  icon: const Icon(Icons.remove_circle, color: Colors.white),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$numberOfQuestions',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (numberOfQuestions < 200) {
                      setState(() {
                        numberOfQuestions += 5;
                      });
                    }
                  },
                  icon: const Icon(Icons.add_circle, color: Colors.white),
                ),
              ],
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4facfe).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: isWaitingForQuestions
                    ? null
                    : () {
                        _generateQuestions();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
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
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Generating Questions...',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Start Learning',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizArea() {
    print(
        '_buildQuizArea called with ${scienceQuestions.length} questions, current index: $currentQuestionIndex');
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
              final isCorrect =
                  showAnswer && option == currentQuestion["answer"];
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
                            color: isCorrect
                                ? Colors.green
                                : isWrong
                                    ? Colors.red
                                    : null,
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
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
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
              child: ElevatedButton(
                onPressed: _submitAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Submit Answer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
        else if (showAnswer)
          Column(
            children: [
              // Ask AI for Help Button
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667eea).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      String question = currentQuestion["question"]!;
                      String options = currentQuestion["options"].join('\n• ');
                      String prompt =
                          "Please explain how to solve this question: '$question'\n\nOptions:\n• $options\n\nProvide a detailed step-by-step explanation with the fundamental concepts involved and explain why the correct answer is the best choice.";
                      _showChatModal(initialMessage: prompt);
                    },
                    icon: const Icon(Icons.psychology, color: Colors.white),
                    label: const Text(
                      "Ask AI for Help",
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
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Next Question Button
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: currentQuestionIndex + 1 == scienceQuestions.length
                        ? [Color(0xFF56ab2f), Color(0xFFa8e6cf)]
                        : [Color(0xFF4facfe), Color(0xFF00f2fe)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (currentQuestionIndex + 1 == scienceQuestions.length
                                  ? const Color(0xFF56ab2f)
                                  : const Color(0xFF4facfe))
                              .withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: goToNextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    currentQuestionIndex + 1 == scienceQuestions.length
                        ? 'Finish Quiz'
                        : 'Next Question',
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
      ],
    );
  }

  Widget _buildScoreSummary() {
    int correctAnswers = answeredCorrectly.where((correct) => correct).length;
    double accuracy = (correctAnswers / scienceQuestions.length) * 100;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 25),
            // Trophy Icon with Animation
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),

            // Quiz Completed Text
            const Text(
              "Quiz Completed!",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 40),

            // Score Card
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667eea).withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Your Score",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "$correctAnswers / ${scienceQuestions.length}",
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Accuracy: ${accuracy.toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: accuracy > 70
                            ? const Color(0xFF4CAF50)
                            : accuracy > 40
                                ? const Color(0xFFFF9800)
                                : const Color(0xFFF44336),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4facfe).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _restartQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22.5),
                        ),
                      ),
                      child: const Text(
                        "Retry Quiz",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF667eea).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _returnToHome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22.5),
                        ),
                      ),
                      child: const Text(
                        "Return Home",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
                    message.parts.isNotEmpty
                        ? message.parts.first.text
                        : 'No message content',
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

class HorizontalSubjectWheel extends StatefulWidget {
  final List<String> subjects;
  final String selectedSubject;
  final Function(String) onSubjectSelected;

  const HorizontalSubjectWheel({
    Key? key,
    required this.subjects,
    required this.selectedSubject,
    required this.onSubjectSelected,
  }) : super(key: key);

  @override
  _HorizontalSubjectWheelState createState() => _HorizontalSubjectWheelState();
}

class _HorizontalSubjectWheelState extends State<HorizontalSubjectWheel>
    with TickerProviderStateMixin {
  late FixedExtentScrollController _scrollController;
  late AnimationController _animationController;
  int _selectedIndex = 0;

  final List<Color> _gradients = [
    const Color(0xFF667eea),
    const Color(0xFFf093fb),
    const Color(0xFF4facfe),
    const Color(0xFF43e97b),
    const Color(0xFFfa709a),
    const Color(0xFFa8edea),
    const Color(0xFFffecd2),
    const Color(0xFFff9a9e),
    const Color(0xFF667eea),
    const Color(0xFFf093fb),
    const Color(0xFF4facfe),
    const Color(0xFF43e97b),
    const Color(0xFFfa709a),
    const Color(0xFFa8edea),
    const Color(0xFFffecd2),
    const Color(0xFFff9a9e),
    const Color(0xFF667eea),
  ];

  final List<IconData> _icons = [
    Icons.science,
    Icons.rocket_launch,
    Icons.biotech,
    Icons.calculate,
    Icons.history_edu,
    Icons.public,
    Icons.computer,
    Icons.trending_up,
    Icons.book,
    Icons.palette,
    Icons.music_note,
    Icons.psychology,
    Icons.people,
    Icons.lightbulb,
    Icons.visibility,
    Icons.landscape,
    Icons.eco,
    Icons.gavel,
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _selectedIndex = widget.subjects.indexOf(widget.selectedSubject);
    if (_selectedIndex == -1) _selectedIndex = 0;
    
    // Set initial position after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpToItem(_selectedIndex);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSelectedItemChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onSubjectSelected(widget.subjects[index]);
    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Selection indicator with glow - smaller size to match items
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 25),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: _gradients[_selectedIndex % _gradients.length].withOpacity(0.8 + (_animationController.value * 0.2)),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _gradients[_selectedIndex % _gradients.length].withOpacity(0.4 + (_animationController.value * 0.3)),
                      blurRadius: 15 + (_animationController.value * 8),
                      spreadRadius: 1 + (_animationController.value * 2),
                    ),
                  ],
                ),
              );
            },
          ),
          // Subject wheel
          Container(
            height: 180,
            child: ListWheelScrollView.useDelegate(
              controller: _scrollController,
              itemExtent: 60,
              diameterRatio: 1.8,
              perspective: 0.01,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: _onSelectedItemChanged,
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  if (index >= widget.subjects.length) return Container();
                  
                  final subject = widget.subjects[index];
                  final isSelected = index == _selectedIndex;
                  
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: isSelected
                            ? [_gradients[index % _gradients.length], _gradients[index % _gradients.length].withOpacity(0.7)]
                            : [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.05)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: _gradients[index % _gradients.length].withOpacity(0.5),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                                spreadRadius: 1,
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected 
                                ? Colors.white.withOpacity(0.2)
                                : Colors.transparent,
                          ),
                          child: Icon(
                            _icons[index % _icons.length],
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                            size: isSelected ? 30 : 26,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            subject,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                              fontSize: isSelected ? 20 : 17,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelected)
                          Container(
                            margin: const EdgeInsets.only(right: 15),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  );
                },
                childCount: widget.subjects.length,
              ),
            ),
          ),
          // Center line indicators
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              color: _gradients[_selectedIndex % _gradients.length].withOpacity(0.6),
            ),
          ),
          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              color: _gradients[_selectedIndex % _gradients.length].withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}