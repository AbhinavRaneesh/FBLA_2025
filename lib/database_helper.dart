import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

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
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        points INTEGER DEFAULT 0,
        current_theme TEXT DEFAULT 'space',
        created_at TEXT NOT NULL
      )
    ''');

    // Create study_sets table
    await db.execute('''
      CREATE TABLE study_sets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        username TEXT NOT NULL,
        is_premade INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (username) REFERENCES users (username)
      )
    ''');

    // Create study_set_questions table
    await db.execute('''
      CREATE TABLE study_set_questions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        study_set_id INTEGER NOT NULL,
        question_text TEXT NOT NULL,
        correct_answer TEXT NOT NULL,
        options TEXT NOT NULL,
        FOREIGN KEY (study_set_id) REFERENCES study_sets (id)
      )
    ''');

    // User's study sets (for tracking which sets a user has added)
    await db.execute('''
      CREATE TABLE user_study_sets(
        user_id INTEGER,
        study_set_id INTEGER,
        added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (user_id, study_set_id),
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (study_set_id) REFERENCES study_sets (id) ON DELETE CASCADE
      )
    ''');

    // Insert default premade study sets
    await _insertPremadeStudySets(db);
  }

  Future<void> _insertPremadeStudySets(Database db) async {
    // AP Study Sets
    final apSets = [
      {
        'name': 'AP Calculus AB',
        'description': 'Comprehensive review of AP Calculus AB concepts',
        'is_premade': 1,
      },
      {
        'name': 'AP Calculus BC',
        'description': 'Advanced calculus concepts for AP Calculus BC',
        'is_premade': 1,
      },
      {
        'name': 'AP Physics 1',
        'description': 'Algebra-based physics concepts',
        'is_premade': 1,
      },
      {
        'name': 'AP Physics 2',
        'description': 'Advanced algebra-based physics',
        'is_premade': 1,
      },
      {
        'name': 'AP Chemistry',
        'description': 'Comprehensive AP Chemistry review',
        'is_premade': 1,
      },
      {
        'name': 'AP Biology',
        'description': 'Complete AP Biology curriculum',
        'is_premade': 1,
      },
      {
        'name': 'AP Computer Science A',
        'description': 'Java programming and computer science concepts',
        'is_premade': 1,
      },
      {
        'name': 'AP Computer Science Principles',
        'description': 'Foundational computer science concepts',
        'is_premade': 1,
      },
      {
        'name': 'AP Statistics',
        'description': 'Statistical concepts and methods',
        'is_premade': 1,
      },
      {
        'name': 'AP Environmental Science',
        'description': 'Environmental systems and processes',
        'is_premade': 1,
      },
    ];

    // IB Study Sets
    final ibSets = [
      {
        'name': 'IB Mathematics: Analysis and Approaches HL',
        'description': 'Higher level mathematics concepts',
        'is_premade': 1,
      },
      {
        'name': 'IB Mathematics: Applications and Interpretation HL',
        'description': 'Applied mathematics concepts',
        'is_premade': 1,
      },
      {
        'name': 'IB Physics HL',
        'description': 'Advanced physics concepts',
        'is_premade': 1,
      },
      {
        'name': 'IB Chemistry HL',
        'description': 'Advanced chemistry concepts',
        'is_premade': 1,
      },
      {
        'name': 'IB Biology HL',
        'description': 'Advanced biology concepts',
        'is_premade': 1,
      },
      {
        'name': 'IB Computer Science HL',
        'description': 'Advanced computer science concepts',
        'is_premade': 1,
      },
    ];

    // Insert all premade sets
    for (var set in [...apSets, ...ibSets]) {
      await db.insert('study_sets', {
        'name': set['name'],
        'description': set['description'],
        'username': 'system',
        'is_premade': 1,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // User authentication methods
  Future<bool> authenticateUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
  }

  Future<bool> usernameExists(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

  Future<bool> addUser(String username, String password) async {
    final db = await database;
    try {
      await db.insert('users', {
        'username': username,
        'password': password,
        'points': 0,
        'current_theme': 'space',
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      // Log error in debug mode only
      assert(() {
        debugPrint('Error adding user: $e');
        return true;
      }());
      return false;
    }
  }

  // Study set methods
  Future<int> createStudySet(
      String name, String description, String username) async {
    final db = await database;
    return await db.insert('study_sets', {
      'name': name,
      'description': description,
      'username': username,
      'is_premade': 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> addQuestionToStudySet(
    int studySetId,
    String questionText,
    String correctAnswer,
    List<String> options,
  ) async {
    final db = await database;
    await db.insert('study_set_questions', {
      'study_set_id': studySetId,
      'question_text': questionText,
      'correct_answer': correctAnswer,
      'options': options.join('|'),
    });
  }

  Future<List<Map<String, dynamic>>> getUserStudySets(String username) async {
    final db = await database;
    return await db.query(
      'study_sets',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getStudySetQuestions(
      int studySetId) async {
    final db = await database;
    return await db.query(
      'study_set_questions',
      where: 'study_set_id = ?',
      whereArgs: [studySetId],
    );
  }

  Future<void> deleteStudySet(int studySetId) async {
    final db = await database;
    await db.delete(
      'study_set_questions',
      where: 'study_set_id = ?',
      whereArgs: [studySetId],
    );
    await db.delete(
      'study_sets',
      where: 'id = ?',
      whereArgs: [studySetId],
    );
  }

  Future<List<Map<String, dynamic>>> getPremadeStudySets() async {
    final db = await database;
    return await db.query(
      'study_sets',
      where: 'is_premade = ?',
      whereArgs: [1],
    );
  }

  Future<void> addStudySetToUser(String username, int studySetId) async {
    final db = await database;
    final userId = await getUserId(username);

    await db.insert('user_study_sets', {
      'user_id': userId,
      'study_set_id': studySetId,
    });
  }

  // Helper methods
  Future<int> getUserId(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      columns: ['id'],
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.first['id'] as int;
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
    return result.first['points'] as int;
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
    return result.first['current_theme'] as String?;
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

  Future<void> purchaseTheme(String username, String theme) async {
    final db = await database;
    await db.update(
      'users',
      {'current_theme': theme},
      where: 'username = ?',
      whereArgs: [username],
    );
  }
}
