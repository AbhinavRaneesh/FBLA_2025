import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 2, // Increment version for schema changes
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        points INTEGER DEFAULT 0,
        level INTEGER DEFAULT 1,
        last_challenge_date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE achievements(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        achievement TEXT,
        FOREIGN KEY(username) REFERENCES users(username)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN points INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE users ADD COLUMN level INTEGER DEFAULT 1');
      await db.execute('ALTER TABLE users ADD COLUMN last_challenge_date TEXT');
      await db.execute('''
        CREATE TABLE achievements(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT,
          achievement TEXT,
          FOREIGN KEY(username) REFERENCES users(username)
        )
      ''');
    }
  }

  // Add a new user to the database
  Future<bool> addUser(String username, String password) async {
    try {
      final db = await database;
      await db.insert(
        'users',
        {
          'username': username,
          'password': password,
          'points': 0, // Initialize points to 0
          'level': 1, // Initialize level to 1
        },
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
      print('User $username added successfully.');
      return true;
    } catch (e) {
      print('Error adding user: $e');
      return false;
    }
  }

  // Authenticate a user
  Future<bool> authenticateUser(String username, String password) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> result = await db.query(
        'users',
        where: 'username = ? AND password = ?',
        whereArgs: [username, password],
      );
      return result.isNotEmpty;
    } catch (e) {
      print('Error during authentication: $e');
      return false;
    }
  }

  // Check if a username already exists
  Future<bool> checkIfUserExists(String username) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> result = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );
      return result.isNotEmpty;
    } catch (e) {
      print('Error checking if user exists: $e');
      return false;
    }
  }

  // Update user points
  Future<void> updateUserPoints(String username, int points) async {
    final db = await database;
    await db.update(
      'users',
      {'points': points},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  // Get user points
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

  // Update user level
  Future<void> updateUserLevel(String username, int level) async {
    final db = await database;
    await db.update(
      'users',
      {'level': level},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  // Get user level
  Future<int> getUserLevel(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      columns: ['level'],
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty ? result.first['level'] as int : 1;
  }

  // Add an achievement for a user
  Future<void> addAchievement(String username, String achievement) async {
    final db = await database;
    await db.insert(
      'achievements',
      {
        'username': username,
        'achievement': achievement,
      },
    );
  }

  // Get all achievements for a user
  Future<List<String>> getUserAchievements(String username) async {
    final db = await database;
    final result = await db.query(
      'achievements',
      columns: ['achievement'],
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.map((row) => row['achievement'] as String).toList();
  }

  // Get leaderboard (top 10 users by points)
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    final db = await database;
    return await db.query(
      'users',
      columns: ['username', 'points'],
      orderBy: 'points DESC',
      limit: 10,
    );
  }

  // Update the last challenge date for a user
  Future<void> updateLastChallengeDate(String username, String date) async {
    final db = await database;
    await db.update(
      'users',
      {'last_challenge_date': date},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  // Get the last challenge date for a user
  Future<String?> getLastChallengeDate(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      columns: ['last_challenge_date'],
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty ? result.first['last_challenge_date'] as String : null;
  }

  // Fetch all users (for admin purposes)
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  // Delete a user by ID
  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Print all users (for debugging)
  Future<void> printAllUsers() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> users = await db.query('users');
      print('Current Users in the Database:');
      for (var user in users) {
        print('ID: ${user['id']}, Username: ${user['username']}, Points: ${user['points']}, Level: ${user['level']}');
      }
    } catch (e) {
      print('Error while fetching users: $e');
    }
  }
}