import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database_helper.dart';
import 'study_set.dart';
import 'main.dart'; // Import for SpaceBackground

class CreateStudySetScreen extends StatefulWidget {
  final String username;
  final String currentTheme;
  final Function(StudySet) onStudySetCreated;

  const CreateStudySetScreen({
    super.key,
    required this.username,
    required this.currentTheme,
    required this.onStudySetCreated,
  });

  @override
  _CreateStudySetScreenState createState() => _CreateStudySetScreenState();
}

class _CreateStudySetScreenState extends State<CreateStudySetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subjectController = TextEditingController();
  final _csvController = TextEditingController();
  String _importMethod = 'manual';
  bool _isLoading = false;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    _csvController.dispose();
    super.dispose();
  }

  Future<void> _createStudySet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = await _dbHelper.getUserId(widget.username);
      if (userId == null) {
        throw Exception('User not found');
      }

      final studySetId = await _dbHelper.createStudySet(
        _nameController.text,
        _descriptionController.text,
        _subjectController.text,
        userId,
      );

      List<Question> questions = [];
      if (_importMethod == 'csv' && _csvController.text.isNotEmpty) {
        questions = _parseCsvQuestions(_csvController.text);
        for (final question in questions) {
          await _dbHelper.addQuestion({
            'study_set_id': studySetId,
            'question_text': question.questionText,
            'correct_answer': question.correctAnswer,
            'option_a': question.options.isNotEmpty ? question.options[0] : '',
            'option_b': question.options.length > 1 ? question.options[1] : '',
            'option_c': question.options.length > 2 ? question.options[2] : '',
            'option_d': question.options.length > 3 ? question.options[3] : '',
            'explanation': '',
          });
        }
      }

      final studySet = StudySet(
        id: studySetId,
        name: _nameController.text,
        description: _descriptionController.text,
        subject: _subjectController.text,
        isPremade: false,
        userId: userId,
        questions: questions,
      );

      widget.onStudySetCreated(studySet);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error creating study set: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating study set: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Question> _parseCsvQuestions(String csvText) {
    final lines = csvText.split('\n');
    final questions = <Question>[];

    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      final parts = line.split(',');
      if (parts.length < 2) continue;

      final questionText = parts[0].trim();
      final correctAnswer = parts[1].trim();
      final options = parts.length > 2
          ? parts.sublist(1).map((e) => e.trim()).toList()
          : [correctAnswer];

      questions.add(Question(
        id: 0,
        studySetId: 0,
        questionText: questionText,
        correctAnswer: correctAnswer,
        options: options,
      ));
    }

    return questions;
  }

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
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Study Set Name',
                        labelStyle: TextStyle(
                          color: widget.currentTheme == 'beach'
                              ? Colors.black
                              : Colors.white70,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: widget.currentTheme == 'beach'
                                ? Colors.orange
                                : Colors.blueAccent,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: widget.currentTheme == 'beach'
                                ? Colors.orange
                                : Colors.blueAccent,
                            width: 2,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        color: widget.currentTheme == 'beach'
                            ? Colors.black
                            : Colors.white,
                      ),
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
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(
                          color: widget.currentTheme == 'beach'
                              ? Colors.black
                              : Colors.white70,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: widget.currentTheme == 'beach'
                                ? Colors.orange
                                : Colors.blueAccent,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: widget.currentTheme == 'beach'
                                ? Colors.orange
                                : Colors.blueAccent,
                            width: 2,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        color: widget.currentTheme == 'beach'
                            ? Colors.black
                            : Colors.white,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _subjectController,
                      decoration: InputDecoration(
                        labelText: 'Subject',
                        labelStyle: TextStyle(
                          color: widget.currentTheme == 'beach'
                              ? Colors.black
                              : Colors.white70,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: widget.currentTheme == 'beach'
                                ? Colors.orange
                                : Colors.blueAccent,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: widget.currentTheme == 'beach'
                                ? Colors.orange
                                : Colors.blueAccent,
                            width: 2,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        color: widget.currentTheme == 'beach'
                            ? Colors.black
                            : Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a subject';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Import Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    RadioListTile<String>(
                      title: const Text(
                        'Manual Entry',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: 'manual',
                      groupValue: _importMethod,
                      onChanged: (value) {
                        setState(() => _importMethod = value!);
                      },
                      activeColor: widget.currentTheme == 'beach'
                          ? Colors.orange
                          : Colors.blueAccent,
                    ),
                    RadioListTile<String>(
                      title: const Text(
                        'Import from CSV',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        'Format: question,correct_answer,option1,option2,...',
                        style: TextStyle(color: Colors.white70),
                      ),
                      value: 'csv',
                      groupValue: _importMethod,
                      onChanged: (value) {
                        setState(() => _importMethod = value!);
                      },
                      activeColor: widget.currentTheme == 'beach'
                          ? Colors.orange
                          : Colors.blueAccent,
                    ),
                    if (_importMethod == 'csv') ...[
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _csvController,
                        decoration: InputDecoration(
                          labelText: 'CSV Content',
                          labelStyle: TextStyle(
                            color: widget.currentTheme == 'beach'
                                ? Colors.black
                                : Colors.white70,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: widget.currentTheme == 'beach'
                                  ? Colors.orange
                                  : Colors.blueAccent,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: widget.currentTheme == 'beach'
                                  ? Colors.orange
                                  : Colors.blueAccent,
                              width: 2,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          color: widget.currentTheme == 'beach'
                              ? Colors.black
                              : Colors.white,
                        ),
                        maxLines: 10,
                      ),
                    ],
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _createStudySet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.currentTheme == 'beach'
                            ? Colors.orange
                            : Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text(
                              'Create Study Set',
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
          ),
        ],
      ),
    );
  }
}
