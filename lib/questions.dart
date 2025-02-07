// questions.dart
class QuestionsRepository {
  static final List<Question> mathQuestions = [
    Question(
      questionText: 'What is 2 + 2?',
      options: ['3', '4', '5', '6'],
      correctAnswer: '4',
    ),
    Question(
      questionText: 'What is 10 x 5?',
      options: ['50', '100', '15', '25'],
      correctAnswer: '50',
    ),
    // Add more math questions here...
  ];

  static final List<Question> historyQuestions = [
    Question(
      questionText: 'Who was the first President of the United States?',
      options: ['Thomas Jefferson', 'George Washington', 'Abraham Lincoln', 'John Adams'],
      correctAnswer: 'George Washington',
    ),
    Question(
      questionText: 'In which year did World War II end?',
      options: ['1945', '1939', '1941', '1950'],
      correctAnswer: '1945',
    ),
    // Add more history questions here...
  ];

  static final List<Question> englishQuestions = [
    Question(
      questionText: 'What is the past tense of "go"?',
      options: ['Went', 'Goed', 'Gone', 'Going'],
      correctAnswer: 'Went',
    ),
    Question(
      questionText: 'Which word is a synonym for "happy"?',
      options: ['Sad', 'Joyful', 'Angry', 'Tired'],
      correctAnswer: 'Joyful',
    ),
    // Add more English questions here...
  ];

  static final List<Question> scienceQuestions = [
    Question(
      questionText: 'What is the chemical symbol for water?',
      options: ['H2O', 'CO2', 'O2', 'NaCl'],
      correctAnswer: 'H2O',
    ),
    Question(
      questionText: 'Which planet is known as the Red Planet?',
      options: ['Earth', 'Mars', 'Jupiter', 'Venus'],
      correctAnswer: 'Mars',
    ),
    // Add more science questions here...
  ];

  // Method to get questions by subject
  static List<Question> getQuestionsForSubject(String subject) {
    switch (subject) {
      case 'Math':
        return mathQuestions;
      case 'History':
        return historyQuestions;
      case 'English':
        return englishQuestions;
      case 'Science':
        return scienceQuestions;
      default:
        return [];
    }
  }
}

class Question {
  final String questionText;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.questionText,
    required this.options,
    required this.correctAnswer,
  });
}