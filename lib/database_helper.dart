import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'eduquest.db');

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
        username TEXT UNIQUE,
        password TEXT,
        points INTEGER DEFAULT 0,
        current_theme TEXT DEFAULT 'space'
      )
    ''');

    // Create powerups table
    await db.execute('''
      CREATE TABLE powerups(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        powerup_name TEXT,
        quantity INTEGER DEFAULT 0,
        FOREIGN KEY(username) REFERENCES users(username)
      )
    ''');

    // Create themes table
    await db.execute('''
      CREATE TABLE themes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        theme_name TEXT,
        is_purchased INTEGER DEFAULT 0,
        FOREIGN KEY(username) REFERENCES users(username)
      )
    ''');
  }

  // Add a new user
  Future<bool> addUser(String username, String password) async {
    final db = await database;
    try {
      await db.insert(
        'users',
        {
          'username': username,
          'password': password,
          'current_theme': 'space', // Default theme
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      print('Error adding user: $e');
      return false;
    }
  }

  // Authenticate a user
  Future<bool> authenticateUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
  }

  // Check if a username already exists
  Future<bool> usernameExists(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

  // Get user points
  Future<int> getUserPoints(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty ? result.first['points'] as int : 0;
  }

  // Update user points
  Future<void> updateUserPoints(String username, int newPoints) async {
    final db = await database;
    await db.update(
      'users',
      {'points': newPoints},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  // Get powerup quantity for a user
  Future<int> getPowerupQuantity(String username, String powerupName) async {
    final db = await database;
    final result = await db.query(
      'powerups',
      where: 'username = ? AND powerup_name = ?',
      whereArgs: [username, powerupName],
    );
    return result.isNotEmpty ? result.first['quantity'] as int : 0;
  }

  // Update powerup quantity for a user
  Future<void> updatePowerupQuantity(String username, String powerupName, int newQuantity) async {
    final db = await database;
    await db.insert(
      'powerups',
      {
        'username': username,
        'powerup_name': powerupName,
        'quantity': newQuantity,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Purchase a theme
  Future<void> purchaseTheme(String username, String themeName) async {
    final db = await database;
    await db.insert(
      'themes',
      {
        'username': username,
        'theme_name': themeName,
        'is_purchased': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> equipTheme(String username, String themeName) async {
    final db = await database;
    await db.update(
      'users',
      {'current_theme': themeName},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  Future<bool> isThemePurchased(String username, String themeName) async {
    final db = await database;
    final result = await db.query(
      'themes',
      where: 'username = ? AND theme_name = ?',
      whereArgs: [username, themeName],
    );
    return result.isNotEmpty && result.first['is_purchased'] == 1;
  }

  Future<String?> getCurrentTheme(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty ? result.first['current_theme'] as String? : 'space';
  }
}