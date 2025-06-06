import 'package:flutter/material.dart';

class StudySet {
  final int id;
  final String name;
  final String description;
  final String subject;
  final bool isPremade;
  final int userId;
  final List<Question> questions;

  StudySet({
    required this.id,
    required this.name,
    required this.description,
    required this.subject,
    required this.isPremade,
    required this.userId,
    this.questions = const [],
  });

  factory StudySet.fromMap(Map<String, dynamic> map) {
    return StudySet(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      subject: map['subject'] as String,
      isPremade: map['is_premade'] == 1,
      userId: map['user_id'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'subject': subject,
      'is_premade': isPremade ? 1 : 0,
      'user_id': userId,
    };
  }
}

class Question {
  final int id;
  final int studySetId;
  final String questionText;
  final String correctAnswer;
  final List<String> options;
  final String? explanation;

  Question({
    required this.id,
    required this.studySetId,
    required this.questionText,
    required this.correctAnswer,
    required this.options,
    this.explanation,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] as int,
      studySetId: map['study_set_id'] as int,
      questionText: map['question_text'] as String,
      correctAnswer: map['correct_answer'] as String,
      options: [
        map['option_a'] as String,
        map['option_b'] as String,
        map['option_c'] as String,
        map['option_d'] as String,
      ],
      explanation: map['explanation'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'study_set_id': studySetId,
      'question_text': questionText,
      'correct_answer': correctAnswer,
      'option_a': options[0],
      'option_b': options[1],
      'option_c': options[2],
      'option_d': options[3],
      'explanation': explanation,
    };
  }
}

class StudySetRepository {
  static final Map<String, List<Question>> premadeStudySets = {
    'AP Calculus AB': [
      Question(
        id: 1,
        studySetId: 1,
        questionText: 'What is the derivative of f(x) = x²?',
        correctAnswer: '2x',
        options: ['2x', 'x²', '2', 'x'],
        explanation: 'The derivative of x² is 2x using the power rule.',
      ),
      Question(
        id: 2,
        studySetId: 1,
        questionText: 'What is the integral of 2x?',
        correctAnswer: 'x² + C',
        options: ['x² + C', '2x² + C', 'x²', '2x'],
        explanation:
            'The integral of 2x is x² + C, where C is the constant of integration.',
      ),
      // Add more AP Calculus AB questions
    ],
    'AP Physics 1': [
      Question(
        id: 1,
        studySetId: 2,
        questionText: 'What is Newton\'s First Law?',
        correctAnswer:
            'An object in motion stays in motion unless acted upon by an external force',
        options: [
          'An object in motion stays in motion unless acted upon by an external force',
          'Force equals mass times acceleration',
          'For every action there is an equal and opposite reaction',
          'Energy cannot be created or destroyed',
        ],
        explanation:
            'Newton\'s First Law, also known as the Law of Inertia, states that an object will maintain its state of motion unless acted upon by an external force.',
      ),
      // Add more AP Physics 1 questions
    ],
    'IB Biology HL': [
      Question(
        id: 1,
        studySetId: 3,
        questionText:
            'What is the process by which cells convert glucose into ATP?',
        correctAnswer: 'Cellular respiration',
        options: [
          'Cellular respiration',
          'Photosynthesis',
          'Fermentation',
          'Glycolysis',
        ],
        explanation:
            'Cellular respiration is the process by which cells convert glucose and oxygen into ATP, carbon dioxide, and water.',
      ),
      // Add more IB Biology HL questions
    ],
    // Add more AP and IB subjects
  };

  static List<String> getAvailableSubjects() {
    return premadeStudySets.keys.toList();
  }

  static List<Question> getQuestionsForSubject(String subject) {
    return premadeStudySets[subject] ?? [];
  }
}
