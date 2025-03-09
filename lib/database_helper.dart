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
    String path = join(await getDatabasesPath(), 'student_learning_app.db');
    return await openDatabase(
      path,
      version: 3, // Increment the version number
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Add this method
    );
  }


  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
   CREATE TABLE users(
     id INTEGER PRIMARY KEY AUTOINCREMENT,
     username TEXT UNIQUE,
     password TEXT,
     points INTEGER DEFAULT 0
   )
 ''');


    await db.execute('''
   CREATE TABLE user_themes(
     id INTEGER PRIMARY KEY AUTOINCREMENT,
     username TEXT,
     theme TEXT,
     active INTEGER DEFAULT 0
   )
 ''');


    // Insert default space theme for all users
    await db.execute('''
   INSERT INTO user_themes (username, theme, active)
   SELECT username, 'Space Theme', 1 FROM users
 ''');


    await db.execute('''
   CREATE TABLE user_powerups(
     id INTEGER PRIMARY KEY AUTOINCREMENT,
     username TEXT,
     itemName TEXT,
     quantity INTEGER DEFAULT 0
   )
 ''');
  }


  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Create the user_powerups table if it doesn't exist
      await db.execute('''
       CREATE TABLE IF NOT EXISTS user_powerups(
         id INTEGER PRIMARY KEY AUTOINCREMENT,
         username TEXT,
         itemName TEXT,
         quantity INTEGER DEFAULT 0
       )
     ''');
    }
  }


  // Add a new user
  Future<bool> addUser(String username, String password) async {
    try {
      final db = await database;
      await db.insert(
        'users',
        {
          'username': username,
          'password': password,
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


  // Check if a username already exists
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


  // Get user points
  Future<int> getUserPoints(String username) async {
    try {
      final db = await database;
      final result = await db.query(
        'users',
        columns: ['points'],
        where: 'username = ?',
        whereArgs: [username],
      );
      return result.isNotEmpty ? result.first['points'] as int : 0;
    } catch (e) {
      print('Error fetching user points: $e');
      return 0;
    }
  }


  // Update user points and print the updated points to the terminal
  Future<void> updateUserPoints(String username, int newPoints) async {
    final db = await database;
    await db.update(
      'users',
      {'points': newPoints},
      where: 'username = ?',
      whereArgs: [username],
    );
  }


  Future<void> purchaseTheme(String username, String themeName) async {
    final db = await database;
    await db.insert(
      'purchased_themes',
      {
        'username': username,
        'theme_name': themeName,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  // Get purchased themes for a user
  Future<List<String>> getPurchasedThemes(String username) async {
    try {
      final db = await database;
      final result = await db.query(
        'user_themes',
        where: 'username = ?',
        whereArgs: [username],
      );
      return result.map((row) => row['theme'] as String).toList();
    } catch (e) {
      print('Error fetching purchased themes: $e');
      return [];
    }
  }


  // Check if a theme is already purchased
  Future<bool> isThemePurchased(String username, String themeName) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'purchased_themes',
      where: 'username = ? AND theme_name = ?',
      whereArgs: [username, themeName],
    );
    return result.isNotEmpty;
  }


  // Print all users (for debugging)
  Future<void> printAllUsers() async {
    try {
      final db = await database;
      final users = await db.query('users');
      print('Current Users in the Database:');
      for (var user in users) {
        print('ID: ${user['id']}, Username: ${user['username']}, Points: ${user['points']}');
      }
    } catch (e) {
      print('Error while fetching users: $e');
    }
  }


  Future<int> getPowerupQuantity(String username, String itemName) async {
    final db = await database;
    final result = await db.query(
      'user_powerups',
      columns: ['quantity'],
      where: 'username = ? AND itemName = ?',
      whereArgs: [username, itemName],
    );
    return result.isNotEmpty ? result.first['quantity'] as int? ?? 0 : 0;
  }


  Future<void> updatePowerupQuantity(String username, String itemName, int quantity) async {
    final db = await database;
    // First check if the powerup exists for the user
    final result = await db.query(
      'user_powerups',
      where: 'username = ? AND itemName = ?',
      whereArgs: [username, itemName],
    );


    if (result.isEmpty) {
      // If the powerup doesn't exist, insert a new record
      await db.insert(
        'user_powerups',
        {
          'username': username,
          'itemName': itemName,
          'quantity': quantity,
        },
      );
    } else {
      // If it exists, update the quantity
      await db.update(
        'user_powerups',
        {'quantity': quantity},
        where: 'username = ? AND itemName = ?',
        whereArgs: [username, itemName],
      );
    }
  }


  Future<String> getActiveTheme(String username) async {
    try {
      final db = await database;
      final result = await db.query(
        'user_themes',
        where: 'username = ? AND active = 1',
        whereArgs: [username],
      );
      return result.isNotEmpty ? result.first['theme'] as String : 'Space Theme';
    } catch (e) {
      print('Error fetching active theme: $e');
      return 'Space Theme';
    }
  }


  Future<void> updateActiveTheme(String username, String themeName) async {
    final db = await database;
    await db.transaction((txn) async {
      // First, deactivate all themes for this user
      await txn.update(
        'user_themes',
        {'active': 0},
        where: 'username = ?',
        whereArgs: [username],
      );
      // Then, activate the selected theme
      await txn.update(
        'user_themes',
        {'active': 1},
        where: 'username = ? AND theme = ?',
        whereArgs: [username, themeName],
      );
    });
  }
}

