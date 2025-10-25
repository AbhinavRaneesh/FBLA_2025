import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../data/premade_study_sets.dart';
import '../utils/config.dart';
import 'remote_api_client.dart';

/**
 * A singleton database helper class for managing the EduQuest application's SQLite database.
 * 
 * This class provides a centralized interface for all database operations including
 * user management, study set storage, powerup tracking, and theme purchases. It uses
 * the singleton pattern to ensure only one database instance exists throughout the
 * application lifecycle.
 * 
 * The database schema includes the following tables:
 * - users: Stores user account information and preferences
 * - study_sets: Contains study set metadata
 * - study_set_questions: Stores individual questions within study sets
 * - user_study_sets: Tracks which study sets each user has access to
 * - user_powerups: Manages user-owned powerup items
 * - user_purchased_themes: Tracks theme purchases for each user
 * 
 * Features:
 * - Automatic database initialization and migration
 * - Error handling with database corruption recovery
 * - Premade study set population
 * - User authentication and profile management
 * - Study set CRUD operations
 * - Powerup and theme purchase tracking
 */
class DatabaseHelper {
  /** Singleton instance of the DatabaseHelper */
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  /** The SQLite database instance */
  static Database? _database;

  /**
   * Factory constructor that returns the singleton instance.
   * 
   * @return The singleton DatabaseHelper instance
   */
  factory DatabaseHelper() => _instance;

  /**
   * Private constructor for singleton pattern implementation.
   */
  DatabaseHelper._internal();

  // Remote API client for Mongo-backed operations
  final RemoteApiClient _remote = RemoteApiClient();

  /**
   * Gets the database instance, initializing it if necessary.
   * 
   * This method implements lazy initialization of the database. If the database
   * doesn't exist, it will be created with the proper schema and populated with
   * initial data.
   * 
   * @return A Future that completes with the database instance
   */
  Future<Database> get database async {
    if (_database != null) {
      print('DEBUG: Database already exists, returning existing instance');
      return _database!;
    }
    print('DEBUG: Database does not exist, initializing new database');
    _database = await _initDatabase();
    print('DEBUG: Database initialization completed');
    return _database!;
  }

