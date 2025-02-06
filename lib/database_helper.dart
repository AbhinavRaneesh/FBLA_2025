import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<bool> checkIfUserExists(String username) async {
    try {
      final db = await getDatabase();
      final List<Map<String, dynamic>> result = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );

      return result.isNotEmpty; // If the result is not empty, the user exists
    } catch (e) {
      print('Error checking if user exists: $e');
      return false; // Assume user doesn't exist on error
    }
  }


  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Add a new user to the database
  Future<bool> addUser(String username, String password) async {
    try {
      final db = await getDatabase();
      await db.insert(
        'users',
        {
          'username': username, // Username provided by sign-up
          'password': password, // Storing password directly (or hash it before saving)
        },
        conflictAlgorithm: ConflictAlgorithm.fail, // Fail if username duplicates
      );
      print('User $username added successfully.');
      return true;
    } catch (e) {
      print('Error adding user: $e');
      return false;
    }
  }

  // Helper to mock a real DB (replace with your implementation)
  Future<Database> getDatabase() async {
    // Example using sqflite
    return openDatabase(
      'student_learning_app.db',
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT
          )
        ''');
      },
    );
  }



  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT
      )
    ''');
  }

  // Insert a new user
  Future<void> insertUser(String username, String password) async {
    final db = await database;
    await db.insert(
      'users',
      {'username': username, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Check if a user exists with the given username and password
  Future<bool> authenticateUser(String username, String password) async {
    try {
      final db = await getDatabase();

      // Query to find a user with the given username and password
      final List<Map<String, dynamic>> result = await db.query(
        'users',
        where: 'username = ? AND password = ?', // Match username and password
        whereArgs: [username, password], // Provide arguments to prevent SQL injection
      );

      print('Authentication query result: $result'); // Debugging

      return result.isNotEmpty; // If result is not empty, user exists and is authenticated
    } catch (e) {
      print('Error during authentication: $e');
      return false; // Return false if authentication fails
    }
  }

  Future<void> printAllUsers() async {
    try {
      final db = await getDatabase();
      final List<Map<String, dynamic>> users = await db.query('users');
      print('Current Users in the Database:');
      for (var user in users) {
        print('ID: ${user['id']}, Username: ${user['username']}, Password: ${user['password']}');
      }
    } catch (e) {
      print('Error while fetching users: $e');
    }
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

  // Fetch all users
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  // Delete a user by ID
  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
