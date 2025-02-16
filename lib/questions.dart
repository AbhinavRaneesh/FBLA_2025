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
    Question(
      questionText: 'What is 15 + 27?',
      options: ['42', '32', '52', '37'],
      correctAnswer: '42',
    ),
    Question(
      questionText: 'What is 100 ÷ 10?',
      options: ['1', '10', '100', '5'],
      correctAnswer: '10',
    ),
    Question(
      questionText: 'What is the square root of 64?',
      options: ['6', '8', '10', '12'],
      correctAnswer: '8',
    ),
    Question(
      questionText: 'What is 12 × 5?',
      options: ['50', '60', '70', '80'],
      correctAnswer: '60',
    ),
    Question(
      questionText: 'What is 3.14 commonly known as?',
      options: ['Pi', 'Euler\'s Number', 'Golden Ratio', 'Infinity'],
      correctAnswer: 'Pi',
    ),
    Question(
      questionText: 'What is 2³?',
      options: ['4', '6', '8', '10'],
      correctAnswer: '8',
    ),
    Question(
      questionText: 'What is the next number in the sequence: 2, 4, 6, 8, ___?',
      options: ['9', '10', '12', '14'],
      correctAnswer: '10',
    ),
    Question(
      questionText: 'What is 25% of 200?',
      options: ['25', '50', '75', '100'],
      correctAnswer: '50',
    ),
    Question(
      questionText: 'What is the area of a rectangle with length 10 and width 5?',
      options: ['15', '20', '50', '100'],
      correctAnswer: '50',
    ),
    Question(
      questionText: 'What is 7 × 8?',
      options: ['48', '56', '64', '72'],
      correctAnswer: '56',
    ),
    Question(
      questionText: 'What is 144 ÷ 12?',
      options: ['10', '12', '14', '16'],
      correctAnswer: '12',
    ),
    Question(
      questionText: 'What is the sum of the angles in a triangle?',
      options: ['90°', '180°', '270°', '360°'],
      correctAnswer: '180°',
    ),
    Question(
      questionText: 'What is 9 squared?',
      options: ['81', '72', '64', '90'],
      correctAnswer: '81',
    ),
    Question(
      questionText: 'What is 0.5 as a fraction?',
      options: ['1/2', '1/4', '1/3', '1/5'],
      correctAnswer: '1/2',
    ),
    Question(
      questionText: 'What is 5! (5 factorial)?',
      options: ['20', '60', '120', '240'],
      correctAnswer: '120',
    ),
    Question(
      questionText: 'What is the perimeter of a square with side length 4?',
      options: ['8', '12', '16', '20'],
      correctAnswer: '16',
    ),
    Question(
      questionText: 'What is 3/4 as a decimal?',
      options: ['0.25', '0.5', '0.75', '1.0'],
      correctAnswer: '0.75',
    ),
    Question(
      questionText: 'What is the value of π (pi) to two decimal places?',
      options: ['3.14', '3.16', '3.18', '3.20'],
      correctAnswer: '3.14',
    ),
    Question(
      questionText: 'What is 18 ÷ 3?',
      options: ['4', '5', '6', '7'],
      correctAnswer: '6',
    ),
    Question(
      questionText: 'What is the next prime number after 7?',
      options: ['9', '11', '13', '15'],
      correctAnswer: '11',
    ),
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
    Question(
      questionText: 'Who wrote the Declaration of Independence?',
      options: ['George Washington', 'Thomas Jefferson', 'Benjamin Franklin', 'John Adams'],
      correctAnswer: 'Thomas Jefferson',
    ),
    Question(
      questionText: 'In which year did the Titanic sink?',
      options: ['1912', '1905', '1920', '1931'],
      correctAnswer: '1912',
    ),
    Question(
      questionText: 'Who was the first woman to fly solo across the Atlantic?',
      options: ['Amelia Earhart', 'Bessie Coleman', 'Harriet Quimby', 'Sally Ride'],
      correctAnswer: 'Amelia Earhart',
    ),
    Question(
      questionText: 'What was the main cause of World War I?',
      options: ['Economic Depression', 'Assassination of Archduke Franz Ferdinand', 'Treaty of Versailles', 'Cold War'],
      correctAnswer: 'Assassination of Archduke Franz Ferdinand',
    ),
    Question(
      questionText: 'Who was the first President of the United States?',
      options: ['Thomas Jefferson', 'George Washington', 'Abraham Lincoln', 'John Adams'],
      correctAnswer: 'George Washington',
    ),
    Question(
      questionText: 'What was the name of the ship that brought the Pilgrims to America?',
      options: ['Mayflower', 'Santa Maria', 'Titanic', 'Endeavour'],
      correctAnswer: 'Mayflower',
    ),
    Question(
      questionText: 'Who invented the telephone?',
      options: ['Thomas Edison', 'Alexander Graham Bell', 'Nikola Tesla', 'Guglielmo Marconi'],
      correctAnswer: 'Alexander Graham Bell',
    ),
    Question(
      questionText: 'What was the main cause of the American Civil War?',
      options: ['Taxation', 'Slavery', 'Land Disputes', 'Religious Differences'],
      correctAnswer: 'Slavery',
    ),
    Question(
      questionText: 'Who was the leader of the Soviet Union during World War II?',
      options: ['Vladimir Lenin', 'Joseph Stalin', 'Mikhail Gorbachev', 'Leon Trotsky'],
      correctAnswer: 'Joseph Stalin',
    ),
    Question(
      questionText: 'What was the name of the first man on the moon?',
      options: ['Neil Armstrong', 'Buzz Aldrin', 'Yuri Gagarin', 'John Glenn'],
      correctAnswer: 'Neil Armstrong',
    ),
    Question(
      questionText: 'What was the Berlin Wall?',
      options: ['A Trade Route', 'A Military Base', 'A Symbol of Division', 'A Cultural Monument'],
      correctAnswer: 'A Symbol of Division',
    ),
    Question(
      questionText: 'Who was the first female Prime Minister of the United Kingdom?',
      options: ['Margaret Thatcher', 'Theresa May', 'Angela Merkel', 'Indira Gandhi'],
      correctAnswer: 'Margaret Thatcher',
    ),
    Question(
      questionText: 'What was the name of the ancient Egyptian queen known for her beauty?',
      options: ['Cleopatra', 'Nefertiti', 'Hatshepsut', 'Ramses'],
      correctAnswer: 'Cleopatra',
    ),
    Question(
      questionText: 'What was the main cause of the French Revolution?',
      options: ['Religious Conflict', 'Economic Inequality', 'Foreign Invasion', 'Industrial Revolution'],
      correctAnswer: 'Economic Inequality',
    ),
    Question(
      questionText: 'Who discovered America in 1492?',
      options: ['Christopher Columbus', 'Vasco da Gama', 'Ferdinand Magellan', 'Marco Polo'],
      correctAnswer: 'Christopher Columbus',
    ),
    Question(
      questionText: 'What was the name of the first human in space?',
      options: ['Neil Armstrong', 'Yuri Gagarin', 'John Glenn', 'Buzz Aldrin'],
      correctAnswer: 'Yuri Gagarin',
    ),
    Question(
      questionText: 'What was the main cause of the Cold War?',
      options: ['Economic Competition', 'Ideological Differences', 'Territorial Disputes', 'Religious Conflict'],
      correctAnswer: 'Ideological Differences',
    ),
    Question(
      questionText: 'Who was the first Emperor of Rome?',
      options: ['Julius Caesar', 'Augustus', 'Nero', 'Constantine'],
      correctAnswer: 'Augustus',
    ),
    Question(
      questionText: 'What was the name of the ancient Greek philosopher who taught Alexander the Great?',
      options: ['Socrates', 'Plato', 'Aristotle', 'Pythagoras'],
      correctAnswer: 'Aristotle',
    ),
    Question(
      questionText: 'What was the name of the first written code of laws?',
      options: ['The Ten Commandments', 'The Code of Hammurabi', 'The Magna Carta', 'The Constitution'],
      correctAnswer: 'The Code of Hammurabi',
    ),
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
    Question(
      questionText: 'What is the past tense of "run"?',
      options: ['Ran', 'Runned', 'Running', 'Runs'],
      correctAnswer: 'Ran',
    ),
    Question(
      questionText: 'What is a synonym for "happy"?',
      options: ['Sad', 'Joyful', 'Angry', 'Tired'],
      correctAnswer: 'Joyful',
    ),
    Question(
      questionText: 'What is the plural of "child"?',
      options: ['Childs', 'Children', 'Childes', 'Childies'],
      correctAnswer: 'Children',
    ),
    Question(
      questionText: 'What is the opposite of "begin"?',
      options: ['Start', 'End', 'Continue', 'Pause'],
      correctAnswer: 'End',
    ),
    Question(
      questionText: 'What is the literary term for a play on words?',
      options: ['Metaphor', 'Simile', 'Pun', 'Alliteration'],
      correctAnswer: 'Pun',
    ),
    Question(
      questionText: 'Who wrote "Romeo and Juliet"?',
      options: ['Charles Dickens', 'William Shakespeare', 'Mark Twain', 'Jane Austen'],
      correctAnswer: 'William Shakespeare',
    ),
    Question(
      questionText: 'What is the main character in a story called?',
      options: ['Antagonist', 'Protagonist', 'Narrator', 'Sidekick'],
      correctAnswer: 'Protagonist',
    ),
    Question(
      questionText: 'What is the term for a word that imitates a sound?',
      options: ['Onomatopoeia', 'Alliteration', 'Hyperbole', 'Metaphor'],
      correctAnswer: 'Onomatopoeia',
    ),
    Question(
      questionText: 'What is the comparative form of "good"?',
      options: ['Gooder', 'Better', 'Best', 'Well'],
      correctAnswer: 'Better',
    ),
    Question(
      questionText: 'What is the term for a story with a moral lesson?',
      options: ['Fable', 'Myth', 'Legend', 'Fairy Tale'],
      correctAnswer: 'Fable',
    ),
    Question(
      questionText: 'What is the past tense of "go"?',
      options: ['Went', 'Goed', 'Gone', 'Going'],
      correctAnswer: 'Went',
    ),
    Question(
      questionText: 'What is the term for a word that means the opposite of another word?',
      options: ['Synonym', 'Antonym', 'Homonym', 'Acronym'],
      correctAnswer: 'Antonym',
    ),
    Question(
      questionText: 'What is the plural of "mouse"?',
      options: ['Mouses', 'Mice', 'Mices', 'Mousees'],
      correctAnswer: 'Mice',
    ),
    Question(
      questionText: 'What is the term for a word that describes a noun?',
      options: ['Verb', 'Adjective', 'Adverb', 'Preposition'],
      correctAnswer: 'Adjective',
    ),
    Question(
      questionText: 'What is the term for a word that replaces a noun?',
      options: ['Adjective', 'Pronoun', 'Verb', 'Adverb'],
      correctAnswer: 'Pronoun',
    ),
    Question(
      questionText: 'What is the term for a comparison using "like" or "as"?',
      options: ['Metaphor', 'Simile', 'Hyperbole', 'Personification'],
      correctAnswer: 'Simile',
    ),
    Question(
      questionText: 'What is the term for a story about a person\'s life written by someone else?',
      options: ['Autobiography', 'Biography', 'Memoir', 'Diary'],
      correctAnswer: 'Biography',
    ),
    Question(
      questionText: 'What is the term for a word that sounds the same but has a different meaning?',
      options: ['Synonym', 'Antonym', 'Homophone', 'Homonym'],
      correctAnswer: 'Homophone',
    ),
    Question(
      questionText: 'What is the term for a word that describes an action?',
      options: ['Noun', 'Verb', 'Adjective', 'Adverb'],
      correctAnswer: 'Verb',
    ),
    Question(
      questionText: 'What is the term for a word that modifies a verb?',
      options: ['Adjective', 'Adverb', 'Preposition', 'Conjunction'],
      correctAnswer: 'Adverb',
    ),
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
    Question(
      questionText: 'What is the chemical symbol for water?',
      options: ['H2O', 'CO2', 'O2', 'NaCl'],
      correctAnswer: 'H2O',
    ),
    Question(
      questionText: 'What is the closest planet to the Sun?',
      options: ['Earth', 'Mars', 'Venus', 'Mercury'],
      correctAnswer: 'Mercury',
    ),
    Question(
      questionText: 'What is the process by which plants make food?',
      options: ['Respiration', 'Photosynthesis', 'Digestion', 'Fermentation'],
      correctAnswer: 'Photosynthesis',
    ),
    Question(
      questionText: 'What is the largest planet in the solar system?',
      options: ['Earth', 'Jupiter', 'Saturn', 'Neptune'],
      correctAnswer: 'Jupiter',
    ),
    Question(
      questionText: 'What is the hardest natural substance on Earth?',
      options: ['Gold', 'Diamond', 'Iron', 'Quartz'],
      correctAnswer: 'Diamond',
    ),
    Question(
      questionText: 'What is the chemical symbol for gold?',
      options: ['Au', 'Ag', 'Fe', 'Pb'],
      correctAnswer: 'Au',
    ),
    Question(
      questionText: 'What is the smallest unit of life?',
      options: ['Cell', 'Atom', 'Molecule', 'Organ'],
      correctAnswer: 'Cell',
    ),
    Question(
      questionText: 'What is the force that pulls objects toward the Earth?',
      options: ['Magnetism', 'Gravity', 'Friction', 'Inertia'],
      correctAnswer: 'Gravity',
    ),
    Question(
      questionText: 'What is the chemical symbol for oxygen?',
      options: ['O', 'O2', 'H2O', 'CO2'],
      correctAnswer: 'O2',
    ),
    Question(
      questionText: 'What is the process by which liquid turns into gas?',
      options: ['Condensation', 'Evaporation', 'Freezing', 'Melting'],
      correctAnswer: 'Evaporation',
    ),
    Question(
      questionText: 'What is the chemical symbol for carbon dioxide?',
      options: ['CO', 'CO2', 'C2O', 'O2C'],
      correctAnswer: 'CO2',
    ),
    Question(
      questionText: 'What is the study of living organisms called?',
      options: ['Physics', 'Chemistry', 'Biology', 'Geology'],
      correctAnswer: 'Biology',
    ),
    Question(
      questionText: 'What is the chemical symbol for sodium?',
      options: ['Na', 'So', 'Sd', 'Ni'],
      correctAnswer: 'Na',
    ),
    Question(
      questionText: 'What is the process by which plants lose water through their leaves?',
      options: ['Transpiration', 'Photosynthesis', 'Respiration', 'Digestion'],
      correctAnswer: 'Transpiration',
    ),
    Question(
      questionText: 'What is the chemical symbol for iron?',
      options: ['Fe', 'Ir', 'In', 'Io'],
      correctAnswer: 'Fe',
    ),
    Question(
      questionText: 'What is the study of the Earth\'s physical structure called?',
      options: ['Biology', 'Chemistry', 'Geology', 'Physics'],
      correctAnswer: 'Geology',
    ),
    Question(
      questionText: 'What is the chemical symbol for silver?',
      options: ['Si', 'Ag', 'Au', 'Sl'],
      correctAnswer: 'Ag',
    ),
    Question(
      questionText: 'What is the process by which gas turns into liquid?',
      options: ['Evaporation', 'Condensation', 'Freezing', 'Melting'],
      correctAnswer: 'Condensation',
    ),
    Question(
      questionText: 'What is the chemical symbol for lead?',
      options: ['Le', 'Ld', 'Pb', 'Pl'],
      correctAnswer: 'Pb',
    ),
    Question(
      questionText: 'What is the study of the universe called?',
      options: ['Astronomy', 'Biology', 'Geology', 'Chemistry'],
      correctAnswer: 'Astronomy',
    ),
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