  /**
   * Initializes the SQLite database with proper error handling.
   * 
   * This method creates the database file and handles potential corruption
   * by deleting and recreating the database if necessary. It sets up the
   * database with version 4 and configures onCreate and onUpgrade callbacks.
   * 
   * @return A Future that completes with the initialized database
   */
  Future<Database> _initDatabase() async {
    String pathStr = path.join(await getDatabasesPath(), 'eduquest.db');
    print('DEBUG: Database path: $pathStr');
    print('DEBUG: Database path exists: ${await databaseExists(pathStr)}');

    try {
      return await openDatabase(
        pathStr,
        version: 4,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      print('DEBUG: Error opening database: $e');
      print('DEBUG: Attempting to delete and recreate database...');

      // Delete the corrupted database
      if (await databaseExists(pathStr)) {
        await deleteDatabase(pathStr);
        print('DEBUG: Corrupted database deleted');
      }

      // Try to open again, which will trigger onCreate
      return await openDatabase(
        pathStr,
        version: 4,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    }
  }

  /**
   * Creates the initial database schema and populates it with default data.
   * 
   * This method is called when the database is first created. It creates all
   * necessary tables with proper relationships and constraints, then populates
   * the database with premade study sets.
   * 
   * @param db The database instance to create tables in
   * @param version The database version being created
   */
  Future<void> _onCreate(Database db, int version) async {
    print('DEBUG: Creating database tables, version: $version');

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
    print('DEBUG: Users table created successfully');

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
    print('DEBUG: Study_sets table created successfully');

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
    print('DEBUG: Study_set_questions table created successfully');

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
    print('DEBUG: User_study_sets table created successfully');

    // Create user_powerups table
    await db.execute('''
      CREATE TABLE user_powerups(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        powerup_id TEXT NOT NULL,
        count INTEGER DEFAULT 1,
        purchased_at TEXT NOT NULL,
        FOREIGN KEY (username) REFERENCES users (username) ON DELETE CASCADE
      )
    ''');
    print('DEBUG: User_powerups table created successfully');

    // Create user_purchased_themes table
    await db.execute('''
      CREATE TABLE user_purchased_themes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        theme_name TEXT NOT NULL,
        purchased_at TEXT NOT NULL,
        UNIQUE(username, theme_name),
        FOREIGN KEY (username) REFERENCES users (username) ON DELETE CASCADE
      )
    ''');
    print('DEBUG: User_purchased_themes table created successfully');

    // Insert default premade study sets
    await _insertPremadeStudySets(db);
    print('DEBUG: Database creation completed successfully');
  }

  /**
   * Handles database schema upgrades between versions.
   * 
   * This method is called when the database version is increased. It performs
   * necessary schema migrations and data updates to maintain compatibility
   * with newer versions of the application.
   * 
   * @param db The database instance to upgrade
   * @param oldVersion The previous database version
   * @param newVersion The new database version
   */
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('DEBUG: Database upgrade from version $oldVersion to $newVersion');
    if (oldVersion < 2) {
      print('DEBUG: Upgrading to version 2 - adding new courses');
      // Add new courses to existing database
      await _insertPremadeStudySets(db);
    }
    if (oldVersion < 3) {
      print('DEBUG: Upgrading to version 3 - adding user_powerups table');
      // Add user_powerups table
      await db.execute('''
        CREATE TABLE user_powerups(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT NOT NULL,
          powerup_id TEXT NOT NULL,
          count INTEGER DEFAULT 1,
          purchased_at TEXT NOT NULL,
          FOREIGN KEY (username) REFERENCES users (username) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 4) {
      print(
          'DEBUG: Upgrading to version 4 - adding user_purchased_themes table');
      try {
        // Add user_purchased_themes table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS user_purchased_themes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            theme_name TEXT NOT NULL,
            purchased_at TEXT NOT NULL,
            UNIQUE(username, theme_name),
            FOREIGN KEY (username) REFERENCES users (username) ON DELETE CASCADE
          )
        ''');
        print('DEBUG: user_purchased_themes table created successfully');

        // Migrate existing users: give them ownership of their current theme if it's not free
        final users = await db.query('users');
        for (var user in users) {
          final username = user['username'] as String;
          final currentTheme = user['current_theme'] as String;

          // If current theme is not 'space' (the free theme), mark it as purchased
          if (currentTheme != 'space') {
            try {
              await db.insert('user_purchased_themes', {
                'username': username,
                'theme_name': currentTheme,
                'purchased_at': DateTime.now().toIso8601String(),
              });
              print(
                  'DEBUG: Migrated theme ownership for user $username: $currentTheme');
            } catch (e) {
              print(
                  'DEBUG: Failed to migrate theme for user $username: $e (possibly already exists)');
            }
          }
        }
      } catch (e) {
        print('DEBUG: Error during database upgrade to version 4: $e');
        // Continue execution - the _ensureThemeTableExists method will handle missing table
      }
    }
    print('DEBUG: Database upgrade completed');
  }

  /**
   * Inserts premade study sets into the database.
   * 
   * This method populates the database with predefined study sets from the
   * PremadeStudySetsRepository. It checks for existing sets to avoid duplicates
   * and inserts both the study set metadata and associated questions.
   * 
   * @param db The database instance to insert data into
   */
  Future<void> _insertPremadeStudySets(Database db) async {
    // Import premade sets from repository
    final premadeSets = PremadeStudySetsRepository.getPremadeSets();

    for (var set in premadeSets) {
      // Check if set already exists
      final existingSets = await db.query(
        'study_sets',
        where: 'name = ? AND is_premade = ?',
        whereArgs: [set.name, 1],
      );

      if (existingSets.isEmpty) {
        // Insert the study set
        final studySetId = await db.insert('study_sets', {
          'name': set.name,
          'description': set.description,
          'username': 'system',
          'is_premade': 1,
          'created_at': DateTime.now().toIso8601String(),
        });

        // Insert the questions
        for (var question in set.questions) {
          await db.insert('study_set_questions', {
            'study_set_id': studySetId,
            'question_text': question.questionText,
            'correct_answer': question.correctAnswer,
            'options': question.options.join('|'),
          });
        }

        debugPrint(
            'Added new premade set: ${set.name} with ${set.questions.length} questions');
      } else {
        debugPrint('Premade set already exists: ${set.name}');
      }
    }

    // Debug: Print all premade sets in database
    final allPremadeSets = await db.query(
      'study_sets',
      where: 'is_premade = ?',
      whereArgs: [1],
    );
    debugPrint('Total premade sets in database: ${allPremadeSets.length}');
    for (var set in allPremadeSets) {
      debugPrint('- ${set['name']}');
    }
  }

