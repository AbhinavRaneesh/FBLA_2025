import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database_helper.dart';
import 'study_set.dart';
import 'quiz_screen.dart' as quiz;
import 'create_study_set_screen.dart';
import 'main.dart';

class StudySetSelectionScreen extends StatefulWidget {
  final String username;
  final String currentTheme;

  const StudySetSelectionScreen({
    super.key,
    required this.username,
    required this.currentTheme,
  });

  @override
  _StudySetSelectionScreenState createState() =>
      _StudySetSelectionScreenState();
}

class _StudySetSelectionScreenState extends State<StudySetSelectionScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<StudySet> _studySets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudySets();
  }

  Future<void> _loadStudySets() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userId = await _dbHelper.getUserId(widget.username);
      if (userId == null) {
        throw Exception('User not found');
      }

      final studySetMaps = await _dbHelper.getUserStudySets(userId);
      final studySets =
          studySetMaps.map((map) => StudySet.fromMap(map)).toList();

      if (mounted) {
        setState(() {
          _studySets = studySets;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading study sets: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading study sets. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showGameModeDialog(StudySet studySet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Select Game Mode',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: widget.currentTheme == 'beach'
            ? Colors.orange.withOpacity(0.9)
            : const Color(0xFF1D1E33),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text(
                'Learn',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement learn mode
              },
            ),
            ListTile(
              title: const Text(
                'Practice',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _showPracticeModeDialog(studySet);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPracticeModeDialog(StudySet studySet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Select Practice Mode',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: widget.currentTheme == 'beach'
            ? Colors.orange.withOpacity(0.9)
            : const Color(0xFF1D1E33),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text(
                'Classic',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Answer all questions at your own pace',
                style: TextStyle(color: Colors.white70),
              ),
              onTap: () {
                Navigator.pop(context);
                _startQuiz(studySet, 'classic');
              },
            ),
            ListTile(
              title: const Text(
                'Timed',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Answer questions within a time limit',
                style: TextStyle(color: Colors.white70),
              ),
              onTap: () {
                Navigator.pop(context);
                _showQuestionCountDialog(studySet);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showQuestionCountDialog(StudySet studySet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Select Number of Questions',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: widget.currentTheme == 'beach'
            ? Colors.orange.withOpacity(0.9)
            : const Color(0xFF1D1E33),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text(
                '5 Questions',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _startQuiz(studySet, 'timed', questionCount: 5);
              },
            ),
            ListTile(
              title: const Text(
                '10 Questions',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _startQuiz(studySet, 'timed', questionCount: 10);
              },
            ),
            ListTile(
              title: const Text(
                'All Questions',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _startQuiz(studySet, 'timed');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _startQuiz(StudySet studySet, String gameMode, {int? questionCount}) {
    final questions = questionCount != null
        ? studySet.questions.take(questionCount).toList()
        : studySet.questions;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => quiz.QuizScreen(
          studySet: studySet,
          questions: questions,
          gameMode: gameMode,
          currentTheme: widget.currentTheme,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Study Sets',
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
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _studySets.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'No study sets available',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateStudySetScreen(
                                    username: widget.username,
                                    currentTheme: widget.currentTheme,
                                    onStudySetCreated: (studySet) {
                                      _loadStudySets();
                                    },
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.currentTheme == 'beach'
                                  ? Colors.orange
                                  : Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Create Study Set',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _studySets.length,
                      itemBuilder: (context, index) {
                        final studySet = _studySets[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          color: Colors.blueAccent.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: const BorderSide(
                              color: Colors.blueAccent,
                              width: 2,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              studySet.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  studySet.description,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Subject: ${studySet.subject}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Questions: ${studySet.questions.length}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 30,
                              ),
                              onPressed: () => _showGameModeDialog(studySet),
                            ),
                          ),
                        );
                      },
                    ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateStudySetScreen(
                username: widget.username,
                currentTheme: widget.currentTheme,
                onStudySetCreated: (studySet) {
                  _loadStudySets();
                },
              ),
            ),
          );
        },
        backgroundColor:
            widget.currentTheme == 'beach' ? Colors.orange : Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
