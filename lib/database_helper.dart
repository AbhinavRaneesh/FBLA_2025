import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'eduquest.db');
    print('Database path: ' + path); // Debug print
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onOpen: (db) async {
        // Check if we need to create default data
        final userCount = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM users'));
        if (userCount == 0) {
          // Create a default user for testing
          await db.insert('users', {
            'username': 'test',
            'password': 'test123',
            'points': 0,
            'current_theme': 'space',
          });
        }
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        points INTEGER DEFAULT 0,
        current_theme TEXT DEFAULT 'space'
      )
    ''');

    // Study sets table
    await db.execute('''
      CREATE TABLE study_sets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        subject TEXT,
        is_premade BOOLEAN DEFAULT 0,
        user_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Questions table
    await db.execute('''
      CREATE TABLE questions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        study_set_id INTEGER,
        question_text TEXT,
        correct_answer TEXT,
        option_a TEXT,
        option_b TEXT,
        option_c TEXT,
        option_d TEXT,
        explanation TEXT,
        FOREIGN KEY (study_set_id) REFERENCES study_sets (id)
      )
    ''');

    // User progress table
    await db.execute('''
      CREATE TABLE user_progress(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        study_set_id INTEGER,
        questions_answered INTEGER DEFAULT 0,
        correct_answers INTEGER DEFAULT 0,
        last_practiced TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (study_set_id) REFERENCES study_sets (id)
      )
    ''');

    // Create some default study sets
    await _createDefaultStudySets(db);
  }

  Future<void> _createDefaultStudySets(Database db) async {
    // Math study set
    final mathSetId = await db.insert('study_sets', {
      'name': 'Basic Math',
      'description': 'Fundamental math concepts',
      'subject': 'Math',
      'is_premade': 1,
      'user_id': null,
    });

    await db.insert('questions', {
      'study_set_id': mathSetId,
      'question_text': 'What is 2 + 2?',
      'correct_answer': '4',
      'option_a': '3',
      'option_b': '4',
      'option_c': '5',
      'option_d': '6',
      'explanation': 'Basic addition',
    });

    // Science study set
    final scienceSetId = await db.insert('study_sets', {
      'name': 'Basic Science',
      'description': 'Introduction to science',
      'subject': 'Science',
      'is_premade': 1,
      'user_id': null,
    });

    await db.insert('questions', {
      'study_set_id': scienceSetId,
      'question_text': 'What is the chemical symbol for water?',
      'correct_answer': 'H2O',
      'option_a': 'H2O',
      'option_b': 'CO2',
      'option_c': 'O2',
      'option_d': 'H2',
      'explanation': 'Water is made of two hydrogen atoms and one oxygen atom',
    });
  }

  // User authentication methods
  Future<bool> authenticateUser(String username, String password) async {
    try {
      final db = await database;
      final result = await db.query(
        'users',
        where: 'username = ? AND password = ?',
        whereArgs: [username, password],
      );
      return result.isNotEmpty;
    } catch (e) {
      print('Error authenticating user: $e');
      return false;
    }
  }

  Future<bool> usernameExists(String username) async {
    try {
      final db = await database;
      final result = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );
      return result.isNotEmpty;
    } catch (e) {
      print('Error checking username: $e');
      return false;
    }
  }

  Future<bool> addUser(String username, String password) async {
    try {
      final db = await database;
      await db.insert('users', {
        'username': username,
        'password': password,
        'points': 0,
        'current_theme': 'space',
      });
      return true;
    } catch (e) {
      print('Error adding user: $e');
      return false;
    }
  }

  // Study set methods
  Future<int> createStudySet(
      String name, String description, String subject, int userId,
      {bool isPremade = false}) async {
    final db = await database;
    return await db.insert('study_sets', {
      'name': name,
      'description': description,
      'subject': subject,
      'is_premade': isPremade ? 1 : 0,
      'user_id': userId,
    });
  }

  Future<List<Map<String, dynamic>>> getUserStudySets(int userId) async {
    try {
      final db = await database;
      // Get both user's study sets and premade sets
      final userSets = await db.query(
        'study_sets',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      final premadeSets = await db.query(
        'study_sets',
        where: 'is_premade = ?',
        whereArgs: [1],
      );

      return [...userSets, ...premadeSets];
    } catch (e) {
      print('Error getting study sets: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPremadeStudySets() async {
    final db = await database;
    return await db.query(
      'study_sets',
      where: 'is_premade = ?',
      whereArgs: [1],
    );
  }

  // Question methods
  Future<int> addQuestion(Map<String, dynamic> question) async {
    final db = await database;
    return await db.insert('questions', question);
  }

  Future<List<Map<String, dynamic>>> getStudySetQuestions(
      int studySetId) async {
    final db = await database;
    return await db.query(
      'questions',
      where: 'study_set_id = ?',
      whereArgs: [studySetId],
    );
  }

  Future<void> importQuestionsFromCSV(int studySetId, String csvContent) async {
    final db = await database;
    final lines = csvContent.split('\n');

    await db.transaction((txn) async {
      for (var line in lines) {
        if (line.trim().isEmpty) continue;
        final parts = line.split(',');
        if (parts.length >= 6) {
          await txn.insert('questions', {
            'study_set_id': studySetId,
            'question_text': parts[0],
            'correct_answer': parts[1],
            'option_a': parts[2],
            'option_b': parts[3],
            'option_c': parts[4],
            'option_d': parts[5],
            'explanation': parts.length > 6 ? parts[6] : '',
          });
        }
      }
    });
  }

  // Progress tracking methods
  Future<void> updateUserProgress(int userId, int studySetId,
      int questionsAnswered, int correctAnswers) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    await db.insert(
      'user_progress',
      {
        'user_id': userId,
        'study_set_id': studySetId,
        'questions_answered': questionsAnswered,
        'correct_answers': correctAnswers,
        'last_practiced': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUserProgress(
      int userId, int studySetId) async {
    final db = await database;
    final result = await db.query(
      'user_progress',
      where: 'user_id = ? AND study_set_id = ?',
      whereArgs: [userId, studySetId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Points and theme methods
  Future<int> getUserPoints(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      columns: ['points'],
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty ? result.first['points'] as int : 0;
  }

  Future<void> updateUserPoints(String username, int points) async {
    final db = await database;
    await db.update(
      'users',
      {'points': points},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  Future<String?> getCurrentTheme(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      columns: ['current_theme'],
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty ? result.first['current_theme'] as String : null;
  }

  Future<void> updateCurrentTheme(String username, String theme) async {
    final db = await database;
    await db.update(
      'users',
      {'current_theme': theme},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  // User methods
  Future<int?> getUserId(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      columns: ['id'],
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty ? result.first['id'] as int : null;
  }

  Future<void> purchaseTheme(String username, String theme) async {
    final db = await database;
    await db.transaction((txn) async {
      // Get user points
      final List<Map<String, dynamic>> userMaps = await txn.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );

      if (userMaps.isEmpty) {
        throw Exception('User not found');
      }

      final int userPoints = userMaps.first['points'] as int;
      final int themeCost = 1000; // Cost of themes in points

      if (userPoints < themeCost) {
        throw Exception('Not enough points');
      }

      // Deduct points
      await txn.update(
        'users',
        {'points': userPoints - themeCost},
        where: 'username = ?',
        whereArgs: [username],
      );

      // Add theme to purchased themes
      await txn.insert(
        'purchased_themes',
        {
          'username': username,
          'theme': theme,
          'purchase_date': DateTime.now().toIso8601String(),
        },
      );
    });
  }
}