  /**
   * Authenticates a user with the provided username and password.
   * 
   * This method checks if the provided credentials match a user record
   * in the database. It performs a simple string comparison for password
   * verification (in a production environment, this should use proper
   * password hashing).
   * 
   * @param username The username to authenticate
   * @param password The password to verify
   * @return A Future that completes with true if authentication succeeds, false otherwise
   */
  Future<bool> authenticateUser(String username, String password) async {
    print('DEBUG: authenticateUser called for username: $username');
    if (AppConfig.useRemoteDb) {
      try {
        final ok = await _remote.login(username, password);
        print('DEBUG: Remote login result: $ok for $username');
        if (ok) return true;
        // If remote login fails, fall back to local SQLite
        print('DEBUG: Remote login failed, trying local SQLite fallback');
      } catch (e) {
        print('DEBUG: Remote login error: $e, falling back to local SQLite');
      }
    }
    // Local SQLite authentication
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    final isAuthenticated = result.isNotEmpty;
    print(
        'DEBUG: User authentication result: $isAuthenticated for username: $username');
    // Best-effort remote provisioning so this user can log in from other devices next time
    if (isAuthenticated && AppConfig.useRemoteDb) {
      try {
        await _remote.register(username, password);
        print('DEBUG: Provisioned remote account for $username');
      } catch (e) {
        // Ignore errors like 409 conflict if already exists
        print('DEBUG: Remote provisioning skipped/failed for $username: $e');
      }
    }
    return isAuthenticated;
  }

  /**
   * Checks if a username already exists in the database.
   * 
   * This method is used during user registration to prevent duplicate usernames.
   * 
   * @param username The username to check for existence
   * @return A Future that completes with true if the username exists, false otherwise
   */
  Future<bool> usernameExists(String username) async {
    print('DEBUG: usernameExists called for username: $username');
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    final exists = result.isNotEmpty;
    print(
        'DEBUG: Username exists check result: $exists for username: $username');
    return exists;
  }

  /**
   * Creates a new user account in the database.
   * 
   * This method inserts a new user record with the provided credentials.
   * New users start with 0 points and the default 'space' theme.
   * 
   * @param username The username for the new account
   * @param password The password for the new account
   * @return A Future that completes with true if user creation succeeds, false otherwise
   */
  Future<bool> addUser(String username, String password) async {
    print('DEBUG: addUser called for username: $username');
    // Create the account in the remote API first when enabled
    if (AppConfig.useRemoteDb) {
      try {
        final ok = await _remote.register(username, password);
        print('DEBUG: Remote register result for $username: $ok');
        if (!ok) {
          print('DEBUG: Remote register returned false for $username');
          return false; // require cloud registration for cross-device access
        }
      } catch (e) {
        // Fail sign-up if cloud registration fails (e.g., 409 user exists or network error)
        print('DEBUG: Remote register error for $username: $e');
        return false;
      }
    }
    final db = await database;
    try {
      final userId = await db.insert('users', {
        'username': username,
        'password': password,
        'points': 0,
        'current_theme': 'space',
        'created_at': DateTime.now().toIso8601String(),
      });
      print(
          'DEBUG: User created successfully with ID: $userId, username: $username, initial points: 0');
      return true;
    } catch (e) {
      print('DEBUG: Error creating user: $e');
      // Log error in debug mode only
      return false;
    }
  }

  /**
   * Creates a new study set in the database.
   * 
   * This method creates a study set record with the provided metadata.
   * The study set is marked as user-created (not premade) and associated
   * with the specified username.
   * 
   * @param name The name of the study set
   * @param description The description of the study set
   * @param username The username of the creator
   * @return A Future that completes with the ID of the created study set
   */
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

  /**
   * Adds a question to an existing study set.
   * 
   * This method inserts a new question record associated with the specified
   * study set. The options are stored as a pipe-separated string for
   * database storage efficiency.
   * 
   * @param studySetId The ID of the study set to add the question to
   * @param questionText The question text
   * @param correctAnswer The correct answer for the question
   * @param options The list of answer options
   */
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

  /**
   * Retrieves all study sets created by a specific user.
   * 
   * This method returns study sets that are owned by the specified user,
   * ordered by creation date (newest first).
   * 
   * @param username The username whose study sets to retrieve
   * @return A Future that completes with a list of study set records
   */
  Future<List<Map<String, dynamic>>> getUserStudySets(String username) async {
    final db = await database;
    return await db.query(
      'study_sets',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'created_at DESC',
    );
  }

  /**
   * Retrieves all questions for a specific study set.
   * 
   * This method returns all questions associated with the specified study set ID.
   * 
   * @param studySetId The ID of the study set whose questions to retrieve
   * @return A Future that completes with a list of question records
   */
  Future<List<Map<String, dynamic>>> getStudySetQuestions(
      int studySetId) async {
    final db = await database;
    return await db.query(
      'study_set_questions',
      where: 'study_set_id = ?',
      whereArgs: [studySetId],
    );
  }

  /**
   * Deletes a study set for a specific user.
   * 
   * This method removes the association between a user and a study set
   * from the user_study_sets table.
   * 
   * @param username The username who owns the study set
   * @param setName The name of the study set to delete
   */
  Future<void> deleteStudySet(String username, String setName) async {
    final db = await database;
    await db.delete(
      'user_study_sets',
      where: 'username = ? AND set_name = ?',
      whereArgs: [username, setName],
    );
  }

  /**
   * Retrieves all premade study sets from the database.
   * 
   * This method returns all study sets that are marked as premade (system-created),
   * ordered alphabetically by name.
   * 
   * @return A Future that completes with a list of premade study set records
   */
  Future<List<Map<String, dynamic>>> getPremadeStudySets() async {
    final db = await database;
    return await db.query(
      'study_sets',
      where: 'is_premade = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
  }

  /**
   * Checks if all premade study sets from the repository are loaded in the database.
   * 
   * This method compares the study sets available in the PremadeStudySetsRepository
   * with those stored in the database to ensure all premade sets are properly loaded.
   * 
   * @return A Future that completes with true if all sets are loaded, false otherwise
   */
  Future<bool> areAllPremadeSetsLoaded() async {
    final db = await database;
    final premadeSets = PremadeStudySetsRepository.getPremadeSets();
    final dbSets = await db.query(
      'study_sets',
      where: 'is_premade = ?',
      whereArgs: [1],
    );

    debugPrint(
        'Repository has ${premadeSets.length} sets, database has ${dbSets.length} sets');

    // Check if all repository sets exist in database
    for (var set in premadeSets) {
      final exists = dbSets.any((dbSet) => dbSet['name'] == set.name);
      if (!exists) {
        debugPrint('Missing set in database: ${set.name}');
        return false;
      }
    }

    return true;
  }

  /**
   * Refreshes the premade study sets in the database.
   * 
   * This method synchronizes the database with the current state of the
   * PremadeStudySetsRepository. It adds new sets, updates existing ones,
   * and removes obsolete sets to maintain consistency.
   */
  Future<void> refreshPremadeSets() async {
    final db = await database;

    // Get existing premade sets
    final existingSets = await db.query(
      'study_sets',
      where: 'is_premade = ?',
      whereArgs: [1],
    );

    // Get all premade sets from repository
    final premadeSets = PremadeStudySetsRepository.getPremadeSets();

    debugPrint(
        'Refreshing premade sets: ${existingSets.length} existing, ${premadeSets.length} in repository');

    for (var set in premadeSets) {
      // Check if set already exists
      final existingSet = existingSets.firstWhere(
        (existing) => existing['name'] == set.name,
        orElse: () => {},
      );

      if (existingSet.isEmpty) {
        // Insert new set
        final studySetId = await db.insert('study_sets', {
          'name': set.name,
          'description': set.description,
          'username': 'system',
          'is_premade': 1,
          'created_at': DateTime.now().toIso8601String(),
        });

        // Insert the questions
        for (var question in set.questions) {
          await db.insert('study_set_questions', {
            'study_set_id': studySetId,
            'question_text': question.questionText,
            'correct_answer': question.correctAnswer,
            'options': question.options.join('|'),
          });
        }

        debugPrint('Added new premade set: ${set.name} with ID $studySetId');
      } else {
        // Update existing set (preserve ID)
        final studySetId = existingSet['id'];
        await db.update(
          'study_sets',
          {
            'description': set.description,
            'created_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [studySetId],
        );

        // Delete old questions and insert new ones
        await db.delete(
          'study_set_questions',
          where: 'study_set_id = ?',
          whereArgs: [studySetId],
        );

        for (var question in set.questions) {
          await db.insert('study_set_questions', {
            'study_set_id': studySetId,
            'question_text': question.questionText,
            'correct_answer': question.correctAnswer,
            'options': question.options.join('|'),
          });
        }

        debugPrint(
            'Updated existing premade set: ${set.name} with ID $studySetId');
      }
    }

    // Remove any premade sets that are no longer in the repository
    for (var existingSet in existingSets) {
      final stillExists =
          premadeSets.any((repoSet) => repoSet.name == existingSet['name']);
      if (!stillExists) {
        await db.delete(
          'study_sets',
          where: 'id = ?',
          whereArgs: [existingSet['id']],
        );
        debugPrint('Removed obsolete premade set: ${existingSet['name']}');
      }
    }

    // Debug: Print all premade sets in database after refresh
    final allPremadeSets = await db.query(
      'study_sets',
      where: 'is_premade = ?',
      whereArgs: [1],
    );
    debugPrint(
        'Total premade sets in database after refresh: ${allPremadeSets.length}');
    for (var set in allPremadeSets) {
      debugPrint('- ${set['name']} (ID: ${set['id']})');
    }
  }

  /**
   * Associates a study set with a user.
   * 
   * This method creates a relationship between a user and a study set,
   * allowing the user to access the study set for practice.
   * 
   * @param username The username to associate with the study set
   * @param studySetId The ID of the study set to associate
   */
  Future<void> addStudySetToUser(String username, int studySetId) async {
    final db = await database;
    final userId = await getUserId(username);

    await db.insert('user_study_sets', {
      'user_id': userId,
      'study_set_id': studySetId,
    });
  }

  /**
   * Retrieves the user ID for a given username.
   * 
   * This helper method is used to get the internal user ID from the username,
   * which is needed for foreign key relationships in other tables.
   * 
   * @param username The username to look up
   * @return A Future that completes with the user ID
   */
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
    print('DEBUG: getUserPoints called for username: $username');
    if (AppConfig.useRemoteDb) {
      try {
        final points = await _remote.getUserPoints(username).timeout(
          Duration(seconds: 8),
          onTimeout: () {
            print('DEBUG: Remote getUserPoints timed out, falling back to local');
            throw TimeoutException('getUserPoints timeout');
          },
        );
        print('DEBUG: Remote points returned: $points');
        return points;
      } catch (e) {
        print('DEBUG: Remote getUserPoints error: $e, falling back to local');
        // Fall back to local on timeout or error
      }
    }
    try {
      final db = await database;
      final result = await db.query(
        'users',
        columns: ['points'],
        where: 'username = ?',
        whereArgs: [username],
      );

      if (result.isEmpty) {
        print('DEBUG: getUserPoints - No user found for username: $username');
        return 0;
      }

      final points = result.first['points'] as int;
      print('DEBUG: getUserPoints returned: $points for username: $username');
      return points;
    } catch (e) {
      print('DEBUG: getUserPoints error: $e');
      print('DEBUG: getUserPoints stack trace: ${StackTrace.current}');
      return 0;
    }
    
  }

  Future<void> updateUserPoints(String username, int points) async {
    print('DEBUG: updateUserPoints called for username: $username with points: $points');
    if (AppConfig.useRemoteDb) {
      try {
        await _remote.setUserPoints(username, points).timeout(
          Duration(seconds: 8),
          onTimeout: () {
            print('DEBUG: Remote updateUserPoints timed out, falling back to local');
            throw TimeoutException('updateUserPoints timeout');
          },
        );
        print('DEBUG: Remote updateUserPoints ok');
        return;
      } catch (e) {
        print('DEBUG: Remote updateUserPoints error: $e, falling back to local');
        // Fall back to local on timeout or error
      }
    }
    try {
      final db = await database;
      final result = await db.update(
        'users',
        {'points': points},
        where: 'username = ?',
        whereArgs: [username],
      );
      print('DEBUG: updateUserPoints completed. Rows affected: $result for username: $username');

      if (result == 0) {
        print('DEBUG: updateUserPoints - No rows were updated for username: $username');
      }
    } catch (e) {
      print('DEBUG: updateUserPoints error: $e');
      print('DEBUG: updateUserPoints stack trace: ${StackTrace.current}');
      throw e;
    }
  }

  Future<String?> getCurrentTheme(String username) async {
    if (AppConfig.useRemoteDb) {
      try {
        return await _remote.getCurrentTheme(username).timeout(
          Duration(seconds: 8),
          onTimeout: () {
            print('DEBUG: Remote getCurrentTheme timed out, falling back to local');
            throw TimeoutException('getCurrentTheme timeout');
          },
        );
      } catch (e) {
        print('DEBUG: Remote getCurrentTheme error: $e, falling back to local');
        // Fall back to local
      }
    }
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
    if (AppConfig.useRemoteDb) {
      try {
        await _remote.setCurrentTheme(username, theme).timeout(
          Duration(seconds: 8),
          onTimeout: () {
            print('DEBUG: Remote updateCurrentTheme timed out, falling back to local');
            throw TimeoutException('updateCurrentTheme timeout');
          },
        );
        return;
      } catch (e) {
        print('DEBUG: Remote updateCurrentTheme error: $e, falling back to local');
        // Fall back to local
      }
    }
    final db = await database;
    await db.update(
      'users',
      {'current_theme': theme},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  Future<bool> userOwnsTheme(String username, String theme) async {
    // Space theme is free for everyone
    if (theme == 'space') {
      return true;
    }
    if (AppConfig.useRemoteDb) {
      try {
        final owned = await getUserOwnedThemes(username);
        return owned.contains(theme);
      } catch (e) {
        return false;
      }
    }
    final db = await database;
    try {
      await _ensureThemeTableExists(db);
      final result = await db.query(
        'user_purchased_themes',
        where: 'username = ? AND theme_name = ?',
        whereArgs: [username, theme],
      );
      return result.isNotEmpty;
    } catch (e) {
      print('DEBUG: Error in userOwnsTheme: $e');
      return false; // If there's an error, assume user doesn't own theme
    }
  }

  Future<List<String>> getUserOwnedThemes(String username) async {
    if (AppConfig.useRemoteDb) {
      try {
        final themes = await _remote.getUserOwnedThemes(username).timeout(
          Duration(seconds: 8),
          onTimeout: () {
            print('DEBUG: Remote getUserOwnedThemes timed out, falling back to local');
            throw TimeoutException('getUserOwnedThemes timeout');
          },
        );
        return {'space', ...themes}.toList();
      } catch (e) {
        print('DEBUG: Remote getUserOwnedThemes: $e, falling back to local');
        // Fall back to local
      }
    }
    final db = await database;
    try {
      await _ensureThemeTableExists(db);
      final result = await db.query(
        'user_purchased_themes',
        where: 'username = ?',
        whereArgs: [username],
      );
      List<String> ownedThemes = ['space'];
      for (var row in result) {
        ownedThemes.add(row['theme_name'] as String);
      }
      return ownedThemes;
    } catch (e) {
      print('DEBUG: Error in getUserOwnedThemes: $e');
      return ['space'];
    }
  }

  Future<void> purchaseTheme(String username, String theme) async {
    print('DEBUG: purchaseTheme called for user: $username, theme: $theme');
    if (AppConfig.useRemoteDb) {
      try {
        await _remote.purchaseTheme(username, theme).timeout(
          Duration(seconds: 8),
          onTimeout: () {
            print('DEBUG: Remote purchaseTheme timed out, falling back to local');
            throw TimeoutException('purchaseTheme timeout');
          },
        );
        await _remote.setCurrentTheme(username, theme).timeout(
          Duration(seconds: 8),
          onTimeout: () {
            print('DEBUG: Remote setCurrentTheme timed out after purchase');
            throw TimeoutException('setCurrentTheme timeout');
          },
        );
        return;
      } catch (e) {
        print('DEBUG: Remote purchaseTheme error: $e, falling back to local');
        // Fall back to local on timeout or error
      }
    }
    final db = await database;
    try {
      await _ensureThemeTableExists(db);
      final existingPurchase = await db.query(
        'user_purchased_themes',
        where: 'username = ? AND theme_name = ?',
        whereArgs: [username, theme],
      );
      if (existingPurchase.isNotEmpty) {
        print('DEBUG: User $username already owns theme $theme');
        throw Exception('You already own this theme');
      }
      await db.insert('user_purchased_themes', {
        'username': username,
        'theme_name': theme,
        'purchased_at': DateTime.now().toIso8601String(),
      });
      await db.update(
        'users',
        {'current_theme': theme},
        where: 'username = ?',
        whereArgs: [username],
      );
      print('DEBUG: Theme purchase recorded and current theme set');
    } catch (e) {
      print('DEBUG: Error in purchaseTheme: $e');
      print('DEBUG: Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<void> _ensureThemeTableExists(Database db) async {
    try {
      // Try to query the table to see if it exists
      await db.rawQuery('SELECT 1 FROM user_purchased_themes LIMIT 1');
      print('DEBUG: user_purchased_themes table exists');
    } catch (e) {
      print(
          'DEBUG: user_purchased_themes table does not exist, creating it...');
      // Create the table if it doesn't exist
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_purchased_themes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT NOT NULL,
          theme_name TEXT NOT NULL,
          purchased_at TEXT NOT NULL,
          UNIQUE(username, theme_name),
          FOREIGN KEY (username) REFERENCES users (username) ON DELETE CASCADE
        )
      ''');
      print('DEBUG: user_purchased_themes table created successfully');
    }
  }

  Future<void> importPremadeSet(String username, int studySetId) async {
    if (AppConfig.useRemoteDb) {
      try {
        String? setName;
        try {
          final db = await database;
          final res = await db.query('study_sets', where: 'id = ?', whereArgs: [studySetId]);
          if (res.isNotEmpty) setName = res.first['name'] as String?;
        } catch (_) {}
        if (setName == null) {
          debugPrint('Could not resolve study set name for ID $studySetId');
          return;
        }
  await _remote.addImportedSet(username, setName, studySetId: studySetId).timeout(
          Duration(seconds: 8),
          onTimeout: () {
            debugPrint('Remote addImportedSet timed out, falling back to local');
            throw TimeoutException('addImportedSet timeout');
          },
        );
        debugPrint('Remote: Imported set "$setName" for $username');
        return;
      } catch (e) {
        debugPrint('Remote importPremadeSet error: $e, falling back to local');
        // Fall back to local
      }
    }
    final db = await database;
    final userId = await getUserId(username);
    debugPrint('Attempting to import set ID $studySetId for user $username (ID: $userId)');
    final existingSet = await db.query(
      'user_study_sets',
      where: 'user_id = ? AND study_set_id = ?',
      whereArgs: [userId, studySetId],
    );
    if (existingSet.isEmpty) {
      debugPrint('User does not have set ID $studySetId, adding it...');
      await db.insert('user_study_sets', {
        'user_id': userId,
        'study_set_id': studySetId,
      });
      debugPrint('Successfully added set ID $studySetId to user $username');
    } else {
      debugPrint('User already has set ID $studySetId, skipping import');
    }

    final allUserSets = await db.rawQuery('''
      SELECT s.* FROM study_sets s
      INNER JOIN user_study_sets us ON s.id = us.study_set_id
      WHERE us.user_id = ?
    ''', [userId]);
    debugPrint('User $username now has ${allUserSets.length} imported sets:');
    for (var set in allUserSets) {
      debugPrint('- ${set['name']} (ID: ${set['id']})');
    }
  }

  Future<List<Map<String, dynamic>>> getUserImportedSets(
      String username) async {
    if (AppConfig.useRemoteDb) {
      try {
        final sets = await _remote.getUserImportedSets(username).timeout(
          Duration(seconds: 8),
          onTimeout: () {
            debugPrint('Remote getUserImportedSets timed out, falling back to local');
            throw TimeoutException('getUserImportedSets timeout');
          },
        );
        // Enrich remote data with local IDs by matching set names
        final db = await database;
        final enrichedSets = <Map<String, dynamic>>[];
        for (var remoteSet in sets) {
          final setName = remoteSet['name'] as String?;
          if (setName != null) {
            final localMatch = await db.query('study_sets', where: 'name = ?', whereArgs: [setName]);
            if (localMatch.isNotEmpty) {
              enrichedSets.add(localMatch.first);
            } else {
              // Fallback: use name-only with placeholder id
              enrichedSets.add({'id': 0, 'name': setName});
            }
          }
        }
        return enrichedSets;
      } catch (e) {
        debugPrint('Remote getUserImportedSets error: $e, falling back to local');
        // Fall back to local
      }
    }
    final db = await database;
    final userId = await getUserId(username);
    final result = await db.rawQuery('''
      SELECT s.* FROM study_sets s
      INNER JOIN user_study_sets us ON s.id = us.study_set_id
      WHERE us.user_id = ?
    ''', [userId]);
    debugPrint('User $username (ID: $userId) has ${result.length} imported sets:');
    for (var set in result) {
      debugPrint('- ${set['name']} (ID: ${set['id']})');
    }
    return result;
  }

  Future<void> removeImportedSet(String username, int setId) async {
    if (AppConfig.useRemoteDb) {
      try {
        String? setName;
        try {
          final db = await database;
          final res = await db.query('study_sets', where: 'id = ?', whereArgs: [setId]);
          if (res.isNotEmpty) setName = res.first['name'] as String?;
        } catch (_) {}
        if (setName != null) {
          await _remote.removeImportedSet(username, setName).timeout(
            Duration(seconds: 8),
            onTimeout: () {
              debugPrint('Remote removeImportedSet timed out, falling back to local');
              throw TimeoutException('removeImportedSet timeout');
            },
          );
        }
        return;
      } catch (e) {
        debugPrint('Remote removeImportedSet error: $e, falling back to local');
        // Fall back to local
      }
    }
    final db = await database;
    final userId = await getUserId(username);
    await db.delete(
      'user_study_sets',
      where: 'user_id = ? AND study_set_id = ?',
      whereArgs: [userId, setId],
    );
  }

  Future<int> getStudySetQuestionCount(int studySetId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM study_set_questions WHERE study_set_id = ?',
      [studySetId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> updateStudySet(
    int studySetId,
    String name,
    String description,
  ) async {
    final db = await database;
    await db.update(
      'study_sets',
      {
        'name': name,
        'description': description,
      },
      where: 'id = ?',
      whereArgs: [studySetId],
    );
  }

  Future<void> updateQuestion(
    int questionId,
    String questionText,
    String correctAnswer,
    List<String> options,
  ) async {
    final db = await database;
    await db.update(
      'study_set_questions',
      {
        'question_text': questionText,
        'correct_answer': correctAnswer,
        'options': options.join('|'),
      },
      where: 'id = ?',
      whereArgs: [questionId],
    );
  }

  Future<void> deleteQuestion(int questionId) async {
    final db = await database;
    await db.delete(
      'study_set_questions',
      where: 'id = ?',
      whereArgs: [questionId],
    );
  }

  // Powerup methods
  Future<Map<String, int>> getUserPowerups(String username) async {
    if (AppConfig.useRemoteDb) {
      try {
        return await _remote.getUserPowerups(username).timeout(
          Duration(seconds: 8),
          onTimeout: () {
            debugPrint('Remote getUserPowerups timed out, falling back to local');
            throw TimeoutException('getUserPowerups timeout');
          },
        );
      } catch (e) {
        debugPrint('Remote getUserPowerups error: $e, falling back to local');
        // Fall back to local
      }
    }
    final db = await database;
    final result = await db.query(
      'user_powerups',
      where: 'username = ?',
      whereArgs: [username],
    );
    Map<String, int> powerups = {};
    for (var row in result) {
      final powerupId = row['powerup_id'] as String;
      final count = row['count'] as int;
      powerups[powerupId] = (powerups[powerupId] ?? 0) + count;
    }
    return powerups;
  }

  Future<void> purchasePowerup(String username, String powerupId) async {
    if (AppConfig.useRemoteDb) {
      try {
        await _remote.purchasePowerup(username, powerupId).timeout(
          Duration(seconds: 8),
          onTimeout: () {
            debugPrint('Remote purchasePowerup timed out, falling back to local');
            throw TimeoutException('purchasePowerup timeout');
          },
        );
        return;
      } catch (e) {
        debugPrint('Remote purchasePowerup error: $e, falling back to local');
        // Fall back to local
      }
    }
    final db = await database;
    final existingPowerup = await db.query(
      'user_powerups',
      where: 'username = ? AND powerup_id = ?',
      whereArgs: [username, powerupId],
    );
    if (existingPowerup.isNotEmpty) {
      final currentCount = existingPowerup.first['count'] as int;
      await db.update(
        'user_powerups',
        {'count': currentCount + 1},
        where: 'username = ? AND powerup_id = ?',
        whereArgs: [username, powerupId],
      );
    } else {
      await db.insert('user_powerups', {
        'username': username,
        'powerup_id': powerupId,
        'count': 1,
        'purchased_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> usePowerup(String username, String powerupId) async {
    if (AppConfig.useRemoteDb) {
      try {
        await _remote.usePowerup(username, powerupId).timeout(
          Duration(seconds: 8),
          onTimeout: () {
            debugPrint('Remote usePowerup timed out, falling back to local');
            throw TimeoutException('usePowerup timeout');
          },
        );
        return;
      } catch (e) {
        debugPrint('Remote usePowerup error: $e, falling back to local');
        // Fall back to local
      }
    }
    final db = await database;
    final existingPowerup = await db.query(
      'user_powerups',
      where: 'username = ? AND powerup_id = ?',
      whereArgs: [username, powerupId],
    );
    if (existingPowerup.isNotEmpty) {
      final currentCount = existingPowerup.first['count'] as int;
      if (currentCount > 1) {
        await db.update(
          'user_powerups',
          {'count': currentCount - 1},
          where: 'username = ? AND powerup_id = ?',
          whereArgs: [username, powerupId],
        );
      } else {
        await db.delete(
          'user_powerups',
          where: 'username = ? AND powerup_id = ?',
          whereArgs: [username, powerupId],
        );
      }
    }
  }

  Future<int> getPowerupCount(String username, String powerupId) async {
    final db = await database;
    final result = await db.query(
      'user_powerups',
      columns: ['count'],
      where: 'username = ? AND powerup_id = ?',
      whereArgs: [username, powerupId],
    );

    if (result.isNotEmpty) {
      return result.first['count'] as int;
    }
    return 0;
  }
}
